USING: system vocabs vocabs.loader kernel combinators
namespaces sequences io.backend accessors ;
IN: bootstrap.io

"bootstrap.compiler" vocab [
    "io.backend." {
        { [ "io-backend" get ] [ "io-backend" get ] }
        { [ os unix? ] [ "unix." os name>> append ] }
        { [ os winnt? ] [ "windows.nt" ] }
    } cond append require
] when
