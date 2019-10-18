! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
IN: partial-continuations
USING: kernel continuations arrays sequences quotations ;

: breset ( quot -- )
    [ 1array swap keep first continue-with ] callcc1 nip ;

: (bshift) ( v r k -- )
    >r dup first -rot r>
    [
        rot set-first
        continue-with
    ] callcc1
    >r drop nip set-first r> ;

: bshift ( r quot -- )
    swap [ ! quot r k
        over >r
        [ (bshift) ] 2curry swap call
        r> first continue-with
    ] callcc1 2nip ;
