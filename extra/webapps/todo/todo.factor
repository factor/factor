! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences namespaces
db db.types db.tuples validators hashtables urls
html.components
html.templates.chloe
http.server
http.server.dispatchers
furnace
furnace.sessions
furnace.boilerplate
furnace.auth
furnace.actions
furnace.db
furnace.auth.login ;
IN: webapps.todo

TUPLE: todo-list < dispatcher ;

TUPLE: todo uid id priority summary description ;

todo "TODO"
{
    { "uid" "UID" { VARCHAR 256 } +not-null+ }
    { "id" "ID" +db-assigned-id+ }
    { "priority" "PRIORITY" INTEGER +not-null+ }
    { "summary" "SUMMARY" { VARCHAR 256 } +not-null+ }
    { "description" "DESCRIPTION" { VARCHAR 256 } }
} define-persistent

: <todo> ( id -- todo )
    todo new
        swap >>id
        uid >>uid ;

: <view-action> ( -- action )
    <page-action>
        [
            validate-integer-id
            "id" value <todo> select-tuple from-object
        ] >>init
        
        { todo-list "view-todo" } >>template ;

: validate-todo ( -- )
    {
        { "summary" [ v-one-line ] }
        { "priority" [ v-integer 0 v-min-value 10 v-max-value ] }
        { "description" [ v-required ] }
    } validate-params ;

: view-todo-url ( id -- url )
    <url> "$todo-list/view" >>path swap "id" set-query-param ;

: <new-action> ( -- action )
    <page-action>
        [ 0 "priority" set-value ] >>init

        { todo-list "new-todo" } >>template

        [ validate-todo ] >>validate

        [
            f <todo>
                dup { "summary" "priority" "description" } deposit-slots
            [ insert-tuple ] [ id>> view-todo-url <redirect> ] bi
        ] >>submit ;

: <edit-action> ( -- action )
    <page-action>
        [
            validate-integer-id
            "id" value <todo> select-tuple from-object
        ] >>init

        { todo-list "edit-todo" } >>template

        [
            validate-integer-id
            validate-todo
        ] >>validate

        [
            f <todo>
                dup { "id" "summary" "priority" "description" } deposit-slots
            [ update-tuple ] [ id>> view-todo-url <redirect> ] bi
        ] >>submit ;

: todo-list-url ( -- url )
    URL" $todo-list/list" ;

: <delete-action> ( -- action )
    <action>
        [ validate-integer-id ] >>validate

        [
            "id" get <todo> delete-tuples
            todo-list-url <redirect>
        ] >>submit ;

: <list-action> ( -- action )
    <page-action>
        [ f <todo> select-tuples "items" set-value ] >>init
        { todo-list "todo-list" } >>template ;

: <todo-list> ( -- responder )
    todo-list new-dispatcher
        <list-action>   "list"   add-main-responder
        <view-action>   "view"   add-responder
        <new-action>    "new"    add-responder
        <edit-action>   "edit"   add-responder
        <delete-action> "delete" add-responder
    <boilerplate>
        { todo-list "todo" } >>template
    <protected>
        "view your todo list" >>description ;
