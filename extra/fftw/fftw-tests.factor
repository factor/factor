USING: tools.test ;
IN: fftw

{
    { C{ 1.5 0.0 } C{ -0.5 0.0 } }
} [
    { 0.5 1.0 } fft1d
] unit-test
