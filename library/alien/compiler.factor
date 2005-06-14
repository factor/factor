! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: alien
USING: assembler compiler compiler-backend compiler-frontend
errors generic hashtables inference kernel lists math namespaces
sequences stdio strings unparser words ;

! ! ! WARNING ! ! !
! Reloading this file into a running Factor instance on Win32
! or Unix with FFI I/O will bomb the runtime, since I/O words
! would become uncompiled, and FFI calls can only be made from
! compiled code.

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

TUPLE: alien-error symbol library ;

C: alien-error ( lib sym -- )
    [ set-alien-error-symbol ] keep
    [ set-alien-error-library ] keep ;

M: alien-error error. ( error -- )
    [
        "C library interface words cannot be interpreted. " %
        "Either the compiler is disabled, " %
        "or the " % dup alien-error-library unparse %
        " library does not define the " %
        alien-error-symbol unparse %
        " symbol." %
    ] make-string print ;

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
    swap "void" = [
        drop
    ] [
        [ object ] produce-d 1 0 rot node-outputs
    ] ifte ;

: set-alien-parameters ( parameters node -- )
    2dup set-alien-node-parameters
    >r [ drop object ] map dup dup ensure-d
    length 0 r> node-inputs consume-d ;

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

: parameters alien-node-parameters reverse ;

: stack-space ( parameters -- n )
    0 swap [ c-size cell align + ] each ;

: unbox-parameter ( n parameter -- node )
    c-type [ "unboxer" get "reg-class" get ] bind %unbox ;

: unbox-parameters ( len params -- )
    [ >r 1 - dup r> unbox-parameter ] map nip % ;

: load-parameter ( n parameter -- node )
    c-type "reg-class" swap hash
    [ class dup get dup 1 + rot set ] keep
    %parameter ;

: load-parameters ( params -- )
    [
        0 int-regs set
        0 float-regs set
        0 double-regs set
        reverse 0 swap
        [ dupd load-parameter >r 1 + r> ] map nip
    ] with-scope % ;

: linearize-parameters ( parameters -- )
    #! Generate code for boxing a list of C types, then generate
    #! code for moving these parameters to register on
    #! architectures where parameters are passed in registers
    #! (PowerPC).
    dup stack-space %parameters ,
    [ length ] keep tuck
    unbox-parameters load-parameters ;

: linearize-return ( return -- )
    alien-node-return dup "void" = [
        drop
    ] [
        c-type [ "boxer" get "reg-class" get ] bind %box ,
    ] ifte ;

M: alien-node linearize-node* ( node -- )
    dup parameters linearize-parameters
    dup node-param dup uncons %alien-invoke ,
    cdr library-abi "stdcall" =
    [ dup parameters stack-space %cleanup , ] unless
    linearize-return ;

\ alien-invoke [ [ string object string general-list ] [ ] ]
"infer-effect" set-word-prop

\ alien-invoke [
    pop-literal nip
    pop-literal nip >r
    pop-literal nip
    pop-literal nip -rot
    r> swap alien-node
] "infer" set-word-prop

global [
    "libraries" get [ <namespace> "libraries" set ] unless
] bind
