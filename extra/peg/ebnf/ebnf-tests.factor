! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel tools.test peg peg.ebnf words ;
IN: peg.ebnf.tests

{ T{ ebnf-non-terminal f "abc" } } [
  "abc" 'non-terminal' parse parse-result-ast 
] unit-test

{ T{ ebnf-terminal f "55" } } [
  "'55'" 'terminal' parse parse-result-ast 
] unit-test

{
  T{ ebnf-rule f 
     "digit"
     T{ ebnf-choice f
        V{ T{ ebnf-terminal f "1" } T{ ebnf-terminal f "2" } }
     }
  } 
} [
  "digit = '1' | '2'" 'rule' parse parse-result-ast
] unit-test

{
  T{ ebnf-rule f 
     "digit" 
     T{ ebnf-sequence f
        V{ T{ ebnf-terminal f "1" } T{ ebnf-terminal f "2" } }
     }
  }   
} [
  "digit = '1' '2'" 'rule' parse parse-result-ast
] unit-test

{
  T{ ebnf-choice f
     V{ 
       T{ ebnf-sequence f
          V{ T{ ebnf-non-terminal f "one" } T{ ebnf-non-terminal f "two" } }
       }
       T{ ebnf-non-terminal f "three" }
     }
  } 
} [
  "one two | three" 'choice' parse parse-result-ast
] unit-test

{
  T{ ebnf-sequence f
     V{ 
       T{ ebnf-non-terminal f "one" }
       T{ ebnf-choice f
          V{ T{ ebnf-non-terminal f "two" } T{ ebnf-non-terminal f "three" } }
       }
     }
  } 
} [
  "one (two | three)" 'choice' parse parse-result-ast
] unit-test

{
  T{ ebnf-sequence f
     V{ 
       T{ ebnf-non-terminal f "one" }
       T{ ebnf-repeat0 f
          T{ ebnf-sequence f
             V{
                T{ ebnf-choice f
                   V{ T{ ebnf-non-terminal f "two" } T{ ebnf-non-terminal f "three" } }
                }
                T{ ebnf-non-terminal f "four" }
             }
          }
        }
     }
  } 
} [
  "one ((two | three) four)*" 'choice' parse parse-result-ast
] unit-test

{
  T{ ebnf-sequence f
     V{ 
         T{ ebnf-non-terminal f "one" } 
         T{ ebnf-optional f T{ ebnf-non-terminal f "two" } }
         T{ ebnf-non-terminal f "three" }
     }
  } 
} [
  "one ( two )? three" 'choice' parse parse-result-ast
] unit-test

{ "foo" } [
  "\"foo\"" 'identifier' parse parse-result-ast
] unit-test

{ "foo" } [
  "'foo'" 'identifier' parse parse-result-ast
] unit-test

{ "foo" } [
  "foo" 'non-terminal' parse parse-result-ast ebnf-non-terminal-symbol
] unit-test

{ "foo" } [
  "foo]" 'non-terminal' parse parse-result-ast ebnf-non-terminal-symbol
] unit-test

{ V{ "a" "b" } } [
  "ab" [EBNF foo='a' 'b' EBNF] call parse-result-ast 
] unit-test

{ V{ 1 "b" } } [
  "ab" [EBNF foo=('a')[[ drop 1 ]] 'b' EBNF] call parse-result-ast 
] unit-test

{ V{ 1 2 } } [
  "ab" [EBNF foo=('a') [[ drop 1 ]] ('b') [[ drop 2 ]] EBNF] call parse-result-ast 
] unit-test

{ CHAR: A } [
  "A" [EBNF foo=[A-Z] EBNF] call parse-result-ast 
] unit-test

{ CHAR: Z } [
  "Z" [EBNF foo=[A-Z] EBNF] call parse-result-ast 
] unit-test

{ f } [
  "0" [EBNF foo=[A-Z] EBNF] call  
] unit-test

{ CHAR: 0 } [
  "0" [EBNF foo=[^A-Z] EBNF] call parse-result-ast 
] unit-test

{ f } [
  "A" [EBNF foo=[^A-Z] EBNF] call  
] unit-test

{ f } [
  "Z" [EBNF foo=[^A-Z] EBNF] call  
] unit-test

[ 
  #! Test direct left recursion. Currently left recursion should cause a
  #! failure of that parser.
  #! Not using packrat, so recursion causes data stack overflow  
  "1+1" [EBNF num=([0-9])+ expr=expr "+" num | num EBNF] call
] must-fail

{ V{ 49 } } [ 
  #! Test direct left recursion. Currently left recursion should cause a
  #! failure of that parser.
  #! Using packrat, so first part of expr fails, causing 2nd choice to be used  
  "1+1" [ [EBNF num=([0-9])+ expr=expr "+" num | num EBNF] call ] with-packrat parse-result-ast
] unit-test

[ 
  #! Test indirect left recursion. Currently left recursion should cause a
  #! failure of that parser.
  #! Not using packrat, so recursion causes data stack overflow  
  "1+1" [EBNF num=([0-9])+ x=expr expr=x "+" num | num EBNF] call
] must-fail

{ V{ 49 } } [ 
  #! Test indirect left recursion. Currently left recursion should cause a
  #! failure of that parser.
  #! Using packrat, so first part of expr fails, causing 2nd choice to be used  
  "1+1" [ [EBNF num=([0-9])+ x=expr expr=x "+" num | num EBNF] call ] with-packrat parse-result-ast
] unit-test
