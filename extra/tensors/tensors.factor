! Copyright (C) 2019 HMC Clinic.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors alien.data arrays grouping kernel locals math
math.functions math.ranges multi-methods sequences
sequences.extras sequences.private specialized-arrays typed ;

QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAY: c:float
IN: tensors

! Tensor class definition
TUPLE: tensor
    { shape array }
    { vec float-array } ;

! Errors
ERROR: non-positive-shape-error shape ;
ERROR: shape-mismatch-error shape1 shape2 ;

<PRIVATE

! Check that the shape has only positive values
: check-shape ( shape -- shape )
    dup [ 1 < ] map-find drop [ non-positive-shape-error ] when ;

! Construct a tensor of zeros
: <tensor> ( shape seq -- tensor )
    tensor boa ;

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

! Construct a tensors with vec { 0 1 2 ... } and reshape to the desired shape
: naturals ( shape -- tensor )
    check-shape [ ] [ product [0,b) >float-array ] bi <tensor> ;

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

: check-bop-shape ( shape1 shape2 -- shape )
    2dup = [ shape-mismatch-error ] unless drop ;

! Apply the binary operator bop to combine the tensors
TYPED:: t-bop ( tensor1: tensor tensor2: tensor quot: ( x y -- z ) -- tensor: tensor )
    tensor1 shape>> tensor2 shape>> check-bop-shape
    tensor1 vec>> tensor2 vec>> quot 2map <tensor> ; inline

! Apply the operation to the tensor
TYPED:: t-uop ( tensor: tensor quot: ( x -- y ) -- tensor: tensor )
    tensor vec>> quot map [ tensor shape>> ] dip <tensor> ; inline

PRIVATE>

! Add a tensor to either another tensor or a scalar
multi-methods:GENERIC: t+ ( x y -- tensor )
METHOD: t+ { tensor tensor } [ + ] t-bop ;
METHOD: t+ { tensor number } >float [ + ] curry t-uop ;
METHOD: t+ { number tensor } [ >float ] dip [ + ] with t-uop ;

! Subtraction between two tensors or a tensor and a scalar
multi-methods:GENERIC: t- ( x y -- tensor )
METHOD: t- { tensor tensor } [ - ] t-bop ;
METHOD: t- { tensor number } >float [ - ] curry t-uop ;
METHOD: t- { number tensor } [ >float ] dip [ - ] with t-uop ;

! Multiply a tensor with either another tensor or a scalar
multi-methods:GENERIC: t* ( x y -- tensor )
METHOD: t* { tensor tensor } [ * ] t-bop ;
METHOD: t* { tensor number } >float [ * ] curry t-uop ;
METHOD: t* { number tensor } [ >float ] dip [ * ] with t-uop ;

! Divide two tensors or a tensor and a scalar
multi-methods:GENERIC: t/ ( x y -- tensor )
METHOD: t/ { tensor tensor } [ / ] t-bop ;
METHOD: t/ { tensor number } >float [ / ] curry t-uop ;
METHOD: t/ { number tensor } [ >float ] dip [ / ] with t-uop ;

! Divide two tensors or a tensor and a scalar
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

! Perform matrix multiplication muliplying an
! mxn matrix with a nxp matrix
TYPED:: 2d-matmul ( vec1: float-array start1: fixnum
                    vec2: float-array start2: fixnum
                    res: float-array start3: fixnum
                    m: fixnum n: fixnum p: fixnum -- )
    ! For each element in the range, we want to compute the dot product of the
    ! corresponding row and column
    m [ :> i
        p [ :> j
            0.0 ! This is the sum
            n [ :> k
                ! Add to the sum
                i n * k + start1 + vec1 nth-unsafe
                k p * j + start2 + vec2 nth-unsafe
                * +
            ] each-integer
            i p * j + start3 + res set-nth-unsafe
        ] each-integer
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
    dup product c:float (c-array) :> vec3

    ! Now update the tensor3 to contain the multiplied matricies
    top-prod [
        :> i
        ! Compute vec1 and start1
        tensor1 vec>> m n * i *
        ! Compute vec2 and start2
        tensor2 vec>> n p * i *
        ! Compute the result
        vec3 m p * i *
        ! Push m, n, and p and multiply the arrays
        m n p 2d-matmul
    ] each-integer
    vec3 <tensor> ;


<PRIVATE
! helper for transpose: turns a shape into a list of things
! by which to multiply indices to get a full index
: ind-mults ( shape -- seq )
    <reversed> 1 swap [ swap [ * ] keep ] map nip ;

! helper for transpose: given shape, flat index, & mults for
! the shape, gives nd index
: transpose-index ( i shape -- seq )
    <reversed> [ /mod ] map reverse nip ;
PRIVATE>

! Transpose an n-dimensional tensor by flipping the axes
TYPED:: transpose ( tensor: tensor -- tensor': tensor )
    tensor shape>> :> old-shape
    tensor vec>> :> vec
    old-shape reverse :> new-shape
    ! check that the size is fine
    new-shape product vec length assert=
    old-shape ind-mults reverse :> mults
    ! loop through new tensor
    new-shape dup product <iota> [
        ! find index in original tensor
        old-shape mults [ [ /mod ] dip * ] 2map-sum nip
        ! get that index in original tensor
        vec nth-unsafe
    ] float-array{ } map-as <tensor> ;
