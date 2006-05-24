! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: arrays assembler compiler compiler
errors generic hashtables inference inspector
io kernel kernel-internals math namespaces parser
prettyprint sequences strings words ;

TUPLE: alien-invoke library function return parameters ;
C: alien-invoke make-node ;

: alien-invoke-stack ( node -- )
    dup alien-invoke-parameters length over consume-values
    dup alien-invoke-return "void" = 0 1 ? swap produce-values ;

: alien-invoke-dlsym ( node -- symbol dll )
    dup alien-invoke-function swap alien-invoke-library
    load-library ;

TUPLE: alien-invoke-error library symbol ;

M: alien-invoke-error summary ( error -- )
    drop "Words calling ``alien-invoke'' cannot run in the interpreter. Compile the caller word and try again." ;

: alien-invoke ( ... return library function parameters -- ... )
    pick pick <alien-invoke-error> throw ;

\ alien-invoke [ [ string object string object ] [ ] ]
"infer-effect" set-word-prop

\ alien-invoke [
    empty-node <alien-invoke>
    pop-literal nip over set-alien-invoke-parameters
    pop-literal nip over set-alien-invoke-function
    pop-literal nip over set-alien-invoke-library
    pop-literal nip over set-alien-invoke-return
    dup alien-invoke-dlsym dlsym drop
    dup alien-invoke-stack
    node,
] "infer" set-word-prop

: unbox-parameter ( stack# type -- )
    c-type [ "reg-class" get "unboxer" get call ] bind ;

: unbox-parameters ( parameters -- )
    [ unbox-parameter ] reverse-each-parameter ;

: objects>registers ( parameters -- )
    #! Generate code for boxing a list of C types, then generate
    #! code for moving these parameters to register on
    #! architectures where parameters are passed in registers
    #! (PowerPC, AMD64).
    dup unbox-parameters "save_stacks" f %alien-invoke
    \ %stack>freg move-parameters ;

: box-return ( node -- )
    alien-invoke-return [ ] [ f swap box-parameter ] if-void ;

: generate-cleanup ( node -- )
    dup alien-invoke-library library-abi "stdcall" = [
        drop
    ] [
        alien-invoke-parameters stack-space %cleanup
    ] if ;

M: alien-invoke generate-node ( node -- )
    end-basic-block compile-gc
    dup alien-invoke-parameters objects>registers
    dup alien-invoke-dlsym %alien-invoke
    dup generate-cleanup box-return
    iterate-next ;

M: alien-invoke stack-reserve*
    alien-invoke-parameters stack-space ;

: parse-arglist ( return seq -- types stack-effect )
    2 swap group unpair
    rot dup "void" = [ drop { } ] [ 1array ] if 2array
    effect>string ;

: (define-c-word) ( type lib func types stack-effect -- )
    >r over create-in dup reset-generic >r 
    [ alien-invoke ] curry curry curry curry
    r> swap define-compound word r>
    "stack-effect" set-word-prop ;

: define-c-word ( return library function parameters -- )
    [ "()" subseq? not ] subset >r pick r> parse-arglist
    (define-c-word) ;

M: compound unxref-word*
    dup "infer" word-prop [
        dup
        { "infer-effect" "base-case" "no-effect" "terminates" }
        reset-props
        dup word-def \ alien-invoke swap member?
        [ dup update-xt ] unless
    ] unless drop ;
