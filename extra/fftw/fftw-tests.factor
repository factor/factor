USING: fftw tools.test ;
IN: fftw.tests

{
    { C{ 1.5 0.0 } C{ -0.5 0.0 } }
} [
    { 0.5 1.0 } fft1d
] unit-test
