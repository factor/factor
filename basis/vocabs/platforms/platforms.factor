! Copyright (C) 2018 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors compiler.units kernel lexer multiline parser
sequences splitting system vocabs.parser ;
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

SYNTAX: USE-X86-32: scan-token os x86.32? [ use-vocab ] [ drop ] if ;
SYNTAX: USE-X86-64: scan-token os x86.64? [ use-vocab ] [ drop ] if ;
SYNTAX: USE-ARM-32: scan-token os arm.32? [ use-vocab ] [ drop ] if ;
SYNTAX: USE-ARM-64: scan-token os arm.64? [ use-vocab ] [ drop ] if ;

SYNTAX: USE-IF: scan-token scan-object call( -- ? ) [ use-vocab ] [ drop ] if ;
