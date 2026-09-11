# Open signal issues — 2026-09-11

Reviewed the eight open issues carrying the `signals` label. Changes are
committed locally; no GitHub issues were closed or commented on.

## New fixes

### #1668: Unix syscall wrappers and their callers

[Issue #1668](https://github.com/factor/factor/issues/1668) prompted a review
of every `unix-system-call` and `unix-system-call-allow-eintr` caller under
`basis` and `extra`.

* `c5fc1d9573` fixes argument consumption on EINTR in the non-retrying wrapper.
  Previously, interrupted `close` returned its input descriptor, while a
  six-argument call left all six inputs on the stack. Both wrappers now capture
  errno immediately and document their distinct retry contracts. The names
  remain unchanged.
* `7c5cf1f395` handles the direct error-number return values of `getgrnam_r`
  and `getgrgid_r`, retries EINTR, grows buffers on ERANGE, and copies results
  before freeing stable native scratch storage. `getgrouplist` grows its
  output array using the required count instead of assuming 64 groups.
  `all-groups` now calls `endgrent` even when copying an entry throws.
* `9bba9db63c` disambiguates an FFI name collision in the enumeration regression.

**Compatibility:** `unix.groups:group-struct` now returns a managed
`unix.groups:group` tuple (or `f`), rather than a C struct containing pointers
into a temporary buffer. Use `id>>`, `name>>`, `passwd>>`, and `members>>`.
All repository consumers were updated, and the public help documents the
change. External consumers relying on the old C struct need adjustment.

The different libc contracts are documented in
[getgrnam(3)](https://man7.org/linux/man-pages/man3/getgrnam.3.html) and
[getgrouplist(3)](https://man7.org/linux/man-pages/man3/getgrouplist.3.html).

### #505: Interrupted kqueue changes

`1cee61f8d1` addresses
[issue #505](https://github.com/factor/factor/issues/505). Changelist
submission accepts EINTR without replaying the changes, and callbacks enter
the pending map only after registration succeeds. The existing event wait
continues to return to the scheduler on EINTR, preserving deadline handling.

This distinction matters because all changelist changes have already been
applied when `kevent` returns EINTR.
[FreeBSD kevent(2)](https://man.freebsd.org/cgi/man.cgi?query=kevent&sektion=2&format=html)

Fault-injected tests execute on Linux with a temporary kqueue ABI shim;
native BSD/macOS execution remains unverified.

### #1595: Ctrl-C interrupts every nested shell

`f8fdada537` addresses
[issue #1595](https://github.com/factor/factor/issues/1595). Waiting Unix
shells temporarily catch SIGINT and SIGQUIT with a no-op handler while
foreground commands or pipelines run. Reference-counted scopes restore the
complete previous dispositions after the final scope exits, including errors.
Using a caught handler allows exec to restore the child's default disposition;
installing SIG_IGN would make ordinary children inherit ignored interrupts.
[signal(7)](https://man7.org/linux/man-pages/man7/signal.7.html)

Private pseudoterminal tests reproduced three interrupted Factor processes
before the change and one afterwards. They also cover ordinary commands,
pipelines, handler restoration after a child fails, and console busy-loop
recovery. This is not full shell job control: process groups and background
job handling are unchanged.

## Existing fixes and remaining work

| Issue | Assessment |
| --- | --- |
| [#2259: flaky signal test](https://github.com/factor/factor/issues/2259) | Already addressed by `6067c08ae5`, which waits for handler acknowledgement instead of sleeping. `f7a9a1aa18` imports `raise` explicitly. The tests are included in this validation. |
| [#1419: mac64 stack overflow during GC](https://github.com/factor/factor/issues/1419) | `3879095201` already moves guard transitions outside active collection. The preceding audit passed the Linux stack-safety suite. The original macOS failure has not been verified on macOS here. |
| [#1573: infinite loops freeze the Listener](https://github.com/factor/factor/issues/1573) | Console interruption and recovery pass in an isolated PTY. This does not solve GUI event starvation or interruption of an arbitrary Factor thread. The broader issue remains. |
| [#322: inline words in backtraces](https://github.com/factor/factor/issues/322) | Remains open. The VM currently emits physical frames using a code block's owner. Accurate inline frames require compiler origin metadata mapped to generated code locations, plus changes to backtrace consumers and metadata lifetime handling. |
| [#299: resumable signals on RISC](https://github.com/factor/factor/issues/299) | ARM64 already has ABI-specific resumable dispatch in `vm/cpu-arm.64.cpp`. x86 and ARM64 still duplicate the outer dispatch logic; that refactor and architecture-specific validation remain. No ARM64 execution was available here. |

## Validation

* Original wrapper, group-lookup, kqueue, and nested-shell code failed the
  corresponding new regression cases. The group buffer ownership problem
  was established by code inspection; a compact-GC probe alone did not
  reproduce visible string corruption in the old implementation.
* `make test-vm CONFIG=vm/Config.linux.x86.64 BUILD_DIR=build-signal-issues`
  passed all eight native signal groups and the GC tests.
* `python3 vm/tests/unix_shell_signals.py` runs four tests in private PTY
  sessions. Its cleanup targets only its own test process groups.
* The group regression file explicitly exercises positive error codes,
  interruption, buffer growth, cleanup on lookup/enumeration failure, managed
  result lifetime, and a 65-group response. Group help lint passes.
* A freshly saved image passed 842 Factor checks without source refreshes:
  the root `unix` regression file plus `unix.groups`, `unix.users`,
  `unix.signals`, `unix.ffi`, `unix.process`, `io.launcher`, `io.backend.unix`,
  `io.files`, `io.directories`, `io.pipes`, `io.sockets`,
  `tools.profiler.sampling`, `shell.parser`, `http`, and `furnace`.
  All four PTY tests also pass with that image. Deliberate closed-stream and
  TLS-rejection fixtures print background errors; existing FIFO fixtures
  print automatic-import notices. None are failed assertions.
* Earlier broad test attempts exposed two harness configuration errors:
  a relative image path made resource paths depend on the temporary working
  directory, and subprocess tests needed an image matching the temporary
  executable's name. The final run uses absolute paths and a matching image.

The rebuilt binary and refreshed default image are prepared locally for the
next server restart. Their predecessors are retained in a private temporary
backup directory with SHA-256 checksums.

The Linux kqueue tests can be reproduced with a temporary vocabulary root
containing `unix/kqueue/linux/linux.factor` with these contents:

```factor
! Test-only ABI shim: every kevent call is fault-injected.
USING: unix.kqueue.macos ;
IN: unix.kqueue.linux
```

Then add that root with `add-vocab-root`, bind `check-vocab-hook` to `[ drop ]`,
require `io.backend.unix.multiplexers.kqueue`, and explicitly run
`resource:basis/io/backend/unix/multiplexers/kqueue/kqueue-tests.factor`
with `run-test-file`. Normal platform-filtered test discovery skips this
vocabulary on Linux. No real kevent call is made in this configuration.

The running website was neither restarted nor sent test signals.
