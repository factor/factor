! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: concurrency.futures concurrency.count-downs sequences
kernel ;
IN: concurrency.combinators

: parallel-map ( seq quot -- newseq )
    [ curry future ] curry map dup [ ?future ] change-each ;
    inline

: parallel-each ( seq quot -- )
    "Parallel each" pick length <count-down>
    [ [ spawn-stage ] 2curry each ] keep await ; inline
