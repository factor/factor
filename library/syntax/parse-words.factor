! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: parser
USING: errors hashtables io kernel lists math namespaces
sequences strings vectors words ;

! The parser uses a number of variables:
! line - the line being parsed
! pos  - position in the line
! use  - list of vocabularies
! in   - vocabulary for new words
!
! When a token is scanned, it is searched for in the 'use' list
! of vocabularies. If it is a parsing word, it is executed
! immediately. Otherwise it is appended to the parse tree.

SYMBOL: use
SYMBOL: in

: check-vocab ( name -- vocab )
    dup vocab
    [ ] [ " is not a vocabulary name" append throw ] ?if ;

: use+ ( string -- )
    #! Add a vocabulary to the search path.
    check-vocab use get push ;

: set-use ( seq -- )
    #! Convert to a later so we can push later.
    [ check-vocab ] map >vector use set ;

: set-in ( name -- )
    dup ensure-vocab dup in set use+ ;

: parsing? ( word -- ? )
    dup word? [ "parsing" word-prop ] [ drop f ] if ;

SYMBOL: file
SYMBOL: line-number

SYMBOL: line-text
SYMBOL: column

: skip ( i seq quot -- n | quot: elt -- ? )
    over >r find* drop dup -1 =
    [ drop r> length ] [ r> drop ] if ; inline

: skip-blank ( -- )
    column [ line-text get [ blank? not ] skip ] change ;

: skip-word ( n line -- n )
    2dup nth CHAR: " = [ drop 1+ ] [ [ blank? ] skip ] if ;

: (scan) ( n line -- start end )
    dupd 2dup length < [ skip-word ] [ drop ] if ;

: scan ( -- token )
    skip-blank
    column [ line-text get (scan) dup ] change
    2dup = [ 2drop f ] [ line-text get subseq ] if ;

: save-location ( word -- )
    #! Remember where this word was defined.
    dup set-word
    dup line-number get "line" set-word-prop
    file get "file" set-word-prop ;

: create-in in get create dup save-location ;

: CREATE ( -- word ) scan create-in ;

! If this variable is on, the parser does not internalize words;
! it just appends strings to the parse tree as they are read.
SYMBOL: string-mode
global [ string-mode off ] bind

: scan-word ( -- obj )
    scan dup [
        dup ";" = not string-mode get and [
            dup use get hash-stack [ ] [ string>number ] ?if
        ] unless
    ] when ;

! Used by parsing words
: ch-search ( ch -- index )
    column get line-text get index* ;

: (until) ( index -- str )
    column [ swap dup 1+ ] change line-text get subseq ;

: until ( ch -- str )
    ch-search (until) ;

: (until-eol) ( -- index ) 
    CHAR: \n ch-search dup -1 =
    [ drop line-text get length ] when ;

: until-eol ( -- str )
    #! This is just a hack to get "eval" to work with multiline
    #! strings from jEdit with EOL comments. Normally, input to
    #! the parser is already line-tokenized.
    (until-eol) (until) ;

: escape ( ch -- esc )
    H{
        { CHAR: e  CHAR: \e }
        { CHAR: n  CHAR: \n }
        { CHAR: r  CHAR: \r }
        { CHAR: t  CHAR: \t }
        { CHAR: s  CHAR: \s }
        { CHAR: \s CHAR: \s }
        { CHAR: 0  CHAR: \0 }
        { CHAR: \\ CHAR: \\ }
        { CHAR: \" CHAR: \" }
    } hash dup [ "Bad escape" throw ] unless ;

: next-escape ( n str -- ch n )
    2dup nth CHAR: u = [
        swap 1+ dup 4 + [ rot subseq hex> ] keep
    ] [
        over 1+ >r nth escape r>
    ] if ;

: next-char ( n str -- ch n )
    2dup nth CHAR: \\ = [
        >r 1+ r> next-escape
    ] [
        over 1+ >r nth r>
    ] if ;

: doc-comment-here? ( parsed -- ? )
    not "in-definition" get and ;

: parsed-stack-effect ( parsed str -- parsed )
    over doc-comment-here? [
        word "stack-effect" word-prop [
            drop
        ] [
            word swap "stack-effect" set-word-prop
        ] if
    ] [
        drop
    ] if ;

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
    ] if ;

: (parse-string) ( n str -- n )
    2dup nth CHAR: " = [
        drop 1+
    ] [
        [ next-char swap , ] keep (parse-string)
    ] if ;

: parse-string ( -- str )
    #! Read a string from the input stream, until it is
    #! terminated by a ".
    column [
        [ line-text get (parse-string) ] "" make swap
    ] change ;

global [
    {
        "scratchpad" "syntax" "arrays" "compiler" "errors"
        "generic" "hashtables" "inference" "inspector"
        "interpreter" "io" "jedit" "kernel" "listener" "lists"
        "math" "memory" "namespaces" "parser" "prettyprint"
        "queues" "sequences" "shells" "strings" "styles" "test"
        "threads" "vectors" "words"
    } set-use
    "scratchpad" set-in
] bind
