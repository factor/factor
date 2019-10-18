! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic assocs hashtables inference io kernel math
namespaces prettyprint sequences vectors words errors
quotations ;
IN: generator

! Computing free registers and initializing allocator
: maybe-gc ( n -- )
    #! n is a size in bytes
    \ maybe-gc get push ;

: free-vregs ( reg-class -- seq )
    #! Free vregs in a given register class
    \ free-vregs get at ;

: (compute-free-vregs) ( used class -- vector )
    #! Find all vregs in 'class' which are not in 'used'.
    dup vregs length reverse [ swap <vreg> ] map-with diff
    >vector ;

: compute-free-vregs ( -- )
    #! Create a new hashtable for thee free-vregs variable.
    live-vregs
    { T{ int-regs } T{ float-regs f 8 } }
    [ 2dup (compute-free-vregs) ] H{ } map>assoc \ free-vregs set
    drop ;

: init-templates ( -- )
    #! Initialize register allocator.
    V{ } clone \ maybe-gc set
    <phantom-datastack> phantom-d set
    <phantom-retainstack> phantom-r set
    compute-free-vregs ;

: copy-templates ( -- )
    #! Copies register allocator state, used when compiling
    #! branches.
    V{ } clone \ maybe-gc set
    phantom-d [ clone ] change
    phantom-r [ clone ] change
    compute-free-vregs ;

! Copying vregs to stacks
: take-vreg ( vreg -- )
    #! Remove a specific vreg from the free list.
    dup delegate free-vregs delete ;

: alloc-vreg ( spec -- vreg )
    #! If spec requests a specific integer vreg, remove it from
    #! the free list, otherwise remove the first free vreg in
    #! the requested class.
    dup integer? [
        <int-vreg> dup take-vreg
    ] [
        reg-spec>class free-vregs pop
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

: value-literal* ( value spec -- obj ) drop value-literal ;

: transfer-ops
    H{
        { { int-regs f } { 0 f } }
        { { int-regs integer } { [ swap vreg-n = 0 f ? ] f } }
        { { int-regs float } { T{ float-regs 8 } vreg>vreg } }
        { { float-regs f } { T{ int-regs } vreg>vreg } }
        { { float-regs integer } { f f } }
        { { float-regs float } { 0 f } }
        { { value f } { T{ int-regs } value>int-vreg } }
        { { value integer } { T{ int-regs } value>int-vreg } }
        { { value float } { T{ float-regs 8 } value>float-vreg } }
        { { value quotation } { 0 value-literal* } }
        { { loc f } { T{ int-regs } loc>vreg } }
        { { loc integer } { T{ int-regs } loc>vreg } }
        { { loc float } { T{ float-regs 8 } loc>vreg } }
    } ;

GENERIC: template-lhs ( obj -- lhs )

M: int-regs template-lhs class ;
M: float-regs template-lhs class ;
M: ds-loc template-lhs drop loc ;
M: rs-loc template-lhs drop loc ;
M: f template-lhs drop loc ;
M: value template-lhs class ;

GENERIC: template-rhs ( obj -- rhs )

M: integer template-rhs drop integer ;
M: quotation template-rhs drop quotation ;
M: object template-rhs ;

: transfer-op ( value spec -- seq )
    swap template-lhs swap template-rhs 2array
    transfer-ops at ;

: (lazy-load) ( value spec -- value )
    2dup transfer-op second dup [ execute ] [ 2drop ] if ;

: test-compatibility ( obj1 obj2 -- n/f )
    2dup transfer-op first dup quotation? [ call ] [ 2nip ] if ;

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
    over length [ - <ds-loc> ] map-with 2array flip ;

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
    [
        \ free-vregs [ [ clone ] assoc-map ] change
        call
    ] with-scope ; inline

: finalize-contents ( -- )
    [ finalize-locs ] reusing-vregs
    [ finalize-values ] reusing-vregs
    finalize-vregs
    [ delete-all ] each-phantom ;

: %gc ( -- )
    0 frame-required "simple_gc" f %alien-invoke ;

: end-basic-block ( -- )
    #! Commit all deferred stacking shuffling, and ensure the
    #! in-memory data and retain stacks are up to date with
    #! respect to the compiler's current picture.
    finalize-contents finalize-heights
    \ maybe-gc get dup empty? swap delete-all [ %gc ] unless ;

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
    >r phantom&spec r> 2map [ ] all? ; inline

: compatible? ( phantom spec -- ? )
    [ test-compatibility ] phantom&spec-agree? ;

: split-template ( template -- slow fast )
    phantom-d get 2dup swap compatible? [
        2dup [ length ] 2apply <=
        [ drop { } swap ] [ length swap cut* ] if
    ] [
        drop { }
    ] if ;

: lazy-load ( values template -- )
    #! Set operand vars here.
    dup length neg phantom-d get adjust-phantom
    [ first2 >r (lazy-load) r> set ] 2each ;

: fast-input ( template -- )
    dup empty? [
        drop
    ] [
        phantom-d get over length swap cut-phantom
        swap lazy-load
    ] if ;

SYMBOL: +input+
SYMBOL: +output+
SYMBOL: +scratch+
SYMBOL: +clobber+

: output-vregs ( -- seq seq )
    +output+ +clobber+ [ get [ get ] map ] 2apply ;

: outputs-clash? ( -- ? )
    output-vregs append phantoms append
    [ swap member? ] contains-with? ;

: slow-input ( template -- )
    #! Are we loading stuff from the stack? Then flush out
    #! remaining vregs, not slurped in by fast-input.
    #! Do the outputs clash with vregs on the phantom stacks?
    #! Then we must flush them first.
    dup empty? [
        drop
        outputs-clash? [ finalize-contents ] when
    ] [
        finalize-contents
        [ length phantom-d get phantom-locs ] keep lazy-load
    ] if ;

: input-vregs# ( phantom spec -- )
    phantom&spec [ test-compatibility inc ] 2each ;

: scratch-regs# ( spec -- )
    [ first reg-spec>class inc ] each ;

: guess-vregs ( dinput rinput scratch -- int# float# )
    H{
        { T{ int-regs } 0 }
        { T{ float-regs 8 } 0 }
        { 0 0 }
    } clone [
        scratch-regs#
        phantom-r get swap input-vregs#
        phantom-d get swap input-vregs#
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

: with-template ( quot hash -- )
    clone [ template-inputs call template-outputs ] bind
    compute-free-vregs ;
    inline

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

: template-matches? ( spec -- ? )
    clone [
        phantom-d get +input+ get
        [ value-matches? ] phantom&spec-agree?
        [ guess-template-vregs free-vregs? ] [ f ] if
    ] bind ;

: (find-template) ( templates -- pair/f )
    [ second template-matches? ] find nip ;

: find-template ( templates -- pair/f )
    #! Pair has shape { quot hash }
    compute-free-vregs
    dup (find-template) [ ] [
        finalize-contents (find-template)
    ] ?if ;
