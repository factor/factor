! Copyright (C) 2024 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs classes combinators
combinators.short-circuit command-line continuations debugger
formatting generic.math io io.pathnames io.sockets kernel lexer
math math.parser namespaces parser prettyprint quotations random
sequences sequences.extras splitting strings
strings.tables.private tools.completion unicode vocabs.parser ;

IN: command-line.parser

! add a --help default option
INITIALIZED-SYMBOL: default-help? [ t ]

! allow unambiguous abbreviations of options
INITIALIZED-SYMBOL: allow-abbrev? [ t ]

! the optional name of the program, or inferred
SYMBOL: program-name

! printed before the help options
SYMBOL: help-prolog

! printed after the help options
SYMBOL: help-epilog

TUPLE: option name type help variable default convert validate
    const required? meta ;

<PRIVATE

: option-name ( option -- name )
    {
        [ name>> [ CHAR: - = ] trim-head ]
        [ variable>> dup string? [ name>> ] unless ]
    } 1|| ;

: option-meta ( option -- meta/f )
    dup const>> [ drop f ] [
        { [ meta>> ] [ option-name ] } 1|| >upper
    ] if ;

: option-variable ( option -- variable )
    { [ variable>> ] [ name>> [ CHAR: - = ] trim-head ] } 1|| ;

: optional? ( option -- ? ) name>> "-" head? ;

: positional? ( option -- ? ) optional? not ;

ERROR: option-error ;

ERROR: unknown-option < option-error str ;

M: unknown-option error.
    "Unknown option ``" write str>> write "''" print ;

ERROR: ambiguous-option < option-error arg options ;

M: ambiguous-option error.
    "The argument ``" write dup arg>> write
    "'' resolves to more than one option (" write
    options>> [ ", " write ] [ option-name write ] interleave
    ")" print ;

ERROR: required-options < option-error options ;

M: required-options error.
    "Missing required options (" write
    options>> [ ", " write ] [ option-name write ] interleave
    ")" print ;

ERROR: invalid-value < option-error option value ;

M: invalid-value error.
    "Invalid value ``" write dup value>> write
    "'' for option ``" write option>> option-name write
    "''" print ;

ERROR: expected-arguments < option-error option ;

M: expected-arguments error.
    "Expected more arguments for option ``" write
    option>> option-name write "''" print ;

ERROR: unrecognized-arguments < option-error args ;

M: unrecognized-arguments error.
    "Unrecognized arguments: " write
    args>> [ bl ] [ write ] interleave nl ;

ERROR: cannot-convert-value < option-error str converter ;

M: cannot-convert-value error.
    "Unable to convert value ``" write dup str>> write
    "'' with converter ``" write converter>> pprint "''" print ;

: argconvert ( str/f converter -- val )
    dup quotation? [ call( str -- val ) ] [
        {
            { f [ ] }
            { object [ [ 1array <lexer> [ scan-object ] with-lexer ] with-manifest ] }
            { boolean [ {
                    { [ dup >lower { "t" "true" "1" "on" "y" "yes" } member? ] [ drop t ] }
                    { [ dup >lower { "f" "false" "0" "off" "n" "no" } member? ] [ drop f ] }
                    [ throw ]
                } cond ] }
            { hostname [ hostname boa ] }
            { inet [ ":" split1 string>number <inet> ] }
            { inet4 [ ":" split1 [ ipv4 argconvert ] [ string>number ] bi* <inet4> ] }
            { inet6 [ ":" split1 [ ipv6 argconvert ] [ string>number ] bi* <inet6> ] }
            { ipv4 [ resolve-host [ ipv4? ] filter random ] }
            { ipv6 [ resolve-host [ ipv6? ] filter random ] }
            [
                dup math-class? [
                    drop string>number
                ] [
                    cannot-convert-value
                ] if
            ]
        } case
    ] if ;

GENERIC: argvalid? ( val validater -- ? )

M: f argvalid? 2drop t ;

M: quotation argvalid? call( val -- ? ) ;

M: class argvalid? instance? ;

:: option-value ( args option -- args' value )
    args option const>> [
        option positional? [
            f swap [| arg |
                arg [ option expected-arguments ] unless*
                option { [ convert>> ] [ type>> ] } 1||
                [ argconvert ] when*
                option { [ validate>> ] [ type>> ] } 1||
                [ dupd argvalid? [ option arg invalid-value ] unless ] when*
            ] map
        ] [
            ?unclip :> arg
            arg [ option expected-arguments ] unless*
            option { [ convert>> ] [ type>> ] } 1||
            [ argconvert ] when*
            option { [ validate>> ] [ type>> ] } 1||
            [ dupd argvalid? [ option arg invalid-value ] unless ] when*
        ] if
    ] unless* ;

: get-program-name ( -- name )
    {
        [ program-name get ]
        [ "run" get [ "factor -run=" prepend ] [ f ] if* ]
        [ (command-line) first file-name ]
    } 0|| ;

: print-program-name ( -- )
    get-program-name "    " write write " [options] [arguments]" print ;

: option-argument ( option -- argument )
    [ option-name ]
    [
        dup positional? [ drop ] [
            [ "--" prepend ]
            [ option-meta [ " " glue ] when* ] bi*
        ] if
    ] bi ;

: print-arguments ( options -- )
    [ bl ] [ option-argument "[" "]" surround write ] interleave ;

: print-short-usage ( options -- )
    get-program-name write bl print-arguments nl ;

: option-description ( option -- description )
    [ help>> ]
    [ default>> dup [ "(default: %s)" sprintf ] when ] bi
    2dup and [ " " glue ] [ or "" or ] if ;

: print-options ( options -- )
    [ [ option-argument ] [ option-description ] bi ] map>alist
    format-cells flip [ "    %s    %s\n" printf ] assoc-each ;

SYMBOL: print-help?

CONSTANT: HELP T{ option
    { name "--help" }
    { help "show this help and exit" }
    { variable print-help? }
    { const t }
}

: print-help ( options -- )
    "Usage:" print print-program-name
    help-prolog get [ nl print ] unless-empty
    [ positional? ] partition
    [ [ nl "Arguments:" print print-options ] unless-empty ]
    [ [ nl "Options:" print print-options ] unless-empty ] bi*
    help-epilog get [ nl print ] unless-empty ;

ERROR: usage-error < option-error options ;

M: usage-error error. options>> print-help ;

:: find-option ( arg options -- option )
    allow-abbrev? get [
        arg options [ dup option-name ] map>alist
        completions keys dup length {
            { 0 [ arg unknown-option ] }
            { 1 [ first ] }
            [ arg swap ambiguous-option ]
        } case
    ] [
        options [ option-name arg = ] find nip
    ] if [ arg unknown-option ] unless* ;

: default-options ( options -- defaults )
    [ default>> ] filter
    [ [ option-variable ] [ default>> ] bi ] H{ } map>assoc ;

:: parse-optional ( options command-line -- command-line' )
    command-line unclip [ CHAR: - = ] trim-head
    "no-" ?head [ options find-option ] dip
    [ f swap ] [ [ option-value ] keep ] if
    option-variable set ;

: parse-positional ( option command-line -- command-line' )
    swap [ option-value ] [ option-variable set ] bi ;

: parse-arguments ( options command-line -- )
    [ [ optional? ] partition ] dip [
        dup first "-" head? [
            overd parse-optional
        ] [
            over empty? [
                unrecognized-arguments
            ] [
                [ unclip ] dip parse-positional
            ] if
        ] if
    ] until-empty 2drop ;

PRIVATE>

: (parse-options) ( options command-line -- arguments )
    over default-options [
        default-help? get [ [ HELP prefix ] dip ] when
        dupd parse-arguments
        default-help? get [ print-help? get [ usage-error ] when ] when
        [ required?>> ] filter namespace [
            '[ option-variable _ key? ] reject
            [ required-options ] unless-empty
        ] keep
    ] with-variables ;

: parse-options ( options -- arguments )
    command-line get (parse-options) ;

: with-options ( ... options quot: ( ... -- ... ) -- ... )
    '[ _ parse-options _ with-variables ] [
        dup option-error? [
            dup usage-error? [ "ERROR: " write ] unless
            print-error flush
        ] [ rethrow ] if
    ] recover ; inline
