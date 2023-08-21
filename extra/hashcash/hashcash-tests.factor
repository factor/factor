! Copyright (C) 2023 Zoltán Kéri.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar hashcash hashcash.private kernel
literals namespaces sequences splitting tools.test ;
IN: hashcash.tests

: generate-stamp ( -- stamp ) "foo@bar.com" mint ;

! Generate the stamp iff it does not exist.
! You can delete it with `generated-stamp global delete-at`.
INITIALIZED-SYMBOL: generated-stamp [ generate-stamp ]

! Generate the stamp iff it is set to `f`.
! You can change it to `f` with `f generated-stamp set-global`.
generated-stamp get f eq? [ generate-stamp generated-stamp set ] when

{ t } [
    generated-stamp get dup ":" split third valid-date? swap drop
] unit-test

{ f } [
    [ -1 expiry-days set
      generated-stamp get valid-stamp?
    ] with-scope
] unit-test

{ t } [
    [ 0 expiry-days set
      generated-stamp get valid-stamp?
    ] with-scope
] unit-test

{ t } [ generated-stamp get valid-stamp? ] unit-test

{ t } [
    <hashcash> "foo@bar.com" >>resource 16 >>bits
    mint* valid-stamp?
] unit-test

{ t } [
    [ 9999 expiry-days set
      "1:20:220403:foo@bar.com::fAY*-p!s:23472" valid-stamp?
    ] with-scope
] unit-test

{ f } [
    [ -1 expiry-days set
      now-gmt-yymmdd valid-date?
    ] with-scope
] unit-test

{ t } [
    [ 0 expiry-days set
      now-gmt-yymmdd valid-date?
    ] with-scope
] unit-test

{ t } [ now-gmt-yymmdd valid-date? ] unit-test

{  30 } [ "220131" "220101" yymmdd-gmt-diff ] unit-test
{ -30 } [ "220101" "220131" yymmdd-gmt-diff ] unit-test

{ t } [
    now-gmt 1 days time- timestamp>yymmdd on-or-before-today? nip
] unit-test

{ t } [
    now-gmt timestamp>yymmdd on-or-before-today? nip
] unit-test

{ f } [
    now-gmt 1 days time+ timestamp>yymmdd on-or-before-today? nip
] unit-test
