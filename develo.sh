#!/bin/bash

DEVELO_VERSION="0.0.28"
DEVELO_CONF_DIR=${HOME}/.develo_project
DEVELO_PRIVATE_HELPERS_DIR=${HOME}/.develo_helpers
DEVELO_DIR=".develo"
DEVELO_ENV_FILE=".develoenv"

source "${DEVELO_CONF_DIR}/completion.sh"
source "${DEVELO_CONF_DIR}/functions.sh"
source "${DEVELO_CONF_DIR}/helpers.sh"


# Colorful banners :)
# You will see them when you init new env
# or when activate env and so on :)
source "${DEVELO_CONF_DIR}/banners.sh"

function develo {
  local cmd=$1;

  # Show help info if call develo
  # without any arguments
  if [ -z "$cmd" ]; then
      _develo_help;
      return 0;
  fi

  case "$cmd" in
    help|-h|--help)
      _develo_help;
      return 0;
    ;;

    init)
      _develo_init;
      return 0;
    ;;

    activate)
      _develo_activate 1;
      return 0;
    ;;

    selfupdate)
      _develo_update;
      return 0;
    ;;

    version|-v|--version)
      _develo_version;
      return 0;
    ;;

    *)
      _develo_run $@;
      return 0;
    ;;

  esac

}

function _develo_help {

  echo "usage: develo <command>"
  echo

  echo -e "\x1B[1mSome things that you have to know:\x1B[0m"
  echo

  if [ -d "$DEVELO_DIR" ]; then
    echo "  Your scripts are here: $(pwd)/$DEVELO_DIR/"
    echo
  fi

  echo "  init          Initialize new develo environemnt"
  echo "  activate      Activate develo environemnt"
  echo "  readme        Shows some instructions for the current project"
  echo "  selfupdate    Updates itself"
  echo "  version       Shows installed version"
  echo "  help          Shows you this help"
}

function _develo_run {
  local cmd=$1;
  local args=${@:2};
  local file="$(_develo_root_dir)/$DEVELO_DIR/$cmd"
  local develoenv_file="$(_develo_root_dir)/$DEVELO_ENV_FILE"
  local global_develoenv_file="$HOME/$DEVELO_ENV_FILE"

  ## Load project specific environment variables
  ## from .develoenv file
  __develo_load_env_file_helper "$global_develoenv_file"
  __develo_load_env_file_helper "$develoenv_file"

  if [ -f "$file" ]; then
    # Auto loading banners before out of every command
    # disabled for now
    # local banner="_develo_actions_${cmd}_banner";
    # ($banner)
    source "$file";
    return 0;
  else
    _develo_action_not_exist_banner $cmd;
    return 1;
  fi
}

function _develo_init {
  # Create .develo dir if doesn't exists
  if [ ! -d "$DEVELO_DIR" ]; then
    cp -R $DEVELO_CONF_DIR/actions "`pwd`/$DEVELO_DIR";
    chmod +x $DEVELO_DIR/*;

    _develo_initalized_banner;
    return 0;
  else
    echo "Develo is already initialized in $(pwd)/$DEVELO_DIR/";
    return 0;
  fi
}

function _develo_detected {
  if [[ ! "$PS1" =~ "Develo" ]]; then
    _develo_detected_banner;
  fi
}

function _develo_activate {

  local manual_activation=$1;

  if [[ ! "$PS1" =~ "Develo" ]]; then

    # Show this banner on activating every time
    # except when develo is activate manualy "develo activate"
    if [ -z "$manual_activation" ]; then
      DEVELO_AUTO_ACTIVATE="auto"
      _develo_actions_activate_banner;
    fi

    local project_name=$(basename "$PWD");

    #TODO: Fix code repetition
    if [[ ! $PS1 =~ ^[\\n].+$ ]]; then
      PS1="\n(Develo#$project_name)\n$PS1";
    else
      PS1="\n(Develo#$project_name)$PS1";
    fi

  fi

  # This will show up when develo
  # is activated by command "develo activate"
  if [ ! -z "$manual_activation" ]; then
    DEVELO_AUTO_ACTIVATE="";
    _develo_actions_activate_banner;
    _develo_run activate;
  fi
}

function _develo_decativate {
  echo "Deactivating Develo ..."
  echo "Not implemented yet..."
  return 1;
}

function _develo_version {
  _develo_version_banner;
}

function _develo_update {
  local develo_version=$(curl -s https://raw.github.com/mignev/develo/master/develo.sh |grep '^DEVELO_VERSION='| awk -F\" '{print $(NF-1)}')
  local my_develo_version=$DEVELO_VERSION;
  if [ "$develo_version" != "$my_develo_version" ]; then

    _develo_actions_selfupdate_banner;

    git clone https://github.com/mignev/develo.git ~/develo
    rm -rf ~/.develo_project
    mv ~/develo ~/.develo_project
    source ~/.develo_project/develo.sh
  else
    echo
    echo "Your Develo is up-to-date.";
  fi


  return 0;
}
