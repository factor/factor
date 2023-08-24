! Copyright (C) 2009, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit compiler.cfg compiler.cfg.instructions
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.assignment compiler.cfg.parallel-copy
compiler.cfg.predecessors compiler.cfg.registers
compiler.cfg.rpo compiler.cfg.utilities cpu.architecture kernel
make namespaces sequences ;
IN: compiler.cfg.linear-scan.resolve

TUPLE: location
    { reg read-only }
    { rep read-only }
    { reg-class read-only } ;

: <location> ( reg rep -- location )
    dup reg-class-of location boa ;

M: location equal?
    over location? [
        { [ [ reg>> ] same? ] [ [ reg-class>> ] same? ] } 2&&
    ] [ 2drop f ] if ;

M: location hashcode*
    reg>> hashcode* ;

SYMBOL: temp-spills

: temp-spill ( rep -- spill-slot )
    rep-size temp-spills get
    [ cfg get stack-frame>> next-spill-slot ] cache ;

SYMBOL: temp-locations

: temp-location ( loc -- temp )
    rep>> temp-locations get
    [ [ temp-spill ] keep <location> ] cache ;

: init-resolve ( -- )
    H{ } clone temp-spills set
    H{ } clone temp-locations set ;

: add-mapping ( from to rep -- )
    '[ _ <location> ] bi@ 2array , ;

:: resolve-value-data-flow ( vreg live-out live-in edge-live-in -- )
    vreg live-out ?at [ bad-vreg ] unless
    vreg live-in ?at [ edge-live-in ?at [ bad-vreg ] unless ] unless
    2dup = [ 2drop ] [ vreg rep-of add-mapping ] if ;

:: compute-mappings ( bb to -- mappings )
    bb machine-live-out :> live-out
    to machine-live-in :> live-in
    bb to machine-edge-live-in :> edge-live-in
    live-out assoc-empty? [ f ] [
        [
            live-in keys edge-live-in keys append [
                live-out live-in edge-live-in
                resolve-value-data-flow
            ] each
        ] { } make
    ] if ;

: memory->register ( from to -- )
    swap [ reg>> ] [ [ rep>> ] [ reg>> ] bi ] bi* ##reload, ;

: register->memory ( from to -- )
    [ [ reg>> ] [ rep>> ] bi ] [ reg>> ] bi* ##spill, ;

: register->register ( from to -- )
    swap [ reg>> ] [ [ reg>> ] [ rep>> ] bi ] bi* ##copy, ;

: >insn ( from to -- )
    {
        { [ over reg>> spill-slot? ] [ memory->register ] }
        { [ dup reg>> spill-slot? ] [ register->memory ] }
        [ register->register ]
    } cond ;

: mapping-instructions ( alist -- insns )
    [ swap ] H{ } assoc-map-as [
        [ temp-location ] [ swap >insn ] parallel-mapping
        ##branch,
    ] { } make ;

: perform-mappings ( bb to mappings -- )
    [ 2drop ] [
        mapping-instructions insert-basic-block
        cfg get cfg-changed
    ] if-empty ;

: resolve-edge-data-flow ( bb to -- )
    2dup compute-mappings perform-mappings ;

: resolve-block-data-flow ( bb -- )
    dup kill-block?>> [ drop ] [
        dup successors>> [ resolve-edge-data-flow ] with each
    ] if ;

: resolve-data-flow ( cfg -- )
    init-resolve
    [ needs-predecessors ]
    [ [ resolve-block-data-flow ] each-basic-block ] bi ;
