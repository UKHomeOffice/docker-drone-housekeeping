#/usr/bin/env bash

set -o errexit
set -o nounset

log() {
  (2>/dev/null echo -e "$@")
}

debug()   { if [[ $VERBOSITY -gt 1 ]]; then log "[debug] $*"; fi }
info()    { if [[ $VERBOSITY -gt 0 ]]; then log "[info] $*"; fi }
warning() { log "[warning] $*"; }
error()   { log "[error] $*"; }
failed()  { log "[failed] $*"; exit 1; }

export VERBOSITY=${VERBOSITY:-1}
export REMOVE_USERS_SKIP_ADMIN=${REMOVE_USERS_SKIP_ADMIN:-true}
export REMOVE_USERS_SKIP_INACTIVE=${REMOVE_USERS_SKIP_INACTIVE:-false}
export REMOVE_USERS_SKIP_USERS=${REMOVE_USERS_SKIP_USERS:-admin}
export REMOVE_USERS_PERIOD=${REMOVE_USERS_PERIOD:-90}
export DRY_RUN=${DRY_RUN:-false}

now=$(date +%s)
let "back_then = $now - $REMOVE_USERS_PERIOD * 24 * 3600"

debug now is $now
debug back_then is $back_then

info VERBOSITY: $VERBOSITY
info REMOVE_USERS_SKIP_ADMIN: $REMOVE_USERS_SKIP_ADMIN
info REMOVE_USERS_SKIP_INACTIVE: $REMOVE_USERS_SKIP_INACTIVE
info REMOVE_USERS_SKIP_USERS: $REMOVE_USERS_SKIP_USERS
info REMOVE_USERS_PERIOD: $REMOVE_USERS_PERIOD
info DRY_RUN: $DRY_RUN

for user in $(drone user ls --format "{{ .Login }},{{ .Active }},{{ .Admin }},{{ .LastLogin }}"); do
  debug user: $user

  login=$(echo $user | cut -d, -f1)
  active=$(echo $user | cut -d, -f2)
  admin=$(echo $user | cut -d, -f3)
  last_login=$(echo $user | cut -d, -f4)

  debug login: $login
  debug active: $active
  debug admin: $admin
  debug last_login: $last_login

  if [[ $last_login -lt $back_then ]]; then
    if [[ $REMOVE_USERS_SKIP_ADMIN == true && $admin == true ]]; then
      info "Skipping admin $login who has not logged on since $(date -d @${last_login})"
    elif [[ $REMOVE_USERS_SKIP_INACTIVE == true && $active == false ]]; then
      info "Skipping user $login who has not logged on since $(date -d @${last_login}) as blocked"
    else
      skip=false
      for skipped_user in $REMOVE_USERS_SKIP_USERS; do
        if [[ $login == $skipped_user ]]; then
          skip=true
          break
        fi
      done
      if [[ $skip == true ]]; then
        info "Skipping user $login as on exceptions list"
      else
        info "Removing user $login as not logged in since $(date -d @${last_login})"
        if [[ $DRY_RUN == true ]]; then
          info [dry-run] drone user rm $login
        else
          drone user rm $login
        fi
      fi
    fi
  fi
done