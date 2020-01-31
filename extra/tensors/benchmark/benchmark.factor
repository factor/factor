! Copyright (C) 2019 HMC Clinic.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays arrays.shaped io kernel locals math math.matrices math.ranges
prettyprint tensors tools.time ;
IN: tensors.benchmark

<PRIVATE

! benchmarking for tensors vocabulary
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
    [ trials [ dup tensors:transpose drop ] times ] benchmark
    ! Normalize
    trials / >float
    nip ;

! benchmarking for arrays.shaped vocabulary
:: add-shaped-array ( trials elems -- time )
    ! Create the arrays to be added
    elems 1array increasing dup
    ! Benchmark!
    [ trials [ 2dup shaped+ drop ] times ] benchmark
    ! Normalize
    trials / >float
    nip nip ;

! benchmarking for math.matrices vocabulary
:: add-matrices ( trials elems -- time )
    ! Create the arrays to be added
    0 elems 1 - 1 <range> <square-rows> 0 elems elems * elems - elems <range> <square-cols> m+ dup
    ! Benchmark!
    [ trials [ 2dup m+ drop ] times ] benchmark
    ! Normalize
    trials / >float
    nip nip ;

:: matmul-matrices ( trials elems -- time )
    ! Create the arrays to be multiplied
    0 elems 1 - 1 <range> <square-rows> 0 elems elems * elems - elems <range> <square-cols> m+ dup
    ! Benchmark!
    [ trials [ 2dup m. drop ] times ] benchmark
    ! Normalize
    trials / >float
    nip nip ;

:: transpose-matrix ( trials elems -- time )
    ! Create the array to be transposed
    0 elems 1 - 1 <range> <square-rows> 0 elems elems * elems - elems <range> <square-cols> m+
    ! benchmark
    [ trials [ dup math.matrices:transpose drop ] times ] benchmark
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
    "Multiply two 10x10 tensors" print
    100000 10 matmul-tensors .
    "Multiply two 100x100 tensors" print
    1000 100 matmul-tensors .
    "Transpose a 10x10 tensor" print
    10000 10 transpose-tensor .
    "Transpose a 100x100 tensor" print
    10 100 transpose-tensor . 
    "Benchmarking the arrays.shaped vocabulary" print
    "Add two 100 element shaped arrays" print
    1000000 100 add-shaped-array .
    "Add two 100,000 element shaped arrays" print
    10000 100000 add-shaped-array .
    "Benchmarking the math.matrices vocabulary" print
    "Add two 10x10 matrices" print
    1000000 10 add-matrices .
    "Add two 316x316 matrices" print
    10000 316 add-matrices .
    "Multiply two 10x10 matrices" print
    100000 10 matmul-matrices .
    "Multiply two 100x100 matrices" print
    1000 100 matmul-matrices .
    "Transpose a 10x10 matrix" print
    10000 10 transpose-matrix .
    "Transpose a 100x100 matrix" print
    10 100 transpose-matrix . 
    ;
