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

: asm ( word -- )
    ! Prints JVM bytecode disassembly of the given word.
    intern [ $asm ] bind dup [
        print
    ] [
        drop "Not a compiled word." print
    ] ifte ;

: balance ( code -- effect )
    ! Push stack effect of the given code quotation.
    no-name effect ;

: compile* ( word -- )
    $interpreter swap
    [ "factor.FactorInterpreter" ] "factor.FactorWord" "compile"
    jinvoke ;

: compile ( word -- )
    dup worddef compiled? [
        drop
    ] [
        intern compile*
    ] ifte ;

: compile-all ( -- )
    "Compiling..." write
    words [ compile ] each
    " done" print ;

: compiled? ( obj -- boolean )
    "factor.compiler.CompiledDefinition" is ;

: compound? ( obj -- boolean )
    "factor.FactorCompoundDefinition" is ;

: <compound> ( word def -- worddef )
    [ "factor.FactorWord" "factor.Cons" ]
    "factor.FactorCompoundDefinition"
    jnew ;

: effect ( word -- effect )
    ! Push stack effect of the given word.
    worddef [ ] "factor.FactorWordDefinition"
    "getStackEffect" jinvoke ;

: effect>list ( effect -- effect )
    [
        [ "factor.compiler.StackEffect" "inD" jvar$ ]
        [ "factor.compiler.StackEffect" "outD" jvar$ ]
        [ "factor.compiler.StackEffect" "inR" jvar$ ]
        [ "factor.compiler.StackEffect" "outR" jvar$ ]
    ] interleave unit cons cons cons ;

: gensym ( -- word )
    [ ] "factor.FactorWord" "gensym" jinvoke-static ;

: <word> ( name -- word )
    ! Creates a new uninternalized word.
    [ "java.lang.String" ] "factor.FactorWord" jnew ;

: intern* ( "word" -- word )
    dup $ dup [
        nip
    ] [
        drop dup $ tuck s@
    ] ifte ;

: intern ( "word" -- word )
    ! Returns the top of the stack if it already been interned.
    dup word? [ $dict [ intern* ] bind ] unless ;

: missing>f ( word -- word/f )
    ! Is it the missing word placeholder? Then push f.
    dup undefined? [ drop f ] when ;

: no-name ( list -- word )
    ! Generates an uninternalized word and gives it a compound
    ! definition created from the given list.
    [ gensym dup dup ] dip <compound> define ;

: shuffle? ( obj -- boolean )
    "factor.FactorShuffleDefinition" is ;

: undefined? ( obj -- boolean )
    "factor.FactorMissingDefinition" is ;

: word? ( obj -- boolean )
    "factor.FactorWord" is ;

: word ( -- word )
    ! Pushes most recently defined word.
    $global [ $last ] bind ;

: worddef? (obj -- boolean)
    "factor.FactorWordDefinition" is ;

: worddef ( word -- worddef )
    dup worddef? [ intern [ $def ] bind missing>f ] unless ;

: worddef>list ( worddef -- list )
    worddef
    [ ] "factor.FactorWordDefinition" "toList" jinvoke ;

: words ( -- list )
    ! Pushes a list of all defined words.
    $dict [ uvalues ] bind
    [
        cdr dup [ drop ] unless
    ] map ;
