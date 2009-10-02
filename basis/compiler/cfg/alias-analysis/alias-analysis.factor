! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math namespaces assocs hashtables sequences arrays
accessors words vectors combinators combinators.short-circuit
sets classes layouts cpu.architecture
compiler.cfg
compiler.cfg.rpo
compiler.cfg.def-use
compiler.cfg.liveness
compiler.cfg.copy-prop
compiler.cfg.registers
compiler.cfg.comparisons
compiler.cfg.instructions
compiler.cfg.representations.preferred ;
IN: compiler.cfg.alias-analysis

! We try to eliminate redundant slot operations using some simple heuristics.
! 
! All heap-allocated objects which are loaded from the stack, or
! other object slots are pessimistically assumed to belong to
! the same alias class.
!
! Freshly-allocated objects get their own alias class.
!
! Simple pseudo-C example showing load elimination:
! 
! int *x, *y, z: inputs
! int a, b, c, d, e: locals
! 
! Before alias analysis:
!
! a = x[2]
! b = x[2]
! c = x[3]
! y[2] = z
! d = x[2]
! e = y[2]
! f = x[3]
!
! After alias analysis:
!
! a = x[2]
! b = a /* ELIMINATED */
! c = x[3]
! y[2] = z
! d = x[2] /* if x=y, d=z, if x!=y, d=b; NOT ELIMINATED */
! e = z /* ELIMINATED */
! f = c /* ELIMINATED */
!
! Simple pseudo-C example showing store elimination:
!
! Before alias analysis:
!
! x[0] = a
! b = x[n]
! x[0] = c
! x[1] = d
! e = x[0]
! x[1] = c
!
! After alias analysis:
!
! x[0] = a /* dead if n = 0, live otherwise; NOT ELIMINATED */
! b = x[n]
! x[0] = c
! /* x[1] = d */  /* ELIMINATED */
! e = c
! x[1] = c

! Map vregs -> alias classes
SYMBOL: vregs>acs

ERROR: vreg-ac-not-set vreg ;

: vreg>ac ( vreg -- ac )
    #! Only vregs produced by ##allot, ##peek and ##slot can
    #! ever be used as valid inputs to ##slot and ##set-slot,
    #! so we assert this fact by not giving alias classes to
    #! other vregs.
    vregs>acs get ?at [ vreg-ac-not-set ] unless ;

! Map alias classes -> sequence of vregs
SYMBOL: acs>vregs

: ac>vregs ( ac -- vregs ) acs>vregs get at ;

GENERIC: aliases ( vreg -- vregs )

M: integer aliases
    #! All vregs which may contain the same value as vreg.
    vreg>ac ac>vregs ;

M: word aliases
    1array ;

: each-alias ( vreg quot -- )
    [ aliases ] dip each ; inline

! Map vregs -> slot# -> vreg
SYMBOL: live-slots

! Current instruction number
SYMBOL: insn#

! Load/store history, for dead store elimination
TUPLE: load insn# ;
TUPLE: store insn# ;

: new-action ( class -- action )
    insn# get swap boa ; inline

! Maps vreg -> slot# -> sequence of loads/stores
SYMBOL: histories

: history ( vreg -- history ) histories get at ;

: set-ac ( vreg ac -- )
    #! Set alias class of newly-seen vreg.
    {
        [ drop H{ } clone swap histories get set-at ]
        [ drop H{ } clone swap live-slots get set-at ]
        [ swap vregs>acs get set-at ]
        [ acs>vregs get push-at ]
    } 2cleave ;

: live-slot ( slot#/f vreg -- vreg' )
    #! If the slot number is unknown, we never reuse a previous
    #! value.
    over [ live-slots get at at ] [ 2drop f ] if ;

ERROR: vreg-has-no-slots vreg ;

: load-constant-slot ( value slot# vreg -- )
    live-slots get ?at [ vreg-has-no-slots ] unless set-at ;

: load-slot ( value slot#/f vreg -- )
    over [ load-constant-slot ] [ 3drop ] if ;

: record-constant-slot ( slot# vreg -- )
    #! A load can potentially read every store of this slot#
    #! in that alias class.
    [
        history [ load new-action swap ?push ] change-at
    ] with each-alias ;

: record-computed-slot ( vreg -- )
    #! Computed load is like a load of every slot touched so far
    [
        history values [ load new-action swap push ] each
    ] each-alias ;

: remember-slot ( value slot#/f vreg -- )
    over
    [ [ record-constant-slot ] [ load-constant-slot ] 2bi ]
    [ 2nip record-computed-slot ] if ;

SYMBOL: ac-counter

: next-ac ( -- n )
    ac-counter [ dup 1 + ] change ;

! Alias class for objects which are loaded from the data stack
! or other object slots. We pessimistically assume that they
! can all alias each other.
SYMBOL: heap-ac

: set-heap-ac ( vreg -- ) heap-ac get set-ac ;

: set-new-ac ( vreg -- ) next-ac set-ac ;

: kill-constant-set-slot ( slot# vreg -- )
    [ live-slots get at delete-at ] with each-alias ;

: record-constant-set-slot ( slot# vreg -- )
    history [
        dup empty? [ dup last store? [ dup pop* ] when ] unless
        store new-action swap ?push
    ] change-at ;

: kill-computed-set-slot ( ac -- )
    [ live-slots get at clear-assoc ] each-alias ;

: remember-set-slot ( slot#/f vreg -- )
    over [
        [ record-constant-set-slot ]
        [ kill-constant-set-slot ] 2bi
    ] [ nip kill-computed-set-slot ] if ;

SYMBOL: constants

: constant ( vreg -- n/f )
    #! Return a ##load-immediate value, or f if the vreg was not
    #! assigned by an ##load-immediate.
    resolve constants get at ;

GENERIC: insn-slot# ( insn -- slot#/f )
GENERIC: insn-object ( insn -- vreg )

M: ##slot insn-slot# slot>> constant ;
M: ##slot-imm insn-slot# slot>> ;
M: ##set-slot insn-slot# slot>> constant ;
M: ##set-slot-imm insn-slot# slot>> ;
M: ##alien-global insn-slot# [ library>> ] [ symbol>> ] bi 2array ;
M: ##vm-field-ptr insn-slot# field-name>> ;

M: ##slot insn-object obj>> resolve ;
M: ##slot-imm insn-object obj>> resolve ;
M: ##set-slot insn-object obj>> resolve ;
M: ##set-slot-imm insn-object obj>> resolve ;
M: ##alien-global insn-object drop \ ##alien-global ;
M: ##vm-field-ptr insn-object drop \ ##vm-field-ptr ;

: init-alias-analysis ( insns -- insns' )
    H{ } clone histories set
    H{ } clone vregs>acs set
    H{ } clone acs>vregs set
    H{ } clone live-slots set
    H{ } clone constants set
    H{ } clone copies set

    0 ac-counter set
    next-ac heap-ac set

    \ ##vm-field-ptr set-new-ac
    \ ##alien-global set-new-ac

    dup local-live-in [ set-heap-ac ] each ;

GENERIC: analyze-aliases* ( insn -- insn' )

M: insn analyze-aliases*
    ! If an instruction defines a value with a non-integer
    ! representation it means that the value will be boxed
    ! anywhere its used as a tagged pointer. Boxing allocates
    ! a new value, except boxing instructions haven't been
    ! inserted yet.
    dup defs-vreg [
        over defs-vreg-rep int-rep eq?
        [ set-heap-ac ] [ set-new-ac ] if
    ] when* ;

M: ##phi analyze-aliases*
    dup defs-vreg set-heap-ac ;

M: ##load-immediate analyze-aliases*
    call-next-method
    dup [ val>> ] [ dst>> ] bi constants get set-at ;

M: ##allocation analyze-aliases*
    #! A freshly allocated object is distinct from any other
    #! object.
    dup dst>> set-new-ac ;

M: ##read analyze-aliases*
    call-next-method
    dup [ dst>> ] [ insn-slot# ] [ insn-object ] tri
    2dup live-slot dup [
        2nip any-rep \ ##copy new-insn analyze-aliases* nip
    ] [
        drop remember-slot
    ] if ;

: idempotent? ( value slot#/f vreg -- ? )
    #! Are we storing a value back to the same slot it was read
    #! from?
    live-slot = ;

M: ##write analyze-aliases*
    dup
    [ src>> resolve ] [ insn-slot# ] [ insn-object ] tri
    [ remember-set-slot drop ] [ load-slot ] 3bi ;

M: ##copy analyze-aliases*
    #! The output vreg gets the same alias class as the input
    #! vreg, since they both contain the same value.
    dup record-copy ;

: useless-compare? ( insn -- ? )
    {
        [ cc>> cc= eq? ]
        [ [ src1>> vreg>ac ] [ src2>> vreg>ac ] bi = not ]
    } 1&& ; inline

M: ##compare analyze-aliases*
    call-next-method
    dup useless-compare? [
        dst>> \ f tag-number \ ##load-immediate new-insn
        analyze-aliases*
    ] when ;

: analyze-aliases ( insns -- insns' )
    [ insn# set analyze-aliases* ] map-index sift ;

SYMBOL: live-stores

: compute-live-stores ( -- )
    histories get
    values [
        values [ [ store? ] filter [ insn#>> ] map ] map concat
    ] map concat unique
    live-stores set ;

GENERIC: eliminate-dead-stores* ( insn -- insn' )

: (eliminate-dead-stores) ( insn -- insn' )
    dup insn-slot# [
        insn# get live-stores get key? [
            drop f
        ] unless
    ] when ;

M: ##set-slot eliminate-dead-stores* (eliminate-dead-stores) ;

M: ##set-slot-imm eliminate-dead-stores* (eliminate-dead-stores) ;

M: insn eliminate-dead-stores* ;

: eliminate-dead-stores ( insns -- insns' )
    [ insn# set eliminate-dead-stores* ] map-index sift ;

: alias-analysis-step ( insns -- insns' )
    init-alias-analysis
    analyze-aliases
    compute-live-stores
    eliminate-dead-stores ;

: alias-analysis ( cfg -- cfg' )
    [ alias-analysis-step ] local-optimization ;
