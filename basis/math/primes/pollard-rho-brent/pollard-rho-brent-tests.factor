! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: math.primes.pollard-rho-brent sorting tools.test ;
IN: math.primes.pollard-rho-brent.tests

{ { 2 2 2507191691 1231026625769 } } [ 12345678910111213141516 pollard-rho-brent-factors ] unit-test
{ { 2 2 2 2 3 257 7221391 696389341 } } [ 62036506940903331216 pollard-rho-brent-factors ] unit-test
{ { 13 4253 15823 32472893749823741 } } [ 28408516453955558205925627 pollard-rho-brent-factors ] unit-test

! Fermat number, F8
! Takes about 5s, too slow for unit tests imo
! {
!     { 93461639715357977769163558199606896584051237541638188580280321 1238926361552897 }
! } [
!     93461639715357977769163558199606896584051237541638188580280321 1238926361552897 * pollard-rho-brent-factors
! ] unit-test

