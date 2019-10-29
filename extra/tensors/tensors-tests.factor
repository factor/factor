! Copyright (C) 2019 HMC Clinic.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types kernel math math.order math.vectors
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
