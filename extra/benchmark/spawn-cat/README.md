# Spawning cat

Based on [Jarred Sumner's benchmark](https://gist.github.com/Jarred-Sumner/54990c8de079b90f5eca797c3894480b).
Each batch starts 100 children without a shell, discards all standard streams,
and waits for every child to exit successfully. Both versions read the same file.
The original runs 1,001 batches and prints RSS; these timing runs use five warmup
batches followed by three rounds of 100 batches, excluding runtime startup and
printing from the timed region. Run the runtimes sequentially, not concurrently.

From the repository root:

```sh
./factor -no-user-init -e='USING: benchmark.spawn-cat kernel math tools.time vocabs.refresh ; "io.backend.unix.multiplexers" refresh "io.launcher" refresh 5 [ "resource:extra/benchmark/spawn-cat/spawn-cat.factor" spawn-cat-batch ] times 3 [ [ spawn-cat-benchmark ] time ] times'
bun extra/benchmark/spawn-cat/bun.mjs
```

`spawn-cat ( path batches -- )` also accepts another input file. Pass that same
absolute path to the Bun script as its first argument.

## Measurements

macOS ARM64, Bun 1.4.2, September 25, 2026. These measurements used the original
910-byte gist as input for both runtimes. Times are medians of three rounds,
each spawning 10,000 processes; they are machine-specific, not cross-platform claims.

| Implementation | Seconds |
| --- | ---: |
| Factor before changes | 5.445 |
| Factor with environment/resource cleanup | 4.860 |
| Factor also sharing the discarded-stream descriptor | 3.607 |
| Factor also resolving PATH before spawning | 2.461 |
| Factor also using kqueue child-exit notification | 1.951 |
| Bun, using `node:child_process` (final comparison) | 1.936 |

The final sequential comparison was Factor 1.993/1.929/1.951 seconds and Bun
1.901/1.936/1.943 seconds. Factor is about 2.8 times faster than its baseline;
its difference from Bun is smaller than the observed run-to-run variation.

Factor's final round breakdown is about 1.87 seconds spawning and 0.08 seconds
waiting for completion, down from about 0.61 seconds waiting with polling.
These are wall-clock phases, including OS work, rather
than CPU-only measurements. Sampling the original implementation identified
environment decoding, reconstruction and C-string allocation; inclusive profile
percentages overlap and should not be added together.

A C control using equivalent POSIX spawn actions took about 4.27 seconds.
Replacing three child-side `/dev/null` opens with descriptor duplication brought
it to about 2.94 seconds. Omitting the working-directory action and adding
`POSIX_SPAWN_CLOEXEC_DEFAULT` did not improve that control materially.

The Factor change also frees argument/environment strings and destroys spawn
attributes/actions on success and failure. Inherited environments are read live,
not cached. Kqueue signal notifications wake the existing reaping thread on
SIGCHLD. Backends without signal notification support retain polling, with a
corrected 100-millisecond backoff cap. Registration is followed by another
nonblocking reap to cover children that exited before notification was installed.

## Comparison with Bun 1.4.2 source

Bun's [`node:child_process`](https://github.com/oven-sh/bun/blob/bun-v1.4.2/src/js/node/child_process.ts)
delegates to `Bun.spawn`. Its bindings resolve the executable with
[`which_for_spawn`](https://github.com/oven-sh/bun/blob/bun-v1.4.2/src/which/lib.rs)
before calling `posix_spawn`, whereas Factor previously called `posix_spawnp`.
Before implementing PATH lookup and event notification, giving Factor `/bin/cat`
explicitly reduced its median
to 2.280 seconds (about 1.67 spawning and 0.61 waiting). This diagnostic bypasses
PATH lookup; it is not the equivalent-workload result in the table above.

Bun's [`Process`](https://github.com/oven-sh/bun/blob/bun-v1.4.2/src/spawn/process.rs)
uses kqueue process-exit notifications on macOS, avoiding a polling timer.
It frees temporary C strings and spawn objects after each call.
Its [ignored-stdio setup](https://github.com/oven-sh/bun/blob/bun-v1.4.2/src/spawn_sys/spawn_process.rs)
still uses `/dev/null` open actions; the shared descriptor optimization above
is a separate experiment, not a description of Bun's implementation.

Factor now probes PATH without caching it, resolves relative entries against
the child's working directory, and calls `posix_spawn` on a candidate. If no
candidate is found or execution fails, it falls back to libc's `posix_spawnp`.
Tests cover PATH changes, relative/empty entries, directory and non-executable
candidates, fast concurrent exits, signal delivery, redirection, environment
overrides, resource cleanup, timeouts, and process groups. Native validation
was on macOS ARM64; other operating systems were not benchmarked.
