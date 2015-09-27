USING: accessors combinators namespaces sequences system vocabs
;
IN: bootstrap.io

"bootstrap.compiler" require
"bootstrap.threads" require

"io.backend." {
    { [ "io-backend" get ] [ "io-backend" get ] }
    { [ os unix? ] [ "unix." os name>> append ] }
    { [ os windows? ] [ "windows" ] }
} cond append require
