! Copyright (C) 2012 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays arrays.shaped eval kernel math prettyprint sequences tools.test ;

{ t } [
    { 5 5 } increasing
    {
        { 0 1 2 3 4 }
        { 5 6 7 8 9 }
        { 10 11 12 13 14 }
        { 15 16 17 18 19 }
        { 20 21 22 23 24 }
    } >shaped-array =
] unit-test

{ { 5 5 } } [
    {
        { 0 1 2 3 4 }
        { 5 6 7 8 9 }
        { 10 11 12 13 14 }
        { 15 16 17 18 19 }
        { 20 21 22 23 24 }
    } >shaped-array shape>>
] unit-test

{ { 5 5 } } [
    {
        { 0 1 2 3 4 }
        { 5 6 7 8 9 }
        { 10 11 12 13 14 }
        { 15 16 17 18 19 }
        { 20 21 22 23 24 }
    } >shaped-array shape
] unit-test

{ { } { 1 } } [ { } ones [ shape>> ] [ underlying>> ] bi ] unit-test
{ sa{ 1 } } [ { 1 } ones ] unit-test

{ { } { 0 } } [ { } zeros [ shape>> ] [ underlying>> ] bi ] unit-test
{ sa{ 0 } } [ { 1 } zeros ] unit-test

! Error on 0, negative shapes

{
    sa{ { 1 3 3 } { 4 1 3 } { 4 4 1 } }
} [
    { 3 3 } 2 strict-lower
    [ drop 3 ] map-strict-upper
    [ drop 1 ] map-diagonal
    [ sq ] map-strict-lower
] unit-test


[ 15 <iota> { 3 5 1 } reshape ] must-not-fail

! #2378: dimensions must remain flat at every nesting level.
{ { 3 3 3 } } [ { 3 3 3 } zeros shaped-array>array shape shape>> ] unit-test
{ { 2 3 4 5 } } [ { 2 3 4 5 } zeros shaped-array>array shape shape>> ] unit-test
{ t } [ { 3 3 3 } increasing dup shaped-array>array >shaped-array = ] unit-test
{ t } [ { 2 3 4 5 } increasing dup shaped-array>array >shaped-array = ] unit-test
{ { 2 0 } } [ { { } { } } shape shape>> ] unit-test
{ t } [
    { { { 1 } { 2 3 } } { { 4 } { 5 6 } } } shape abnormal-shape?
] unit-test
[
    { { { 1 } { 2 3 } } { { 4 } { 5 6 } } } >shaped-array
] [ no-abnormally-shaped-arrays? ] must-fail-with

! Follow-up to #2378: dimension queries must also unwrap ordinary array shapes.
{ 3 } [ { { { 1 2 } { 3 4 } } } ndim ] unit-test
{ 4 } [ { 2 3 4 5 } zeros shaped-array>array ndim ] unit-test
{ 4 } [ { 2 3 4 5 } zeros ndim ] unit-test
{ 1 } [ { } ndim ] unit-test

! Rectangular strides and complete coordinate validation.
{ 5 } [ { 1 2 } { 2 3 } increasing get-shaped-row-major ] unit-test
{ 23 } [ { 1 2 3 } { 2 3 4 } increasing get-shaped-row-major ] unit-test
{ 17 } [ { 1 1 1 } { 2 3 4 } increasing get-shaped-row-major ] unit-test
{ 9 } [ { 1 1 1 } { 2 3 4 } increasing get-shaped-column-major ] unit-test
{ 99 } [
    { 2 3 } increasing 99 { 1 2 } pick set-shaped-row-major
    underlying>> last
] unit-test
[ { 1 } { 2 3 } increasing get-shaped-row-major ]
[ shaped-bounds-error? ] must-fail-with
[ { 0 0 0 } { 2 3 } increasing get-shaped-row-major ]
[ shaped-bounds-error? ] must-fail-with
{ 3 } [ { -1 0 } { 2 3 } increasing get-shaped-row-major ] unit-test
[ { -3 0 } { 2 3 } increasing get-shaped-row-major ]
[ shaped-bounds-error? ] must-fail-with
[ { 0.5 0 } { 2 3 } increasing get-shaped-row-major ]
[ shaped-bounds-error? ] must-fail-with
[ { 0 0 } { 2 0 } zeros get-shaped-row-major ]
[ shaped-bounds-error? ] must-fail-with

! Broadcasting aligns trailing axes, including zero-sized axes.
{ t } [ { 2 3 } zeros { 3 } zeros broadcastable? ] unit-test
{ t } [ { 2 1 } zeros { 1 3 } zeros broadcastable? ] unit-test
{ t } [ { 0 3 } zeros { 1 3 } zeros broadcastable? ] unit-test
{ f } [ { 2 3 } zeros { 2 } zeros broadcastable? ] unit-test
{ f } [ { 0 3 } zeros { 2 3 } zeros broadcastable? ] unit-test
{ { 2 3 } } [ { 2 1 } zeros { 3 } zeros output-shape ] unit-test
{ { 0 3 } } [ { 0 3 } zeros { 1 3 } zeros output-shape ] unit-test
[ { 2 3 } zeros { 2 } zeros output-shape ]
[ shape-mismatch? ] must-fail-with

! Empty inner dimensions retain their outer structure.
{ { { } { } } } [ { 2 0 } zeros shaped-array>array ] unit-test
{ { { { } { } { } } { { } { } { } } } }
[ { 2 3 0 } zeros shaped-array>array ] unit-test
{ { { } { } } } [ { 2 0 3 } zeros shaped-array>array ] unit-test
{ { } } [ { 0 3 } zeros shaped-array>array ] unit-test

! Elementwise arithmetic broadcasts trailing axes without mutating inputs.
{ sa{ { 10 21 32 } { 13 24 35 } } } [
    { 2 3 } increasing { 10 20 30 } shaped+
] unit-test
{ sa{ { 11 21 31 } { 12 22 32 } } } [
    { { 1 } { 2 } } { 10 20 30 } shaped+
] unit-test
{ sa{ { -9 -19 -29 } { -8 -18 -28 } } } [
    { { 1 } { 2 } } { 10 20 30 } shaped-
] unit-test
{ sa{ { 10 20 30 } { 20 40 60 } } } [
    { { 1 } { 2 } } { 10 20 30 } shaped*.
] unit-test
{ { 2 3 4 } { 0 1 2 3 1 2 3 4 2 3 4 5 1 2 3 4 2 3 4 5 3 4 5 6 } } [
    { 2 1 1 } increasing { 1 3 1 } increasing shaped+
    { 4 } increasing shaped+ [ shape>> ] [ underlying>> ] bi
] unit-test
{ { 0 3 } { } } [
    { 0 3 } zeros { 1 3 } ones shaped+ [ shape>> ] [ underlying>> ] bi
] unit-test
{ { 2 0 3 } { } } [
    { 2 0 3 } zeros { 3 } ones shaped*. [ shape>> ] [ underlying>> ] bi
] unit-test
[ { 2 3 } zeros { 2 } zeros shaped+ ]
[ shape-mismatch? ] must-fail-with
{ sa{ { 0 1 2 } { 3 4 5 } } } [
    { 2 3 } increasing dup { 3 } ones shaped+
    99 { 0 0 } rot set-shaped-row-major
] unit-test
{ { } { 42 } } [
    { 6 } { } <shaped-array> { 7 } { } <shaped-array> shaped*.
    [ shape>> ] [ underlying>> ] bi
] unit-test
{ sa{ { 6 7 8 } { 9 10 11 } } } [
    { 6 } { } <shaped-array> { 2 3 } increasing shaped+
] unit-test

! Reshape returns a new object and infers exactly one dimension.
{ { 2 3 } { 3 2 } f t } [
    { 2 3 } increasing dup { 3 -1 } reshape
    [ [ shape>> ] bi@ ] [ [ eq? ] [ [ underlying>> ] bi@ eq? ] 2bi ] 2bi
] unit-test
{ { 2 3 } } [ { { 1 2 3 } { 4 5 6 } } { -1 3 } reshape shape>> ] unit-test
{ { 6 } } [ { 2 3 } increasing -1 reshape shape>> ] unit-test
{ { 0 3 } } [ { } { -1 3 } reshape shape>> ] unit-test
[ { } { 0 -1 } reshape ] [ invalid-reshape? ] must-fail-with
[ { 1 2 } { -1 -1 } reshape ] [ invalid-reshape? ] must-fail-with
[ { 1 2 } { -2 } reshape ] [ invalid-reshape? ] must-fail-with
[ { 1 2 } { 3 } reshape ] [ underlying-shape-mismatch? ] must-fail-with
[ { 1 2 } { 3 -1 } reshape ] [ invalid-reshape? ] must-fail-with
[ { 1.5 } zeros ] [ noninteger-shape-components? ] must-fail-with
[ { -1 } <uniform-shape> shape-capacity ]
[ no-negative-shape-components? ] must-fail-with
{ 0 { } { 5 } } [ 5 >shaped-array [ ndim ] [ shape>> ] [ underlying>> ] tri ] unit-test
{ sa{ 11 12 13 } } [ 10 { 1 2 3 } shaped+ ] unit-test
{ sa{ 9 8 7 } } [ 10 { 1 2 3 } shaped- ] unit-test
{ { } { 12 } } [ 3 4 shaped*. [ shape>> ] [ underlying>> ] bi ] unit-test
{ 7 } [ { } 7 >shaped-array get-shaped-row-major ] unit-test
{ 7 } [ { } 7 >shaped-array get-shaped-column-major ] unit-test
{ 9 } [ 7 >shaped-array 9 { } pick set-shaped-row-major underlying>> first ] unit-test

! Views share writes, while reshaping a noncontiguous view copies.
{ { 3 2 } { 0 3 1 4 2 5 } } [
    { 2 3 } increasing shaped-transpose [ shape>> ] [ underlying>> >array ] bi
] unit-test
{ { 4 2 3 } { 0 4 8 12 16 20 1 5 9 13 17 21 2 6 10 14 18 22 3 7 11 15 19 23 } } [
    { 2 3 4 } increasing { -1 0 1 } shaped-permute
    [ shape>> ] [ underlying>> >array ] bi
] unit-test
{ 99 } [
    { 2 3 } increasing dup shaped-transpose
    99 { 2 1 } rot set-shaped-row-major underlying>> last
] unit-test
{ { 3 } { 3 4 5 } } [
    { 2 3 } increasing { -1 } shaped-slice-view
    [ shape>> ] [ underlying>> >array ] bi
] unit-test
{ { 2 3 } { 5 4 3 2 1 0 } } [
    { 2 3 } increasing
    f f -1 <shaped-slice> dup 2array shaped-slice-view
    [ shape>> ] [ underlying>> >array ] bi
] unit-test
{ { 2 } { 1 3 } } [
    { 5 } increasing 1 -1 2 <shaped-slice> 1array shaped-slice-view
    [ shape>> ] [ underlying>> >array ] bi
] unit-test
{ { 0 } { } } [
    { 5 } increasing f -1 -1 <shaped-slice> 1array shaped-slice-view
    [ shape>> ] [ underlying>> >array ] bi
] unit-test
{ 77 } [
    { 2 3 } increasing dup { 1 } shaped-slice-view
    77 { -1 } rot set-shaped-row-major underlying>> last
] unit-test
{ { 1 2 3 4 5 6 } } [
    { 2 3 } increasing dup shaped-transpose [ 1 + ] shaped-map! drop underlying>>
] unit-test
{ { 0 1 2 3 4 5 } { 99 3 1 4 2 5 } } [
    { 2 3 } increasing dup shaped-transpose { -1 } reshape
    99 { 0 } pick set-shaped-row-major [ underlying>> ] bi@
] unit-test
{ { } { 5 } } [
    { 2 3 } increasing { -1 -1 } shaped-slice-view
    [ shape>> ] [ underlying>> >array ] bi
] unit-test
{ { 0 2 } { } } [
    { 2 0 } zeros shaped-transpose [ shape>> ] [ underlying>> >array ] bi
] unit-test
[ { 2 3 } zeros { 0 0 } shaped-permute ]
[ duplicate-shaped-axes? ] must-fail-with
[ { 2 3 } zeros { 1 } shaped-permute ]
[ invalid-shaped-permutation? ] must-fail-with
[ { 3 } zeros f f 0 <shaped-slice> 1array shaped-slice-view ]
[ invalid-shaped-slice? ] must-fail-with
[ { 3 } zeros { 3 } shaped-slice-view ]
[ invalid-shaped-axis? ] must-fail-with

! Axis reductions, including zero-sized axes and scalar outputs.
{ { } { 15 } } [ { 2 3 } increasing f f shaped-sum [ shape>> ] [ underlying>> ] bi ] unit-test
{ { 3 } { 3 5 7 } } [ { 2 3 } increasing 0 f shaped-sum [ shape>> ] [ underlying>> ] bi ] unit-test
{ { 2 1 } { 3 12 } } [ { 2 3 } increasing -1 t shaped-sum [ shape>> ] [ underlying>> ] bi ] unit-test
{ { 1 3 1 } { 60 92 124 } } [
    { 2 3 4 } increasing { 0 -1 } t shaped-sum [ shape>> ] [ underlying>> ] bi
] unit-test
{ { 1.0 4.0 } } [ { 2 3 } increasing 1 f shaped-mean underlying>> ] unit-test
{ { 0 1 2 } } [ { 2 3 } increasing 0 f shaped-min underlying>> ] unit-test
{ { 2 5 } } [ { 2 3 } increasing 1 f shaped-max underlying>> ] unit-test
{ { 2 3 } { 0 1 2 3 4 5 } } [
    { 2 3 } increasing { } f shaped-sum [ shape>> ] [ underlying>> ] bi
] unit-test
{ { 0 0 0 } } [ { 0 3 } zeros 0 f shaped-sum underlying>> ] unit-test
{ t } [ { 0 3 } zeros 0 f shaped-mean underlying>> [ fp-nan? ] all? ] unit-test
{ { 0 } { } } [ { 0 3 } zeros 1 f shaped-min [ shape>> ] [ underlying>> ] bi ] unit-test
{ { } { 7 } } [ 7 f t shaped-sum [ shape>> ] [ underlying>> ] bi ] unit-test
{ t t } [
    { 1 0/0. 3 } f f shaped-min underlying>> first fp-nan?
    { 0/0. 1 3 } f f shaped-max underlying>> first fp-nan?
] unit-test
[ { 0 3 } zeros 0 f shaped-min ] [ empty-shaped-reduction? ] must-fail-with
[ { 0 0 } zeros 0 f shaped-max ] [ empty-shaped-reduction? ] must-fail-with
[ { 2 3 } zeros { 0 -2 } f shaped-sum ] [ duplicate-shaped-axes? ] must-fail-with
[ { 2 3 } zeros 2 f shaped-sum ] [ invalid-shaped-axis? ] must-fail-with

! Matrix multiplication uses NumPy vector promotion and batch broadcasting.
{ { } { 32 } } [ { 1 2 3 } { 4 5 6 } shaped-matmul [ shape>> ] [ underlying>> ] bi ] unit-test
{ { 2 2 } { 10 13 28 40 } } [
    { 2 3 } increasing { 3 2 } increasing shaped-matmul [ shape>> ] [ underlying>> ] bi
] unit-test
{ { 2 } { 8 26 } } [
    { 2 3 } increasing { 1 2 3 } shaped-matmul [ shape>> ] [ underlying>> ] bi
] unit-test
{ { 2 } { 16 22 } } [
    { 1 2 3 } { 3 2 } increasing shaped-matmul [ shape>> ] [ underlying>> ] bi
] unit-test
{ { 2 1 2 } { 10 13 28 40 } } [
    { 2 1 3 } increasing { 3 2 } increasing shaped-matmul [ shape>> ] [ underlying>> ] bi
] unit-test
{ { 2 3 } { 0 0 0 0 0 0 } } [
    { 2 0 } zeros { 0 3 } zeros shaped-matmul [ shape>> ] [ underlying>> ] bi
] unit-test
{ { } { 0 } } [ { } { } shaped-matmul [ shape>> ] [ underlying>> ] bi ] unit-test
{ { 0 2 4 } { } } [
    { 0 2 3 } zeros { 1 3 4 } zeros shaped-matmul [ shape>> ] [ underlying>> ] bi
] unit-test
{ { 3 3 } { 9 12 15 12 17 22 15 22 29 } } [
    { 2 3 } increasing dup shaped-transpose swap shaped-matmul
    [ shape>> ] [ underlying>> ] bi
] unit-test
[ 2 { 1 2 } shaped-matmul ] [ invalid-shaped-matmul? ] must-fail-with
[ { 2 3 } zeros { 2 4 } zeros shaped-matmul ] [ invalid-shaped-matmul? ] must-fail-with
[ { 2 2 3 } zeros { 3 3 2 } zeros shaped-matmul ] [ shape-mismatch? ] must-fail-with

! Metadata ownership and aliasing boundaries.
{ { 2 3 } } [
    { 2 3 } clone dup zeros swap 9 0 rot set-nth shape>>
] unit-test
{ 9 } [
    { 2 3 } zeros dup { 3 2 } reshape
    9 { -1 -1 } rot set-shaped-row-major underlying>> last
] unit-test
{ { 2 3 } } [
    { 2 3 } zeros dup { 3 2 } reshape shape>> 9 0 rot set-nth shape>>
] unit-test
{ 99 } [
    { 2 3 } increasing dup shaped-transpose
    f f -1 <shaped-slice> 1array shaped-slice-view
    99 { 0 0 } rot set-shaped-row-major underlying>> third
] unit-test
{ 1 } [
    { 2 3 } increasing dup shaped-transpose
    99 0 rot set-nth underlying>> second
] unit-test
{ 99 } [
    { 2 3 } increasing dup shaped-transpose
    99 1 rot set-nth underlying>> fourth
] unit-test
[ { 2 3 } zeros shaped-transpose underlying>> -1 swap nth ]
[ bounds-error? ] must-fail-with
[ { 2 3 } zeros shaped-transpose underlying>> 6 swap nth ]
[ bounds-error? ] must-fail-with


! Scalar and empty shapes must survive printing and parsing.
{ { } { 7 } } [
    7 >shaped-array unparse eval( -- shaped ) [ shape>> ] [ underlying>> ] bi
] unit-test
{ { 2 0 3 } { } } [
    { 2 0 3 } zeros unparse eval( -- shaped ) [ shape>> ] [ underlying>> ] bi
] unit-test
{ { 7 } } [
    7 >shaped-array shaped-transpose underlying>> >array
] unit-test
