! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math namespaces assocs hashtables sequences
accessors vectors combinators sets compiler.vops compiler.cfg ;
IN: compiler.cfg.alias

! Alias analysis -- must be run after compiler.cfg.stack.
!
! We try to eliminate redundant slot and stack
! traffic using some simple heuristics.
! 
! All heap-allocated objects which are loaded from the stack, or
! other object slots are pessimistically assumed to belong to
! the same alias class.
!
! Freshly-allocated objects get their own alias class.
!
! The data and retain stack pointer registers are treated
! uniformly, and each one gets its own alias class.
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

: check [ "BUG: static type error detected" throw ] unless* ; inline
 
: vreg>ac ( vreg -- ac )
    #! Only vregs produced by %%allot, %peek and %%slot can
    #! ever be used as valid inputs to %%slot and %%set-slot,
    #! so we assert this fact by not giving alias classes to
    #! other vregs.
    vregs>acs get at check ;

! Map alias classes -> sequence of vregs
SYMBOL: acs>vregs

: ac>vregs ( ac -- vregs ) acs>vregs get at ;

: aliases ( vreg -- vregs )
    #! All vregs which may contain the same value as vreg.
    vreg>ac ac>vregs ;

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

: load-constant-slot ( value slot# vreg -- )
    live-slots get at check set-at ;

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
    ac-counter [ dup 1+ ] change ;

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
        dup empty? [ dup peek store? [ dup pop* ] when ] unless
        store new-action swap ?push
    ] change-at ;

: kill-computed-set-slot ( ac -- )
    [ live-slots get at clear-assoc ] each-alias ;

: remember-set-slot ( slot#/f vreg -- )
    over [
        [ record-constant-set-slot ]
        [ kill-constant-set-slot ] 2bi
    ] [ nip kill-computed-set-slot ] if ;

SYMBOL: copies

: resolve ( vreg -- vreg )
    dup copies get at swap or ;

SYMBOL: constants

: constant ( vreg -- n/f )
    #! Return an %iconst value, or f if the vreg was not
    #! assigned by an %iconst.
    resolve constants get at ;

! We treat slot accessors and stack traffic alike
GENERIC: insn-slot# ( insn -- slot#/f )
GENERIC: insn-object ( insn -- vreg )

M: %peek insn-slot# n>> ;
M: %replace insn-slot# n>> ;
M: %%slot insn-slot# slot>> constant ;
M: %%set-slot insn-slot# slot>> constant ;

M: %peek insn-object stack>> ;
M: %replace insn-object stack>> ;
M: %%slot insn-object obj>> resolve ;
M: %%set-slot insn-object obj>> resolve ;

: init-alias-analysis ( -- )
    H{ } clone histories set
    H{ } clone vregs>acs set
    H{ } clone acs>vregs set
    H{ } clone live-slots set
    H{ } clone constants set
    H{ } clone copies set

    0 ac-counter set
    next-ac heap-ac set

    %data next-ac set-ac
    %retain next-ac set-ac ;

GENERIC: analyze-aliases ( insn -- insn' )

M: %iconst analyze-aliases
    dup [ value>> ] [ out>> ] bi constants get set-at ;

M: %%allot analyze-aliases
    #! A freshly allocated object is distinct from any other
    #! object.
    dup out>> set-new-ac ;

M: read-op analyze-aliases
    dup out>> set-heap-ac
    dup [ out>> ] [ insn-slot# ] [ insn-object ] tri
    2dup live-slot dup [
        2nip %copy boa analyze-aliases nip
    ] [
        drop remember-slot
    ] if ;

: idempotent? ( value slot#/f vreg -- ? )
    #! Are we storing a value back to the same slot it was read
    #! from?
    live-slot = ;

M: write-op analyze-aliases
    dup
    [ in>> resolve ] [ insn-slot# ] [ insn-object ] tri
    3dup idempotent? [
        2drop 2drop nop
    ] [
        [ remember-set-slot drop ] [ load-slot ] 3bi
    ] if ;

M: %copy analyze-aliases
    #! The output vreg gets the same alias class as the input
    #! vreg, since they both contain the same value.
    dup [ in>> resolve ] [ out>> ] bi copies get set-at ;

M: vop analyze-aliases ;

SYMBOL: live-stores

: compute-live-stores ( -- )
    histories get
    values [
        values [ [ store? ] filter [ insn#>> ] map ] map concat
    ] map concat unique
    live-stores set ;

GENERIC: eliminate-dead-store ( insn -- insn' )

: (eliminate-dead-store) ( insn -- insn' )
    dup insn-slot# [
        insn# get live-stores get key? [
            drop nop
        ] unless
    ] when ;

M: %replace eliminate-dead-store
    #! Writes to above the top of the stack can be pruned also.
    #! This is sound since any such writes are not observable
    #! after the basic block, and any reads of those locations
    #! will have been converted to copies by analyze-slot,
    #! and the final stack height of the basic block is set at
    #! the beginning by compiler.cfg.stack.
    dup n>> 0 < [ drop nop ] [ (eliminate-dead-store) ] if ;

M: %%set-slot eliminate-dead-store (eliminate-dead-store) ;

M: vop eliminate-dead-store ;

: alias-analysis ( insns -- insns' )
    init-alias-analysis
    [ insn# set analyze-aliases ] map-index
    compute-live-stores
    [ insn# set eliminate-dead-store ] map-index ;
