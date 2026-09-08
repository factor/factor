USING: cpu.arm.64.features generic kernel system tools.test ;
! No Windows method existed at the snapshot, so Windows dispatched to object.
{ t } [ windows \ probe-arm64-features ?lookup-method >boolean ] unit-test
{ { "dotprod" "fp16" "bf16" "i8mm" } } [
    object \ probe-arm64-features lookup-method execute( -- features )
] unit-test
