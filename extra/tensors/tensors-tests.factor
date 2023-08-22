! Copyright (C) 2019 HMC Clinic.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays kernel math math.order math.vectors
sequences specialized-arrays tensors tools.test ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAY: c:float
IN: tensors.tests

! Test zeros
{ float-array{ 0.0 0.0 0.0 0.0 } } [
    { 4 } zeros vec>>
] unit-test

{ { 4 } } [
    { 4 } zeros shape>>
] unit-test

{ float-array{ 0.0 0.0 0.0 0.0 } } [
    { 2 2 } zeros vec>>
] unit-test

{ { 2 2 } } [
    { 2 2 } zeros shape>>
] unit-test

[
    { 0 5 } zeros
]
[ { 0 5 } \ non-positive-shape-error boa = ] must-fail-with

[
    { -3 5 } zeros
]
[ { -3 5 } \ non-positive-shape-error boa = ] must-fail-with

! Test ones
{ float-array{ 1.0 1.0 1.0 1.0 } } [
    { 4 } ones vec>>
] unit-test

{ { 4 } } [
    { 4 } ones shape>>
] unit-test

{ float-array{ 1.0 1.0 1.0 1.0 } } [
    { 2 2 } ones vec>>
] unit-test

{ { 2 2 } } [
    { 2 2 } ones shape>>
] unit-test

[
    { 0 5 } ones
]
[ { 0 5 } \ non-positive-shape-error boa = ] must-fail-with

[
    { -3 5 } ones
]
[ { -3 5 } \ non-positive-shape-error boa = ] must-fail-with


! Test arange
{ { 4 } float-array{ 0. 1. 2. 3. } } [
    0 3 1 arange [ shape>> ] [ vec>> ] bi
] unit-test

{ { 4 } float-array{ 0. 2. 4. 6. } } [
    0 7 2 arange [ shape>> ] [ vec>> ] bi
] unit-test

{ { 3 } float-array{ 1. 4. 7. } } [
    1 9 3 arange [ shape>> ] [ vec>> ] bi
] unit-test

{ { 5 } float-array{ 1. 3. 5. 7. 9. } } [
    1 9 2 arange [ shape>> ] [ vec>> ] bi
] unit-test


! Test naturals
{ float-array{ 0.0 1.0 2.0 3.0 } } [
    { 4 } naturals vec>>
] unit-test

{ { 4 } } [
    { 4 } naturals shape>>
] unit-test

{ float-array{ 0.0 1.0 2.0 3.0 } } [
    { 2 2 } naturals vec>>
] unit-test

{ { 2 2 } } [
    { 2 2 } naturals shape>>
] unit-test

[
    { 0 5 } naturals
]
[ { 0 5 } \ non-positive-shape-error boa = ] must-fail-with

[
    { -3 5 } naturals
]
[ { -3 5 } \ non-positive-shape-error boa = ] must-fail-with

! Test (tensor)
{ { 2 4 } } [
    { 2 4 } (tensor) shape>>
] unit-test

{ { 0 } } [
    { 0 } (tensor) shape>>
] unit-test

{ float-array{ } } [
    { 0 } (tensor) vec>>
] unit-test


! Test reshape
{ float-array{ 0.0 0.0 0.0 0.0 } } [
    { 4 } zeros { 2 2 } reshape vec>>
] unit-test

{ { 2 2 } } [
    { 4 } zeros { 2 2 } reshape shape>>
] unit-test

[
    { 2 2 } zeros { 2 3 } reshape
]
[ { 2 2 } { 2 3 } \ shape-mismatch-error boa = ] must-fail-with

[
    { 2 2 } zeros { -2 -2 } reshape
]
[ { -2 -2 } \ non-positive-shape-error boa = ] must-fail-with

! Test flatten
{ float-array{ 0.0 0.0 0.0 0.0 } } [
    { 2 2 } zeros flatten vec>>
] unit-test

{ { 4 } } [
    { 2 2 } zeros flatten shape>>
] unit-test

{ float-array{ 0.0 0.0 0.0 0.0 } } [
    { 4 } zeros flatten vec>>
] unit-test

{ { 4 } } [
    { 4 } zeros flatten shape>>
] unit-test

! Test dims
{ 1 } [
    { 3 } zeros dims
] unit-test

{ 2 } [
    { 2 2 } ones dims
] unit-test

{ 3 } [
    { 1 2 3 } zeros dims
] unit-test

! Test sequence operations
! TODO: add tests for clone-like
! test length
{ 20 } [
    { 2 2 5 } naturals length
] unit-test

{ 0 } [
    t{ } length
] unit-test

! test new-sequence
{ 10 } [
    10 { 2 5 } ones new-sequence shape>> product
] unit-test

{ 2 } [
    2 { 3 4 5 } ones new-sequence shape>> product
] unit-test

{ 20 } [
    20 { 2 5 } ones new-sequence shape>> product
] unit-test

! test nth
{ 1.0 } [
    1 { 5 } naturals nth
] unit-test

{ 1.0 } [
    { 1 } { 5 } naturals nth
] unit-test

{ 3.0 } [
    { 1 1 } { 2 2 } naturals nth
] unit-test

{ 5.0 } [
    { 1 0 1 } { 2 2 2 } naturals nth
] unit-test

[
    { 1 2 3 } t{ 1 2 3 } nth
]
[ 1 3 \ dimension-mismatch-error boa = ] must-fail-with

! test set-nth
{ t{ 1 5 3 } } [
    t{ 1 2 3 } dup [ 5 { 1 } ] dip set-nth
] unit-test

{ t{ { 0 1 } { 5 3 } } } [
    { 2 2 } naturals dup [ 5 { 1 0 } ] dip set-nth
] unit-test

{ t{ { { 0 1 } { 2 3 } } { { 4 10 } { 6 7 } } } } [
    { 2 2 2 } naturals dup [ 10 { 1 0 1 } ] dip set-nth
] unit-test

[
    { 2 2 } naturals dup [ 5 { 1 } ] dip set-nth
]
[ 2 1 \ dimension-mismatch-error boa = ] must-fail-with

! test clone
{ t{ 1 2 3 }  } [
    t{ 1 2 3 } dup clone [ 5 1 ] dip set-nth
] unit-test

{ t } [
    t{ 1 2 3 } dup clone =
] unit-test

{ f } [
    t{ 1 2 3 } dup clone dup [ 5 1 ] dip set-nth =
] unit-test

! Test like
{ float-array{ 0.0 1.0 2.0 3.0 4.0 5.0 } } [
    { 2 3 } naturals dup like vec>>
] unit-test

{ { 2 3 } } [
    { 2 3 } naturals dup like shape>>
] unit-test

{ float-array{ 0.0 1.0 2.0 3.0 4.0 5.0 } } [
    { 0 1 2 3 4 5 } { 2 3 } naturals like vec>>
] unit-test

{ { 2 3 } } [
    { 0 1 2 3 4 5 } { 2 3 } naturals like shape>>
] unit-test

{ float-array{ 0.0 1.0 2.0 3.0 4.0 5.0 } } [
    float-array{ 0 1 2 3 4 5 } { 2 3 } naturals like vec>>
] unit-test

{ { 2 3 } } [
    float-array{ 0 1 2 3 4 5 } { 2 3 } naturals like shape>>
] unit-test

{ float-array{ 0.0 1.0 2.0 3.0 4.0 } } [
    { 0 1 2 3 4 } { 2 3 } naturals like vec>>
] unit-test

{ { 5 } } [
    { 0 1 2 3 4 } { 2 3 } naturals like shape>>
] unit-test

{ float-array{ 0.0 1.0 2.0 3.0 4.0 } } [
    float-array{ 0 1 2 3 4 } { 2 3 } naturals like vec>>
] unit-test

{ { 5 } } [
    float-array{ 0 1 2 3 4 } { 2 3 } naturals like shape>>
] unit-test

{ t{ { 0.0 1.0 } { 2.0 3.0 } } } [
    { { 0 1 } { 2 3 } } t{ } like
] unit-test

! test clone-like
{ float-array{ 1.0 2.0 3.0 } } [
    { 1 2 3 } t{ } clone-like vec>>
] unit-test

{ f } [
    float-array{ 1.0 2.0 3.0 } dup t{ } clone-like
    dup [ 5 1 ] dip set-nth vec>> =
] unit-test

! Test sum
{ 21.0 } [
    t{ 1 2 3 4 5 6 } sum
] unit-test

{ 50005000.0 } [
    { 100 100 } naturals 1 t+ sum
] unit-test

! Test tensor parsing word
{ float-array{ 1 2 3 4 5 6 7 8 } } [
    t{ 1 2 3 4 5 6 7 8 } vec>>
] unit-test

{ { 8 } } [
    t{ 1 2 3 4 5 6 7 8 } shape>>
] unit-test

{ float-array{ 1 2 3 4 5 6 7 8 } } [
    t{ { 1 2 3 4 } { 5 6 7 8 } } vec>>
] unit-test

{ { 2 4 } } [
    t{ { 1 2 3 4 } { 5 6 7 8 } } shape>>
] unit-test

{ float-array{ 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 } } [
    t{ { { 1 2 3 4 } { 5 6 7 8 } { 9 10 11 12 } } { { 13 14 15 16 } { 17 18 19 20 } { 21 22 23 24 } } } vec>>
] unit-test

{ { 2 3 4 } } [
    t{ { { 1 2 3 4 } { 5 6 7 8 } { 9 10 11 12 } } { { 13 14 15 16 } { 17 18 19 20 } { 21 22 23 24 } } } shape>>
] unit-test


! Test addition
{ float-array{ 1.0 2.0 3.0 4.0 } } [
    { 4 } naturals { 4 } ones t+ vec>>
] unit-test

{ { 4 } } [
    { 4 } naturals { 4 } ones t+ shape>>
] unit-test

{ float-array{ 1.0 2.0 3.0 4.0 } } [
    { 2 2 } naturals { 2 2 } ones t+ vec>>
] unit-test

{ { 2 2 } } [
    { 2 2 } naturals { 2 2 } ones t+ shape>>
] unit-test

[
    { 3 } naturals { 2 2 } ones t+ vec>>
]
[ { 3 } { 2 2 } \ shape-mismatch-error boa = ] must-fail-with

[
    { 4 } naturals { 2 2 } ones t+ vec>>
]
[ { 4 } { 2 2 } \ shape-mismatch-error boa = ] must-fail-with

! Test scalar addition
{ float-array{ 1.0 2.0 3.0 4.0 } } [
    { 4 } naturals 1 t+ vec>>
] unit-test

{ { 4 } } [
    { 4 } naturals 1 t+ shape>>
] unit-test

{ float-array{ 1.0 2.0 3.0 4.0 } } [
    1 { 4 } naturals t+ vec>>
] unit-test

{ { 4 } } [
    1 { 4 } naturals t+ shape>>
] unit-test

! Test subtraction
{ float-array{ -1.0 0.0 1.0 2.0 } } [
    { 4 } naturals { 4 } ones t- vec>>
] unit-test

{ { 4 } } [
    { 4 } naturals { 4 } ones t- shape>>
] unit-test

{ float-array{ -1.0 0.0 1.0 2.0 } } [
    { 2 2 } naturals { 2 2 } ones t- vec>>
] unit-test

{ { 2 2 } } [
    { 2 2 } naturals { 2 2 } ones t- shape>>
] unit-test

[
    { 3 } naturals { 2 2 } ones t- vec>>
]
[ { 3 } { 2 2 } \ shape-mismatch-error boa = ] must-fail-with

[
    { 4 } naturals { 2 2 } ones t- vec>>
]
[ { 4 } { 2 2 } \ shape-mismatch-error boa = ] must-fail-with

! Test scalar subtraction
{ float-array{ -1.0 0.0 1.0 2.0 } } [
    { 4 } naturals 1 t- vec>>
] unit-test

{ { 4 } } [
    { 4 } naturals 1 t- shape>>
] unit-test

{ float-array{ 1.0 0.0 -1.0 -2.0 } } [
    1 { 4 } naturals t- vec>>
] unit-test

{ { 4 } } [
    1 { 4 } naturals t- shape>>
] unit-test

! Test multiplication
{ float-array{ 0.0 1.0 4.0 9.0 } } [
    { 4 } naturals { 4 } naturals t* vec>>
] unit-test

{ { 4 } } [
    { 4 } naturals { 4 } naturals t* shape>>
] unit-test

{ float-array{ 0.0 1.0 4.0 9.0 } } [
    { 2 2 } naturals { 2 2 } naturals t* vec>>
] unit-test

{ { 2 2 } } [
    { 2 2 } naturals { 2 2 } naturals t* shape>>
] unit-test

[
    { 3 } naturals { 2 2 } naturals t* vec>>
]
[ { 3 } { 2 2 } \ shape-mismatch-error boa = ] must-fail-with

[
    { 4 } naturals { 2 2 } naturals t* vec>>
]
[ { 4 } { 2 2 } \ shape-mismatch-error boa = ] must-fail-with

! Test division
{ t } [
    { 4 } ones
    { 4 } naturals { 4 } ones t+
    t/ vec>>
    { 1.0 0.5 0.33333 0.25 } v-
    [ abs ] map
    0 [ max ] reduce 0.0001 <
] unit-test

{ { 4 } } [
    { 4 } ones
    { 4 } naturals { 4 } ones t+
    t/ shape>>
] unit-test

{ t } [
    { 2 2 } ones
    { 2 2 } naturals { 2 2 } ones t+
    t/ vec>>
    { 1.0 0.5 0.33333 0.25 } v-
    [ abs ] map
    0 [ max ] reduce 0.0001 <
] unit-test

{ { 2 2 } } [
    { 2 2 } ones
    { 2 2 } naturals { 2 2 } ones t+
    t/ shape>>
] unit-test

[
    { 3 } ones
    { 2 2 } naturals { 2 2 } ones t+
    t/ vec>>
]
[ { 3 } { 2 2 } \ shape-mismatch-error boa = ] must-fail-with

[
    { 4 } ones
    { 2 2 } naturals { 2 2 } ones t+
    t/ vec>>
]
[ { 4 } { 2 2 } \ shape-mismatch-error boa = ] must-fail-with

! Test scalar division
{ t } [
    1
    { 4 } naturals { 4 } ones t+
    t/ vec>>
    { 1.0 0.5 0.33333 0.25 } v-
    [ abs ] map
    0 [ max ] reduce 0.0001 <
] unit-test

{ { 4 } } [
    1
    { 4 } naturals { 4 } ones t+
    t/ shape>>
] unit-test

{ float-array{ 0.0 0.5 1.0 1.5 } } [
    { 4 } naturals 2 t/ vec>>
] unit-test

{ { 4 } } [
    { 4 } naturals 2 t/ shape>>
] unit-test

! Test scalar multiplication
{ float-array{ 0.0 3.0 6.0 9.0 } } [
    { 4 } naturals 3 t* vec>>
] unit-test

{ { 4 } } [
    { 4 } naturals 3 t* shape>>
] unit-test

{ float-array{ 0.0 3.0 6.0 9.0 } } [
    { 2 2 } naturals 3 t* vec>>
] unit-test

{ { 2 2 } } [
    { 2 2 } naturals 3 t* shape>>
] unit-test

{ float-array{ 0.0 3.0 6.0 9.0 } } [
    3 { 4 } naturals t* vec>>
] unit-test

{ { 4 } } [
    3 { 4 } naturals t* shape>>
] unit-test

{ float-array{ 0.0 3.0 6.0 9.0 } } [
    3 { 2 2 } naturals t* vec>>
] unit-test

{ { 2 2 } } [
    3 { 2 2 } naturals t* shape>>
] unit-test

! test mod
{ float-array{ 0.0 1.0 2.0 0.0 1.0 } } [
    { 5 } naturals
    { 5 } ones 3 t*
    t% vec>>
] unit-test

{ { 5 } } [
    { 5 } naturals
    { 5 } ones 3 t*
    t% shape>>
] unit-test

{ float-array{ 0.0 1.0 2.0 0.0 1.0 2.0 } } [
    { 2 3 } naturals
    { 2 3 } ones 3 t*
    t% vec>>
] unit-test

{ { 2 3 } } [
    { 2 3 } naturals
    { 2 3 } ones 3 t*
    t% shape>>
] unit-test

[
    { 4 } naturals
    { 2 3 } ones 3 t*
    t% vec>>
]
[ { 4 } { 2 3 } \ shape-mismatch-error boa = ] must-fail-with

[
    { 4 } naturals
    { 2 3 } ones 3 t*
    t% vec>>
]
[ { 4 } { 2 3 } \ shape-mismatch-error boa = ] must-fail-with

! Test scalar mod
{ float-array{ 0.0 1.0 2.0 0.0 1.0 } } [
    { 5 } naturals
    3
    t% vec>>
] unit-test

{ { 5 } } [
    { 5 } naturals
    3
    t% shape>>
] unit-test

{ float-array{ 0.0 1.0 2.0 0.0 1.0 2.0 } } [
    { 2 3 } naturals
    3
    t% vec>>
] unit-test

{ { 2 3 } } [
    { 2 3 } naturals
    3
    t% shape>>
] unit-test

{ float-array{ 0.0 1.0 0.0 3.0 3.0 } } [
    3
    { 5 } naturals 1 t+
    t% vec>>
] unit-test

{ { 5 } } [
    { 5 } naturals
    3
    t% shape>>
] unit-test

{ float-array{ 0.0 1.0 0.0 3.0 3.0 3.0 } } [
    3
    { 2 3 } naturals 1 t+
    t% vec>>
] unit-test

{ { 2 3 } } [
    { 2 3 } naturals
    3
    t% shape>>
] unit-test

! t-concat
{ t{ { 0.0 1.0 2.0 } { 3.0 4.0 5.0 } { 0.0 1.0 2.0 } { 3.0 4.0 5.0 } } } [
    { 2 3 } naturals dup 2array t-concat
] unit-test

{ t{ { 0.0 1.0 2.0 } { 3.0 4.0 5.0 } { 0.0 1.0 2.0 } { 3.0 4.0 5.0 }
     { 0.0 1.0 2.0 } { 3.0 4.0 5.0 } } } [
    { 2 3 } naturals dup dup 3array t-concat
] unit-test

{ t{ { 0.0 1.0 2.0 }
     { 3.0 4.0 5.0 }
     { 0.0 1.0 2.0 }
     { 3.0 4.0 5.0 }
     { 6.0 7.0 8.0 }
     { 9.0 10.0 11.0 }
     { 12.0 13.0 14.0 } } } [
    { 2 3 } naturals { 5 3 } naturals 2array t-concat
] unit-test

{ t{ { { 0.0 1.0 } { 2.0 3.0 } { 4.0 5.0 } }
     { { 6.0 7.0 } { 8.0 9.0 } { 10.0 11.0 } }
     { { 0.0 1.0 } { 2.0 3.0 } { 4.0 5.0 } }
     { { 6.0 7.0 } { 8.0 9.0 } { 10.0 11.0 } } } } [
     { 2 3 2 } naturals dup 2array t-concat
] unit-test

{ t{ { { 0.0 1.0 } { 2.0 3.0 } { 4.0 5.0 } }
     { { 6.0 7.0 } { 8.0 9.0 } { 10.0 11.0 } }
     { { 0.0 1.0 } { 2.0 3.0 } { 4.0 5.0 } }
     { { 6.0 7.0 } { 8.0 9.0 } { 10.0 11.0 } }
     { { 0.0 1.0 } { 2.0 3.0 } { 4.0 5.0 } }
     { { 6.0 7.0 } { 8.0 9.0 } { 10.0 11.0 } } } } [
     { 2 3 2 } naturals dup dup 3array t-concat
] unit-test

[
    { 2 2 } naturals { 2 3 } naturals 2array t-concat
]
[ { 2 2 } { 2 3 } \ shape-mismatch-error boa = ] must-fail-with

[
    { 2 2 } naturals dup { 2 3 } naturals 3array t-concat
]
[ { 2 2 } { 2 3 } \ shape-mismatch-error boa = ] must-fail-with

! stack
{ t{ { { 0.0 1.0 2.0 } { 3.0 4.0 5.0 } }
     { { 0.0 1.0 2.0 } { 3.0 4.0 5.0 } } } } [
    { 2 3 } naturals dup 2array stack
] unit-test

{ t{ { { 0.0 1.0 2.0 } { 3.0 4.0 5.0 } }
     { { 0.0 1.0 2.0 } { 3.0 4.0 5.0 } }
     { { 0.0 1.0 2.0 } { 3.0 4.0 5.0 } } } } [
    { 2 3 } naturals dup dup 3array stack
] unit-test

{ t{ { { { 0.0 1.0 } { 2.0 3.0 } { 4.0 5.0 } }
       { { 6.0 7.0 } { 8.0 9.0 } { 10.0 11.0 } } }
     { { { 0.0 1.0 } { 2.0 3.0 } { 4.0 5.0 } }
       { { 6.0 7.0 } { 8.0 9.0 } { 10.0 11.0 } } } } } [
     { 2 3 2 } naturals dup 2array stack
] unit-test

{ t{ { { { 0.0 1.0 } { 2.0 3.0 } { 4.0 5.0 } }
       { { 6.0 7.0 } { 8.0 9.0 } { 10.0 11.0 } } }
     { { { 0.0 1.0 } { 2.0 3.0 } { 4.0 5.0 } }
       { { 6.0 7.0 } { 8.0 9.0 } { 10.0 11.0 } } }
     { { { 0.0 1.0 } { 2.0 3.0 } { 4.0 5.0 } }
       { { 6.0 7.0 } { 8.0 9.0 } { 10.0 11.0 } } } } } [
     { 2 3 2 } naturals dup dup 3array stack
] unit-test

[
    { 2 2 } naturals { 2 3 } naturals 2array stack
]
[ { 2 2 } { 2 3 } \ shape-mismatch-error boa = ] must-fail-with

[
    { 2 2 } naturals { 3 2 } naturals 2array stack
]
[ { 2 2 } { 3 2 } \ shape-mismatch-error boa = ] must-fail-with

[
    { 2 2 } naturals dup { 2 3 } naturals 3array stack
]
[ { 2 2 } { 2 3 } \ shape-mismatch-error boa = ] must-fail-with

[
    { 2 2 } naturals dup { 3 2 } naturals 3array stack
]
[ { 2 2 } { 3 2 } \ shape-mismatch-error boa = ] must-fail-with

! hstack

{ t{ { 0.0 1.0 2.0 3.0 1.0 }
     { 4.0 5.0 6.0 7.0 1.0 }
     { 8.0 9.0 10.0 11.0 1.0 } } } [
    { 3 4 } naturals { 3 1 } ones 2array hstack
] unit-test

{ t{ { 0.0 1.0 2.0 3.0 1.0 0.0 0.0 }
     { 4.0 5.0 6.0 7.0 1.0 0.0 0.0 }
     { 8.0 9.0 10.0 11.0 1.0 0.0 0.0 } } } [
    { 3 4 } naturals { 3 1 } ones { 3 2 } zeros 3array hstack
] unit-test

{ t{ { { 0.0 1.0 2.0 3.0 1.0 } { 4.0 5.0 6.0 7.0 1.0 } }
     { { 8.0 9.0 10.0 11.0 1.0 } { 12.0 13.0 14.0 15.0 1.0 } } } } [
     { 2 2 4 } naturals { 2 2 1 } ones 2array hstack
] unit-test

{ t{ { { 0.0 1.0 2.0 3.0 1.0 0.0 0.0 }
       { 4.0 5.0 6.0 7.0 1.0 0.0 0.0 } }
     { { 8.0 9.0 10.0 11.0 1.0 0.0 0.0 }
       { 12.0 13.0 14.0 15.0 1.0 0.0 0.0 } } } } [
     { 2 2 4 } naturals { 2 2 1 } ones { 2 2 2 } zeros 3array hstack
] unit-test

[
    { 2 2 } naturals { 3 2 } naturals 2array hstack
]
[ { 2 2 } { 3 2 } \ shape-mismatch-error boa = ] must-fail-with

[
    { 2 2 } naturals dup { 3 2 } naturals 3array hstack
]
[ { 2 2 } { 3 2 } \ shape-mismatch-error boa = ] must-fail-with

[
    { 2 2 2 } naturals { 3 2 2 } naturals 2array hstack
]
[ { 2 2 2 } { 3 2 2 } \ shape-mismatch-error boa = ] must-fail-with

[
    { 2 2 2 } naturals dup { 3 2 2 } naturals 3array hstack
]
[ { 2 2 2 } { 3 2 2 } \ shape-mismatch-error boa = ] must-fail-with

! vstack
{ t{ { 0.0 1.0 } { 2.0 3.0 } { 4.0 5.0 } { 0.0 1.0 } } } [
    { 3 2 } naturals { 1 2 } naturals 2array vstack
] unit-test

{ t{ { 0.0 1.0 } { 2.0 3.0 } { 4.0 5.0 }
     { 0.0 1.0 } { 0.0 1.0 } { 2.0 3.0 } } } [
    { 3 2 } naturals { 1 2 } naturals { 2 2 } naturals 3array vstack
] unit-test

{ t{ { { 0.0 1.0 } { 2.0 3.0 } { 4.0 5.0 } { 0.0 1.0 } }
     { { 6.0 7.0 } { 8.0 9.0 } { 10.0 11.0 } { 2.0 3.0 } } } } [
    { 2 3 2 } naturals { 2 1 2 } naturals 2array vstack
] unit-test

{ t{ { { 0.0 1.0 } { 2.0 3.0 } { 4.0 5.0 }
       { 0.0 1.0 } { 0.0 1.0 } { 2.0 3.0 } }
     { { 6.0 7.0 } { 8.0 9.0 } { 10.0 11.0 }
       { 2.0 3.0 } { 4.0 5.0 } { 6.0 7.0 } } } } [
    { 2 3 2 } naturals { 2 1 2 } naturals { 2 2 2 } naturals 3array vstack
] unit-test

[
    { 2 2 } naturals { 2 3 } naturals 2array vstack
]
[ { 2 2 } { 2 3 } \ shape-mismatch-error boa = ] must-fail-with

[
    { 2 2 } naturals dup { 2 3 } naturals 3array vstack
]
[ { 2 2 } { 2 3 } \ shape-mismatch-error boa = ] must-fail-with

[
    { 2 2 2 } naturals { 3 2 2 } naturals 2array vstack
]
[ { 2 2 2 } { 3 2 2 } \ shape-mismatch-error boa = ] must-fail-with

[
    { 2 2 2 } naturals dup { 3 2 2 } naturals 3array vstack
]
[ { 2 2 2 } { 3 2 2 } \ shape-mismatch-error boa = ] must-fail-with

! test tensor>array
{ { 0.0 0.0 } } [
    { 2 } zeros tensor>array
] unit-test

{ { { 0.0 0.0 } { 0.0 0.0 } } } [
    { 2 2 } zeros tensor>array
] unit-test

{ { { { 1.0 1.0 } { 1.0 1.0 } { 1.0 1.0 } }
    { { 1.0 1.0 } { 1.0 1.0 } { 1.0 1.0 } } } } [
    { 2 3 2 } ones tensor>array
] unit-test

! test >tensor
{ t } [
    { 2 3 4 } naturals dup tensor>array >tensor =
] unit-test

{ t } [
    { { { 1.0 2.0 } { 3.0 4.0 } }
      { { 5.0 6.0 } { 7.0 8.0 } }
      { { 9.0 10.0 } { 11.0 12.0 } } }
    dup >tensor tensor>array =
] unit-test

{ t } [
    { 2 3 } naturals
    { { 0 1 2 } { 3 4 5 } } >tensor =
] unit-test

[
    { { 1 2 } { 3 } } >tensor
]
[ { { 1 2 } { 3 } } \ non-uniform-seq-error boa = ] must-fail-with

{ float-array{ } } [
    t{ } vec>>
] unit-test

{ { 0 } } [
    t{ } shape>>
] unit-test

! test matmul
{ float-array{ 70.0 76.0 82.0 88.0 94.0 190.0 212.0 234.0
               256.0 278.0 310.0 348.0 386.0 424.0 462.0 } } [
    { 3 4 } naturals { 4 5 } naturals matmul vec>>
] unit-test

{ { 3 5 } } [
    { 3 4 } naturals { 4 5 } naturals matmul shape>>
] unit-test

{ float-array{ 70.0 76.0 82.0 88.0 94.0 190.0 212.0 234.0 256.0
               278.0 310.0 348.0 386.0 424.0 462.0 1510.0 1564.0
               1618.0 1672.0 1726.0 1950.0 2020.0 2090.0 2160.0
               2230.0 2390.0 2476.0 2562.0 2648.0 2734.0 } } [
    { 2 3 4 } naturals { 2 4 5 } naturals matmul vec>>
] unit-test

{ { 2 3 5 } } [
    { 2 3 4 } naturals { 2 4 5 } naturals matmul shape>>
] unit-test

{ float-array{ 70.0 76.0 82.0 88.0 94.0 190.0 212.0 234.0 256.0
    278.0 310.0 348.0 386.0 424.0 462.0 1510.0 1564.0 1618.0
    1672.0 1726.0 1950.0 2020.0 2090.0 2160.0 2230.0 2390.0 2476.0
    2562.0 2648.0 2734.0 4870.0 4972.0 5074.0 5176.0 5278.0 5630.0
    5748.0 5866.0 5984.0 6102.0 6390.0 6524.0 6658.0 6792.0 6926.0
    10150.0 10300.0 10450.0 10600.0 10750.0 11230.0 11396.0 11562.0
    11728.0 11894.0 12310.0 12492.0 12674.0 12856.0 13038.0 } } [
    { 2 2 3 4 } naturals { 2 2 4 5 } naturals matmul vec>>
] unit-test

{ { 2 2 3 5 } } [
    { 2 2 3 4 } naturals { 2 2 4 5 } naturals matmul shape>>
] unit-test

! where n mod 4 is not 0 and m & p have same mod 4 val
{ float-array{ 45.0 48.0 51.0 54.0 57.0 60.0 63.0 66.0 69.0 126.0
    138.0 150.0 162.0 174.0 186.0 198.0 210.0 222.0 207.0 228.0
    249.0 270.0 291.0 312.0 333.0 354.0 375.0 288.0 318.0 348.0
    378.0 408.0 438.0 468.0 498.0 528.0 369.0 408.0 447.0 486.0
    525.0 564.0 603.0 642.0 681.0 } } [
    { 5 3 } naturals { 3 9 } naturals matmul vec>>
] unit-test

! where n mod 4 is not 0 and m & p have same mod 4 val
{ float-array{ 270.0 280.0 290.0 300.0 310.0 320.0 330.0 340.0 350.0
               720.0 755.0 790.0 825.0 860.0 895.0 930.0 965.0 1000.0
               1170.0 1230.0 1290.0 1350.0 1410.0 1470.0 1530.0 1590.0
               1650.0 1620.0 1705.0 1790.0 1875.0 1960.0 2045.0 2130.0
               2215.0 2300.0 2070.0 2180.0 2290.0 2400.0 2510.0 2620.0
               2730.0 2840.0 2950.0 } } [
    { 5 5 } naturals { 5 9 } naturals matmul vec>>
] unit-test

! where n mod 4 is not 0 and m & p have different mod 4 vals
{ float-array{ 35.0 38.0 41.0 44.0 47.0 50.0 53.0 98.0 110.0
    122.0 134.0 146.0 158.0 170.0 161.0 182.0 203.0 224.0
    245.0 266.0 287.0 224.0 254.0 284.0 314.0 344.0 374.0
    404.0 287.0 326.0 365.0 404.0 443.0 482.0 521.0 } } [
    { 5 3 } naturals { 3 7 } naturals matmul vec>>
] unit-test

{ float-array{ 546.0 567.0 588.0 609.0 630.0 651.0 1428.0 1498.0 1568.0 1638.0
    1708.0 1778.0 2310.0 2429.0 2548.0 2667.0 2786.0 2905.0 3192.0 3360.0
    3528.0 3696.0 3864.0 4032.0 4074.0 4291.0 4508.0 4725.0 4942.0 5159.0
    4956.0 5222.0 5488.0 5754.0 6020.0 6286.0 5838.0 6153.0 6468.0 6783.0
    7098.0 7413.0 22008.0 22372.0 22736.0 23100.0 23464.0 23828.0 24948.0
    25361.0 25774.0 26187.0 26600.0 27013.0 27888.0 28350.0 28812.0 29274.0
    29736.0 30198.0 30828.0 31339.0 31850.0 32361.0 32872.0 33383.0 33768.0
    34328.0 34888.0 35448.0 36008.0 36568.0 36708.0 37317.0 37926.0 38535.0
    39144.0 39753.0 39648.0 40306.0 40964.0 41622.0 42280.0 42938.0 } } [
    { 2 7 7 } naturals { 2 7 6 } naturals matmul vec>>
] unit-test

! test transpose
{ float-array{ 0.0 2.0 1.0 3.0 } } [
    { 2 2 } naturals transpose vec>>
] unit-test

{ float-array{ 0.0 12.0 4.0 16.0 8.0 20.0 1.0
    13.0 5.0 17.0 9.0 21.0 2.0 14.0 6.0 18.0
    10.0 22.0 3.0 15.0 7.0 19.0 11.0 23.0 } } [
    { 2 3 4 } naturals transpose vec>>
] unit-test

{ { 4 3 2 } } [
    { 2 3 4 } naturals transpose shape>>
] unit-test

{ t } [
    { 2 3 4 5 6 } naturals dup transpose transpose =
] unit-test
