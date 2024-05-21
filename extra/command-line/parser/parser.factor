! Copyright (C) 2024 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs classes combinators
combinators.short-circuit command-line continuations debugger
formatting io io.pathnames io.sockets kernel lexer math
math.parser namespaces parser quotations random sequences
sequences.extras splitting strings strings.tables.private
tools.completion unicode vocabs.parser ;

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
    { [ name>> ] [ variable>> dup string? [ name>> ] unless ] } 1|| ;

: option-meta ( option -- meta/f )
    dup const>> [ drop f ] [
        { [ meta>> ] [ option-name ] } 1|| >upper
    ] if ;

: option-variable ( option -- variable )
    { [ variable>> ] [ name>> ] } 1|| ;

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

GENERIC: argconvert ( str/f converter -- val )

M: f argconvert drop ;

M: class argconvert
    drop [ 1array <lexer> [ scan-object ] with-lexer ] with-manifest ;

M: quotation argconvert call( str -- val ) ;

M: boolean argconvert
    drop {
        { [ dup >lower { "t" "true" "1" "on" "y" "yes" } member? ] [ drop t ] }
        { [ dup >lower { "f" "false" "0" "off" "n" "no" } member? ] [ drop f ] }
        [ throw ]
    } cond ;

M: number argconvert drop string>number ;

M: hostname argconvert drop hostname boa ;

M: ipv4 argconvert drop resolve-host [ ipv4? ] filter random ;

M: ipv6 argconvert drop resolve-host [ ipv6? ] filter random ;

M: inet argconvert drop ":" split1 string>number <inet> ;

M: inet4 argconvert
    [ ":" split1 ] dip swap
    [ call-next-method ] [ string>number with-port ] bi* ;

M: inet6 argconvert
    [ ":" split1 ] dip swap
    [ call-next-method ] [ string>number with-port ] bi* ;

GENERIC: argvalid? ( val validater -- ? )

M: f argvalid? 2drop t ;

M: quotation argvalid? call( val -- ? ) ;

M: class argvalid? instance? ;

:: option-value ( args option -- args' value )
    args option const>> [
        ?unclip :> arg
        arg [ option expected-arguments ] unless*
        option { [ convert>> ] [ type>> ] } 1||
        [ argconvert ] when*
        option { [ validate>> ] [ type>> ] } 1||
        [ dupd argvalid? [ option arg invalid-value ] unless ] when*
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
    [ option-name "--" prepend ]
    [ option-meta [ " " glue ] when* ] bi ;

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
    { name "help" }
    { help "show this help and exit" }
    { variable print-help? }
    { const t }
}

: print-help ( options -- )
    "Usage:" print print-program-name nl
    help-prolog get [ nl print nl ] unless-empty
    "Options:" print print-options
    help-epilog get [ nl print ] unless-empty ;

ERROR: usage-error < option-error options ;

M: usage-error error. options>> print-help ;

:: find-option ( arg options -- option )
    allow-abbrev? get [
        arg options named completions keys dup length {
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

PRIVATE>

: (parse-options) ( options command-line -- kwds args )
    over default-options [
        [ dup ?first "-" head? ] [
            unclip [ CHAR: - = ] trim-head
            "no-" ?head [ pick find-option ] dip
            [ f swap ] [ [ option-value ] keep ] if
            option-variable set
        ] while nip namespace swap
    ] with-variables ;

: parse-options ( options -- kwds args )
    command-line get (parse-options) ;

:: (with-options) ( ... options quot: ( ... kwds args -- ... ) -- ... )
    options
    default-help? get [ HELP prefix ] when
    dup parse-options :> ( kwds args )

    default-help? get [ print-help? kwds at ] [ f ] if
    [ usage-error ] [
        [ required?>> ] filter
        [ option-variable kwds key? ] reject
        [ required-options ] unless-empty
        kwds args quot call
    ] if ; inline

: with-options ( ... options quot: ( ... kwds args -- ... ) -- ... )
    '[ _ _ (with-options) ] [
        dup option-error? [
            dup usage-error? [ "ERROR: " write ] unless
            print-error flush
        ] [ rethrow ] if
    ] recover ; inline
