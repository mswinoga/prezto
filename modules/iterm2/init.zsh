#
# Provides for printing background image for remote (ssh) sessions
#
# Authors:
#   Marcin Swinoga <marcin.swinoga@gmail.com>
#

# Return if requirements are not found.
if [[ "$TERM_PROGRAM" != iTerm.app ]]; then
  return 1
fi

zstyle -s ':prezto:module:ssh-profiles' conf 'iterm_ssh_conf' || iterm_ssh_conf="${0:h}/profiles.conf"
zstyle -s ':prezto:module:ssh-profiles:profile' local 'iterm_ssh_local' || iterm_ssh_local="Default"
zstyle -s ':prezto:module:ssh-profiles:profile' remote 'iterm_ssh_remote' || iterm_ssh_remote="Remote"

function _iterm_set_profile() {
  local NAME=$1; if [ -z "$NAME" ]; then NAME=$iterm_ssh_local; fi
  echo -e "\033]50;SetProfile=$NAME\a"
}

function _iterm_reset_profile() {
  _iterm_set_profile $iterm_ssh_local
  trap INT EXIT # reset trap
}

function _iterm_decorated_ssh() {
  if [[ -n "$ITERM_SESSION_ID" ]]; then
    trap "_iterm_reset_profile" INT EXIT
    local HOST_NAME=$(echo "$@" | awk '{print $NF}' | sed -e 's/.*@//')
    HOST_NAME=$(nslookup $HOST_NAME | grep "^Name:" | awk '{print $2}')
    local PROFILE_NAME=$(grep "$HOST_NAME" $iterm_ssh_conf | awk '{print $2}')
    if ([[ -n $HOST_NAME ]] && [[ -n $PROFILE_NAME ]]); then
      _iterm_set_profile $PROFILE_NAME
    else
      _iterm_set_profile $iterm_ssh_remote
    fi
  fi
  ssh $*
}
compdef _ssh _iterm_decorated_ssh=ssh

alias ssh="_iterm_decorated_ssh"

# set default profile
_iterm_set_profile
