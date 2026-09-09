# Binding and CI integration

The logging bindings now include the native `va_list` parameter. Curses and
GObject introspection retain their existing vocabulary-local `va_list` names,
aliased to the canonical ABI-aware type in `alien.varargs`.

Verified against primary headers:

- [raylib 6.0](https://github.com/raysan5/raylib/blob/6.0/src/raylib.h):
  `TraceLogCallback` has three parameters, ending in `va_list args`.
- [systemd v183](https://github.com/systemd/systemd/blob/v183/src/libudev/libudev.h)
  and [current systemd](https://github.com/systemd/systemd/blob/main/src/libudev/libudev.h):
  `udev_set_log_fn`'s callback has seven parameters, ending in `va_list args`.
  The current function is deprecated but still declared.

## Local validation

Baseline assertions against commit `233db947df` failed as expected:
`raylib-before.log` reports two parameters instead of three;
`libudev-before.log` reports six instead of seven.

After the changes, native macOS ARM64 runs passed:

- `bindings-after.log`: raylib signature and both canonical typedef identity
  checks, three unit tests, zero failures and zero compiler errors, exit 0.
- `libudev-after.log`: the declaration-only callback arity check passes, exit 0.
  The libudev vocabulary is Linux-only; this check explicitly parses its source
  without invoking any native function. The committed vocabulary unit test runs
  in the Linux CI lane.
- `help-lint.log`: `alien.syntax` documentation lint, exit 0.
- `apple-clang-controls.log` and `llvm-controls.log`: standalone C fixtures built
  with `-std=c11 -O2 -Wall -Wextra -Werror -DFACTOR_VARARGS_CONTROL_MAIN`, general
  control mask `0xff`, half/BF16 controls PASS, exit 0. Compiler versions are in
  `compilers.log`.
- Python helper syntax compilation and workflow YAML parsing pass. The YAML
  check verifies two independent compiler steps and an explicit required-small
  step on each of the three ARM64 jobs.

The tests use the pre-change verified runtime/image with the new cursor and
promotion vocabularies available as dependencies. These checks validate binding
signatures and aliases; callback machine-code and native list execution are
covered by the separate C-backed varargs suite.

## CI behavior and qualification

`.github/check-arm64-varargs.py` rebuilds the native fixture library independently
for each compiler, builds and executes the standalone C oracle, runs the focused
Factor suite normally and with optional extensions disabled, and checks real CRT
`printf` output in subprocesses. Existing full ARM64 regression and feature-cache
steps remain in place.

Linux uses GCC and Clang 18; Windows uses MSVC and clang-cl targeting ARM64;
macOS uses Apple Clang and Homebrew LLVM. The Clang lane on every platform passes
`--require-small`, which requires both half/BF16 fixture capability exports and
passing C small-float controls. Missing compilers, symbols, capabilities, failed
C controls, failed Factor tests, and incorrect printf output fail the job.

Native Linux and Windows execution, including their Clang runtime linkage, remains
pending until these CI steps execute. Workflow configuration and local compiler
oracles are not a claim of native platform qualification. No workflow has been
triggered or published by this task.
