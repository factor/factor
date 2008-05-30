! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences namespaces
db db.types db.tuples validators hashtables
html.components
html.templates.chloe
http.server.sessions
http.server.boilerplate
http.server.auth
http.server.actions
http.server.db
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

: <view-action> ( -- action )
    <page-action>
        [
            validate-integer-id
            "id" value <todo> select-tuple from-tuple
        ] >>init
        
        "view-todo" todo-template >>template ;

: <id-redirect> ( id next -- response )
    swap "id" associate <standard-redirect> ;

: validate-todo ( -- )
    {
        { "summary" [ v-one-line ] }
        { "priority" [ v-integer 0 v-min-value 10 v-max-value ] }
        { "description" [ v-required ] }
    } validate-params ;

: <new-action> ( -- action )
    <page-action>
        [ 0 "priority" set-value ] >>init

        "edit-todo" todo-template >>template

        [ validate-todo ] >>validate

        [
            f <todo>
                dup { "summary" "description" } deposit-slots
            [ insert-tuple ]
            [ id>> "$todo-list/view" <id-redirect> ]
            bi
        ] >>submit ;

: <edit-action> ( -- action )
    <page-action>
        [
            validate-integer-id
            "id" value <todo> select-tuple from-tuple
        ] >>init

        "edit-todo" todo-template >>template

        [
            validate-integer-id
            validate-todo
        ] >>validate

        [
            f <todo>
                dup { "id" "summary" "priority" "description" } deposit-slots
            [ update-tuple ]
            [ id>> "$todo-list/view" <id-redirect> ]
            bi
        ] >>submit ;

: <delete-action> ( -- action )
    <action>
        [ validate-integer-id ] >>validate

        [
            "id" get <todo> delete-tuples
            "$todo-list/list" f <standard-redirect>
        ] >>submit ;

: <list-action> ( -- action )
    <page-action>
        [ f <todo> select-tuples "items" set-value ] >>init
        "todo-list" todo-template >>template ;

TUPLE: todo-list < dispatcher ;

: <todo-list> ( -- responder )
    todo-list new-dispatcher
        <list-action>   "list"   add-main-responder
        <view-action>   "view"   add-responder
        <new-action>    "new"    add-responder
        <edit-action>   "edit"   add-responder
        <delete-action> "delete" add-responder
    <boilerplate>
        "todo" todo-template >>template
    f <protected> ;
