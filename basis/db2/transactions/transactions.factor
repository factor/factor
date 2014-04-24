! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations db2 db2.connections namespaces ;
IN: db2.transactions

SYMBOL: in-transaction

HOOK: begin-transaction db-connection ( -- )

HOOK: commit-transaction db-connection ( -- )

HOOK: rollback-transaction db-connection ( -- )

M: db-connection begin-transaction ( -- ) "BEGIN" sql-command ;

M: db-connection commit-transaction ( -- ) "COMMIT" sql-command ;

M: db-connection rollback-transaction ( -- ) "ROLLBACK" sql-command ;

: in-transaction? ( -- ? ) in-transaction get ;

: with-transaction ( quot -- )
    t in-transaction [
        begin-transaction
        [ ] [ rollback-transaction ] cleanup commit-transaction
    ] with-variable ; inline
