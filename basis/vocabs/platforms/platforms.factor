! Copyright (C) 2018 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays compiler.units kernel lexer multiline
namespaces parser sequences sets splitting system vocabs
vocabs.loader.private vocabs.parser ;
IN: vocabs.platforms

: with-vocabulary ( quot suffix -- )
    [
        [ [ current-vocab name>> ] dip ?tail drop ]
        [ append ] bi set-current-vocab
        call
    ] [
        [ current-vocab name>> ] dip ?tail drop set-current-vocab
    ] bi ; inline

: parse-platform-section ( string suffix -- )
    [
        [ [ split-lines parse-lines ] curry with-nested-compilation-unit ]
        curry
    ] dip with-vocabulary drop ; inline

SYNTAX: <UNIX
    "UNIX>" parse-multiline-string
    os unix? [ ".unix" parse-platform-section ] [ drop ] if ;

SYNTAX: <MACOSX
    "MACOSX>" parse-multiline-string
    os macosx? [ ".macosx" parse-platform-section ] [ drop ] if ;

SYNTAX: <LINUX
    "LINUX>" parse-multiline-string
    os linux? [ ".linux" parse-platform-section ] [ drop ] if ;

SYNTAX: <WINDOWS
    "WINDOWS>" parse-multiline-string
    os windows? [ ".windows" parse-platform-section ] [ drop ] if ;

SYNTAX: <!UNIX
    "!UNIX>" parse-multiline-string
    os unix? [ drop ] [ ".unix" parse-platform-section ] if ;

SYNTAX: <!MACOSX
    "!MACOSX>" parse-multiline-string
    os macosx? [ drop ] [ ".macosx" parse-platform-section ] if ;

SYNTAX: <!LINUX
    "!LINUX>" parse-multiline-string
    os linux? [ drop ] [ ".linux" parse-platform-section ] if ;

SYNTAX: <!WINDOWS
    "!WINDOWS>" parse-multiline-string
    os windows? [ drop ] [ ".windows" parse-platform-section ] if ;

SYNTAX: USE-UNIX: scan-token os unix? [ use-vocab ] [ drop ] if ;
SYNTAX: USE-FREEBSD: scan-token os freebsd? [ use-vocab ] [ drop ] if ;
SYNTAX: USE-LINUX: scan-token os linux? [ use-vocab ] [ drop ] if ;
SYNTAX: USE-MACOSX: scan-token os macosx? [ use-vocab ] [ drop ] if ;
SYNTAX: USE-WINDOWS: scan-token os windows? [ use-vocab ] [ drop ] if ;
SYNTAX: USE-OS-SUFFIX: scan-token os name>> "." glue require ;

SYNTAX: USE-X86: scan-token cpu x86? [ use-vocab ] [ drop ] if ;
SYNTAX: USE-X86-32: scan-token cpu x86.32? [ use-vocab ] [ drop ] if ;
SYNTAX: USE-X86-64: scan-token cpu x86.64? [ use-vocab ] [ drop ] if ;
SYNTAX: USE-ARM: scan-token cpu arm? [ use-vocab ] [ drop ] if ;
SYNTAX: USE-ARM-32: scan-token cpu arm.32? [ use-vocab ] [ drop ] if ;
SYNTAX: USE-ARM-64: scan-token cpu arm.64? [ use-vocab ] [ drop ] if ;
SYNTAX: USE-PPC: scan-token cpu ppc? [ use-vocab ] [ drop ] if ;
SYNTAX: USE-PPC-32: scan-token cpu ppc.32? [ use-vocab ] [ drop ] if ;
SYNTAX: USE-PPC-64: scan-token cpu ppc.64? [ use-vocab ] [ drop ] if ;

SYNTAX: USE-IF: scan-token scan-object call( -- ? ) [ use-vocab ] [ drop ] if ;

SYNTAX: WHEN-UNIX: scan-object os unix? [ call( -- ) ] [ drop ] if ;
SYNTAX: WHEN-FREEBSD: scan-object os freebsd? [ call( -- ) ] [ drop ] if ;
SYNTAX: WHEN-LINUX: scan-object os linux? [ call( -- ) ] [ drop ] if ;
SYNTAX: WHEN-MACOSX: scan-object os macosx? [ call( -- ) ] [ drop ] if ;
SYNTAX: WHEN-WINDOWS: scan-object os windows? [ call( -- ) ] [ drop ] if ;

SYNTAX: IF-UNIX: scan-object scan-object os unix? -rot ? call( -- ) ;
SYNTAX: IF-FREEBSD: scan-object scan-object os freebsd? -rot ? call( -- ) ;
SYNTAX: IF-LINUX: scan-object scan-object os linux? -rot ? call( -- ) ;
SYNTAX: IF-MACOSX: scan-object scan-object os macosx? -rot ? call( -- ) ;
SYNTAX: IF-WINDOWS: scan-object scan-object os windows? -rot ? call( -- ) ;
