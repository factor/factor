USING: accessors kernel sequences combinators kernel namespaces
classes.tuple assocs splitting words arrays
io io.files io.encodings.utf8 html.elements unicode.case
tuple-syntax xml xml.data xml.writer xml.utilities
http.server
http.server.auth
http.server.components
http.server.sessions
http.server.templating
http.server.boilerplate ;
IN: http.server.templating.chloe

! Chloe is Ed's favorite web designer

TUPLE: chloe path ;

C: <chloe> chloe

DEFER: process-template

: chloe-ns TUPLE{ name url: "http://factorcode.org/chloe/1.0" } ;

: chloe-tag? ( tag -- ? )
    {
        { [ dup tag? not ] [ f ] }
        { [ dup chloe-ns names-match? not ] [ f ] }
        [ t ]
    } cond nip ;

SYMBOL: tags

: required-attr ( tag name -- value )
    dup rot at*
    [ nip ] [ drop " attribute is required" append throw ] if ;

: optional-attr ( tag name -- value )
    swap at ;

: write-title-tag ( tag -- )
    drop
    "head" tags get member? "title" tags get member? not and
    [ <title> write-title </title> ] [ write-title ] if ;

: style-tag ( tag -- )
    dup "include" optional-attr dup [
        swap children>string empty? [
            "style tag cannot have both an include attribute and a body" throw
        ] unless
        utf8 file-contents
    ] [
        drop children>string
    ] if add-style ;

: write-style-tag ( tag -- )
    drop <style> write-style </style> ;

: atom-tag ( tag -- )
    [ "title" required-attr ]
    [ "href" required-attr ]
    bi set-atom-feed ;

: write-atom-tag ( tag -- )
    drop
    "head" tags get member? [
        write-atom-feed
    ] [
        atom-feed get value>> second write
    ] if ;

: component-attr ( tag -- name )
    "component" required-attr ;

: view-tag ( tag -- )
    component-attr component render-view ;

: edit-tag ( tag -- )
    component-attr component render-edit ;

: summary-tag ( tag -- )
    component-attr component render-summary ;

: parse-query-attr ( string -- assoc )
    dup empty?
    [ drop f ] [ "," split [ dup value ] H{ } map>assoc ] if ;

: a-start-tag ( tag -- )
    <a
    dup "value" optional-attr [ value f ] [
        [ "href" required-attr ]
        [ "query" optional-attr parse-query-attr ]
        bi
    ] ?if link>string =href
    a> ;

: process-tag-children ( tag -- )
    [ process-template ] each ;

: a-tag ( tag -- )
    [ a-start-tag ]
    [ process-tag-children ]
    [ drop </a> ]
    tri ;

: form-start-tag ( tag -- )
    <form
    "POST" =method
    tag-attrs print-attrs
    form>
    hidden-form-field ;

: form-tag ( tag -- )
    [ form-start-tag ]
    [ process-tag-children ]
    [ drop </form> ]
    tri ;

: attr>word ( value -- word/f )
    dup ":" split1 swap lookup
    [ ] [ "No such word: " swap append throw ] ?if ;

: attr>var ( value -- word/f )
    attr>word dup symbol? [
        "Must be a symbol: " swap append throw
    ] unless ;

: if-satisfied? ( tag -- ? )
    {
        [ "code" optional-attr [ attr>word execute ] [ t ] if* ]
        [  "var" optional-attr [ attr>var      get ] [ t ] if* ]
        [ "svar" optional-attr [ attr>var     sget ] [ t ] if* ]
        [ "uvar" optional-attr [ attr>var     uget ] [ t ] if* ]
    } cleave 4array [ ] all? ;

: if-tag ( tag -- )
    dup if-satisfied? [ process-tag-children ] [ drop ] if ;

: error-tag ( tag -- )
    children>string render-error ;

: process-chloe-tag ( tag -- )
    dup name-tag {
        { "chloe" [ [ process-template ] each ] }
        { "title" [ children>string set-title ] }
        { "write-title" [ write-title-tag ] }
        { "style" [ style-tag ] }
        { "write-style" [ write-style-tag ] }
        { "atom" [ atom-tag ] }
        { "write-atom" [ write-atom-tag ] }
        { "view" [ view-tag ] }
        { "edit" [ edit-tag ] }
        { "summary" [ summary-tag ] }
        { "a" [ a-tag ] }
        { "form" [ form-tag ] }
        { "error" [ error-tag ] }
        { "if" [ if-tag ] }
        { "comment" [ drop ] }
        { "call-next-template" [ drop call-next-template ] }
        [ "Unknown chloe tag: " swap append throw ]
    } case ;

: process-tag ( tag -- )
    {
        [ name-tag >lower tags get push ]
        [ write-start-tag ]
        [ process-tag-children ]
        [ write-end-tag ]
        [ drop tags get pop* ]
    } cleave ;

: process-template ( xml -- )
    {
        { [ dup [ chloe-tag? ] is? ] [ process-chloe-tag ] }
        { [ dup [ tag? ] is? ] [ process-tag ] }
        { [ t ] [ write-item ] }
    } cond ;

: process-chloe ( xml -- )
    [
        V{ } clone tags set

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
    path>> utf8 <file-reader> read-xml process-chloe ;

INSTANCE: chloe template
