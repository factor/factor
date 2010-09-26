! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs namespaces make kernel sequences accessors
combinators strings splitting io io.streams.string present
xml.writer xml.data xml.entities html.forms
html.templates html.templates.chloe.syntax ;
IN: html.templates.chloe.compiler

: chloe-attrs-only ( assoc -- assoc' )
    [ drop chloe-name? ] assoc-filter ;

: non-chloe-attrs-only ( assoc -- assoc' )
    [ drop chloe-name? not ] assoc-filter ;

: chloe-tag? ( tag -- ? )
    dup xml? [ body>> ] when
    {
        { [ dup tag? not ] [ f ] }
        { [ dup chloe-name? not ] [ f ] }
        [ t ]
    } cond nip ;

SYMBOL: string-buffer

SYMBOL: tag-stack

DEFER: compile-element

: compile-children ( tag -- )
    [ compile-element ] each ;

: [write] ( string -- ) string-buffer get push-all ;

: reset-buffer ( -- )
    string-buffer get [
        [ >string , \ write , ] [ delete-all ] bi
    ] unless-empty ;

: [code] ( quot -- )
    reset-buffer % ;

: [code-with] ( obj quot -- )
    reset-buffer [ , ] [ % ] bi* ;

: [xml-code] ( quot -- )
    [ write-xml ] compose [code] ;

: expand-attr ( value -- )
    [ value present write ] [code-with] ;

: compile-attr ( value -- )
    reset-buffer "@" ?head [ , [ value present ] % ] [ , ] if ;

: compile-attrs ( assoc -- )
    [
        " " [write]
        swap name>string [write]
        "=\"" [write]
        "@" ?head [ expand-attr ] [ escape-quoted-string [write] ] if
        "\"" [write]
    ] assoc-each ;

: compile-start-tag ( tag -- )
    "<" [write]
    [ name>string [write] ] [ attrs>> compile-attrs ] bi
    ">" [write] ;

: compile-end-tag ( tag -- )
    "</" [write]
    name>string [write]
    ">" [write] ;

SYMBOL: string-context?

ERROR: tag-not-allowed-here ;

: check-tag ( -- )
    string-context? get [ tag-not-allowed-here ] when ;

: compile-tag ( tag -- )
    check-tag
    {
        [ main>> tag-stack get push ]
        [ compile-start-tag ]
        [ compile-children ]
        [ compile-end-tag ]
    } cleave
    tag-stack get pop* ;

ERROR: unknown-chloe-tag tag ;

: compile-chloe-tag ( tag -- )
    dup main>> dup tags get at
    [ call( tag -- ) ]
    [ unknown-chloe-tag ]
    ?if ;

: compile-string ( string -- )
    string-context? get [ escape-string ] unless [write] ;

: compile-misc ( object -- )
    check-tag
    [ write-xml ] [code-with] ;

: compile-element ( element -- )
    {
        { [ dup chloe-tag? ] [ compile-chloe-tag ] }
        { [ dup [ tag? ] [ xml? ] bi or ] [ compile-tag ] }
        { [ dup string? ] [ compile-string ] }
        { [ dup comment? ] [ drop ] }
        [ compile-misc ]
    } cond ;

: with-compiler ( quot -- quot' )
    [
        SBUF" " string-buffer set
        V{ } clone tag-stack set
        call
        reset-buffer
    ] [ ] make ; inline

: compile-chunk ( seq -- )
    [ compile-element ] each ;

: compile-quot ( quot -- )
    reset-buffer
    [
        SBUF" " string-buffer set
        call
        reset-buffer
    ] [ ] make , ; inline

: process-children ( tag quot -- )
    [ [ compile-children ] compile-quot ] [ % ] bi* ; inline

: compile-children>xml-string ( tag -- )
    [ with-string-writer ] process-children ;

: compile-children>string ( tag -- )
    t string-context? [
        compile-children>xml-string
    ] with-variable ;

: compile-with-scope ( quot -- )
    compile-quot [ with-scope ] [code] ; inline

: if-not-nested ( quot -- )
    nested-template? get swap unless ; inline

: compile-prologue ( xml -- )
    [
        [ prolog>> [ write-xml ] [code-with] ]
        [ before>> compile-chunk ]
        bi
    ] compile-quot
    [ if-not-nested ] [code] ;

: compile-epilogue ( xml -- )
    [ after>> compile-chunk ] compile-quot
    [ if-not-nested ] [code] ;

: compile-template ( xml -- quot )
    [
        [ compile-prologue ]
        [ compile-element ]
        [ compile-epilogue ]
        tri
    ] with-compiler ;
