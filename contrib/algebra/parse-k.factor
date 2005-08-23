IN: parse-k
USING: sequences kernel math strings combinators namespaces prettyprint io inspector
       errors parser generic lists kernel-internals hashtables words vectors ;
       ! remove: inspector

! Tokenizer

PREDICATE: fixnum num-char "0123456789." member? ;
PREDICATE: fixnum special-char ";!@#$%^&*?/|\\=+_-" member? ;
PREDICATE: fixnum opener-char "([{" member? ;
PREDICATE: fixnum closer-char "}])" member? ;
PREDICATE: fixnum apost CHAR: ' = ;

TUPLE: tok char ;

TUPLE: brackets seq ender ;

PREDICATE: symbol apostrophe 
    #! placeholder
    apostrophe = ;

SYMBOL: code #! Source code
SYMBOL: spot #! Current index of string

: take-until ( quot -- parsed-stuff | quot: char -- ? )
    #! Take the substring of a string starting at spot
    #! from code until the quotation given is true and
    #! advance spot to after the substring.
    >r spot get code get 2dup r>
    skip [ swap subseq ] keep
    spot set ;

: parse-blank ( -- )
    #! Advance code past any whitespace, including newlines
    spot get code get [ blank? not ] skip spot set ;

: not-done? ( -- ? )
    #! Return t if spot is not at the end of code
    code get length spot get = not ;

: incr-spot ( -- )
    #! Increment spot.
    spot [ 1 + ] change ;

: parse-var ( -- variable-name )
    #! Take a series of letters from code, advancing
    #! spot and returning the letters.
    [ letter? not ] take-until ;

: parse-num ( -- number )
    #! Take a number from code, advancing spot and
    #! returning the number.
    [ num-char? not ] take-until parse-number ;

GENERIC: token ( list char -- list )
    #! Given the first character, decide how to get the
    #! next token

: get-token ( -- char )
    spot get code get nth ;

: next-token ( list -- list )
    #! Take one token from code and return it
    parse-blank not-done? [
         get-token token
    ] when ;

M: letter token
    drop parse-var swons next-token ;
M: num-char token
    drop parse-num swons next-token ;
M: special-char token
    <tok> swons incr-spot next-token ;
M: opener-char token
    drop f incr-spot next-token ;
M: closer-char token
    <brackets> swons incr-spot next-token ;
M: apost token
    drop apostrophe swons incr-spot next-token ;

: tokenize ( string -- tokens )
    #! Tokenize a string, returning a list of tokens
    [
        code set 0 spot set
        f next-token reverse
    ] with-scope ;




! Parser

PREDICATE: tok operator
    #! A normal operator, like +
    tok-char "!@#$%^&*?/|=+_-" member? ;

TUPLE: apply func args ;
    #! Function application
C: apply
     >r [ ] subset r> 
    [ set-apply-args ] keep
    [ set-apply-func ] keep ;

UNION: value number string ;

: semicolon ( -- semicolon )
    #! The semicolon token
    << tok f CHAR: ; >> ;

PREDICATE: tok semicol
    semicolon = ;

: nest-apply ( [ ast ] -- apply )
    unswons unit swap [
        swap <apply> unit
    ] each car  ;

GENERIC: parse-token ( ast tokens token -- ast tokens )
    #! Take one or more tokens

DEFER: parse-tokens

: semicolon-split ( list -- [ ast ] )
    reverse semicolon unit split [ parse-tokens ] map ;

M: value parse-token
    swapd swons swap ;

: case ( value quot-alist -- )
    #! This is evil. It's just like Joy's case but there's
    #! no default. [ ] case is equivalent to drop
    assoc call ;

M: brackets parse-token
    swapd dup brackets-seq swap brackets-ender [
          [ CHAR: ]
            semicolon-split >r unswons r> <apply> swons
        ] [ CHAR: }
            semicolon-split >vector swons
        ] [ CHAR: )
            reverse parse-tokens swons
        ]
    ] case swap ;

M: object tok-char drop -1 ; ! Hack!

GENERIC: tok>string ( token/string -- string )
M: tok tok>string
    tok-char ch>string ;
M: string tok>string ;

: binary-op ( ast tokens token -- ast )
    >r >r unswons r> parse-tokens 2list r>
    tok>string swap <apply> swons ;

: unary-op ( ast tokens token -- ast )
    tok>string -rot nip
    parse-tokens unit <apply> unit ;

: apost-op ( ast tokens token -- ast )
    nip tok-char ch>string swons ;

M: operator parse-token
    over [
        pick [
            binary-op
        ] [
            unary-op
        ] ifte
    ] [
        apost-op
    ] ifte f ;

M: apostrophe parse-token 
    drop unswons >r parse-tokens >r car r> 2list r>
    unit parse-tokens swap <apply> swons f ;

: (parse-tokens) ( ast tokens -- ast )
    dup [
        unswons parse-token (parse-tokens)
    ] [
        drop
    ] ifte ;

: parse-tokens ( tokens -- ast )
    #! Convert a list of tokens into an AST
    f swap (parse-tokens) nest-apply ;

: parse-full ( string -- ast )
    #! Convert a string into an AST
    tokenize parse-tokens ;


! Compiler

GENERIC: compile-ast ( vars ast -- quot )

M: string compile-ast ! variables
    swap index dup -1 = [
        "Variable not found" throw
    ] [
        [ swap array-nth ] cons
    ] ifte ;

: replace-with ( data -- [ drop data ] )
    \ drop swap 2list ;

UNION: comp-literal number general-list ;

M: comp-literal compile-ast ! literal numbers
    replace-with nip ;

: seq-stupid-all? ( seq pred -- ? )
    t -rot [ call and ] cons each ; inline

: accumulator ( vars { asts } closer -- quot )
    -rot [
        [
            \ dup ,
            compile-ast %
            dup %
        ] each-with
    ] make-list nip ;

M: vector compile-ast ! literal vectors
    dup [ number? ] seq-stupid-all? [
        replace-with nip
    ] [
        [ , ] accumulator [ make-vector nip ] cons
    ] ifte ;

: infix-relation
    #! Wraps operators like = and > so that if they're given
    #! f as either argument, they return f, and they return f if
    #! the operation yields f, but if it yields t, it returns the
    #! left argument. This way, these types of operations can be
    #! composed.
    >r 2dup and not [
        r> 3drop f
    ] [
        dupd r> call [
            drop f
        ] unless
    ] ifte ;

: functions
    #! Regular functions
    #! Gives quotation applicable to stack
    {{
        [ [[ "sin" 1 ]] sin ]
        [ [[ "cos" 1 ]] cos ]
        [ [[ "+" 2 ]] + ]
        [ [[ "-" 2 ]] - ]
        [ [[ ">" 2 ]] [ > ] infix-relation ]
        [ [[ "<" 2 ]] [ < ] infix-relation ]
        [ [[ "=" 2 ]] [ = ] infix-relation ]
        [ [[ "-" 1 ]] neg ]
        [ [[ "~" 1 ]] not ]
        [ [[ "&" 2 ]] and ]
        [ [[ "|" 2 ]] or ]
        [ [[ "*" 2 ]] * ]
        [ [[ "log" 1 ]] log ]
        [ [[ "plusmin" 2 ]] [ + ] 2keep - ]
        [ [[ "@" 2 ]] swap nth ]
        [ [[ "sqrt" 1 ]] sqrt ]
        [ [[ "/" 2 ]] / ]
        [ [[ "^" 2 ]] ^ ]
    }} ;

: drc ( list -- list )
    #! all of list except last element (backwards cdr)
    dup cdr [
        uncons drc cons
    ] [
        drop f
    ] ifte ;

: map-with-left ( seq object quot -- seq )
    [ swapd call ] cons swapd map-with ; inline

: high-functions
    #! Higher-order functions
    #! Gives quotation applicable to quotation and rest of stack
    {{
        [ [[ "each" 2 ]] 2map ]
        [ [[ "each" 1 ]] map ]
        [ [[ "right" 2 ]] map-with ]
        [ [[ "left" 2 ]] map-with-left ]
        
    }} ;

: get-hash ( key table -- value )
    #! like hash but throws exception if f
    dupd hash [ nip ] [
        [ "Key not found " write . ] string-out throw
    ] ifte* ;

: >apply< ( apply -- func args )
    dup apply-func swap apply-args ;

: make-apply ( arity apply/string -- quot )
    dup string? [
        swons functions get-hash
    ] [
        >apply< car >r over r> make-apply
        -rot swons high-functions get-hash cons
    ] ifte ;

: get-function ( apply -- quot )
    >apply< length swap make-apply ;

M: apply compile-ast ! function application
    [ apply-args [ swap ] accumulator drc [ nip ] append ] keep
    get-function append ;

: push-list ( list item -- list )
    unit append ;

: parse-comp ( args string -- quot )
    #! Compile a string into a quotation w/o prologue
    parse-full compile-ast ;

: prologue ( args -- quot )
    #! Build the prolog for a function
    [
        length dup ,  \ <array> ,
        [ 1 - ] keep [
            2dup -  [ swap set-array-nth ] cons , \ keep ,
        ] repeat drop
    ] make-list ;

: ast>quot ( args ast -- quot )
    over prologue -rot compile-ast append ;

: define-math ( string -- )
    dup parse-full apply-args 2unlist swap
    >apply< >r create-in r>
    [ "math-args" set-word-prop ] 2keep
    >r tuck >r >r swap "code" set-word-prop r> r> r>
    rot ast>quot define-compound ;

: MATH:
    #! MATH: sq[x]=x*x ;
    "in-definition" on
    string-mode on 
    [
        " " join string-mode off define-math
    ] f ; parsing

: TEST-MATH:
    #! Executes and prints the result of a math
    #! expression at parsetime
    string-mode on [
        concat/spaces string-mode off parse-full
        f swap ast>quot call .
    ] f ; parsing

! PREDICATE: compound infix-word "code" word-prop ;
! M: infix-word definer
!     drop POSTPONE: MATH: ;
! M: infix-word class.
!     "code" word-prop write " ;" print ;
!
! Redefine compound to not include infix words so see works
! IN: words
! USING: kernel words parse-k ;
!
! PREDICATE: word compound
!     dup word-primitive 1 = swap infix-word? not and ;

: (watch-after) ( word def -- def )
    [ % "<== " , \ write , word-name , \ print , \ .s , ] make-list ;

: watch-after ( word -- )
    [ (watch-after) ] annotate ;

: watch-all ( word -- )
    dup watch watch-after ;



MATH: quadratic[a;b;c] =
    plusmin[(-b)/2*a;(sqrt(b^2)-4*a*c)/2*a] ;
