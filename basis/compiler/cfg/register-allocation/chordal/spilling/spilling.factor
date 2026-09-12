! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.cfg compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals compiler.cfg.loop-detection compiler.cfg.predecessors
compiler.cfg.linearization
compiler.cfg.register-allocation.chordal.spilling.next-use
compiler.cfg.register-allocation.chordal.spilling.residency
compiler.cfg.register-allocation.rematerialization compiler.cfg.registers
compiler.cfg.renaming.functor compiler.cfg.rpo compiler.cfg.utilities compiler.utilities
compiler.cfg.ssa.destruction.leaders
cpu.architecture kernel locals math math.order namespaces sequences sets vectors ;
IN: compiler.cfg.register-allocation.chordal.spilling

! Memory names and register definitions are deliberately different vregs.
! Every reload defines a fresh register SSA value. Entry phis join precisely
! those versions supplied by each predecessor, including backedges.
TUPLE: spill-block bb originals distances afters phi-sources
    entry-versions entry-phis memory-phis saved-entry exit-versions saved-exit ;

SYMBOLS: spill-homes spill-memory-locations spill-plans spill-bank
    spill-W spill-S spill-output spill-use-renaming spill-def-renaming
    spill-statistics ;

ERROR: missing-spill-value value ;

:: spill-stat ( key -- ) key spill-statistics get inc-at ;

:: memory-name ( value -- name )
    value spill-homes get [
        drop
        value rep-of next-vreg-rep :> name
        value rematerialization-of [ ] [ name name rep-of assign-spill-slot ] if*
        name spill-memory-locations get set-at
        name
    ] cache ;

: memory-location ( value -- location )
    memory-name spill-memory-locations get at ;

: register-class ( value -- class ) rep-of reg-class-of ;

:: register-version ( value -- version ) value spill-W get at ;

:: store-value ( value -- )
    value spill-S get key? [ ] [
        value memory-location :> location
        location constant-recipe? [ ] [
            ##spill new value register-version >>src
            value rep-of >>rep location >>dst spill-output get push
            "pressure-stores" spill-stat
        ] if
        value spill-S get conjoin
    ] if ;

:: reload-value ( value -- version )
    value spill-S get key? value rematerialization-of >boolean or
    [ ] [ value missing-spill-value ] if
    value rep-of next-vreg-rep :> version
    value memory-location :> location
    location constant-recipe? [
        ##load-integer new version >>dst location val>> >>val :> insn
        rematerialization-observer get [
            location original-insn>> insn rot call( original insn -- )
        ] when*
        "loads" rematerialization-statistics get inc-at
        insn
    ] [
        ##reload new version >>dst value rep-of >>rep location >>src
    ] if spill-output get push
    "reload-definitions" spill-stat
    version ;

:: evict-values ( values distances -- )
    values [| value |
        value distances key? [ value store-value ] when
        value spill-W get delete-at
    ] each ;

:: limit-residents ( demanded distances -- )
    "pressure-decisions" spill-stat
    spill-bank get [| class bank |
        spill-W get keys [ register-class class = ] filter
        demanded [ register-class class = ] filter
        distances bank length pressure-victims distances evict-values
    ] assoc-each ;

:: ensure-register ( value -- )
    value spill-W get key? [ ] [
        value reload-value value spill-W get set-at
    ] if ;

RENAMING: spill-rename
    [ dup spill-def-renaming get at swap or ]
    [ dup spill-use-renaming get at swap or ]
    [ ]

:: forget-dead-residents ( distances -- )
    spill-W get [ drop distances key? ] assoc-filter! drop ;

:: rewrite-ordinary-insn ( insn distances -- )
    insn uses-vregs members :> uses
    insn defs-vregs :> defs
    insn temp-vregs :> temps
    ! Protect all inputs while loading missing operands and reserving temps.
    uses temps append distances limit-residents
    uses [ ensure-register ] each
    uses [ dup register-version ] H{ } map>assoc spill-use-renaming namespaces:set
    ! Only the first ordinary input may die before the result is written.
    ! A live first input can be saved here and its register reused afterward.
    insn def-is-use-insn? [ uses ] [
        insn uses-vregs dup empty? [ ] [ rest ] if
    ] if
    defs append temps append distances limit-residents
    insn spill-rename-insn-uses
    insn spill-output get push
    defs [| value |
        value value spill-W get set-at
        value spill-S get delete-at
    ] each
    distances forget-dead-residents ;

:: rewrite-gc-map ( insn -- )
    insn gc-map-insn? [
        insn gc-map>>
        [ [ memory-name ] map ] change-gc-roots
        [ [ [ memory-name ] bi@ ] assoc-map ] change-derived-roots drop
    ] when ;

:: rewrite-clobber-insn ( insn distances -- )
    ! The ABI consumes homes. GC also requires homes for roots, bases and
    ! live non-roots; all register versions end before the clobber.
    insn spill-insn-uses :> uses
    uses [| value |
        value spill-W get key? [ value store-value ] when
    ] each
    spill-W get keys distances evict-values
    uses [ dup memory-name ] H{ } map>assoc spill-use-renaming namespaces:set
    insn defs-vregs :> defs
    insn hairy-clobber-insn? [
        insn temp-vregs distances limit-residents
        defs [ dup memory-name ] H{ } map>assoc spill-def-renaming namespaces:set
        insn spill-rename-insn-defs
        defs [ spill-S get conjoin ] each
    ] [
        defs insn temp-vregs append distances limit-residents
        defs [ dup spill-W get set-at ] each
    ] if
    insn spill-rename-insn-uses
    insn rewrite-gc-map
    insn spill-output get push
    distances forget-dead-residents ;

:: new-spill-block ( bb exit-distances -- plan )
    bb instructions>> clone :> originals
    H{ } clone :> sources
    originals [ ##phi? ] filter [| phi |
        phi inputs>> H{ } assoc-like phi dst>> sources set-at
        phi [ H{ } assoc-like ] change-inputs drop
    ] each
    exit-distances :> distances!
    originals <reversed> [| insn |
        insn ##phi? [ ] [ distances insn transfer-next-use distances! ] if
    ] each
    spill-block new bb >>bb originals >>originals distances >>distances
    bb exit-distances instruction-next-uses >>afters sources >>phi-sources
    H{ } clone >>entry-versions H{ } clone >>entry-phis H{ } clone >>memory-phis
    H{ } clone >>saved-entry ;

:: predecessor-value ( value plan predecessor -- source )
    value plan phi-sources>> at [ predecessor swap at ] [ value ] if* ;

:: known-predecessor-residents ( value plan -- flags )
    plan bb>> predecessors>> [ spill-plans get at ] map
    [ exit-versions>> ] filter [| previous |
        value plan previous bb>> predecessor-value
        previous exit-versions>> key?
    ] map ;

:: loop-entry-candidates ( candidates plan class capacity -- allowed )
    plan bb>> loops get at [| loop |
        loop blocks>> members [ spill-plans get at ] map :> body
        body [ originals>> [ spill-insn-uses ] map concat ] map concat members
        :> loop-uses
        candidates loop-uses diff :> through
        ! Reserve room for the loop's own maximum demand before retaining
        ! unused live-through values. Spilling these at entry avoids repeated
        ! eviction/reload around the backedge.
        body [| block |
            block originals>> [| insn |
                insn block afters>> at keys
                insn uses-vregs append insn defs-vregs append
                insn temp-vregs append members through diff
                [ register-class class = ] count
            ] map 0 [ max ] reduce
        ] map 0 [ max ] reduce :> pressure
        through { } plan distances>> capacity pressure - 0 max
        select-entry-residents :> retained
        candidates through diff retained append
    ] [ candidates ] if* ;

! Do not reload a memory-only value merely to fill the entry bank. A
! known single predecessor supplies its own resident set; fully known
! joins may keep values resident on some incoming paths. Unknown loop
! backedges retain the existing conservative entry-selection behavior.
:: entry-resident-candidate? ( value plan -- ? )
    plan bb>> predecessors>> [| predecessor |
        predecessor spill-plans get at exit-versions>> :> residents
        residents [
            value plan predecessor predecessor-value residents key?
        ] [ t ] if
    ] any? ;

:: choose-entry-values ( plan -- values )
    ! Factor call/prologue/epilogue blocks are not register allocation
    ! regions. In particular, a callback's hidden raw result pointer can
    ! remain live across Factor calls in its ABI-created memory home.
    ! Creating a register repair phi here would both cross the call's
    ! clobbers and strand an interval in the skipped assignment block.
    plan bb>> kill-block?>> [ { } ] [
    plan distances>> keys [ plan entry-resident-candidate? ] filter :> candidates
    candidates [| value |
        value plan known-predecessor-residents dup empty?
        [ drop f ] [ [ ] all? ] if
    ] filter :> common
    spill-bank get [| class bank |
        candidates [ register-class class = ] filter
        plan class bank length loop-entry-candidates
        common plan distances>> bank length select-entry-residents
    ] { } assoc>map concat
    ] if ;

:: entry-memory-valid? ( value plan -- ? )
    value plan phi-sources>> key? [ f ] [
        plan bb>> predecessors>> [ spill-plans get at saved-exit>> ] map :> saved
        saved empty? [ f ] [
            saved [ ] all? [
                ! Resident values need no new store just to make a dirty hot
                ! path agree with a saved cold/GC path. Record only homes
                ! already valid on every predecessor; a later real eviction
                ! or clobber will save the joined register value if needed.
                saved [ value swap key? ] all?
            ] [
                ! Keep existing loop-header planning while a backedge's
                ! exit state is unknown. Edge coupling still establishes
                ! every memory requirement selected by that planning.
                saved sift [ value swap key? ] any?
            ] if
        ] if
    ] if ;

:: make-entry-versions ( plan -- )
    plan choose-entry-values :> residents
    plan originals>> [ ##phi? ] filter [ dup dst>> swap ] H{ } map>assoc :> phis
    residents [| value |
        value phis at [ ] [
            ##phi new value rep-of next-vreg-rep >>dst
            H{ } clone >>inputs
            "repair-phis" spill-stat
        ] if* :> phi
        phi dst>> value plan entry-versions>> set-at
        phi value plan entry-phis>> set-at
        value plan entry-memory-valid?
        [ value plan saved-entry>> conjoin ] when
    ] each
    plan distances>> keys residents diff
    [ plan saved-entry>> conjoin ] each
    ! Every original nonresident phi becomes a memory phi. Its edge inputs
    ! are fixed memory names, never unallocated ordinary register vregs.
    phis [| value phi |
        value residents member? [ ] [
            phi value memory-name >>dst drop
            phi value plan memory-phis>> set-at
            value plan saved-entry>> conjoin
            "memory-phis" spill-stat
        ] if
    ] assoc-each ;

:: rewrite-spill-block ( plan -- )
    plan make-entry-versions
    plan entry-versions>> clone spill-W namespaces:set
    plan saved-entry>> clone spill-S namespaces:set
    V{ } clone spill-output namespaces:set
    plan entry-phis>> values [ spill-output get push ] each
    plan originals>> [| insn |
        insn ##phi? [
            insn plan entry-phis>> values member? [ ]
            [ insn spill-output get push ] if
        ] [
            insn plan afters>> at :> distances
            insn clobber-insn? insn gc-check-insn? or
            [ insn distances rewrite-clobber-insn ]
            [ insn distances rewrite-ordinary-insn ] if
        ] if
    ] each
    plan spill-W get clone >>exit-versions
    spill-S get clone >>saved-exit drop
    spill-output get plan bb>> instructions<< ;

:: edge-register-version ( value previous -- version )
    value previous exit-versions>> at [ ] [ value reload-value ] if* ;

:: couple-spill-edge ( previous plan -- )
    previous bb>> :> from
    plan bb>> :> to
    previous exit-versions>> clone spill-W namespaces:set
    previous saved-exit>> clone spill-S namespaces:set
    V{ } clone spill-output namespaces:set
    ! All stores precede reloads; parallel memory-phi copies follow later
    ! in SSA destruction, after their source homes have been initialized.
    plan saved-entry>> keys [| value |
        value plan from predecessor-value :> source
        source spill-W get key? [ source store-value ] when
    ] each
    IH{ } clone :> inputs
    plan entry-phis>> [| value phi |
        value plan from predecessor-value previous edge-register-version
        phi inputs set-at
    ] assoc-each
    plan memory-phis>> [| value phi |
        value plan from predecessor-value memory-name phi inputs set-at
    ] assoc-each
    from :> predecessor!
    spill-output get empty? [ ] [
        ##branch new spill-output get push
        spill-output get f insns>block :> edge
        from 1vector edge predecessors<<
        to 1vector edge successors<<
        from to edge update-predecessors
        from to edge update-successors
        edge predecessor!
        "edge-blocks" spill-stat
    ] if
    inputs [| phi version |
        from phi inputs>> delete-at
        version predecessor phi inputs>> set-at
    ] assoc-each ;

:: remove-unused-spill-phis ( cfg -- )
    cfg cfg>insns :> instructions
    instructions [ ##phi? ] filter :> phis
    H{ } clone :> needed
    instructions [ ##phi? ] reject
    [ spill-insn-uses [ needed conjoin ] each ] each
    t :> changed!
    [ changed ] [
        needed assoc-size :> before
        phis [| phi |
            phi dst>> needed key? [
                phi inputs>> values [ needed conjoin ] each
            ] when
        ] each
        needed assoc-size before = not changed!
    ] while
    cfg [| bb |
        bb [ [| insn |
            insn ##phi? [ insn dst>> needed key? not ] [ f ] if
            dup [ "dead-phis-removed" spill-stat ] when
        ] reject ] change-instructions drop
    ] each-basic-block ;

:: spill-ssa ( cfg available -- fixed-locations statistics )
    available spill-bank namespaces:set
    H{ } clone spill-homes namespaces:set
    H{ } clone spill-memory-locations namespaces:set
    H{ } clone spill-plans namespaces:set
    H{ } clone spill-statistics namespaces:set
    H{ } clone spill-def-renaming namespaces:set
    H{ } clone spill-slots namespaces:set
    cfg remove-unused-spill-phis
    representations get keys [ dup ] H{ } map>assoc leader-map namespaces:set
    cfg prepare-rematerialization
    cfg compute-next-uses nip :> exits
    cfg reverse-post-order >array :> blocks
    blocks [| bb | bb bb exits at new-spill-block bb spill-plans get set-at ] each
    blocks [ spill-plans get at rewrite-spill-block ] each
    blocks [| bb |
        bb successors>> clone [| successor |
            bb spill-plans get at successor spill-plans get at couple-spill-edge
        ] each
    ] each
    cfg cfg-changed
    spill-memory-locations get spill-statistics get ;
