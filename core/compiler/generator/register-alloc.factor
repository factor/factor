! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generator
USING: arrays generic hashtables inference io kernel math
namespaces prettyprint sequences vectors words errors ;

! Computing free registers and initializing allocator
: maybe-gc ( n -- )
    #! n is a size in bytes
    \ maybe-gc get push ;

: free-vregs ( reg-class -- seq )
    #! Free vregs in a given register class
    \ free-vregs get hash ;

: (compute-free-vregs) ( used class -- vector )
    #! Find all vregs in 'class' which are not in 'used'.
    dup vregs length reverse [ swap <vreg> ] map-with diff
    >vector ;

: compute-free-vregs ( -- )
    #! Create a new hashtable for thee free-vregs variable.
    live-vregs
    { T{ int-regs } T{ float-regs f 8 } }
    [ 2dup (compute-free-vregs) ] map>hash \ free-vregs set
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

: shuffle-reserve ( -- vreg )
    "shuffle-reserve" get [
        f alloc-vreg dup "shuffle-reserve" set
    ] unless* ;

: loc>loc ( fromloc toloc -- )
    #! Move a value from a stack location to another stack
    #! location.
    shuffle-reserve rot %peek
    shuffle-reserve swap %replace ;

: value>loc ( literal toloc -- )
    #! Move a literal to a stack location.
    >r value-literal shuffle-reserve load-literal
    shuffle-reserve r> %replace ;

: lazy-store ( src dest -- )
    #! Don't store a location to itself.
    2dup = [
        2drop
    ] [
        >r \ live-locs get hash dup vreg?
        [ r> %replace ] [ r> loc>loc ] if
    ] if ;

: do-shuffle ( seq quot -- )
    #! quot has stack effect ( locs -- hash ). Hash maps locs
    #! to vregs or other locs.
    over empty? [
        2drop
    ] [
        map>hash \ live-locs set
        [ over loc? [ lazy-store ] [ 2drop ] if ] each-loc
    ] if ; inline

GENERIC: (lazy-load) ( spec value -- value )

M: loc (lazy-load) swap alloc-vreg [ swap %peek ] keep ;

: load-literal* ( obj vreg -- )
    dup delegate class {
        { float-regs
            [
                >r shuffle-reserve load-literal
                r> shuffle-reserve %move
            ]
        }
        { int-regs [ load-literal ] }
    } case ;

M: value (lazy-load)
    value-literal
    swap dup quotation?
    [ drop ] [ alloc-vreg [ load-literal* ] keep ] if ;

M: vreg (lazy-load)
    dup reg-class>spec pick eq?
    [ nip ] [ >r alloc-vreg dup r> %move ] if ;

: fast-shuffle ( locs -- )
    #! We have enough free registers to load all shuffle inputs
    #! at once
    [ f over (lazy-load) ] do-shuffle ;

: find-tmp-loc ( -- n )
    #! Find an area of the data stack which is not referenced
    #! from the phantom stacks. We can clobber there all we want
    [
        0 [ dup ds-loc? [ ds-loc-n min ] [ drop ] if ] reduce
    ] each-phantom min 1- ;

: slow-shuffle ( locs -- )
    #! We don't have enough free registers to load all shuffle
    #! inputs, so we use a single temporary register, together
    #! with the area of the data stack above the stack pointer
    find-tmp-loc over length [ - ] map-with 2array flip
    [ first2 <ds-loc> 2dup loc>loc ] do-shuffle ;

: fast-shuffle? ( live-locs -- ? )
    #! Test if we have enough free registers to load all
    #! shuffle inputs at once.
    T{ int-regs } free-vregs [ length ] 2apply <= ;

: finalize-locs ( -- )
    #! Perform any deferred stack shuffling.
    live-locs dup fast-shuffle?
    [ fast-shuffle ] [ slow-shuffle ] if ;

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
        \ free-vregs [ [ clone ] hash-map ] change
        call
    ] with-scope ; inline

: finalize-contents ( -- )
    [ finalize-locs ] reusing-vregs
    [ finalize-values ] reusing-vregs
    finalize-vregs
    [ delete-all ] each-phantom ;

: (%gc) ( -- ) "simple_gc" f %alien-invoke ;

: %gc ( -- )
    \ stack-frame-size get no-stack-frame = [
        [
            0 \ stack-frame-size set
            %prologue (%gc) %epilogue
        ] with-scope
    ] [
        (%gc)
    ] if ;

: end-basic-block ( -- )
    #! Commit all deferred stacking shuffling, and ensure the
    #! in-memory data and retain stacks are up to date with
    #! respect to the compiler's current picture.
    finalize-contents finalize-heights
    \ maybe-gc get dup empty? swap delete-all [ %gc ] unless ;

! Loading stacks to vregs
: additional-vregs ( seq seq -- n )
    2array phantoms 2array [ [ length ] map ] 2apply v-
    [ 0 max ] map sum ;

: ?shuffle-reserve ( -- n )
    #! If the phantom stacks contain unloaded locs and literals,
    #! we reserve one vreg for shuffling them
    [ [ pseudo? ] contains? ] each-phantom or 1 0 ? ;

: free-vregs# ( -- int# float# )
    T{ int-regs } free-vregs length ?shuffle-reserve -
    T{ float-regs f 8 } free-vregs length ;

: ensure-vregs ( int# float# -- )
    compute-free-vregs free-vregs# swapd <= >r <= r> and
    [ finalize-contents compute-free-vregs ] unless ;

: lazy-load ( values template -- )
    #! Set operand vars here.
    dup length neg phantom-d get adjust-phantom
    [ first2 >r swap (lazy-load) r> set ] 2each ;

: (compatible?) ( value spec -- ? )
    #! Almost everything is compatible, except if the template
    #! requests that a stack value be stored in a specific
    #! integer vreg (this is done on x86).
    {
        { [ dup integer? not ] [ 2drop t ] }
        { [ over [ float-regs? ] is? ] [ 2drop f ] }
        { [ over pseudo? ] [ 2drop t ] }
        { [ t ] [ swap vreg-n = ] }
    } cond ;

: compatible? ( template phantom -- ? )
    [ <reversed> ] 2apply
    [ swap first 2array ] 2map
    [ first2 (compatible?) ] all? ;

: split-template ( template -- slow fast )
    phantom-d get 2dup compatible? [
        2dup [ length ] 2apply <=
        [ drop { } swap ] [ length swap cut* ] if
    ] [
        drop { }
    ] if ;

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

: fix-spec ( spec -- spec )
    H{
        { +input+ { } }
        { +output+ { } }
        { +scratch+ { } }
        { +clobber+ { } }
    } swap hash-union ;

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

: requested-vregs ( template -- int# float# )
    H{ { f 0 } { float 0 } } clone [
        [ first inc ] each
        f get float get
    ] bind ;

: guess-vregs ( -- int# float# )
    +input+ get { } additional-vregs
    +scratch+ get requested-vregs >r + r> ;

: alloc-scratch ( -- )
    +scratch+ get [ first2 >r alloc-vreg r> set ] each ;

: template-inputs ( -- )
    ! Ensure we have enough to hold any new stack elements we
    ! will read (if any), and scratch.
    guess-vregs ensure-vregs
    ! Split the template into available (fast) parts and those
    ! that require allocating registers and reading the stack
    +input+ get split-template fast-input slow-input
    ! Finally allocate scratch registers
    alloc-scratch ;

: template-outputs ( -- )
    +output+ get [ get ] map phantom-d get phantom-append ;

: with-template ( quot hash -- )
    fix-spec [ template-inputs call template-outputs ] bind
    compute-free-vregs ; inline

: value-matches? ( value spec -- ? )
    #! If the spec is a quotation and the value is a literal
    #! fixnum, see if the quotation yields true when applied
    #! to the fixnum. Otherwise, the values don't match. If the
    #! spec is not a quotation, its a reg-class, in which case
    #! the value is always good.
    dup quotation? [
        over value? [
            >r value-literal dup fixnum? [
                r> call small-enough?
            ] [
                r> 2drop f
            ] if
        ] [
            2drop f
        ] if
    ] [
        2drop t
    ] if ;

: template-matches? ( hash -- ? )
    ! Pad phantom stack with f's on the left if necessary
    phantom-d get +input+ rot hash [ length f pad-left ] keep
    ! Build a sequence of value/template pairs
    [ <reversed> ] 2apply [ first 2array ] 2map
    ! See if the phantom stack is suitable for this template
    [ first2 value-matches? ] all? ;

: apply-template ( templates -- )
    #! Templates is a sequence of { quot hash }
    dup [ second template-matches? ] find nip
    [ ] [ peek ] ?if first2 with-template ;
