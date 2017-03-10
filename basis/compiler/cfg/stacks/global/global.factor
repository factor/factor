! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors compiler.cfg.dataflow-analysis kernel sequences sets ;
IN: compiler.cfg.stacks.global

: transfer-peeked-locs ( set bb -- set' )
    [ replaces>> diff ] [ peeks>> union ] bi ;

BACKWARD-ANALYSIS: anticip

M: anticip transfer-set drop transfer-peeked-locs ;
M: anticip join-sets 2drop refine ;

BACKWARD-ANALYSIS: live

M: live transfer-set drop transfer-peeked-locs ;
M: live join-sets 2drop combine ;

FORWARD-ANALYSIS: avail

M: avail transfer-set ( in-set bb dfa -- out-set )
    drop [ peeks>> ] [ replaces>> ] bi union union ;
M: avail join-sets 2drop refine ;

FORWARD-ANALYSIS: pending

M: pending transfer-set
    drop replaces>> union ;
M: pending join-sets 2drop refine ;

BACKWARD-ANALYSIS: dead

M: dead transfer-set
    drop [ kills>> ] [ replaces>> ] bi union union ;
M: dead join-sets 2drop refine ;
