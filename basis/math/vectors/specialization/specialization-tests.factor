IN: math.vectors.specialization.tests
USING: compiler.tree.debugger math.vectors tools.test kernel
kernel.private math specialized-arrays.double
specialized-arrays.float ;

[ V{ t } ] [
    [ { double-array double-array } declare distance 0.0 < not ] final-literals
] unit-test

[ V{ float } ] [
    [ { float-array float } declare v*n norm ] final-classes
] unit-test