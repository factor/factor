! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: alien
USE: compiler
USE: errors
USE: generic
USE: inference
USE: interpreter
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: parser
USE: words
USE: hashtables
USE: strings

! Command line parameters specify libraries to load.
!
! -library:<foo>:name=<soname> -- define a library <foo>, to be
! loaded from the <soname> DLL.
!
! -library:<foo>:abi=stdcall -- define a library using the
! stdcall ABI. This ABI is usually used on Win32. Any other abi
! parameter, or a missing abi parameter indicates the cdecl ABI
! should be used, which is common on Unix.

BUILTIN: dll   15
BUILTIN: alien 16

M: alien hashcode ( obj -- n )
    alien-address ;

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

#alien-invoke [ linearize-alien ] "linearizer" set-word-property

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
"infer-effect" set-word-property

\ alien-invoke [ infer-alien ] "infer" set-word-property

global [
    "libraries" get [ <namespace> "libraries" set ] unless
] bind
