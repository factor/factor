! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: alien
USING: assembler compiler errors generic inference interpreter
kernel lists math namespaces parser words hashtables strings
unparser ;

! Command line parameters specify libraries to load.
!
! -libraries:<foo>:name=<soname> -- define a library <foo>, to be
! loaded from the <soname> DLL.
!
! -libraries:<foo>:abi=stdcall -- define a library using the
! stdcall ABI. This ABI is usually used on Win32. Any other abi
! parameter, or a missing abi parameter indicates the cdecl ABI
! should be used, which is common on Unix.

: null? ( alien -- ? ) dup [ alien-address 0 = ] when ;

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

SYMBOL: #c-call ( jump to raw address )

SYMBOL: #unbox ( move top of datastack to C stack )
SYMBOL: #box ( move EAX to datastack )

: library-abi ( library -- abi )
    library [ [ "abi" get ] bind ] [ "cdecl" ] ifte* ;

SYMBOL: #alien-invoke

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

: alien-node ( returns params function library -- )
    #! We should fail if the library does not exist, so that
    #! compilation does not keep trying to compile FFI words
    #! over and over again if the library is not loaded.
   ! 2dup load-dll dlsym
    cons #alien-invoke dataflow,
    [ set-alien-parameters ] keep
    set-alien-returns ;

: infer-alien ( -- )
    [ object object object object ] ensure-d
    dataflow-drop, pop-d literal-value
    dataflow-drop, pop-d literal-value >r
    dataflow-drop, pop-d literal-value
    dataflow-drop, pop-d literal-value -rot
    r> swap alien-node ;

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

: linearize-alien ( node -- )
    dup linearize-parameters >r
    dup [ node-param get ] bind #c-call swons ,
    dup [ node-param get cdr library-abi "stdcall" = ] bind
    r> swap [ drop ] [ #cleanup swons , ] ifte
    linearize-returns ;

#alien-invoke [ linearize-alien ] "linearizer" set-word-prop

: alien-invoke ( ... returns library function parameters -- ... )
    #! Call a C library function.
    #! 'returns' is a type spec, and 'parameters' is a list of
    #! type specs. 'library' is an entry in the "libraries"
    #! namespace.
    [
        "alien-invoke cannot be interpreted. " ,
        "Either the compiler is disabled, " ,
        "or the ``" , rot , "'' library is missing. " ,
    ] make-string throw ;

\ alien-invoke [ [ object object object object ] [ ] ]
"infer-effect" set-word-prop

\ alien-invoke [ infer-alien ] "infer" set-word-prop

global [
    "libraries" get [ <namespace> "libraries" set ] unless
] bind
