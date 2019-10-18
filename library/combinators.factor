! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel

: slip ( quot x -- x | quot: -- )
    >r call r> ; inline

: 2slip ( quot x y -- x y : quot: -- )
    >r >r call r> r> ; inline

: keep ( a quot -- a | quot: a -- )
    over >r call r> ; inline

: 2keep ( a b quot -- a b | quot: a b -- )
    over >r pick >r call r> r> ; inline

: while ( quot generator -- )
    #! Keep applying the quotation to the value produced by
    #! calling the generator until the generator returns f.
    2dup >r >r swap >r call dup [
        r> call r> r> while
    ] [
        r> 2drop r> r> 2drop
    ] ifte ; inline

: ifte* ( cond true false -- )
    #! [ X ] [ Y ] ifte* ==> dup [ X ] [ drop Y ] ifte
    pick [ drop call ] [ 2nip call ] ifte ; inline

: ?ifte ( default cond true false -- )
    #! [ X ] [ Y ] ?ifte ==> dup [ nip X ] [ drop Y ] ifte
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
