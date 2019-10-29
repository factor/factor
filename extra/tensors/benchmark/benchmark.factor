! Copyright (C) 2019 HMC Clinic.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays io kernel locals math prettyprint tensors tools.time ;
IN: tensors.benchmark

<PRIVATE

:: add-tensors ( trials elems -- time )
    ! Create the arrays to be added
    elems 1array naturals dup
    ! Benchmark!
    [ trials [ 2dup t+ drop ] times ] benchmark
    ! Normalize
    trials / >float
    nip nip ;

:: matmul-tensors ( trials elems -- time )
    ! Create the arrays to be multiplied
    elems elems 2array naturals dup
    ! Benchmark!
    [ trials [ 2dup matmul drop ] times ] benchmark
    ! Normalize
    trials / >float
    nip nip ;

:: transpose-tensor ( trials elems -- time )
    ! Create the array to be transposed
    elems elems 2array naturals
    ! benchmark
    [ trials [ dup transpose drop ] times ] benchmark
    ! Normalize
    trials / >float
    nip ;

PRIVATE>

: run-benchmarks ( -- )
    "Benchmarking the tensors vocabulary" print
    "Add two 100 element tensors" print
    1000000 100 add-tensors .
    "Add two 100,000 element tensors" print
    10000 100000 add-tensors .
    "Multiply two 10x10 matrices" print
    100000 10 matmul-tensors .
    "Multiply two 100x100 matrices" print
    1000 100 matmul-tensors .
    "Transpose a 10x10 matrix" print
    10000 10 transpose-tensor .
    "Transpose a 100x100 matrix" print
    10 100 transpose-tensor . ;
