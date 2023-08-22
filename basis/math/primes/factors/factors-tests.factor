USING: math math.primes.factors sequences tools.test ;

{ { 999983 999983 1000003 } } [ 999969000187000867 factors ] unit-test
{ { } } [ -5 factors ] unit-test
{ { { 999983 2 } { 1000003 1 } } } [ 999969000187000867 group-factors ] unit-test
{ { 999983 1000003 } } [ 999969000187000867 unique-factors ] unit-test
{ 999967000236000612 } [ 999969000187000867 totient ] unit-test
{ 0 } [ 1 totient ] unit-test
{ { 425612003 } } [ 425612003 factors ] unit-test
{ { 13 4253 15823 32472893749823741 } } [ 28408516453955558205925627 factors ] unit-test
{ { 1 2 3 4 6 8 12 24 } } [ 24 divisors ] unit-test
{ 24 } [ 360 divisors length ] unit-test
{ { 1 } } [ 1 divisors ] unit-test


{ { 618970019642690137449562111 } } [
    618970019642690137449562111 factors ! 89 2^ 1 -, prime
] unit-test

{
    { 162259276829213363391578010288127 }
} [
    ! Mersenne Prime M107
    107 2^ 1 - factors
] unit-test

{
    { 2316528667279 8168603188573 }
} [
    18922803457956001611802867 factors
] unit-test

{ { 35742549198872617291353508656626642567 } } [
    35742549198872617291353508656626642567 factors ! bell number prime
] unit-test

! Too slow
! {
!     {
!         618970019642690137449562111
!         162259276829213363391578010288127
!         170141183460469231731687303715884105727
!     }
! } [
!     89 2^ 1 -
!     107 2^ 1 -
!     127 2^ 1 - * * factors
! ] unit-test

