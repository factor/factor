# ARM64 combined comparison

The complete OFF / ON / ON / OFF experiment passes: 27,834 identical selected
words, 30 workload outputs, two checked processes, four timing processes and
360 measured batches. SSA, interval allocation and final value-flow verification
are enabled in the checked runs. All 16 final static reports repeat across timing
processes and match the checked state. The all-OFF reports and scope also match
the previous individual-feature baseline exactly. No run was discarded.

Representation costs remain the clear witness improvement: -67.285% retired
instructions and -77.559% CPU time. Loop hoisting gives -16.705% / -11.336%,
load reuse -2.098% / -11.246%, and SLP -2.915% / +5.046%. SLP CPU ratios disagree
between rounds (-2.810% versus +13.538%); this is not a demonstrated speedup.

The original 26-workload geometric mean is -0.013% retired instructions and
-4.720% CPU time. Nearly unchanged instruction counts and final metric reports,
with material timing changes among unchanged controls, do not establish a broad
compiler speedup. Compilation retired work rises +2.741%; compile CPU ratios
are +7.704% and -10.759% in the two pairs, aggregate -1.961%. These measurements
do not identify the cause of the execution-rate variation.

Combining the flags preserves each changed witness's prior individual final
static report. The nbody size increase also remains. There is no new static
interaction among these 16 targets; that is not proof about every compiled word.
LICM motion can preserve final instruction totals while changing loop work.

[MEASUREMENTS.md](MEASUREMENTS.md) lists every workload and both pairs;
[results.json](results.json) retains absolute observations and ratios.
The source manifest, exact executed harness, preparation status, compressed raw
records/logs and SHA256 manifest are retained. The compiler source matches
6b14328972, production-equivalent to the prior measured020b74ce5d. Preparation
refreshes an existing image and is not a bootstrap measurement. Defaults remain OFF.
