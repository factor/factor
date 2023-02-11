! Copyright (c) 2014 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.

USING: alien.c-types destructors fftw.ffi kernel math
math.vectors sequences sequences.private specialized-arrays ;
SPECIALIZED-ARRAY: double
SPECIALIZED-ARRAY: fftw_complex

IN: fftw

<PRIVATE

: <fftw-array> ( length -- array )
    [ fftw_complex heap-size * fftw_malloc &fftw_free ] keep
    fftw_complex-array boa ;

: >fftw-array ( seq -- array )
    [ length <fftw-array> ] keep over '[
        [ >rect 0 1 ] [ _ nth ] bi*
        [ set-nth-unsafe ] curry bi-curry@ bi*
    ] each-index ;

: fftw-array> ( array -- seq )
    [ first2 rect> ] { } map-as ;

:: (fft1d) ( seq sign -- seq' )
    seq length :> n
    [
        n
        seq >fftw-array
        n <fftw-array> [
            sign FFTW_ESTIMATE fftw_plan_dft_1d
            [ fftw_execute ] [ fftw_destroy_plan ] bi
        ] keep fftw-array>
    ] with-destructors ;

PRIVATE>

: fft1d ( seq -- seq' ) FFTW_FORWARD (fft1d) ;

: ifft1d ( seq -- seq' )
    [ FFTW_BACKWARD (fft1d) ] [ length v/n ] bi ;

: correlate1d ( x y -- z )
    [ fft1d ] [ reverse fft1d ] bi* v* ifft1d ;
