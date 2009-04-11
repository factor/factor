! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: db2 ;
IN: db2.transactions

! Transactions
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
