! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators combinators.short-circuit compiler.cfg
compiler.cfg.def-use compiler.cfg.instructions
compiler.cfg.linear-scan.live-intervals compiler.cfg.predecessors
compiler.cfg.liveness compiler.cfg.ssa.destruction.leaders
compiler.cfg.register-allocation compiler.cfg.registers compiler.cfg.rpo cpu.architecture
continuations hashtables.identity kernel locals math namespaces sequences sets
vectors vocabs.loader ;
IN: compiler.cfg.register-allocation.verifier

! This checker deliberately does not consult allocated intervals, leaders,
! or the resolver's location maps. Its specification is the original SSA.
TUPLE: value-flow-operand value rep ;
TUPLE: value-flow-instruction inputs outputs temps roots derived constant ;
TUPLE: value-flow-snapshot instructions blocks phis aliases reps tagged-values ;
SINGLETON: value-flow-false
SYMBOL: active-value-flow-snapshot

ERROR: bad-allocation-value insn operand location available ;
ERROR: lost-allocation-instruction insn ;
ERROR: unexpected-allocation-instruction insn ;
ERROR: invalid-allocation-edge predecessor successor ;
ERROR: invalid-allocation-rematerialization original insn ;
ERROR: invalid-allocation-temporary insn ;
ERROR: invalid-allocation-gc-root insn value ;
ERROR: invalid-allocation-derived-root insn derived base ;
ERROR: overlapping-allocation-gc-roots insn ;
ERROR: invalid-allocation-operands insn ;
ERROR: invalid-allocation-operand-constraint insn ;

: value-flow-copy? ( insn -- ? )
    { [ ##copy? ] [ ##tagged>integer? ] } 1|| ;

:: value-flow-root ( value aliases -- root )
    value aliases at [ aliases value-flow-root ] [ value ] if* ;

:: value-flow-alias ( destination source aliases -- )
    destination aliases value-flow-root :> dst
    source aliases value-flow-root :> src
    dst src = [ ] [ src dst aliases set-at ] if ;

: value-flow-operands ( values -- operands )
    [ dup rep-of value-flow-operand boa ] map ;

: snapshot-value-flow-instruction ( insn -- snapshot )
    { [ uses-vregs value-flow-operands ]
    [ defs-vregs value-flow-operands ]
    [ temp-vregs value-flow-operands ]
    [ dup gc-map-insn? [ gc-map>> gc-roots>> clone ] [ drop f ] if ]
    [ dup gc-map-insn? [ gc-map>> derived-roots>> H{ } assoc-clone-like ] [ drop f ] if ]
    [ dup ##load-integer? [ val>> ] [ drop f ] if ]
    } cleave value-flow-instruction boa ;

:: snapshot-value-flow ( cfg -- snapshot )
    ! Fill original SSA GC maps in a private analysis scope, before allocator
    ! liveness rewrites their operands to leaders and then physical slots.
    [ f leader-map namespaces:set cfg compute-live-sets ] with-scope
    100 <identity-hashtable> :> instructions
    H{ } clone :> blocks
    H{ } clone :> phis
    H{ } clone :> aliases
    cfg [| bb |
        t bb blocks set-at
        bb instructions>> [| insn |
            insn ##phi? [
                insn dst>> insn inputs>> H{ } assoc-clone-like 2array bb phis push-at
            ] [
                insn snapshot-value-flow-instruction insn instructions set-at
                insn value-flow-copy? [
                    insn dst>> insn src>> aliases value-flow-alias
                ] when
            ] if
        ] each
    ] each-basic-block
    H{ } clone :> reps
    V{ } clone :> tagged-values
    representations get [| value rep |
        value aliases value-flow-root :> token
        token reps at [ rep-size rep rep-size < ] [ t ] if*
        [ rep token reps set-at ] when
        rep tagged-rep eq? [ token tagged-values push ] when
    ] assoc-each
    instructions blocks phis aliases reps tagged-values members value-flow-snapshot boa ;

! Allocator-generated recipes must retain the original instruction object.
! The caller already controls whether rematerialization is enabled.
:: record-value-flow-rematerialization ( original insn -- )
    active-value-flow-snapshot get [| snapshot |
        original snapshot instructions>> at :> expected
        expected [
            expected constant>> integer? insn ##load-integer? and [
                expected constant>> insn val>> =
            ] [ f ] if
        ] [ f ] if [ ] [ original insn invalid-allocation-rematerialization ] if
        expected insn snapshot instructions>> set-at
    ] when* ;

! Register classes disambiguate targets that number integer and FP registers
! alike. Spill memory is tracked by byte, so overlapping or partial writes
! cannot silently preserve a wider value.
:: value-flow-locations ( location rep -- locations )
    location spill-slot? [
        rep rep-size <iota> [ location n>> + "spill" swap 2array ] map
    ] [ rep reg-class-of location 2array 1array ] if ;

:: value-flow-read ( location rep state -- values )
    location rep value-flow-locations
    [ state at { } or ] map
    dup empty? [ drop { } ] [ unclip [ intersect ] reduce ] if ;

:: value-flow-write ( values location rep state -- )
    location rep value-flow-locations [ values swap state set-at ] each ;

:: value-flow-forget ( values state -- )
    state keys [| location |
        location state at values diff location state set-at
    ] each ;

:: value-flow-clobber ( state -- )
    state keys [ first "spill" = not ] filter
    [ state delete-at ] each ;

:: value-flow-token ( operand snapshot -- value )
    operand value>> snapshot aliases>> value-flow-root ;

:: check-value-flow-inputs ( insn expected state snapshot -- )
    insn uses-vregs length expected inputs>> length =
    insn defs-vregs length expected outputs>> length = and
    insn temp-vregs length expected temps>> length = and [ ] [
        insn invalid-allocation-operands
    ] if
    insn uses-vregs expected inputs>> [| location operand |
        location operand rep>> state value-flow-read :> available
        operand snapshot value-flow-token available member? [ ] [
            insn operand location available bad-allocation-value
        ] if
    ] 2each ;

:: define-value-flow-outputs ( insn expected state snapshot -- )
    expected outputs>> [ snapshot value-flow-token ] map :> values
    expected constant>> integer? [ ] [ values state value-flow-forget ] if
    insn defs-vregs expected outputs>> [| location operand |
        operand snapshot value-flow-token 1array
        location operand rep>> state value-flow-write
    ] 2each ;

:: forget-value-flow-temps ( insn expected state -- )
    insn temp-vregs expected temps>> [| location operand |
        { } location operand rep>> state value-flow-write
    ] 2each ;

:: check-value-flow-temps ( insn expected -- )
    insn uses-vregs expected inputs>> [ rep>> value-flow-locations ] 2map concat
    insn defs-vregs expected outputs>> [ rep>> value-flow-locations ] 2map concat
    append :> operands
    insn temp-vregs expected temps>> [ rep>> value-flow-locations ] 2map concat :> temps
    insn temp-vregs [ spill-slot? ] any? not
    temps all-unique? and temps operands intersect empty? and [ ] [
        insn invalid-allocation-temporary
    ] if ;

! Target two-address lowering may reuse the first source's location. A
! distinct later source must survive that copy into the destination. ABI
! clobbers marshal all slot inputs before writing outputs, so their input /
! output memory reuse follows the separate call contract.
:: check-value-flow-output-constraints ( insn expected -- )
    insn defs-vregs expected outputs>>
    [ rep>> value-flow-locations ] 2map concat :> outputs
    outputs all-unique? [ ] [ insn invalid-allocation-operand-constraint ] if
    insn clobber-insn? [ ] [
        insn uses-vregs expected inputs>>
        [ rep>> value-flow-locations ] 2map :> inputs
        inputs empty? [ ] [
            insn def-is-use-insn?
            [ inputs concat ]
            [ inputs rest concat inputs first diff ] if :> late
            outputs late intersect empty? [ ] [
                insn invalid-allocation-operand-constraint
            ] if
        ] if
    ] if ;

:: check-value-flow-roots ( insn expected state snapshot -- )
    insn gc-map-insn? [
        insn gc-map>> [ gc-roots>> ] [ derived-roots>> keys ] bi
        intersect empty? [ ] [ insn overlapping-allocation-gc-roots ] if
        insn gc-map>> gc-roots>> [| slot |
            slot tagged-rep state value-flow-read [
                dup value-flow-false eq?
                [ drop t ] [ snapshot tagged-values>> member? ] if
            ] any? [ ] [ insn slot invalid-allocation-gc-root ] if
        ] each
    ] when
    expected roots>> empty? [ ] [
        insn gc-map>> gc-roots>> [ tagged-rep state value-flow-read ] map concat :> available
        expected roots>> [| value |
            value snapshot aliases>> value-flow-root available member? [ ] [
                insn value invalid-allocation-gc-root
            ] if
        ] each
    ] if
    expected derived>> [| derived base |
        derived snapshot aliases>> value-flow-root :> value
        base snapshot aliases>> value-flow-root :> base-value
        value base-value = [ ] [
            insn gc-map>> derived-roots>> [| slot base-slot |
                value slot int-rep state value-flow-read member?
                base-value base-slot tagged-rep state value-flow-read member? and
                base-slot insn gc-map>> gc-roots>> member? and
            ] assoc-find 2nip [ ] [
                insn derived base invalid-allocation-derived-root
            ] if
        ] if
    ] assoc-each ;

! A collection updates only the slots named by its map. An unrooted copy
! of a pointer becomes stale even when another copy was rooted correctly.
:: relocate-value-flow-roots ( insn expected state snapshot -- )
    insn gc-map>> [ gc-roots>> ] [ derived-roots>> keys ] bi append
    [ tagged-rep value-flow-locations ] map concat :> updated
    expected roots>> expected derived>> keys append
    [ snapshot aliases>> value-flow-root ] map :> moving
    state keys [| location |
        location updated member? [ ] [
            location state at moving diff location state set-at
        ] if
    ] each ;

:: transfer-value-flow-copy ( insn state snapshot -- )
    insn ##tagged>integer? [ int-rep ] [ insn rep>> ] if :> rep
    insn src>> rep state value-flow-read
    [| value |
        value value-flow-false eq? [ rep reg-class-of int-regs eq? ] [
            value snapshot reps>> at [| original-rep |
                original-rep rep-size rep rep-size <=
                original-rep reg-class-of rep reg-class-of = and
            ] [ f ] if*
        ] if
    ] filter
    insn dst>> rep state value-flow-write ;

:: transfer-value-flow-insn ( insn state snapshot checking? -- )
    insn snapshot instructions>> at :> expected
    expected checking? and [
        expected constant>> integer? [
            insn ##load-integer? [ expected constant>> insn val>> = ] [ f ] if
            [ ] [ insn insn invalid-allocation-rematerialization ] if
        ] when
        insn expected state snapshot check-value-flow-inputs
        insn expected check-value-flow-temps
        insn expected check-value-flow-output-constraints
        insn expected state snapshot check-value-flow-roots
    ] when
    {
        { [ insn value-flow-copy? ] [ insn state snapshot transfer-value-flow-copy ] }
        { [ insn ##spill? insn ##reload? or ] [ insn state snapshot transfer-value-flow-copy ] }
        { [ expected >boolean ] [
            insn gc-map-insn? [ insn expected state snapshot relocate-value-flow-roots ] when
            ! Ordinary Factor calls live in kill blocks, but CFG boundaries
            ! do not themselves invalidate physical registers. In particular,
            ! a callback's raw result pointer must survive these calls in
            ! memory, never in an allocator register.
            insn clobber-insn? insn ##call-gc? or insn ##call? or
            [ state value-flow-clobber ] when
            insn expected state forget-value-flow-temps
            insn expected state snapshot define-value-flow-outputs
        ] }
        { [ insn ##branch? ] [ ] }
        ! SSA allocation can introduce false companion bases for derived
        ! pointers. They carry no original value, but do overwrite a register.
        { [ insn ##load-reference? ] [
            insn obj>> [ insn unexpected-allocation-instruction ] when
            value-flow-false 1array insn dst>> tagged-rep state value-flow-write
        ] }
        [ insn unexpected-allocation-instruction ]
    } cond ;

! Resolver blocks have a single incoming edge. Find the predecessor in the
! original CFG, before either CSSA or physical edge copies split that edge.
:: original-value-flow-predecessor ( predecessor snapshot -- original )
    predecessor snapshot blocks>> key? [ predecessor ] [
        predecessor predecessors>> dup length 1 = [
            first snapshot original-value-flow-predecessor
        ] [ drop predecessor f invalid-allocation-edge ] if
    ] if ;

:: rename-value-flow-phis ( predecessor successor state snapshot -- state' )
    successor snapshot phis>> at :> phis
    phis empty? [ state ] [
        predecessor snapshot original-value-flow-predecessor :> original
        phis [ first snapshot aliases>> value-flow-root ] map :> destinations
        phis [| phi |
            original phi second ?at [ ] [ original successor invalid-allocation-edge ] if
            snapshot aliases>> value-flow-root
            phi first snapshot aliases>> value-flow-root 2array
        ] map :> renames
        state [| location values |
            location values destinations diff
            renames [| pair |
                pair first values member? [ pair second suffix ] when
            ] each members
        ] assoc-map
    ] if ;

:: meet-value-flow-states ( first-state second-state -- state )
    first-state [| location values |
        location values location second-state at { } or intersect
    ] assoc-map ;

:: incoming-value-flow-state ( bb cfg states snapshot -- state/f )
    bb cfg entry>> eq? [ H{ } clone ] [
        bb predecessors>> [| predecessor |
            predecessor states at [
                predecessor bb rot snapshot rename-value-flow-phis
            ] [ f ] if*
        ] map sift
        dup empty? [ drop f ] [ unclip [ meet-value-flow-states ] reduce ] if
    ] if ;

:: transfer-value-flow-block ( bb state snapshot checking? -- state' )
    state clone :> result
    bb instructions>> [ result snapshot checking? transfer-value-flow-insn ] each
    result ;

:: check-value-flow-presence ( cfg snapshot -- )
    100 <identity-hashtable> :> present
    cfg [ instructions>> [ t swap present set-at ] each ] each-basic-block
    snapshot instructions>> keys [| insn |
        insn value-flow-copy? insn present key? or [ ] [
            insn lost-allocation-instruction
        ] if
    ] each ;

! Unvisited predecessor outputs denote top, not an empty machine. Iteration
! then intersects available values at joins until a fixed point, including
! back edges, before validating any use. No path is chosen speculatively.
:: check-value-flow ( cfg snapshot -- )
    cfg needs-predecessors
    cfg snapshot check-value-flow-presence
    cfg reverse-post-order :> blocks
    H{ } clone :> states
    t :> changed!
    [ changed ] [
        f changed!
        blocks [| bb |
            bb cfg states snapshot incoming-value-flow-state [| incoming |
                bb incoming snapshot f transfer-value-flow-block :> outgoing
                outgoing bb states at = [ ] [
                    outgoing bb states set-at t changed!
                ] if
            ] when*
        ] each
    ] while
    blocks [| bb |
        bb cfg states snapshot incoming-value-flow-state [| incoming |
            bb incoming snapshot t transfer-value-flow-block drop
        ] when*
    ] each ;

:: allocate-with-value-flow-check ( cfg -- )
    cfg snapshot-value-flow :> snapshot
    active-value-flow-snapshot get :> previous
    snapshot active-value-flow-snapshot namespaces:set
    [
        cfg current-register-allocator allocate-cfg
        cfg snapshot check-value-flow
    ] [ previous active-value-flow-snapshot namespaces:set ] finally ;

: value-flow-verifier-enabled? ( -- ? )
    allocation-verifier get >boolean ;

[ allocate-with-value-flow-check ] allocation-verifier set-global

{ "compiler.cfg.register-allocation.verifier"
  "compiler.cfg.register-allocation.rematerialization" }
"compiler.cfg.register-allocation.verifier.rematerialization" require-when
