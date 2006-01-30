USING: kernel math errors namespaces math-contrib sequences io ;
USE: prettyprint
USE: inspector
IN: crypto

SYMBOL: a
SYMBOL: n
SYMBOL: r
SYMBOL: s
SYMBOL: composite
SYMBOL: count
SYMBOL: trials

: rand[1..n-1] ( n -- )
    1- random-int 1+ ;

: (factor-2s) ( s n -- s n )
    dup 2 mod 0 = [ -1 shift >r 1+ r> (factor-2s) ] when ;

: factor-2s ( n -- r s )
    #! factor an even number into 2 ^ s * m
    dup dup even? >r 0 > r> and [
        "input must be positive and even" throw
    ] unless 0 swap (factor-2s) ;

: init-miller-rabin ( n -- )
    0 composite set
    [ n set ] keep 10000 < 20 100 ? trials set ;

: miller-rabin ( n -- bool )
    [
        init-miller-rabin
        n get even? [
            f ] [
            n get 1- factor-2s s set r set
            trials get [
                n get rand[1..n-1] a set
                a get s get n get ^mod 1 = [
                    0 count set
                    r get [
                        2 over ^ s get * a get swap n get ^mod n get - -1 = [
                            count [ 1+ ] change
                            r get +
                        ] when
                    ] repeat
                    count get zero? [
                        composite on
                        trials get +
                    ] when
                ] unless
            ] repeat
            composite get 0 = [ t ] [ composite get not ] if
        ] if
    ] with-scope ;

: next-miller-rabin-prime ( n -- p )
    dup even? [ 1+ ] [ 2 + ] if
    dup miller-rabin [ next-miller-rabin-prime ] unless ;


! 473155932665450549999756893736999469773678960651272093993257221235459777950185377130233556540099119926369437865330559863 100 miller-rabin
