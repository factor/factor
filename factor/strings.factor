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

: >bytes ( string -- array )
    ! Converts a string to an array of ASCII bytes. An exception
    ! is thrown if the string contains non-ASCII characters.
    "ASCII" swap
    [ "java.lang.String" ] "java.lang.String" "getBytes"
    jinvoke ;

: >lower ( str -- str )
    [ ] "java.lang.String" "toLowerCase" jinvoke ;

: >str ( obj -- string )
    ! Returns the Java string representation of this object.
    [ ] "java.lang.Object" "toString" jinvoke ;

: >title ( str -- str )
    1 str/ [ >upper ] dip >lower cat2 ;

: >upper ( str -- str )
    [ ] "java.lang.String" "toUpperCase" jinvoke ;

: <sbuf> ( -- StringBuffer )
    [ ] "java.lang.StringBuffer" jnew ;

: sbuf-append ( str buf -- buf )
    [ "java.lang.String" ] "java.lang.StringBuffer" "append"
    jinvoke ;

: cat ( [ "a" "b" "c" ] -- "abc" )
    ! If f appears in the list, it is not appended to the
    ! string.
    <sbuf> swap [ [ swap sbuf-append ] when* ] each >str ;

: cat2 ( "a" "b" -- "ab" )
    swap <sbuf> sbuf-append sbuf-append >str ;

: cat3 ( "a" "b" "c" -- "abc" )
    [ ] cons cons cons cat ;

: cat4 ( "a" "b" "c" "d" -- "abcd" )
    [ ] cons cons cons cons cat ;

: cat5 ( "a" "b" "c" "d" "e" -- "abcde" )
    [ ] cons cons cons cons cons cat ;

: char? ( obj -- boolean )
    "java.lang.Character" is ;

: ends-with-newline? ( string -- string )
    #! Test if the string ends with a newline or not.
    "\n" str-tail? ;

: html-entities ( -- alist )
    [
        [ #\< , "&lt;"   ]
        [ #\> , "&gt;"   ]
        [ #\& , "&amp;"  ]
        [ #\' , "&apos;" ]
        [ #\" , "&quot;" ]
    ] ;

: chars>entities ( str -- str )
    #! Convert <, >, &, ' and " to HTML entities.
    [ dup html-entities assoc dup rot ? ] str-map ;

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

: index-of* ( index string substring -- index )
    dup char? [
        -rot
        ! Why is the first parameter an int and not a char?
        [ "int" "int" ]
        "java.lang.String" "indexOf"
        jinvoke
    ] [
        -rot
        [ "java.lang.String" "int" ]
        "java.lang.String" "indexOf"
        jinvoke
    ] ifte ;

: index-of ( string substring -- index )
    0 -rot index-of* ;

: join ( list separator -- string )
    #! Returns a new string where each element of the list is
    #! separated by the separator.
    swap dup [
        uncons
        [ <sbuf> sbuf-append ] dip
        [
            [ dupd sbuf-append ] dip
            swap sbuf-append
        ] each >str nip
    ] [
        2drop ""
    ] ifte ;

: [re-matches] ( matcher code -- boolean )
    ! If the matcher's re-matches* function returns true,
    ! evaluate the code with the matcher at the top of the
    ! stack. Otherwise, pop the matcher off the stack and
    ! push f.
    [ dup re-matches* ] dip [ drop f ] ifte ;

: <matcher> ( string pattern -- matcher )
    [ "java.lang.CharSequence" ]
    "java.util.regex.Pattern" "matcher"
    jinvoke ;

: re-cond ( string alist -- )
    dup [
        unswons [ over ] dip ( string tail string head )
        uncons [ groups/t ] dip ( string tail groups code )
        over [
            2nip call
        ] [
            2drop re-cond
        ] ifte
    ] [
        2drop
    ] ifte ;

: re-matches* ( matcher -- boolean )
    [ ] "java.util.regex.Matcher" "matches"
    jinvoke ;

: re-matches ( input regex -- boolean )
    <regex> <matcher> re-matches* ;

: re-replace* ( replace matcher -- string )
    [ "java.lang.String" ] "java.util.regex.Matcher"
    "replaceAll" jinvoke ;

: re-replace ( input regex replace -- string )
    ! Replaces all occurrences of the regex in the input string
    ! with the replace string.
    -rot <regex> <matcher> re-replace* ;

: re-split ( string split -- list )
    <regex> [ "java.lang.CharSequence" ]
    "java.util.regex.Pattern" "split" jinvoke array>list ;

: <regex> (pattern -- regex)
    ! Compile the regex, if its not already compiled.
    dup "java.util.regex.Pattern" is not [
        [ "java.lang.String" ]
        "java.util.regex.Pattern" "compile"
        jinvoke-static
    ] when ;

: spaces ( len -- str )
    ! Returns a string containing the given number of spaces.
    <sbuf> swap [ " " swap sbuf-append ] times >str ;

: split ( string split -- list )
    2dup index-of dup -1 = [
        2drop dup str-length 0 = [
            drop f
        ] [
            unit
        ] ifte
    ] [
        swap [ str// ] dip split cons
    ] ifte ;

: string? ( obj -- ? )
    "java.lang.String" is ;

: str->=< ( str1 str2 -- n )
    swap [ "java.lang.String" ] "java.lang.String" "compareTo"
    jinvoke ;

: str-lexi> ( str1 str2 -- ? )
    ! Returns if the first string lexicographically follows str2
    str->=< 0 > ;

: str/ ( str index -- str str )
    ! Returns 2 strings, that when concatenated yield the
    ! original string.
    2dup str-tail [ str-head ] dip ;

: str// ( str index -- str str )
    ! Returns 2 strings, that when concatenated yield the
    ! original string, without the character at the given
    ! index.
    2dup succ str-tail [ str-head ] dip ;

: str-each ( str [ code ] -- )
    ! Execute the code, with each character of the string pushed
    ! onto the stack.
    over str-length [
        -rot 2dup [ [ str-get ] dip call ] 2dip
    ] times* 2drop ;

: str-expand ( [ code ] -- str )
    expand cat ;

: str-get (index str -- char)
    [ "int" ] "java.lang.String" "charAt" jinvoke ;

: str-head ( str index -- str )
    #! Returns a new string, from the beginning of the string
    #! until the given index.
    0 transp substring ;

: str-headcut ( str begin -- str str )
    str-length str/ ;

: str-head? ( str begin -- str )
    #! If the string starts with begin, return the rest of the
    #! string after begin. Otherwise, return f.
    2dup str-length< [
        2drop f
    ] [
        tuck str-headcut
        [ = ] dip f ?
    ] ifte ;

: str-length ( str -- length )
    [ ] "java.lang.String" "length" jinvoke ;

: str-length< ( str str -- boolean )
    ! Compare string lengths.
    [ str-length ] 2apply < ;

: str-map ( str code -- str )
    f transp [
        ( accum code elem -- accum code )
        transp over >r >r call r> cons r>
    ] str-each drop nreverse cat ;

: str-contains ( substr str -- ? )
    swap index-of -1 = not ;

: str-tail ( str index -- str )
    #! Returns a new string, from the given index until the end
    #! of the string.
    over str-length rot substring ;

: str-tailcut ( str end -- str str )
    str-length [ dup str-length ] dip - str/ ;

: str-tail? ( str end -- str )
    #! If the string ends with end, return the start of the
    #! string before end. Otherwise, return f.
    2dup str-length< [
        2drop f
    ] [
        tuck str-tailcut swap
        [ = ] dip f ?
    ] ifte ;

: substring ( start end str -- str )
    [ "int" "int" ] "java.lang.String" "substring"
    jinvoke ;

: max-str-length ( list -- len )
    ! Returns the length of the longest string in the given
    ! list.
    0 swap [ str-length max ] each ;

: pad-string ( len str -- str )
    str-length - spaces ;
