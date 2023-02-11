! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: kernel math math.constants math.functions sequences sets
sets.extras ;

IN: math.unicode
CONSTANT: ½ 1/2
CONSTANT: ¼ 1/4
CONSTANT: ¾ 3/4
CONSTANT: ⅓ 1/3
CONSTANT: ⅔ 2/3
CONSTANT: ⅕ 1/5
CONSTANT: ⅖ 2/5
CONSTANT: ⅗ 3/5
CONSTANT: ⅘ 4/5
CONSTANT: ⅙ 1/6
CONSTANT: ⅚ 5/6
CONSTANT: ⅛ 1/8
CONSTANT: ⅜ 3/8
CONSTANT: ⅝ 5/8
CONSTANT: ⅞ 7/8

ALIAS: ≤ <=
ALIAS: ≥ >=

: ≠ ( obj1 obj2 -- ? ) = not ; inline

! Please don't use these
ALIAS: − -
ALIAS: ÷ /
ALIAS: ∕ /
ALIAS: × *

ALIAS: ⁿ ^
: ¹ ( m -- n ) ; inline
: ² ( m -- n ) 2 ⁿ ; inline
: ³ ( m -- n ) 3 ⁿ ; inline
ALIAS: √ sqrt
: ∛ ( x -- y ) ⅓ ⁿ ; inline
: ∜ ( x -- y ) ¼ ⁿ ; inline

ALIAS: ⌈ ceiling
ALIAS: ⌊ floor

ALIAS: π pi

MEMO: φ ( -- n ) 5 √ 1 + 2 / ;
CONSTANT: ∞ 1/0.

ALIAS: Π product
ALIAS: Σ sum

: ‰ ( m -- n ) 1000 / ; inline
: ‱ ( m -- n ) 10000 / ; inline

ALIAS: ¬ not
ALIAS: ∧ and
ALIAS: ∨ or
: ⊽ ( obj1 obj2 -- ? ) ∨ ¬ ; inline
: ⊼ ( obj1 obj2 -- ? ) ∧ ¬ ; inline
ALIAS: ∀ all?
ALIAS: ∃ any?
ALIAS: ∄ none?

ALIAS: ∩ intersect
ALIAS: ∪ union
: ∋ ( seq elt -- ? ) swap member? ; inline
ALIAS: ∈ member?
: ∉ ( elt seq -- y ) ∈ not ; inline
: ∌ ( seq elt -- y ) ∋ not ; inline
ALIAS: ∖ diff
ALIAS: ⊂ subset?
ALIAS: ⊃ superset?
: ⊄ ( set1 set2 -- ? ) ⊂ not ; inline
: ⊅ ( set1 set2 -- ? ) ⊃ not ; inline
