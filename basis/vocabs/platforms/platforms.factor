! Copyright (C) 2018 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors compiler.units kernel layouts lexer multiline
parser sequences splitting system vocabs vocabs.parser ;
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

SYNTAX: <TESTS
    "TESTS>" parse-multiline-string drop ;

SYNTAX: <32
    "32>" parse-multiline-string
    cell-bits 32 = [ ".32" parse-platform-section ] [ drop ] if ;

SYNTAX: <64
    "64>" parse-multiline-string
    cell-bits 64 = [ ".64" parse-platform-section ] [ drop ] if ;

SYNTAX: <UNIX
    "UNIX>" parse-multiline-string
    os unix? [ ".unix" parse-platform-section ] [ drop ] if ;

SYNTAX: <BSD
    "BSD>" parse-multiline-string
    os bsd? [ ".bsd" parse-platform-section ] [ drop ] if ;

SYNTAX: <FREEBSD
    "FREEBSD>" parse-multiline-string
    os freebsd? [ ".freebsd" parse-platform-section ] [ drop ] if ;

SYNTAX: <MACOSX
    "MACOSX>" parse-multiline-string
    os macosx? [ ".macosx" parse-platform-section ] [ drop ] if ;

SYNTAX: <LINUX
    "LINUX>" parse-multiline-string
    os linux? [ ".linux" parse-platform-section ] [ drop ] if ;

SYNTAX: <WINDOWS
    "WINDOWS>" parse-multiline-string
    os windows? [ ".windows" parse-platform-section ] [ drop ] if ;

! Inverted sections
SYNTAX: <!32
    "!32>" parse-multiline-string
    cell-bits 32 = [ drop ] [ ".32" parse-platform-section ] if ;

SYNTAX: <!64
    "!64>" parse-multiline-string
    cell-bits 64 = [ drop ] [ ".64" parse-platform-section ] if ;

SYNTAX: <!UNIX
    "!UNIX>" parse-multiline-string
    os unix? [ drop ] [ ".unix" parse-platform-section ] if ;

SYNTAX: <!BSD
    "!BSD>" parse-multiline-string
    os bsd? [ drop ] [ ".bsd" parse-platform-section ] if ;

SYNTAX: <!FREEBSD
    "!FREEBSD>" parse-multiline-string
    os freebsd? [ drop ] [ ".freebsd" parse-platform-section ] if ;

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
SYNTAX: USE-BSD: scan-token os bsd? [ use-vocab ] [ drop ] if ;
SYNTAX: USE-FREEBSD: scan-token os freebsd? [ use-vocab ] [ drop ] if ;
SYNTAX: USE-MACOSX: scan-token os macosx? [ use-vocab ] [ drop ] if ;
SYNTAX: USE-LINUX: scan-token os linux? [ use-vocab ] [ drop ] if ;
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
