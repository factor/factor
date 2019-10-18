USING: system vocabs vocabs.loader kernel ;
IN: bootstrap.io

"bootstrap.compiler" vocab [
    unix? [ "io.unix" require ] when
    winnt? [ "io.windows.nt" require ] when
    wince? [ "io.windows.ce" require ] when
] when
