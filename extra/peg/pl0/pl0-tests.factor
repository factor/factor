! Copyright (C) 2007 Chris Double.
! See https://factorcode.org/license.txt for BSD license.

USING: kernel tools.test peg peg.ebnf peg.ebnf.private peg.pl0
sequences accessors ;

{ t } [
  "CONST foo = 1;" "block" \ pl0 rule (parse) remaining>> empty?
] unit-test

{ t } [
  "VAR foo;" "block" \ pl0 rule (parse) remaining>> empty?
] unit-test

{ t } [
  "VAR foo,bar , baz;" "block" \ pl0 rule (parse) remaining>> empty?
] unit-test

{ t } [
  "foo := 5" "statement" \ pl0 rule (parse) remaining>> empty?
] unit-test

{ t } [
  "BEGIN foo := 5 END" "statement" \ pl0 rule (parse) remaining>> empty?
] unit-test

{ t } [
  "IF 1=1 THEN foo := 5" "statement" \ pl0 rule (parse) remaining>> empty?
] unit-test

{ t } [
  "WHILE 1=1 DO foo := 5" "statement" \ pl0 rule (parse) remaining>> empty?
] unit-test

{ t } [
  "WHILE ODD 1 DO foo := 5" "statement" \ pl0 rule (parse) remaining>> empty?
] unit-test

{ t } [
  "PROCEDURE square; BEGIN squ:=x*x END" "block" \ pl0 rule (parse) remaining>> empty?
] unit-test

{ t } [
"VAR x, squ;

PROCEDURE square;
BEGIN
   squ := x * x
END;

BEGIN
   x := 1;
   WHILE x <= 10 DO
   BEGIN
      CALL square;
      x := x + 1;
   END
END." main \ pl0 rule (parse) remaining>> empty?
] unit-test

{ f } [
" 
CONST
  m =  7,
  n = 85;

VAR
  x, y, z, q, r;

PROCEDURE multiply;
VAR a, b;

BEGIN
  a := x;
  b := y;
  z := 0;
  WHILE b > 0 DO BEGIN
    IF ODD b THEN z := z + a;
    a := 2 * a;
    b := b / 2;
  END
END;

PROCEDURE divide;
VAR w;
BEGIN
  r := x;
  q := 0;
  w := y;
  WHILE w <= r DO w := 2 * w;
  WHILE w > y DO BEGIN
    q := 2 * q;
    w := w / 2;
    IF w <= r THEN BEGIN
      r := r - w;
      q := q + 1
    END
  END
END;

PROCEDURE gcd;
VAR f, g;
BEGIN
  f := x;
  g := y;
  WHILE f # g DO BEGIN
    IF f < g THEN g := g - f;
    IF g < f THEN f := f - g;
  END;
  z := f
END;

BEGIN
  x := m;
  y := n;
  CALL multiply;
  x := 25;
  y :=  3;
  CALL divide;
  x := 84;
  y := 36;
  CALL gcd;
END.
" main \ pl0 rule (parse) remaining>> empty?
] unit-test
