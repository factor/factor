!:folding=indent:collapseFolds=1:

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
USE: arithmetic
USE: combinators
USE: errors
USE: kernel
USE: lists
USE: logic
USE: namespaces
USE: stack
USE: strings
USE: words
USE: vocabularies
USE: unparser

! Number parsing

: letter? #\a #\z between? ;
: LETTER? #\A #\Z between? ;
: digit? #\0 #\9 between? ;

: not-a-number "Not a number" throw ;

: digit> ( ch -- n )
    [
        [ digit? ] [ #\0 - ]
        [ letter? ] [ #\a - 10 + ]
        [ LETTER? ] [ #\A - 10 + ]
        [ drop t ] [ not-a-number ]
    ] cond ;

: >digit ( n -- ch )
    dup 10 < [ #\0 + ] [ 10 - #\a + ] ifte ;

: digit ( num digit -- num )
    "base" get swap 2dup >= [
        >r * r> +
    ] [
        not-a-number
    ] ifte ;

: (str>fixnum) ( str -- num )
    0 swap [ digit> digit ] str-each ;

: str>fixnum ( str -- num )
    #! Parse a string representation of an integer.
    dup str-length 0 = [
        drop not-a-number
    ] [
        dup "-" str-head? dup [
            nip str>fixnum neg
        ] [
            drop (str>fixnum)
        ] ifte
    ] ifte ;

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
        "parsing" swap word-property
    ] [
        drop f
    ] ifte ;

: parsing ( -- ) t "parsing" word set-word-property ;

: <parsing "line" set 0 "pos" set ;
: parsing> f "line" set f "pos" set ;
: end? ( -- ? ) "pos" get "line" get str-length >= ;
: ch ( -- ch ) "pos" get "line" get str-nth ;
: advance ( -- ) "pos" succ@ ;

: ch-blank? ( -- ? ) end? [ f ] [ ch blank? ] ifte ;
: skip-blank ( -- ) [ ch-blank? ] [ advance ] while ;
: ch-word? ( -- ? ) end? [ f ] [ ch blank? not ] ifte ;
: skip-word ( -- ) [ ch-word? ] [ advance ] while ;

: ch-dispatch? ( -- ? )
    #! Hard-coded for now. Make this customizable later.
    #! A 'dispatch' is a character that is treated as its
    #! own word, eg:
    #!
    #! "hello world"
    #!
    #! Will call the parsing word ".
    ch "\"!" str-contains? ;

: (scan) ( -- start end )
    skip-blank "pos" get
    end? [
        dup
    ] [
        ch-dispatch? [ advance ] [ skip-word ] ifte "pos" get
    ] ifte ;

: scan ( -- str )
    (scan) 2dup = [ 2drop f ] [ "line" get substring ] ifte ;

: parse-word ( str -- obj )
    dup "use" get search dup [
        nip
    ] [
        drop str>fixnum
    ] ifte ;

: parsed ( obj -- )
    swons ;

: number, ( num -- )
    str>fixnum parsed ;

: word, ( str -- )
    [
        parse-word dup parsing? [ execute ] [ parsed ] ifte
    ] when* ;

: (parse) <parsing [ end? not ] [ scan word, ] while parsing> ;

: parse ( str -- code )
    #! Parse the string into a parse tree that can be executed.
    f swap (parse) nreverse ;

: eval ( "X" -- X )
    parse call ;

!!! Used by parsing words
: ch-search ( ch -- index )
    "pos" get "line" get rot index-of* ;

: (until) ( index -- str )
    "pos" get swap dup succ "pos" set "line" get substring ;

: until ( ch -- str )
    ch-search (until) ;

: until-eol ( ch -- str )
    "line" get str-length (until) ;

: next-ch ( -- ch )
    end? [ "Unexpected EOF" throw ] [ ch advance ] ifte ;

!!! Parsing words. 'builtins' is a stupid vocabulary name now
!!! that it does not contain Java words anymore!

IN: builtins

! Constants
: t t parsed ; parsing
: f f parsed ; parsing

! Lists
: [ f ; parsing
: ] nreverse parsed ; parsing

: expect-] scan "]" = not [ "Expected ]" throw ] when ;

: one-word ( -- obj ) f scan word, car ;

: | ( syntax: | cdr ] )
    #! See the word 'parsed'.
    "|"
    nreverse dup last* one-word swap rplacd parsed
    expect-] ; parsing

! Colon defs
: :
    #! Begin a word definition. Word name follows.
    scan "in" get create f ; parsing

: ;
    #! End a word definition.
    nreverse define ; parsing

! Vocabularies
: DEFER: scan "in" get create drop ; parsing
: USE: scan "use" cons@ ; parsing
: IN: scan dup "use" cons@ "in" set ; parsing

! \x
: escape ( ch -- esc )
    [
        [ #\e | #\\e ]
        [ #\n | #\\n ]
        [ #\r | #\\r ]
        [ #\t | #\\t ]
        [ #\s | #\\s ]
        [ #\\s | #\\s ]
        [ #\0 | #\\0 ]
        [ #\\\ | #\\\ ]
        [ #\\" | #\\" ]
    ] assoc ;

! String literal

: parse-escape ( -- )
    next-ch escape dup [ % ] [ drop "Bad escape" throw ] ifte ;

: parse-string ( -- )
    next-ch dup #\" = [
        drop
    ] [
        dup #\\\ = [ drop parse-escape ] [ % ] ifte parse-string
    ] ifte ;

: "
    #! Note the ugly hack to carry the new value of 'pos' from
    #! the <% %> scope up to the original scope.
    <% parse-string "pos" get %> swap "pos" set parsed ; parsing

! Comments
: ( ")" until drop ; parsing
: ! until-eol drop ; parsing
: #! until-eol drop ; parsing
    
! Reading numbers in other bases

: BASE: ( base -- )
    #! Read a number in a specific base.
    "base" get >r "base" set scan number, r> "base" set ;

: HEX: 16 BASE: ; parsing
: DEC: 10 BASE: ; parsing
: OCT: 8 BASE: ; parsing
: BIN: 2 BASE: ; parsing
