! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel tools.test peg peg.pl0 multiline sequences words assocs ;
IN: peg.pl0.tests

{ f } [
  "CONST foo = 1;" \ pl0 "ebnf-parser" word-prop "block" swap at parse not 
] unit-test

{ f } [
  "VAR foo;" \ pl0 "ebnf-parser" word-prop "block" swap at parse not 
] unit-test

{ f } [
  "VAR foo,bar , baz;" \ pl0 "ebnf-parser" word-prop "block" swap at parse not 
] unit-test

{ f } [
  "foo := 5;" \ pl0 "ebnf-parser" word-prop "statement" swap at parse not 
] unit-test

{ f } [
  "BEGIN foo := 5; END" \ pl0 "ebnf-parser" word-prop "statement" swap at parse not 
] unit-test

{ f } [
  "IF 1=1 THEN foo := 5; END" \ pl0 "ebnf-parser" word-prop "statement" swap at parse not 
] unit-test

{ f } [
  "WHILE 1=1 DO foo := 5; END" \ pl0 "ebnf-parser" word-prop "statement" swap at parse not 
] unit-test

{ f } [
  "WHILE ODD 1=1 DO foo := 5; END" \ pl0 "ebnf-parser" word-prop "statement" swap at parse not 
] unit-test

{ f } [
  "PROCEDURE square; BEGIN squ=x*x END" \ pl0 "ebnf-parser" word-prop "block" swap at parse not 
] unit-test

{ f } [
  <"
PROCEDURE square; 
BEGIN 
  squ := x * x 
END;
"> \ pl0 "ebnf-parser" word-prop "block" swap at parse not 
] unit-test

{ t } [
  <"
VAR x, squ;

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
END.
"> pl0 parse-result-remaining empty?
] unit-test

{ f } [
  <"
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
  "> pl0 parse-result-remaining empty?
] unit-test