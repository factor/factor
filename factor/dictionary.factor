!:folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003 Slava Pestov.
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

: apropos ( substring -- )
    ! Prints all word names that contain the given substring.
    words [ 2dup str-contains [ . ] [ drop ] ifte ] each drop ;

: compiled? ( worddef -- boolean )
    "factor.compiler.CompiledDefinition" is ;

: compound? ( worddef -- boolean )
    "factor.FactorCompoundDefinition" is ;

: <compound> ( word def -- worddef )
    [ "factor.FactorWord" "factor.Cons" ]
    "factor.FactorCompoundDefinition"
    jnew ;

: gensym ( -- word )
    [ ] "factor.FactorWord" "gensym" jinvoke-static ;

: <word> ( name -- word )
    ! Creates a new uninternalized word.
    [ "java.lang.String" ] "factor.FactorWord" jnew ;

: intern* ( "word" -- word )
    dup $ dup [
        nip
    ] [
        drop dup <word> tuck s@
    ] ifte ;

: intern ( "word" -- word )
    ! Returns the top of the stack if it already been interned.
    dup word? [ $dict [ intern* ] bind ] unless ;

: no-name ( list -- word )
    ! Generates an uninternalized word and gives it a compound
    ! definition created from the given list.
    [ gensym dup dup ] dip <compound> define ;

: primitive? ( worddef -- boolean )
    "factor.FactorPrimitiveDefinition" is ;

: shuffle? ( worddef -- boolean )
    "factor.FactorShuffleDefinition" is ;

: word? ( obj -- boolean )
    "factor.FactorWord" is ;

: word-of-worddef ( worddef -- word )
    "factor.FactorWordDefinition" "word" jvar$ ;

: worddef? (obj -- boolean)
    "factor.FactorWordDefinition" is ;

: worddef ( word -- worddef )
    dup worddef? [ intern dup [ [ $def ] bind ] when ] unless ;

: worddef>list ( worddef -- list )
    worddef dup word-of-worddef swap interpreter swap
    [ "factor.FactorInterpreter" ] "factor.FactorWordDefinition"
    "toList" jinvoke cons ;

: words ( -- list )
    ! Pushes a list of all defined words.
    $dict [ values ] bind [ worddef ] subset ;

: words. (--)
    ! Print all defined words.
    words [ . ] each ;

: usages. ( word -- )
    intern
    words [
        2dup = [
            drop
        ] [
            2dup worddef>list tree-contains [ . ] [ drop ] ifte
        ] ifte
    ] each drop ;
