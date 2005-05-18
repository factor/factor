! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: parser
USING: errors kernel lists math namespaces sequences streams
strings unparser words ;

! The parser uses a number of variables:
! line - the line being parsed
! pos  - position in the line
! use  - list of vocabularies
! in   - vocabulary for new words
!
! When a token is scanned, it is searched for in the 'use' list
! of vocabularies. If it is a parsing word, it is executed
! immediately. Otherwise it is appended to the parse tree.

: use+ ( string -- ) "use" [ cons ] change ;

: parsing? ( word -- ? )
    dup word? [ "parsing" word-prop ] [ drop f ] ifte ;

SYMBOL: file

: skip ( i seq quot -- n | quot: elt -- ? )
    #! Find the next element starting at i that satisfies the
    #! quotation.
    >r 2dup length < [
        2dup nth r> dup >r call [
            r> 2drop
        ] [
            >r 1 + r> r> skip
        ] ifte
    ] [
        r> drop nip length
    ] ifte ; inline

: (skip-blank) ( n line -- n )
    [ blank? not ] skip ;

: skip-blank ( -- )
    "col" [ "line" get (skip-blank) ] change ;

: skip-word ( n line -- n )
    2dup nth CHAR: " = [ drop 1 + ] [ [ blank? ] skip ] ifte ;

: (scan) ( n line -- start end )
    [ (skip-blank) dup ] keep
    2dup length < [ skip-word ] [ drop ] ifte ;

: scan ( -- token )
    "col" get "line" get dup >r (scan) dup "col" set
    2dup = [ r> 3drop f ] [ r> subseq ] ifte ;

: save-location ( word -- )
    #! Remember where this word was defined.
    dup set-word
    dup line-number get "line" set-word-prop
    dup "col" get "col"  set-word-prop
    file get "file" set-word-prop ;

: create-in "in" get create dup save-location ;

: CREATE ( -- word ) scan create-in ;

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

! Used by parsing words
: ch-search ( ch -- index )
    "line" get "col" get index* ;

: (until) ( index -- str )
    "col" get swap dup 1 + "col" set "line" get subseq ;

: until ( ch -- str )
    ch-search (until) ;

: (until-eol) ( -- index ) 
    CHAR: \n ch-search dup -1 = [ drop "line" get length ] when ;

: until-eol ( -- str )
    #! This is just a hack to get "eval" to work with multiline
    #! strings from jEdit with EOL comments. Normally, input to
    #! the parser is already line-tokenized.
    (until-eol) (until) ;

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
    2dup nth CHAR: u = [
        swap 1 + dup 4 + [ rot subseq hex> ] keep
    ] [
        over 1 + >r nth escape r>
    ] ifte ;

: next-char ( n str -- ch n )
    2dup nth CHAR: \\ = [
        >r 1 + r> next-escape
    ] [
        over 1 + >r nth r>
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
        swap "\n" swap append3
    ] when*
    "documentation" set-word-prop ;

: parsed-documentation ( parsed str -- parsed )
    over doc-comment-here? [
        word swap documentation+
    ] [
        drop
    ] ifte ;
