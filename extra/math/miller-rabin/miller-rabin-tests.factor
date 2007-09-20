USING: math.miller-rabin kernel math namespaces tools.test ;

[ f ] [ 473155932665450549999756893736999469773678960651272093993257221235459777950185377130233556540099119926369437865330559863 miller-rabin ] unit-test
[ t ] [ 2 miller-rabin ] unit-test
[ t ] [ 3 miller-rabin ] unit-test
[ f ] [ 36 miller-rabin ] unit-test
[ t ] [ 37 miller-rabin ] unit-test
[ 101 ] [ 100 next-prime ] unit-test
[ 100000000000031 ] [ 100000000000000 next-prime ] unit-test

