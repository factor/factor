! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel tools.test peg peg.ebnf compiler.units ;
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
  "foo='a' 'b'" ebnf>quot with-compilation-unit "ab" foo parse parse-result-ast 
] unit-test

{ V{ 1 "b" } } [
  "foo=('a')[[ drop 1 ]] 'b'" ebnf>quot with-compilation-unit "ab" foo parse parse-result-ast 
] unit-test

{ V{ 1 2 } } [
  "foo=('a') [[ drop 1 ]] ('b') [[ drop 2 ]]" ebnf>quot with-compilation-unit "ab" foo parse parse-result-ast 
] unit-test