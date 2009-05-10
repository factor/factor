USING: math.miller-rabin tools.test kernel sequences
math.miller-rabin.private math ;
IN: math.miller-rabin.tests

[ f ] [ 473155932665450549999756893736999469773678960651272093993257221235459777950185377130233556540099119926369437865330559863 miller-rabin ] unit-test
[ t ] [ 2 miller-rabin ] unit-test
[ t ] [ 3 miller-rabin ] unit-test
[ f ] [ 36 miller-rabin ] unit-test
[ t ] [ 37 miller-rabin ] unit-test
[ 2 ] [ 1 next-prime ] unit-test
[ 3 ] [ 2 next-prime ] unit-test
[ 5 ] [ 3 next-prime ] unit-test
[ 101 ] [ 100 next-prime ] unit-test
[ t ] [ 2135623355842621559 miller-rabin ] unit-test
[ 100000000000031 ] [ 100000000000000 next-prime ] unit-test

[ 863 ] [ 862 next-safe-prime ] unit-test
[ f ] [ 862 safe-prime? ] unit-test
[ t ] [ 7 safe-prime? ] unit-test
[ f ] [ 31 safe-prime? ] unit-test
[ t ] [ 47 safe-prime-candidate? ] unit-test
[ t ] [ 47 safe-prime? ] unit-test
[ t ] [ 863 safe-prime? ] unit-test

[ f ] [ 1000 [ drop 15 miller-rabin ] any? ] unit-test

[ 47 ] [ 31 next-safe-prime ] unit-test
[ 49 ] [ 50 random-prime log2 ] unit-test
[ 49 ] [ 50 random-bits* log2 ] unit-test
