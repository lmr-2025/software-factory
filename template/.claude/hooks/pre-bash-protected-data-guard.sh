#!/usr/bin/env bash
# PreToolUse(Bash) — a session never deletes protected data.
#
# Some storage is the owner's to remove and nobody else's: a customer's data
# directory, a database volume, a backup. A session with a shell can remove it
# with one mistyped command (a `down -v` meant for a different project). This
# hook refuses the commands that delete that storage. The owner removes it
# from their own terminal, where no hook runs.
#
# What counts as protected:
#   * any directory holding a `.protected-data` marker file, or inside one
#     (found by walking up from the path);
#   * any Docker volume whose name starts with $PROTECTED_VOLUME_PREFIX
#     (default `protected-`).
#
# Refused:
#   * `rm` whose target, cwd or leading `cd` sits in a protected directory;
#   * `docker volume rm` naming a protected volume, or naming volumes this hook
#     cannot read (`$(…)`, backticks, variables) while any protected volume
#     exists;
#   * `docker compose … down -v|--volumes` run from, or pointed at, a
#     protected directory;
#   * `docker volume prune` and `docker system prune --volumes` while any
#     protected volume exists.

set -uo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/_common.sh"

read_payload
cmd="$(field '.tool_input.command')"
[[ -z "$cmd" ]] && exit 0

PREFIX="${PROTECTED_VOLUME_PREFIX:-protected-}"

# Heredoc bodies and comments are text, not commands. Quoted strings stay,
# because paths arrive quoted.
text="$(printf '%s' "$cmd" | awk '
  BEGIN { in_heredoc = 0 }
  {
    line = $0
    if (in_heredoc) { if (line == delim) in_heredoc = 0; next }
    if (match(line, /<<-?[[:space:]]*['\''"]?[A-Za-z_][A-Za-z0-9_]*['\''"]?/)) {
      d = substr(line, RSTART, RLENGTH)
      gsub(/^<<-?[[:space:]]*/, "", d); gsub(/['\''"]/, "", d)
      delim = d; in_heredoc = 1
    }
    sub(/[[:space:]]#.*$/, "", line)
    print line
  }')"

says() { printf '%s' "$text" | grep -Eq -- "$1"; }
refuse() {
  block "Blocked: $1. Protected data (a directory with a .protected-data marker, or a Docker volume named ${PREFIX}*) is removed only by the owner, from their own terminal. If this is meant, ask them to run it."
}
unquote() { printf '%s' "$1" | tr -d "\"'"; }

# True when the path is, is inside, or directly holds a protected directory.
protected_path() {
  local d="${1/#\~/$HOME}"
  [ -e "$d" ] || return 1
  [ -d "$d" ] || d="$(dirname -- "$d")"
  d="$(cd -- "$d" 2>/dev/null && pwd -P)" || return 1
  compgen -G "$d/*/.protected-data" >/dev/null && return 0
  while [ -n "$d" ]; do
    [ -f "$d/.protected-data" ] && return 0
    [ "$d" = / ] && return 1
    d="$(dirname -- "$d")"
  done
  return 1
}

volume_rm='docker[[:space:]]+volume[[:space:]]+(rm|remove)([[:space:]]|$)'
down_v='docker([[:space:]]+|-)compose([[:space:]].*)?[[:space:]]down([[:space:]].*)?[[:space:]](-v|--volumes)([[:space:]]|$)'
rm_path='(^|[;&|(){}[:space:]])rm[[:space:]]'
prune_v='docker[[:space:]]+(volume[[:space:]]+prune|system[[:space:]]+prune([[:space:]].*)?--volumes)'

# Where the command runs: the cwd, every `cd` target, and compose's -f /
# --project-directory paths.
here=false
places=("${HOOK_CWD:-.}")
places+=($(printf '%s' "$text" | grep -oE '(^|[;&|[:space:]])cd[[:space:]]+[^;&|[:space:]]+' | awk '{print $NF}'))
places+=($(printf '%s' "$text" | grep -oE '(-f|--file|--project-directory)[[:space:]=]+[^;&|[:space:]]+' | sed -E 's/^[^[:space:]=]+[[:space:]=]+//'))
for place in "${places[@]}"; do
  protected_path "$(unquote "$place")" && here=true
done

if $here; then
  says "$down_v" && refuse "\`down -v\` deletes this project's volumes along with its containers"
  says "$rm_path" && refuse "this deletes files from inside a protected directory"
fi

if says "$rm_path"; then
  for target in $(printf '%s' "$text" | grep -oE '(^|[;&|(){}[:space:]])rm[[:space:]][^;&|]*' | sed -E 's/^[^r]*rm[[:space:]]+//'); do
    case "$target" in -*) continue ;; esac
    protected_path "$(unquote "$target")" && refuse "this deletes a protected directory, or one holding protected directories"
  done
fi

if says "$volume_rm" && says "(^|[[:space:]])${PREFIX}"; then
  refuse "this removes a protected volume"
fi

if says "$prune_v" || says "$volume_rm"; then
  held="${PROTECTED_GUARD_VOLUMES-$(docker volume ls -q --filter "name=${PREFIX}" 2>/dev/null)}"
  if [[ -n "$held" ]]; then
    says "$prune_v" && refuse "a prune removes every unused volume, and a stopped project's protected volumes are unused"
    says "$volume_rm" && says '\$\(|`|\$[A-Za-z_{]' && refuse "\`docker volume rm\` over names this hook cannot read while protected volumes exist; write the names out"
  fi
fi

exit 0
