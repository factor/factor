! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel tools.test peg peg.ebnf words math math.parser 
       sequences accessors ;
IN: peg.ebnf.tests

{ T{ ebnf-non-terminal f "abc" } } [
  "abc" 'non-terminal' parse ast>> 
] unit-test

{ T{ ebnf-terminal f "55" } } [
  "'55'" 'terminal' parse ast>> 
] unit-test

{
  T{ ebnf-rule f 
     "digit"
     T{ ebnf-choice f
        V{ T{ ebnf-terminal f "1" } T{ ebnf-terminal f "2" } }
     }
  } 
} [
  "digit = '1' | '2'" 'rule' parse ast>>
] unit-test

{
  T{ ebnf-rule f 
     "digit" 
     T{ ebnf-sequence f
        V{ T{ ebnf-terminal f "1" } T{ ebnf-terminal f "2" } }
     }
  }   
} [
  "digit = '1' '2'" 'rule' parse ast>>
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
  "one two | three" 'choice' parse ast>>
] unit-test

{
  T{ ebnf-sequence f
     V{ 
       T{ ebnf-non-terminal f "one" }
       T{ ebnf-whitespace f
         T{ ebnf-choice f
            V{ T{ ebnf-non-terminal f "two" } T{ ebnf-non-terminal f "three" } }
         }
       }
     }
  } 
} [
  "one {two | three}" 'choice' parse ast>>
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
  "one ((two | three) four)*" 'choice' parse ast>>
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
  "one ( two )? three" 'choice' parse ast>>
] unit-test

{ "foo" } [
  "\"foo\"" 'identifier' parse ast>>
] unit-test

{ "foo" } [
  "'foo'" 'identifier' parse ast>>
] unit-test

{ "foo" } [
  "foo" 'non-terminal' parse ast>> ebnf-non-terminal-symbol
] unit-test

{ "foo" } [
  "foo]" 'non-terminal' parse ast>> ebnf-non-terminal-symbol
] unit-test

{ V{ "a" "b" } } [
  "ab" [EBNF foo='a' 'b' EBNF] call ast>> 
] unit-test

{ V{ 1 "b" } } [
  "ab" [EBNF foo=('a')[[ drop 1 ]] 'b' EBNF] call ast>> 
] unit-test

{ V{ 1 2 } } [
  "ab" [EBNF foo=('a') [[ drop 1 ]] ('b') [[ drop 2 ]] EBNF] call ast>> 
] unit-test

{ CHAR: A } [
  "A" [EBNF foo=[A-Z] EBNF] call ast>> 
] unit-test

{ CHAR: Z } [
  "Z" [EBNF foo=[A-Z] EBNF] call ast>> 
] unit-test

{ f } [
  "0" [EBNF foo=[A-Z] EBNF] call  
] unit-test

{ CHAR: 0 } [
  "0" [EBNF foo=[^A-Z] EBNF] call ast>> 
] unit-test

{ f } [
  "A" [EBNF foo=[^A-Z] EBNF] call  
] unit-test

{ f } [
  "Z" [EBNF foo=[^A-Z] EBNF] call  
] unit-test

{ V{ "1" "+" "foo" } } [
  "1+1" [EBNF foo='1' '+' '1' [[ drop "foo" ]] EBNF] call ast>>
] unit-test

{ "foo" } [
  "1+1" [EBNF foo='1' '+' '1' => [[ drop "foo" ]] EBNF] call ast>>
] unit-test

{ "foo" } [
  "1+1" [EBNF foo='1' '+' '1' => [[ drop "foo" ]] | '1' '-' '1' => [[ drop "bar" ]] EBNF] call ast>>
] unit-test

{ "bar" } [
  "1-1" [EBNF foo='1' '+' '1' => [[ drop "foo" ]] | '1' '-' '1' => [[ drop "bar" ]] EBNF] call ast>>
] unit-test

{ 6 } [
  "4+2" [EBNF num=[0-9] => [[ digit> ]] foo=num:x '+' num:y => [[ drop x y + ]] EBNF] call ast>>
] unit-test

{ 6 } [
  "4+2" [EBNF foo=[0-9]:x '+' [0-9]:y => [[ drop x digit> y digit> + ]] EBNF] call ast>>
] unit-test

{ 10 } [
  { 1 2 3 4 } [EBNF num=. ?[ number? ]? list=list:x num:y => [[ drop x y + ]] | num EBNF] call ast>>
] unit-test

{ f } [
  { "a" 2 3 4 } [EBNF num=. ?[ number? ]? list=list:x num:y => [[ drop x y + ]] | num EBNF] call 
] unit-test

{ 3 } [
  { 1 2 "a" 4 } [EBNF num=. ?[ number? ]? list=list:x num:y => [[ drop x y + ]] | num EBNF] call ast>>
] unit-test

{ f } [
  "ab" [EBNF -=" " | "\t" | "\n" foo="a" - "b" EBNF] call 
] unit-test

{ V{ "a" " " "b" } } [
  "a b" [EBNF -=" " | "\t" | "\n" foo="a" - "b" EBNF] call ast>>
] unit-test

{ V{ "a" "\t" "b" } } [
  "a\tb" [EBNF -=" " | "\t" | "\n" foo="a" - "b" EBNF] call ast>> 
] unit-test

{ V{ "a" "\n" "b" } } [
  "a\nb" [EBNF -=" " | "\t" | "\n" foo="a" - "b" EBNF] call ast>>
] unit-test

{ V{ "a" f "b" } } [
  "ab" [EBNF -=" " | "\t" | "\n" foo="a" (-)? "b" EBNF] call ast>>
] unit-test

{ V{ "a" " " "b" } } [
  "a b" [EBNF -=" " | "\t" | "\n" foo="a" (-)? "b" EBNF] call ast>>
] unit-test


{ V{ "a" "\t" "b" } } [
  "a\tb" [EBNF -=" " | "\t" | "\n" foo="a" (-)? "b" EBNF] call ast>>
] unit-test

{ V{ "a" "\n" "b" } } [
  "a\nb" [EBNF -=" " | "\t" | "\n" foo="a" (-)? "b" EBNF] call ast>>
] unit-test

{ V{ "a" "b" } } [
  "ab" [EBNF -=(" " | "\t" | "\n")? => [[ drop ignore ]] foo="a" - "b" EBNF] call ast>>
] unit-test

{ V{ "a" "b" } } [
  "a\tb" [EBNF -=(" " | "\t" | "\n")? => [[ drop ignore ]] foo="a" - "b" EBNF] call ast>>
] unit-test

{ V{ "a" "b" } } [
  "a\nb" [EBNF -=(" " | "\t" | "\n")? => [[ drop ignore ]] foo="a" - "b" EBNF] call ast>>
] unit-test

{ f } [
  "axb" [EBNF -=(" " | "\t" | "\n")? => [[ drop ignore ]] foo="a" - "b" EBNF] call 
] unit-test

{ V{ V{ 49 } "+" V{ 49 } } } [ 
  #! Test direct left recursion. 
  #! Using packrat, so first part of expr fails, causing 2nd choice to be used  
  "1+1" [EBNF num=([0-9])+ expr=expr "+" num | num EBNF] call ast>>
] unit-test

{ V{ V{ V{ 49 } "+" V{ 49 } } "+" V{ 49 } } } [ 
  #! Test direct left recursion. 
  #! Using packrat, so first part of expr fails, causing 2nd choice to be used  
  "1+1+1" [EBNF num=([0-9])+ expr=expr "+" num | num EBNF] call ast>>
] unit-test

{ V{ V{ V{ 49 } "+" V{ 49 } } "+" V{ 49 } } } [ 
  #! Test indirect left recursion. 
  #! Using packrat, so first part of expr fails, causing 2nd choice to be used  
  "1+1+1" [EBNF num=([0-9])+ x=expr expr=x "+" num | num EBNF] call ast>>
] unit-test

{ t } [
  "abcd='9' | ('8'):x => [[ drop x ]]" 'ebnf' parse parse-result-remaining empty?
] unit-test

EBNF: primary 
Primary = PrimaryNoNewArray
PrimaryNoNewArray =  ClassInstanceCreationExpression
                   | MethodInvocation
                   | FieldAccess
                   | ArrayAccess
                   | "this"
ClassInstanceCreationExpression =  "new" ClassOrInterfaceType "(" ")"
                                 | Primary "." "new" Identifier "(" ")"
MethodInvocation =  Primary "." MethodName "(" ")"
                  | MethodName "(" ")"
FieldAccess =  Primary "." Identifier
             | "super" "." Identifier  
ArrayAccess =  Primary "[" Expression "]" 
             | ExpressionName "[" Expression "]"
ClassOrInterfaceType = ClassName | InterfaceTypeName
ClassName = "C" | "D"
InterfaceTypeName = "I" | "J"
Identifier = "x" | "y" | ClassOrInterfaceType
MethodName = "m" | "n"
ExpressionName = Identifier
Expression = "i" | "j"
main = Primary
;EBNF 

{ "this" } [
  "this" primary ast>>
] unit-test

{ V{ "this" "." "x" } } [
  "this.x" primary ast>>
] unit-test

{ V{ V{ "this" "." "x" } "." "y" } } [
  "this.x.y" primary ast>>
] unit-test

{ V{ V{ "this" "." "x" } "." "m" "(" ")" } } [
  "this.x.m()" primary ast>>
] unit-test

{ V{ V{ V{ "x" "[" "i" "]" } "[" "j" "]" } "." "y" } } [
  "x[i][j].y" primary ast>>
] unit-test

'ebnf' compile must-infer

{ V{ V{ "a" "b" } "c" } } [
  "abc" [EBNF a="a" "b" foo=(a "c") EBNF] call ast>>
] unit-test

{ V{ V{ "a" "b" } "c" } } [
  "abc" [EBNF a="a" "b" foo={a "c"} EBNF] call ast>>
] unit-test

{ V{ V{ "a" "b" } "c" } } [
  "abc" [EBNF a="a" "b" foo=a "c" EBNF] call ast>>
] unit-test

{ f } [
  "a bc" [EBNF a="a" "b" foo=(a "c") EBNF] call 
] unit-test

{ f } [
  "a bc" [EBNF a="a" "b" foo=a "c" EBNF] call 
] unit-test

{ f } [
  "a bc" [EBNF a="a" "b" foo={a "c"} EBNF] call
] unit-test

{ f } [
  "ab c" [EBNF a="a" "b" foo=a "c" EBNF] call 
] unit-test

{ V{ V{ "a" "b" } "c" } } [
  "ab c" [EBNF a="a" "b" foo={a "c"} EBNF] call ast>>
] unit-test

{ f } [
  "ab c" [EBNF a="a" "b" foo=(a "c") EBNF] call 
] unit-test

{ f } [
  "a b c" [EBNF a="a" "b" foo=a "c" EBNF] call 
] unit-test

{ f } [
  "a b c" [EBNF a="a" "b" foo=(a "c") EBNF] call 
] unit-test

{ f } [
  "a b c" [EBNF a="a" "b" foo={a "c"} EBNF] call 
] unit-test

{ V{ V{ V{ "a" "b" } "c" } V{ V{ "a" "b" } "c" } } } [
  "ab cab c" [EBNF a="a" "b" foo={a "c"}* EBNF] call ast>>
] unit-test

{ V{ } } [
  "ab cab c" [EBNF a="a" "b" foo=(a "c")* EBNF] call ast>>
] unit-test

{ V{ V{ V{ "a" "b" } "c" } V{ V{ "a" "b" } "c" } } } [
  "ab c ab c" [EBNF a="a" "b" foo={a "c"}* EBNF] call ast>>
] unit-test

{ V{ } } [
  "ab c ab c" [EBNF a="a" "b" foo=(a "c")* EBNF] call ast>>
] unit-test

