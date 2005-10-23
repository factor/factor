IN: analysis-internals
USING: kernel sequences errors namespaces math ;

: Z:(-inf,0]? ( n -- bool )
    #! nonpositive integer
    dup 0 <= [ integer? ] [ drop f ] if ;

! http://www.rskey.org/gamma.htm  "Lanczos Approximation"
! n=6: error ~ 3 x 10^-11

: gamma-g6 5.15 ; inline

: gamma-p6
    {
        2.50662827563479526904 225.525584619175212544 -268.295973841304927459
        80.9030806934622512966 -5.00757863970517583837 0.0114684895434781459556 
    } ; inline

: gamma-z ( x n -- seq )
    [ [ over + 1.0 swap / , ] each ] { } make 1.0 0 pick set-nth nip ;

: (gamma-lanczos6) ( x -- log[gamma[x+1]] )
    #! log(gamma(x+1)
    dup 0.5 + dup gamma-g6 + dup >r log * r> -
    swap 6 gamma-z gamma-p6 v. log + ;

: gamma-lanczos6 ( x -- gamma[x] )
    #! gamma(x) = gamma(x+1) / x
    dup (gamma-lanczos6) exp swap / ;

: gammaln-lanczos6 ( x -- gammaln[x] )
    #! log(gamma(x)) = log(gamma(x+1)) - log(x)
    dup (gamma-lanczos6) swap log - ;

: gamma-neg ( gamma[abs[x]] x -- gamma[x] )
    dup pi * sin * * pi neg swap / ; inline

IN: math-contrib

: gamma ( x -- gamma[x] )
    #! gamma(x) = integral 0..inf [ t^(x-1) exp(-t) ] dt
    #! gamma(n+1) = n! for n > 0
    dup Z:(-inf,0]? [
            drop inf
        ] [
            dup abs gamma-lanczos6 swap dup 0 > [ drop ] [ gamma-neg ] if
    ] if ;

: gammaln ( x -- gamma[x] )
    #! gammaln(x) is an alternative when gamma(x)'s range
    #! varies too widely
    dup 0 < [
            drop inf
        ] [
            dup abs gammaln-lanczos6 swap dup 0 > [ drop ] [ gamma-neg ] if
    ] if ;

