! Copyright (C) 2018 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors compiler.units kernel multiline parser
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
