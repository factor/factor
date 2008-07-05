! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences combinators kernel namespaces
classes.tuple assocs splitting words arrays memoize
io io.files io.encodings.utf8 io.streams.string
unicode.case tuple-syntax mirrors fry math urls present
multiline xml xml.data xml.writer xml.utilities
html.forms
html.elements
html.components
html.templates
html.templates.chloe.syntax ;
IN: html.templates.chloe

! Chloe is Ed's favorite web designer
SYMBOL: tag-stack

TUPLE: chloe path ;

C: <chloe> chloe

DEFER: process-template

: chloe-attrs-only ( assoc -- assoc' )
    [ drop name-url chloe-ns = ] assoc-filter ;

: non-chloe-attrs-only ( assoc -- assoc' )
    [ drop name-url chloe-ns = not ] assoc-filter ;

: chloe-tag? ( tag -- ? )
    {
        { [ dup tag? not ] [ f ] }
        { [ dup url>> chloe-ns = not ] [ f ] }
        [ t ]
    } cond nip ;

: process-tag-children ( tag -- )
    [ process-template ] each ;

CHLOE: chloe process-tag-children ;

: children>string ( tag -- string )
    [ process-tag-children ] with-string-writer ;

CHLOE: title children>string set-title ;

CHLOE: write-title
    drop
    "head" tag-stack get member?
    "title" tag-stack get member? not and
    [ <title> write-title </title> ] [ write-title ] if ;

CHLOE: style
    dup "include" optional-attr dup [
        swap children>string empty? [
            "style tag cannot have both an include attribute and a body" throw
        ] unless
        utf8 file-contents
    ] [
        drop children>string
    ] if add-style ;

CHLOE: write-style
    drop <style> write-style </style> ;

CHLOE: even "index" value even? [ process-tag-children ] [ drop ] if ;

CHLOE: odd "index" value odd? [ process-tag-children ] [ drop ] if ;

: (bind-tag) ( tag quot -- )
    [
        [ "name" required-attr ] keep
        '[ , process-tag-children ]
    ] dip call ; inline

CHLOE: each [ with-each-value ] (bind-tag) ;

CHLOE: bind-each [ with-each-object ] (bind-tag) ;

CHLOE: bind [ with-form ] (bind-tag) ;

: error-message-tag ( tag -- )
    children>string render-error ;

CHLOE: comment drop ;

CHLOE: call-next-template drop call-next-template ;

: attr>word ( value -- word/f )
    ":" split1 swap lookup ;

: if-satisfied? ( tag -- ? )
    [ "code" optional-attr [ attr>word dup [ execute ] when ] [ t ] if* ]
    [ "value" optional-attr [ value ] [ t ] if* ]
    bi and ;

CHLOE: if dup if-satisfied? [ process-tag-children ] [ drop ] if ;

CHLOE-SINGLETON: label
CHLOE-SINGLETON: link
CHLOE-SINGLETON: inspector
CHLOE-SINGLETON: comparison
CHLOE-SINGLETON: html
CHLOE-SINGLETON: hidden

CHLOE-TUPLE: farkup
CHLOE-TUPLE: field
CHLOE-TUPLE: textarea
CHLOE-TUPLE: password
CHLOE-TUPLE: choice
CHLOE-TUPLE: checkbox
CHLOE-TUPLE: code

: process-chloe-tag ( tag -- )
    dup name-tag dup tags get at
    [ call ] [ "Unknown chloe tag: " prepend throw ] ?if ;

: process-tag ( tag -- )
    {
        [ name-tag >lower tag-stack get push ]
        [ write-start-tag ]
        [ process-tag-children ]
        [ write-end-tag ]
        [ drop tag-stack get pop* ]
    } cleave ;

: expand-attrs ( tag -- tag )
    dup [ tag? ] is? [
        clone [
            [ "@" ?head [ value present ] when ] assoc-map
        ] change-attrs
    ] when ;

: process-template ( xml -- )
    expand-attrs
    {
        { [ dup [ chloe-tag? ] is? ] [ process-chloe-tag ] }
        { [ dup [ tag? ] is? ] [ process-tag ] }
        { [ t ] [ write-item ] }
    } cond ;

: process-chloe ( xml -- )
    [
        V{ } clone tag-stack set

        nested-template? get [
            process-template
        ] [
            {
                [ xml-prolog write-prolog ]
                [ xml-before write-chunk  ]
                [ process-template        ]
                [ xml-after write-chunk   ]
            } cleave
        ] if
    ] with-scope ;

M: chloe call-template*
    path>> ".xml" append utf8 <file-reader> read-xml process-chloe ;

INSTANCE: chloe template
