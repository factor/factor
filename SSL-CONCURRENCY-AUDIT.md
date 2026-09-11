# SSL, I/O ownership, and concurrency audit — 2026-09-11

The production log showed SQLite `SQLITE_CANTOPEN` and resolver `EAI_SYSTEM`
failures. Descriptor exhaustion can cause both, but the old resolver diagnostic
omitted `errno`, and the log does not establish the cause. The initial fix commit
closes reproducible constructor leaks, preserves that diagnostic, and keeps
website maintenance running after a failed iteration. Deployment and observation
of the actual website process are still needed to confirm the production cause.

## Scope

Reviewed the secure socket abstraction, OpenSSL socket implementation, Unix and
Windows adapters, initialization and crypto/SSL bindings, checksum contexts,
STARTTLS, session caching, certificate matching, callbacks, handshake/read/write/
shutdown paths, timers, timeout cancellation, all `concurrency.*` implementations,
the green-thread scheduler, Unix I/O multiplexers, and the VM's native thread,
callback, profiler, signal, and atomic interfaces. This is a source audit with
Linux regression testing, not a claim that every platform or interleaving has
been exercised.

## Changes

### SSL and native resources

* Verify explicit IPv4/IPv6 connections as well as resolved hostnames. Preserve
  an explicit hostname override, propagate it through resolution and STARTTLS,
  and omit numeric IP addresses from SNI. Use the socket's original context for
  certificate verification. Local sockets need an explicit hostname for an
  identity check.
* Use OpenSSL's hostname/IP checks: DNS SANs take precedence over the common
  name, IP addresses require IP SANs, and wildcards match one nonempty label.
  Reject embedded NULs. Release peer certificate and GENERAL_NAMES references,
  and copy ASN.1 strings using their actual lengths.
* Configure ALPN once per context. Use binary buffers and counted lengths in the
  FFI; copy negotiated protocol data by length. Callback userdata is unmanaged
  memory retained until the final SSL handle releases the context. Selected
  protocol pointers refer to the native peer buffer, not movable Factor memory.
* Bound the session cache to 256 entries, free replaced/evicted references, and
  include the secure hostname in Unix cache keys.
* Return the number of password bytes actually copied into OpenSSL's buffer.
  Free parsed DH parameters after transferring them to the context. Protect
  failed checksum initialization and allocation.
* Capture syscall `errno` before inspecting SSL errors; use caller-owned error
  buffers instead of OpenSSL's shared static buffer. Clear the error queue
  before handshake operations and reject unsuccessful terminal handshakes.
  Handle SSL_shutdown's nonnegative results separately from failed operations.
* Correct initialization flag combination, binary ALPN signatures, RSA key-file
  arguments, digest/EC buffer sizes, certificate decoding length, cipher-suite
  and context-switch return types, and protocol-limit macro wrappers. Bind
  crypto APIs to the configured libcrypto instead of a hard-coded Windows DLL;
  restore libssl selection for subsequent SSL functions.
* Release Windows certificate enumeration/store objects on success and failure;
  use a caller-owned buffer for certificate name printing.

### Scheduling and I/O

* Cancel I/O timeout timers in `finally`, including when an operation throws.
  Clear timer running/thread state when callbacks fail or loops exit.
* Give timed condition waits a notification token, preventing an already queued
  timeout callback from deleting/resuming a waiter after notification won.
* Recheck lock, reader/writer lock, semaphore, and flag predicates after waking.
  A runnable thread can acquire a resource before an earlier waiter resumes.
* Preserve a single monotonic deadline across wakeups in locks, semaphores,
  flags, promises, and mailbox receives/close waits. Unmatched mailbox messages
  no longer extend a selective receive's timeout indefinitely.
* Make parallel-filter collect predicate results independently, then assemble
  the result in input order. Parallel-map uses generic intermediate storage so
  predicates/results need not fit the input sequence's element type.
* Preserve the first linked promise error when several supervised stages fail.
* Merge epoll registrations with EPOLL_CTL_MOD when a descriptor already has
  readers or writers. Removing one direction preserves the other registration.
  Protect epoll/kqueue construction, and publish kqueue callbacks only after
  native registration succeeds.
* Close and unregister Unix descriptors even if cancellation raises an error;
  attempt cancellation of both input and output callbacks.

### Native VM preparation

* Replace volatile loads/stores plus fences with actual atomic operations.
  GCC/Clang operations are required to be lock-free because signal paths use
  them; MSVC uses Interlocked operations. Profiler counters and remaining
  accesses to the affected flags now use these operations consistently.
* Check pthread_setspecific failure rather than silently losing the current VM.

These changes retain cooperative Factor threads. The waiter tokens, caches,
reference counters, and container mutations still rely on that execution model.

## Validation

* Linux x86-64 VM build, followed by execution using the rebuilt VM and the
  sampling-profiler suite (including GC and compacting GC while profiling).
* Standalone native atomic publication/counter stress test, including a clean
  ThreadSanitizer run:

  ```sh
  g++ -std=c++17 -O1 -g -fsanitize=thread -pthread vm/tests/atomic.cpp -o /tmp/factor-atomic-tsan
  /tmp/factor-atomic-tsan
  ```

* Existing SSL/OpenSSL/checksum and threading/concurrency/timer/timeout suites;
  existing socket/server tests and added Unix cancellation/epoll regressions.
* Certificate fixtures cover SAN precedence, IPv4/IPv6, wildcard boundaries,
  and NUL rejection. ALPN tests check exact wire bytes, invalid lengths, native
  pointer ownership, and a real local nonblocking handshake. Callback tests
  check password buffer boundaries and context disposal with a live SSL handle.
* Deterministic lock/semaphore/flag barging tests; selective mailbox timeout
  under repeated unmatched messages; notification-versus-timeout regression.
* Initial FD regression: 200 failed client encoding constructors leaked 200
  descriptors before the first fix and zero afterward.

The checked-in image was older than the source tree. Factor tests used a
refreshed temporary image, the repository resource path, no user init, and a
writable temporary directory. Deliberate failed-connection/thread tests emit
expected background errors; the test failure collection is the pass/fail gate.
Windows, macOS/kqueue, older OpenSSL/LibreSSL, and MSVC execution were not available
for this run. Cross-platform changes require their normal platform CI coverage.

## Remaining work before native Factor threads

1. **VM entry and lifetime.** `thread_vms` is an unsynchronized global map, used
   by platform signal/exception/console paths as well as VM registration. It
   retains entries during VM destruction. Define a signal-safe lookup and
   unregister/lifetime protocol; an ordinary mutex in a signal handler is not
   a solution. The standalone-thread entry also needs a defined argument and VM
   ownership contract if it is to return without exiting the process.
2. **Heap and scheduler ownership.** Contexts, special objects, run/sleep queues,
   thread registries, allocation, GC roots, write barriers, code mutation, and
   callback heaps assume one running mutator per VM. Establish per-worker state
   and stop-the-world/safepoint coordination before permitting shared-heap
   execution. Per-VM native threads are a separate, smaller milestone.
3. **Wait and cancellation protocol.** Predicate checks, queue insertion, token
   claims, ownership transfer, and suspension must be one coordinated operation
   under native execution. Define interruption/unwind cleanup as well as normal
   notification and timeout behavior. Audit fairness/starvation separately;
   these fixes enforce resource ownership, not FIFO scheduling.
4. **I/O and FFI affinity.** Decide who owns each SSL object, port buffer,
   multiplexer, and native callback. Keep an SSL operation and SSL_get_error on
   the same OS thread. Coordinate readiness/cancellation with descriptor reuse;
   global multiplexer maps and disposable registries are not native-safe.
5. **Shared library state.** Synchronize context initialization, session caches,
   context user counts, promises, mailboxes, flags, exchangers, countdowns, and
   shared containers. Disjoint parallel writes still require correct GC/write
   barrier behavior. OpenSSL <1.1 additionally needs its legacy locking setup
   or an explicit support cutoff.
6. **Distributed messaging.** Its global connection map and writes to a shared
   serialized stream need an ownership/serialization policy. Repeated `connect`
   for the same remote key can replace a live stream; overlapping scopes and
   reconnects require a defined lifecycle before a reliable fix.

## Remaining SSL policy/platform findings

* Windows still reports certificate verification unsupported and defaults to
  `verify = f`. The certificate-store helper builds a store but does not install
  it into an SSL_CTX. A tested Windows trust-store integration and a verified
  default are required; cleanup and DLL binding fixes do not establish trust.
* The existing cipher compatibility list, TLS minimum defaults, and
  IGNORE_UNEXPECTED_EOF behavior remain policy decisions. Strict truncation
  detection and a modern protocol baseline need interoperability tests.
* Legacy public structure layouts and version-sensitive bindings remain in the
  bindings vocabulary. OpenSSL option widths differ across releases/platforms;
  a versioned binding strategy is preferable to assuming one ABI everywhere.
* Verify the actual website database path, parent-directory/journal permissions,
  descriptor count/limit, and resolver errno after deploying the initial fixes.
  No website deployment or SMTP message was performed during this audit.

## API references

* [OpenSSL ALPN buffer and callback contracts](https://docs.openssl.org/3.3/man3/SSL_CTX_set_alpn_select_cb/)
* [OpenSSL hostname and IP verification](https://docs.openssl.org/3.0/man3/X509_check_host/)
* [OpenSSL password callback contract](https://docs.openssl.org/3.0/man3/SSL_CTX_set_default_passwd_cb/)
* [SSL_get_error thread and error-queue requirements](https://docs.openssl.org/3.6/man3/SSL_get_error/)
* [Cipher-list and cipher-suite return values](https://docs.openssl.org/3.0/man3/SSL_CTX_set_cipher_list/)
* [Private-key file APIs](https://docs.openssl.org/3.0/man3/SSL_CTX_use_certificate/)

Binding signatures and macro wrappers were also checked against the installed
OpenSSL C headers under `/usr/include/openssl`.
