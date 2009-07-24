! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs kernel fry accessors sequences make math
combinators compiler.cfg compiler.cfg.hats compiler.cfg.instructions
compiler.cfg.utilities compiler.cfg.rpo compiler.cfg.stacks.local
compiler.cfg.stacks.global compiler.cfg.stacks.height ;
IN: compiler.cfg.stacks.finalize

! This pass inserts peeks and replaces.

: inserting-peeks ( from to -- assoc )
    peek-in swap [ peek-out ] [ avail-out ] bi
    assoc-union assoc-diff ;

: inserting-replaces ( from to -- assoc )
    [ replace-out ] [ [ kill-in ] [ replace-in ] bi ] bi*
    assoc-union assoc-diff ;

: each-insertion ( assoc bb quot: ( vreg loc -- ) -- )
    '[ drop [ loc>vreg ] [ _ untranslate-loc ] bi @ ] assoc-each ; inline

ERROR: bad-peek dst loc ;

: insert-peeks ( from to -- )
    [ inserting-peeks ] keep
    [ dup n>> 0 < [ bad-peek ] [ ##peek ] if ] each-insertion ;

: insert-replaces ( from to -- )
    [ inserting-replaces ] keep
    [ dup n>> 0 < [ 2drop ] [ ##replace ] if ] each-insertion ;

: visit-edge ( from to -- )
    2dup [ [ insert-peeks ] [ insert-replaces ] 2bi ] V{ } make
    [ 2drop ] [ <simple-block> insert-basic-block ] if-empty ;

: visit-block ( bb -- )
    [ predecessors>> ] keep '[ _ visit-edge ] each ;

: finalize-stack-shuffling ( cfg -- cfg' )
    dup [ visit-block ] each-basic-block
    cfg-changed ;