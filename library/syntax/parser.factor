! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004, 2005 Slava Pestov.
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

IN: parser
USE: errors
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: strings
USE: words
USE: unparser

! The parser uses a number of variables:
! line - the line being parsed
! pos  - position in the line
! use  - list of vocabularies
! in   - vocabulary for new words
!
! When a token is scanned, it is searched for in the 'use' list
! of vocabularies. If it is a parsing word, it is executed
! immediately. Otherwise it is appended to the parse tree.

: parsing? ( word -- ? )
    dup word? [ "parsing" word-property ] [ drop f ] ifte ;

: skip ( n line quot -- n )
    #! Find the next character that satisfies the quotation,
    #! which should have stack effect ( ch -- ? ).
    >r 2dup str-length < [
        2dup str-nth r> dup >r call [
            r> 2drop
        ] [
            >r 1 + r> r> skip
        ] ifte
    ] [
        r> drop nip str-length
    ] ifte ; inline

: skip-blank ( n line -- n )
    [ blank? not ] skip ;

: denotation? ( ch -- ? )
    #! Hard-coded for now. Make this customizable later.
    #! A 'denotation' is a character that is treated as its
    #! own word, eg:
    #!
    #! "hello world"
    #!
    #! Will call the parsing word ".
    "\"" str-contains? ;

: skip-word ( n line -- n )
    2dup str-nth denotation? [
        drop 1 +
    ] [
        [ blank? ] skip
    ] ifte ;

: (scan) ( n line -- start end )
    [ skip-blank dup ] keep
    2dup str-length < [ skip-word ] [ drop ] ifte ;

: scan ( -- token )
    "col" get "line" get dup >r (scan) dup "col" set
    2dup = [ r> 3drop f ] [ r> substring ] ifte ;

! If this variable is on, the parser does not internalize words;
! it just appends strings to the parse tree as they are read.
SYMBOL: string-mode
global [ string-mode off ] bind

: scan-word ( -- obj )
    scan dup [
        dup ";" = not string-mode get and [
            dup "use" get search [ str>number ] ?unless
        ] unless
    ] when ;

: parse-loop ( -- )
    scan-word [
        dup parsing? [ execute ] [ swons ] ifte  parse-loop
    ] when* ;

: (parse) ( str -- )
    "line" set 0 "col" set
    parse-loop
    "line" off "col" off ;

: parse ( str -- code )
    #! Parse the string into a parse tree that can be executed.
    f swap (parse) reverse ;

: eval ( "X" -- X )
    parse call ;

! Used by parsing words
: ch-search ( ch -- index )
    "col" get "line" get rot index-of* ;

: (until) ( index -- str )
    "col" get swap dup 1 + "col" set "line" get substring ;

: until ( ch -- str )
    ch-search (until) ;

: (until-eol) ( -- index ) 
    "\n" ch-search dup -1 = [ drop "line" get str-length ] when ;

: until-eol ( -- str )
    #! This is just a hack to get "eval" to work with multiline
    #! strings from jEdit with EOL comments. Normally, input to
    #! the parser is already line-tokenized.
    (until-eol) (until) ;

: CREATE ( -- word )
    scan "in" get create dup set-word
    dup f "documentation" set-word-property
    dup f "stack-effect" set-word-property
    dup "line-number" get "line" set-word-property
    dup "col"         get "col"  set-word-property
    dup "file"        get "file" set-word-property ;

: escape ( ch -- esc )
    [
        [[ CHAR: e  CHAR: \e ]]
        [[ CHAR: n  CHAR: \n ]]
        [[ CHAR: r  CHAR: \r ]]
        [[ CHAR: t  CHAR: \t ]]
        [[ CHAR: s  CHAR: \s ]]
        [[ CHAR: \s CHAR: \s ]]
        [[ CHAR: 0  CHAR: \0 ]]
        [[ CHAR: \\ CHAR: \\ ]]
        [[ CHAR: \" CHAR: \" ]]
    ] assoc dup [ "Bad escape" throw ] unless ;

: next-escape ( n str -- ch n )
    2dup str-nth CHAR: u = [
        swap 1 + dup 4 + [ rot substring hex> ] keep
    ] [
        over 1 + >r str-nth escape r>
    ] ifte ;

: next-char ( n str -- ch n )
    2dup str-nth CHAR: \\ = [
        >r 1 + r> next-escape
    ] [
        over 1 + >r str-nth r>
    ] ifte ;

: doc-comment-here? ( parsed -- ? )
    not "in-definition" get and ;

: parsed-stack-effect ( parsed str -- parsed )
    over doc-comment-here? [
        word stack-effect [
            drop
        ] [
            word swap "stack-effect" set-word-property
        ] ifte
    ] [
        drop
    ] ifte ;

: documentation+ ( word str -- )
    over "documentation" word-property [
        swap "\n" swap cat3
    ] when*
    "documentation" set-word-property ;

: parsed-documentation ( parsed str -- parsed )
    over doc-comment-here? [
        word swap documentation+
    ] [
        drop
    ] ifte ;
