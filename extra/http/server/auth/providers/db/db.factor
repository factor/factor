! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: db db.tuples db.types new-slots accessors
http.server.auth.providers kernel continuations
singleton ;
IN: http.server.auth.providers.db

user "USERS"
{
    { "username" "USERNAME" { VARCHAR 256 } +assigned-id+ }
    { "realname" "REALNAME" { VARCHAR 256 } }
    { "password" "PASSWORD" { VARCHAR 256 } +not-null+ }
    { "email" "EMAIL" { VARCHAR 256 } }
    { "ticket" "TICKET" { VARCHAR 256 } }
    { "profile" "PROFILE" FACTOR-BLOB }
} define-persistent

: init-users-table user ensure-table ;

SINGLETON: users-in-db

: find-user ( username -- user )
    <user>
        swap >>username
    select-tuple ;

M: users-in-db get-user
    drop
    find-user ;

M: users-in-db new-user
    drop
    [
        dup username>> find-user [
            drop f
        ] [
            dup insert-tuple
        ] if
    ] with-transaction ;

M: users-in-db update-user
    drop update-tuple ;
