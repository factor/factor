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

! Undefined words's def field is equal to this.
"factor.FactorMissingDefinition" "INSTANCE" jfield jvarStatic$ @undefinedWord

: asm. (word -- assembly)
    ! Prints JVM bytecode disassembly of the given word.
    worddef [ $asm ] bind dup [
        print
    ] [
        drop "Not a compiled word." print
    ] ifte ;

: word? (obj -- boolean)
    "factor.FactorWord" is ;

: str>word ("word" -- word)
    ! Returns the top of the stack if it already been interned.
    dup word? [
        $dict [ "java.lang.String" ] "factor.FactorDictionary" "intern"
        jmethod jinvoke
    ] unless ;

: worddef? (obj -- boolean)
    "factor.FactorWordDefinition" is ;

: compound? (obj -- boolean)
    "factor.FactorCompoundDefinition" is ;

: shuffle? (obj -- boolean)
    "factor.FactorShuffleDefinition" is ;

: worddef (word -- worddef)
    str>word
    ! Get the 'def' field
    "factor.FactorWord" "def" jfield jvar$
    ! Is it equal to the missing word placeholder? Then push f.
    dup $undefinedWord = [ drop f ] when ;

: words (-- list)
    ! Pushes a list of all defined words.
    $dict [ ] "factor.FactorDictionary" "toWordList" jmethod jinvoke ;
