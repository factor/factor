! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
IN: partial-continuations
USING: kernel continuations arrays sequences quotations ;

: breset ( quot -- )
    [ 1array swap keep first continue-with ] callcc1 nip ; inline

: (bshift) ( v r k -- obj )
    [ dup first -rot ] dip
    [
        rot set-first
        continue-with
    ] callcc1
    [ drop nip set-first ] dip ;

: bshift ( r quot -- )
    swap [ ! quot r k
        over [
            [ (bshift) ] 2curry swap call
        ] dip first continue-with
    ] callcc1 2nip ; inline
