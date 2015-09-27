! Copyright (c) 2014 John Benediktsson
! See http://factorcode.org/license.txt for BSD license.

USING: alien alien.c-types alien.destructors alien.libraries
alien.libraries.finder alien.syntax combinators kernel system ;

IN: fftw.ffi

LIBRARY: fftw3

<< "fftw3" {
    { [ os windows? ] [ "libfftw3-3.dll" ] }
    { [ os macosx? ] [ "libfftw3.dylib" ] }
    { [ os unix? ] [ "libfftw3.so" ] }
} cond cdecl add-library >>

TYPEDEF: double[2] fftw_complex

TYPEDEF: void* fftw_plan

CONSTANT: FFTW_FORWARD -1
CONSTANT: FFTW_BACKWARD 1

CONSTANT: FFTW_MEASURE 0
CONSTANT: FFTW_DESTROY_INPUT 1
CONSTANT: FFTW_UNALIGNED 2
CONSTANT: FFTW_CONSERVE_MEMORY 4
CONSTANT: FFTW_EXHAUSTIVE 8
CONSTANT: FFTW_PRESERVE_INPUT 16
CONSTANT: FFTW_PATIENT 32
CONSTANT: FFTW_ESTIMATE 64

FUNCTION: void* fftw_malloc ( size_t n )

FUNCTION: fftw_plan fftw_plan_dft_1d ( int n, void* in, void* out, int sign, int flags )

FUNCTION: void fftw_destroy_plan ( fftw_plan p )

FUNCTION: void fftw_execute ( fftw_plan p )

FUNCTION: void fftw_free ( void* p )

DESTRUCTOR: fftw_free
