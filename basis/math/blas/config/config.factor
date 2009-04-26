USING: alien.fortran combinators kernel namespaces system ;
IN: math.blas.config

SYMBOLS: blas-library blas-fortran-abi ;

blas-library [
    {
        { [ os macosx?  ] [ "libblas.dylib" ] }
        { [ os windows? ] [ "blas.dll"      ] }
        [ "libblas.so" ]
    } cond
] initialize

blas-fortran-abi [
    {
        { [ os macosx?                  ] [ intel-unix-abi ] }
        { [ os windows? cpu x86.32? and ] [ f2c-abi        ] }
        { [ os netbsd?  cpu x86.64? and ] [ g95-abi        ] }
        { [ os windows? cpu x86.64? and ] [ gfortran-abi   ] }
        { [ os freebsd?                 ] [ gfortran-abi   ] }
        { [ os linux?                   ] [ gfortran-abi   ] }
        [ f2c-abi ]
    } cond
] initialize
