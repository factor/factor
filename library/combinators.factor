! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel

: slip ( quot x -- x )
    >r call r> ; inline

: 2slip ( quot x y -- x y )
    >r >r call r> r> ; inline

: 3slip ( quot x y z -- x y z )
    >r >r >r call r> r> r> ; inline

: keep ( a quot -- a )
    #! Execute the quotation with a on the stack, and restore a
    #! after the quotation returns.
    over >r call r> ; inline

: 2keep ( a b quot -- a b )
    #! Execute the quotation with a and b on the stack, and
    #! restore a and b after the quotation returns.
    over >r pick >r call r> r> ; inline

: while ( quot generator -- )
    #! Keep applying the quotation to the value produced by
    #! calling the generator until the generator returns f.
    2dup >r >r swap >r call dup [
        r> call r> r> while
    ] [
        r> 2drop r> r> 2drop
    ] ifte ; inline

: apply ( code input -- code )
    #! A utility word for recursive combinators.
    swap dup slip ; inline

: ifte* ( cond true false -- )
    #! If the condition is not f, execute the 'true' quotation,
    #! with the condition on the stack. Otherwise, pop the
    #! condition and execute the 'false' quotation.
    pick [ drop call ] [ 2nip call ] ifte ; inline

: ?ifte ( default cond true false -- )
    #! If cond is true, drop default and apply true
    #! quotation to cond. Otherwise, drop cond, and apply false
    #! to default.
    >r >r dup [
        nip r> r> drop call
    ] [
        drop r> drop r> call
    ] ifte ; inline

: unless ( cond quot -- )
    #! Execute a quotation only when the condition is f. The
    #! condition is popped off the stack.
    #!
    #! In order to compile, the quotation must consume as many
    #! values as it produces.
    [ ] swap ifte ; inline

: unless* ( cond quot -- )
    #! If cond is f, pop it off the stack and evaluate the
    #! quotation. Otherwise, leave cond on the stack.
    #!
    #! In order to compile, the quotation must consume one less
    #! value than it produces.
    over [ drop ] [ nip call ] ifte ; inline

: when ( cond quot -- )
    #! Execute a quotation only when the condition is not f. The
    #! condition is popped off the stack.
    #!
    #! In order to compile, the quotation must consume as many
    #! values as it produces.
    [ ] ifte ; inline

: when* ( cond quot -- )
    #! If the condition is true, it is left on the stack, and
    #! the quotation is evaluated. Otherwise, the condition is
    #! popped off the stack.
    #!
    #! In order to compile, the quotation must consume one more
    #! value than it produces.
    dupd [ drop ] ifte ; inline

: forever ( quot -- )
    #! The code is evaluated in an infinite loop. Typically, a
    #! continuation is used to escape the infinite loop.
    #!
    #! This combinator will not compile.
    dup slip forever ;
