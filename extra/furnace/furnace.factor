! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel combinators assocs
continuations namespaces sequences splitting words
vocabs.loader classes strings
fry urls multiline present
xml
xml.data
xml.entities
xml.writer
html.components
html.elements
html.forms
html.templates
html.templates.chloe
html.templates.chloe.syntax
http
http.server
http.server.redirection
http.server.responses
qualified ;
QUALIFIED-WITH: assocs a
EXCLUDE: xml.utilities => children>string ;
IN: furnace

: nested-responders ( -- seq )
    responder-nesting get a:values ;

: each-responder ( quot -- )
   nested-responders swap each ; inline

: base-path ( string -- pair )
    dup responder-nesting get
    [ second class superclasses [ word-name = ] with contains? ] with find nip
    [ first ] [ "No such responder: " swap append throw ] ?if ;

: resolve-base-path ( string -- string' )
    "$" ?head [
        [
            "/" split1 [ base-path [  "/" % % ] each "/" % ] dip %
        ] "" make
    ] when ;

: vocab-path ( vocab -- path )
    dup vocab-dir vocab-append-path ;

: resolve-template-path ( pair -- path )
    [
        first2 [ word-vocabulary vocab-path % ] [ "/" % % ] bi*
    ] "" make ;

GENERIC: modify-query ( query responder -- query' )

M: object modify-query drop ;

GENERIC: adjust-url ( url -- url' )

M: url adjust-url
    clone
        [ [ modify-query ] each-responder ] change-query
        [ resolve-base-path ] change-path
    relative-to-request ;

M: string adjust-url ;

: <redirect> ( url -- response )
    adjust-url request get method>> {
        { "GET" [ <temporary-redirect> ] }
        { "HEAD" [ <temporary-redirect> ] }
        { "POST" [ <permanent-redirect> ] }
    } case ;

GENERIC: modify-form ( responder -- )

M: object modify-form drop ;

: request-params ( request -- assoc )
    dup method>> {
        { "GET" [ url>> query>> ] }
        { "HEAD" [ url>> query>> ] }
        { "POST" [
            post-data>>
            dup content-type>> "application/x-www-form-urlencoded" =
            [ content>> ] [ drop f ] if
        ] }
    } case ;

: referrer ( -- referrer )
    #! Typo is intentional, its in the HTTP spec!
    "referer" request get header>> at >url ;

: user-agent ( -- user-agent )
    "user-agent" request get header>> at "" or ;

: same-host? ( url -- ? )
    request get url>>
    [ [ protocol>> ] [ host>> ] [ port>> ] tri 3array ] bi@ = ;

SYMBOL: exit-continuation

: exit-with ( value -- )
    exit-continuation get continue-with ;

: with-exit-continuation ( quot -- )
    '[ exit-continuation set @ ] callcc1 exit-continuation off ;

! Chloe tags
: parse-query-attr ( string -- assoc )
    dup empty?
    [ drop f ] [ "," split [ dup value ] H{ } map>assoc ] if ;

: a-url-path ( tag -- string )
    [ "href" required-attr ]
    [ "rest" optional-attr dup [ value ] when ] bi
    [ [ "/" ?tail drop "/" ] dip present 3append ] when* ;

: a-url ( tag -- url )
    dup "value" optional-attr
    [ value ] [
        <url>
            swap
            [ a-url-path >>path ]
            [ "query" optional-attr parse-query-attr >>query ]
            bi
        adjust-url relative-to-request
    ] ?if ;

CHLOE: atom [ children>string ] [ a-url ] bi add-atom-feed ;

CHLOE: write-atom drop write-atom-feeds ;

GENERIC: link-attr ( tag responder -- )

M: object link-attr 2drop ;

: link-attrs ( tag -- )
    #! Side-effects current namespace.
    '[ , _ link-attr ] each-responder ;

: a-start-tag ( tag -- )
    [ <a [ link-attrs ] [ a-url =href ] bi a> ] with-scope ;

CHLOE: a
    [ a-start-tag ]
    [ process-tag-children ]
    [ drop </a> ]
    tri ;

: hidden-form-field ( value name -- )
    over [
        <input
            "hidden" =type
            =name
            present =value
        input/>
    ] [ 2drop ] if ;

: nested-forms-key "__n" ;

: form-magic ( tag -- )
    [ modify-form ] each-responder
    nested-forms get " " join f like nested-forms-key hidden-form-field
    "for" optional-attr [ "," split [ hidden render ] each ] when* ;

: form-start-tag ( tag -- )
    [
        [
            <form
                {
                    [ link-attrs ]
                    [ "method" optional-attr "post" or =method ]
                    [ "action" required-attr resolve-base-path =action ]
                    [ tag-attrs non-chloe-attrs-only print-attrs ]
                } cleave
            form>
        ]
        [ form-magic ] bi
    ] with-scope ;

CHLOE: form
    [ form-start-tag ]
    [ process-tag-children ]
    [ drop </form> ]
    tri ;

STRING: button-tag-markup
<t:form class="inline" xmlns:t="http://factorcode.org/chloe/1.0">
    <button type="submit"></button>
</t:form>
;

: add-tag-attrs ( attrs tag -- )
    tag-attrs swap update ;

CHLOE: button
    button-tag-markup string>xml delegate
    {
        [ [ tag-attrs chloe-attrs-only ] dip add-tag-attrs ]
        [ [ tag-attrs non-chloe-attrs-only ] dip "button" tag-named add-tag-attrs ]
        [ [ children>string 1array ] dip "button" tag-named set-tag-children ]
        [ nip ]
    } 2cleave process-chloe-tag ;
