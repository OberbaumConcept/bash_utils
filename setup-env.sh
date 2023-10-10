#!/usr/bin/env bash
set -eo pipefail

########################################################################################################################
# Settings

########################################################################################################################
# Variables - do not edit
_SOURCE="${BASH_SOURCE[0]}"
while [ -h "$_SOURCE" ]; do # resolve $_SOURCE until the file is no longer a symlink
	_DIR="$(cd -P "$(dirname "$_SOURCE")" >/dev/null 2>&1 && pwd)"
	_SOURCE="$(readlink "$_SOURCE")"
	# if $SOURCE was a relative symlink, we need to resolve it relative to the path
	# where the symlink file was located
	[[ $_SOURCE != /* ]] && _SOURCE="$_DIR/$_SOURCE"
done

# shellcheck disable=SC2155
readonly SOURCE_DIR="$(cd -P "$(dirname "$_SOURCE")" >/dev/null 2>&1 && pwd)"

# shellcheck source=src/libs/logging_lib.sh
source "$SOURCE_DIR"/src/libs/logging_lib.sh

readonly PYTHON_MIN_VERSION=3.8
readonly PYTHON_MAX_VERSION=3.12
# shellcheck disable=SC2155
readonly SCRIPT_NAME=$(basename "$0")

########################################################################################################################
# Functions

#-----------------------------------------------------------------------------------------------------------------------
help() {

	echo "

$SCRIPT_NAME [-l <loglevel>] [-n] [-D] [-P] [-R] [-h] [<venv-name>]

Setup dev environment. Will create a python venv and install requirements from
requirements.txt into it.

Options:
  -l <level>     Set loglevel. Valid values are 'trace', 'debug', 'info', 'warn',
                 'error' (case insensitive). Default: 'info'
  -n             Dry run
  -P             do not install pre-commit
  -R             register git hooks only
  -h             this help.
  <venv-name>    Name for the python virtual env. Default: '.venv'

Requirements:
* Python: $PYTHON_MIN_VERSION

"
}

#-----------------------------------------------------------------------------------------------------------------------
execute_cmd() {
	local cmd="$*"
	if [[ $DRY_RUN -eq 1 ]]; then
		logging_info "$cmd" " [DRY_RUN]"
	else
		logging_info "$cmd"
		$cmd
	fi
}

#-----------------------------------------------------------------------------------------------------------------------
check_venv() {
	if [[ "$VIRTUAL_ENV" != "" ]]; then
		logging_error "It looks like your are already working inside a virtual env: $VIRTUAL_ENV"
		logging_error "Please run 'deactivate' first before executing this script"
		return 1
	fi
}

#-----------------------------------------------------------------------------------------------------------------------
# version_compare <v1> <v2>
# VERSION_COMPARE_RESULT=0 if v1 == v2
# VERSION_COMPARE_RESULT=1 if v1 > v2
# VERSION_COMPARE_RESULT=2 if v1 < v2
version_compare() {
	VERSION_COMPARE_RESULT=0
	if [[ $1 == "$2" ]]; then
		return
	fi

	local i ver1 ver2
	IFS=. read -r -a ver1 <<<"$1"
	IFS=. read -r -a ver2 <<<"$2"
	for ((i = 0; i < ${#ver1[@]}; i++)); do
		if ((10#${ver1[i]} > 10#${ver2[i]})); then
			VERSION_COMPARE_RESULT=1
			return
		fi
		if ((10#${ver1[i]} < 10#${ver2[i]})); then
			VERSION_COMPARE_RESULT=2
			return
		fi
	done
}

#-----------------------------------------------------------------------------------------------------------------------
check_python_version() {

	local PYTHON_VERSION=
	PYTHON_VERSION=$(python3 --version | head -n 1 | cut -d' ' -f2)
	version_compare $PYTHON_MIN_VERSION "$PYTHON_VERSION"
	if [[ $VERSION_COMPARE_RESULT -eq 1 ]]; then
		logging_error "Minimal python version required: $PYTHON_MIN_VERSION, found $PYTHON_VERSION"
		return 1
	fi
	version_compare $PYTHON_MAX_VERSION "$PYTHON_VERSION"
	if [[ $VERSION_COMPARE_RESULT -eq 2 ]]; then
		logging_error "Maximum python version allowed: $PYTHON_MAX_VERSION, found $PYTHON_VERSION"
		logging_error "Python $PYTHON_MAX_VERSION required, found $PYTHON_VERSION"
		return 1
	fi
	logging_info "Found Python $PYTHON_VERSION ... OK"
}

#-----------------------------------------------------------------------------------------------------------------------
create_venv() {
	if [[ ! -d $VENV ]]; then
		logging_info "Creating VENV $VENV ..."
		execute_cmd python3 -m venv "$VENV"
	else
		logging_info "VENV $VENV found"
	fi
}

#-----------------------------------------------------------------------------------------------------------------------
install_requirements() {
	logging_info "Install requirements ..."
	if [[ $LOGGING_LEVEL -le $LOGGING_LEVEL_DEBUG || $DRY_RUN -eq 1 ]]; then
		echo "--- requirements.txt:"
		cat "$SOURCE_DIR"/requirements.txt
		echo
	fi
	execute_cmd python -m pip install --timeout 30 -r "$SOURCE_DIR"/requirements.txt
}

#-----------------------------------------------------------------------------------------------------------------------
setup_precommit() {
	logging_info "Setting up pre-commit [may take a couple of minutes] ..."
	execute_cmd pre-commit install --install-hooks --overwrite
}

#-----------------------------------------------------------------------------------------------------------------------
register_git_hooks() {
	if [[ -d ".git-hooks" ]]; then
		logging_info "Register git hooks ..."
		while IFS= read -r -d '' hook; do
			ln -sf "../../$hook" ".git/hooks/"
			logging_info "Registered ${hook}"
		done < <(find .git-hooks -maxdepth 1 -type f -perm /111 -print0)
	else
		logging_info "directory .git-hooks not found"
	fi
}

#-----------------------------------------------------------------------------------------------------------------------
update_git_submodules() {
	logging_info "Updating git submodules"
	execute_cmd git submodule init
	execute_cmd git submodule update
}

########################################################################################################################
# main
while getopts ":l:nPRh" opt; do
	case $opt in
		l) _LOG_LEVEL=$OPTARG ;;
		n) DRY_RUN=1 ;;
		P) PRECOMMIT_SETUP=0 ;;
		R) HOOKS_ONLY=1 ;;
		h)
			help
			exit 0
			;;
		\?)
			echo "ERROR: Invalid option -$OPTARG"
			exit 1
			;;
		:)
			echo "ERROR: Option -$OPTARG requires an argument"
			exit 1
			;;
	esac
done
shift $((OPTIND - 1))

if [[ -n $1 ]]; then
	VENV_NAME=$1
	shift
fi
# set defaults
: "${_LOG_LEVEL:=info}"
: "${DRYRUN:=0}"
: "${VENV_NAME:=.venv}"
: "${PRECOMMIT_SETUP:=1}"
: "${HOOKS_ONLY:=0}"
VENV="$VENV_NAME"

logging_setLevel "$_LOG_LEVEL"

register_git_hooks
[[ $HOOKS_ONLY -eq 1 ]] && exit

# check requirements
check_venv
check_python_version
create_venv

logging_info "Sourceing VENV $VENV ..."
execute_cmd source "${VENV}"/bin/activate

logging_info "Install basic packages first"
execute_cmd "python -m pip install --timeout 30 pip>=21.3.1 setuptools wheel"

logging_info "Update pip to latest version"
execute_cmd "python -m pip install --upgrade pip"

install_requirements
if [[ $PRECOMMIT_SETUP -eq 1 ]]; then
	setup_precommit
else
	logging_info "Setup precommit disabled via flag"
fi

update_git_submodules

echo "
Creating environment competed. Type 'source $VENV/bin/activate'
to activate it.
"
