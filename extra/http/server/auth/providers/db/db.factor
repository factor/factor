! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: db db.tuples db.types new-slots accessors
http.server.auth.providers kernel ;
IN: http.server.auth.providers.db

TUPLE: user name password ;

: <user> user construct-empty ;

user "USERS"
{
    { "name" "NAME" { VARCHAR 256 } +assigned-id+ }
    { "password" "PASSWORD" { VARCHAR 256 } +not-null+ }
} define-persistent

: init-users-table ( -- )
    user create-table ;

TUPLE: db-auth-provider ;

: db-auth-provider T{ db-auth-provider } ;

M: db-auth-provider check-login
    drop
    <user>
    swap >>name
    swap >>password
    select-tuple >boolean ;

M: db-auth-provider new-user
    drop
    [
        <user>
        swap >>name

        dup select-tuple [ name>> user-exists ] when

        "unassigned" >>password

        insert-tuple
    ] with-transaction ;

M: db-auth-provider set-password
    drop
    [
        <user>
        swap >>name

        dup select-tuple [ ] [ no-such-user ] ?if

        swap >>password update-tuple
    ] with-transaction ;
