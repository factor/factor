! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel combinators assocs
namespaces sequences splitting words
fry urls multiline present qualified
xml
xml.data
xml.entities
xml.writer
xml.utilities
html.components
html.elements
html.forms
html.templates
html.templates.chloe
html.templates.chloe.compiler
html.templates.chloe.syntax
http
http.server
http.server.redirection
http.server.responses
furnace ;
QUALIFIED-WITH: assocs a
IN: furnace.chloe-tags

! Chloe tags
: parse-query-attr ( string -- assoc )
    [ f ] [ "," split [ dup value ] H{ } map>assoc ] if-empty ;

: a-url-path ( href rest -- string )
    dup [ value ] when
    [ [ "/" ?tail drop "/" ] dip present 3append ] when* ;

: a-url ( href rest query value-name -- url )
    dup [ >r 3drop r> value ] [
        drop
        <url>
            swap parse-query-attr >>query
            -rot a-url-path >>path
        adjust-url relative-to-request
    ] if ;

: compile-a-url ( tag -- )
    {
        [ "href" required-attr compile-attr ]
        [ "rest" optional-attr compile-attr ]
        [ "query" optional-attr compile-attr ]
        [ "value" optional-attr compile-attr ]
    } cleave [ a-url ] [code] ;

CHLOE: atom
    [ compile-children>string ] [ compile-a-url ] bi
    [ add-atom-feed ] [code] ;

CHLOE: write-atom drop [ write-atom-feeds ] [code] ;

: compile-link-attrs ( tag -- )
    #! Side-effects current namespace.
    attrs>> '[ [ , _ link-attr ] each-responder ] [code] ;

: a-start-tag ( tag -- )
    [ compile-link-attrs ] [ compile-a-url ] bi
    [ <a =href a> ] [code] ;

: a-end-tag ( tag -- )
    drop [ </a> ] [code] ;

CHLOE: a [ a-start-tag ] [ compile-children ] [ a-end-tag ] tri ;

: compile-hidden-form-fields ( for -- )
    '[
        , [ "," split [ hidden render ] each ] when*
        nested-forms get " " join f like nested-forms-key hidden-form-field
        [ modify-form ] each-responder
    ] [code] ;

: compile-form-attrs ( method action attrs -- )
    [ <form ] [code]
    [ compile-attr [ =method ] [code] ]
    [ compile-attr [ resolve-base-path =action ] [code] ]
    [ compile-attrs ]
    tri*
    [ form> ] [code] ;

: form-start-tag ( tag -- )
    [
        [ "method" optional-attr "post" or ]
        [ "action" required-attr ]
        [ attrs>> non-chloe-attrs-only ] tri
        compile-form-attrs
    ]
    [ "for" optional-attr compile-hidden-form-fields ] bi ;

: form-end-tag ( tag -- )
    drop [ </form> ] [code] ;

CHLOE: form
    {
        [ compile-link-attrs ]
        [ form-start-tag ]
        [ compile-children ]
        [ form-end-tag ]
    } cleave ;

STRING: button-tag-markup
<t:form class="inline" xmlns:t="http://factorcode.org/chloe/1.0">
    <button type="submit"></button>
</t:form>
;

: add-tag-attrs ( attrs tag -- )
    attrs>> swap update ;

CHLOE: button
    button-tag-markup string>xml body>>
    {
        [ [ attrs>> chloe-attrs-only ] dip add-tag-attrs ]
        [ [ attrs>> non-chloe-attrs-only ] dip "button" tag-named add-tag-attrs ]
        [ [ children>> ] dip "button" tag-named (>>children) ]
        [ nip ]
    } 2cleave compile-chloe-tag ;
