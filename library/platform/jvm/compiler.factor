! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003, 2004 Slava Pestov.
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

IN: compiler
USE: combinators
USE: lists
USE: namespaces
USE: stack
USE: stdio
USE: words

: class-name ( class -- name )
    [ ] "java.lang.Class" "getName" jinvoke ;

: compile* ( word -- )
    interpreter swap
    [ "factor.FactorInterpreter" ] "factor.FactorWord" "compile"
    jinvoke ;

: compile ( word -- )
    #! Compile a word.
    intern dup worddef compiled? [
        drop
    ] [
        compile*
    ] ifte ;

: compile-all ( -- )
    #! Compile all words.
    vocabs [ words [ compile ] each ] each ;

: compiled>compound ( word -- def )
    #! Convert a compiled word definition into the compound
    #! definition which compiles to it.
    dup worddef>list <compound> ;

: decompile ( word -- )
    #! Decompiles a word; from now on, it will be interpreted
    #! again.
    intern dup worddef compiled? [
        dup compiled>compound redefine
    ] [
        drop
    ] ifte ;

: recompile ( word -- )
    #! If a word is not compiled, behave like compile; otherwise
    #! decompile the word and compile it again.
    dup decompile compile ;

: recompile-all ( -- )
    #! Recompile all words in the dictionary.
    vocabs [ words [ compile ] each ] each ;

: effect ( word -- effect )
    #! Push stack effect of a word.
    interpreter swap worddef
    [ "factor.FactorInterpreter" ] "factor.FactorWordDefinition"
    "getStackEffect" jinvoke ;

: effect>list ( effect -- list )
    [ "inD" "outD" "inR" "outR" ]
    [ dupd "factor.compiler.StackEffect" swap jvar-get ]
    map nip ;

: effect>typelist ( effect -- list )
    [ "inDtypes" "outDtypes" "inRtypes" "outRtypes" ]
    [
        dupd "factor.compiler.StackEffect" swap jvar-get
        array>list [ class-name ] map
    ] map nip ;

: balance ( code -- effect )
    #! Push stack effect of a quotation.
    no-name effect ;

: balance>list ( quotation -- list )
    balance effect>list ;

: balance>typelist ( quotation -- list )
    balance effect>typelist ;
