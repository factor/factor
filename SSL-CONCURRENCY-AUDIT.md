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
  protocol pointers refer to native context/peer buffers, not movable Factor
  memory. Selection preserves the server's protocol preference.
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

### Scheduling and I/O

* Cancel I/O timeout timers in `finally`, including when an operation throws.
  Clear timer running/thread state when callbacks fail or loops exit.
* Recheck lock, reader/writer lock, semaphore, and lower-flag predicates after
  waking. A runnable thread can acquire a resource before an earlier waiter
  resumes. Ordinary flag waits retain broadcast notification semantics.
* Preserve a single monotonic deadline across wakeups in locks, semaphores,
  and mailbox receives. Unmatched mailbox messages
  no longer extend a selective receive's timeout indefinitely.
* Make parallel-filter collect predicate results independently, then assemble
  the result in input order. Parallel-map allocates storage from the output
  exemplar so results need not fit the input sequence's element type.
* Preserve the first linked promise error when several supervised stages fail.
* Merge epoll registrations with EPOLL_CTL_MOD when a descriptor already has
  readers or writers. Removing one direction preserves the other registration.
  Protect epoll construction.
* Close and unregister Unix descriptors even if cancellation raises an error;
  attempt cancellation of both input and output callbacks.
* Release the semaphore actually acquired by a server handler, including when
  that server is stopped/reinitialized before the old handler finishes.

### Native VM preparation

* Replace volatile loads/stores plus fences with actual atomic operations.
  GCC/Clang operations are required to be lock-free because signal paths use
  them; MSVC uses Interlocked operations. Profiler counters and remaining
  accesses to the affected flags now use these operations consistently.
* Check pthread_setspecific failure rather than silently losing the current VM.

These changes retain cooperative Factor threads. The wait queues, caches,
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
  pointer ownership, and a real local nonblocking handshake after the server
  context owner has been disposed. STARTTLS checks SNI at the peer. Callback tests
  check password buffer boundaries and context disposal with a live SSL handle.
* Deterministic lock/semaphore/flag barging tests; selective mailbox timeout
  under repeated unmatched messages; preserved flag broadcast behavior.
* Initial FD regression: 200 failed client encoding constructors leaked 200
  descriptors before the first fix and zero afterward.

The checked-in image was older than the source tree. Factor tests used a
refreshed temporary image, the repository resource path, no user init, and a
writable temporary directory. Deliberate failed-connection/thread tests emit
expected background errors; the test failure collection is the pass/fail gate.
Windows, macOS/kqueue, older OpenSSL/LibreSSL, and MSVC execution were not available
for this run. The Windows certificate-helper and kqueue rewrites were reverted
in the second pass and deferred. Shared binding/VM changes still require their
normal platform CI coverage. Optional newer OpenSSL tests check API availability.

## Second-pass review and evidence

The follow-up review checked whether the regressions actually detect removal of
the fixes, not merely whether they pass on the changed tree. Old definitions were
loaded in isolated Factor processes after requiring the affected vocabulary, then
the committed regression files were run. Requiring the vocabulary first matters:
otherwise a test's USING: can reload the current implementation and invalidate a
mutation check. The baseline was `2d59e4e38c`; the three review regressions below
also tested the first audit's behavior (`84215f2d78`). No baseline files were
written over the working tree.

Three behavior/lifecycle problems in the first pass were corrected:

* ALPN had unintentionally preferred client order. A reversed-order test got
  `http/1.1` instead of the server's preferred `h2`. Context-owned native storage
  permits preserving server preference safely; the corrected test passes.
* Rechecking ordinary flag waits lost an already-delivered broadcast when a
  different consumer lowered the flag. That test timed out. The recheck now
  applies only to `lower-flag`, and both broadcast and consumer tests pass.
* A finishing server handler looked up the server's current semaphore rather
  than its acquired one. Replacing the semaphore during shutdown left the old
  permit unavailable. Capturing that semaphore fixes the failing lifecycle test.

Changes narrowed or deferred:

* Removed condition-waiter tokens and their artificial stopped-callback test.
  The test did not establish an interleaving through the cooperative scheduler;
  native waits need an atomic queue/suspend/cancellation design, not this token.
* Removed speculative deadline conversions for one-shot promises and the unused
  mailbox close-wait helper. Kept conversions for resource/receive loops with
  actual repeated-wakeup cases. The linked-promise error fix remains.
* Removed the unexecuted Windows certificate-helper and kqueue rewrites. Their
  findings remain documented below rather than being claimed as validated fixes.
* Allocated parallel-map results using the requested exemplar, avoiding the
  unnecessary generic intermediate introduced in the first pass. String-to-array
  mapping and string filtering both pass.

| Retained change | Failure with old code / evidence | Regression location |
| --- | --- | --- |
| Client, server, accept construction cleanup | Three resource-count failures | `io.sockets.unix` |
| SQLite failed-open cleanup | Native SQLite allocation count grows | `db.sqlite.lib` |
| SQLite failed-step result cleanup | Disposable count grows after UNIQUE failure | `db.sqlite.lib` |
| Resolver diagnostics | EAI_SYSTEM omits the injected EMFILE diagnostic | `io.sockets.unix` |
| Maintenance recovery | Expiry and planet tasks fail to reach a second iteration | `furnace.alloy`, `webapps.planet` |
| Server connection limits | Second handler starts while the only permit is occupied | `io.servers` |
| Unix close after cancellation failure | Native descriptor remains usable instead of returning EBADF | `io.backend.unix/tests/cleanup.factor` |
| Duplex epoll registrations | EEXIST when adding another direction/reader | `io.backend.unix.multiplexers.epoll` |
| Lock / reader-writer lock / semaphore rechecks | Waiters proceed after a different thread acquires the resource | `concurrency.locks`, `concurrency.semaphores` |
| Receive deadlines | Unmatched messages extend the deadline | `concurrency.mailboxes` |
| Failed operation timeout cleanup | Timer cancels a later operation | `io.timeouts` |
| Timer exit state | Failed callback leaves thread/running state set | `timers` |
| Parallel result ordering | Delayed predicates return elements in completion order | `concurrency.combinators` |
| Linked promise errors | Second linked error throws instead of preserving the first | `concurrency.promises` |
| Checksum constructor cleanup | Unknown digest leaves a registered native context | `checksums.openssl` |
| Session replacement and cache bound | Old: 0 early frees, 301 cached, 301 total frees; fixed: 1, 256, 302 | `io.sockets.secure.openssl/tests/sessions.factor` |
| Terminal TLS handshake | EOF returns a client stream instead of failing construction | `io.sockets.secure.unix` |
| STARTTLS identity | Server receives no SNI; fixed receives `localhost` | `io.sockets.secure.unix/tests/starttls.factor` |
| Native atomics | ThreadSanitizer reports a byte load/store race; same stress test is clean with the fix | `vm/tests/atomic.cpp` |

The session test uses OpenSSL ex_data free callbacks to count real native frees,
including replacement, eviction, and final context disposal. It does not infer
native cleanup from Factor registry counts. Its callback index is released after
the test. TLS lifetime tests exercise a handshake after context disposal, not
just the reference-count slots. Binding tests call the protocol-limit wrappers,
cipher-suite setter, SSL context switch, and both RSA key-file APIs. ECDSA tests
exercise the EC buffer bindings. Width/signature corrections additionally rely
on the installed OpenSSL headers; large (>4 GiB) buffers and every legacy ABI
have not been exercised.

The final validation uses a freshly saved temporary image containing the
reviewed source, so the Unix backend's subprocess test also executes that code.
The retained platform-specific MSVC atomic branch and shared code on other OSes
remain explicit platform-CI requirements; Linux results do not establish them.

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
  default are required; DLL binding fixes do not establish trust. The helper
  also leaks store/certificate references and uses the wrong allocator for a
  printed name. Its cleanup rewrite was deferred pending Windows tests.
* The existing cipher compatibility list, TLS minimum defaults, and
  IGNORE_UNEXPECTED_EOF behavior remain policy decisions. Strict truncation
  detection and a modern protocol baseline need interoperability tests.
* kqueue construction and failed-registration cleanup need macOS/BSD regression
  coverage before adopting the proposed ownership changes.
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
