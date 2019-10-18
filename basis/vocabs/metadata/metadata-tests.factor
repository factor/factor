USING: accessors debugger kernel system tools.test vocabs
vocabs.parser ;
IN: vocabs.metadata

: wrong-platform-vocab-name ( -- name )
    os windows? "unix" "windows" ? ;

[
    [ wrong-platform-vocab-name use-vocab ]
    [ error>> unsupported-platform? ] must-fail-with

    ! Factor remembers that we tried to load the wrong vocab
    ! and this breaks f2 until we forget the vocab.
    ! See issue #1463.
    [ wrong-platform-vocab-name forget-vocab ] try
] with-manifest
