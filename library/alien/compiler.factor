! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: arrays assembler compiler compiler-backend
compiler-frontend errors generic hashtables inference inspector
io kernel kernel-internals lists math namespaces parser
prettyprint sequences strings words ;

! USAGE:
! 
! Command line parameters given to the runtime specify libraries
! to load.
!
! -libraries:<foo>:name=<soname> -- define a library <foo>, to be
! loaded from the <soname> DLL.
!
! -libraries:<foo>:abi=stdcall -- define a library using the
! stdcall ABI. This ABI is usually used on Win32. Any other abi
! parameter, or a missing abi parameter indicates the cdecl ABI
! should be used, which is common on Unix.

! FFI code does not run in the interpreter.

TUPLE: alien-error library symbol ;

M: alien-error summary ( error -- )
    drop "Words calling ``alien-invoke'' cannot run in the interpreter. Compile the caller word and try again." ;

: alien-invoke ( ... return library function parameters -- ... )
    #! Call a C library function.
    #! 'return' is a type spec, and 'parameters' is a list of
    #! type specs. 'library' is an entry in the "libraries"
    #! namespace.
    drop <alien-error> throw ;

TUPLE: alien-node return parameters ;
C: alien-node make-node ;

: set-alien-return ( return node -- )
    2dup set-alien-node-return
    swap "void" = [ 1 over produce-values ] unless drop ;

: set-alien-parameters ( parameters node -- )
    2dup set-alien-node-parameters
    >r length r> consume-values ;

: ensure-dlsym ( symbol library -- ) load-library dlsym drop ;

: alien-node ( return params function library -- )
    #! We should fail if the library does not exist, so that
    #! compilation does not keep trying to compile FFI words
    #! over and over again if the library is not loaded.
    2dup ensure-dlsym
    cons param-node <alien-node>
    [ set-alien-parameters ] keep
    [ set-alien-return ] keep
    node, ;

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
    dup unbox-parameters load-parameters ;

: linearize-return ( node -- )
    alien-node-return dup "void" = [
        drop
    ] [
        c-type [ "reg-class" get "boxer" get ] bind call ,
    ] if ;

: linearize-cleanup ( node -- )
    node-param cdr library-abi "stdcall" = [
        dup alien-node-parameters stack-space %cleanup ,
    ] unless ;

M: alien-node linearize* ( node -- )
    dup alien-node-parameters linearize-parameters
    dup node-param uncons %alien-invoke ,
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

\ alien-invoke [ [ string object string object ] [ ] ]
"infer-effect" set-word-prop

\ alien-invoke [
    pop-literal nip
    pop-literal nip >r
    pop-literal nip
    pop-literal nip -rot
    r> swap alien-node
] "infer" set-word-prop

global [ "libraries" nest drop ] bind

M: compound (uncrossref)
    dup word-def \ alien-invoke swap member?
    over "infer" word-prop or [
        drop
    ] [
        dup { "infer-effect" "base-case" "no-effect" "terminates" }
        reset-props update-xt
    ] if ;
