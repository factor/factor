USING: alien.fortran combinators kernel math namespaces
sequences system system-info ;
IN: math.blas.config

SYMBOLS: blas-library blas-fortran-abi deploy-blas? ;

blas-library [
    {
        { [ os macosx?  ] [ "libblas.dylib" ] }
        { [ os windows? ] [ "blas.dll"      ] }
        [ "libblas.so" ]
    } cond
] initialize

blas-fortran-abi [
    {
        { [
            os macosx? cpu
            x86.64? and
            os-version second 7 >= and
        ] [ f2c-abi ] }
        { [
            os macosx? cpu
            x86.64? and
            os-version second 6 = and
        ] [ "The libblas.dylib included in Mac OS X 10.6 is incompatible with Factor. To use the math.blas bindings you will need to install a third-party BLAS library and configure Factor. See `\"math.blas.config\" help` for more information." <bad-fortran-abi> ] }
        { [
            os macosx? cpu
            x86.64? and
            os-version second 5 <= and
        ] [ intel-unix-abi ] }
        { [ os macosx? cpu x86.32? and ] [ intel-unix-abi ] }
        { [ os windows? cpu x86.32? and ] [ f2c-abi        ] }
        { [ os windows? cpu x86.64? and ] [ gfortran-abi   ] }
        ! { [ os freebsd?                 ] [ gfortran-abi   ] }
        { [ os linux?                   ] [ gfortran-abi   ] }
        [ f2c-abi ]
    } cond
] initialize

deploy-blas? [ os macosx? not ] initialize
