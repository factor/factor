IN: math.vectors.specialization.tests
USING: compiler.tree.debugger math.vectors tools.test kernel
kernel.private math specialized-arrays ;
SPECIALIZED-ARRAY: double
SPECIALIZED-ARRAY: complex-float
SPECIALIZED-ARRAY: float

[ V{ t } ] [
    [ { double-array double-array } declare distance 0.0 < not ] final-literals
] unit-test

[ V{ float } ] [
    [ { float-array float } declare v*n norm ] final-classes
] unit-test

[ V{ complex } ] [
    [ { complex-float-array complex-float-array } declare v. ] final-classes
] unit-test

[ V{ float } ] [
    [ { float-array float } declare v*n norm ] final-classes
] unit-test

[ V{ float } ] [
    [ { complex-float-array complex } declare v*n norm ] final-classes
] unit-test