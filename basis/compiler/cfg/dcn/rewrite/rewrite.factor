! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs kernel fry accessors sequences make math
combinators compiler.cfg compiler.cfg.hats compiler.cfg.instructions
compiler.cfg.utilities compiler.cfg.rpo compiler.cfg.dcn.local
compiler.cfg.dcn.global compiler.cfg.dcn.height ;
IN: compiler.cfg.dcn.rewrite

! This pass inserts peeks, replaces, and copies. All stack locations
! are loaded to canonical vregs, with a 1-1 mapping from location to
! vreg. SSA is reconstructed afterwards.

: inserting-peeks ( from to -- assoc )
    [
        peek-in swap [ peek-out ] [ avail-out ] bi
        assoc-union assoc-diff
    ] keep untranslate-locs ;

: inserting-replaces ( from to -- assoc )
    [
        [ replace-out ] [ [ kill-in ] [ replace-in ] bi ] bi*
        assoc-union assoc-diff
    ] keep
    untranslate-locs
    [ drop n>> 0 >= ] assoc-filter ;

SYMBOL: locs>vregs

: loc>vreg ( loc -- vreg ) locs>vregs get [ drop i ] cache ;

: each-insertion ( assoc quot: ( vreg loc -- ) -- )
    '[ drop [ loc>vreg ] keep @ ] assoc-each ; inline

: visit-edge ( from to -- )
    2dup [
        [ inserting-peeks [ ##peek ] each-insertion ]
        [ inserting-replaces [ ##replace ] each-insertion ] 2bi
    ] V{ } make
    [ 2drop ] [ <simple-block> insert-basic-block ] if-empty ;

: visit-edges ( bb -- )
    [ predecessors>> ] keep '[ _ visit-edge ] each ;

: insert-in-copies ( bb -- )
    peek [ swap loc>vreg ##copy ] assoc-each ;

: insert-out-copies ( bb -- )
    replace [ swap loc>vreg swap ##copy ] assoc-each ;

: rewrite-instructions ( bb -- )
    [
        [
            {
                [ insert-in-copies ]
                [ instructions>> but-last-slice % ]
                [ insert-out-copies ]
                [ instructions>> last , ]
            } cleave
        ] V{ } make
    ] keep (>>instructions) ;

: visit-block ( bb -- )
    [ visit-edges ] [ rewrite-instructions ] bi ;

: rewrite ( cfg -- )
    H{ } clone locs>vregs set
    [ visit-block ] each-basic-block ;