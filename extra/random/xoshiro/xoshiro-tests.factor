! Copyright (C) 2018 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math random.xoshiro tools.test ;
IN: random.xoshiro.tests

{
  2 3 131074 70368744177664
  5760
} [
  0 1 2 3
  (next-256)
] unit-test

{
  4046638647718970624
  2015137892536077249
  6184416992699500823
  16308606917844226410
} [
  0 1 2 3
  10,000 [
    (next-256) drop
  ] times
] unit-test

{
  14662298501051415801
  12883398035623381500
  17052052954271276209
  1546841944388125985
} [ 0 1 2 3 jump-256 ] unit-test

{
  15716266295256758020
  17232205271518152816
  9857397594961175947
  8327361040835137714
} [ 0 1 2 3 long-jump-256 ] unit-test

