! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs namespaces kernel sequences accessors combinators
strings splitting io io.streams.string xml.writer xml.data
xml.entities html.forms html.templates.chloe.syntax ;
IN: html.templates.chloe.compiler

: chloe-attrs-only ( assoc -- assoc' )
    [ drop url>> chloe-ns = ] assoc-filter ;

: non-chloe-attrs-only ( assoc -- assoc' )
    [ drop url>> chloe-ns = not ] assoc-filter ;

: chloe-tag? ( tag -- ? )
    dup xml? [ body>> ] when
    {
        { [ dup tag? not ] [ f ] }
        { [ dup url>> chloe-ns = not ] [ f ] }
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

: expand-attr ( value -- )
    [ value write ] [code-with] ;

: compile-attr ( value -- )
    reset-buffer "@" ?head [ , \ value ] when , ;

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
    [ name>string [write] ] [ compile-attrs ] bi
    ">" [write] ;

: compile-end-tag ( tag -- )
    "</" [write]
    name>string [write]
    ">" [write] ;

: compile-tag ( tag -- )
    {
        [ main>> tag-stack get push ]
        [ compile-start-tag ]
        [ compile-children ]
        [ compile-end-tag ]
        [ drop tag-stack get pop* ]
    } cleave ;

: compile-chloe-tag ( tag -- )
    ! "Unknown chloe tag: " prepend throw
    dup main>> dup tags get at
    [ curry assert-depth ] [ 2drop ] ?if ;

: compile-element ( element -- )
    {
        { [ dup chloe-tag? ] [ compile-chloe-tag ] }
        { [ dup [ tag? ] [ xml? ] bi or ] [ compile-tag ] }
        { [ dup string? ] [ escape-string [write] ] }
        { [ dup comment? ] [ drop ] }
        [ [ write-item ] [code-with] ]
    } cond ;

: with-compiler ( quot -- quot' )
    [
        SBUF" " string-buffer set
        V{ } clone tag-stack set
        call
        reset-buffer
    ] [ ] make ; inline

: compile-nested-template ( xml -- quot )
    [ compile-element ] with-compiler ;

: compile-chunk ( seq -- )
    [ compile-element ] each ;

: process-children ( tag quot -- )
    reset-buffer
    [
        [
            SBUF" " string-buffer set
            compile-children
            reset-buffer
        ] [ ] make ,
    ] [ % ] bi* ;

: compile-children>string ( tag -- )
     [ with-string-writer ] process-children ;

: compile-template ( xml -- quot )
    [
        {
            [ prolog>> [ write-prolog ] [code-with] ]
            [ before>> compile-chunk ]
            [ compile-element ]
            [ after>> compile-chunk ]
        } cleave
    ] with-compiler ;
