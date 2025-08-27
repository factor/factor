USING: accessors combinators namespaces sequences system vocabs ;
IN: bootstrap.io

"bootstrap.compiler" require
"bootstrap.threads" require

{
    { [ "io-backend" get ] [ "io.backend." "io-backend" get append ] }
    { [ os unix? ] [ "io.backend.unix." os name>> append ] }
    { [ os windows? ] [ "io.backend.windows" ] }
} cond require
