USING: cpu.arm.64.features.linux tools.test ;
IN: cpu.arm.64.features.linux.tests

{ { } } [ 0 0 hwcaps>arm64-features ] unit-test
{ { "dotprod" } } [ 0x100000 0 hwcaps>arm64-features ] unit-test
{ { "fp16" } } [ 0x400 0 hwcaps>arm64-features ] unit-test
{ { "bf16" } } [ 0 0x4000 hwcaps>arm64-features ] unit-test
{ { "i8mm" } } [ 0 0x2000 hwcaps>arm64-features ] unit-test
{ { "dotprod" "fp16" "bf16" "i8mm" } } [
    0x100400 0x6000 hwcaps>arm64-features
] unit-test
{ { } } [ 0x200 0x8000 hwcaps>arm64-features ] unit-test
