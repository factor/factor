USING: kernel math.primes.miller-rabin sequences tools.test ;
IN: math.primes.miller-rabin.tests

[ f ] [ 473155932665450549999756893736999469773678960651272093993257221235459777950185377130233556540099119926369437865330559863 miller-rabin ] unit-test
[ t ] [ 2 miller-rabin ] unit-test
[ t ] [ 3 miller-rabin ] unit-test
[ f ] [ 36 miller-rabin ] unit-test
[ t ] [ 37 miller-rabin ] unit-test
[ t ] [ 2135623355842621559 miller-rabin ] unit-test

[ f ] [ 1000 [ drop 15 miller-rabin ] any? ] unit-test
