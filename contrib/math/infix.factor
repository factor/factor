IN: infix
USING: arrays errors generic hashtables io kernel kernel-internals lists math math-contrib namespaces parser parser-combinators prettyprint sequences strings vectors words ;

: 2list ( x y -- [ x y ] ) f cons cons ;

! Tokenizer

TUPLE: tok char ;

TUPLE: brackets seq ender ;

SYMBOL: apostrophe

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
    [ "0123456789." member? not ] take-until string>number ;

: get-token ( -- char )
    spot get code get nth ;

DEFER: token

: next-token ( list -- list )
    #! Take one token from code and return it
    parse-blank not-done? [
         get-token token
    ] when ;

: token
    {
        { [ dup letter? ] [ drop parse-var swons ] }
        { [ dup "0123456789." member? ] [ drop parse-num swons ] }
        { [ dup ";!@#$%^&*?/|\\=+_-~" member? ] [ <tok> swons incr-spot ] }
        { [ dup "([{" member? ] [ drop f incr-spot ] }
        { [ dup ")]}" member? ] [ <brackets> swons incr-spot ] }
        { [ dup CHAR: ' = ] [ drop apostrophe swons incr-spot ] }
        { [ t ] [ "Bad character " swap ch>string append throw ] }
    } cond next-token ;

: tokenize ( string -- tokens )
    #! Tokenize a string, returning a list of tokens
    [
        code set 0 spot set
        f next-token reverse
    ] with-scope ;


! Parser

TUPLE: apply func args ;
    #! Function application
C: apply
     >r [ ] subset r> 
    [ set-apply-args ] keep
    [ set-apply-func ] keep ;

UNION: value number string ;

: semicolon ( -- semicolon )
    #! The semicolon token
    T{ tok f CHAR: ; } ;

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

M: brackets parse-token
    swapd dup brackets-seq swap brackets-ender {
        { [ dup CHAR: ] = ] [ drop semicolon-split >r unswons r> <apply> swons ] }
        { [ dup CHAR: } = ] [ drop semicolon-split >vector swons ] }
        { [ CHAR: ) = ] [ reverse parse-tokens swons ] }
    } cond swap ;

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

: null-op ( ast tokens token -- ast )
    nip tok-char ch>string swons ;

M: tok parse-token
    over [
        pick [
            binary-op
        ] [
            unary-op
        ] if
    ] [
        null-op
    ] if f ;

( ast tokens token -- ast tokens )

M: symbol parse-token ! apostrophe 
    drop unswons >r parse-tokens >r unswons r> 2list r>
    unit parse-tokens swap <apply> swons f ;

: (parse-tokens) ( ast tokens -- ast )
    dup [
        unswons parse-token (parse-tokens)
    ] [
        drop
    ] if ;

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
    ] if ;

: replace-with ( data -- [ drop data ] )
    \ drop swap 2list ;

UNION: comp-literal number general-list ;

M: comp-literal compile-ast ! literal numbers
    replace-with nip ;

: accumulator ( vars { asts } quot -- quot )
    -rot [
        [
            \ dup ,
            compile-ast %
            dup %
        ] each-with
    ] [ ] make nip ;

M: vector compile-ast ! literal vectors
    dup [ number? ] all? [
        replace-with nip
    ] [
        [ , ] accumulator [ { } make nip ] cons
    ] if ;

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
    ] if ;

: functions
    #! Regular functions
    #! Gives quotation applicable to stack
    H{
        [ [[ "+" 2 ]] + ]
        [ [[ "-" 2 ]] - ]
        [ [[ ">" 2 ]] [ > ] infix-relation ]
        [ [[ "<" 2 ]] [ < ] infix-relation ]
        [ [[ "=" 2 ]] [ = ] infix-relation ]
        [ [[ "-" 1 ]] neg ]
        [ [[ "~" 1 ]] not ]
        [ [[ "&" 2 ]] and ]
        [ [[ "|" 2 ]] or ]
        [ [[ "&" 1 ]] t [ and ] reduce ]
        [ [[ "|" 1 ]] f [ or ] reduce ]
        [ [[ "*" 2 ]] * ]
        [ [[ "ln" 1 ]] log ]
        [ [[ "plusmin" 2 ]] [ + ] 2keep - ]
        [ [[ "@" 2 ]] swap nth ]
        [ [[ "sqrt" 1 ]] sqrt ]
        [ [[ "/" 2 ]] / ]
        [ [[ "^" 2 ]] ^ ]
        [ [[ "#" 1 ]] length ]
        [ [[ "eq" 2 ]] eq? ]
        [ [[ "*" 1 ]] first ]
        [ [[ "+" 1 ]] flip ]
        [ [[ "\\" 1 ]] <reversed> ]
        [ [[ "sin" 1 ]] sin ]
        [ [[ "cos" 1 ]] cos ]
        [ [[ "tan" 1 ]] tan ]
        [ [[ "max" 2 ]] max ]
        [ [[ "min" 2 ]] min ]
        [ [[ "," 2 ]] append ]
        [ [[ "," 1 ]] concat ]
        [ [[ "sn" 3 ]] -rot set-nth ]
        [ [[ "prod" 1 ]] product ]
        [ [[ "vec" 1 ]] >vector ]
    } ;

: drc ( list -- list )
    #! all of list except last element (backwards cdr)
    dup cdr [
        uncons drc cons
    ] [
        drop f
    ] if ;

: map-with-left ( seq object quot -- seq )
    [ swapd call ] cons swapd map-with ; inline

: high-functions
    #! Higher-order functions
    #! Gives quotation applicable to quotation and rest of stack
    H{
        [ [[ "!" 2 ]] 2map ]
        [ [[ "!" 1 ]] map ]
        [ [[ ">" 2 ]] map-with ]
        [ [[ "<" 2 ]] map-with-left ]
        [ [[ "^" 1 ]] all? ]
        [ [[ "~" 1 ]] call not ]
        [ [[ "~" 2 ]] call not ]
        [ [[ "/" 2 ]] swapd reduce ]
        [ [[ "\\" 2 ]] swapd accumulate ]
    } ;

: get-hash ( key table -- value )
    #! like hash but throws exception if f
    dupd hash [ nip ] [
        [ "Key not found " write . ] string-out throw
    ] if* ;

: >apply< ( apply -- func args )
    dup apply-func swap apply-args ;

: make-apply ( arity apply/string -- quot )
    dup string? [
        swons functions get-hash
    ] [
        >apply< car >r over r> make-apply
        -rot swons high-functions get-hash cons
    ] if ;

: get-function ( apply -- quot )
    >apply< length swap make-apply ;

M: apply compile-ast ! function application
    [ apply-args [ swap ] accumulator [ drop ] append ] keep
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
    ] [ ] make ;

: ast>quot ( args ast -- quot )
    over prologue -rot compile-ast append ;

: define-math ( seq -- )
    " " join
    dup parse-full apply-args uncons car swap
    >apply< >r create-in r>
    [ "math-args" set-word-prop ] 2keep
    >r tuck >r >r swap "code" set-word-prop r> r> r>
    rot ast>quot define-compound ;

: MATH:
    #! MATH: sq[x]=x*x ;
    "in-definition" on
    string-mode on 
    [
        string-mode off define-math
    ] f ; parsing

: TEST-MATH:
    #! Executes and prints the result of a math
    #! expression at parsetime
    string-mode on [
        " " join string-mode off parse-full
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



MATH: quadratic[a;b;c] =
    plusmin[(-b)/2*a;(sqrt(b^2)-4*a*c)/2*a] ;
