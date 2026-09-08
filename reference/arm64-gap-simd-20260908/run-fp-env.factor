USING: io parser vocabs.loader ;
"Refreshing backend" print flush
"cpu.arm.64.assembler" reload
"math.vectors.simd.intrinsics" reload
"cpu.arm.64" reload
"Backend refreshed; compiling workload" print flush
"reference/arm64-gap-simd-20260908/fp-env.factor" run-file
