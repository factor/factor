! Copyright (C) 2012 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel machine-learning.label-binarizer
machine-learning.transformer tools.test ;

{ { { 1 0 0 0 } { 0 0 0 1 } } } [
    <label-binarizer> { 1 2 6 4 2 } over fit-y
    { 1 6 } swap transform-y
] unit-test

{ { 1 6 } } [
    <label-binarizer> { 1 2 6 4 2 } over fit-y
    { 1 6 } over transform-y swap inverse-transform-y
] unit-test
