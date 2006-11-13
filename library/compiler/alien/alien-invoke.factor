! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: arrays assembler compiler errors generic hashtables
inference io kernel kernel-internals math namespaces parser
prettyprint sequences strings words ;

TUPLE: alien-invoke library function return parameters ;
C: alien-invoke make-node ;

: alien-invoke-stack ( node -- )
    dup alien-invoke-parameters over consume-values
    dup alien-invoke-return "void" = 0 1 ? swap produce-values ;

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

\ alien-invoke [ string object string object ] [ ] <effect>
"inferred-effect" set-word-prop

\ alien-invoke [
    empty-node <alien-invoke>
    pop-literal nip over set-alien-invoke-parameters
    pop-literal nip over set-alien-invoke-function
    pop-literal nip over set-alien-invoke-library
    pop-literal nip over set-alien-invoke-return
    dup alien-invoke-parameters make-prep-quot infer-quot
    dup ensure-dlsym
    dup node,
    alien-invoke-stack
] "infer" set-word-prop

: unbox-parameters ( parameters -- )
    [ c-type c-type-unbox ] reverse-each-parameter ;

: objects>registers ( parameters -- )
    #! Generate code for boxing a list of C types, then generate
    #! code for moving these parameters to register on
    #! architectures where parameters are passed in registers
    #! (PowerPC, AMD64).
    dup unbox-parameters
    "save_stacks" f %alien-invoke
    \ %stack>freg move-parameters ;

: box-return ( ctype -- )
    [ ] [ f swap c-type c-type-box ] if-void ;

: generate-invoke-cleanup ( node -- )
    dup alien-invoke-library library-abi "stdcall" = [
        drop
    ] [
        alien-invoke-parameters stack-space %cleanup
    ] if ;

M: alien-invoke generate-node
    end-basic-block
    dup alien-invoke-parameters objects>registers
    dup alien-invoke-dlsym %alien-invoke
    dup generate-invoke-cleanup
    alien-invoke-return box-return
    iterate-next ;

M: alien-invoke stack-reserve*
    alien-invoke-parameters stack-space ;

: parse-arglist ( return seq -- types effect )
    2 group unpair
    rot dup "void" = [ drop { } ] [ 1array ] if <effect> ;

: (define-c-word) ( type lib func types stack-effect -- )
    >r over create-in dup reset-generic >r 
    [ alien-invoke ] curry curry curry curry
    r> swap define-compound word r>
    "declared-effect" set-word-prop ;

: define-c-word ( return library function parameters -- )
    [ "()" subseq? not ] subset >r pick r> parse-arglist
    (define-c-word) ;
