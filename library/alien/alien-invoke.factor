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

: parameter-size c-size cell align ;

: stack-space ( parameters -- n )
    0 [ parameter-size + ] reduce ;

: unbox-parameter ( stack# type -- node )
    c-type [ "reg-class" get "unboxer" get ] bind call ;

: unbox-parameters ( params -- )
    reverse
    [ stack-space ] keep
    [ [ parameter-size - dup ] keep unbox-parameter , ] each
    drop ;

: reg-class-full? ( class -- ? )
    dup class get swap fastcall-regs length >= ;

: spill-param ( reg-class -- n reg-class )
    reg-size stack-params dup get -rot +@ T{ stack-params } ;

: fastcall-param ( reg-class -- n reg-class )
    [ dup class get swap inc-reg-class ] keep ;

: load-parameter ( n parameter -- node )
    #! n is a stack location, and the value of the class
    #! variable is a register number.
    c-type "reg-class" swap hash dup reg-class-full?
    [ spill-param ] [ fastcall-param ] if %parameter ;

: flatten-value-types ( params -- params )
    #! Convert value type structs to consecutive void*s.
    [
        dup c-struct?
        [ c-size cell / "void*" <array> ] [ 1array ] if
    ] map concat ;

: load-parameters ( params -- )
    [
        flatten-value-types
        0 { int-regs float-regs stack-params } [ set ] each-with
        0 [ 2dup load-parameter , parameter-size + ] reduce drop
    ] with-scope ;

: linearize-parameters ( parameters -- )
    #! Generate code for boxing a list of C types, then generate
    #! code for moving these parameters to register on
    #! architectures where parameters are passed in registers
    #! (PowerPC).
    dup stack-space %parameters ,
    dup unbox-parameters
    "save_stacks" f %alien-invoke ,
    load-parameters ;

: linearize-return ( node -- )
    alien-invoke-return dup "void" = [
        drop
    ] [
        c-type [ "reg-class" get "boxer" get ] bind call ,
    ] if ;

: linearize-cleanup ( node -- )
    dup alien-invoke-library library-abi "stdcall" = [
        drop
    ] [
        alien-invoke-parameters stack-space %cleanup ,
    ] if ;

M: alien-invoke linearize* ( node -- )
    dup alien-invoke-parameters linearize-parameters
    dup alien-invoke-dlsym %alien-invoke ,
    dup linearize-cleanup
    dup linearize-return
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
