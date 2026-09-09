# Bootstrap execution-rate diagnosis

Read-only analysis of three existing runs. No new probe, priority change,
Factor process, or source modification was performed for this review.
This concerns the combined compiler candidate, not the isolated greedy
hint change.

| Run | Source | Core wall | Whole wall s | CPU s | Retired instructions | Cycles | Cycles / CPU s |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Previously accepted | `5c848c90f6` | 1:52 | 115.995 | 113.935 | 1,800,212,929,873 | 478,275,373,603 | 4.198 billion |
| Combined candidate | `eccfc0accc` | 2:38 | 161.490 | 159.990 | 1,798,440,724,358 | 493,455,558,857 | 3.084 billion |
| Contemporary unchanged baseline | `c1f7e4d34c` | 3:07 | 190.485 | 188.967 | 1,801,823,263,167 | 509,551,967,003 | 2.697 billion |

All exited successfully. All three status records identify the same VM,
libfactor, and input boot-image SHA-256 hashes. The boot-image hash is
`ebb781cb1391d30b679b715939b84f491da1c8014778a5bd31ed64bacc5e78cd`.
The exact records are retained in [bootstrap-rate](bootstrap-rate/).

## What the measurements establish

Against the earlier accepted run, the candidate retires 0.0984% fewer
instructions, takes 3.17% more cycles, but consumes 40.42% more CPU time.
Its counted cycles per CPU second fall 26.5%, from 4.198 to 3.084 billion.
Instructions per cycle fall only 3.17%, from 3.764 to 3.645. Thus most of
the extra time is lower execution rate while running, rather than more
compiler instructions or a proportional increase in required cycles.

The contemporary unchanged baseline is slower still: 3:07 core and
188.967 CPU seconds. Relative to it, the candidate retires 0.1877% fewer
instructions and takes 3.16% fewer cycles. This one pair is sufficient to
reject a large source-work increase as the explanation for the observed
46-second CPU increase over the historical accepted run. It does not
establish a statistically significant small instruction improvement or a
15.3% source-caused CPU speedup: the baseline itself ran at a lower rate.

None of the two current runs satisfies a two-minute wall-time budget.
The historical 1:52 result remains a historical observation, not a claim
that the candidate currently meets that budget.

## Host and launcher interpretation

Whole wall minus process CPU is only 1.50 seconds for the candidate,
1.52 for the current baseline, and 2.06 for the historical run. Ordinary
waiting off CPU therefore does not account for the extra CPU time. Lower
frequency, a different core mix, thermal limits, or scheduling/QoS effects
on execution rate are plausible explanations. These counters cannot
separate them; the cycles/CPU ratio is an effective process rate, not a
measurement of one physical core's clock.

Recorded background CPU is 0.040 seconds for the candidate, 0.052 for the
current baseline, and 0.136 for the historical run. The recorded
background bucket alone cannot account for tens of extra seconds. The
candidate's aggregate load was lower than the historical run's, so load
average alone would also be an inadequate rate guard.

The launcher is
`reference/allocator-speed-20260908/run-command.py`. Both versions launch
with `taskpolicy -a -t 0 -l 0` and run parent-side `taskpolicy -B -p PID`
once per second. The locally installed taskpolicy manual defines `-B` as
moving a process out of `PRIO_DARWIN_BG`; it does not promise a fixed core,
frequency, or uniform effective execution rate. Zero refresh failures does
not establish those conditions. The historical run's one failure is only
an aggregate count and may be the already-known exit race.

## Measurement protocol

Keep the current commands and raw process counters, but base CPU/wall
comparisons on contemporary reversed baseline/candidate pairs. Report
instructions, cycles, and cycles per CPU second together; with this size
of execution-rate disparity, decline to rank source changes by CPU time.
Do not normalize wall time into a claimed wall-budget pass.

A future small observability improvement could retain all QoS time buckets
and runnable time already present in the rusage structure, plus timestamped
refresh exit codes/stderr. Current output retains only the background
bucket and an aggregate refresh-failure count. That would improve
diagnosis, not force stable performance. No such launcher change is part
of this evidence-only commit.
