! Copyright (C) 2012 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel machine-learning.label-encoder
machine-learning.transformer tools.test ;

{ { 1 3 2 4 } } [
    <label-encoder> { 1 2 3 4 3 2 3 2 2 3 2 } over fit-y
    { 1 3 2 4 } over transform-y swap inverse-transform-y
] unit-test
