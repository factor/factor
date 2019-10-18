! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
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
USE: combinators
USE: errors
USE: kernel
USE: lists
USE: logic
USE: math
USE: namespaces
USE: stack
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
    dup word? [
        "parsing" word-property
    ] [
        drop f
    ] ifte ;

: parsing ( -- )
    #! Mark the most recently defined word to execute at parse
    #! time, rather than run time. The word can use 'scan' to
    #! read ahead in the input stream.
    word t "parsing" set-word-property ;

: end? ( -- ? )
    "col" get "line" get str-length >= ;

: (with-parser) ( quot -- )
    end? [ drop ] [ [ call ] keep (with-parser) ] ifte ;

: with-parser ( text quot -- )
    #! Keep calling the quotation until we reach the end of the
    #! input.
    swap "line" set 0 "col" set
    (with-parser)
    "line" off "col" off ;

: ch ( -- ch ) "col" get "line" get str-nth ;
: advance ( -- ) "col" succ@ ;

: skip ( n line quot -- n )
    #! Find the next character that satisfies the quotation,
    #! which should have stack effect ( ch -- ? ).
    >r 2dup str-length < [
        2dup str-nth r> dup >r call [
            r> 2drop
        ] [
            >r succ r> r> skip
        ] ifte
    ] [
        r> drop nip str-length
    ] ifte ;

: skip-blank ( n line -- n )
    [ blank? not ] skip ;

: skip-word ( n line -- n )
    [ blank? ] skip ;

: denotation? ( ch -- ? )
    #! Hard-coded for now. Make this customizable later.
    #! A 'denotation' is a character that is treated as its
    #! own word, eg:
    #!
    #! "hello world"
    #!
    #! Will call the parsing word ".
    "\"" str-contains? ;

: (scan) ( n line -- start end )
    dup >r skip-blank dup r>
    2dup str-length < [
        2dup str-nth denotation? [
            drop succ
        ] [
            skip-word
        ] ifte
    ] [
        drop
    ] ifte ;

: scan ( -- token )
    "col" get "line" get dup >r (scan) dup "col" set
    2dup = [
        r> 3drop f
    ] [
        r> substring
    ] ifte ;

: scan-word ( -- obj )
    scan dup [
        dup "use" get search dup [
            nip
        ] [
            drop str>number
        ] ifte
    ] when ;

: parsed| ( parsed parsed obj -- parsed )
    #! Some ugly ugly code to handle [ a | b ] expressions.
    >r unswons r> cons swap [ swons ] each swons ;

: expect ( word -- )
    dup scan = not [
        "Expected " swap cat2 throw
    ] [
        drop
    ] ifte ;

: parsed ( obj -- )
    over "|" = [ nip parsed| "]" expect ] [ swons ] ifte ;

: (parse) ( str -- )
    [
        scan-word [
            dup parsing? [ execute ] [ parsed ] ifte
        ] when*
    ] with-parser ;

: parse ( str -- code )
    #! Parse the string into a parse tree that can be executed.
    f swap (parse) reverse ;

: eval ( "X" -- X )
    parse call ;

! Used by parsing words
: ch-search ( ch -- index )
    "col" get "line" get rot index-of* ;

: (until) ( index -- str )
    "col" get swap dup succ "col" set "line" get substring ;

: until ( ch -- str )
    ch-search (until) ;

: until-eol ( -- str )
    "line" get str-length (until) ;

: next-ch ( -- ch )
    end? [ "Unexpected EOF" throw ] [ ch advance ] ifte ;

: next-word-ch ( -- ch )
    "col" get "line" get skip-blank "col" set next-ch ;

! Once this file has loaded, we can use 'parsing' normally.
! This hack is needed because in Java Factor, 'parsing' is
! not parsing, but in CFactor, it is.
\ parsing t "parsing" set-word-property
