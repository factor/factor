IN: algebra
USING: kernel lists math namespaces test stdio words parser
    generic errors prettyprint vectors kernel-internals ;

SYMBOL: variable?
    #! For word props: will this be a var in an infix expression?
PREDICATE: word var
    #! Class of variables
    variable? word-property ;
SYMBOL: constant?
    #! Word prop for things like pi and e
PREDICATE: word con
    constant? word-property ;

PREDICATE: cons single
    #! Single-element list
    cdr not ;
UNION: num/vc number var con ;
PREDICATE: cons list-word
    #! List where first element is a word but not a variable
    unswons tuck word? and [ var? not ] [ drop f ] ifte ;
PREDICATE: cons list-nvl
    #! List where first element is a number, variable, or list
    unswons dup num/vc? swap cons? or and ;
UNION: num/con number con ;

GENERIC: infix ( list -- list )
    #! Parse an infix expression. This is right associative
    #! and everything has equal precendence. The output is
    #! an s-expression. Operators can be unary or binary.
M: num/vc infix ;
M: single infix car infix ;
M: list-word infix
    uncons infix 2list ;
M: list-nvl infix
    unswons infix swap uncons infix swapd 3list ;


: ([
    #! Begin a literal infix expression
    [ ] ; parsing
: ])
    #! End a literal infix expression.
    reverse infix swons ; parsing

: VARIABLE:
    #! Make a variable, which acts like a symbol
    CREATE dup define-symbol t variable? set-word-property ; parsing
VARIABLE: x
VARIABLE: y
VARIABLE: z
VARIABLE: a
VARIABLE: b
VARIABLE: c

SYMBOL: arith-1
    #! Word prop for unary mathematical function
SYMBOL: arith-2
    #! Word prop for binary mathematical function

PREDICATE: cons list2
    #! List of 2 elements
    length 2 = ;
PREDICATE: cons list3
    #! List of 3 elements
    length 3 = ;


GENERIC: (eval-infix) ( varstuff infix -- quote )

M: num/con (eval-infix)
    nip unit \ drop swons ;

: (find) ( counter item list -- index )
    dup [
        2dup car = [ 2drop ] [ >r >r 1 + r> r> cdr (find) ] ifte
    ] [
        "Undefined variable in infix expression" throw
    ] ifte ;
: find ( list item -- index )
    0 -rot swap (find) ;
M: var (eval-infix)
    find [ swap array-nth ] cons ;

: swap-in-infix ( var fix1 fix2 -- [ fix1solved swap fix2solved ] )
    >r dupd (eval-infix) swap r> (eval-infix) \ swap swons append ;
M: list3 (eval-infix)
    unswons arith-2 word-property unit -rot 2unlist
    swap-in-infix \ dup swons swap append ;

M: list2 (eval-infix)
    2unlist swapd (eval-infix) swap arith-1 word-property unit append ;

: build-prefix ( num-of-vars -- quote )
    #! What needs to be placed in front of the eval-infix quote
    [ dup , \ <array> , dup [
        2dup - 1 - [ swap set-array-nth ] cons , \ keep , 
    ] repeat drop ] make-list ;

: eval-infix ( vars infix -- quote )
    #! Given a list of variables and an infix expression in s-expression
    #! form, build a quotation which takes as many arguments from the
    #! datastack as there are elements in the varnames list, builds
    #! it into a vector, and calculates the values of the expression with
    #! the values filled in.
    over length build-prefix -rot (eval-infix) append ;

DEFER: fold-consts
: (| f ; parsing
: | reverse f ; parsing
: |) reverse infix fold-consts eval-infix swons \ call swons ; parsing

: (fac) dup 0 = [ drop ] [ dup 1 - >r * r> (fac) ] ifte ;
: fac
    #! Factorial
    1 swap (fac) ;

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
! Wrapped operations
: new= [ = ] infix-relation ;
: new> [ > ] infix-relation ;
: new< [ < ] infix-relation ;
: new>= [ >= ] infix-relation ;
: new<= [ <= ] infix-relation ;

: +- ( a b -- a+b a-b )
    [ + ] 2keep - ;

! Install arithmetic operators into words
[ + - / * ^ and or xor mod +- min gcd max bitand polar> align shift /mod /i /f rect> bitor proj
  bitxor dot rem ] [
    dup arith-2 set-word-property
] each
[ [[ = new= ]] [[ > new> ]] [[ < new< ]] [[ >= new>= ]] [[ <= new<= ]] ] [
    uncons arith-2 set-word-property
] each
[ sqrt abs fac sq asin denominator rational? rad>deg exp recip sgn >rect acoth arg fixnum
  bitnot sinh acosec acosh acosech complex? ratio? number? >polar number= cis deg>rad >fixnum
  cot cos sec cosec tan imaginary coth asech atanh absq >float numerator acot acos atan asec
  cosh log bignum? conjugate asinh sin float? real? >bignum tanh sech ] [
    dup arith-1 set-word-property
] each
[ [[ - neg ]] ] [ uncons arith-1 set-word-property ] each
[ pi i e -i inf -inf pi/2 ] [ t constant? set-word-property ] each
