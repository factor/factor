# Linux signal handling audit — 2026-09-11

Reviewed the Unix VM signal handlers, profiler timer, notification pipe,
Factor signal dispatch, subprocess signal dispositions, and the console
thread's signal mask. All runtime verification used separate test processes.

## Fixed

* **Signal names used BSD numbering on Linux.** For example, Linux SIGUSR1
  (10) was reported as SIGBUS, SIGUSR2 as SIGSYS, and SIGCHLD as SIGSTOP.
  Select the Linux table on Linux, and correct the BSD SIGTSTP spelling.
  This fixes both diagnostics and callers looking up numbers by name.
* **The FFI signal sentinels were addresses of allocated storage.** SIG_DFL
  and SIG_IGN must be the sentinel pointers themselves. The old SIG_DFL
  installed a pointer to data as a handler, leaving a subprocess vulnerable
  to a signal before exec reset the disposition. Return the actual pointer
  values, add the correctly named SIG_ERR, and keep SIG_EFF as a compatibility
  alias. Construct the non-null pointers at runtime: saved-image testing
  caught that ALIEN literals expire on image reload. The fork launcher now
  checks signal() for failure.
* **The spawn launcher reset the wrong signal.** Its hand-built signal set
  shifted by SIGPIPE instead of SIGPIPE minus one, selecting SIGALRM on BSD;
  the representation also failed with Linux's structured sigset_t. Allocate
  the platform's signal-set size and use sigemptyset/sigaddset. The shared
  helper was tested on Linux; the macOS spawn path was not run here.
* **Signal handlers overwrote errno.** Filling the notification pipe and
  raising SIGUSR1 changed the interrupted thread's errno from EDOM to EAGAIN.
  All handlers that perform work now preserve errno, including profiling,
  debugger, memory-fault, and floating-point handlers. Notification writes
  retry EINTR iteratively. Unexpected pipe failures use write/_exit instead
  of entering the stdio-based fatal-error machinery from the handler.
* **The sampler traversed the VM map from a signal handler.** On a foreign
  thread, an empty map caused a native crash. A nonempty map could identify
  a VM other than the one that started profiling. Publish the process timer's
  owner with lock-free atomics, route foreign samples to that owner, and clear
  it when stopping. A foreign SIGALRM with no active profiler is ignored.
* **Some profiler frequencies silently disabled sampling.** One sample per
  second set tv_usec to 1,000,000, which Linux rejects. Rates above 1,000,000
  truncated the interval to zero, disarming the timer. Normalize seconds and
  microseconds, clamp the interval to at least one microsecond, and check
  setitimer failures.
* **Descriptor zero was treated as an absent notification pipe.** Initialize
  native signal descriptors to -1 and accept zero as a valid output FD.

Signal numbering and disposition inheritance are described in
[signal(7)](https://man7.org/linux/man-pages/man7/signal.7.html), and the
handler sentinel interface in
[signal(2)](https://man7.org/linux/man-pages/man2/signal.2.html).
The errno preservation rule and async-signal-safe functions are documented in
[signal-safety(7)](https://man7.org/linux/man-pages/man7/signal-safety.7.html).
The timer's microsecond range and zero-value behavior are documented in
[setitimer(2)](https://man7.org/linux/man-pages/man2/setitimer.2.html).

## Verification

The original code failed the new tests for Linux names, FFI sentinels, spawn
signal-set construction, full-pipe errno preservation, descriptor zero,
one-Hz/above-resolution timers, and SIGALRM on a foreign thread without a VM.
The existing 1000-Hz timer control passed before and after the changes.

Native regressions in `vm/tests/unix_signals.cpp` run each case in its own
child process so a crashing handler cannot suppress subsequent checks. They
also cover debugger requests while the pipe is full, foreign profiler
samples, timer shutdown, and late alarms after profiling stops. Run them with:

```
make test-vm CONFIG=vm/Config.linux.x86.64 BUILD_DIR=build-signal-audit
```

The fresh native build passed all seven signal regression groups and the
existing GC tests. The combined Factor suite passed for:

```
unix.signals unix.ffi unix.types.linux unix.process io.launcher
tools.profiler.sampling io.backend.unix io.files io.pipes io.sockets
io.monitors.linux io.encodings continuations
```

The separate `math.floats.env` suite passed, including actual floating-point
traps. All six `vm/tests/stack_safety.py` tests passed, exercising hundreds of
isolated overflow and GC recovery probes. A real two-second, one-Hz profiling
run returned no samples with the old VM and samples with the fixed VM.
Existing closed-stream and TLS-rejection fixtures can print deliberate
background-thread errors; these are not failed assertions. Existing FIFO
fixtures also print missing-import restart notices.

The refreshed image passed normal-startup tests, without explicit source
refreshes, for `unix.signals`, `unix.ffi`, `io.launcher.unix`,
`tools.profiler.sampling`, `http`, and `furnace`. This includes the one-Hz
sampling regression and ensures the signal sentinels survive image reload.

The rebuilt executable and refreshed default image are prepared for the next
server restart. Their predecessors are backed up in the private directory:

```
/tmp/factor-before-signals-20260911T211050Z-__skgymu/
```

The running website was not restarted or sent test signals.

## Limits and follow-ups

Standard signals can coalesce, and a full notification pipe still drops
notifications. The Factor documentation now states this explicitly. SIGALRM
is reserved for sampling while the profiler is running; SIGUSR2 is reserved
for interrupting the console reader. Factor does not install a SIGQUIT handler,
contrary to the old documentation's claim that it entered the debugger.

This audit does not establish complete POSIX async-signal safety for every
debugger/fatal-error path. Other asynchronous signals delivered to foreign
native threads, console cancellation and debugger handoff, and embedded VM
teardown (signal-pipe ownership, alternate-stack restoration, and in-flight
handler lifetime) still need a focused lifecycle review. ITIMER_REAL remains
a single process-wide timer; simultaneous independent profilers in multiple
VMs are not supported by this change.
