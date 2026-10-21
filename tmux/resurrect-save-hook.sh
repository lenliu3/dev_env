#!/usr/bin/env bash
# tmux-resurrect post-save-layout hook: patches the save file ($1) in place so
# restore brings panes back closer to how they were.
#
# - claude panes resume their live conversation as `claude --resume <id>`.
#   ps argv goes stale after /clear or an in-app /resume, so the id comes from
#   Claude's per-process registry ($CLAUDE_CONFIG_DIR/sessions/<pid>.json).
#   Launch flags are dropped: ps joins argv without quoting, and replaying a
#   positional prompt or -p would resend it. claude panes replay from claude's
#   own cwd, which is the worktree if it entered one.
# - vi, vim, nvim or view launched with a non-flag argument (typically a
#   path) is replayed from the cwd of the process the pane started (normally
#   the shell) rather than its own. nvim-tree lcd's into a directory argument,
#   so `nvim docs/foo` would otherwise be replayed from inside docs/foo. Other
#   programs don't chdir themselves, so their own cwd is where they launched.
# - A pane with nothing running gets no command. resurrect finds a pane's
#   program by parent-pid prefix and can pick up another pane's.
# - Sessions named in @resurrect-skip-sessions are left out, for sessions some
#   other process recreates itself (say a cron job, which can be what starts
#   tmux after a reboot). Restoring them too would swap its pane for a bare
#   shell (a from-scratch restore overwrites the only pane) and leave shells it
#   then adds its panes next to, as second windows.

set -u

save_file=${1:?usage: $0 <resurrect save file>}
claude_dir=${CLAUDE_CONFIG_DIR:-$HOME/.claude}
uuid_re='^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
skip_sessions=$(tmux show-option -gqv @resurrect-skip-sessions)

# Read a string field from the registry's flat single-line JSON ($2).
json_field() {
  printf '%s\n' "$2" | sed -n "s/.*\"$1\":\"\([^\"]*\)\".*/\1/p"
}

# Print the session id of claude process $1, or nothing if it has no usable
# registry entry.
claude_session_id() {
  local pid=$1 reg="$claude_dir/sessions/$1.json" comm json start sid
  [ -f "$reg" ] || return 0
  comm=$(cat "/proc/$pid/comm" 2>/dev/null || ps -o comm= -p "$pid" 2>/dev/null)
  [ "${comm##*/}" = claude ] || return 0
  # Claude rewrites the file in place on status changes; retry a torn read.
  json=$(cat "$reg" 2>/dev/null)
  case $json in
    *'}') ;;
    *) sleep 0.2; json=$(cat "$reg" 2>/dev/null) ;;
  esac
  case $json in
    *'}') ;;
    *) return 0 ;;
  esac
  # -p runs register too, as entrypoint sdk-cli; they have nothing to resume.
  [ "$(json_field kind "$json")" = interactive ] || return 0
  [ "$(json_field entrypoint "$json")" = cli ] || return 0
  # A SIGKILLed claude leaves its entry behind; reject one whose pid was reused.
  if [ -r "/proc/$pid/stat" ]; then
    start=$(sed 's/.*) //' "/proc/$pid/stat" | cut -d' ' -f20)
    [ "$(json_field procStart "$json")" = "$start" ] || return 0
  fi
  sid=$(json_field sessionId "$json")
  [[ $sid =~ $uuid_re ]] || return 0
  # No transcript yet (no prompt since start or fork) means --resume would fail;
  # the pane then keeps its saved argv.
  compgen -G "$claude_dir/projects/*/$sid.jsonl" >/dev/null || return 0
  echo "$sid"
}

# /proc reads where available: pgrep and ps each scan every process.
children_of() {
  cat "/proc/$1/task/$1/children" 2>/dev/null || pgrep -P "$1"
}

proc_cwd() {
  readlink "/proc/$1/cwd" 2>/dev/null && return
  command -v lsof >/dev/null 2>&1 &&
    lsof -a -p "$1" -d cwd -Fn 2>/dev/null | sed -n 's/^n//p'
}

map=$(mktemp) || exit 1
# Plain redirection (not mktemp) so the file gets resurrect's umask mode; the
# resurrect dir is private, and its backup pruning only globs *.txt.
tmp=$save_file.hook.$$
trap 'rm -f "$map" "$tmp"' EXIT

# One line per live pane: session, window, pane, claude session id, escaped
# dir to replay from, and 1 if nothing runs in it.
t=$'\t'
tmux list-panes -a -F "#{session_name}$t#{window_index}$t#{pane_index}$t#{pane_pid}" |
  while IFS=$t read -r s w p pane_pid; do
    children=$(children_of "$pane_pid")
    sid= dir= cwd_pid=$pane_pid
    # pane_pid is claude itself when the pane was created to run it directly.
    for pid in $pane_pid $children; do
      sid=$(claude_session_id "$pid")
      [ -n "$sid" ] && { cwd_pid=$pid; break; }
    done
    # An idle pane's dir only needs re-escaping; skip the slow lsof without /proc.
    if [ -n "$sid$children" ] || [ -d "/proc/$pane_pid" ]; then
      dir=$(proc_cwd "$cwd_pid")
      case $dir in
        /*) ;;
        *) dir= ;;
      esac
      case $dir in
        *$'\t'* | *$'\n'* | *\\*) dir= ;;
      esac
      # Restore reads this field with backslash-unescaping `read`.
      dir=${dir// /\\ }
    fi
    idle=0
    [ -z "$sid$children" ] && idle=1
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$s" "$w" "$p" "$sid" "$dir" "$idle"
  done >"$map"

# Pane lines have 11 fields; dir ($8) and command ($11) carry a ':' guard. A
# line whose $8 lacks it was shifted by an empty pane title and is left alone,
# as is a pane that closed since resurrect listed it.
awk -F'\t' -v OFS='\t' -v skip_list="$skip_sessions" '
  BEGIN { n = split(skip_list, names, " "); for (i = 1; i <= n; i++) skip[names[i]] = 1 }
  FILENAME == ARGV[1] {
    k = $1 SUBSEP $2 SUBSEP $3; sid[k] = $4; dir[k] = $5; idle[k] = $6
    if ($4 != "") live[$4] = 1
    next
  }
  # Untyped lines continue a multi-line pane command and go with their pane line.
  $1 == "pane" || $1 == "window" || $1 == "grouped_session" {
    drop = ($2 in skip) || ($1 == "grouped_session" && ($3 in skip))
  }
  $1 == "state" {
    drop = 0
    # Restore reads this line with a tab-IFS `read`, which collapses an empty
    # field, so a skipped client session gives way to the last session.
    if ($3 in skip) $3 = ""
    if ($2 in skip) { $2 = $3; $3 = "" }
  }
  drop { next }
  $1 == "pane" && NF == 11 && $8 ~ /^:/ && (($2 SUBSEP $3 SUBSEP $6) in idle) {
    k = $2 SUBSEP $3 SUBSEP $6
    if (sid[k] != "") {
      # Keep in sync with @resurrect-processes in tmux.conf, which restores only these forms.
      $11 = ":claude --resume " sid[k]
      # Two panes on one conversation would interleave writes into one transcript.
      if (sid[k] in seen) $11 = $11 " --fork-session"
      seen[sid[k]] = 1
      if (dir[k] != "") $8 = ":" dir[k]
    } else if (idle[k]) {
      $11 = ":"
      # Same dir resurrect saw, minus its space collapsing and partial escaping.
      if (dir[k] != "") $8 = ":" dir[k]
    } else if ($11 ~ /^:claude --resume [0-9a-f-]+( --fork-session)?$/) {
      # Unresolved, so restore replays this argv as is. A pane live on the id
      # owns it, and a replayed fork writes to a new id, so neither claims it.
      split($11, argv, " ")
      if ($11 !~ / --fork-session$/) {
        if ((argv[3] in live) || (argv[3] in seen)) $11 = $11 " --fork-session"
        else seen[argv[3]] = 1
      }
    } else if (dir[k] != "" && $11 ~ /^:[^ ]+ (.* )?[^- ]/) {
      # Only when the replayed editor ($11, the child of the pane shell) is
      # also the foreground program ($10), which a nested shell breaks. Bare
      # nvim after :cd keeps its own cwd: that is where it was, and nothing
      # relative is replayed.
      split(substr($11, 2), argv, " ")
      n = split(argv[1], path, "/")
      if (path[n] == $10 && $10 ~ /^(vi|vim|nvim|view)$/) $8 = ":" dir[k]
    }
  }
  { print }
' "$map" "$save_file" >"$tmp" && mv "$tmp" "$save_file"
