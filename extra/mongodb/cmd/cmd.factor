USING: accessors assocs hashtables kernel linked-assocs strings ;
IN: mongodb.cmd

<PRIVATE

TUPLE: mongodb-cmd
    { name string }
    { const? boolean }
    { admin? boolean }
    { auth? boolean }
    { assoc assoc }
    { norep? boolean } ;

PRIVATE>

CONSTANT: buildinfo-cmd
    T{ mongodb-cmd f "buildinfo" t t f H{ { "buildinfo" 1 } } }

CONSTANT: list-databases-cmd
    T{ mongodb-cmd f "listDatabases" t t f H{ { "listDatabases" 1 } } }

! Options: { "async" t }
CONSTANT: fsync-cmd
    T{ mongodb-cmd f "fsync" f t f H{ { "fsync" 1 } } }

! Value: { "clone" from_host }
CONSTANT: clone-db-cmd
    T{ mongodb-cmd f "clone" f f t H{ { "clone" f } } }

! Options { { "fromdb" db } { "todb" db } { fromhost host } }
CONSTANT: copy-db-cmd
    T{ mongodb-cmd f "copydb" f f f H{ { "copydb" 1 } } }

CONSTANT: shutdown-cmd
    T{ mongodb-cmd f "shutdown" t t t H{ { "shutdown" 1 } } t }

CONSTANT: reseterror-cmd
    T{ mongodb-cmd f "reseterror" t f f H{ { "reseterror" 1 } } }

CONSTANT: getlasterror-cmd
    T{ mongodb-cmd f "getlasterror" t f f H{ { "getlasterror" 1 } } }

CONSTANT: getpreverror-cmd
    T{ mongodb-cmd f "getpreverror" t f f H{ { "getpreverror" 1 } } }

CONSTANT: forceerror-cmd
    T{ mongodb-cmd f "forceerror" t f f H{ { "forceerror" 1 } } }

CONSTANT: drop-db-cmd
    T{ mongodb-cmd f "dropDatabase" t f f H{ { "dropDatabase" 1 } } }

! Options { { "preserveClonedFilesOnFailure" t/f } { "backupOriginalFiles" t/f } }
CONSTANT: repair-db-cmd
    T{ mongodb-cmd f "repairDatabase" f f f H{ { "repairDatabase" 1 } } }

! Options: -1 gets the current profile level; 0-2 set the profile level
CONSTANT: profile-cmd
    T{ mongodb-cmd f "profile" f f f H{ { "profile" 0 } } }

CONSTANT: server-status-cmd
    T{ mongodb-cmd f "serverStatus" t f f H{ { "serverStatus" 1 } } }

CONSTANT: assertinfo-cmd
    T{ mongodb-cmd f "assertinfo" t f f H{ { "assertinfo" 1 } } }

CONSTANT: getoptime-cmd
    T{ mongodb-cmd f "getoptime" t f f H{ { "getoptime" 1 } } }

CONSTANT: oplog-cmd
    T{ mongodb-cmd f "opLogging" t f f H{ { "opLogging" 1 } } }

! Value: { "deleteIndexes" collection-name }
! Options: { "index" index_name or "*" }
CONSTANT: delete-index-cmd
    T{ mongodb-cmd f "deleteIndexes" f f f H{ { "deleteIndexes" f } } }

! Value: { "create" collection-name }
! Options: { { "capped" t } { "size" size_in_bytes } { "max" max_number_of_objects } { "autoIndexId" t/f } }
CONSTANT: create-cmd
    T{ mongodb-cmd f "drop" f f f H{ { "create" f } } }

! Value { "drop" collection-name }
CONSTANT: drop-cmd
    T{ mongodb-cmd f "drop" f f f H{ { "drop" f } } }

! Value { "count" collection-name }
! Options: { "query" query-object }
CONSTANT: count-cmd
    T{ mongodb-cmd f "count" f f f H{ { "count" f } } }

! Value { "validate" collection-name }
CONSTANT: validate-cmd
    T{ mongodb-cmd f "validate" f f f H{ { "validate" f } } }

! Value { "collstats" collection-name }
CONSTANT: collstats-cmd
    T{ mongodb-cmd f "collstats" f f f H{ { "collstats" f } } }

! Value: { "distinct" collection-name }
! Options: { "key" key-name }
CONSTANT: distinct-cmd
    T{ mongodb-cmd f "distinct" f f f H{ { "distinct" f } } }

! Value: { "filemd5" oid }
! Options: { "root" bucket-name }
CONSTANT: filemd5-cmd
    T{ mongodb-cmd f "filemd5" f f f H{ { "filemd5" f } } }

CONSTANT: getnonce-cmd
    T{ mongodb-cmd f "getnonce" t f f H{ { "getnonce" 1 } } }

! Options: { { "user" username } { "nonce" nonce } { "key" digest } }
CONSTANT: authenticate-cmd
    T{ mongodb-cmd f "authenticate" f f f H{ { "authenticate" 1 } } }

CONSTANT: logout-cmd
    T{ mongodb-cmd f "logout" t f f H{ { "logout" 1 } } }

! Value: { "findandmodify" collection-name }
! Options: { { "query" selector } { "sort" sort-spec }
!            { "remove" t/f } { "update" modified-object }
!            { "new" t/f } }
CONSTANT: findandmodify-cmd
    T{ mongodb-cmd f "findandmodify" f f f H{ { "findandmodify" f } } }

: make-cmd ( cmd-stub -- cmd-assoc )
    dup const?>> [  ] [
        clone [ clone <linked-assoc> ] change-assoc
    ] if ; inline

: set-cmd-opt ( cmd value key -- cmd )
    pick assoc>> set-at ; inline
