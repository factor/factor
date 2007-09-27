! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes classes.private combinators
cpu.architecture generator.fixup generic hashtables
inference.dataflow inference.stack kernel kernel.private layouts
math memory namespaces quotations sequences system vectors words
effects ;
IN: generator.registers

SYMBOL: +input+
SYMBOL: +output+
SYMBOL: +scratch+
SYMBOL: +clobber+
SYMBOL: known-tag

! A scratch register for computations
TUPLE: vreg n ;

: <vreg> ( n reg-class -- vreg )
    { set-vreg-n set-delegate } vreg construct ;

! Register classes
TUPLE: int-regs ;
TUPLE: float-regs size ;

: <int-vreg> ( n -- vreg ) T{ int-regs } <vreg> ;
: <float-vreg> ( n -- vreg ) T{ float-regs f 8 } <vreg> ;

! Temporary register for stack shuffling
TUPLE: temp-reg ;

: temp-reg T{ temp-reg T{ int-regs } } ;

M: vreg v>operand dup vreg-n swap vregs nth ;

! A data stack location.
TUPLE: ds-loc n ;

C: <ds-loc> ds-loc

! A retain stack location.
TUPLE: rs-loc n ;

C: <rs-loc> rs-loc

<PRIVATE

UNION: loc ds-loc rs-loc ;

! A compile-time stack
TUPLE: phantom-stack height ;

GENERIC: finalize-height ( stack -- )

SYMBOL: phantom-d
SYMBOL: phantom-r

: <phantom-stack> ( class -- stack )
    >r
    V{ } clone 0
    { set-delegate set-phantom-stack-height }
    phantom-stack construct
    r> construct-delegate ;

: (loc)
    #! Utility for methods on <loc>
    phantom-stack-height - ;

: (finalize-height) ( stack word -- )
    #! We consolidate multiple stack height changes until the
    #! last moment, and we emit the final height changing
    #! instruction here.
    swap [
        phantom-stack-height
        dup zero? [ 2drop ] [ swap execute ] if
        0
    ] keep set-phantom-stack-height ; inline

GENERIC: <loc> ( n stack -- loc )

TUPLE: phantom-datastack ;

: <phantom-datastack> phantom-datastack <phantom-stack> ;

M: phantom-datastack <loc> (loc) <ds-loc> ;

M: phantom-datastack finalize-height
    \ %inc-d (finalize-height) ;

TUPLE: phantom-retainstack ;

: <phantom-retainstack> phantom-retainstack <phantom-stack> ;

M: phantom-retainstack <loc> (loc) <rs-loc> ;

M: phantom-retainstack finalize-height
    \ %inc-r (finalize-height) ;

: phantom-locs ( n phantom -- locs )
    #! A sequence of n ds-locs or rs-locs indexing the stack.
    >r <reversed> r> [ <loc> ] curry map ;

: phantom-locs* ( phantom -- locs )
    dup length swap phantom-locs ;

: (each-loc) ( phantom quot -- )
    >r dup phantom-locs* r> 2each ; inline

: each-loc ( quot -- )
    >r phantom-d get r> phantom-r get over
    >r >r (each-loc) r> r> (each-loc) ; inline

: adjust-phantom ( n phantom -- )
    [ phantom-stack-height + ] keep set-phantom-stack-height ;

GENERIC: cut-phantom ( n phantom -- seq )

M: phantom-stack cut-phantom
    [ delegate cut* swap ] keep set-delegate ;

: phantom-append ( seq stack -- )
    over length over adjust-phantom push-all ;

: phantom-input ( n phantom -- seq )
    [
        2dup length <= [
            cut-phantom
        ] [
            [ phantom-locs ] keep
            [ length head-slice* ] keep
            [ append ] keep
            delete-all
        ] if
    ] 2keep >r neg r> adjust-phantom ;

PRIVATE>

: phantom-push ( obj -- )
    1 phantom-d get adjust-phantom
    phantom-d get push ;

: phantom-shuffle ( shuffle -- )
    [ effect-in length phantom-d get phantom-input ] keep
    shuffle* phantom-d get phantom-append ;

: phantom->r ( n -- )
    phantom-d get phantom-input
    phantom-r get phantom-append ;

: phantom-r> ( n -- )
    phantom-r get phantom-input
    phantom-d get phantom-append ;

<PRIVATE

: phantoms ( -- phantom phantom ) phantom-d get phantom-r get ;

: each-phantom ( quot -- ) phantoms rot 2apply ; inline

: finalize-heights ( -- )
    phantoms [ finalize-height ] 2apply ;

! Phantom stacks hold values, locs, and vregs
UNION: pseudo loc value ;

: live-vregs ( -- seq ) phantoms append [ vreg? ] subset ;

: live-loc? ( current actual -- ? )
    over loc? [ = not ] [ 2drop f ] if ;

: (live-locs) ( phantom -- seq )
    #! Discard locs which haven't moved
    dup phantom-locs* 2array flip
    [ live-loc? ] assoc-subset
    keys ;

: live-locs ( -- seq )
    [ (live-locs) ] each-phantom append prune ;

: minimal-ds-loc ( phantom -- n )
    #! When shuffling more values than can fit in registers, we
    #! need to find an area on the data stack which isn't in
    #! use.
    dup phantom-stack-height neg
    [ dup ds-loc? [ ds-loc-n min ] [ drop ] if ] reduce ;

! Operands holding pointers to freshly-allocated objects which
! are guaranteed to be in the nursery
SYMBOL: fresh-objects

! Computing free registers and initializing allocator
: free-vregs ( reg-class -- seq )
    #! Free vregs in a given register class
    \ free-vregs get at ;

: (compute-free-vregs) ( used class -- vector )
    #! Find all vregs in 'class' which are not in 'used'.
    [ vregs length reverse ] keep
    [ <vreg> ] curry map seq-diff
    >vector ;

: compute-free-vregs ( -- )
    #! Create a new hashtable for thee free-vregs variable.
    live-vregs
    { T{ int-regs } T{ float-regs f 8 } }
    [ 2dup (compute-free-vregs) ] H{ } map>assoc \ free-vregs set
    drop ;

: reg-spec>class ( spec -- class )
    float eq?
    T{ float-regs f 8 } T{ int-regs } ? ;

! Copying vregs to stacks
: alloc-vreg ( spec -- vreg )
    reg-spec>class free-vregs pop ;

: %move ( dst src -- )
    2dup = [
        2drop
    ] [
        2dup [ delegate class ] 2apply 2array {
            { { int-regs int-regs } [ %move-int>int ] }
            { { float-regs int-regs } [ %move-int>float ] }
            { { int-regs float-regs } [ %move-float>int ] }
        } case
    ] if ;

: vreg>vreg ( vreg spec -- vreg )
    alloc-vreg dup rot %move ;

: value>int-vreg ( value spec -- vreg )
    alloc-vreg [ >r value-literal  r> load-literal ] keep ;

: value>float-vreg ( value spec -- vreg )
    alloc-vreg [
        >r value-literal temp-reg load-literal r> temp-reg %move
    ] keep ;

: loc>vreg ( loc spec -- vreg )
    alloc-vreg [ swap %peek ] keep ;

: allocation
    H{
        { { int-regs f } f }
        { { int-regs float } T{ float-regs 8 f } }
        { { float-regs f } T{ int-regs f } }
        { { float-regs float } f }
        { { value value } f }
        { { value f } T{ int-regs f } }
        { { value float } T{ float-regs 8 f } }
        { { loc f } T{ int-regs f } }
        { { loc float } T{ float-regs 8 f } }
    } at ;

: transfer
    {
        { { int-regs f } [ drop ] }
        { { int-regs float } [ vreg>vreg ] }
        { { float-regs f } [ vreg>vreg ] }
        { { float-regs float } [ drop ] }
        { { value f } [ value>int-vreg ] }
        { { value float } [ value>float-vreg ] }
        { { value value } [ drop ] }
        { { loc f } [ loc>vreg ] }
        { { loc float } [ loc>vreg ] }
    } case ;

GENERIC: template-lhs ( obj -- lhs )

M: int-regs template-lhs class ;
M: float-regs template-lhs class ;
M: ds-loc template-lhs drop loc ;
M: rs-loc template-lhs drop loc ;
M: f template-lhs drop loc ;
M: value template-lhs class ;

GENERIC: template-rhs ( obj -- rhs )

M: quotation template-rhs drop value ;
M: object template-rhs ;

: transfer-op ( value spec -- pair )
    swap template-lhs swap template-rhs 2array ;

: (lazy-load) ( value spec -- value )
    2dup transfer-op transfer ;

: loc>loc ( fromloc toloc -- )
    #! Move a value from a stack location to another stack
    #! location.
    temp-reg rot %peek
    temp-reg swap %replace ;

: lazy-store ( src dest -- )
    #! Don't store a location to itself.
    2dup = [
        2drop
    ] [
        >r \ live-locs get at dup vreg?
        [ r> %replace ] [ r> loc>loc ] if
    ] if ;

: do-shuffle ( hash -- )
    dup assoc-empty? [
        drop
    ] [
        \ live-locs set
        [ over loc? [ lazy-store ] [ 2drop ] if ] each-loc
    ] if ;

: fast-shuffle ( locs -- )
    #! We have enough free registers to load all shuffle inputs
    #! at once
    [ dup f (lazy-load) ] H{ } map>assoc do-shuffle ;

: find-tmp-loc ( -- n )
    #! Find an area of the data stack which is not referenced
    #! from the phantom stacks. We can clobber there all we want
    [ minimal-ds-loc ] each-phantom min 1- ;

: slow-shuffle-mapping ( locs tmp -- pairs )
    >r dup length r>
    [ swap - <ds-loc> ] curry map
    2array flip ;

: slow-shuffle ( locs -- )
    #! We don't have enough free registers to load all shuffle
    #! inputs, so we use a single temporary register, together
    #! with the area of the data stack above the stack pointer
    find-tmp-loc slow-shuffle-mapping
    [ [ loc>loc ] assoc-each ] keep
    >hashtable do-shuffle ;

: fast-shuffle? ( live-locs -- ? )
    #! Test if we have enough free registers to load all
    #! shuffle inputs at once.
    T{ int-regs } free-vregs [ length ] 2apply <= ;

: finalize-locs ( -- )
    #! Perform any deferred stack shuffling.
    live-locs dup fast-shuffle?
    [ fast-shuffle ] [ slow-shuffle ] if ;

: value>loc ( literal toloc -- )
    #! Move a literal to a stack location.
    >r value-literal temp-reg load-literal
    temp-reg r> %replace ;

: finalize-values ( -- )
    #! Store any deferred literals to their final stack
    #! locations.
    [ over value? [ value>loc ] [ 2drop ] if ] each-loc ;

: finalize-vregs ( -- )
    #! Store any vregs to their final stack locations.
    [ over pseudo? [ 2drop ] [ %replace ] if ] each-loc ;

: reusing-vregs ( quot -- )
    #! Any vregs allocated by quot are released again.
    >r \ free-vregs get [ clone ] assoc-map \ free-vregs r>
    with-variable ; inline

: finalize-contents ( -- )
    [ finalize-locs ] reusing-vregs
    [ finalize-values ] reusing-vregs
    finalize-vregs
    [ delete-all ] each-phantom ;

: %gc ( -- )
    0 frame-required
    %prepare-alien-invoke
    "simple_gc" f %alien-invoke ;

! Loading stacks to vregs
: free-vregs# ( -- int# float# )
    T{ int-regs } T{ float-regs f 8 } 
    [ free-vregs length ] 2apply ;

: free-vregs? ( int# float# -- ? )
    free-vregs# swapd <= >r <= r> and ;

: ensure-vregs ( int# float# -- )
    compute-free-vregs free-vregs?
    [ finalize-contents compute-free-vregs ] unless ;

: phantom&spec ( phantom spec -- phantom' spec' )
    0 <column>
    [ length f pad-left ] keep
    [ <reversed> ] 2apply ; inline

: phantom&spec-agree? ( phantom spec quot -- ? )
    >r phantom&spec r> 2all? ; inline

: split-template ( input -- slow fast )
    phantom-d get
    2dup [ length ] 2apply <=
    [ drop { } swap ] [ length swap cut* ] if ;

: substitute-vregs ( alist -- )
    >hashtable
    { phantom-d phantom-r }
    [ get substitute ] curry* each ;

: lazy-load ( values template -- )
    #! Set operand vars here.
    flip first2
    >r dupd [ (lazy-load) ] 2map dup r>
    [ >r dup value? [ value-literal ] when r> set ] 2each
    2array flip substitute-vregs ;

: fast-input ( template -- )
    dup empty? [
        drop
    ] [
        dup length phantom-d get phantom-input swap lazy-load
    ] if ;

: output-vregs ( -- seq seq )
    +output+ +clobber+ [ get [ get ] map ] 2apply ;

: clash? ( seq -- ? )
    phantoms append swap [ member? ] curry contains? ;

: outputs-clash? ( -- ? )
    output-vregs append clash? ;

: slow-input ( template -- )
    outputs-clash? [ finalize-contents ] when fast-input ;

: count-vregs ( reg-classes -- ) [ [ inc ] when* ] each ;

: count-input-vregs ( phantom spec -- )
    phantom&spec [ transfer-op allocation ] 2map
    count-vregs ;

: count-scratch-regs ( spec -- )
    [ first reg-spec>class ] map count-vregs ;

: guess-vregs ( dinput rinput scratch -- int# float# )
    H{
        { T{ int-regs } 0 }
        { T{ float-regs 8 } 0 }
    } clone [
        count-scratch-regs
        phantom-r get swap count-input-vregs
        phantom-d get swap count-input-vregs
        T{ int-regs } get T{ float-regs 8 } get
    ] bind ;

: alloc-scratch ( -- )
    +scratch+ get [ >r alloc-vreg r> set ] assoc-each ;

: guess-template-vregs ( -- int# float# )
    +input+ get { } +scratch+ get guess-vregs ;

: template-inputs ( -- )
    ! Ensure we have enough to hold any new stack elements we
    ! will read (if any), and scratch.
    guess-template-vregs ensure-vregs
    ! Split the template into available (fast) parts and those
    ! that require allocating registers and reading the stack
    +input+ get split-template fast-input slow-input
    ! Finally allocate scratch registers
    alloc-scratch ;

: template-outputs ( -- )
    +output+ get [ get ] map phantom-d get phantom-append ;

: value-matches? ( value spec -- ? )
    #! If the spec is a quotation and the value is a literal
    #! fixnum, see if the quotation yields true when applied
    #! to the fixnum. Otherwise, the values don't match. If the
    #! spec is not a quotation, its a reg-class, in which case
    #! the value is always good.
    dup quotation? [
        over value?
        [ >r value-literal r> call ] [ 2drop f ] if
    ] [
        2drop t
    ] if ;

: template-specs-match? ( -- ? )
    phantom-d get +input+ get
    [ value-matches? ] phantom&spec-agree? ;

: class-tag ( class -- tag/f )
    dup hi-tag class< [
        drop object tag-number
    ] [
        flatten-builtin-class keys
        dup length 1 = [ first tag-number ] [ drop f ] if
    ] if ;

: class-match? ( actual expected -- ? )
    {
        { f [ drop t ] }
        { known-tag [ class-tag >boolean ] }
        [ class< ]
    } case ;

: template-classes-match? ( -- ? )
    #! Depends on node@
    node@ node-input-classes +input+ get
    [ 2 swap ?nth class-match? ] 2all? ;

: template-matches? ( spec -- ? )
    #! Depends on node@
    clone [
        template-specs-match?
        template-classes-match? and
        [ guess-template-vregs free-vregs? ] [ f ] if
    ] bind ;

: (find-template) ( templates -- pair/f )
    #! Depends on node@
    [ second template-matches? ] find nip ;

PRIVATE>

: end-basic-block ( -- )
    #! Commit all deferred stacking shuffling, and ensure the
    #! in-memory data and retain stacks are up to date with
    #! respect to the compiler's current picture.
    finalize-contents finalize-heights
    fresh-objects get dup empty? swap delete-all [ %gc ] unless ;

: with-template ( quot hash -- )
    clone [ template-inputs call template-outputs ] bind
    compute-free-vregs ;
    inline

: fresh-object ( obj -- ) fresh-objects get push ;

: fresh-object? ( obj -- ? ) fresh-objects get memq? ;

: init-templates ( -- )
    #! Initialize register allocator.
    V{ } clone fresh-objects set
    <phantom-datastack> phantom-d set
    <phantom-retainstack> phantom-r set
    compute-free-vregs ;

: copy-templates ( -- )
    #! Copies register allocator state, used when compiling
    #! branches.
    fresh-objects [ clone ] change
    phantom-d [ clone ] change
    phantom-r [ clone ] change
    compute-free-vregs ;

: find-template ( templates -- pair/f )
    #! Pair has shape { quot hash }
    #! Depends on node@
    compute-free-vregs
    dup (find-template) [ ] [
        finalize-contents (find-template)
    ] ?if ;

: operand-class ( operand -- class )
    #! Depends on node@
    +input+ get [ second = ] curry* find drop
    node@ tuck node-in-d nth node-class ;

: operand-tag ( operand -- tag/f )
    #! Depends on node@
    operand-class class-tag ;
