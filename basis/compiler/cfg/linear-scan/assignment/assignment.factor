! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators compiler.cfg
compiler.cfg.instructions compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals compiler.cfg.linearization
compiler.cfg.liveness compiler.cfg.registers
compiler.cfg.renaming.functor compiler.cfg.ssa.destruction.leaders fry
heaps kernel make math namespaces sequences ;
IN: compiler.cfg.linear-scan.assignment

: heap-pop-while ( heap quot: ( key -- ? ) -- values )
    '[ dup heap-empty? [ f f ] [ dup heap-peek @ ] if ]
    [ over heap-pop* ] produce 2nip ; inline

! This contains both active and inactive intervals; any interval
! such that start <= insn# <= end is in this set.
SYMBOL: pending-interval-heap
SYMBOL: pending-interval-assoc

: add-pending ( live-interval -- )
    [ dup live-interval-end pending-interval-heap get heap-push ]
    [ [ reg>> ] [ vreg>> ] bi pending-interval-assoc get set-at ]
    bi ;

: remove-pending ( live-interval -- )
    vreg>> pending-interval-assoc get delete-at ;

: vreg>reg ( vreg -- reg/spill-slot )
    dup leader dup pending-interval-assoc get at
    [ 2nip ] [ swap rep-of lookup-spill-slot ] if* ;

ERROR: not-spilled-error vreg ;

: vreg>spill-slot ( vreg -- spill-slot )
    dup vreg>reg dup spill-slot?
    [ nip ] [ drop leader not-spilled-error ] if ;

: vregs>regs ( vregs -- assoc )
    [ dup vreg>reg ] H{ } map>assoc ;

SYMBOL: unhandled-intervals

SYMBOL: machine-live-ins

: machine-live-in ( bb -- assoc )
    machine-live-ins get at ;

: compute-live-in ( bb -- )
    [ live-in keys vregs>regs ] keep machine-live-ins get set-at ;

SYMBOL: machine-edge-live-ins

: machine-edge-live-in ( predecessor bb -- assoc )
    machine-edge-live-ins get at at ;

: compute-edge-live-in ( bb -- )
    [ edge-live-ins get at [ keys vregs>regs ] assoc-map ] keep
    machine-edge-live-ins get set-at ;

SYMBOL: machine-live-outs

: machine-live-out ( bb -- assoc )
    machine-live-outs get at ;

: compute-live-out ( bb -- )
    [ live-out keys vregs>regs ] keep machine-live-outs get set-at ;

: insert-spill ( live-interval -- )
    [ reg>> ] [ spill-rep>> ] [ spill-to>> ] tri ##spill, ;

: handle-spill ( live-interval -- )
    dup spill-to>> [ insert-spill ] [ drop ] if ;

: expire-interval ( live-interval -- )
    [ remove-pending ] [ handle-spill ] bi ;

: expire-old-intervals ( n pending-heap -- )
    [ > ] with heap-pop-while [ expire-interval ] each ;

: insert-reload ( live-interval -- )
    [ reg>> ] [ reload-rep>> ] [ reload-from>> ] tri ##reload, ;

: handle-reload ( live-interval -- )
    dup reload-from>> [ insert-reload ] [ drop ] if ;

: activate-interval ( live-interval -- )
    [ add-pending ] [ handle-reload ] bi ;

: activate-new-intervals ( n unhandled-heap -- )
    [ = ] with heap-pop-while [ activate-interval ] each ;

: prepare-insn ( n -- )
    [ pending-interval-heap get expire-old-intervals ]
    [ unhandled-intervals get activate-new-intervals ] bi ;

RENAMING: assign [ vreg>reg ] [ vreg>reg ] [ vreg>reg ]

: assign-all-registers ( insn -- )
    [ assign-insn-defs ] [ assign-insn-uses ] [ assign-insn-temps ] tri ;

: assign-gc-roots ( gc-map -- )
    gc-roots>> [ vreg>spill-slot ] map! drop ;

: assign-derived-roots ( gc-map -- )
    [ [ [ vreg>spill-slot ] bi@ ] assoc-map ] change-derived-roots drop ;

: begin-block ( bb -- )
    {
        [ basic-block namespaces:set ]
        [ block-from unhandled-intervals get activate-new-intervals ]
        [ compute-edge-live-in ]
        [ compute-live-in ]
    } cleave ;

: handle-gc-map-insn ( insn -- )
    dup , gc-map>> [ assign-gc-roots ] [ assign-derived-roots ] bi ;

: assign-registers-in-block ( bb -- )
    dup begin-block
    [
        [
            [
                [ insn#>> prepare-insn ]
                [ assign-all-registers ]
                [ dup gc-map-insn? [ handle-gc-map-insn ] [ , ] if ] tri
            ] each
        ] V{ } make
    ] change-instructions compute-live-out ;

: live-intervals>min-heap ( live-intervals -- min-heap )
    [ [ live-interval-start ] map ] keep zip >min-heap ;

: init-assignment ( live-intervals -- )
    live-intervals>min-heap unhandled-intervals namespaces:set
    <min-heap> pending-interval-heap namespaces:set
    H{ } clone pending-interval-assoc namespaces:set
    H{ } clone machine-live-ins namespaces:set
    H{ } clone machine-edge-live-ins namespaces:set
    H{ } clone machine-live-outs namespaces:set ;

: assign-registers ( cfg live-intervals -- )
    init-assignment
    linearization-order [ kill-block?>> ] reject
    [ assign-registers-in-block ] each ;
