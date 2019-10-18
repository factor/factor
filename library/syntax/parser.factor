! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: parser
USING: errors kernel lists math namespaces streams strings words
unparser ;

! The parser uses a number of variables:
! line - the line being parsed
! pos  - position in the line
! use  - list of vocabularies
! in   - vocabulary for new words
!
! When a token is scanned, it is searched for in the 'use' list
! of vocabularies. If it is a parsing word, it is executed
! immediately. Otherwise it is appended to the parse tree.

SYMBOL: file

: parsing? ( word -- ? )
    dup word? [ "parsing" word-prop ] [ drop f ] ifte ;

: skip ( n line quot -- n )
    #! Find the next character that satisfies the quotation,
    #! which should have stack effect ( ch -- ? ).
    >r 2dup string-length < [
        2dup string-nth r> dup >r call [
            r> 2drop
        ] [
            >r 1 + r> r> skip
        ] ifte
    ] [
        r> drop nip string-length
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
    "\"" string-contains? ;

: skip-word ( n line -- n )
    2dup string-nth denotation? [
        drop 1 +
    ] [
        [ blank? ] skip
    ] ifte ;

: (scan) ( n line -- start end )
    [ skip-blank dup ] keep
    2dup string-length < [ skip-word ] [ drop ] ifte ;

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
            dup "use" get search [ ] [ str>number ] ?ifte
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
    "\n" ch-search dup -1 = [ drop "line" get string-length ] when ;

: until-eol ( -- str )
    #! This is just a hack to get "eval" to work with multiline
    #! strings from jEdit with EOL comments. Normally, input to
    #! the parser is already line-tokenized.
    (until-eol) (until) ;

: save-location ( word -- )
    #! Remember where this word was defined.
    dup set-word
    dup line-number get "line" set-word-prop
    dup "col" get "col"  set-word-prop
    file get "file" set-word-prop ;

: create-in "in" get create ;

: CREATE ( -- word )
    scan create-in dup save-location ;

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
    2dup string-nth CHAR: u = [
        swap 1 + dup 4 + [ rot substring hex> ] keep
    ] [
        over 1 + >r string-nth escape r>
    ] ifte ;

: next-char ( n str -- ch n )
    2dup string-nth CHAR: \\ = [
        >r 1 + r> next-escape
    ] [
        over 1 + >r string-nth r>
    ] ifte ;

: doc-comment-here? ( parsed -- ? )
    not "in-definition" get and ;

: parsed-stack-effect ( parsed str -- parsed )
    over doc-comment-here? [
        word "stack-effect" word-prop [
            drop
        ] [
            word swap "stack-effect" set-word-prop
        ] ifte
    ] [
        drop
    ] ifte ;

: documentation+ ( word str -- )
    over "documentation" word-prop [
        swap "\n" swap cat3
    ] when*
    "documentation" set-word-prop ;

: parsed-documentation ( parsed str -- parsed )
    over doc-comment-here? [
        word swap documentation+
    ] [
        drop
    ] ifte ;
