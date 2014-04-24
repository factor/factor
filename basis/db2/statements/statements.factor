! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays continuations db2.connections db2.errors
db2.result-sets db2.utils destructors fry kernel sequences math
vectors ;
IN: db2.statements

TUPLE: statement handle sql in out after
retries errors retry-quotation reconstructor ;

: normalize-statement ( statement -- statement )
    [ object>vector ] change-in
    [ object>vector ] change-out ; inline

: initialize-statement ( statement -- statement )
    V{ } clone >>in
    V{ } clone >>out
    V{ } clone >>errors ; inline
 
: <sql> ( string -- statement )
    statement new
        swap >>sql
        initialize-statement ; inline

: <statement> ( -- statement )
    statement new
        initialize-statement ; inline

HOOK: next-bind-index db-connection ( -- string )
HOOK: init-bind-index db-connection ( -- )

: add-sql ( statement sql -- statement )
    '[ _ "" append-as ] change-sql ;

GENERIC: add-in ( statement object -- statement )
GENERIC: add-out ( statement object -- statement )

: in-vector ( statmenet object -- statement object statement )
    over [ >vector ] change-in in>> ;

: out-vector ( statmenet object -- statement object statement )
    over [ >vector ] change-out out>> ;

M: sequence add-in in-vector push-all ;
M: object add-in in-vector push ;
M: sequence add-out out-vector push-all ;
M: object add-out out-vector push ;

HOOK: prepare-statement* db-connection ( statement -- statement' )
HOOK: dispose-statement db-connection ( statement -- )
HOOK: bind-sequence db-connection ( statement -- )
HOOK: reset-statement db-connection ( statement -- statement' )

ERROR: no-database-in-scope ;

M: statement dispose dispose-statement ;
M: f dispose-statement no-database-in-scope ;
M: object reset-statement ;

: with-sql-error-handler ( quot -- )
    [ dup sql-error? [ parse-sql-error ] when rethrow ] recover ; inline

: prepare-statement ( statement -- statement )
    [ dup handle>> [ prepare-statement* ] unless ] with-sql-error-handler ;

: (run-after-setters) ( tuple statement -- )
    after>> [
        [ value>> ] [ setter>> ] bi
        call( obj val -- obj ) drop
    ] with each ;

: run-after-setters ( tuple statement -- )
    dup sequence? [
        [ (run-after-setters) ] with each
    ] [
        (run-after-setters)
    ] if ;
