! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit kernel make math modern modern.slices
sequences sequences.extras shuffle combinators.extras splitting
strings unicode ;
IN: modern.html

TUPLE: tag open name props close children ;

TUPLE: processing-instruction open target props close ;
: <processing-instruction> ( open target props close -- processing-instruction )
    processing-instruction new
        swap >>close
        swap >>props
        swap >>target
        swap >>open ; inline

TUPLE: embedded-language open payload close ;
: <embedded-language> ( open payload close -- embedded-language )
    embedded-language new
        swap >>close
        swap >>payload
        swap >>open ; inline

TUPLE: doctype open close values ;
: <doctype> ( open values close -- doctype )
    doctype new
        swap >string >>close
        swap >>values
        swap >string >>open ;

TUPLE: cdata open close value ;
: <cdata> ( open value close -- doctype )
    cdata new
        swap >string >>close
        swap >>value
        swap >string >>open ;

TUPLE: comment open payload close ;
: <comment> ( open payload close -- comment )
    comment new
        swap >>close
        swap >>payload
        swap >>open ;

TUPLE: close-tag name ;
: <close-tag> ( name -- tag )
    close-tag new
        swap >string rest rest but-last >>name ;

TUPLE: open-tag < tag close-tag ;
: <open-tag> ( open name props close -- tag )
    open-tag new
        swap >>close
        swap >>props
        swap >string >>name
        swap >string >>open
        V{ } clone >>children ;

TUPLE: self-close-tag < tag ;
: <self-close-tag> ( open name props close -- tag )
    self-close-tag new
        swap >>close
        swap >>props
        swap >string >>name
        swap >string >>open
        V{ } clone >>children ;

TUPLE: text text ;
: <text> ( text -- text )
    text new
        swap >>text ; inline

TUPLE: squote payload ;
C: <squote> squote
TUPLE: dquote payload ;
C: <dquote> dquote

: advance-dquote-payload-noescape ( n string -- n' string )
    over [
        { CHAR: \" } slice-til-separator-inclusive {
            { f [ to>> over string-expected-got-eof ] }
            { CHAR: \" [ drop ] }
        } case
    ] [
        string-expected-got-eof
    ] if ;

: advance-squote-payload-noescape ( n string -- n' string )
    over [
        { CHAR: ' } slice-til-separator-inclusive {
            { f [ to>> over string-expected-got-eof ] }
            { CHAR: ' [ drop ] }
        } case
    ] [
        string-expected-got-eof
    ] if ;

:: read-string ( $n $string $char -- n' string payload )
    $n $string $char CHAR: ' =
    [ advance-squote-payload-noescape ]
    [ advance-dquote-payload-noescape ] if drop :> $n'
    $n' $string
    $n $n' 1 - $string <slice> ;

: take-tag-name ( n string -- n' string tag )
    [ "\t\s\r\n/>" member? ] slice-until ;

: read-value ( n string -- n' string value )
    take-char {
        { CHAR: ' [ CHAR: ' read-string >string <squote> ] }
        { CHAR: " [ CHAR: " read-string >string <dquote> ] }
        { CHAR: [ [ "[" throw ] }
        { CHAR: { [ "{" throw ] }
        [ [ take-tag-name ] dip prefix ]
    } case ;

: read-prop ( n string -- n' string prop/f closing/f )
    skip-whitespace "\s\n\r\t\"'<=/>?" slice-til-either {
        { CHAR: < [ "< error" throw ] }
        { CHAR: = [ 1 split-slice-back drop >string [ read-value ] dip swap 2array f ] }
        { CHAR: / [ ">" expect-and-span 2 split-slice-back [ >string f like ] bi@ ] }
        { CHAR: > [ 1 split-slice-back [ >string f like ] bi@ ] }
        { CHAR: ' [ first read-string >string <squote> f ] }
        { CHAR: " [ first read-string >string <dquote> f ] }
        { CHAR: ? [ ">" expect-and-span >string f swap ] }
        { CHAR: \s [ [ 1 + ] 2dip >string f ] }
        { CHAR: \r [ [ 1 + ] 2dip >string f ] }
        { CHAR: \n [ [ 1 + ] 2dip >string f ] }
        { CHAR: \t [ [ 1 + ] 2dip >string f ] }
        { f [ "efff" throw ] }
    } case ;

: read-props* ( n string props -- n' string props closing )
    [ read-prop ] dip-2up [
        [ [ over push ] when* ] dip
    ] [
        [ over push ] when* read-props*
    ] if* ; inline recursive

: read-props ( n string -- n' string props closing )
    V{ } clone read-props* ;

: read-processing-instruction ( n string opening -- n string processing-instruction )
    "?" expect-and-span >string
    [ take-tag-name >string ] dip-1up
    [ read-props ] 2dip-2up
    <processing-instruction> ;

: read-doctype-or-cdata ( n string opening -- n string doctype/comment )
    "!" expect-and-span
    2over 2 peek-from "--" sequence= [
        "--" expect-and-span >string
        [ "-->" slice-til-string [ >string ] bi@ ] dip-2up <comment>
    ] [
        2over 1 peek-from "[" sequence= [
            "[CDATA[" expect-and-span-insensitive
            [ "]]" slice-til-string [ >string ] bi@ ] dip-2up <cdata>
        ] [
            "DOCTYPE" expect-and-span-insensitive
            [ read-props ] dip-2up
            <doctype>
        ] if
    ] if ;

: read-embedded-language ( n string opening -- n string embedded-language )
    "%" expect-and-span >string
    [ take-tag-name >string ] dip-1up append
    [ "%>" slice-til-string [ >string ] bi@ ] dip-2up
    <embedded-language> ;

: read-open-tag ( n string opening -- n' string tag )
    [ take-tag-name ] dip-1up
    [ read-props ] 2dip-2up
    dup ">" sequence= [
        <open-tag>
    ] [
        <self-close-tag>
    ] if ;

: read-close-tag ( n string opening -- n' string tag )
    "/" expect-and-span
    [ take-tag-name ] dip span-slices
    ">" expect-and-span
    <close-tag> ;

: unclosed-open-tag? ( obj -- ? )
    { [ open-tag? ] [ close-tag>> not ] } 1&& ; inline

ERROR: unmatched-open-tags-error stack seq ;
: check-tag-stack ( stack -- stack )
    dup [ unclosed-open-tag? ] filter
    [ unmatched-open-tags-error ] unless-empty ;

ERROR: unmatched-closing-tag-error stack tag ;
:: find-last-open-tag ( stack name -- seq )
    stack [ { [ unclosed-open-tag? ] [ name>> name = ] } 1&& ] find-last drop [
        stack swap shorten*
    ] [
        stack name unmatched-closing-tag-error
    ] if* ;

: lex-html ( stack n string -- stack n' string )
    "<" slice-til-either {
        { CHAR: < [
            1 split-slice-back [ >string f like [ reach push ] when* ] dip
            [ 2dup peek1-from ] dip
            swap {
                { CHAR: / [
                    read-close-tag reach over name>> find-last-open-tag unclip
                    swap check-tag-stack >>children
                    swap >>close-tag
                    ] }
                { CHAR: ! [ read-doctype-or-cdata ] }
                { CHAR: ? [ read-processing-instruction ] }
                { CHAR: % [ read-embedded-language ] }
                [ drop read-open-tag ]
            } case
        ] }
        { f [ drop f ] }
        [ drop >string <text> ]
    } case [ reach push lex-html ] when* ;

: string>html ( string -- sequence )
    [ V{ } clone 0 ] dip lex-html 2drop check-tag-stack ;

GENERIC: write-html ( tag -- )

: >value ( obj -- string )
    {
        { [ dup squote? ] [ payload>> "'" 1surround ] }
        { [ dup dquote? ] [ payload>> "\"" 1surround ] }
        [ ]
    } cond ;

M: doctype write-html
    [ open>> % ]
    [ values>> [ >value ] map " " join [ " " % % ] unless-empty ]
    [ close>> % ] tri ;

M: cdata write-html
    [ open>> % ]
    [ value>> % ]
    [ close>> % ] tri ;

: write-props ( seq -- )
    [
        dup array? [ first2 >value "=" glue ] [ >value ] if
    ] map " " join [ " " % % ] unless-empty ;

M: processing-instruction write-html
    {
        [ open>> % ]
        [ target>> % ]
        [ props>> write-props ]
        [ close>> % ]
    } cleave ;

M: open-tag write-html
    {
        [ open>> % ]
        [ name>> % ]
        [ props>> write-props ]
        [ close>> % ]
        [ children>> [ write-html ] each ]
        [ close-tag>> name>> "</" ">" surround % ]
    } cleave ;

M: self-close-tag write-html
    {
        [ open>> % ]
        [ name>> % ]
        [ props>> write-props ]
        [ close>> % ]
    } cleave ;

M: comment write-html
    [ open>> % ]
    [ payload>> % ]
    [ close>> % ] tri ;

M: string write-html % ;

: html>string ( sequence -- string )
    [ [ write-html ] each ] "" make ;

GENERIC#: walk-html 1 ( seq/tag quot -- )

M: sequence walk-html [ walk-html ] curry each ;
M: string walk-html call( obj -- ) ;
M: doctype walk-html call( obj -- ) ;
M: processing-instruction walk-html call( obj -- ) ;
M: embedded-language walk-html call( obj -- ) ;
M: open-tag walk-html [ call( obj -- ) ] 2keep [ children>> ] dip [ walk-html ] curry each ;
M: self-close-tag walk-html [ call( obj -- ) ] 2keep [ children>> ] dip [ walk-html ] curry each ;
M: comment walk-html call( obj -- ) ;

: find-links ( seq -- links )
    [
        [
            dup tag? [
                props>> [ drop  >lower "href" = ] assoc-find
                [ nip , ] [ 2drop ] if
            ] [ drop ] if
        ] walk-html
    ] { } make [ payload>> ] map ;
