#!/usr/bin/env bash

# Copyright 2021 Oberbaum Concept UG
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# VERSION=1.0.0

################################################################################
# Variables - may be overwritten
################################################################################
# We will try to detect if colors are supported. If so, log levels will be
# colored (fatal=bold red, error=red, warn=yellow). Set LOGGING_COLOR_SUPPORT_DISABLED=1
# to disable color support. Color support requires 'tput'

: "${LOGGING_LEVEL:=LOGGING_LEVEL_WARN}"
: "${LOGGING_COLORS_DISABLED:=0}"
LOGGING_DATE_FORMAT='%Y-%m-%d %H:%M:%S'
LOGGING_COMMAND_DATE="date"
LOGGING_COMMAND_TPUT="tput"

################################################################################
# Variables - do not edit / overwrite
################################################################################
LOGGING_LEVEL_TRACE=0
LOGGING_LEVEL_DEBUG=1
LOGGING_LEVEL_INFO=2
LOGGING_LEVEL_WARN=3
LOGGING_LEVEL_ERROR=4
LOGGING_LEVEL_FATAL=5

_LOGGING_LEVEL_NAMES=("TRACE" "DEBUG" "INFO" "WARN" "ERROR" "FATAL")
_LOGGING_COLORS=("" "" "" "" "" "")
_LOGGING_COLOR_NORMAL=""

if [[ ${LOGGING_COLORS_DISABLED:=0} -eq 0 ]]; then
	if [[ -t 1 ]]; then # stdout is a terminal
		# see if it supports colors...
		_ncolors=$($LOGGING_COMMAND_TPUT colors)
		if [[ -n "$_ncolors" && $_ncolors -ge 8 ]]; then
			_LOGGING_COLORS=("" "" "" "" "" "")
			_LOGGING_COLOR_NORMAL="$($LOGGING_COMMAND_TPUT sgr0)"
			_LOGGING_COLORS[$LOGGING_LEVEL_WARN]="$($LOGGING_COMMAND_TPUT setaf 3)"
			_LOGGING_COLORS[$LOGGING_LEVEL_ERROR]="$($LOGGING_COMMAND_TPUT setaf 1)"
			_LOGGING_COLORS[$LOGGING_LEVEL_FATAL]="$(
				$LOGGING_COMMAND_TPUT bold
				$LOGGING_COMMAND_TPUT setaf 1
			)"
		fi
	fi
fi

################################################################################
# Internal functions
################################################################################

#------------------------------------------------------------------------------
_logging_log() {
	local level=$1
	shift 1
	local message="$*"
	local currentLevel=${LOGGING_LEVEL:=LOGGING_LEVEL_WARN}
	local ts

	if [[ $level -ge $currentLevel ]]; then
		ts=$($LOGGING_COMMAND_DATE +"$LOGGING_DATE_FORMAT")
		local levelName="${_LOGGING_COLORS[$level]}${_LOGGING_LEVEL_NAMES[$level]}${_LOGGING_COLOR_NORMAL}"
		printf "%s [%-5s] %s\n" "$ts" "$levelName" "$message"
	fi
}

################################################################################
# Public functions
################################################################################

#------------------------------------------------------------------------------
# logging_setLevel <level>
#
# Params:
#   level: <debug|info|warn|error|fatal>, case insensitive
#
# Effect: Sets LOGGING_LOGLEVEL#
logging_setLevel() {
	case ${1^^} in
		TRACE) LOGGING_LEVEL=$LOGGING_LEVEL_TRACE ;;
		DEBUG) LOGGING_LEVEL=$LOGGING_LEVEL_DEBUG ;;
		INFO) LOGGING_LEVEL=$LOGGING_LEVEL_INFO ;;
		WARN) LOGGING_LEVEL=$LOGGING_LEVEL_WARN ;;
		ERROR) LOGGING_LEVEL=$LOGGING_LEVEL_ERROR ;;
		FATAL) LOGGING_LEVEL=$LOGGING_LEVEL_FATAL ;;
		*)
			logging_error "unable to parse log level '$1'"
			return 1
			;;
	esac
}

#------------------------------------------------------------------------------
# logging_trace <message>
logging_trace() {
	_logging_log $LOGGING_LEVEL_TRACE "${FUNCNAME[1]:-main}: $*"
}

#------------------------------------------------------------------------------
# logging_debug <message>
logging_debug() {
	_logging_log $LOGGING_LEVEL_DEBUG "${FUNCNAME[1]:-main}: $*"
}

#------------------------------------------------------------------------------
# logging_info <message>
logging_info() {
	_logging_log $LOGGING_LEVEL_INFO "${FUNCNAME[1]:-main}: $*"
}

#------------------------------------------------------------------------------
# logging_warn <message>
logging_warn() {
	_logging_log $LOGGING_LEVEL_WARN "${FUNCNAME[1]:-main}: $*"
}

#------------------------------------------------------------------------------
# log_error <message>
logging_error() {
	_logging_log $LOGGING_LEVEL_ERROR "${FUNCNAME[1]:-main}: $*"
}

#------------------------------------------------------------------------------
# logging_fatal <message>
logging_fatal() {
	_logging_log $LOGGING_LEVEL_FATAL "${FUNCNAME[1]:-main}: $*"
}
