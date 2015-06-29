! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences namespaces
db db.types db.tuples validators hashtables urls
html.forms
html.components
html.templates.chloe
http.server
http.server.dispatchers
furnace
furnace.boilerplate
furnace.auth
furnace.actions
furnace.redirection
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

USING: furnace.auth.features.registration
furnace.auth.features.edit-profile
furnace.auth.features.deactivate-user
db.sqlite
furnace.alloy
io.servers
io.sockets.secure ;

: <login-config> ( responder -- responder' )
    "Todo list" <login-realm>
        "Todo list" >>name
        allow-registration
        allow-edit-profile
        allow-deactivation ;

: todo-db ( -- db ) "resource:todo.db" <sqlite-db> ;

: init-todo-db ( -- )
    todo-db [
        init-furnace-tables
        todo ensure-table
    ] with-db ;

: <todo-secure-config> ( -- config )
    ! This is only suitable for testing!
    <secure-config>
        "vocab:openssl/test/dh1024.pem" >>dh-file
        "vocab:openssl/test/server.pem" >>key-file
        "password" >>password ;

: <todo-app> ( -- responder )
    init-todo-db
    <todo-list>
        <login-config>
        todo-db <alloy> ;

: <todo-website-server> ( -- threaded-server )
    <http-server>
        <todo-secure-config> >>secure-config
        8080 >>insecure
        8431 >>secure ;

: run-todo ( -- )
    <todo-app> main-responder set-global
    todo-db start-expiring
    <todo-website-server> start-server drop ;

MAIN: run-todo
