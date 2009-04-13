! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors continuations destructors fry kernel
sequences db2.result-sets db2.connections db2.errors ;
IN: db2.statements

TUPLE: statement handle sql in out type ;

: new-statement ( sql in out class -- statement )
    new
        swap >>out
        swap >>in
        swap >>sql ;

HOOK: <statement> db-connection ( sql in out -- statement )
GENERIC: statement>result-set* ( statement -- result-set )
GENERIC: execute-statement* ( statement type -- )
GENERIC: prepare-statement* ( statement -- statement' )
GENERIC: bind-sequence ( sequence statement -- )
GENERIC: bind-typed-sequence ( sequence statement -- )

: statement>result-set ( statement -- result-set )
    [ statement>result-set* ]
    [ dup sql-error? [ parse-sql-error ] when rethrow ] recover ;

M: object execute-statement* ( statement type -- )
    drop statement>result-set dispose ;

: execute-one-statement ( statement -- )
    dup type>> execute-statement* ;

: execute-statement ( statement -- )
    dup sequence?
    [ [ execute-one-statement ] each ]
    [ execute-one-statement ] if ;

: prepare-statement ( statement -- statement )
    dup handle>> [ prepare-statement* ] unless ;

: statement-each ( statement quot: ( statement -- ) -- )
    over more-rows?
    [ [ call ] 2keep over advance-row statement-each ]
    [ 2drop ] if ; inline recursive

: statement-map ( statement quot -- sequence )
    accumulator [ statement-each ] dip { } like ; inline

: statement>result-sequence ( statement -- sequence )
    statement>result-set [ [ sql-row ] statement-map ] with-disposal ;
