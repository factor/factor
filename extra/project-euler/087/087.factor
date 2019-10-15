USING: locals math math.primes sequences math.functions sets kernel ;
IN: project-euler.087

<PRIVATE

: remove-duplicates ( seq -- seq' )
    dup intersect ;

:: prime-powers-less-than ( primes pow n -- prime-powers )
    primes [ pow ^ ] map [ n <= ] filter ;

! You may think to make a set of all possible sums of a prime square and cube 
! and then subtract prime fourths from numbers ranging from 1 to 'n' to find 
! this. As n grows large, this is actually more inefficient!
! Prime numbers grow ~ n / log n
! Thus there are (n / log n)^(1/2) prime squares <= n,
!                (n / log n)^(1/3) prime cubes   <= n,
!            and (n / log n)^(1/4) prime fourths <= n.
! If we compute the cartesian product of these, this takes 
! O((n / log n)^(13/12)).
! If we instead precompute sums of squares and cubes, and iterate up to n,
! checking each fourth power against it, this takes
! O(n * (n / log n)^(1/4)) = O(n^(5/4)/(log n)^(1/4)) >> O((n / log n)^(13/12))
!
! When n = 50000000, the first equation is approximately 10 million and 
! the second is approximately 2 billion.

:: prime-triples ( n -- answer )
    n sqrt primes-upto                :> primes
    primes 2 n prime-powers-less-than :> primes^2
    primes 3 n prime-powers-less-than :> primes^3
    primes 4 n prime-powers-less-than :> primes^4
    primes^2 primes^3 [ + ] cartesian-map concat
             primes^4 [ + ] cartesian-map concat
    [ n <= ] filter remove-duplicates length ;

PRIVATE>

:: euler087 ( -- answer )
    50000000 prime-triples ;
