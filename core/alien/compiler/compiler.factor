! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generator generator.registers generator.fixup
hashtables kernel math namespaces sequences words
inference.backend inference.dataflow system math.functions
math.parser classes alien.arrays alien.c-types alien.structs
alien.syntax cpu.architecture alien inspector quotations assocs
kernel.private threads continuations.private libc combinators ;
IN: alien.compiler

! Common protocol for alien-invoke/alien-callback/alien-indirect
GENERIC: alien-node-parameters ( node -- seq )
GENERIC: alien-node-return ( node -- ctype )
GENERIC: alien-node-abi ( node -- str )

: large-struct? ( ctype -- ? )
    dup c-struct? [
        heap-size struct-small-enough? not
    ] [
        drop f
    ] if ;

: alien-node-parameters* ( node -- seq )
    dup alien-node-parameters
    swap alien-node-return large-struct? [ "void*" add* ] when ;

: alien-node-return* ( node -- ctype )
    alien-node-return dup large-struct? [ drop "void" ] when ;

: parameter-align ( n type -- n delta )
    over >r
    dup c-type-stack-align? [ c-type-align ] [ drop cell ] if
    align
    dup r> - ;

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

: alien-stack-frame ( node -- n )
    alien-node-parameters* parameter-sizes drop ;

: alien-invoke-frame ( node -- n )
    #! One cell is temporary storage, temp@
    dup alien-node-return return-size
    swap alien-stack-frame +
    cell + ;

: set-stack-frame ( n -- )
    dup [ frame-required ] when* \ stack-frame set ;

: with-stack-frame ( n quot -- )
    swap set-stack-frame
    call
    f set-stack-frame ; inline

: reg-class-full? ( class -- ? )
    dup class get swap param-regs length >= ;

: spill-param ( reg-class -- n reg-class )
    reg-size stack-params dup get -rot +@ T{ stack-params } ;

: fastcall-param ( reg-class -- n reg-class )
    [ dup class get swap inc-reg-class ] keep ;

: alloc-parameter ( parameter -- reg reg-class )
    c-type c-type-reg-class dup reg-class-full?
    [ spill-param ] [ fastcall-param ] if
    [ param-reg ] keep ;

: (flatten-int-type) ( size -- )
    cell /i "void*" <repetition> % ;

: flatten-int-type ( n type -- n )
    [ parameter-align (flatten-int-type) ] keep
    stack-size cell align dup (flatten-int-type) + ;

: flatten-value-type ( n type -- n )
    dup c-type c-type-reg-class T{ int-regs } =
    [ flatten-int-type ] [ , ] if ;

: flatten-value-types ( params -- params )
    #! Convert value type structs to consecutive void*s.
    [ 0 [ flatten-value-type ] reduce drop ] { } make ;

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
    swap
    alien-node-parameters*
    flatten-value-types
    [ pick >r alloc-parameter r> execute ] each-parameter
    drop ; inline

: if-void ( type true false -- )
    pick "void" = [ drop nip call ] [ nip call ] if ; inline

: alien-invoke-stack ( node extra -- )
    over alien-node-parameters length + dup reify-curries
    over consume-values
    dup alien-node-return "void" = 0 1 ?
    swap produce-values ;

: (make-prep-quot) ( parameters -- )
    dup empty? [
        drop
    ] [
        unclip c-type c-type-prep %
        \ >r , (make-prep-quot) \ r> ,
    ] if ;

: make-prep-quot ( node -- quot )
    alien-node-parameters
    [ <reversed> (make-prep-quot) ] [ ] make ;

: unbox-parameters ( offset node -- )
    alien-node-parameters [
        %prepare-unbox >r over + r> unbox-parameter
    ] reverse-each-parameter drop ;

: prepare-box-struct ( node -- offset )
    #! Return offset on C stack where to store unboxed
    #! parameters. If the C function is returning a structure,
    #! the first parameter is an implicit target area pointer,
    #! so we need to use a different offset.
    alien-node-return dup large-struct?
    [ heap-size %prepare-box-struct cell ] [ drop 0 ] if ;

: objects>registers ( node -- )
    #! Generate code for unboxing a list of C types, then
    #! generate code for moving these parameters to register on
    #! architectures where parameters are passed in registers.
    [
        [ prepare-box-struct ] keep
        [ unbox-parameters ] keep
        \ %load-param-reg move-parameters
    ] with-param-regs ;

: box-return* ( node -- )
    alien-node-return [ ] [ box-return ] if-void ;

M: alien-invoke alien-node-parameters alien-invoke-parameters ;
M: alien-invoke alien-node-return alien-invoke-return ;

M: alien-invoke alien-node-abi
    alien-invoke-library library
    [ library-abi ] [ "cdecl" ] if* ;

: stdcall-mangle ( symbol node -- symbol )
    "@"
    swap alien-node-parameters parameter-sizes drop
    number>string 3append ;

: (alien-invoke-dlsym) ( node -- symbol dll )
    dup alien-invoke-function
    swap alien-invoke-library load-library ;

TUPLE: no-such-symbol ;

M: no-such-symbol summary
    drop "Symbol not found" ;

: no-such-symbol ( -- )
    \ no-such-symbol inference-error ;

: alien-invoke-dlsym ( node -- symbol dll )
    dup (alien-invoke-dlsym) 2dup dlsym [
        >r over stdcall-mangle r> 2dup dlsym
        [ no-such-symbol ] unless
    ] unless rot drop ;

M: alien-invoke-error summary
    drop "Words calling ``alien-invoke'' cannot run in the interpreter. Compile the caller word and try again." ;

: pop-parameters pop-literal nip [ expand-constants ] map ;

\ alien-invoke [
    ! Four literals
    4 ensure-values
    \ alien-invoke empty-node
    ! Compile-time parameters
    pop-parameters over set-alien-invoke-parameters
    pop-literal nip over set-alien-invoke-function
    pop-literal nip over set-alien-invoke-library
    pop-literal nip over set-alien-invoke-return
    ! Quotation which coerces parameters to required types
    dup make-prep-quot recursive-state get infer-quot
    ! If symbol doesn't resolve, no stack effect, no compile
    dup alien-invoke-dlsym 2drop
    ! Add node to IR
    dup node,
    ! Magic #: consume exactly the number of inputs
    0 alien-invoke-stack
] "infer" set-word-prop

M: alien-invoke generate-node
    dup alien-invoke-frame [
        end-basic-block
        %prepare-alien-invoke
        dup objects>registers
        dup alien-invoke-dlsym %alien-invoke
        dup %cleanup
        box-return*
        iterate-next
    ] with-stack-frame ;

M: alien-indirect alien-node-parameters alien-indirect-parameters ;
M: alien-indirect alien-node-return alien-indirect-return ;
M: alien-indirect alien-node-abi alien-indirect-abi ;

M: alien-indirect-error summary
    drop "Words calling ``alien-indirect'' cannot run in the interpreter. Compile the caller word and try again." ;

\ alien-indirect [
    ! Three literals and function pointer
    4 ensure-values
    4 reify-curries
    \ alien-indirect empty-node
    ! Compile-time parameters
    pop-literal nip over set-alien-indirect-abi
    pop-parameters over set-alien-indirect-parameters
    pop-literal nip over set-alien-indirect-return
    ! Quotation which coerces parameters to required types
    dup make-prep-quot [ dip ] curry recursive-state get infer-quot
    ! Add node to IR
    dup node,
    ! Magic #: consume the function pointer, too
    1 alien-invoke-stack
] "infer" set-word-prop

M: alien-indirect generate-node
    dup alien-invoke-frame [
        ! Flush registers
        end-basic-block
        ! Save registers for GC
        %prepare-alien-invoke
        ! Save alien at top of stack to temporary storage
        %prepare-alien-indirect
        dup objects>registers
        ! Call alien in temporary storage
        %alien-indirect
        dup %cleanup
        box-return*
        iterate-next
    ] with-stack-frame ;

! Callbacks are registered in a global hashtable. If you clear
! this hashtable, they will all be blown away by code GC, beware
SYMBOL: callbacks

H{ } clone callbacks set-global

: register-callback ( word -- ) dup callbacks get set-at ;

M: alien-callback alien-node-parameters alien-callback-parameters ;
M: alien-callback alien-node-return alien-callback-return ;
M: alien-callback alien-node-abi alien-callback-abi ;

M: alien-callback-error summary
    drop "Words calling ``alien-callback'' cannot run in the interpreter. Compile the caller word and try again." ;

: callback-bottom ( node -- )
    alien-callback-xt [ word-xt <alien> ] curry
    recursive-state get infer-quot ;

\ alien-callback [
    4 ensure-values
    \ alien-callback empty-node dup node,
    pop-literal nip over set-alien-callback-quot
    pop-literal nip over set-alien-callback-abi
    pop-parameters over set-alien-callback-parameters
    pop-literal nip over set-alien-callback-return
    gensym dup register-callback over set-alien-callback-xt
    callback-bottom
] "infer" set-word-prop

: box-parameters ( node -- )
    alien-node-parameters* [ box-parameter ] each-parameter ;

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
    init-error-handler
    dup 2 setenv
    slip
    wait-to-return ; inline

: prepare-callback-return ( ctype -- quot )
    alien-node-return {
        { [ dup "void" = ] [ drop [ ] ] }
        { [ dup large-struct? ] [ heap-size [ memcpy ] curry ] }
        { [ t ] [ c-type c-type-prep ] }
    } cond ;

: wrap-callback-quot ( node -- quot )
    [
        dup alien-callback-quot
        swap prepare-callback-return append ,
        [ callback-context construct-empty do-callback ] %
    ] [ ] make ;

: %unnest-stacks ( -- ) "unnest_stacks" f %alien-invoke ;

: callback-unwind ( node -- n )
    {
        { [ dup alien-node-abi "stdcall" = ] [ alien-stack-frame ] }
        { [ dup alien-node-return large-struct? ] [ drop 4 ] }
        { [ t ] [ drop 0 ] }
    } cond ;

: %callback-return ( node -- )
    #! All the extra book-keeping for %unwind is only for x86.
    #! On other platforms its an alias for %return.
    dup alien-node-return*
    [ %unnest-stacks ] [ %callback-value ] if-void
    callback-unwind %unwind ;

: generate-callback ( node -- )
    dup alien-callback-xt dup rot [
        dup alien-stack-frame [
            init-templates
            dup registers>objects
            dup wrap-callback-quot %alien-callback
            %callback-return
        ] with-stack-frame
    ] generate-1 ;

M: alien-callback generate-node
    end-basic-block generate-callback iterate-next ;
