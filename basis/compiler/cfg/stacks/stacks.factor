! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes classes.private classes.algebra
combinators hashtables kernel layouts math fry namespaces
quotations sequences system vectors words effects alien
byte-arrays accessors sets math.order cpu.architecture
compiler.cfg.instructions compiler.cfg.registers ;
IN: compiler.cfg.stacks

! Converting stack operations into register operations, while
! doing a bit of optimization along the way.
SYMBOL: known-tag

PREDICATE: small-slot < integer cells small-enough? ;

PREDICATE: small-tagged < integer tag-fixnum small-enough? ;

! Value protocol
GENERIC: move-spec ( obj -- spec )
GENERIC: live-loc? ( actual current -- ? )
GENERIC# (lazy-load) 1 ( value spec -- value )
GENERIC# (eager-load) 1 ( value spec -- value )
GENERIC: lazy-store ( dst src -- )
GENERIC: minimal-ds-loc* ( min obj -- min )

! This will be a multimethod soon
DEFER: %move

PRIVATE>

! Default implementation
M: value live-loc? 2drop f ;
M: value minimal-ds-loc* drop ;
M: value lazy-store 2drop ;

M: vreg move-spec reg-class>> move-spec ;
M: vreg value-class* reg-class>> value-class* ;

M: int-regs move-spec drop f ;
M: int-regs value-class* drop object ;

M: float-regs move-spec drop float ;
M: float-regs value-class* drop float ;

M: ds-loc minimal-ds-loc* n>> min ;
M: ds-loc live-loc?
    over ds-loc? [ [ n>> ] bi@ = not ] [ 2drop t ] if ;

M: rs-loc live-loc?
    over rs-loc? [ [ n>> ] bi@ = not ] [ 2drop t ] if ;

M: loc value-class* class>> ;
M: loc set-value-class (>>class) ;
M: loc move-spec drop loc ;

M: f move-spec drop loc ;
M: f value-class* ;

M: cached move-spec drop cached ;
M: cached live-loc? loc>> live-loc? ;
M: cached (lazy-load) >r vreg>> r> (lazy-load) ;
M: cached (eager-load) >r vreg>> r> (eager-load) ;
M: cached lazy-store
    2dup loc>> live-loc?
    [ "live-locs" get at %move ] [ 2drop ] if ;
M: cached minimal-ds-loc* loc>> minimal-ds-loc* ;

M: tagged move-spec drop f ;

M: unboxed-alien move-spec class ;

M: unboxed-byte-array move-spec class ;

M: unboxed-f move-spec class ;

M: unboxed-c-ptr move-spec class ;

M: constant move-spec class ;

! Moving values between locations and registers
: %move-bug ( -- * ) "Bug in generator.registers" throw ;

: %unbox-c-ptr ( dst src -- )
    dup value-class {
        { [ dup \ f class<= ] [ drop ##unbox-f ] }
        { [ dup simple-alien class<= ] [ drop ##unbox-alien ] }
        { [ dup byte-array class<= ] [ drop ##unbox-byte-array ] }
        [ drop ##unbox-any-c-ptr ]
    } cond ; inline

: %move-via-temp ( dst src -- )
    #! For many transfers, such as loc to unboxed-alien, we
    #! don't have an intrinsic, so we transfer the source to
    #! temp then temp to the destination.
    int-regs next-vreg [ over %move value-class ] keep
    tagged new
        swap >>vreg
        swap >>class
    %move ;

! Operands holding pointers to freshly-allocated objects which
! are guaranteed to be in the nursery
SYMBOL: fresh-objects

: fresh-object ( vreg/t -- ) fresh-objects get push ;

: fresh-object? ( vreg -- ? ) fresh-objects get memq? ;

: %move ( dst src -- )
    2dup [ move-spec ] bi@ 2array {
        { { f f } [ ##copy ] }
        { { unboxed-alien unboxed-alien } [ ##copy ] }
        { { unboxed-byte-array unboxed-byte-array } [ ##copy ] }
        { { unboxed-f unboxed-f } [ ##copy ] }
        { { unboxed-c-ptr unboxed-c-ptr } [ ##copy ] }
        { { float float } [ ##copy-float ] }

        { { f unboxed-c-ptr } [ %move-bug ] }
        { { f unboxed-byte-array } [ %move-bug ] }

        { { f constant } [ value>> ##load-literal ] }

        { { f float } [ int-regs next-vreg ##box-float t fresh-object ] }
        { { f unboxed-alien } [ int-regs next-vreg ##box-alien t fresh-object ] }
        { { f loc } [ ##peek ] }

        { { float f } [ ##unbox-float ] }
        { { unboxed-alien f } [ ##unbox-alien ] }
        { { unboxed-byte-array f } [ ##unbox-byte-array ] }
        { { unboxed-f f } [ ##unbox-f ] }
        { { unboxed-c-ptr f } [ %unbox-c-ptr ] }
        { { loc f } [ swap ##replace ] }

        [ drop %move-via-temp ]
    } case ;

! A compile-time stack
TUPLE: phantom-stack height stack ;

M: phantom-stack clone
    call-next-method [ clone ] change-stack ;

GENERIC: finalize-height ( stack -- )

: new-phantom-stack ( class -- stack )
    >r 0 V{ } clone r> boa ; inline

: (loc) ( m stack -- n )
    #! Utility for methods on <loc>
    height>> - ;

: (finalize-height) ( stack word -- )
    #! We consolidate multiple stack height changes until the
    #! last moment, and we emit the final height changing
    #! instruction here.
    '[ dup zero? [ drop ] [ _ execute ] if 0 ] change-height drop ; inline

GENERIC: <loc> ( n stack -- loc )

TUPLE: phantom-datastack < phantom-stack ;

: <phantom-datastack> ( -- stack )
    phantom-datastack new-phantom-stack ;

M: phantom-datastack <loc> (loc) <ds-loc> ;

M: phantom-datastack finalize-height
    \ ##inc-d (finalize-height) ;

TUPLE: phantom-retainstack < phantom-stack ;

: <phantom-retainstack> ( -- stack )
    phantom-retainstack new-phantom-stack ;

M: phantom-retainstack <loc> (loc) <rs-loc> ;

M: phantom-retainstack finalize-height
    \ ##inc-r (finalize-height) ;

: phantom-locs ( n phantom -- locs )
    #! A sequence of n ds-locs or rs-locs indexing the stack.
    >r <reversed> r> '[ _ <loc> ] map ;

: phantom-locs* ( phantom -- locs )
    [ stack>> length ] keep phantom-locs ;

: phantoms ( -- phantom phantom )
    phantom-datastack get phantom-retainstack get ;

: (each-loc) ( phantom quot -- )
    >r [ phantom-locs* ] [ stack>> ] bi r> 2each ; inline

: each-loc ( quot -- )
    phantoms 2array swap '[ _ (each-loc) ] each ; inline

: adjust-phantom ( n phantom -- )
    swap '[ _ + ] change-height drop ;

: cut-phantom ( n phantom -- seq )
    swap '[ _ cut* swap ] change-stack drop ;

: phantom-append ( seq stack -- )
    over length over adjust-phantom stack>> push-all ;

: add-locs ( n phantom -- )
    2dup stack>> length <= [
        2drop
    ] [
        [ phantom-locs ] keep
        [ stack>> length head-slice* ] keep
        [ append >vector ] change-stack drop
    ] if ;

: phantom-input ( n phantom -- seq )
    2dup add-locs
    2dup cut-phantom
    >r >r neg r> adjust-phantom r> ;

: each-phantom ( quot -- ) phantoms rot bi@ ; inline

: finalize-heights ( -- ) [ finalize-height ] each-phantom ;

: (live-locs) ( phantom -- seq )
    #! Discard locs which haven't moved
    [ phantom-locs* ] [ stack>> ] bi zip
    [ live-loc? ] assoc-filter
    values ;

: live-locs ( -- seq )
    [ (live-locs) ] each-phantom append prune ;

: reg-spec>class ( spec -- class )
    float eq? double-float-regs int-regs ? ;

: alloc-vreg ( spec -- reg )
    [ reg-spec>class next-vreg ] keep {
        { f [ <tagged> ] }
        { unboxed-alien [ <unboxed-alien> ] }
        { unboxed-byte-array [ <unboxed-byte-array> ] }
        { unboxed-f [ <unboxed-f> ] }
        { unboxed-c-ptr [ <unboxed-c-ptr> ] }
        [ drop ]
    } case ;

: compatible? ( value spec -- ? )
    >r move-spec r> {
        { [ 2dup = ] [ t ] }
        { [ dup unboxed-c-ptr eq? ] [
            over { unboxed-byte-array unboxed-alien } member?
        ] }
        [ f ]
    } cond 2nip ;

: alloc-vreg-for ( value spec -- vreg )
    alloc-vreg swap value-class
    over tagged? [ >>class ] [ drop ] if ;

M: value (lazy-load)
    {
        { [ dup { small-slot small-tagged } memq? ] [ drop ] }
        { [ 2dup compatible? ] [ drop ] }
        [ (eager-load) ]
    } cond ;

M: value (eager-load) ( value spec -- vreg )
    [ alloc-vreg-for ] [ drop ] 2bi
    [ %move ] [ drop ] 2bi ;

M: loc lazy-store
    2dup live-loc? [ "live-locs" get at %move ] [ 2drop ] if ;

: finalize-locs ( -- )
    #! Perform any deferred stack shuffling.
    live-locs [ dup f (lazy-load) ] H{ } map>assoc
    dup assoc-empty? [ drop ] [
        "live-locs" set [ lazy-store ] each-loc
    ] if ;

: finalize-vregs ( -- )
    #! Store any vregs to their final stack locations.
    [
        dup loc? over cached? or [ 2drop ] [ %move ] if
    ] each-loc ;

: clear-phantoms ( -- )
    [ stack>> delete-all ] each-phantom ;

: finalize-contents ( -- )
    finalize-locs finalize-vregs clear-phantoms ;

! Loading stacks to vregs
: vreg-substitution ( value vreg -- pair )
    dupd <cached> 2array ;

: substitute-vreg? ( old new -- ? )
    #! We don't substitute locs for float or alien vregs,
    #! since in those cases the boxing overhead might kill us.
    vreg>> tagged? >r loc? r> and ;

: substitute-vregs ( values vregs -- )
    [ vreg-substitution ] 2map
    [ substitute-vreg? ] assoc-filter >hashtable
    '[ stack>> _ substitute-here ] each-phantom ;

: set-value-classes ( classes -- )
    phantom-datastack get
    over length over add-locs
    stack>> [
        [ value-class class-and ] keep set-value-class
    ] 2reverse-each ;

: finalize-phantoms ( -- )
    #! Commit all deferred stacking shuffling, and ensure the
    #! in-memory data and retain stacks are up to date with
    #! respect to the compiler's current picture.
    finalize-contents
    finalize-heights
    fresh-objects get [
        empty? [ ##simple-stack-frame ##gc ] unless
    ] [ delete-all ] bi ;

: init-phantoms ( -- )
    V{ } clone fresh-objects set
    <phantom-datastack> phantom-datastack set
    <phantom-retainstack> phantom-retainstack set ;

: copy-phantoms ( -- )
    fresh-objects [ clone ] change
    phantom-datastack [ clone ] change
    phantom-retainstack [ clone ] change ;

: phantom-push ( obj -- )
    1 phantom-datastack get adjust-phantom
    phantom-datastack get stack>> push ;

: phantom-shuffle ( shuffle -- )
    [ in>> length phantom-datastack get phantom-input ] keep
    shuffle phantom-datastack get phantom-append ;

: phantom->r ( n -- )
    phantom-datastack get phantom-input
    phantom-retainstack get phantom-append ;

: phantom-r> ( n -- )
    phantom-retainstack get phantom-input
    phantom-datastack get phantom-append ;

: phantom-drop ( n -- )
    phantom-datastack get phantom-input drop ;

: phantom-rdrop ( n -- )
    phantom-retainstack get phantom-input drop ;

: phantom-pop ( -- vreg )
    1 phantom-datastack get phantom-input dup first f (lazy-load)
    [ 1array substitute-vregs ] keep ;
