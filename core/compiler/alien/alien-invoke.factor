! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: arrays generator errors generic hashtables
inference io kernel kernel-internals math namespaces parser
prettyprint sequences strings words ;

TUPLE: alien-invoke library function return parameters ;

M: alien-invoke alien-node-parameters alien-invoke-parameters ;
M: alien-invoke alien-node-return alien-invoke-return ;
M: alien-invoke alien-node-abi alien-invoke-library library-abi ;

C: alien-invoke make-node ;

: alien-invoke-dlsym ( node -- symbol dll )
    dup alien-invoke-function swap alien-invoke-library
    load-library ;

TUPLE: alien-invoke-error library symbol ;

M: alien-invoke-error summary
    drop "Words calling ``alien-invoke'' cannot run in the interpreter. Compile the caller word and try again." ;

: alien-invoke ( ... return library function parameters -- ... )
    pick pick <alien-invoke-error> throw ;

: ensure-dlsym ( node -- )
    [ alien-invoke-dlsym dlsym drop ]
    [ inference-warning ] recover ;

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
    dup ensure-dlsym
    ! Add node to IR
    dup node,
    ! Magic #: consume exactly the number of inputs
    0 alien-invoke-stack
] "infer" set-word-prop

M: alien-invoke generate-node
    end-basic-block
    dup objects>registers
    dup alien-invoke-dlsym %alien-invoke
    dup %cleanup
    box-return*
    iterate-next ;

M: alien-invoke stack-frame-size* alien-invoke-frame ;

: parse-arglist ( return seq -- types effect )
    2 <groups> unpair
    rot dup "void" = [ drop { } ] [ 1array ] if <effect> ;

: (define-c-word) ( type lib func types stack-effect -- )
    >r over create-in dup reset-generic >r 
    [ alien-invoke ] curry curry curry curry
    r> swap define-compound word r>
    "declared-effect" set-word-prop ;

: define-c-word ( return library function parameters -- )
    [ "()" subseq? not ] subset >r pick r> parse-arglist
    (define-c-word) ;
