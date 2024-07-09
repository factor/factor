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
SYMBOL: program-prolog

! printed after the help options
SYMBOL: program-epilog

TUPLE: option name type help variable default convert validate
    const required? meta #args ;

<PRIVATE

GENERIC: >option ( obj -- option )
M: string >option option new swap >>name ;
M: option >option ;

: option-name ( option -- name )
    {
        [ name>> ] [ variable>> dup string? [ name>> ] unless ]
    } 1|| [ CHAR: - = ] trim-head ;

:: option-#args ( option -- #args )
    option #args>> [ option const>> 1 xor ] unless* ;

: option-meta ( option -- meta/f )
    dup option-#args [
        [ { [ meta>> ] [ option-name ] } 1|| >upper ] dip {
            { "+" [ dup "%s [%s ...]" sprintf ] }
            { "*" [ "[%s ...]" sprintf ] }
            { "?" [ "[%s]" sprintf ] }
            [ swap <repetition> " " join ]
        } case
    ] [ drop f ] if* ;

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
    "The option ``" write dup arg>> write
    "'' matches more than one (" write
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
            { string [ ] }
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

:: option-convert ( arg option -- value )
    arg [ option expected-arguments ] unless*
    option { [ convert>> ] [ type>> ] } 1||
    [ argconvert ] when*
    option { [ validate>> ] [ type>> ] } 1||
    [ dupd argvalid? [ option arg invalid-value ] unless ] when* ;

:: option-value ( args option -- args' value )
    args option option-#args {
        { "+" [
            [ option expected-arguments ]
            [ f swap [ option option-convert ] map ]
            if-empty ] }
        { "*" [ f swap [ option option-convert ] map ] }
        { "?" [ ?unclip [ option option-convert ] [ option const>> ] if* ] }
        [
            [
                2dup 1 - swap bounds-check? [
                    dup 1 = [
                        drop unclip option option-convert
                    ] [
                        cut swap [ option option-convert ] map
                    ] if
                ] [
                    drop option expected-arguments
                ] if
            ] [ option const>> ] if*
        ]
    } case ;

: get-program-name ( -- name )
    {
        [ program-name get ]
        [ script get [ "factor " prepend ] [ f ] if* ]
        [
            "run" get [
                dup "tools.deploy.shaker" =
                [ drop f ] [ "factor -run=" prepend ] if
            ] [ f ] if*
        ]
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
    "Usage:\n    " write dup print-short-usage
    program-prolog get [ nl print ] unless-empty
    [ positional? ] partition
    [ [ nl "Arguments:" print print-options ] unless-empty ]
    [ [ nl "Options:" print print-options ] unless-empty ] bi*
    program-epilog get [ nl print ] unless-empty ;

ERROR: usage-error < option-error options ;

M: usage-error error. options>> print-help ;

:: find-option ( arg options -- option )
    options [ option-name arg = ] find nip [
        allow-abbrev? get [
            arg options [ dup option-name ] map>alist
            completions keys dup length {
                { 0 [ arg unknown-option ] }
                { 1 [ first ] }
                [ drop arg swap ambiguous-option ]
            } case
        ] [
            arg unknown-option
        ] if
    ] unless* ;

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

: (parse-arguments) ( optional positional command-line -- positional' )
    [
        pick empty? [ f ] [
            1 over [ "-" head? ] find-from drop
            [ cut ] [ f ] if*
        ] if [
            pick empty? [ f ] [ dup first "-" head? ] if [
                overd parse-optional
            ] [
                [ ?unclip ] dip over
                [ parse-positional ]
                [ unrecognized-arguments ] if
            ] if
        ] dip append
    ] until-empty nip ;

: parse-arguments ( options command-line -- arguments )
    [ dup [ optional? ] partition ] dip { "--" } split1
    [ (parse-arguments) f swap ] dip (parse-arguments)
    [ #args>> { "*" "?" } member? ] reject
    [ required-options ] unless-empty
    [ required?>> ] filter namespace [
        '[ option-variable _ key? ] reject
        [ required-options ] unless-empty
    ] keep ;

PRIVATE>

: (parse-options) ( options command-line -- arguments )
    [ [ >option ] map ] dip over default-options [
        default-help? get [ [ HELP prefix ] dip ] when
        [ parse-arguments ] pick '[
            default-help? get [ print-help? get [ _ usage-error ] when ] when
        ] finally
    ] with-variables ;

: parse-options ( options -- arguments )
    command-line get (parse-options) ;

: with-options ( ... options quot: ( ... -- ... ) -- ... )
    '[ _ parse-options _ with-variables ] [
        dup option-error? [
            dup usage-error? [ "ERROR: " write ] unless
            print-error
        ] [ rethrow ] if
    ] recover ; inline
