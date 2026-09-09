# GVN × rematerialization matrix

All configurations use linear scan, loop-spill policy OFF, one common refreshed source/image and the same frozen word-object closure. Defaults are unchanged.

The existing Factor arguments are preserved, with GVN added at index6: allocator, mode, samples, rematerialization, loop-spills, source, GVN. The harness applies the option, reads the actual GVN setting back, asserts it matches and emits it. The driver independently checks all emitted flags, mode and record counts and retains image/VM/script hashes.

Four configurations are denoted GVN/rematerialization:00,10,01,11. Run strict checked closures for all four first. Then run fresh timing processes in balanced order00,10,11,01 /01,11,10,00 with three measured batches per26 workloads. This produces624 measured runtime batches, six per configuration/workload, and two compiler observations per configuration. Each process compiles and installs the selected full compiler/workload closure before dynamically invoking the actual workload word handles. The original12 static kernel reports remain.

Compare all language outputs across configurations. Report compiler and runtime CPU/retired work, per-case/per-round changes, code/spill/reload/copy metrics and factorial interaction. Separate untimed fixtures must demonstrate actual GVN elimination and rematerialized loads; enabled settings alone are not activity evidence. Machine-IR copy counts are not emitted movement counts.

Native Linux timing uses CPU2, nice0 and the identical capability-bearing VM. macOS uses the existing foreground/background guards and applies external taskpolicy to each owned child; an exited-child race is accepted only after confirming process exit. No failed or incomplete attempt is silently promoted into accepted data.
