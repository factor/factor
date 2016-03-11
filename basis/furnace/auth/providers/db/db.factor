! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes.singleton continuations
db2.transactions db2.types furnace.auth.providers kernel
orm.persistent orm.tuples ;
IN: furnace.auth.providers.db

PERSISTENT: { user "users" }
    { "username" { VARCHAR 256 } +user-assigned-key+ }
    { "realname" { VARCHAR 256 } }
    { "password" BLOB +not-null+ }
    { "salt" INTEGER +not-null+ }
    { "email" { VARCHAR 256 } }
    { "ticket" { VARCHAR 256 } }
    { "capabilities" FACTOR-BLOB }
    { "profile" FACTOR-BLOB }
    { "deleted" INTEGER +not-null+ } ;

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
