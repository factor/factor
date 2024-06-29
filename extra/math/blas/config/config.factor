USING: alien.fortran combinators kernel math.order namespaces
system system-info ;
IN: math.blas.config

SYMBOLS: blas-library blas-fortran-abi deploy-blas? ;

blas-library [
    {
        { [ os macos?  ] [ "libblas.dylib" ] }
        { [ os windows? ] [ "blas.dll"      ] }
        [ "libblas.so" ]
    } cond
] initialize

blas-fortran-abi [
    {
        { [ os macos? cpu x86.32? and ] [ intel-unix-abi ] }
        { [ os macos? cpu x86.64? and ]
            [
                os-version {
                    { [ dup { 10 7 } after=? ] [ f2c-abi ] }
                    { [ dup { 10 6 } after=? ] [ "The libblas.dylib included in macOS 10.6 is incompatible with Factor. To use the math.blas bindings y
ou will need to install a third-party BLAS library and configure Factor. See `\"math.blas.config\" about` for more information." <bad-fortran-abi> ] }
                    [ intel-unix-abi ]
                } cond nip
            ]
        }
        { [ os windows? cpu x86.32? and ] [ f2c-abi        ] }
        { [ os windows? cpu x86.64? and ] [ gfortran-abi   ] }
        ! { [ os freebsd?                 ] [ gfortran-abi   ] }
        { [ os linux?                   ] [ gfortran-abi   ] }
        [ f2c-abi ]
    } cond
] initialize

deploy-blas? [ os macos? not ] initialize
