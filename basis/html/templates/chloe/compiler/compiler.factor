! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors ascii assocs combinators html.forms
html.templates html.templates.chloe.syntax io io.streams.string
kernel make namespaces present sequences splitting strings
xml.data xml.entities xml.writer ;
IN: html.templates.chloe.compiler

: chloe-attrs-only ( assoc -- assoc' )
    [ chloe-name? ] filter-keys ;

: non-chloe-attrs-only ( assoc -- assoc' )
    [ chloe-name? ] reject-keys ;

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

: compile-self-closing-tag ( tag -- )
    "<" [write]
    [ name>string [write] ] [ attrs>> compile-attrs ] bi
    " />" [write] ;

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

CONSTANT: self-closing-tags {
        "area"
        "base"
        "br"
        "embed"
        "hr"
        "iframe"
        "img"
        "input"
        "link"
        "meta"
        "param"
        "source"
        "track"
    }

: check-tag ( -- )
    string-context? get [ tag-not-allowed-here ] when ;

: (compile-tag) ( tag -- )
    dup name>string >lower self-closing-tags
    member? [
        compile-self-closing-tag
    ] [
        [ compile-start-tag ]
        [ compile-children ]
        [ compile-end-tag ] tri
    ] if ;

: compile-tag ( tag -- )
    check-tag
    [ main>> tag-stack get push ]
    [ (compile-tag) ] bi
    tag-stack get pop* ;

ERROR: unknown-chloe-tag tag ;

: compile-chloe-tag ( tag -- )
    dup main>>
    [ chloe-tags get at ]
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
        SBUF" " clone string-buffer namespaces:set
        V{ } clone tag-stack namespaces:set
        call
        reset-buffer
    ] [ ] make ; inline

: compile-chunk ( seq -- )
    [ compile-element ] each ;

: compile-quot ( quot -- )
    reset-buffer
    [
        SBUF" " clone string-buffer namespaces:set
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
    [ before>> compile-chunk ] compile-quot
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
