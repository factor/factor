! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel tools.test peg peg.ebnf words math math.parser 
       sequences accessors peg.parsers parser namespaces arrays 
       strings ;
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
  "ab" [EBNF foo='a' 'b' EBNF] ast>> 
] unit-test

{ V{ 1 "b" } } [
  "ab" [EBNF foo=('a')[[ drop 1 ]] 'b' EBNF] ast>> 
] unit-test

{ V{ 1 2 } } [
  "ab" [EBNF foo=('a') [[ drop 1 ]] ('b') [[ drop 2 ]] EBNF] ast>> 
] unit-test

{ CHAR: A } [
  "A" [EBNF foo=[A-Z] EBNF] ast>> 
] unit-test

{ CHAR: Z } [
  "Z" [EBNF foo=[A-Z] EBNF] ast>> 
] unit-test

[
  "0" [EBNF foo=[A-Z] EBNF]  
] must-fail

{ CHAR: 0 } [
  "0" [EBNF foo=[^A-Z] EBNF] ast>> 
] unit-test

[
  "A" [EBNF foo=[^A-Z] EBNF]  
] must-fail

[
  "Z" [EBNF foo=[^A-Z] EBNF]  
] must-fail

{ V{ "1" "+" "foo" } } [
  "1+1" [EBNF foo='1' '+' '1' [[ drop "foo" ]] EBNF] ast>>
] unit-test

{ "foo" } [
  "1+1" [EBNF foo='1' '+' '1' => [[ drop "foo" ]] EBNF] ast>>
] unit-test

{ "foo" } [
  "1+1" [EBNF foo='1' '+' '1' => [[ drop "foo" ]] | '1' '-' '1' => [[ drop "bar" ]] EBNF] ast>>
] unit-test

{ "bar" } [
  "1-1" [EBNF foo='1' '+' '1' => [[ drop "foo" ]] | '1' '-' '1' => [[ drop "bar" ]] EBNF] ast>>
] unit-test

{ 6 } [
  "4+2" [EBNF num=[0-9] => [[ digit> ]] foo=num:x '+' num:y => [[ x y + ]] EBNF] ast>>
] unit-test

{ 6 } [
  "4+2" [EBNF foo=[0-9]:x '+' [0-9]:y => [[ x digit> y digit> + ]] EBNF] ast>>
] unit-test

{ 10 } [
  { 1 2 3 4 } [EBNF num=. ?[ number? ]? list=list:x num:y => [[ x y + ]] | num EBNF] ast>>
] unit-test

[
  { "a" 2 3 4 } [EBNF num=. ?[ number? ]? list=list:x num:y => [[ x y + ]] | num EBNF] 
] must-fail

{ 3 } [
  { 1 2 "a" 4 } [EBNF num=. ?[ number? ]? list=list:x num:y => [[ x y + ]] | num EBNF] ast>>
] unit-test

[
  "ab" [EBNF -=" " | "\t" | "\n" foo="a" - "b" EBNF] 
] must-fail

{ V{ "a" " " "b" } } [
  "a b" [EBNF -=" " | "\t" | "\n" foo="a" - "b" EBNF] ast>>
] unit-test

{ V{ "a" "\t" "b" } } [
  "a\tb" [EBNF -=" " | "\t" | "\n" foo="a" - "b" EBNF] ast>> 
] unit-test

{ V{ "a" "\n" "b" } } [
  "a\nb" [EBNF -=" " | "\t" | "\n" foo="a" - "b" EBNF] ast>>
] unit-test

{ V{ "a" f "b" } } [
  "ab" [EBNF -=" " | "\t" | "\n" foo="a" (-)? "b" EBNF] ast>>
] unit-test

{ V{ "a" " " "b" } } [
  "a b" [EBNF -=" " | "\t" | "\n" foo="a" (-)? "b" EBNF] ast>>
] unit-test


{ V{ "a" "\t" "b" } } [
  "a\tb" [EBNF -=" " | "\t" | "\n" foo="a" (-)? "b" EBNF] ast>>
] unit-test

{ V{ "a" "\n" "b" } } [
  "a\nb" [EBNF -=" " | "\t" | "\n" foo="a" (-)? "b" EBNF] ast>>
] unit-test

{ V{ "a" "b" } } [
  "ab" [EBNF -=(" " | "\t" | "\n")? => [[ drop ignore ]] foo="a" - "b" EBNF] ast>>
] unit-test

{ V{ "a" "b" } } [
  "a\tb" [EBNF -=(" " | "\t" | "\n")? => [[ drop ignore ]] foo="a" - "b" EBNF] ast>>
] unit-test

{ V{ "a" "b" } } [
  "a\nb" [EBNF -=(" " | "\t" | "\n")? => [[ drop ignore ]] foo="a" - "b" EBNF] ast>>
] unit-test

[
  "axb" [EBNF -=(" " | "\t" | "\n")? => [[ drop ignore ]] foo="a" - "b" EBNF] 
] must-fail

{ V{ V{ 49 } "+" V{ 49 } } } [ 
  #! Test direct left recursion. 
  #! Using packrat, so first part of expr fails, causing 2nd choice to be used  
  "1+1" [EBNF num=([0-9])+ expr=expr "+" num | num EBNF] ast>>
] unit-test

{ V{ V{ V{ 49 } "+" V{ 49 } } "+" V{ 49 } } } [ 
  #! Test direct left recursion. 
  #! Using packrat, so first part of expr fails, causing 2nd choice to be used  
  "1+1+1" [EBNF num=([0-9])+ expr=expr "+" num | num EBNF] ast>>
] unit-test

{ V{ V{ V{ 49 } "+" V{ 49 } } "+" V{ 49 } } } [ 
  #! Test indirect left recursion. 
  #! Using packrat, so first part of expr fails, causing 2nd choice to be used  
  "1+1+1" [EBNF num=([0-9])+ x=expr expr=x "+" num | num EBNF] ast>>
] unit-test

{ t } [
  "abcd='9' | ('8'):x => [[ x ]]" 'ebnf' parse parse-result-remaining empty?
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
  "abc" [EBNF a="a" "b" foo=(a "c") EBNF] ast>>
] unit-test

{ V{ V{ "a" "b" } "c" } } [
  "abc" [EBNF a="a" "b" foo={a "c"} EBNF] ast>>
] unit-test

{ V{ V{ "a" "b" } "c" } } [
  "abc" [EBNF a="a" "b" foo=a "c" EBNF] ast>>
] unit-test

[
  "a bc" [EBNF a="a" "b" foo=(a "c") EBNF] 
] must-fail

[
  "a bc" [EBNF a="a" "b" foo=a "c" EBNF] 
] must-fail

[
  "a bc" [EBNF a="a" "b" foo={a "c"} EBNF]
] must-fail

[
  "ab c" [EBNF a="a" "b" foo=a "c" EBNF] 
] must-fail

{ V{ V{ "a" "b" } "c" } } [
  "ab c" [EBNF a="a" "b" foo={a "c"} EBNF] ast>>
] unit-test

[
  "ab c" [EBNF a="a" "b" foo=(a "c") EBNF] 
] must-fail

[
  "a b c" [EBNF a="a" "b" foo=a "c" EBNF] 
] must-fail

[
  "a b c" [EBNF a="a" "b" foo=(a "c") EBNF] 
] must-fail

[
  "a b c" [EBNF a="a" "b" foo={a "c"} EBNF] 
] must-fail

{ V{ V{ V{ "a" "b" } "c" } V{ V{ "a" "b" } "c" } } } [
  "ab cab c" [EBNF a="a" "b" foo={a "c"}* EBNF] ast>>
] unit-test

{ V{ } } [
  "ab cab c" [EBNF a="a" "b" foo=(a "c")* EBNF] ast>>
] unit-test

{ V{ V{ V{ "a" "b" } "c" } V{ V{ "a" "b" } "c" } } } [
  "ab c ab c" [EBNF a="a" "b" foo={a "c"}* EBNF] ast>>
] unit-test

{ V{ } } [
  "ab c ab c" [EBNF a="a" "b" foo=(a "c")* EBNF] ast>>
] unit-test

{ V{ "a" "a" "a" } } [
  "aaa" [EBNF a=('a')* b=!('b') a:x => [[ x ]] EBNF] ast>>
] unit-test

{ t } [
  "aaa" [EBNF a=('a')* b=!('b') a:x => [[ x ]] EBNF] ast>>
  "aaa" [EBNF a=('a')* b=!('b') (a):x => [[ x ]] EBNF] ast>> =
] unit-test

{ V{ "a" "a" "a" } } [
  "aaa" [EBNF a=('a')* b=a:x => [[ x ]] EBNF] ast>>
] unit-test

{ t } [
  "aaa" [EBNF a=('a')* b=a:x => [[ x ]] EBNF] ast>>
  "aaa" [EBNF a=('a')* b=(a):x => [[ x ]] EBNF] ast>> =
] unit-test

{ t } [
  "number=(digit)+:n 'a'" 'ebnf' parse remaining>> length zero?
] unit-test

{ t } [
  "number=(digit)+ 'a'" 'ebnf' parse remaining>> length zero?
] unit-test

{ t } [
  "number=digit+ 'a'" 'ebnf' parse remaining>> length zero?
] unit-test

{ t } [
  "number=digit+:n 'a'" 'ebnf' parse remaining>> length zero?
] unit-test

{ t } [
  "foo=(name):n !(keyword) => [[ n ]]" 'rule' parse ast>>
  "foo=name:n !(keyword) => [[ n ]]" 'rule' parse ast>> =
] unit-test

{ t } [
  "foo=!(keyword) (name):n => [[ n ]]" 'rule' parse ast>>
  "foo=!(keyword) name:n => [[ n ]]" 'rule' parse ast>> =
] unit-test

<<
EBNF: parser1 
foo='a' 
;EBNF
>>

EBNF: parser2
foo=<foreign parser1 foo> 'b'
;EBNF

EBNF: parser3
foo=<foreign parser1> 'c'
;EBNF

EBNF: parser4
foo=<foreign any-char> 'd'
;EBNF

{ "a" } [
  "a" parser1 ast>>
] unit-test

{ V{ "a" "b" } } [
  "ab" parser2 ast>>
] unit-test

{ V{ "a" "c" } } [
  "ac" parser3 ast>>
] unit-test

{ V{ CHAR: a "d" } } [
  "ad" parser4 ast>>
] unit-test

{ t } [
 "USING: kernel peg.ebnf ; \"a\\n\" [EBNF foo='a' '\n'  => [[ drop \"\n\" ]] EBNF]" eval drop t
] unit-test

[
  "USING: peg.ebnf ; \"ab\" [EBNF foo='a' foo='b' EBNF]" eval drop
] must-fail

{ t } [
  #! Rule lookup occurs in a namespace. This causes an incorrect duplicate rule
  #! if a var in a namespace is set. This unit test is to remind me to fix this.
  [ "fail" "foo" set "foo='a'" 'ebnf' parse ast>> transform drop t ] with-scope
] unit-test

#! Tokenizer tests
{ V{ "a" CHAR: b } } [
  "ab" [EBNF tokenizer=default foo="a" . EBNF] ast>>
] unit-test

TUPLE: ast-number value ;

EBNF: a-tokenizer 
Letter            = [a-zA-Z]
Digit             = [0-9]
Digits            = Digit+
SingleLineComment = "//" (!("\n") .)* "\n" => [[ ignore ]]
MultiLineComment  = "/*" (!("*/") .)* "*/" => [[ ignore ]]
Space             = " " | "\t" | "\r" | "\n" | SingleLineComment | MultiLineComment
Spaces            = Space* => [[ ignore ]]
Number            = Digits:ws '.' Digits:fs => [[ ws "." fs 3array concat >string string>number ast-number boa ]]
                    | Digits => [[ >string string>number ast-number boa ]]  
Special            =   "("   | ")"   | "{"   | "}"   | "["   | "]"   | ","   | ";"
                     | "?"   | ":"   | "!==" | "~="  | "===" | "=="  | "="   | ">="
                     | ">"   | "<="  | "<"   | "++"  | "+="  | "+"   | "--"  | "-="
                     | "-"   | "*="  | "*"   | "/="  | "/"   | "%="  | "%"   | "&&="
                     | "&&"  | "||=" | "||"  | "."   | "!"
Tok                = Spaces (Number | Special )
;EBNF

{ V{ CHAR: 1 T{ ast-number f 23 } ";" CHAR: x } } [
  "123;x" [EBNF bar = . 
                tokenizer = <foreign a-tokenizer Tok>  foo=. 
                tokenizer=default baz=. 
                main = bar foo foo baz 
          EBNF] ast>>
] unit-test

{ V{ CHAR: 5 "+" CHAR: 2 } } [
  "5+2" [EBNF 
          space=(" " | "\n") 
          number=[0-9] 
          operator=("*" | "+") 
          spaces=space* => [[ ignore ]] 
          tokenizer=spaces (number | operator) 
          main= . . . 
        EBNF] ast>> 
] unit-test

{ V{ CHAR: 5 "+" CHAR: 2 } } [
  "5 + 2" [EBNF 
          space=(" " | "\n") 
          number=[0-9] 
          operator=("*" | "+") 
          spaces=space* => [[ ignore ]] 
          tokenizer=spaces (number | operator) 
          main= . . . 
        EBNF] ast>> 
] unit-test

{ "++" } [
  "++--" [EBNF tokenizer=("++" | "--") main="++" EBNF] ast>>
] unit-test

{ "\\" } [
  "\\" [EBNF foo="\\" EBNF] ast>>
] unit-test