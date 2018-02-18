USING: math.transforms.fft math.vectors tools.test ;

! even lengths

{ t } [
    { C{ 10 0 } C{ -2 2 } C{ -2 0 } C{ -2 -2 } }
    { 1 2 3 4 } fft 1e-12 v~
] unit-test

{ t } [
    { C{ 2+1/2 0 } C{ -1/2 -1/2 } C{ -1/2 0 } C{ -1/2 1/2 } }
    { 1 2 3 4 } ifft 1e-12 v~
] unit-test

! odd lengths

{ t } [
    { C{ 5 0 } C{ -1 0 } C{ -1 0 } }
    { 1 2 2 } fft 1e-12 v~
] unit-test

{ t } [
    { C{ 1+2/3 0 } C{ -1/3 0 } C{ -1/3 0 } }
    { 1 2 2 } ifft 1e-12 v~
] unit-test

{ t } [
    { C{ 0.05 0.0 } C{ 0.05 0.0 } C{ 0.05 0.0 } C{ 0.05 0.0 } }
    { 0.1 0.1 0.1 0.1 } { 0.2 0.1 0.1 0.1 } correlate 1e-12 v~
] unit-test
