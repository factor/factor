! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: arrays generator errors generic hashtables
inference io kernel kernel-internals math namespaces parser
prettyprint sequences strings words quotations
inspector ;

TUPLE: alien-invoke library function return parameters ;

M: alien-invoke alien-node-parameters alien-invoke-parameters ;
M: alien-invoke alien-node-return alien-invoke-return ;

M: alien-invoke alien-node-abi
    alien-invoke-library library
    [ library-abi ] [ "cdecl" ] if* ;

C: alien-invoke make-node ;

: stdcall-mangle ( symbol node -- symbol )
    "@"
    swap alien-node-parameters parameter-sizes drop
    number>string 3append ;

: (alien-invoke-dlsym) ( node -- symbol dll )
    dup alien-invoke-function
    swap alien-invoke-library load-library ;

: alien-invoke-dlsym ( node -- symbol dll )
    dup (alien-invoke-dlsym) 2dup dlsym [
        >r over stdcall-mangle r> 2dup dlsym [
            "No such symbol" inference-error
        ] unless
    ] unless rot drop ;

TUPLE: alien-invoke-error library symbol ;

M: alien-invoke-error summary
    drop "Words calling ``alien-invoke'' cannot run in the interpreter. Compile the caller word and try again." ;

: alien-invoke ( ... return library function parameters -- ... )
    pick pick <alien-invoke-error> throw ;

\ alien-invoke [
    ! Four literals
    4 ensure-values
    empty-node <alien-invoke>
    ! Compile-time parameters
    pop-literal nip over set-alien-invoke-parameters
    pop-literal nip over set-alien-invoke-function
    pop-literal nip over set-alien-invoke-library
    pop-literal nip over set-alien-invoke-return
    ! Quotation which coerces parameters to required types
    dup make-prep-quot infer-quot
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
        dup objects>registers
        dup alien-invoke-dlsym %alien-invoke
        dup %cleanup
        box-return*
        iterate-next
    ] with-stack-frame ;

: parse-arglist ( return seq -- types effect )
    2 <groups> unpair
    rot dup "void" = [ drop { } ] [ 1array ] if <effect> ;

: function-quot ( type lib func types -- quot )
    [ alien-invoke ] curry curry curry curry ;

: define-function ( return library function parameters -- )
    >r pick r> parse-arglist
    pick create-in dup reset-generic
    >r >r function-quot r> r> 
    -rot define-declared ;
