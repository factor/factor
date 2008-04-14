! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes classes.private classes.algebra
combinators cpu.architecture generator.fixup hashtables kernel
layouts math namespaces quotations sequences system vectors
words effects alien byte-arrays bit-arrays float-arrays
accessors sets ;
IN: generator.registers

SYMBOL: +input+
SYMBOL: +output+
SYMBOL: +scratch+
SYMBOL: +clobber+
SYMBOL: known-tag

! Register classes
SINGLETON: int-regs
SINGLETON: single-float-regs
SINGLETON: double-float-regs
UNION: float-regs single-float-regs double-float-regs ;
UNION: reg-class int-regs float-regs ;

<PRIVATE

! Value protocol
GENERIC: set-operand-class ( class obj -- )
GENERIC: operand-class* ( operand -- class )
GENERIC: move-spec ( obj -- spec )
GENERIC: live-vregs* ( obj -- )
GENERIC: live-loc? ( actual current -- ? )
GENERIC# (lazy-load) 1 ( value spec -- value )
GENERIC: lazy-store ( dst src -- )
GENERIC: minimal-ds-loc* ( min obj -- min )

! This will be a multimethod soon
DEFER: %move

MIXIN: value

PRIVATE>

: operand-class ( operand -- class )
    operand-class* object or ;

! Default implementation
M: value set-operand-class 2drop ;
M: value operand-class* drop f ;
M: value live-vregs* drop ;
M: value live-loc? 2drop f ;
M: value minimal-ds-loc* drop ;
M: value lazy-store 2drop ;

! A scratch register for computations
TUPLE: vreg n reg-class ;

C: <vreg> vreg ( n reg-class -- vreg )

M: vreg v>operand [ n>> ] [ reg-class>> ] bi vregs nth ;
M: vreg live-vregs* , ;
M: vreg move-spec reg-class>> move-spec ;

INSTANCE: vreg value

M: float-regs move-spec drop float ;
M: float-regs operand-class* drop float ;

! Temporary register for stack shuffling
TUPLE: temp-reg reg-class>> ;

: temp-reg T{ temp-reg f int-regs } ;

M: temp-reg move-spec drop f ;

INSTANCE: temp-reg value

! A data stack location.
TUPLE: ds-loc n class ;

: <ds-loc> f ds-loc boa ;

M: ds-loc minimal-ds-loc* ds-loc-n min ;
M: ds-loc operand-class* ds-loc-class ;
M: ds-loc set-operand-class set-ds-loc-class ;
M: ds-loc live-loc?
    over ds-loc? [ [ ds-loc-n ] bi@ = not ] [ 2drop t ] if ;

! A retain stack location.
TUPLE: rs-loc n class ;

: <rs-loc> f rs-loc boa ;
M: rs-loc operand-class* rs-loc-class ;
M: rs-loc set-operand-class set-rs-loc-class ;
M: rs-loc live-loc?
    over rs-loc? [ [ rs-loc-n ] bi@ = not ] [ 2drop t ] if ;

UNION: loc ds-loc rs-loc ;

M: loc move-spec drop loc ;

INSTANCE: loc value

M: f move-spec drop loc ;
M: f operand-class* ;

! A stack location which has been loaded into a register. To
! read the location, we just read the register, but when time
! comes to save it back to the stack, we know the register just
! contains a stack value so we don't have to redundantly write
! it back.
TUPLE: cached loc vreg ;

C: <cached> cached

M: cached set-operand-class cached-vreg set-operand-class ;
M: cached operand-class* cached-vreg operand-class* ;
M: cached move-spec drop cached ;
M: cached live-vregs* cached-vreg live-vregs* ;
M: cached live-loc? cached-loc live-loc? ;
M: cached (lazy-load) >r cached-vreg r> (lazy-load) ;
M: cached lazy-store
    2dup cached-loc live-loc?
    [ "live-locs" get at %move ] [ 2drop ] if ;
M: cached minimal-ds-loc* cached-loc minimal-ds-loc* ;

INSTANCE: cached value

! A tagged pointer
TUPLE: tagged vreg class ;

: <tagged> ( vreg -- tagged )
    f tagged boa ;

M: tagged v>operand tagged-vreg v>operand ;
M: tagged set-operand-class set-tagged-class ;
M: tagged operand-class* tagged-class ;
M: tagged move-spec drop f ;
M: tagged live-vregs* tagged-vreg , ;

INSTANCE: tagged value

! Unboxed alien pointers
TUPLE: unboxed-alien vreg ;
C: <unboxed-alien> unboxed-alien
M: unboxed-alien v>operand unboxed-alien-vreg v>operand ;
M: unboxed-alien operand-class* drop simple-alien ;
M: unboxed-alien move-spec class ;
M: unboxed-alien live-vregs* unboxed-alien-vreg , ;

INSTANCE: unboxed-alien value

TUPLE: unboxed-byte-array vreg ;
C: <unboxed-byte-array> unboxed-byte-array
M: unboxed-byte-array v>operand unboxed-byte-array-vreg v>operand ;
M: unboxed-byte-array operand-class* drop c-ptr ;
M: unboxed-byte-array move-spec class ;
M: unboxed-byte-array live-vregs* unboxed-byte-array-vreg , ;

INSTANCE: unboxed-byte-array value

TUPLE: unboxed-f vreg ;
C: <unboxed-f> unboxed-f
M: unboxed-f v>operand unboxed-f-vreg v>operand ;
M: unboxed-f operand-class* drop \ f ;
M: unboxed-f move-spec class ;
M: unboxed-f live-vregs* unboxed-f-vreg , ;

INSTANCE: unboxed-f value

TUPLE: unboxed-c-ptr vreg ;
C: <unboxed-c-ptr> unboxed-c-ptr
M: unboxed-c-ptr v>operand unboxed-c-ptr-vreg v>operand ;
M: unboxed-c-ptr operand-class* drop c-ptr ;
M: unboxed-c-ptr move-spec class ;
M: unboxed-c-ptr live-vregs* unboxed-c-ptr-vreg , ;

INSTANCE: unboxed-c-ptr value

! A constant value
TUPLE: constant value ;
C: <constant> constant
M: constant operand-class* constant-value class ;
M: constant move-spec class ;

INSTANCE: constant value

<PRIVATE

! Moving values between locations and registers
: %move-bug "Bug in generator.registers" throw ;

: %unbox-c-ptr ( dst src -- )
    dup operand-class {
        { [ dup \ f class< ] [ drop %unbox-f ] }
        { [ dup simple-alien class< ] [ drop %unbox-alien ] }
        { [ dup byte-array class< ] [ drop %unbox-byte-array ] }
        { [ dup bit-array class< ] [ drop %unbox-byte-array ] }
        { [ dup float-array class< ] [ drop %unbox-byte-array ] }
        [ drop %unbox-any-c-ptr ]
    } cond ; inline

: %move-via-temp ( dst src -- )
    #! For many transfers, such as loc to unboxed-alien, we
    #! don't have an intrinsic, so we transfer the source to
    #! temp then temp to the destination.
    temp-reg over %move
    operand-class temp-reg
    { set-operand-class set-tagged-vreg } tagged construct
    %move ;

: %move ( dst src -- )
    2dup [ move-spec ] bi@ 2array {
        { { f f } [ %move-bug ] }
        { { f unboxed-c-ptr } [ %move-bug ] }
        { { f unboxed-byte-array } [ %move-bug ] }

        { { f constant } [ constant-value swap load-literal ] }

        { { f float } [ %box-float ] }
        { { f unboxed-alien } [ %box-alien ] }
        { { f loc } [ %peek ] }

        { { float f } [ %unbox-float ] }
        { { unboxed-alien f } [ %unbox-alien ] }
        { { unboxed-byte-array f } [ %unbox-byte-array ] }
        { { unboxed-f f } [ %unbox-f ] }
        { { unboxed-c-ptr f } [ %unbox-c-ptr ] }
        { { loc f } [ swap %replace ] }

        [ drop %move-via-temp ]
    } case ;

! A compile-time stack
TUPLE: phantom-stack height stack ;

M: phantom-stack clone
    call-next-method [ clone ] change-stack ;

GENERIC: finalize-height ( stack -- )

: construct-phantom-stack ( class -- stack )
    >r 0 V{ } clone r> boa ; inline

: (loc)
    #! Utility for methods on <loc>
    height>> - ;

: (finalize-height) ( stack word -- )
    #! We consolidate multiple stack height changes until the
    #! last moment, and we emit the final height changing
    #! instruction here.
    [
        over zero? [ 2drop ] [ execute ] if 0
    ] curry change-height drop ; inline

GENERIC: <loc> ( n stack -- loc )

TUPLE: phantom-datastack < phantom-stack ;

: <phantom-datastack> ( -- stack )
    phantom-datastack construct-phantom-stack ;

M: phantom-datastack <loc> (loc) <ds-loc> ;

M: phantom-datastack finalize-height
    \ %inc-d (finalize-height) ;

TUPLE: phantom-retainstack < phantom-stack ;

: <phantom-retainstack> ( -- stack )
    phantom-retainstack construct-phantom-stack ;

M: phantom-retainstack <loc> (loc) <rs-loc> ;

M: phantom-retainstack finalize-height
    \ %inc-r (finalize-height) ;

: phantom-locs ( n phantom -- locs )
    #! A sequence of n ds-locs or rs-locs indexing the stack.
    >r <reversed> r> [ <loc> ] curry map ;

: phantom-locs* ( phantom -- locs )
    [ stack>> length ] keep phantom-locs ;

: phantoms ( -- phantom phantom )
    phantom-datastack get phantom-retainstack get ;

: (each-loc) ( phantom quot -- )
    >r [ phantom-locs* ] [ stack>> ] bi r> 2each ; inline

: each-loc ( quot -- )
    phantoms 2array swap [ (each-loc) ] curry each ; inline

: adjust-phantom ( n phantom -- )
    swap [ + ] curry change-height drop ;

: cut-phantom ( n phantom -- seq )
    swap [ cut* swap ] curry change-stack drop ;

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

: live-vregs ( -- seq )
    [ [ stack>> [ live-vregs* ] each ] each-phantom ] { } make ;

: (live-locs) ( phantom -- seq )
    #! Discard locs which haven't moved
    [ phantom-locs* ] [ stack>> ] bi zip
    [ live-loc? ] assoc-subset
    values ;

: live-locs ( -- seq )
    [ (live-locs) ] each-phantom append prune ;

! Operands holding pointers to freshly-allocated objects which
! are guaranteed to be in the nursery
SYMBOL: fresh-objects

! Computing free registers and initializing allocator
: reg-spec>class ( spec -- class )
    float eq? double-float-regs int-regs ? ;

: free-vregs ( reg-class -- seq )
    #! Free vregs in a given register class
    \ free-vregs get at ;

: alloc-vreg ( spec -- reg )
    [ reg-spec>class free-vregs pop ] keep {
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

: allocation ( value spec -- reg-class )
    {
        { [ dup quotation? ] [ 2drop f ] }
        { [ 2dup compatible? ] [ 2drop f ] }
        [ nip reg-spec>class ]
    } cond ;

: alloc-vreg-for ( value spec -- vreg )
    alloc-vreg swap operand-class
    over tagged? [ >>class ] [ drop ] if ;

M: value (lazy-load)
    2dup allocation [
        dupd alloc-vreg-for dup rot %move
    ] [
        drop
    ] if ;

: (compute-free-vregs) ( used class -- vector )
    #! Find all vregs in 'class' which are not in 'used'.
    [ vregs length reverse ] keep
    [ <vreg> ] curry map diff
    >vector ;

: compute-free-vregs ( -- )
    #! Create a new hashtable for thee free-vregs variable.
    live-vregs
    { int-regs double-float-regs }
    [ 2dup (compute-free-vregs) ] H{ } map>assoc
    \ free-vregs set
    drop ;

M: loc lazy-store
    2dup live-loc? [ "live-locs" get at %move ] [ 2drop ] if ;

: do-shuffle ( hash -- )
    dup assoc-empty? [
        drop
    ] [
        "live-locs" set
        [ lazy-store ] each-loc
    ] if ;

: fast-shuffle ( locs -- )
    #! We have enough free registers to load all shuffle inputs
    #! at once
    [ dup f (lazy-load) ] H{ } map>assoc do-shuffle ;

: minimal-ds-loc ( phantom -- n )
    #! When shuffling more values than can fit in registers, we
    #! need to find an area on the data stack which isn't in
    #! use.
    [ stack>> ] [ height>> neg ] bi [ minimal-ds-loc* ] reduce ;

: find-tmp-loc ( -- n )
    #! Find an area of the data stack which is not referenced
    #! from the phantom stacks. We can clobber there all we want
    [ minimal-ds-loc ] each-phantom min 1- ;

: slow-shuffle-mapping ( locs tmp -- pairs )
    >r dup length r>
    [ swap - <ds-loc> ] curry map zip ;

: slow-shuffle ( locs -- )
    #! We don't have enough free registers to load all shuffle
    #! inputs, so we use a single temporary register, together
    #! with the area of the data stack above the stack pointer
    find-tmp-loc slow-shuffle-mapping [
        [
            swap dup cached? [ cached-vreg ] when %move
        ] assoc-each
    ] keep >hashtable do-shuffle ;

: fast-shuffle? ( live-locs -- ? )
    #! Test if we have enough free registers to load all
    #! shuffle inputs at once.
    int-regs free-vregs [ length ] bi@ <= ;

: finalize-locs ( -- )
    #! Perform any deferred stack shuffling.
    [
        \ free-vregs [ [ clone ] assoc-map ] change
        live-locs dup fast-shuffle?
        [ fast-shuffle ] [ slow-shuffle ] if
    ] with-scope ;

: finalize-vregs ( -- )
    #! Store any vregs to their final stack locations.
    [
        dup loc? over cached? or [ 2drop ] [ %move ] if
    ] each-loc ;

: reset-phantom ( phantom -- )
    #! Kill register assignments but preserve constants and
    #! class information.
    dup phantom-locs*
    over stack>> [
        dup constant? [ nip ] [
            operand-class over set-operand-class
        ] if
    ] 2map
    over stack>> delete-all
    swap stack>> push-all ;

: reset-phantoms ( -- )
    [ reset-phantom ] each-phantom ;

: finalize-contents ( -- )
    finalize-locs finalize-vregs reset-phantoms ;

: %gc ( -- )
    0 frame-required
    %prepare-alien-invoke
    "simple_gc" f %alien-invoke ;

! Loading stacks to vregs
: free-vregs? ( int# float# -- ? )
    double-float-regs free-vregs length <=
    >r int-regs free-vregs length <= r> and ;

: phantom&spec ( phantom spec -- phantom' spec' )
    >r stack>> r>
    [ length f pad-left ] keep
    [ <reversed> ] bi@ ; inline

: phantom&spec-agree? ( phantom spec quot -- ? )
    >r phantom&spec r> 2all? ; inline

: vreg-substitution ( value vreg -- pair )
    dupd <cached> 2array ;

: substitute-vreg? ( old new -- ? )
    #! We don't substitute locs for float or alien vregs,
    #! since in those cases the boxing overhead might kill us.
    cached-vreg tagged? >r loc? r> and ;

: substitute-vregs ( values vregs -- )
    [ vreg-substitution ] 2map
    [ substitute-vreg? ] assoc-subset >hashtable
    [ >r stack>> r> substitute-here ] curry each-phantom ;

: set-operand ( value var -- )
    >r dup constant? [ constant-value ] when r> set ;

: lazy-load ( values template -- )
    #! Set operand vars here.
    2dup [ first (lazy-load) ] 2map
    dup rot [ second set-operand ] 2each
    substitute-vregs ;

: load-inputs ( -- )
    +input+ get
    [ length phantom-datastack get phantom-input ] keep
    lazy-load ;

: output-vregs ( -- seq seq )
    +output+ +clobber+ [ get [ get ] map ] bi@ ;

: clash? ( seq -- ? )
    phantoms [ stack>> ] bi@ append [
        dup cached? [ cached-vreg ] when swap member?
    ] with contains? ;

: outputs-clash? ( -- ? )
    output-vregs append clash? ;

: count-vregs ( reg-classes -- ) [ [ inc ] when* ] each ;

: count-input-vregs ( phantom spec -- )
    phantom&spec [
        >r dup cached? [ cached-vreg ] when r> first allocation
    ] 2map count-vregs ;

: count-scratch-regs ( spec -- )
    [ first reg-spec>class ] map count-vregs ;

: guess-vregs ( dinput rinput scratch -- int# float# )
    [
        0 int-regs set
        0 double-float-regs set
        count-scratch-regs
        phantom-retainstack get swap count-input-vregs
        phantom-datastack get swap count-input-vregs
        int-regs get double-float-regs get
    ] with-scope ;

: alloc-scratch ( -- )
    +scratch+ get [ >r alloc-vreg r> set ] assoc-each ;

: guess-template-vregs ( -- int# float# )
    +input+ get { } +scratch+ get guess-vregs ;

: template-inputs ( -- )
    ! Load input values into registers
    load-inputs
    ! Allocate scratch registers
    alloc-scratch
    ! If outputs clash, we write values back to the stack
    outputs-clash? [ finalize-contents ] when ;

: template-outputs ( -- )
    +output+ get [ get ] map phantom-datastack get phantom-append ;

: value-matches? ( value spec -- ? )
    #! If the spec is a quotation and the value is a literal
    #! fixnum, see if the quotation yields true when applied
    #! to the fixnum. Otherwise, the values don't match. If the
    #! spec is not a quotation, its a reg-class, in which case
    #! the value is always good.
    dup quotation? [
        over constant?
        [ >r constant-value r> call ] [ 2drop f ] if
    ] [
        2drop t
    ] if ;

: class-tag ( class -- tag/f )
    class-tags dup length 1 = [ first ] [ drop f ] if ;

: class-matches? ( actual expected -- ? )
    {
        { f [ drop t ] }
        { known-tag [ class-tag >boolean ] }
        [ class< ]
    } case ;

: spec-matches? ( value spec -- ? )
    2dup first value-matches?
    >r >r operand-class 2 r> ?nth class-matches? r> and ;

: template-matches? ( spec -- ? )
    phantom-datastack get +input+ rot at
    [ spec-matches? ] phantom&spec-agree? ;

: ensure-template-vregs ( -- )
    guess-template-vregs free-vregs? [
        finalize-contents compute-free-vregs
    ] unless ;

: clear-phantoms ( -- )
    [ stack>> delete-all ] each-phantom ;

PRIVATE>

: set-operand-classes ( classes -- )
    phantom-datastack get
    over length over add-locs
    stack>> [ set-operand-class ] 2reverse-each ;

: end-basic-block ( -- )
    #! Commit all deferred stacking shuffling, and ensure the
    #! in-memory data and retain stacks are up to date with
    #! respect to the compiler's current picture.
    finalize-contents
    clear-phantoms
    finalize-heights
    fresh-objects get [ empty? [ %gc ] unless ] [ delete-all ] bi ;

: with-template ( quot hash -- )
    clone [
        ensure-template-vregs
        template-inputs call template-outputs
    ] bind
    compute-free-vregs ; inline

: do-template ( pair -- )
    #! Use with return value from find-template
    first2 with-template ;

: fresh-object ( obj -- ) fresh-objects get push ;

: fresh-object? ( obj -- ? ) fresh-objects get memq? ;

: init-templates ( -- )
    #! Initialize register allocator.
    V{ } clone fresh-objects set
    <phantom-datastack> phantom-datastack set
    <phantom-retainstack> phantom-retainstack set
    compute-free-vregs ;

: copy-templates ( -- )
    #! Copies register allocator state, used when compiling
    #! branches.
    fresh-objects [ clone ] change
    phantom-datastack [ clone ] change
    phantom-retainstack [ clone ] change
    compute-free-vregs ;

: find-template ( templates -- pair/f )
    #! Pair has shape { quot hash }
    [ second template-matches? ] find nip ;

: operand-tag ( operand -- tag/f )
    operand-class class-tag ;

UNION: immediate fixnum POSTPONE: f ;

: operand-immediate? ( operand -- ? )
    operand-class immediate class< ;

: phantom-push ( obj -- )
    1 phantom-datastack get adjust-phantom
    phantom-datastack get stack>> push ;

: phantom-shuffle ( shuffle -- )
    [ effect-in length phantom-datastack get phantom-input ] keep
    shuffle* phantom-datastack get phantom-append ;

: phantom->r ( n -- )
    phantom-datastack get phantom-input
    phantom-retainstack get phantom-append ;

: phantom-r> ( n -- )
    phantom-retainstack get phantom-input
    phantom-datastack get phantom-append ;
