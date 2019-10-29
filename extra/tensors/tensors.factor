! Copyright (C) 2019 HMC Clinic.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data arrays
concurrency.combinators grouping kernel locals math.functions
math.ranges math.statistics math multi-methods quotations sequences 
sequences.private specialized-arrays tensors.tensor-slice typed ;
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
    <range> [ length 1array ] keep >float-array <tensor> ;

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
METHOD: t+ { tensor number } [ + ] curry t-uop ;
METHOD: t+ { number tensor } swap [ + ] curry t-uop ;

! Subtraction between two tensors or a tensor and a scalar
multi-methods:GENERIC: t- ( x y -- tensor )
METHOD: t- { tensor tensor } [ - ] t-bop ;
METHOD: t- { tensor number } [ - ] curry t-uop ;
METHOD: t- { number tensor } swap [ swap - ] curry t-uop ;

! Multiply a tensor with either another tensor or a scalar
multi-methods:GENERIC: t* ( x y -- tensor )
METHOD: t* { tensor tensor } [ * ] t-bop ;
METHOD: t* { tensor number } [ * ] curry t-uop ;
METHOD: t* { number tensor } swap [ * ] curry t-uop ;

! Divide two tensors or a tensor and a scalar
multi-methods:GENERIC: t/ ( x y -- tensor )
METHOD: t/ { tensor tensor } [ / ] t-bop ;
METHOD: t/ { tensor number } [ / ] curry t-uop ;
METHOD: t/ { number tensor } swap [ swap / ] curry t-uop ;

! Divide two tensors or a tensor and a scalar
multi-methods:GENERIC: t% ( x y -- tensor )
METHOD: t% { tensor tensor } [ mod ] t-bop ;
METHOD: t% { tensor number } [ mod ] curry t-uop ;
METHOD: t% { number tensor } swap [ swap mod ] curry t-uop ;

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
TYPED:: 2d-matmul ( vec1: slice vec2: slice res: slice n: number p: number -- )
    ! For each element in the range, we want to compute the dot product of the
    ! corresponding row and column
    res
    [   >fixnum
        ! Get the row
        [ [ vec1 n ] dip p row ]
        ! Get the column
        ! [ p mod vec2 swap p every ] bi
        [ p mod f p vec2 <step-slice> ] bi
        ! Take the dot product
        [ * ] [ + ] 2map-reduce
    ]
    map! drop ;

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
    top-shape product :> rest

    ! Now create the new tensor with { 0 ... m*p-1 } repeating
    top-shape { m p } append naturals m p * t% :> tensor3

    ! Now update the tensor3 to contain the multiplied matricies
    rest [0,b)
    [
        :> i
        ! First make vec1
        m n * i * dup m n * + tensor1 vec>> <slice>
        ! Now make vec2
        n p * i * dup n p * + tensor2 vec>> <slice>
        ! Now make the resulting vector
        m p * i * dup m p * + tensor3 vec>> <slice>
        ! Push n and p and multiply the clices
        n p 2d-matmul
        0
    ] map drop
    tensor3 ;

<PRIVATE
! helper for transpose: gets the turns a shape into a list of things
! by which to multiply indices to get a full index
: ind-mults ( shape -- seq )
    rest-slice <reversed> cum-product { 1 } prepend ;

! helper for transpose: given shape, flat index, & mults for the shape, gives nd index
:: trans-index ( ind shape mults -- seq )
    ! what we use to divide things
    shape reverse :> S
    ! accumulator
    V{ } clone
    ! loop thru elements & indices of S (mod by elment m)
    S [| m i |
        ! we divide by the product of the 1st n elements of S
        S i head-slice product :> div
        ! do not mod on the last index
        i S length 1 - = not :> mod?
        ! multiply accumulator by mults & sum
        dup mults [ * ] 2map sum
        ! subtract from ind & divide
        ind swap - div /
        ! mod if necessary
        mod? [ m mod ] [ ] if
        ! append to accumulator
        [ dup ] dip swap push
    ] each-index
    reverse ;
PRIVATE>

! Transpose an n-dimensional tensor
TYPED:: transpose ( tensor: tensor -- tensor': tensor )
    ! new shape
    tensor shape>> reverse :> newshape
    ! what we multiply by to get indices in the old tensor
    tensor shape>> ind-mults :> old-mults
    ! what we multiply to get indices in new tensor
    newshape ind-mults :> mults
    ! new tensor of correct shape
    newshape naturals dup vec>>
    [ ! go thru each index
        ! find index in original tensor
        newshape mults trans-index old-mults [ * ] 2map sum >fixnum
        ! get that index in original tensor
        tensor vec>> nth
    ] map! >>vec ;
