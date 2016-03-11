! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors db2.connections db2.types furnace.actions
furnace.alloy furnace.auth furnace.auth.features.deactivate-user
furnace.auth.features.edit-profile
furnace.auth.features.registration furnace.auth.login
furnace.boilerplate furnace.redirection html.forms http.server
http.server.dispatchers kernel namespaces orm.persistent
orm.tuples urls validators webapps.utils ;
IN: webapps.todo

TUPLE: todo-list < dispatcher ;

TUPLE: todo uid id priority summary description ;

PERSISTENT: todo
    { "uid" { VARCHAR 256 } +not-null+ }
    { "id" +db-assigned-key+ }
    { "priority" INTEGER +not-null+ }
    { "summary" { VARCHAR 256 } +not-null+ }
    { "description" { VARCHAR 256 } } ;

: <todo> ( id -- todo )
    todo new
        swap >>id
        username >>uid ;

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
                dup { "summary" "priority" "description" } to-object
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
                dup { "id" "summary" "priority" "description" } to-object
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
        <list-action>   "list"       add-responder
        URL" /list" <redirect-responder> "" add-responder
        <view-action>   "view"   add-responder
        <new-action>    "new"    add-responder
        <edit-action>   "edit"   add-responder
        <delete-action> "delete" add-responder
    <boilerplate>
        { todo-list "todo" } >>template
    <protected>
        "view your todo list" >>description ;


: <login-config> ( responder -- responder' )
    "Todo list" <login-realm>
        allow-registration
        allow-edit-profile
        allow-deactivation ;

: todo-db ( -- db )
    "todo.db" <temp-sqlite-db> ;

: init-todo-db ( -- )
    todo-db [
        init-furnace-tables
        todo ensure-table
    ] with-db ;

: <todo-app> ( -- responder )
    init-todo-db
    <todo-list>
        <login-config>
        todo-db <alloy> ;

: run-todo ( -- )
    <todo-app> main-responder set-global
    todo-db start-expiring
    run-test-httpd ;

MAIN: run-todo
