USING: system vocabs vocabs.loader kernel combinators
namespaces sequences io.backend accessors ;
IN: bootstrap.io

"bootstrap.compiler" require
"bootstrap.threads" require

"io.backend." {
    { [ "io-backend" get ] [ "io-backend" get ] }
    { [ os unix? ] [ "unix." os name>> append ] }
    { [ os windows? ] [ "windows" ] }
} cond append require
