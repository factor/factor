! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors continuations destructors fry kernel
sequences db2.result-sets db2.connections ;
IN: db2.statements

TUPLE: statement handle sql in out ;

: new-statement ( sql in out class -- statement )
    new
        swap >>out
        swap >>in
        swap >>sql ;

HOOK: <statement> db-connection ( sql in out -- statement )
GENERIC: execute-statement* ( statement type -- )
GENERIC: statement>result-set ( statement -- result-set )

M: object execute-statement* ( statement type -- )
    drop '[ _ statement>result-set dispose ]
    [ parse-db-error rethrow ] recover ;

: execute-one-statement ( statement -- )
    dup type>> execute-statement* ;

: execute-statement ( statement -- )
    dup sequence?
    [ [ execute-one-statement ] each ]
    [ execute-one-statement ] if ;

: statement-each ( statement quot: ( statement -- ) -- )
    over more-rows?
    [ [ call ] 2keep over advance-row statement-each ]
    [ 2drop ] if ; inline recursive

: statement-map ( statement quot -- sequence )
    accumulator [ statement-each ] dip { } like ; inline

: statement>result-sequence ( statement -- sequence )
    statement>result-set [ [ sql-row ] statement-map ] with-disposal ;
