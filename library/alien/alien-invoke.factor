! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: arrays assembler compiler compiler-backend
compiler-frontend errors generic hashtables inference inspector
io kernel kernel-internals lists math namespaces parser
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
    #! Call a C library function.
    #! 'return' is a type spec, and 'parameters' is a list of
    #! type specs. 'library' is an entry in the "libraries"
    #! namespace.
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

: unbox-parameter ( stack# type -- node )
    c-type [ "reg-class" get "unboxer" get ] bind call ;

: unbox-parameters ( parameters -- )
    [ unbox-parameter , ] reverse-each-parameter ;

: objects>registers ( parameters -- )
    #! Generate code for boxing a list of C types, then generate
    #! code for moving these parameters to register on
    #! architectures where parameters are passed in registers
    #! (PowerPC, AMD64).
    dup stack-space %parameters ,
    dup unbox-parameters
    "save_stacks" f %alien-invoke ,
    \ %stack>freg move-parameters ;

: box-return ( node -- )
    alien-invoke-return dup "void" =
    [ drop ] [ f swap box-parameter , ] if ;

: linearize-cleanup ( node -- )
    dup alien-invoke-library library-abi "stdcall" = [
        drop
    ] [
        alien-invoke-parameters stack-space %cleanup ,
    ] if ;

M: alien-invoke linearize* ( node -- )
    dup alien-invoke-parameters objects>registers
    dup alien-invoke-dlsym %alien-invoke ,
    dup linearize-cleanup
    dup box-return
    linearize-next ;

: parse-arglist ( lst -- types stack effect )
    unpair [
        " " % [ "," ?tail drop % " " % ] each "-- " %
    ] "" make ;

: (define-c-word) ( type lib func types stack-effect -- )
    >r over create-in >r 
    [ alien-invoke ] cons cons cons cons r> swap define-compound
    word r> "stack-effect" set-word-prop ;

: define-c-word ( type lib func function-args -- )
    [ "()" subseq? not ] subset parse-arglist (define-c-word) ;

M: compound (uncrossref)
    dup word-def \ alien-invoke swap member?
    over "infer" word-prop or [
        drop
    ] [
        dup
        { "infer-effect" "base-case" "no-effect" "terminates" }
        reset-props update-xt
    ] if ;
