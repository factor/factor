! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: furnace

GENERIC: hidden-form-field ( responder -- )

M: object hidden-form-field drop ;

: request-params ( request -- assoc )
    dup method>> {
        { "GET" [ url>> query>> ] }
        { "HEAD" [ url>> query>> ] }
        { "POST" [ post-data>> ] }
    } case ;

: <feed-content> ( body -- response )
    feed>xml "application/atom+xml" <content> ;

: <json-content> ( obj -- response )
    >json "application/json" <content> ;

SYMBOL: exit-continuation

: exit-with exit-continuation get continue-with ;

: with-exit-continuation ( quot -- )
    '[ exit-continuation set @ ] callcc1 exit-continuation off ;

! Chloe tags
: parse-query-attr ( string -- assoc )
    dup empty?
    [ drop f ] [ "," split [ dup value ] H{ } map>assoc ] if ;

CHLOE: atom
    [ "title" required-attr ]
    [ "href" required-attr ]
    [ "query" optional-attr parse-query-attr ] tri
    <url>
        swap >>query
        swap >>path
    adjust-url
    add-atom-feed ;

CHLOE: write-atom drop write-atom-feeds ;

GENERIC: link-attr ( tag responder -- )

M: object link-attr 2drop ;

: link-attrs ( tag -- )
    '[ , _ link-attr ] each-responder ;

: a-start-tag ( tag -- )
    [
        <a
            dup link-attrs
            dup "value" optional-attr [ value f ] [
                [ "href" required-attr ]
                [ "query" optional-attr parse-query-attr ]
                bi
            ] ?if
            <url>
                swap >>query
                swap >>path
            adjust-url =href
        a>
    ] with-scope ;

CHLOE: a
    [ a-start-tag ]
    [ process-tag-children ]
    [ drop </a> ]
    tri ;

: form-start-tag ( tag -- )
    [
        [
            <form
            "POST" =method
            [ link-attrs ]
            [ "action" required-attr resolve-base-path =action ]
            [ tag-attrs non-chloe-attrs-only print-attrs ]
            tri
            form>
        ] [
            [ hidden-form-field ] each-responder
            "for" optional-attr [ hidden render ] when*
        ] bi
    ] with-scope ;

CHLOE: form
    [ form-start-tag ]
    [ process-tag-children ]
    [ drop </form> ]
    tri ;

DEFER: process-chloe-tag

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

: attr>word ( value -- word/f )
    dup ":" split1 swap lookup
    [ ] [ "No such word: " swap append throw ] ?if ;

: attr>var ( value -- word/f )
    attr>word dup symbol? [
        "Must be a symbol: " swap append throw
    ] unless ;

: if-satisfied? ( tag -- ? )
    t swap
    {
        [ "code"  optional-attr [ attr>word execute and ] when* ]
        [  "var"  optional-attr [ attr>var      get and ] when* ]
        [ "svar"  optional-attr [ attr>var     sget and ] when* ]
        [ "uvar"  optional-attr [ attr>var     uget and ] when* ]
        [ "value" optional-attr [ value             and ] when* ]
    } cleave ;

CHLOE: if dup if-satisfied? [ process-tag-children ] [ drop ] if ;
