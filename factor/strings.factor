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

! Used by chars>entities
[
    [ #\< , "&lt;"   ]
    [ #\> , "&gt;"   ]
    [ #\& , "&amp;"  ]
! Bad parser!
!    [ #\' , "&apos;" ]
!    [ #\" , "&quot;" ]
] @entities

: >bytes ( string -- array )
    ! Converts a string to an array of ASCII bytes. An exception is thrown
    ! if the string contains non-ASCII characters.
    "ASCII" swap
    [ "java.lang.String" ] "java.lang.String" "getBytes" jmethod jinvoke ;

: cat ([ "a" "b" "c" ] -- "abc")
    [ "factor.FactorList" ] "factor.FactorLib" "cat" jmethod jinvokeStatic ;

: cat2 ("a" "b" -- "ab")
    [ "java.lang.Object" "java.lang.Object" ]
    "factor.FactorLib" "cat2" jmethod jinvokeStatic ;

: cat3 ("a" "b" "c" -- "abc")
    [ "java.lang.Object" "java.lang.Object" "java.lang.Object" ]
    "factor.FactorLib" "cat3" jmethod jinvokeStatic ;

: cat4 ("a" "b" "c" "d" -- "abcd")
    cat2 cat3 ;

: chars>entities (str -- str)
    ! Convert <, >, &, ' and " to HTML entities.
    "" [ dup $entities assoc dup [ nip ] [ drop ] ifte ] strmap ;

: group (index match --)
    [ "int" ] "java.util.regex.Matcher" "group"
    jmethod jinvoke ;

: groupCount (matcher -- count)
    [ ] "java.util.regex.Matcher" "groupCount"
    jmethod jinvoke ;

: groups* (matcher -- list)
    [
        [
            dup groupCount [
                succ over group swap
            ] times* drop
        ] cons expand
    ] [matches] ;

: groups (input regex -- list)
    <regex> <matcher> groups* ;

: [matches] ( matcher code -- boolean )
    ! If the matcher's matches* function returns true,
    ! evaluate the code with the matcher at the top of the
    ! stack. Otherwise, pop the matcher off the stack and
    ! push f.
    [ dup matches* ] dip [ drop f ] ifte ;

: <matcher> (string pattern -- matcher)
    [ "java.lang.CharSequence" ]
    "java.util.regex.Pattern" "matcher"
    jmethod jinvoke ;

: matches* (matcher -- boolean)
    [ ] "java.util.regex.Matcher" "matches"
    jmethod jinvoke ;

: matches (input regex -- boolean)
    <regex> <matcher> matches* ;

: replace* ( replace matcher -- string )
    [ "java.lang.String" ] "java.util.regex.Matcher"
    "replaceAll" jmethod jinvoke ;

: replace ( input regex replace -- string )
    ! Replaces all occurrences of the regex in the input string
    ! with the replace string.
    -rot <regex> <matcher> replace* ;

: <regex> (pattern -- regex)
    ! Compile the regex, if its not already compiled.
    dup "java.util.regex.Pattern" is not [
        [ "java.lang.String" ] "java.util.regex.Pattern" "compile"
        jmethod jinvokeStatic
    ] when ;

: strget (index str -- char)
    [ "int" ] "java.lang.String" "charAt" jmethod jinvoke ;

: strlen (str -- length)
    [ ] "java.lang.String" "length" jmethod jinvoke ;

: streach (str [ code ] --)
    ! Execute the code, with each character of the string pushed onto the
    ! stack.
    over strlen [
        -rot 2dup [ [ strget ] dip call ] 2dip
    ] times* 2drop ;

: strmap (str initial [ code ] -- [ mapping ])
    ! If the 'initial' parameter is f, turn it into "".
    ! Maybe cat should handle this instead?
    [ dup [ drop "" ] unless ] dip
    swapd [ ] cons cons cons
    restack
        streach
    unstack cat ;
