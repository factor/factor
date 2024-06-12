! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.cfg
compiler.cfg.instructions compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linearization compiler.cfg.liveness
compiler.cfg.registers compiler.cfg.renaming.functor
compiler.cfg.ssa.destruction.leaders compiler.cfg.utilities
heaps kernel make math namespaces sequences ;
IN: compiler.cfg.linear-scan.assignment
QUALIFIED: sets

! This contains both active and inactive intervals; any interval
! such that start <= insn# <= end is in this set.
SYMBOL: pending-interval-heap
SYMBOL: pending-interval-assoc

: insert-spill ( live-interval -- )
    [ reg>> ] [ spill-rep>> ] [ spill-to>> ] tri ##spill, ;

: handle-spill ( live-interval -- )
    dup spill-to>> [ insert-spill ] [ drop ] if ;

: add-pending ( live-interval -- )
    [ dup live-interval-end pending-interval-heap get heap-push ]
    [ [ reg>> ] [ vreg>> ] bi pending-interval-assoc get set-at ]
    bi ;

: remove-pending ( live-interval -- )
    vreg>> pending-interval-assoc get delete-at ;

: vreg>spill-slot ( vreg -- spill-slot )
    dup rep-of lookup-spill-slot ;

: vreg>reg ( vreg -- reg/spill-slot )
    dup leader dup pending-interval-assoc get at
    [ 2nip ] [ swap rep-of lookup-spill-slot ] if* ;

: vregs>regs ( assoc -- assoc' )
    [ vreg>reg ] assoc-map ;

SYMBOL: unhandled-intervals

SYMBOL: machine-live-ins

: machine-live-in ( bb -- assoc )
    machine-live-ins get at ;

: compute-live-in ( bb -- )
    [ live-in vregs>regs ] keep machine-live-ins get set-at ;

SYMBOL: machine-edge-live-ins

: machine-edge-live-in ( predecessor bb -- assoc )
    machine-edge-live-ins get at at ;

: compute-edge-live-in ( bb -- )
    [ edge-live-ins get at [ vregs>regs ] assoc-map ] keep
    machine-edge-live-ins get set-at ;

SYMBOL: machine-live-outs

: machine-live-out ( bb -- assoc )
    machine-live-outs get at ;

: compute-live-out ( bb -- )
    [ live-out vregs>regs ] keep machine-live-outs get set-at ;

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

: begin-block ( bb -- )
    {
        [ basic-block namespaces:set ]
        [ block-from unhandled-intervals get activate-new-intervals ]
        [ compute-edge-live-in ]
        [ compute-live-in ]
    } cleave ;

: change-insn-gc-roots ( gc-map-insn quot: ( x -- x ) -- )
    [ gc-map>> ] dip [ [ gc-roots>> ] dip map! drop ]
    [ '[ [ _ bi@ ] assoc-map ] change-derived-roots drop ] 2bi ; inline

: spill-required? ( live-interval root-leaders n -- ? )
    [ [ vreg>> ] dip sets:in? ] [ swap covers? ] bi-curry* bi or ;

: spill-intervals ( root-leaders n -- live-intervals )
    [ pending-interval-heap get heap-members ] 2dip
    '[ _ _ spill-required? ] filter ;

: rep-at-insn ( n interval -- rep )
    (find-use) [ def-rep>> ] [ use-rep>> ] bi or ;

: spill/reload ( n interval -- {reg,rep,slot} )
    [ rep-at-insn ] keep [ reg>> ] [ vreg>> ] bi
    pick assign-spill-slot swapd 3array ;

: spill/reloads ( n intervals -- spill/reloads )
    [ spill/reload ] with map ;

: spill/reloads-for-call-gc ( ##call-gc -- spill-seq )
    [ gc-map>> gc-roots>> ] [ insn#>> ] bi
    [ spill-intervals ] 1check spill/reloads ;

: emit-##call-gc ( insn -- )
    dup spill/reloads-for-call-gc
    dup [ first3 ##spill, ] each
    swap ,
    [ first3 ##reload, ] each ;

: emit-gc-map-insn ( gc-map-insn -- )
    [ [ leader ] change-insn-gc-roots ]
    [ dup ##call-gc? [ emit-##call-gc ] [ , ] if ]
    [ [ vreg>spill-slot ] change-insn-gc-roots ] tri ;

: emit-insn ( insn -- )
    dup gc-map-insn? [ emit-gc-map-insn ] [ , ] if ;

: assign-registers-in-block ( bb -- )
    dup begin-block
    [
        [
            [
                [ insn#>> prepare-insn ]
                [ assign-all-registers ]
                [ emit-insn ] tri
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
