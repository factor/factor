! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: alien
USING: assembler compiler compiler-backend compiler-frontend
errors generic hashtables inference io kernel lists math
namespaces prettyprint sequences strings words parser ;

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

TUPLE: alien-error library symbol ;

M: alien-error error. ( error -- )
    "C library interface words cannot be interpreted. " write
    "Either the compiler is disabled, " write
    "or the " write dup alien-error-library pprint
    " library does not define the " write
    alien-error-symbol pprint " symbol." print ;

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

: parameters alien-node-parameters reverse ;

: c-aligned c-size cell align ;

: stack-space ( parameters -- n )
    0 swap [ c-aligned + ] each ;

: unbox-parameter ( n parameter -- node )
    c-type [ "unboxer" get "reg-class" get ] bind %unbox ;

: unbox-parameters ( params -- )
    [ stack-space ] keep
    [ [ c-aligned - dup ] keep unbox-parameter ] map nip % ;

: incr-param ( reg-class -- )
    #! OS X is so ugly.
    dup class inc  dup float-regs? [
        os "macosx" = [
            int-regs [ swap float-regs-size 4 / + ] change
        ] [
            drop
        ] if
    ] [
        drop
    ] if ;

: load-parameter ( n parameter -- node )
    c-type "reg-class" swap hash
    [ [ class get ] keep  incr-param ] keep  %parameter ;

: load-parameters ( params -- )
    [
        0 int-regs set
        0 float-regs set
        reverse 0 swap
        [ 2dup load-parameter >r c-aligned + r> ] map nip
    ] with-scope % ;

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
        c-type [ "boxer" get "reg-class" get ] bind %box ,
    ] if ;

M: alien-node linearize* ( node -- )
    dup parameters linearize-parameters
    dup node-param dup uncons %alien-invoke ,
    cdr library-abi "stdcall" =
    [ dup parameters stack-space %cleanup , ] unless
    dup linearize-return linearize-next ;

: unpair ( seq -- odds evens )
    2 swap group flip dup empty?
    [ drop { } { } ] [ first2 ] if ;

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
    "libraries" get [ {{ }} clone "libraries" set ] unless
] bind

M: compound (uncrossref)
    dup word-def \ alien-invoke swap member?
    over "infer" word-prop or [
        drop
    ] [
        dup { "infer-effect" "base-case" "no-effect" "terminates" }
        reset-props update-xt
    ] if ;
