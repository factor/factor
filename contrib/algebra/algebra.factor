IN: algebra USING: lists math kernel words namespaces ;

GENERIC: (fold-consts) ( infix -- infix ? )

M: number (fold-consts)
    f ;
M: var (fold-consts)
    t ;
M: list2 (fold-consts)
    2unlist (fold-consts) [
        2list t
    ] [
        swap arith-1 word-property unit call f
    ] ifte ;
M: list3 (fold-consts)
    3unlist >r (fold-consts) r> swapd (fold-consts) >r rot r> or [
        3list t
    ] [
        rot arith-2 word-property unit call f
    ] ifte ;

: fold-consts ( infix -- infix )
    #! Given a mathematical s-expression, perform constant folding,
    #! which is doing all the calculations it can do without any
    #! variables added.
    (fold-consts) drop ;


VARIABLE: modularity
    #! This is the variable that stores what mod we're in


GENERIC: (install-mod) ( infix -- infix-with-mod )

: put-mod ( object -- [ mod object modularity ] )
    [ \ mod , , modularity , ] make-list ;

M: num/vc (install-mod)
    put-mod ;

M: list2 (install-mod)
    2unlist (install-mod) 2list put-mod ;

M: list3 (install-mod)
    3unlist (install-mod) swap (install-mod) swap 3list put-mod ;

: install-mod ( arglist infix -- new-arglist infix-with-mod)
    #! Given an argument list and an infix expression, produce
    #! a new arglist and a new infix expression that will evaluate
    #! the given one using modular arithmetic.
    >r modularity swons r> (install-mod) ;

:| quadratic-formula a b c |:
    [ [ - b ] / 2 * a ] +- [ sqrt [ sq b ] - 4 * a * c ] / 2 * a ;

