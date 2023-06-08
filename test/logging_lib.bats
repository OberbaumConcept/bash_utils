
load test_helper/bats-assert/load
load test_helper/bats-support/load

__levels=(trace debug info warn error fatal)


@test "sourcing" {
	source src/libs/logging_lib.sh
}


@test "logging_setLevel" {

	# prepare
	source src/libs/logging_lib.sh

	# test
	for ((i=0; i<${#__levels[@]}; i++)); do
		loglevel=${__levels[$i]}
		# lower case
		LOGGING_LEVEL=-1
		logging_setLevel "$loglevel"
		assert_equal "$LOGGING_LEVEL" "$i"

		# upper case
		LOGGING_LEVEL=-1
		logging_setLevel "${loglevel^^}"
		assert_equal "$LOGGING_LEVEL" "$i"
	done
}


@test "logging_setLevel invalid value" {

	# prepare
	source src/libs/logging_lib.sh

	# test
	LOGGING_LEVEL=100
	run logging_setLevel test
	assert_failure
	assert_equal "$LOGGING_LEVEL" 100
}


@test "logging_trace" {

	# prepare
	source src/libs/logging_lib.sh

	# test
	for ((i=0; i<${#__levels[@]}; i++)); do
		loglevel=${__levels[$i]}
		logging_setLevel "$loglevel"
		run logging_trace "message"
		if [[ $i -le LOGGING_LEVEL_TRACE ]]; then
			assert_output --regexp "\[TRACE\].*message"
		else
			refute_output
		fi
	done
}


@test "logging_debug" {

	# prepare
	source src/libs/logging_lib.sh

	# test
	for ((i=0; i<${#__levels[@]}; i++)); do
		loglevel=${__levels[$i]}
		logging_setLevel "$loglevel"
		run logging_debug "message"
		if [[ $i -le LOGGING_LEVEL_DEBUG ]]; then
			assert_output --regexp "\[DEBUG\].*message"
		else
			refute_output
		fi
	done
}


@test "logging_info" {

	# prepare
	source src/libs/logging_lib.sh

	# test
	for ((i=0; i<${#__levels[@]}; i++)); do
		loglevel=${__levels[$i]}
		logging_setLevel "$loglevel"
		run logging_info "message"
		if [[ $i -le LOGGING_LEVEL_INFO ]]; then
			assert_output --regexp "\[INFO \].*message"
		else
			refute_output
		fi
	done
}


@test "logging_warn" {

	# prepare
	source src/libs/logging_lib.sh

	# test
	for ((i=0; i<${#__levels[@]}; i++)); do
		loglevel=${__levels[$i]}
		logging_setLevel "$loglevel"
		run logging_warn "message"
		if [[ $i -le LOGGING_LEVEL_WARN ]]; then
			assert_output --regexp "\[WARN \].*message"
		else
			refute_output
		fi
	done
}


@test "logging_error" {

	# prepare
	source src/libs/logging_lib.sh

	# test
	for ((i=0; i<${#__levels[@]}; i++)); do
		loglevel=${__levels[$i]}
		logging_setLevel "$loglevel"
		run logging_error "message"
		if [[ $i -le LOGGING_LEVEL_ERROR ]]; then
			assert_output --regexp "\[ERROR\].*message"
		else
			refute_output
		fi
	done
}


@test "logging_fatal" {

	# prepare
	source src/libs/logging_lib.sh

	# test
	for ((i=0; i<${#__levels[@]}; i++)); do
		loglevel=${__levels[$i]}
		logging_setLevel "$loglevel"
		run logging_fatal "message"
		if [[ $i -le LOGGING_LEVEL_FATAL ]]; then
			assert_output --regexp "\[FATAL\].*message"
		else
			refute_output
		fi
	done
}


@test "LOGGING_COLORS_DISABLED=1" {

	# prepare
	# shellcheck disable=SC2034
	LOGGING_COLORS_DISABLED=1
	source src/libs/logging_lib.sh

	# test
	for color in "${_LOGGING_COLORS[@]}"; do
		assert_equal "$color" ""
	done
	assert_equal "$_LOGGING_COLOR_NORMAL" ""
}
