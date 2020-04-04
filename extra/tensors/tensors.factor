! Copyright (C) 2019 HMC Clinic.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors alien alien.c-types alien.data arrays byte-arrays combinators
grouping kernel locals kernel.private math math.functions math.ranges math.vectors
math.vectors.simd multi-methods parser prettyprint.custom sequences sequences.extras
sequences.private specialized-arrays typed ;

QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAY: c:float
SPECIALIZED-ARRAY: float-4
IN: tensors

! Tensor class definition
TUPLE: tensor
    { shape array }
    { vec float-array } ;

! Errors
ERROR: non-positive-shape-error shape ;
ERROR: shape-mismatch-error shape1 shape2 ;
ERROR: non-uniform-seq-error seq ;

<PRIVATE

! Check that the shape has only positive values
: check-shape ( shape -- shape )
    dup [ 1 < ] map-find drop [ non-positive-shape-error ] when ;

! Construct a tensor of zeros
: <tensor> ( shape seq -- tensor )
    tensor boa ;

! Creates a freshly-allocated float-array with the desired c-type values
: >float-array ( seq -- float-array )
    c:float >c-array ;

: repetition ( shape const -- tensor )
    [ check-shape dup product ] dip <repetition>
    >float-array <tensor> ;

PRIVATE>

! Construct a tensor of zeros
: zeros ( shape -- tensor )
    0 repetition ;

! Construct a tensor of ones
: ones ( shape -- tensor )
    1 repetition ;

! Construct a one-dimensional tensor with values start, start+step,
! ..., stop (inclusive)
: arange ( a b step -- tensor )
    <range> [ length >fixnum 1array ] keep >float-array <tensor> ;

! Construct a tensor with vec { 0 1 2 ... } and reshape to the desired shape
: naturals ( shape -- tensor )
    check-shape [ ] [ product [0,b) >float-array ] bi <tensor> ;

! Construct a tensor without initializing its values
: (tensor) ( shape -- tensor )
    dup product (float-array) <tensor> ;

<PRIVATE

: check-reshape ( shape1 shape2 -- shape1 shape2 )
    2dup [ product ] bi@ = [ shape-mismatch-error ] unless ;

PRIVATE>

! Reshape the tensor to conform to the new shape
: reshape ( tensor shape -- tensor )
    [ dup shape>> ] [ check-shape ] bi* check-reshape nip >>shape ;

! Flatten the tensor so that it is only one-dimensional
: flatten ( tensor -- tensor )
    dup shape>>
    product { } 1sequence >>shape ;

! outputs the number of dimensions of a tensor
: dims ( tensor -- n )
    shape>> length ;

! Turn into Factor ND array form
! Source: shaped-array>array
TYPED: tensor>array ( tensor: tensor -- seq: array )
    [ vec>> >array ] [ shape>> ] bi
    [ rest-slice reverse [ group ] each ] unless-empty ;

<PRIVATE
! recursively finds shape of nested array
! assumes properly shaped array (all sub-arrays are same size)
:: find-shape ( seq shape -- shape' )
    seq empty? [ { 0 } ] [
        ! add length of seq element to shape
        shape seq length 1array append :> shape'
        ! base case: check if the first element is a seq
        seq first :> 1st
        1st sequence?
        ! is a sequence: recurse on 1st element
        [ 1st shape' find-shape ]
        ! not a sequence: return shape'
        [ shape' ] if
    ] if ;
PRIVATE>

! turns a nested array into a tensor
:: >tensor ( seq -- tensor )
    ! get the shape
    seq { } find-shape :> shape
    ! flatten the array
    seq
    shape length 1 - [
        drop concat
    ] each-integer :> flatseq
    ! check that the size is good
    shape product flatseq length =
    [ seq non-uniform-seq-error ] unless
    ! turn into a tensor
    shape flatseq >float-array <tensor> ;

SYNTAX: t{ \ } [ >tensor ] parse-literal ;

! Pretty printing
syntax:M: tensor pprint-delims drop \ t{ \ } ;
syntax:M: tensor >pprint-sequence tensor>array ;
syntax:M: tensor pprint* pprint-object ;

! Sequence protocol implementation
syntax:M: tensor clone [ shape>> clone ] [ vec>> clone ] bi <tensor> ;

syntax:M: tensor length vec>> length ;

syntax:M: tensor nth-unsafe vec>> nth-unsafe ;

syntax:M: tensor set-nth-unsafe vec>> set-nth-unsafe ;

syntax:M: tensor new-sequence
    ! Check if the old and new tensors are the same size
    shape>> 2dup product =
    ! If so preserve the shape, otherwise create a 1D tensor
    [ nip (tensor) ] [ drop 1array (tensor) ] if ;

syntax:M: tensor like
    ! If the original sequence is already a tensor, we are done
    over tensor?
    [ drop ] [
        over float-array? [
            [ dup [ length 1array ] dip <tensor> ] dip
        ] [
            [ >tensor ] dip
        ] if
        2dup [ length ] bi@ = [ shape>> reshape ] [ drop ] if
    ] if ;

syntax:M: tensor clone-like
    ! If the original sequence is already a tensor, we just need to clone it
    over tensor?
    [ drop clone ] [
        [ >tensor ] dip
        2dup [ length ] bi@ = [ shape>> reshape ] [ drop ] if
    ] if ;

INSTANCE: tensor sequence


<PRIVATE

:: make-subseq ( arr start len -- arr )
    ! Find the index
    c:float heap-size start *
    ! Compute the starting pointer
    arr underlying>> <displaced-alien>
    ! Push length and type to create the new array
    len c:float <c-direct-array> ; inline

: check-bop-shape ( shape1 shape2 -- shape )
    2dup = [ shape-mismatch-error ] unless drop ;

! Apply the binary operator bop to combine the tensors
TYPED:: t-bop ( tensor1: tensor tensor2: tensor quot: ( x y -- z ) -- tensor: tensor )
    tensor1 shape>> tensor2 shape>> check-bop-shape
    tensor1 vec>> tensor2 vec>> quot 2map <tensor> ; inline

! Create an array of 4-element SIMD arrays for processing floats
: simd-for-bop ( array -- simd-array rest-slice/f )
    dup length dup 4 mod [ drop f ] [ - cut-slice ] if-zero
    [ float-4 cast-array ] dip ; inline

! Create an array of 4-element SIMD arrays for processing floats
! Tensor class definition
TUPLE: simd-slice
    { first-slice float-array }
    { simd-slice float-4-array }
    { end-slice float-array } ;

:: (simd-slice) ( arr start len -- arr/f )
    len [ float-array{ } ] [ drop arr start len make-subseq ] if-zero ; inline

:: <simd-slice> ( arr start -- simd-slice )
    ! Compute the beginning
    arr 0 start (simd-slice)
    ! Compute the SIMD part
    arr length start - :> len
    len 4 mod :> end
    arr start len end - (simd-slice) float-4 cast-array
    ! Compute the end
    arr dup length end - end (simd-slice)
    simd-slice boa ; inline

! Apply the binary operators simd-quot and quot to quickly combine the tensors
:: t-bop-simd ( tensor1 tensor2 simd-quot: ( x y -- z ) quot: ( x y -- z ) -- tensor )
    tensor1 shape>> tensor2 shape>> check-bop-shape
    tensor1 vec>> tensor2 vec>>
    dup length (float-array) dup :> vec3
    [ simd-for-bop ] tri@ :> ( simd1 rest1 simd2 rest2 simd3 rest3 )
    simd1 simd2 simd-quot simd3 2map-into
    rest1 rest2 quot rest3 2map-into
    vec3 <tensor> ; inline

! Apply the operation to the tensor
TYPED:: t-uop ( tensor: tensor quot: ( x -- y ) -- tensor: tensor )
    tensor vec>> quot map [ tensor shape>> ] dip <tensor> ; inline

! Apply the binary operators simd-quot and quot to quickly combine a tensor and
! a number
:: t-uop-simd ( tensor n simd-quot: ( x y -- z ) quot: ( x y -- z ) -- tensor )
    tensor dup [ shape>> ] [ vec>> ] bi*
    dup length (float-array) dup :> vec2
    [ simd-for-bop ] bi@ :> ( simd1 rest1 simd2 rest2 )
    simd1 n n n n float-4-boa simd-quot curry simd2 map-into
    rest1 n quot curry rest2 map-into
    vec2 <tensor> ; inline

PRIVATE>

! Add a tensor to either another tensor or a scalar
multi-methods:GENERIC: t+ ( x y -- tensor )
METHOD: t+ { tensor tensor } [ v+ ] [ + ] t-bop-simd ;
METHOD: t+ { tensor number } >float [ v+ ] [ + ] t-uop-simd ;
METHOD: t+ { number tensor } swap >float [ swap v+ ] [ swap + ] t-uop-simd ;

! Subtraction between two tensors or a tensor and a scalar
multi-methods:GENERIC: t- ( x y -- tensor )
METHOD: t- { tensor tensor } [ v- ] [ - ] t-bop-simd ;
METHOD: t- { tensor number } >float [ v- ] [ - ] t-uop-simd ;
METHOD: t- { number tensor } swap >float [ swap v- ] [ swap - ] t-uop-simd ;

! Multiply a tensor with either another tensor or a scalar
multi-methods:GENERIC: t* ( x y -- tensor )
METHOD: t* { tensor tensor } [ v* ] [ * ] t-bop-simd ;
METHOD: t* { tensor number } >float [ v* ] [ * ] t-uop-simd ;
METHOD: t* { number tensor } swap >float [ swap v* ] [ swap * ] t-uop-simd ;

! Divide two tensors or a tensor and a scalar
multi-methods:GENERIC: t/ ( x y -- tensor )
METHOD: t/ { tensor tensor } [ v/ ] [ / ] t-bop-simd ;
METHOD: t/ { tensor number } >float [ v/ ] [ / ] t-uop-simd ;
METHOD: t/ { number tensor } swap >float [ swap v/ ] [ swap / ] t-uop-simd ;

! Mod two tensors or a tensor and a scalar
multi-methods:GENERIC: t% ( x y -- tensor )
METHOD: t% { tensor tensor } [ mod ] t-bop ;
METHOD: t% { tensor number } >float [ mod ] curry t-uop ;
METHOD: t% { number tensor } [ >float ] dip [ mod ] with t-uop ;

<PRIVATE

! Check that the tensor has an acceptable shape for matrix multiplication
: check-matmul-shape ( tensor1 tensor2 -- )
    [let [ shape>> ] bi@ :> shape2 :> shape1
    ! Check that the matrices can be multiplied
    shape1 last shape2 [ length 2 - ] keep nth =
    ! Check that the other dimensions are equal
    shape1 2 head* shape2 2 head* = and
    ! If either is false, raise an error
    [ shape1 shape2 shape-mismatch-error ] unless ] ;

! Slice out a row from the array
: row ( arr n i p -- slice )
    ! Compute the starting index
    / truncate dupd *
    ! Compute the ending index
    swap over +
    ! Take a slice
    rot <slice> ;

! much quicker transpose for 2d tensors
TYPED:: 2d-transpose ( tensor: tensor -- tensor': tensor )
    tensor shape>> :> old-shape
    tensor vec>> :> vec
    old-shape first2 :> ( s1 s2 )
    ! loop through new tensor
    old-shape reverse dup product <iota> [
        ! find y*b val in original tensor
        s1 /mod s2 *
        ! find x val in original tensor
        [ s2 /mod ] dip + nip
        ! get that index in original tensor
        vec nth-unsafe
    ] float-array{ } map-as <tensor> ;

! Perform matrix multiplication muliplying an
! mxn matrix with a nxp matrix
TYPED:: 2d-matmul ( vec1: float-array vec2: float-array res: float-array
                    m: fixnum n: fixnum p: fixnum -- )
    ! For each element in the range, we want to compute the dot product of the
    ! corresponding row and column
    ! Transpose vec2 so that we are doing row * row (as opposed to row * col)
    { n p } vec2 <tensor> 2d-transpose vec>> :> vec2

    m [ :> i
        i n * :> in
        i p * :> ip
        vec1 in n make-subseq
        p [ :> j
            dup
            vec2 j n * n make-subseq
            0.0 [ * + ] 2reduce
            ip j + res set-nth-unsafe
        ] each-integer
        drop
    ] each-integer ;

! Perform matrix multiplication muliplying an
! mxn matrix with a nxp matrix
TYPED:: 2d-matmul-mixed ( vec1: float-array vec2: float-array res: float-array
                    m: fixnum n: fixnum p: fixnum start: fixnum -- )
    ! For each element in the range, we want to compute the dot product of the
    ! corresponding row and column
    ! Transpose vec2 so that we are doing row * row (as opposed to row * col)
    { n p } vec2 <tensor> 2d-transpose vec>> :> vec2

    ! Compute the location in the float-array each 2D matrix will start at
    start m n * * :> start1
    start n p * * :> start2

    m [ :> i
        i n * :> in
        4 4 in start1 + 4 mod - swap mod :> in4m
        i p * :> ip
        vec1 in n make-subseq :> sub1
        sub1 in4m <simd-slice> :> slice1
        p [ :> j
            j n * :> jn
            4 4 jn 4 mod - swap mod :> jn4m
            vec2 jn n make-subseq
            in4m jn4m = [
                jn4m <simd-slice> slice1 swap
                2dup [ first-slice>> ] bi@ 0.0 [ * + ] 2reduce
                [ 2dup [ simd-slice>> ] bi@ ] dip [ v. + ] 2reduce
                [ [ end-slice>> ] bi@ ] dip [ * + ] 2reduce
            ] [
                sub1 swap
                0.0 [ * + ] 2reduce
            ] if
            ip j + res set-nth-unsafe
        ] each-integer
    ] each-integer ;

! ! Perform matrix multiplication muliplying an
! mxn matrix with a nxp matrix
! Should only be called when n is a multiple of 4
TYPED:: 2d-matmul-simd ( vec1: float-array vec2: float-array
                             res: float-array
                             m: fixnum n: fixnum p: fixnum -- )
    ! For each element in the range, we want to compute the dot product of the
    ! corresponding row and column
    ! Transpose vec2 so that we are doing row * row (as opposed to row * col)
    { n p } vec2 <tensor> 2d-transpose vec>> :> vec2

    m [ :> i
        i n * :> in
        i p * :> ip
        vec1 in n make-subseq float-4 cast-array
        p [ :> j
            dup
            vec2 j n * n make-subseq float-4 cast-array
            0.0 [ v. + ] 2reduce
            ip j + res set-nth-unsafe
        ] each-integer
        drop
    ] each-integer ;

PRIVATE>


! Perform matrix multiplication muliplying an
! ...xmxn matrix with a ...xnxp matrix
TYPED:: matmul ( tensor1: tensor tensor2: tensor -- tensor3: tensor )
    ! First check the shape
    tensor1 tensor2 check-matmul-shape

    ! Now save all of the sizes
    tensor1 shape>> unclip-last-slice :> n
    unclip-last-slice :> m :> top-shape
    tensor2 shape>> last :> p
    top-shape product :> top-prod

    ! Create the shape of the resulting tensor
    top-shape { m p } append

    ! Now create the new float array to store the underlying result
    dup product (float-array) :> vec3

    ! Now update the tensor3 to contain the multiplied matricies
    top-prod [
        :> i

        ! Compute vec1 using direct C arrays
        tensor1 vec>> m n * i * m n * make-subseq

        ! Compute vec2 and start2
        tensor2 vec>> n p * i * n p * make-subseq

        ! Compute the result
        vec3 m p * i * m p * make-subseq
        ! Push m, n, and p and multiply the arrays
        m n p
        { { [ n 4 mod 0 = ] [ 2d-matmul-simd ] }
          { [ n 4 < ] [ 2d-matmul ] }
          [ i 2d-matmul-mixed ]
        } cond

    ] each-integer
    vec3 <tensor> ;

<PRIVATE
! helper for transpose: turns a shape into a list of things
! by which to multiply indices to get a full index
: ind-mults ( shape -- seq )
    <reversed> 1 swap [ swap [ * ] keep ] map nip ;

PRIVATE>

! Transpose an n-dimensional tensor by flipping the axes
TYPED:: transpose ( tensor: tensor -- tensor': tensor )
    tensor shape>> length 2 =
    [ tensor 2d-transpose ]
    [ tensor shape>> :> old-shape
        tensor vec>> :> vec
        old-shape reverse :> new-shape
        old-shape ind-mults reverse :> mults
        ! loop through new tensor
        new-shape dup product <iota> [
            ! find index in original tensor
            old-shape mults [ [ /mod ] dip * ] 2map-sum nip
            ! get that index in original tensor
            vec nth-unsafe
        ] float-array{ } map-as <tensor>
    ] if ;
