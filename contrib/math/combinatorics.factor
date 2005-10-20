USING: kernel sequences errors namespaces ;
USING: test ;
IN: math

: (0..n] ( n -- (0..n] ) 1+ 1 swap <range> ; inline
: [1..n] ( n -- [1..n] ) (0..n] ; inline
: [k..n] ( k n -- [k..n] ) 1+ <range> ; inline
: (k..n] ( k n -- (k..n] ) [ 1+ ] 2apply <range> ; inline

: Z:(-inf,0]? ( n -- bool )
    #! nonpositive integer
    dup 0 <= [ integer? ] [ drop f ] if ;

: factorial ( n -- n! ) (0..n] product ;

: factorial-part ( k! k n -- n! )
    #! calculate n! given n, k, k!
    (k..n] product * ;


: nCk ( n k -- nCk )
    #! uses the results from min(k!,(n-k)!) to compute max(k!,(n-k)!)
    #! use max(k!,(n-k)!) to compute n!
    2dup < [ "n >= k only" throw ] when
    [ - ] 2keep rot 2dup < [ swap ] when
    [ factorial ] keep over
    >r rot [ factorial-part ] keep rot pick >r factorial-part r> r> * / ;

: nPk ( n k -- nPk )
    #! uses the results from (n-k)! to compute n!
    2dup < [ "n >= k only" throw ] when
    2dup - nip [ factorial ] keep rot pick >r factorial-part r> / ;

: binomial ( n k -- nCk )
    #! same as nCk
    nCk ;

