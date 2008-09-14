! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes combinators
cpu.architecture effects generic hashtables io kernel
kernel.private layouts math math.parser namespaces make
prettyprint quotations sequences system threads words vectors
sets deques continuations.private summary alien alien.c-types
alien.structs alien.strings alien.arrays libc compiler.errors
stack-checker.inlining compiler.tree compiler.tree.builder
compiler.tree.combinators compiler.tree.propagation.info
compiler.generator.fixup compiler.generator.registers
compiler.generator.iterator ;
IN: compiler.generator

SYMBOL: compile-queue
SYMBOL: compiled

: queue-compile ( word -- )
    {
        { [ dup "forgotten" word-prop ] [ ] }
        { [ dup compiled get key? ] [ ] }
        { [ dup inlined-block? ] [ ] }
        { [ dup primitive? ] [ ] }
        [ dup compile-queue get push-front ]
    } cond drop ;

: maybe-compile ( word -- )
    dup compiled>> [ drop ] [ queue-compile ] if ;

SYMBOL: compiling-word

SYMBOL: compiling-label

SYMBOL: compiling-loops

! Label of current word, after prologue, makes recursion faster
SYMBOL: current-label-start

: compiled-stack-traces? ( -- ? ) 59 getenv ;

: begin-compiling ( word label -- )
    H{ } clone compiling-loops set
    compiling-label set
    compiling-word set
    compiled-stack-traces?
    compiling-word get f ?
    1vector literal-table set
    f compiling-label get compiled get set-at ;

: save-machine-code ( literals relocation labels code -- )
    4array compiling-label get compiled get set-at ;

: with-generator ( nodes word label quot -- )
    [
        >r begin-compiling r>
        { } make fixup
        save-machine-code
    ] with-scope ; inline

GENERIC: generate-node ( node -- next )

: generate-nodes ( nodes -- )
    [ current-node generate-node ] iterate-nodes
    end-basic-block ;

: init-generate-nodes ( -- )
    init-templates
    %save-word-xt
    %prologue-later
    current-label-start define-label
    current-label-start resolve-label ;

: generate ( nodes word label -- )
    [
        init-generate-nodes
        [ generate-nodes ] with-node-iterator
    ] with-generator ;

: intrinsics ( #call -- quot )
    word>> "intrinsics" word-prop ;

: if-intrinsics ( #call -- quot )
    word>> "if-intrinsics" word-prop ;

! node
M: node generate-node drop iterate-next ;

: %jump ( word -- )
    dup compiling-label get eq?
    [ drop current-label-start get ] [ %epilogue-later ] if
    %jump-label ;

: generate-call ( label -- next )
    dup maybe-compile
    end-basic-block
    dup compiling-loops get at [
        %jump-label f
    ] [
        tail-call? [
            %jump f
        ] [
            0 frame-required
            %call
            iterate-next
        ] if
    ] ?if ;

! #recursive
: compile-recursive ( node -- next )
    dup label>> id>> generate-call >r
    [ child>> ] [ label>> word>> ] [ label>> id>> ] tri generate
    r> ;

: compiling-loop ( word -- )
    <label> dup resolve-label swap compiling-loops get set-at ;

: compile-loop ( node -- next )
    end-basic-block
    [ label>> id>> compiling-loop ] [ child>> generate-nodes ] bi
    iterate-next ;

M: #recursive generate-node
    dup label>> loop?>> [ compile-loop ] [ compile-recursive ] if ;

! #if
: end-false-branch ( label -- )
    tail-call? [ %return drop ] [ %jump-label ] if ;

: generate-branch ( nodes -- )
    [ copy-templates generate-nodes ] with-scope ;

: generate-if ( node label -- next )
    <label> [
        >r >r children>> first2 swap generate-branch
        r> r> end-false-branch resolve-label
        generate-branch
        init-templates
    ] keep resolve-label iterate-next ;

M: #if generate-node
    [ <label> dup %jump-f ]
    H{ { +input+ { { f "flag" } } } }
    with-template
    generate-if ;

! #dispatch
: dispatch-branch ( nodes word -- label )
    gensym [
        [
            copy-templates
            %save-dispatch-xt
            %prologue-later
            [ generate-nodes ] with-node-iterator
            %return
        ] with-generator
    ] keep ;

: dispatch-branches ( node -- )
    children>> [
        compiling-word get dispatch-branch
        %dispatch-label
    ] each ;

: generate-dispatch ( node -- )
    %dispatch dispatch-branches init-templates ;

M: #dispatch generate-node
    #! The order here is important, dispatch-branches must
    #! run after %dispatch, so that each branch gets the
    #! correct register state
    tail-call? [
        generate-dispatch iterate-next
    ] [
        compiling-word get gensym [
            [
                init-generate-nodes
                generate-dispatch
            ] with-generator
        ] keep generate-call
    ] if ;

! #call
: define-intrinsics ( word intrinsics -- )
    "intrinsics" set-word-prop ;

: define-intrinsic ( word quot assoc -- )
    2array 1array define-intrinsics ;

: define-if>branch-intrinsics ( word intrinsics -- )
    "if-intrinsics" set-word-prop ;

: if>boolean-intrinsic ( quot -- )
    "false" define-label
    "end" define-label
    "false" get swap call
    t "if-scratch" get load-literal
    "end" get %jump-label
    "false" resolve-label
    f "if-scratch" get load-literal
    "end" resolve-label
    "if-scratch" get phantom-push ; inline

: define-if>boolean-intrinsics ( word intrinsics -- )
    [
        >r [ if>boolean-intrinsic ] curry r>
        { { f "if-scratch" } } +scratch+ associate assoc-union
    ] assoc-map "intrinsics" set-word-prop ;

: define-if-intrinsics ( word intrinsics -- )
    [ +input+ associate ] assoc-map
    2dup define-if>branch-intrinsics
    define-if>boolean-intrinsics ;

: define-if-intrinsic ( word quot inputs -- )
    2array 1array define-if-intrinsics ;

: do-if-intrinsic ( pair -- next )
    <label> [ swap do-template skip-next ] keep generate-if ;

: find-intrinsic ( #call -- pair/f )
    intrinsics find-template ;

: find-if-intrinsic ( #call -- pair/f )
    node@ {
        { [ dup length 2 < ] [ 2drop f ] }
        { [ dup second #if? ] [ drop if-intrinsics find-template ] }
        [ 2drop f ]
    } cond ;

M: #call generate-node
    dup node-input-infos [ class>> ] map set-operand-classes
    dup find-if-intrinsic [
        do-if-intrinsic
    ] [
        dup find-intrinsic [
            do-template iterate-next
        ] [
            word>> generate-call
        ] ?if
    ] ?if ;

! #call-recursive
M: #call-recursive generate-node label>> id>> generate-call ;

! #push
M: #push generate-node
    literal>> <constant> phantom-push iterate-next ;

! #shuffle
M: #shuffle generate-node
    shuffle-effect phantom-shuffle iterate-next ;

M: #>r generate-node
    [ in-d>> length ] [ out-r>> empty? ] bi
    [ phantom-drop ] [ phantom->r ] if
    iterate-next ;

M: #r> generate-node
    [ in-r>> length ] [ out-d>> empty? ] bi
    [ phantom-rdrop ] [ phantom-r> ] if
    iterate-next ;

! #return
M: #return generate-node
    drop end-basic-block %return f ;

M: #return-recursive generate-node
    end-basic-block
    label>> id>> compiling-loops get key?
    [ %return ] unless f ;

! #alien-invoke
: large-struct? ( ctype -- ? )
    dup c-struct? [ struct-small-enough? not ] [ drop f ] if ;

: alien-parameters ( params -- seq )
    dup parameters>>
    swap return>> large-struct? [ "void*" prefix ] when ;

: alien-return ( params -- ctype )
    return>> dup large-struct? [ drop "void" ] when ;

: c-type-stack-align ( type -- align )
    dup c-type-stack-align? [ c-type-align ] [ drop cell ] if ;

: parameter-align ( n type -- n delta )
    over >r c-type-stack-align align dup r> - ;

: parameter-sizes ( types -- total offsets )
    #! Compute stack frame locations.
    [
        0 [
            [ parameter-align drop dup , ] keep stack-size +
        ] reduce cell align
    ] { } make ;

: return-size ( ctype -- n )
    #! Amount of space we reserve for a return value.
    dup large-struct? [ heap-size ] [ drop 0 ] if ;

: alien-stack-frame ( params -- n )
    alien-parameters parameter-sizes drop ;

: alien-invoke-frame ( params -- n )
    #! Two cells for temporary storage, temp@ and on x86.64,
    #! small struct return value unpacking
    [ return>> return-size ] [ alien-stack-frame ] bi
    + 2 cells + ;

: set-stack-frame ( n -- )
    dup [ frame-required ] when* \ stack-frame set ;

: with-stack-frame ( n quot -- )
    swap set-stack-frame
    call
    f set-stack-frame ; inline

GENERIC: reg-size ( register-class -- n )

M: int-regs reg-size drop cell ;

M: single-float-regs reg-size drop 4 ;

M: double-float-regs reg-size drop 8 ;

M: stack-params reg-size drop "void*" heap-size ;

GENERIC: reg-class-variable ( register-class -- symbol )

M: reg-class reg-class-variable ;

M: float-regs reg-class-variable drop float-regs ;

M: stack-params reg-class-variable drop stack-params ;

GENERIC: inc-reg-class ( register-class -- )

M: reg-class inc-reg-class
    dup reg-class-variable inc
    fp-shadows-int? [ reg-size stack-params +@ ] [ drop ] if ;

M: float-regs inc-reg-class
    dup call-next-method
    fp-shadows-int? [ reg-size cell /i int-regs +@ ] [ drop ] if ;

: reg-class-full? ( class -- ? )
    [ reg-class-variable get ] [ param-regs length ] bi >= ;

: spill-param ( reg-class -- n reg-class )
    stack-params get
    >r reg-size stack-params +@ r>
    stack-params ;

: fastcall-param ( reg-class -- n reg-class )
    [ reg-class-variable get ] [ inc-reg-class ] [ ] tri ;

: alloc-parameter ( parameter -- reg reg-class )
    c-type-reg-class dup reg-class-full?
    [ spill-param ] [ fastcall-param ] if
    [ param-reg ] keep ;

: (flatten-int-type) ( size -- types )
    cell /i "void*" c-type <repetition> ;

GENERIC: flatten-value-type ( type -- types )

M: object flatten-value-type 1array ;

M: struct-type flatten-value-type ( type -- types )
    stack-size cell align (flatten-int-type) ;

M: long-long-type flatten-value-type ( type -- types )
    stack-size cell align (flatten-int-type) ;

: flatten-value-types ( params -- params )
    #! Convert value type structs to consecutive void*s.
    [
        0 [
            c-type
            [ parameter-align (flatten-int-type) % ] keep
            [ stack-size cell align + ] keep
            flatten-value-type %
        ] reduce drop
    ] { } make ;

: each-parameter ( parameters quot -- )
    >r [ parameter-sizes nip ] keep r> 2each ; inline

: reverse-each-parameter ( parameters quot -- )
    >r [ parameter-sizes nip ] keep r> 2reverse-each ; inline

: reset-freg-counts ( -- )
    { int-regs float-regs stack-params } [ 0 swap set ] each ;

: with-param-regs ( quot -- )
    #! In quot you can call alloc-parameter
    [ reset-freg-counts call ] with-scope ; inline

: move-parameters ( node word -- )
    #! Moves values from C stack to registers (if word is
    #! %load-param-reg) and registers to C stack (if word is
    #! %save-param-reg).
    >r
    alien-parameters
    flatten-value-types
    r> [ >r alloc-parameter r> execute ] curry each-parameter ;
    inline

: unbox-parameters ( offset node -- )
    parameters>> [
        %prepare-unbox >r over + r> unbox-parameter
    ] reverse-each-parameter drop ;

: prepare-box-struct ( node -- offset )
    #! Return offset on C stack where to store unboxed
    #! parameters. If the C function is returning a structure,
    #! the first parameter is an implicit target area pointer,
    #! so we need to use a different offset.
    return>> dup large-struct?
    [ heap-size %prepare-box-struct cell ] [ drop 0 ] if ;

: objects>registers ( params -- )
    #! Generate code for unboxing a list of C types, then
    #! generate code for moving these parameters to register on
    #! architectures where parameters are passed in registers.
    [
        [ prepare-box-struct ] keep
        [ unbox-parameters ] keep
        \ %load-param-reg move-parameters
    ] with-param-regs ;

: box-return* ( node -- )
    return>> [ ] [ box-return ] if-void ;

TUPLE: no-such-library name ;

M: no-such-library summary
    drop "Library not found" ;

M: no-such-library compiler-error-type
    drop +linkage+ ;

: no-such-library ( name -- )
    \ no-such-library boa
    compiling-word get compiler-error ;

TUPLE: no-such-symbol name ;

M: no-such-symbol summary
    drop "Symbol not found" ;

M: no-such-symbol compiler-error-type
    drop +linkage+ ;

: no-such-symbol ( name -- )
    \ no-such-symbol boa
    compiling-word get compiler-error ;

: check-dlsym ( symbols dll -- )
    dup dll-valid? [
        dupd [ dlsym ] curry contains?
        [ drop ] [ no-such-symbol ] if
    ] [
        dll-path no-such-library drop
    ] if ;

: stdcall-mangle ( symbol node -- symbol )
    "@"
    swap parameters>> parameter-sizes drop
    number>string 3append ;

: alien-invoke-dlsym ( params -- symbols dll )
    dup function>> dup pick stdcall-mangle 2array
    swap library>> library dup [ dll>> ] when
    2dup check-dlsym ;

M: #alien-invoke generate-node
    params>>
    dup alien-invoke-frame [
        end-basic-block
        %prepare-alien-invoke
        dup objects>registers
        %prepare-var-args
        dup alien-invoke-dlsym %alien-invoke
        dup %cleanup
        box-return*
        iterate-next
    ] with-stack-frame ;

! #alien-indirect
M: #alien-indirect generate-node
    params>>
    dup alien-invoke-frame [
        ! Flush registers
        end-basic-block
        ! Save registers for GC
        %prepare-alien-invoke
        ! Save alien at top of stack to temporary storage
        %prepare-alien-indirect
        dup objects>registers
        %prepare-var-args
        ! Call alien in temporary storage
        %alien-indirect
        dup %cleanup
        box-return*
        iterate-next
    ] with-stack-frame ;

! #alien-callback
: box-parameters ( params -- )
    alien-parameters [ box-parameter ] each-parameter ;

: registers>objects ( node -- )
    [
        dup \ %save-param-reg move-parameters
        "nest_stacks" f %alien-invoke
        box-parameters
    ] with-param-regs ;

TUPLE: callback-context ;

: current-callback 2 getenv ;

: wait-to-return ( token -- )
    dup current-callback eq? [
        drop
    ] [
        yield wait-to-return
    ] if ;

: do-callback ( quot token -- )
    init-catchstack
    dup 2 setenv
    slip
    wait-to-return ; inline

: callback-return-quot ( ctype -- quot )
    return>> {
        { [ dup "void" = ] [ drop [ ] ] }
        { [ dup large-struct? ] [ heap-size [ memcpy ] curry ] }
        [ c-type c-type-unboxer-quot ]
    } cond ;

: callback-prep-quot ( params -- quot )
    parameters>> [ c-type c-type-boxer-quot ] map spread>quot ;

: wrap-callback-quot ( params -- quot )
    [
        [ callback-prep-quot ]
        [ quot>> ]
        [ callback-return-quot ] tri 3append ,
        [ callback-context new do-callback ] %
    ] [ ] make ;

: %unnest-stacks ( -- ) "unnest_stacks" f %alien-invoke ;

: callback-unwind ( params -- n )
    {
        { [ dup abi>> "stdcall" = ] [ alien-stack-frame ] }
        { [ dup return>> large-struct? ] [ drop 4 ] }
        [ drop 0 ]
    } cond ;

: %callback-return ( params -- )
    #! All the extra book-keeping for %unwind is only for x86.
    #! On other platforms its an alias for %return.
    dup alien-return
    [ %unnest-stacks ] [ %callback-value ] if-void
    callback-unwind %unwind ;

: generate-callback ( params -- )
    dup xt>> dup [
        init-templates
        %prologue-later
        dup alien-stack-frame [
            [ registers>objects ]
            [ wrap-callback-quot %alien-callback ]
            [ %callback-return ]
            tri
        ] with-stack-frame
    ] with-generator ;

M: #alien-callback generate-node
    end-basic-block
    params>> generate-callback iterate-next ;
