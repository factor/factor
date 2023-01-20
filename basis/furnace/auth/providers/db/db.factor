! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors db db.tuples db.types furnace.auth.providers
kernel ;
IN: furnace.auth.providers.db

user "USERS"
{
    { "username" "USERNAME" { VARCHAR 256 } +user-assigned-id+ }
    { "realname" "REALNAME" { VARCHAR 256 } }
    { "password" "PASSWORD" BLOB +not-null+ }
    { "salt" "SALT" INTEGER +not-null+ }
    { "email" "EMAIL" { VARCHAR 256 } }
    { "ticket" "TICKET" { VARCHAR 256 } }
    { "capabilities" "CAPABILITIES" FACTOR-BLOB }
    { "profile" "PROFILE" FACTOR-BLOB }
    { "deleted" "DELETED" INTEGER +not-null+ }
} define-persistent

SINGLETON: users-in-db

M: users-in-db get-user
    drop <user> select-tuple ;

M: users-in-db new-user
    drop
    [
        user new
            over username>> >>username
        select-tuple [
            drop f
        ] [
            dup insert-tuple
        ] if
    ] with-transaction ;

M: users-in-db update-user
    drop update-tuple ;
