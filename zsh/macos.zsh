# macOS-specific configs

export ANDROID_HOME="$HOME/Library/Android/sdk"

_java_cache="${XDG_CACHE_HOME:-$HOME/.cache}/java_home_17"
if [[ -r $_java_cache && -d $(<$_java_cache) ]]; then
  export JAVA_HOME="$(<"$_java_cache")"
else
  export JAVA_HOME=$(/usr/libexec/java_home -v 17 2>/dev/null)
  [[ -n $JAVA_HOME ]] && mkdir -p "${_java_cache:h}" && print -r -- "$JAVA_HOME" >| "$_java_cache"
fi
unset _java_cache

export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock

# Never call `colima ls` during shell startup (~200ms+). Reuse the last known VM
# address; refresh after `colima start` / `colima restart`.
_colima_cache="${XDG_CACHE_HOME:-$HOME/.cache}/colima-host"
[[ ${TESTCONTAINERS_HOST_OVERRIDE:-} == null ]] && unset TESTCONTAINERS_HOST_OVERRIDE
if [[ -r $_colima_cache ]]; then
  _addr="$(<"$_colima_cache")"
  [[ -n $_addr && $_addr != null ]] && export TESTCONTAINERS_HOST_OVERRIDE="$_addr"
  unset _addr
fi

refresh-colima-host() {
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/colima-host"
  local addr
  mkdir -p "${cache:h}"
  addr=$(command colima ls -j 2>/dev/null | jq -r '.address // empty')
  if [[ -n $addr && $addr != null ]]; then
    print -r -- "$addr" >| "$cache"
    export TESTCONTAINERS_HOST_OVERRIDE="$addr"
  fi
}

colima() {
  command colima "$@"
  local ret=$?
  case $1 in
    start|restart) refresh-colima-host ;;
  esac
  return $ret
}

unset _colima_cache
