! Copyright (C) 2005, 2008 Chris Double, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors boxes concurrency.conditions continuations
dlists kernel threads typed vocabs.loader ;
IN: concurrency.promises

TUPLE: promise { box box } { threads dlist } ;

: <promise> ( -- promise )
    <box> <dlist> promise boa ;

TYPED: promise-fulfilled? ( promise: promise -- ? )
    box>> occupied>> ;

ERROR: promise-already-fulfilled promise ;

TYPED: fulfill ( value promise: promise -- )
    [ box>> ] keep over occupied>> [
        promise-already-fulfilled
    ] [
        [ >box ] [ threads>> notify-all ] bi* yield
    ] if ;

TYPED:: block-if-empty ( promise: promise timeout -- promise )
    promise box>> '[ _ occupied>> ]
    promise threads>> '[ _ timeout "promise" wait ] until
    promise ;

TYPED: ?promise-timeout ( promise: promise timeout -- result )
    block-if-empty box>> check-box value>> ;

: ?promise ( promise -- result )
    f ?promise-timeout ;

M: promise send-linked-error fulfill ;
