! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel combinators assocs
namespaces sequences splitting words
fry urls multiline present
xml
xml.data
xml.entities
xml.writer
xml.traversal
xml.syntax
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
furnace.utilities ;
IN: furnace.chloe-tags

! Chloe tags
: parse-query-attr ( string -- assoc )
    [ f ] [ "," split [ dup value ] H{ } map>assoc ] if-empty ;

: a-url-path ( href rest -- string )
    dup [ value ] when
    [ [ "/" ?tail drop "/" ] dip present 3append ] when* ;

: a-url ( href rest query value-name -- url )
    dup [ [ 3drop ] dip value ] [
        drop
        <url>
            swap parse-query-attr >>query
            -rot a-url-path >>path
        adjust-url
    ] if ;

: compile-a-url ( tag -- )
    {
        [ "href" optional-attr compile-attr ]
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
    '[ [ [ _ ] dip link-attr ] each-responder ] [code] ;

: a-start-tag ( tag -- )
    [ <a ] [code]
    [ attrs>> non-chloe-attrs-only compile-attrs ]
    [ compile-link-attrs ]
    [ compile-a-url ]
    tri
    [ =href a> ] [code] ;

: process-attrs ( assoc -- newassoc )
    [ "@" ?head [ value present ] when ] assoc-map ;

: non-chloe-attrs ( tag -- )
    attrs>> non-chloe-attrs-only [ process-attrs ] [code-with] ;

: a-attrs ( tag -- )
    [ non-chloe-attrs ]
    [ compile-link-attrs ]
    [ compile-a-url ] tri
    [ swap "href" swap set-at ] [code] ;

CHLOE: a
    [ a-attrs ]
    [ compile-children>string ] bi
    [ <unescaped> [XML <a><-></a> XML] swap >>attrs ]
    [xml-code] ;

CHLOE: base
    compile-a-url [ [XML <base href=<->/> XML] ] [xml-code] ;

: compile-hidden-form-fields ( for -- )
    '[
        <div "display: none;" =style div>
            _ [ "," split [ hidden render ] each ] when*
            nested-forms get " " join f like nested-forms-key hidden-form-field
            [ modify-form ] each-responder
        </div>
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
    [
        {
            [ compile-link-attrs ]
            [ form-start-tag ]
            [ compile-children ]
            [ form-end-tag ]
        } cleave
    ] compile-with-scope ;

: button-tag-markup ( -- xml )
    <XML
        <t:form class="inline" xmlns:t="http://factorcode.org/chloe/1.0">
            <div style="display: inline;"><button type="submit"></button></div>
        </t:form>
    XML> body>> clone ;

: add-tag-attrs ( attrs tag -- )
    attrs>> swap update ;

CHLOE: button
    button-tag-markup
    {
        [ [ attrs>> chloe-attrs-only ] dip add-tag-attrs ]
        [ [ attrs>> non-chloe-attrs-only ] dip "button" deep-tag-named add-tag-attrs ]
        [ [ children>> ] dip "button" deep-tag-named (>>children) ]
        [ nip ]
    } 2cleave compile-chloe-tag ;
