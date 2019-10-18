! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003 Slava Pestov.
! Copyright (C) 2004 Chris Double.
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

IN: words
USE: combinators
USE: kernel
USE: lists
USE: logic
USE: namespaces
USE: stack

: worddef? ( obj -- boolean )
    "factor.FactorWordDefinition" is ;

: worddef ( word -- worddef )
    dup worddef? [
        intern dup [ [ "def" get ] bind ] when
    ] unless ;

: word-property ( word pname -- pvalue )
    swap [ get ] bind ;

: set-word-property ( pvalue word pname -- )
    swap [ set ] bind ;

: redefine ( word def -- )
    swap [ "def" set ] bind ;

: word? ( obj -- ? )
    "factor.FactorWord" is ;

: compiled? ( worddef -- ? )
    "factor.compiler.CompiledDefinition" is ;

: compound? ( worddef -- ? )
    "factor.FactorCompoundDefinition" is ;

: compound-or-compiled? ( worddef -- ? )
    dup compiled? swap compound? or ;

: symbol? ( worddef -- ? )
    "factor.FactorSymbolDefinition" is ;

: comment? ( obj -- ? )
    "factor.FactorDocComment" is ;

: gensym ( -- word )
    [ ] "factor.FactorWord" "gensym" jinvoke-static ;

: <compound> ( word def -- worddef )
    swap intern swap interpreter
    [ "factor.FactorWord" "factor.Cons" "factor.FactorInterpreter" ]
    "factor.FactorCompoundDefinition"
    jnew ;

: no-name ( list -- word )
    ! Generates an uninternalized word and gives it a compound
    ! definition created from the given list.
    [ gensym dup dup ] dip <compound> redefine ;

: primitive? ( worddef -- boolean )
    "factor.FactorPrimitiveDefinition" is ;

: shuffle? ( worddef -- boolean )
    "factor.FactorShuffleDefinition" is ;

: word-of-worddef ( worddef -- word )
    "factor.FactorWordDefinition" "word" jvar-get ;

: defined? ( obj -- ? )
    dup word? [ worddef ] [ drop f ] ifte ;

: word-parameter ( worddef -- list )
    worddef interpreter swap
    [ "factor.FactorInterpreter" ] "factor.FactorWordDefinition"
    "toList" jinvoke ;

: skip-docs ( list -- list )
    dup [ dup car comment? [ cdr skip-docs ] when ] when ;

: compound>list ( worddef -- list )
    word-parameter dup [ skip-docs ] when ;

: define-compound ( word def -- )
    #! Define a compound word at runtime.
    >r dup >r [ "vocabulary" get "name" get ] bind r> r>
    <compound> define ;
