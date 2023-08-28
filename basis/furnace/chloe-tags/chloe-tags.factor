! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators furnace.utilities
html.components html.forms html.templates
html.templates.chloe.compiler html.templates.chloe.syntax kernel
namespaces present sequences splitting urls xml.data xml.syntax
xml.traversal xml.writer ;
IN: furnace.chloe-tags

! Chloe tags
: parse-query-attr ( string -- assoc )
    [ f ] [ "," split [ dup value ] H{ } map>assoc ] if-empty ;

: a-url-path ( href rest -- string )
    dup [ value ] when
    [ [ "/" ?tail drop "/" ] dip present 3append ] when* ;

: a-url ( href rest query value-name -- url )
    dup [ 3nip value ] [
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
    [ compile-children>xml-string ] [ compile-a-url ] bi
    [ add-atom-feed ] [code] ;

CHLOE: write-atom drop [ write-atom-feeds ] [code] ;

: compile-link-attrs ( tag -- )
    ! Side-effects current namespace.
    '[ [ [ _ ] dip link-attr ] each-responder ] [code] ;

: process-attrs ( assoc -- newassoc )
    [ "@" ?head [ value present ] when ] assoc-map ;

: non-chloe-attrs ( tag -- )
    attrs>> non-chloe-attrs-only [ process-attrs ] [code-with] ;

: a-attrs ( tag -- )
    [ non-chloe-attrs ]
    [ compile-link-attrs ]
    [ compile-a-url ] tri
    [ present swap "href" swap [ set-at ] keep ] [code] ;

CHLOE: a
    [
        [ a-attrs ]
        [ compile-children>xml-string ] bi
        [ <unescaped> [XML <a><-></a> XML] second swap >>attrs ]
        [xml-code]
    ] compile-with-scope ;

CHLOE: base
    compile-a-url [ [XML <base href=<->/> XML] ] [xml-code] ;

: hidden-nested-fields ( -- xml )
    nested-forms get join-words f like nested-forms-key
    hidden-form-field ;

: render-hidden ( for -- xml )
    [ "," split [ hidden render>xml ] map ] [ f ] if* ;

: compile-hidden-form-fields ( for -- )
    '[
        _ render-hidden
        hidden-nested-fields
        form-modifications
        [XML <div style="display: none;"><-><-><-></div> XML]
    ] [code] ;

: (compile-form-attrs) ( method action -- )
    ! Leaves an assoc on the stack at runtime
    [ compile-attr [ "method" pick set-at ] [code] ]
    [ compile-attr [ resolve-base-path "action" pick set-at ] [code] ]
    bi* ;

: compile-method/action ( tag -- )
    ! generated code is ( assoc -- assoc )
    [ "method" optional-attr "post" or ]
    [ "action" required-attr ] bi
    (compile-form-attrs) ;

: compile-form-attrs ( tag -- )
    [ non-chloe-attrs ]
    [ compile-link-attrs ]
    [ compile-method/action ] tri ;

: hidden-fields ( tag -- )
    "for" optional-attr compile-hidden-form-fields ;

CHLOE: form
    [
        [ compile-form-attrs ]
        [ hidden-fields ]
        [ compile-children>xml-string ] tri
        [
            <unescaped> [XML <form><-><-></form> XML] second
                swap >>attrs
            write-xml
        ] [code]
    ] compile-with-scope ;

: button-tag-markup ( -- xml )
    <XML
        <t:form class="inline" xmlns:t="http://factorcode.org/chloe/1.0">
            <div style="display: inline;"><button type="submit"></button></div>
        </t:form>
    XML> body>> clone ;

: add-tag-attrs ( attrs tag -- )
    attrs>> swap assoc-union! drop ;

CHLOE: button
    button-tag-markup
    {
        [ [ attrs>> chloe-attrs-only ] dip add-tag-attrs ]
        [ [ attrs>> non-chloe-attrs-only ] dip "button" deep-tag-named add-tag-attrs ]
        [ [ children>> ] dip "button" deep-tag-named children<< ]
        [ nip ]
    } 2cleave compile-chloe-tag ;
