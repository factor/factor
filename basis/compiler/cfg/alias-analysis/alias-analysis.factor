! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators.short-circuit
compiler.cfg.comparisons compiler.cfg.instructions
compiler.cfg.representations.preferred compiler.cfg.rpo
compiler.cfg.utilities cpu.architecture kernel math namespaces
sequences sets ;
IN: compiler.cfg.alias-analysis

! Local copy propagation
SYMBOL: copies

: resolve ( vreg -- vreg ) copies get ?at drop ;

: record-copy ( ##copy -- )
    [ src>> resolve ] [ dst>> ] bi copies get set-at ; inline

! Map vregs -> alias classes
SYMBOL: vregs>acs

! Map alias classes -> sequence of vregs
SYMBOL: acs>vregs

! Alias class for objects which are loaded from the data stack
! or other object slots. We pessimistically assume that they
! can all alias each other.
SYMBOL: heap-ac

: ac>vregs ( ac -- vregs )
    acs>vregs get [ drop V{ } clone ] cache ;

: vreg>ac ( vreg -- ac )
    ! Only vregs produced by ##allot, ##peek and ##slot can
    ! ever be used as valid inputs to ##slot and ##set-slot,
    ! so we assert this fact by not giving alias classes to
    ! other vregs.
    vregs>acs get [ heap-ac get [ ac>vregs push ] keep ] cache ;

: aliases ( vreg -- vregs )
    ! All vregs which may contain the same value as vreg.
    vreg>ac ac>vregs ;

: each-alias ( vreg quot -- )
    [ aliases ] dip each ; inline

: merge-acs ( vreg into -- )
    [ vreg>ac ] dip
    [ eq? ] [ 2drop ] [
        [ ac>vregs ] dip
        [ vregs>acs get '[ [ _ ] dip _ set-at ] each ]
        [ ac>vregs push-all ]
        2bi
    ] 2if ;

! Map vregs -> slot# -> vreg
SYMBOL: live-slots

! Maps vreg -> slot# -> insn# of last store or f
SYMBOL: recent-stores

! A set of insn#s of dead stores
SYMBOL: dead-stores

: dead-store ( insn# -- ) dead-stores get adjoin ;

ERROR: vreg-not-new vreg ;

:: set-ac ( vreg ac -- )
    ! Set alias class of newly-seen vreg.
    vreg vregs>acs get key? [ vreg vreg-not-new ] when
    ac vreg vregs>acs get set-at
    vreg ac ac>vregs push ;

: live-slot ( slot#/f vreg -- vreg' )
    ! If the slot number is unknown, we never reuse a previous
    ! value.
    over [ live-slots get at at ] [ 2drop f ] if ;

: load-constant-slot ( value slot# vreg -- )
    live-slots get [ drop H{ } clone ] cache set-at ;

: load-slot ( value slot#/f vreg -- )
    over [ load-constant-slot ] [ 3drop ] if ;

: record-constant-slot ( slot# vreg -- )
    ! A load can potentially read every store of this slot#
    ! in that alias class.
    [ recent-stores get at delete-at ] with each-alias ;

: record-computed-slot ( vreg -- )
    ! Computed load is like a load of every slot touched so far
    [ recent-stores get at clear-assoc ] each-alias ;

:: remember-slot ( value slot# vreg -- )
    slot# [
        slot# vreg record-constant-slot
        value slot# vreg load-constant-slot
    ] [ vreg record-computed-slot ] if ;

SYMBOL: ac-counter

: next-ac ( -- n )
    ac-counter [ dup 1 + ] change ;

: set-new-ac ( vreg -- ) next-ac set-ac ;

: kill-constant-set-slot ( slot# vreg -- )
    [ live-slots get at delete-at ] with each-alias ;

: recent-stores-of ( vreg -- assoc )
    recent-stores get [ drop H{ } clone ] cache ;

:: record-constant-set-slot ( insn# slot# vreg -- )
    vreg recent-stores-of :> recent-stores
    slot# recent-stores at [ dead-store ] when*
    insn# slot# recent-stores set-at ;

: kill-computed-set-slot ( vreg -- )
    [ live-slots get at clear-assoc ] each-alias ;

:: remember-set-slot ( insn# slot# vreg -- )
    slot# [
        insn# slot# vreg record-constant-set-slot
        slot# vreg kill-constant-set-slot
    ] [ vreg kill-computed-set-slot ] if ;

: init-alias-analysis ( -- )
    H{ } clone vregs>acs namespaces:set
    H{ } clone acs>vregs namespaces:set
    H{ } clone live-slots namespaces:set
    H{ } clone copies namespaces:set
    H{ } clone recent-stores namespaces:set
    HS{ } clone dead-stores namespaces:set
    0 ac-counter namespaces:set ;

GENERIC: insn-slot# ( insn -- slot#/f )
GENERIC: insn-object ( insn -- vreg )

M: ##slot insn-slot# drop f ;
M: ##slot-imm insn-slot# slot>> ;
M: ##set-slot insn-slot# drop f ;
M: ##set-slot-imm insn-slot# slot>> ;
M: ##alien-global insn-slot# [ library>> ] [ symbol>> ] bi 2array ;
M: ##vm-field insn-slot# offset>> ;
M: ##set-vm-field insn-slot# offset>> ;

M: ##slot insn-object obj>> resolve ;
M: ##slot-imm insn-object obj>> resolve ;
M: ##set-slot insn-object obj>> resolve ;
M: ##set-slot-imm insn-object obj>> resolve ;
M: ##alien-global insn-object drop ##alien-global ;
M: ##vm-field insn-object drop ##vm-field ;
M: ##set-vm-field insn-object drop ##vm-field ;

GENERIC: analyze-aliases ( insn -- insn' )

M: insn analyze-aliases ;

: def-acs ( insn -- insn' )
    ! If an instruction defines a value with a non-integer
    ! representation it means that the value will be boxed
    ! anywhere its used as a tagged pointer. Boxing allocates
    ! a new value, except boxing instructions haven't been
    ! inserted yet.
    dup [
        { int-rep tagged-rep } member?
        [ drop ] [ set-new-ac ] if
    ] each-def-rep ;

M: vreg-insn analyze-aliases
    def-acs ;

M: allocation-insn analyze-aliases
    ! A freshly allocated object is distinct from any other
    ! object.
    dup dst>> set-new-ac ;

M: ##box-displaced-alien analyze-aliases
    [ call-next-method ]
    [ base>> heap-ac get merge-acs ] bi ;

M: read-insn analyze-aliases
    call-next-method
    dup [ dst>> ] [ insn-slot# ] [ insn-object ] tri
    2dup live-slot dup
    [ 2nip <copy> analyze-aliases nip ]
    [ drop remember-slot ]
    if ;

: idempotent? ( value slot#/f vreg -- ? )
    ! Are we storing a value back to the same slot it was read
    ! from?
    live-slot = ;

M:: write-insn analyze-aliases ( insn -- insn )
    insn src>> resolve :> src
    insn insn-slot# :> slot#
    insn insn-object :> vreg
    insn insn#>> :> insn#

    src slot# vreg idempotent? [ insn# dead-store ] [
        src heap-ac get merge-acs
        insn insn#>> slot# vreg remember-set-slot
        src slot# vreg load-slot
    ] if

    insn ;

M: ##copy analyze-aliases
    ! The output vreg gets the same alias class as the input
    ! vreg, since they both contain the same value.
    dup record-copy ;

: useless-compare? ( insn -- ? )
    {
        [ cc>> cc= eq? ]
        [ [ src1>> ] [ src2>> ] bi [ resolve vreg>ac ] same? not ]
    } 1&& ; inline

M: ##compare analyze-aliases
    call-next-method
    dup useless-compare? [
        dst>> f ##load-reference new-insn
        analyze-aliases
    ] when ;

: clear-live-slots ( -- )
    heap-ac get ac>vregs [ live-slots get at clear-assoc ] each ;

: clear-recent-stores ( -- )
    recent-stores get values [ clear-assoc ] each ;

M: gc-map-insn analyze-aliases
    ! Can't use call-next-method here because of a limitation, gah
    def-acs
    clear-recent-stores ;

M: alien-call-insn analyze-aliases
    def-acs
    clear-recent-stores
    clear-live-slots ;

GENERIC: eliminate-dead-stores ( insn -- ? )

M: ##set-slot-imm eliminate-dead-stores
    insn#>> dead-stores get in? not ;

M: insn eliminate-dead-stores drop t ;

: reset-alias-analysis ( -- )
    recent-stores get clear-assoc
    vregs>acs get clear-assoc
    acs>vregs get clear-assoc
    live-slots get clear-assoc
    copies get clear-assoc
    dead-stores get clear-set

    next-ac heap-ac namespaces:set
    ##vm-field set-new-ac
    ##alien-global set-new-ac ;

: alias-analysis-step ( insns -- insns' )
    reset-alias-analysis
    [ 0 [ [ insn#<< ] [ drop 1 + ] 2bi ] reduce drop ]
    [ [ analyze-aliases ] map! [ eliminate-dead-stores ] filter! ] bi ;

: alias-analysis ( cfg -- )
    init-alias-analysis
    [ alias-analysis-step ] simple-optimization ;
