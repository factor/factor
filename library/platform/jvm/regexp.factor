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

IN: regexp
USE: arithmetic
USE: combinators
USE: kernel
USE: logic
USE: lists
USE: stack

: <regex> ( pattern -- regex )
    #! Compile the regex, if its not already compiled.
    dup "java.util.regex.Pattern" is not [
        [ "java.lang.String" ]
        "java.util.regex.Pattern" "compile"
        jinvoke-static
    ] when ;

: <matcher> ( string pattern -- matcher )
    [ "java.lang.CharSequence" ]
    "java.util.regex.Pattern" "matcher"
    jinvoke ;

: re-matches* ( matcher -- boolean )
    [ ] "java.util.regex.Matcher" "matches"
    jinvoke ;

: re-matches ( input regex -- boolean )
    <regex> <matcher> re-matches* ;

: [re-matches] ( matcher code -- boolean )
    #! If the matcher's re-matches* function returns true,
    #! evaluate the code with the matcher at the top of the
    #! stack. Otherwise, pop the matcher off the stack and
    #! push f.
    [ dup re-matches* ] dip [ drop f ] ifte ;

: re-replace* ( replace matcher -- string )
    [ "java.lang.String" ] "java.util.regex.Matcher"
    "replaceAll" jinvoke ;

: re-replace ( input regex replace -- string )
    #! Replaces all occurrences of the regex in the input string
    #! with the replace string.
    -rot <regex> <matcher> re-replace* ;

: re-split ( string split -- list )
    <regex> [ "java.lang.CharSequence" ]
    "java.util.regex.Pattern" "split" jinvoke array>list ;

: group ( index match -- )
    [ "int" ] "java.util.regex.Matcher" "group"
    jinvoke ;

: group-count ( matcher -- count )
    [ ] "java.util.regex.Matcher" "groupCount"
    jinvoke ;

: groups* ( matcher -- list )
    [
        [
            dup group-count [
                succ over group swap
            ] times* drop
        ] cons expand
    ] [re-matches] ;

: groups ( input regex -- list )
    <regex> <matcher> groups* ;

: group1 ( string regex -- string )
    groups dup [ car ] when ;
