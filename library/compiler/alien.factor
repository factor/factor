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

BUILTIN: dll   15
BUILTIN: alien 16

: library ( name -- handle )
    "libraries" get [
        dup get dup dll? [
            nip
        ] [
            dlopen tuck put
        ] ifte
    ] bind ;

: alien-function ( function library -- )
    [ library dlsym ] [ dlsym-self ] ifte* ;

SYMBOL: #c-invoke ( C ABI -- Unix and most Windows libs )
SYMBOL: #cleanup ( unwind stack by parameter )

SYMBOL: #c-call ( jump to raw address )

SYMBOL: #unbox ( move top of datastack to C stack )
SYMBOL: #box ( move EAX to datastack )

SYMBOL: #std-invoke ( stdcall ABI -- Win32 )

! These are set in the #c-invoke and #std-invoke dataflow IR
! nodes.
SYMBOL: alien-returns
SYMBOL: alien-parameters

: infer-alien ( op -- )
    >r 4 ensure-d
    dataflow-drop, pop-d car
    dataflow-drop, pop-d car
    dataflow-drop, pop-d car alien-function
    dataflow-drop, pop-d car swap
    r> dataflow, [
        alien-returns set
        alien-parameters set
    ] bind ;

: unbox-parameter ( function -- )
    dlsym-self #unbox swons , ;

: linearize-parameters ( params -- count )
    #! Generate code for boxing a list of C types.
    #! Return amount stack must be unwound by.
    [ alien-parameters get reverse ] bind 0 swap [
        c-type [
            "width" get cell align +
            "unboxer" get
        ] bind unbox-parameter
    ] each ;

: box-parameter ( function -- )
    dlsym-self #box swons , ;

: linearize-returns ( returns -- )
    [ alien-returns get ] bind dup "void" = [
        drop
    ] [
        c-type [ "boxer" get ] bind box-parameter
    ] ifte ;

: linearize-alien ( node -- )
    dup linearize-parameters >r
    dup [ node-param get ] bind #c-call swons ,
    dup [ node-op get #c-invoke = ] bind
    r> swap [ #cleanup swons , ] [ drop ] ifte
    linearize-returns ;

: c-invoke ( ... returns library function parameters -- ... )
    #! Call a C library function.
    #! 'returns' is a type spec, and 'parameters' is a list of
    #! type specs. 'library' is an entry in the "libraries"
    #! namespace.
    "c-invoke cannot be interpreted." throw ;

\ c-invoke [ 4 | 0 ] "infer-effect" set-word-property

\ c-invoke [ #c-invoke infer-alien ] "infer" set-word-property

#c-invoke [ linearize-alien ] "linearizer" set-word-property

: std-invoke ( ... returns library function parameters -- ... )
    #! Call a C library function with the stdcall ABI (Win32).
    #! 'returns' is a type spec, and 'parameters' is a list of
    #! type specs. 'library' is an entry in the "libraries"
    #! namespace.
    "std-invoke cannot be interpreted." throw ;

\ std-invoke [ 4 | 0 ] "infer-effect" set-word-property

\ std-invoke [ #std-invoke infer-alien ] "infer" set-word-property

#std-invoke [ linearize-alien ] "linearizer" set-word-property

: alien-invoke ( ... returns library function parameters -- ... )
    "alien-invoke cannot be interpreted." throw ;

\ alien-invoke [ 4 | 0 ] "infer-effect" set-word-property

\ alien-invoke [
    os "win32" = #std-invoke #c-invoke ? infer-alien
] "infer" set-word-property

global [
    "libraries" get [ <namespace> "libraries" set ] unless
] bind
