USING: http.server help.markup help.syntax kernel prettyprint
sequences parser namespaces words classes math tuples.private
quotations arrays strings ;

IN: furnace

TUPLE: furnace-model model ;
C: <furnace-model> furnace-model

HELP: furnace-model "This definition exists to circumvent a limitation in furnace with regard to sending arbitrary objects as models to .furnace templates." ;

: crud-create ( class string -- word )
    swap unparse "-" rot 3append in get create ;

HELP: crud-create
{ $values { "class" class } { "string" string } { "word" word } }
{ $description "A CRUD utility function - creates a new action word for a given class and suffix string" } ;

: crud-word ( class string -- word )
    swap unparse "-" rot 3append parse first ;
HELP: crud-word
{ $values { "class" class } { "string" string } { "word" word } }
{ $description "A CRUD utility function - looks up a word that has been crud-created" } ;

: crud-index ( tuple -- )
    dup class dup "crud-index" word-prop crud-word execute ;

: crud-lookup ( string class -- obj )
    get-global [ crud-index = ] curry* subset
    dup empty? [ drop f ] [ first ] if ;
HELP: crud-lookup
{ $values { "string" string } { "class" class } { "obj" object } }
{ $description "A CRUD utility function - looks up an object in the store by the pre-designated index." } ;

: crud-lookup* ( string class -- tuple )
    tuck crud-lookup
    [ ] [ dup "slot-names" word-prop length 2 + <tuple> ] ?if ;

HELP: crud-lookup*
{ $values { "string" string } { "class" class } { "tuple" tuple } }
"A CRUD utility function - same as crud-lookup, but always returns a tuple of the given class.  When the lookup fails, returns a tuple of the given class with all slots set to f." ;

: crud-page ( model template title -- )
    [ "libs/furnace/crud-templates" template-path set render-page ]
    with-scope ;

: define-list ( class -- word )
    dup "list" crud-create swap
    [ dup get-global dup empty? -rot ? <furnace-model> "list" "List" crud-page ]
    curry dupd define-compound ;

: define-show ( class -- word )
    dup "show" crud-create swap
    [ crud-lookup <furnace-model> "show" "Show" crud-page ] 
    curry dupd define-compound ;

: define-edit ( class -- word )
    dup "edit" crud-create swap
    [ crud-lookup* <furnace-model> "edit" "Edit" crud-page ] 
    curry dupd define-compound ;
    
: define-new ( class -- word )
    dup "new" crud-create swap "edit" crud-word
    [ f swap execute ]
    curry dupd define-compound ;
    
: define-update ( class -- word )
    dup "update" crud-create swap
    [ 
        tuck crud-lookup [ over get-global remove over set-global ] when* 
        dup >r "constructor" word-prop execute
        r> 2dup get-global swap add over set-global swap
        crud-index swap "show" crud-word execute
    ] curry dupd define-compound ;

: define-delete ( class -- word )
    dup "delete" crud-create swap
    [ 
        tuck crud-lookup [ over get-global remove over set-global ] when* 
        "list" crud-word execute
    ] curry dupd define-compound ;

: define-lookup ( class -- )
    dup "crud-index" word-prop ">" pick unparse 3append in get create
    swap [ crud-lookup ] curry define-compound ;

: define-lookup* ( class -- )
    dup "crud-index" word-prop ">" pick unparse "*" append 3append 
    in get create swap [ crud-lookup* ] curry define-compound ;

: scaffold-params ( class -- array )
    "crud-index" word-prop 1array 1array ;

: scaffold ( class index realm -- )
    -rot dupd "crud-index" set-word-prop
    [ define-lookup ] keep [ define-lookup* ] keep
    [ get-global [ { } over set-global ] unless ] keep
    [ define-list { } rot define-authenticated-action ] 2keep
    [ dup define-show swap scaffold-params rot 
        define-authenticated-action ] 2keep
    [ dup define-edit swap scaffold-params rot
        define-authenticated-action ] 2keep
    [ define-new { } rot define-authenticated-action ] 2keep
    [ dup define-update swap "slot-names" word-prop 
        "crud-index" add [ 1array ] map rot 
        define-authenticated-action ] 2keep
    dup define-delete swap scaffold-params rot
    define-authenticated-action ;

HELP: scaffold
{ $values { "class" class } { "index" "an index" } { "realm" "a realm" } }
"If realm is not f, then realm is used as the basic authentication realm for the scaffolding actions." ;

ARTICLE: { "furnace" "crud" } "CRUD Scaffolding"
{ $code 
    "\"libs/furnace\" require"
    "USING: furnace httpd threads ;"
    "IN: furnace:crud-example"
    "TUPLE: foo bar baz ;"
    "\"crud-example\" \"foo-list\" f web-app"
    "foo \"bar\" f scaffold"
    "[ 8888 httpd ] in-thread"
} ;