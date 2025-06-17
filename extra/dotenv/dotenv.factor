! Copyright (C) 2025 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: ascii environment io.directories io.encodings.utf8
io.files io.launcher io.pathnames kernel make namespaces peg
peg.parsers regexp sequences splitting strings.parser ;

IN: dotenv

<PRIVATE

: ws ( -- parser )
    [ " \t" member? ] satisfy repeat0 ;

: comment ( -- parser )
    "#" token [ CHAR: \n = not ] satisfy repeat0 2seq hide ;

: newline ( -- parser )
    "\n" token "\r\n" token 2choice ;

: key-parser ( -- parser )
    CHAR: A CHAR: Z range
    CHAR: a CHAR: z range
    [ CHAR: _ = ] satisfy 3choice

    CHAR: A CHAR: Z range
    CHAR: a CHAR: z range
    CHAR: 0 CHAR: 9 range
    [ CHAR: _ = ] satisfy 4choice repeat0

    2seq [ first2 swap prefix "" like ] action ;

: escaped-char ( ch -- parser )
    [ "\\" token hide ] dip '[ _ = ] satisfy 2seq [ first ] action ;

: single-quote ( -- parser )
    CHAR: ' escaped-char [ CHAR: ' = not ] satisfy 2choice repeat0
    "'" dup surrounded-by ;

: backtick ( -- parser )
    CHAR: ` escaped-char [ CHAR: ` = not ] satisfy 2choice repeat0
    "`" dup surrounded-by ;

: escaped ( -- parser )
    "\\" token hide [ "\"\\befnrt" member-eq? ] satisfy 2seq
    [ first escape ] action ;

: double-quote ( -- parser )
    escaped [ CHAR: " = not ] satisfy 2choice repeat0
    "\"" dup surrounded-by ;

: literal ( -- parser )
    [ " \t" member? not ] satisfy repeat1 ;

: interpolate-value ( string -- string' )
    R/ \$\([^)]+\)|\$\{[^\}:-]+(:?-[^\}]*)?\}|\$[^(^{].+/ [
        "$(" ?head [
            ")" ?tail drop process-contents [ blank? ] trim
        ] [
            "${" ?head [ "}" ?tail drop ] [ "$" ?head drop ] if
            ":-" split1 [
                [ os-env [ empty? not ] keep ] dip ?
            ] [
                "-" split1 [ [ os-env ] dip or ] [ os-env ] if*
            ] if*
        ] if
    ] re-replace-with ;

: interpolate ( parser -- parser )
    [ "" like interpolate-value ] action ;

: value-parser ( -- parser )
    [
        single-quote ,
        double-quote interpolate ,
        backtick ,
        literal interpolate ,
    ] choice* [ "" like ] action ;

: key-value-parser ( -- parser )
    [
        key-parser ,
        ws hide ,
        "=" token hide ,
        ws hide ,
        value-parser ,
    ] seq* [ first2 swap set-os-env ignore ] action ;

PEG: parse-dotenv ( string -- ast )
    ws hide key-value-parser ws hide comment optional hide 4seq
    ws hide comment optional hide 2seq
    2choice newline list-of hide ;

PRIVATE>

: find-dotenv-file ( -- path/f )
    f current-directory get absolute-path [
        nip
        [ ".env" append-path dup file-exists? [ drop f ] unless ]
        [ ?parent-directory ] bi over [ f ] [ dup ] if
    ] loop drop ;

: load-dotenv-file ( path -- )
    utf8 file-contents parse-dotenv drop ;

: load-dotenv ( -- )
    find-dotenv-file [ load-dotenv-file ] when* ;
