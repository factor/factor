USING: system vocabs vocabs.loader kernel combinators
namespaces sequences io.backend ;
IN: bootstrap.io

"bootstrap.compiler" vocab [
    "io." {
        { [ "io-backend" get ] [ "io-backend" get ] }
        { [ unix? ] [ "unix" ] }
        { [ winnt? ] [ "windows.nt" ] }
        { [ wince? ] [ "windows.ce" ] }
    } cond append require
] when
