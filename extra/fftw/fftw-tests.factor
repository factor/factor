USING: fftw tools.test ;

{
    { C{ 1.5 0.0 } C{ -0.5 0.0 } }
} [
    { 0.5 1.0 } fft1d
] unit-test
