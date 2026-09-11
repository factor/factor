# Linux I/O audit — 2026-09-11

Reviewed Unix/Linux sockets, buffered ports, file opening, mmap, pipes, epoll,
directory monitors, and process-launcher integration. The changes below address
reproduced resource leaks and incorrect I/O behavior. Tests ran in separate
Factor processes; the running website was not restarted.

## Fixes

* **File encoding construction:** protect the opened stream until `<decoder>`
  or `<encoder>` succeeds. UTF-16 decoding reads the BOM during construction;
  a missing BOM previously leaked the reader, its buffer, and its FD. Encoders
  can also perform I/O: a one-byte buffer makes the UTF-16 BOM write to
  `/dev/full` fail with `ENOSPC` inside `<file-appender>`. The regression checks
  that this failure closes the FD. A direct native-FD probe measured **15 → 16**
  with the old constructor and **15 → 15** with the fix. Reader, writer, exclusive writer, and
  appender constructors now all clean up on encoding setup failure.
* **Append seek failures:** `open-append` registered a raw integer with
  `|dispose`, which cannot close an integer FD. Use a `close-file` destructor.
  Opening `/proc/self/mem` for append and attempting `SEEK_END` reproduces the
  error without reading or writing memory. The original seek error is now
  preserved and the opened descriptor is closed.
* **Memory mappings:** retain the disposable FD wrapper as the mapping's
  handle and dispose it when closing. Previously every successful Unix mapping
  left a registered wrapper behind, even after its native FD was closed.
  Mapping handles now receive normal FD initialization, including close-on-exec.
  Closing the handle is guaranteed even if `munmap` fails. Construct/register
  the public mapping object after the backend has successfully mapped the file.
* **Pipes:** take ownership of both native pipe ends before initializing either.
  Dispose input/output ports if encoding construction fails, and release the
  first pipe if constructing the second half of `<connected-pair>` fails.
  Regression tests inject initialization and encoding failures.
* **Datagrams:** accept a successful zero-byte `recvfrom` result; retry `EINTR`,
  wait only for `EAGAIN`, and propagate other errors. Empty datagrams were
  silently discarded, and permanent receive errors were incorrectly treated
  as a reason to wait. Datagram/raw port construction and broadcast option
  setup now clean up on failure.
* **Address resolution:** always free `getaddrinfo` results, including when
  converting the address list throws. A fault-injection test verifies both
  propagation of the conversion error and exactly one `freeaddrinfo` call.
* **epoll:** create event-loop descriptors with
  `epoll_create1(EPOLL_CLOEXEC)`. They previously remained inheritable across
  exec. The regression checks the actual descriptor flag.
* **Directory monitors:** tolerate a watch already removed by the kernel,
  guarantee notification of waiting readers during disposal, and retire
  watches on `IN_IGNORED`. Disposing one child no longer terminates the
  recursive monitor pump. Removing or moving a directory now disposes all
  descendant watches, so a renamed subtree is monitored under its new paths.
  Path-component matching preserves similarly named siblings.

The receive and watch-removal behavior follows the Linux interfaces documented
in [recv(2)](https://man7.org/linux/man-pages/man2/recv.2.html),
[inotify(7)](https://man7.org/linux/man-pages/man7/inotify.7.html), and
[inotify_rm_watch(2)](https://man7.org/linux/man-pages/man2/inotify_rm_watch.2.html).
The event-loop flag is documented in
[epoll_create(2)](https://man7.org/linux/man-pages/man2/epoll_create.2.html).

## Verification

Regression tests were run against both the changed code and definitions from
the previous commit. The original code fails the empty-datagram, receive-error,
constructor-cleanup, mmap-wrapper, munmap-failure, epoll-inheritance, and monitor
rename tests. The nested-directory rename test waits for the real rename
notification before creating a file, avoiding a false pass from synthetic
notifications emitted during the initial directory scan.

The combined suite covers the common socket tests and these vocabularies:

```
io.backend.unix io.ports io.buffers io.files io.directories io.mmap io.pipes
io.monitors io.sockets.unix io.sockets.secure.unix io.launcher.unix http furnace
```

The combined suite passed. The final subtree change was additionally checked
with the complete `io.monitors` tests. Some existing TLS rejection fixtures
print expected server-thread broken-pipe diagnostics when their clients abort;
these do not represent failed test assertions.

A separate mixed stress run performed 500 rounds of mmap, epoll, pipes, UDP,
bad UTF-16 input, and failing append opens, followed by 50 recursive monitor
rename cycles. Native FDs stayed at **15 → 15**, and registered resources at
**27 → 27**. This probe uses `-no-monitors` to disable the development
vocabulary-watcher scans; it explicitly starts and tests its own inotify
monitors. Background vocabulary scans otherwise add legitimate watch objects
while the measurement is in progress.

Core I/O vocabularies can already be compiled into `factor.image`. Source-only
changes require a refresh or rebuilt image to become active on restart. The
default image was refreshed and installed after a separate normal-startup run
passed the file, mmap, pipe, socket, monitor, and epoll tests without explicit
refresh commands. The original image is backed up at:

```
/tmp/factor-before-linux-io-20260911T204232Z-6a0fgocj.image
```

Images must be tested alongside the repository or with its resource path set:
placing an image under `/tmp` changes `resource:` and can cause source-based
tests to be skipped. The normal-startup validation ran from the repository and
produced the expected test output.

## Scope limits and follow-ups

This is a targeted Linux audit, not exhaustive coverage of all devices,
filesystems, kernel errors, or platforms. Overload recovery in the server accept
loop, process-redirection descriptor/status-flag inheritance, and resynchronizing
after an inotify queue overflow remain areas for a separate focused pass.
