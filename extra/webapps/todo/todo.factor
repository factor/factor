! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel locals sequences namespaces
db db.types db.tuples
http.server.components http.server.components.farkup
http.server.forms http.server.templating.chloe
http.server.boilerplate http.server.crud http.server.auth
http.server.actions http.server.db
http.server.auth.login
http.server ;
IN: webapps.todo

TUPLE: todo uid id priority summary description ;

todo "TODO"
{
    { "uid" "UID" { VARCHAR 256 } +not-null+ }
    { "id" "ID" +db-assigned-id+ }
    { "priority" "PRIORITY" INTEGER +not-null+ }
    { "summary" "SUMMARY" { VARCHAR 256 } +not-null+ }
    { "description" "DESCRIPTION" { VARCHAR 256 } }
} define-persistent

: init-todo-table todo ensure-table ;

: <todo> ( id -- todo )
    todo new
        swap >>id
        uid >>uid ;

: todo-template ( name -- template )
    "resource:extra/webapps/todo/" swap ".xml" 3append <chloe> ;

: <todo-form> ( -- form )
    "todo" <form>
        "view-todo" todo-template >>view-template
        "edit-todo" todo-template >>edit-template
        "todo-summary" todo-template >>summary-template
        "id" <integer>
            hidden >>renderer
            add-field
        "summary" <string>
            t >>required
            add-field
        "priority" <integer>
            t >>required
            0 >>default
            0 >>min-value
            10 >>max-value
            add-field
        "description" <farkup>
            add-field ;

: <todo-list-form> ( -- form )
    "todo-list" <form>
        "todo-list" todo-template >>view-template
        "list" <todo-form> +plain+ <list>
        add-field ;

TUPLE: todo-list < dispatcher ;

:: <todo-list> ( -- responder )
    [let | todo-form [ <todo-form> ]
           list-form [ <todo-list-form> ]
           ctor [ [ <todo> ] ] |
        todo-list new-dispatcher
            list-form ctor        <list-action>   "list"   add-main-responder
            todo-form ctor        <view-action>   "view"   add-responder
            todo-form ctor "$todo-list/view" <edit-action>   "edit"   add-responder
                      ctor "$todo-list/list" <delete-action> "delete" add-responder
        <boilerplate>
            "todo" todo-template >>template
        <protected>
    ] ;
