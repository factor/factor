USING: math.primes.factors tools.test ;

{ { 999983 999983 1000003 } } [ 999969000187000867 factors ] unit-test
{ { } } [ -5 factors ] unit-test
{ { { 999983 2 } { 1000003 1 } } } [ 999969000187000867 group-factors ] unit-test
{ { 999983 1000003 } } [ 999969000187000867 unique-factors ] unit-test
{ 999967000236000612 } [ 999969000187000867 totient ] unit-test
{ 0 } [ 1 totient ] unit-test
{ { 425612003 } } [ 425612003 factors ] unit-test
{ { 13 4253 15823 32472893749823741 } } [ 28408516453955558205925627 factors ] unit-test
