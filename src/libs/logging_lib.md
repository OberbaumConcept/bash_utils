# logging_lib.sh

Logging library for bash scripts.

## Requirements

- `bash` >= 4.0
- `date`
- `tput`  
  Required for color support. Set `LOGGING_COLORS_DISABLED=1` to disable color support

## Usage

```bash
#/usr/bin/env bash

source logging_lib.sh
logging_setLevel "debug"

function foo() {
  logging_info "I'm foo"
}
foo
logging_error "oh" "no!"
```

output:

```txt
2021-10-09 02:36:30 [INFO] foo: I'm foo
2021-10-09 02:36:30 [ERROR] main: oh no!
```

Disable color support:

```bash
#/usr/bin/env bash
LOGGING_COLORS_DISABLED=1
source logging_lib.sh
logging_setLevel "debug"
```

## Functions

### logging_setLevel &lt;level&gt;

Sets the log level. Valid values for &lt;level&gt; are (case insensitive):

- `trace`
- `debug`
- `info`
- `warn`
- `error`
- `fatal`

### logging_trace &lt;string&gt; [&lt;string&gt; ...]

Log with log level `TRACE`. Multiple strings will be concatinated using whitspaces.

### logging_debug &lt;string&gt; [&lt;string&gt; ...]

Log with log level `DEBUG`. Multiple strings will be concatinated using whitspaces.

### logging_debug &lt;string&gt; [&lt;string&gt; ...]

Log with log level `DEBUG`. Multiple strings will be concatinated using whitspaces.

### logging_info &lt;string&gt; [&lt;string&gt; ...]

Log with log level `INFO`. Multiple strings will be concatinated using whitspaces.

### logging_warn &lt;string&gt; [&lt;string&gt; ...]

Log with log level `WARN`. Multiple strings will be concatinated using whitspaces.
If colors are supported log level will be printed yellow.

### logging_error &lt;string&gt; [&lt;string&gt; ...]

Log with log level `ERROR`. Multiple strings will be concatinated using whitspaces.
If colors are supported log level will be printed red.

### logging_fatal &lt;string&gt; [&lt;string&gt; ...]

Log with log level `FATAL`. Multiple strings will be concatinated using whitspaces.
If colors are supported log level will be printed red and bolt.

## Variables

### LogLevel constants - must not be overwritten

- LOGGING_LEVEL_TRACE=0
- LOGGING_LEVEL_DEBUG=1
- LOGGING_LEVEL_INFO=2
- LOGGING_LEVEL_WARN=3
- LOGGING_LEVEL_ERROR=4
- LOGGING_LEVEL_FATAL=5

### LOGGING_LEVEL

current log level as int (see LogLevel constants)

### LOGGING_COLORS_DISABLED

Default: `0`. Set to `1` to disable colorized ouput.

### LOGGING_DATE_FORMAT

Default `'%Y-%m-%d %H:%M:%S'`. Date format string.

### Path to utility commands

You may overwrite these values with absolute paths if they are not in your `$PATH`.
- LOGGING_COMMAND_DATE="date"
- LOGGING_COMMAND_TPUT="tput"

## Notes

- Variables / function starting with `_` are supposed to be private and should not be used.
