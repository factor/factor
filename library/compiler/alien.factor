! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: alien
USING: assembler compiler errors generic hashtables inference
interpreter kernel lists math namespaces parser stdio strings
unparser words ;

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

: null? ( alien -- ? ) dup [ alien-address 0 = ] when ;

: null>f ( alien -- alien/f )
    dup alien-address 0 = [ drop f ] when ;

M: alien hashcode ( obj -- n )
    alien-address >fixnum ;

M: alien = ( obj obj -- ? )
    over alien? [
        over local-alien? over local-alien? or [
            eq?
        ] [
            alien-address swap alien-address =
        ] ifte
    ] [
        2drop f
    ] ifte ;

M: alien unparse ( obj -- str )
    [
        "#<" ,
        dup local-alien? "local-alien" "alien" ? ,
        " @ " ,
        alien-address unparse ,
        ">" ,
    ] make-string ;

: library ( name -- object )
    dup [ "libraries" get hash ] when ;

: load-dll ( name -- dll )
    #! Higher level wrapper around dlopen primitive.
    library dup [
        [
            "dll" get dup [
                drop "name" get dlopen dup "dll" set
            ] unless
        ] bind
    ] when ;

: add-library ( library name abi -- )
    "libraries" get [
        <namespace> [
          "abi" set
          "name" set
        ] extend put
    ] bind ;
    
SYMBOL: #cleanup ( unwind stack by parameter )

SYMBOL: #unbox ( move top of datastack to C stack )
SYMBOL: #box ( move EAX to datastack )

: library-abi ( library -- abi )
    library [ [ "abi" get ] bind ] [ "cdecl" ] ifte* ;

SYMBOL: #alien-invoke
SYMBOL: #alien-global

! These are set in the #alien-invoke dataflow IR node.
SYMBOL: alien-returns
SYMBOL: alien-parameters

: set-alien-returns ( returns node -- )
    [ dup alien-returns set ] bind
    "void" = [
        [ object ] produce-d 1 0 node-outputs
    ] unless ;

: set-alien-parameters ( parameters node -- )
    [ dup alien-parameters set ] bind
    [ drop object ] map dup dup ensure-d
    length 0 node-inputs consume-d ;

: ensure-dlsym ( symbol library -- ) load-dll dlsym drop ;

: alien-invoke-node ( returns params function library -- )
    #! We should fail if the library does not exist, so that
    #! compilation does not keep trying to compile FFI words
    #! over and over again if the library is not loaded.
    2dup ensure-dlsym
    cons #alien-invoke dataflow,
    [ set-alien-parameters ] keep
    set-alien-returns ;

DEFER: alien-invoke

: infer-alien-invoke ( -- )
    \ alien-invoke "infer-effect" word-prop car ensure-d
    pop-literal
    pop-literal >r
    pop-literal
    pop-literal -rot
    r> swap alien-invoke-node ;

: alien-global-node ( type name library -- )
    2dup ensure-dlsym
    cons #alien-global dataflow,
    set-alien-returns ;

DEFER: alien-global

: infer-alien-global ( -- )
    \ alien-global "infer-effect" word-prop car ensure-d
    pop-literal
    pop-literal
    pop-literal -rot
    alien-global-node ;

: box-parameter
    c-type [
        "width" get cell align
        "unboxer" get
    ] bind #unbox swons , ;

: linearize-parameters ( params -- count )
    #! Generate code for boxing a list of C types.
    #! Return amount stack must be unwound by.
    [ alien-parameters get reverse ] bind 0 swap [
        box-parameter +
    ] each ;

: linearize-returns ( returns -- )
    [ alien-returns get ] bind dup "void" = [
        drop
    ] [
        c-type [ "boxer" get ] bind #box swons ,
    ] ifte ;

: linearize-alien-invoke ( node -- )
    dup linearize-parameters >r
    dup [ node-param get ] bind #alien-invoke swons ,
    dup [ node-param get cdr library-abi "stdcall" = ] bind
    r> swap [ drop ] [ #cleanup swons , ] ifte
    linearize-returns ;

#alien-invoke [ linearize-alien-invoke ] "linearizer" set-word-prop

: linearize-alien-global ( node -- )
    dup [ node-param get ] bind #alien-global swons ,
    linearize-returns ;

#alien-global [ linearize-alien-global ] "linearizer" set-word-prop

TUPLE: alien-error lib ;

C: alien-error ( lib -- ) [ set-alien-error-lib ] keep ;

M: alien-error error. ( error -- )
    [
        "C library interface words cannot be interpreted. " ,
        "Either the compiler is disabled, " ,
        "or the ``" , alien-error-lib ,
        "'' library is missing." ,
    ] make-string print ;

: alien-invoke ( ... returns library function parameters -- ... )
    #! Call a C library function.
    #! 'returns' is a type spec, and 'parameters' is a list of
    #! type specs. 'library' is an entry in the "libraries"
    #! namespace.
    rot <alien-error> throw ;

\ alien-invoke [ [ string string string general-list ] [ ] ]
"infer-effect" set-word-prop

\ alien-invoke [ infer-alien-invoke ] "infer" set-word-prop

: alien-global ( type library name -- value )
    #! Fetch the value of C global variable.
    #! 'type' is a type spec. 'library' is an entry in the
    #! "libraries" namespace.
    swap <alien-error> throw ;

\ alien-global [ [ string string string ] [ object ] ]
"infer-effect" set-word-prop

\ alien-global [ infer-alien-global ] "infer" set-word-prop

global [
    "libraries" get [ <namespace> "libraries" set ] unless
] bind
