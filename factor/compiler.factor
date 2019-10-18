!:folding=indent:collapseFolds=1:

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

: asm ( word -- )
    #! Prints JVM bytecode disassembly of a compiled word.
    intern [ $asm ] bind dup [
        print
    ] [
        drop "Not a compiled word." print
    ] ifte ;

: balance ( code -- effect )
    #! Push stack effect of a quotation.
    no-name effect ;

: balance>list ( quotation -- list )
    balance effect>list ;

: compile* ( word -- )
    interpreter swap
    [ "factor.FactorInterpreter" ] "factor.FactorWord" "compile"
    jinvoke ;

: compile ( word -- )
    #! Compile a word.
    dup worddef compiled? [
        drop
    ] [
        intern compile*
    ] ifte ;

: compile-all ( -- )
    #! Compile all words.
    words [ compile ] each ;

: words-not-primitives ( -- list )
    words [ worddef primitive? not ] subset ;

: dump-image ( -- )
    "! This is an automatically-generated fastload image." print
    words-not-primitives [
        dup worddef dup compiled? [
            swap >str .
            dup class-of .
            "define" print
            word-of-worddef [ $inline ] bind
            [ "inline" print ] when
        ] [
            drop see
        ] ifte
    ] each ;

: dump-image-file ( file -- )
    <namespace> [
        <filecw> @stdio
        dump-image
        $stdio fclose
    ] bind ;

: dump-boot-image ( -- )
    t @dump
    compile-all
    "factor/boot.fasl" dump-image-file
    "Now, restart Factor without the -no-fasl switch." print
    f @dump ;

: effect ( word -- effect )
    #! Push stack effect of a word.
    worddef [ ] "factor.FactorWordDefinition"
    "getStackEffect" jinvoke ;

: effect>list ( effect -- effect )
    [
        [ "factor.compiler.StackEffect" "inD" jvar$ ]
        [ "factor.compiler.StackEffect" "outD" jvar$ ]
        [ "factor.compiler.StackEffect" "inR" jvar$ ]
        [ "factor.compiler.StackEffect" "outR" jvar$ ]
    ] interleave unit cons cons cons ;
