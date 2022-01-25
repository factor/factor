! Copyright (C) 2021 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators combinators.short-circuit
generalizations kernel make math modern modern.slices sequences
sequences.extras splitting strings ;
IN: modern.html

TUPLE: tag name open-close-delimiter props children ;

TUPLE: doctype open close values ;
: <doctype> ( open close values -- doctype )
    doctype new
        swap >>values
        swap >string >>close
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
: <open-tag> ( name delimiter props -- tag )
    open-tag new
        swap >>props
        swap >string drop ! >>open-close-delimiter
        swap >string >>name
        V{ } clone >>children ;

TUPLE: self-close-tag < tag ;
: <self-close-tag> ( name delimiter props -- tag )
    self-close-tag new
        swap >>props
        swap >string drop ! >>open-close-delimiter
        swap >string >>name
        V{ } clone >>children ;

TUPLE: squote payload ;
C: <squote> squote
TUPLE: dquote payload ;
C: <dquote> dquote

: read-squote-string-payload ( n string -- n' string )
    over [
        { CHAR: \\ CHAR: ' } slice-til-separator-inclusive {
            { f [ drop ] }
            { CHAR: ' [ drop ] }
            { CHAR: \\ [ drop next-char-from drop read-string-payload ] }
        } case
    ] [
        string-expected-got-eof
    ] if ;

: read-dquote-string-payload ( n string -- n' string )
    over [
        { CHAR: \\ CHAR: \" } slice-til-separator-inclusive {
            { f [ drop ] }
            { CHAR: \" [ drop ] }
            { CHAR: \\ [ drop next-char-from drop read-string-payload ] }
        } case
    ] [
        string-expected-got-eof
    ] if ;

:: read-string ( n string char -- n' string payload )
    n string char CHAR: ' = [ read-squote-string-payload ] [ read-dquote-string-payload ] if drop :> n'
    n' string
    n' [ n string string-expected-got-eof ] unless
    n n' 1 - string <slice> ;

: take-tag-name ( n string -- n' string tag )
    [ "\s\r\n/>" member? ] slice-until ;

: read-value ( n string -- n' string value )
    skip-whitespace next-char-from {
        { CHAR: ' [ CHAR: ' read-string >string <squote> ] }
        { CHAR: " [ CHAR: " read-string >string <dquote> ] }
        { CHAR: [ [ "[" throw ] }
        { CHAR: { [ "{" throw ] }
        [ [ take-tag-name ] dip prefix ]
    } case ;

: read-prop ( n string -- n' string closing/f prop/f )
    skip-whitespace "\s\n\r\"'<=/>" slice-til-either {
        { CHAR: < [ "< error" throw ] }
        { CHAR: = [ 1 split-slice-back drop >string [ read-value ] dip swap 2array f swap ] }
        { CHAR: / [ ">" expect-and-span 2 split-slice-back swap >string f like ] }
        { CHAR: > [ 1 split-slice-back swap >string f like ] }
        { CHAR: ' [ first read-string >string <squote> f swap ] }
        { CHAR: " [ first read-string >string <dquote> f swap ] }
        { CHAR: \s [ f swap >string ] }
        { CHAR: \r [ f swap >string ] }
        { CHAR: \n [ f swap >string ] }
        { f [ "efff" throw ] }
    } case ;

: read-props ( props n string -- props n' string closing )
    read-prop
    [ 5 npick push ] when*
    [ ] [ read-props ] if* ;

: read-doctype ( n string opening -- n string doctype/comment )
    "!" expect-and-span
    2over 2 peek-from "--" sequence= [
        "--" expect-and-span >string
        [ "-->" slice-til-string [ >string ] bi@ ] dip -rot <comment>
    ] [
        "DOCTYPE" expect-and-span
        [ V{ } clone -rot read-props ] dip
        swap 5 nrot <doctype>
    ] if ;

: read-open-tag ( n string opening -- n' string tag )
    [ take-tag-name ] dip drop ! B span-slices
    [ V{ } clone -rot read-props ] dip
    swap 5 nrot over ">" sequence= [
        <open-tag>
    ] [
        <self-close-tag>
    ] if ;

: read-close-tag ( n string opening -- n' string tag )
    "/" expect-and-span
    [ take-tag-name ] dip span-slices
    ">" expect-and-span
    <close-tag> ;

:: shorten* ( vector n -- seq )
    vector n tail
    n vector shorten ;

: pop-til-end ( stack quot -- seq/f )
    [ find-last drop ] keepd swap
    [ shorten* ] [ drop f ] if* ; inline

ERROR: unmatched-open-tags-error stack seq ;
: check-tag-stack ( stack -- stack )
    dup [
        { [ open-tag? ] [ close-tag>> not ] } 1&&
    ] filter [ unmatched-open-tags-error ] unless-empty ;

ERROR: unmatched-closing-tag-error stack tag ;
:: find-last-open-tag ( stack name -- seq )
    stack [ { [ tag? ] [ name>> name = ] } 1&& ] find-last drop [
        stack swap shorten*
    ] [
        stack name unmatched-closing-tag-error
    ] if* ;

: lex-html ( stack n string -- stack n' string  )
    skip-whitespace "<" slice-til-either {
        { CHAR: < [
            1 split-slice-back [ >string f like [ reach push ] when* ] dip
            [ 2dup peek1-from ] dip
            swap {
                { CHAR: / [
                    read-close-tag reach over name>> find-last-open-tag unclip
                    swap check-tag-stack >>children
                    swap >>close-tag
                    ] }
                { CHAR: ! [ read-doctype ] }
                [ drop read-open-tag ]
            } case
        ] }
        { f [ drop f ] }
        [ drop >string ]
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
    [ values>> [ >value ] map join-words [ " " % % ] unless-empty ]
    [ close>> % ] tri ;


: write-props ( seq -- )
    [ dup array? [ first2 >value "=" glue ] [ >value ] if ] map join-words [ " " % % ] unless-empty ;

M: open-tag write-html
    {
        [ "<" % name>> % ]
        [ props>> write-props ">" % ]
        [ children>> [ write-html ] each ]
        [ close-tag>> name>> "</" ">" surround % ]
    } cleave ;

M: self-close-tag write-html
    {
        [ "<" % name>> % ]
        [ props>> write-props "/>" % ]
    } cleave ;

M: comment write-html
    [ open>> % ]
    [ payload>> % ]
    [ close>> % ] tri ;

M: string write-html % ;

: html>string ( sequence -- string )
    [ [ write-html ] each ] "" make ;
