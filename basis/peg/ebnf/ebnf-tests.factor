! Copyright (C) 2007 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
!
USING: kernel tools.test peg peg.ebnf peg.ebnf.private words
math math.parser sequences accessors peg.parsers parser
namespaces arrays strings eval unicode multiline ;
IN: peg.ebnf.tests

{ T{ ebnf-non-terminal f "abc" } } [
  "abc" non-terminal-parser parse
] unit-test

{ T{ ebnf-terminal f "55" } } [
  "'55'" terminal-parser parse
] unit-test

{
  T{ ebnf-rule f
    "digit"
    T{ ebnf-choice f
        V{ T{ ebnf-terminal f "1" } T{ ebnf-terminal f "2" } }
    }
  }
} [
  "digit = '1' | '2'" rule-parser parse
] unit-test

{
  T{ ebnf-rule f
    "digit"
    T{ ebnf-sequence f
      V{ T{ ebnf-terminal f "1" } T{ ebnf-terminal f "2" } }
    }
  }
} [
  "digit = '1' '2'" rule-parser parse
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
  "one two | three" choice-parser parse
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
  "one {two | three}" choice-parser parse
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
  "one ((two | three) four)*" choice-parser parse
] unit-test

{
  T{ ebnf-sequence f
    V{
       T{ ebnf-non-terminal f "one" }
       T{ ebnf-ignore f
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
  "one ((two | three) four)~" choice-parser parse
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
  "one ( two )? three" choice-parser parse
] unit-test

{ "foo" } [
  "\"foo\"" identifier-parser parse
] unit-test

{ "foo" } [
  "'foo'" identifier-parser parse
] unit-test

{ "\"" } [
  "\"\\\"\"" identifier-parser parse
] unit-test

{ "\\" } [
  "\"\\\\\"" identifier-parser parse
] unit-test

{ "AΣ𝄞" } [
  "'\\x41\\u{greek-capital-letter-sigma}\\u01D11E'" identifier-parser parse
] unit-test

{ "foo" } [
  "foo" non-terminal-parser parse symbol>>
] unit-test

{ "foo" } [
  "foo]" non-terminal-parser parse symbol>>
] unit-test

{ V{ "a" "b" } } [
  "ab" EBNF[=[ foo='a' 'b' ]=]
] unit-test

{ V{ 1 "b" } } [
  "ab" EBNF[=[ foo=('a')[[ drop 1 ]] 'b' ]=]
] unit-test

{ V{ 1 2 } } [
  "ab" EBNF[=[ foo=('a') [[ drop 1 ]] ('b') [[ drop 2 ]] ]=]
] unit-test

{ CHAR: A } [
  "A" EBNF[=[ foo=[A-Z] ]=]
] unit-test

{ CHAR: Z } [
  "Z" EBNF[=[ foo=[A-Z] ]=]
] unit-test

[
  "0" EBNF[=[ foo=[A-Z] ]=]
] must-fail

{ CHAR: 0 } [
  "0" EBNF[=[ foo=[^A-Z] ]=]
] unit-test

[
  "A" EBNF[=[ foo=[^A-Z] ]=]
] must-fail

[
  "Z" EBNF[=[ foo=[^A-Z] ]=]
] must-fail

{ V{ "1" "+" "foo" } } [
  "1+1" EBNF[=[ foo='1' '+' '1' [[ drop "foo" ]] ]=]
] unit-test

{ "foo" } [
  "1+1" EBNF[=[ foo='1' '+' '1' => [[ drop "foo" ]] ]=]
] unit-test

{ "foo" } [
  "1+1" EBNF[=[ foo='1' '+' '1' => [[ drop "foo" ]] | '1' '-' '1' => [[ drop "bar" ]] ]=]
] unit-test

{ "bar" } [
  "1-1" EBNF[=[ foo='1' '+' '1' => [[ drop "foo" ]] | '1' '-' '1' => [[ drop "bar" ]] ]=]
] unit-test

{ 6 } [
  "4+2" EBNF[=[ num=[0-9] => [[ digit> ]] foo=num:x '+' num:y => [[ x y + ]] ]=]
] unit-test

{ 6 } [
  "4+2" EBNF[=[ foo=[0-9]:x '+' [0-9]:y => [[ x digit> y digit> + ]] ]=]
] unit-test

{ 10 } [
  { 1 2 3 4 } EBNF[=[ num=. ?[ number? ]? list=list:x num:y => [[ x y + ]] | num ]=]
] unit-test

[
  { "a" 2 3 4 } EBNF[=[ num=. ?[ number? ]? list=list:x num:y => [[ x y + ]] | num ]=]
] must-fail

{ 3 } [
  { 1 2 "a" 4 } PARTIAL-EBNF[=[ num=. ?[ number? ]? list=list:x num:y => [[ x y + ]] | num ]=]
] unit-test

[
  "ab" EBNF[=[ -=" " | "\t" | "\n" foo="a" - "b" ]=]
] must-fail

{ V{ "a" " " "b" } } [
  "a b" EBNF[=[ -=" " | "\t" | "\n" foo="a" - "b" ]=]
] unit-test

{ V{ "a" "\t" "b" } } [
  "a\tb" EBNF[=[ -=" " | "\t" | "\n" foo="a" - "b" ]=]
] unit-test

{ V{ "a" "\n" "b" } } [
  "a\nb" EBNF[=[ -=" " | "\t" | "\n" foo="a" - "b" ]=]
] unit-test

{ V{ "a" f "b" } } [
  "ab" EBNF[=[ -=" " | "\t" | "\n" foo="a" (-)? "b" ]=]
] unit-test

{ V{ "a" " " "b" } } [
  "a b" EBNF[=[ -=" " | "\t" | "\n" foo="a" (-)? "b" ]=]
] unit-test


{ V{ "a" "\t" "b" } } [
  "a\tb" EBNF[=[ -=" " | "\t" | "\n" foo="a" (-)? "b" ]=]
] unit-test

{ V{ "a" "\n" "b" } } [
  "a\nb" EBNF[=[ -=" " | "\t" | "\n" foo="a" (-)? "b" ]=]
] unit-test

{ V{ "a" "b" } } [
  "ab" EBNF[=[ -=(" " | "\t" | "\n")? => [[ drop ignore ]] foo="a" - "b" ]=]
] unit-test

{ V{ "a" "b" } } [
  "a\tb" EBNF[=[ -=(" " | "\t" | "\n")? => [[ drop ignore ]] foo="a" - "b" ]=]
] unit-test

{ V{ "a" "b" } } [
  "a\nb" EBNF[=[ -=(" " | "\t" | "\n")? => [[ drop ignore ]] foo="a" - "b" ]=]
] unit-test

[
  "axb" EBNF[=[ -=(" " | "\t" | "\n")? => [[ drop ignore ]] foo="a" - "b" ]=]
] must-fail

{ V{ V{ 49 } "+" V{ 49 } } } [
  ! Test direct left recursion.
  ! Using packrat, so first part of expr fails, causing 2nd choice to be used
  "1+1" EBNF[=[ num=([0-9])+ expr=expr "+" num | num ]=]
] unit-test

{ V{ V{ V{ 49 } "+" V{ 49 } } "+" V{ 49 } } } [
  ! Test direct left recursion.
  ! Using packrat, so first part of expr fails, causing 2nd choice to be used
  "1+1+1" EBNF[=[ num=([0-9])+ expr=expr "+" num | num ]=]
] unit-test

{ V{ V{ V{ 49 } "+" V{ 49 } } "+" V{ 49 } } } [
  ! Test indirect left recursion.
  ! Using packrat, so first part of expr fails, causing 2nd choice to be used
  "1+1+1" EBNF[=[ num=([0-9])+ x=expr expr=x "+" num | num ]=]
] unit-test

{ t } [
  "abcd='9' | ('8'):x => [[ x ]]" ebnf-parser (parse) remaining>> empty?
] unit-test

EBNF: primary [=[
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
]=]

{ "this" } [
  "this" primary
] unit-test

{ V{ "this" "." "x" } } [
  "this.x" primary
] unit-test

{ V{ V{ "this" "." "x" } "." "y" } } [
  "this.x.y" primary
] unit-test

{ V{ V{ "this" "." "x" } "." "m" "(" ")" } } [
  "this.x.m()" primary
] unit-test

{ V{ V{ V{ "x" "[" "i" "]" } "[" "j" "]" } "." "y" } } [
  "x[i][j].y" primary
] unit-test

{ V{ V{ "a" "b" } "c" } } [
  "abc" EBNF[=[ a="a" "b" foo=(a "c") ]=]
] unit-test

{ V{ "a" "c" } } [
  "abc" EBNF[=[ a="a" "b"~ foo=(a "c") ]=]
] unit-test

{ V{ V{ "a" V{ "b" "b" } } "c" } } [
  "abbc" EBNF[=[ a=("a" "b"*) foo=(a "c") ]=]
] unit-test

{ V{ "a" "c" } } [
  "abc" EBNF[=[ a=("a" ("b")~) foo=(a "c") ]=]
] unit-test

{ V{ "a" "c" } } [
  "abc" EBNF[=[ a=("a" "b"~) foo=(a "c") ]=]
] unit-test

{ "c" } [
  "abc" EBNF[=[ a=("a" "b")~ foo=(a "c") ]=]
] unit-test

{ V{ V{ "a" "b" } "c" } } [
  "abc" EBNF[=[ a="a" "b" foo={a "c"} ]=]
] unit-test

{ V{ V{ "a" "b" } "c" } } [
  "abc" EBNF[=[ a="a" "b" foo=a "c" ]=]
] unit-test

[
  "a bc" EBNF[=[ a="a" "b" foo=(a "c") ]=]
] must-fail

[
  "a bc" EBNF[=[ a="a" "b" foo=a "c" ]=]
] must-fail

[
  "a bc" EBNF[=[ a="a" "b" foo={a "c"} ]=]
] must-fail

[
  "ab c" EBNF[=[ a="a" "b" foo=a "c" ]=]
] must-fail

{ V{ V{ "a" "b" } "c" } } [
  "ab c" EBNF[=[ a="a" "b" foo={a "c"} ]=]
] unit-test

[
  "ab c" EBNF[=[ a="a" "b" foo=(a "c") ]=]
] must-fail

[
  "a b c" EBNF[=[ a="a" "b" foo=a "c" ]=]
] must-fail

[
  "a b c" EBNF[=[ a="a" "b" foo=(a "c") ]=]
] must-fail

[
  "a b c" EBNF[=[ a="a" "b" foo={a "c"} ]=]
] must-fail

{ V{ V{ V{ "a" "b" } "c" } V{ V{ "a" "b" } "c" } } } [
  "ab cab c" EBNF[=[ a="a" "b" foo={a "c"}* ]=]
] unit-test

{ V{ } } [
  "ab cab c" PARTIAL-EBNF[=[ a="a" "b" foo=(a "c")* ]=]
] unit-test

{ V{ V{ V{ "a" "b" } "c" } V{ V{ "a" "b" } "c" } } } [
  "ab c ab c" EBNF[=[ a="a" "b" foo={a "c"}* ]=]
] unit-test

{ V{ V{ "a" "c" } V{ "a" "c" } } } [
  "ab c ab c" EBNF[=[ a="a" "b"~ foo={a "c"}* ]=]
] unit-test

{ V{ } } [
  "ab c ab c" PARTIAL-EBNF[=[ a="a" "b" foo=(a "c")* ]=]
] unit-test

{ V{ } } [
  "ab c ab c" PARTIAL-EBNF[=[ a="a" "b" foo=(a "c")* ]=]
] unit-test

{ V{ "a" "a" "a" } } [
  "aaa" EBNF[=[ a=('a')* b=!('b') a:x => [[ x ]] ]=]
] unit-test

{ t } [
  "aaa" EBNF[=[ a=('a')* b=!('b') a:x => [[ x ]] ]=]
  "aaa" EBNF[=[ a=('a')* b=!('b') (a):x => [[ x ]] ]=] =
] unit-test

{ V{ "a" "a" "a" } } [
  "aaa" EBNF[=[ a=('a')* b=a:x => [[ x ]] ]=]
] unit-test

{ t } [
  "aaa" EBNF[=[ a=('a')* b=a:x => [[ x ]] ]=]
  "aaa" EBNF[=[ a=('a')* b=(a):x => [[ x ]] ]=] =
] unit-test

{ t } [
  "number=(digit)+:n 'a'" ebnf-parser (parse) remaining>> length zero?
] unit-test

{ t } [
  "number=(digit)+ 'a'" ebnf-parser (parse) remaining>> length zero?
] unit-test

{ t } [
  "number=digit+ 'a'" ebnf-parser (parse) remaining>> length zero?
] unit-test

{ t } [
  "number=digit+:n 'a'" ebnf-parser (parse) remaining>> length zero?
] unit-test

{ t } [
  "foo=(name):n !(keyword) => [[ n ]]" rule-parser parse
  "foo=name:n !(keyword) => [[ n ]]" rule-parser parse =
] unit-test

{ t } [
  "foo=!(keyword) (name):n => [[ n ]]" rule-parser parse
  "foo=!(keyword) name:n => [[ n ]]" rule-parser parse =
] unit-test

<<
EBNF: parser1 [=[
foo='a' 
]=]
>>

EBNF: parser2 [=[
foo=<foreign parser1 foo> 'b'
]=]

EBNF: parser3 [=[
foo=<foreign parser1> 'c'
]=]

EBNF: parser4 [=[
foo=<foreign any-char> 'd'
]=]

{ "a" } [
  "a" parser1
] unit-test

{ V{ "a" "b" } } [
  "ab" parser2
] unit-test

{ V{ "a" "c" } } [
  "ac" parser3
] unit-test

{ V{ CHAR: a "d" } } [
  "ad" parser4
] unit-test

{ } [
 "USING: kernel peg.ebnf ; \"a\\n\" EBNF[=[ foo='a' '\n'  => [[ drop \"\n\" ]] ]=] drop" eval( -- )
] unit-test

[
  "USING: peg.ebnf ; EBNF[=[ foo='a' foo='b' ]=]" eval( -- ) drop
] must-fail

{ t } [
  ! Rule lookup occurs in a namespace. This causes an incorrect duplicate rule
  ! if a var in a namespace is set. This unit test is to remind me to fix this.
  [ "fail" "foo" set "foo='a'" ebnf-parser parse transform drop t ] with-scope
] unit-test

! Tokenizer tests
{ V{ "a" CHAR: b } } [
  "ab" EBNF[=[ tokenizer=default foo="a" . ]=]
] unit-test

TUPLE: ast-number value ;

EBNF: a-tokenizer [=[
Letter            = [a-zA-Z]
Digit             = [0-9]
Digits            = Digit+
SingleLineComment = "//" (!("\n") .)* "\n" => [[ ignore ]]
MultiLineComment  = "/*" (!("*/") .)* "*/" => [[ ignore ]]
Space             = " " | "\t" | "\r" | "\n" | SingleLineComment | MultiLineComment
Spaces            = Space* => [[ ignore ]]
Number            = Digits:ws '.' Digits:fs => [[ ws "." fs 3array "" concat-as string>number ast-number boa ]]
                    | Digits => [[ >string string>number ast-number boa ]]  
Special            =   "("   | ")"   | "{"   | "}"   | "["   | "]"   | ","   | ";"
                     | "?"   | ":"   | "!==" | "~="  | "===" | "=="  | "="   | ">="
                     | ">"   | "<="  | "<"   | "++"  | "+="  | "+"   | "--"  | "-="
                     | "-"   | "*="  | "*"   | "/="  | "/"   | "%="  | "%"   | "&&="
                     | "&&"  | "||=" | "||"  | "."   | "!"
Tok                = Spaces (Number | Special )
]=]

{ V{ CHAR: 1 T{ ast-number f 23 } ";" CHAR: x } } [
  "123;x" EBNF[=[ bar = .
                tokenizer = <foreign a-tokenizer Tok>  foo=.
                tokenizer=default baz=.
                main = bar foo foo baz
          ]=]
] unit-test

{ V{ CHAR: 5 "+" CHAR: 2 } } [
  "5+2" EBNF[=[
          space=(" " | "\n")
          number=[0-9]
          operator=("*" | "+")
          spaces=space* => [[ ignore ]]
          tokenizer=spaces (number | operator)
          main= . . .
        ]=]
] unit-test

{ V{ CHAR: 5 "+" CHAR: 2 } } [
  "5 + 2" EBNF[=[
          space=(" " | "\n")
          number=[0-9]
          operator=("*" | "+")
          spaces=space* => [[ ignore ]]
          tokenizer=spaces (number | operator)
          main= . . .
        ]=]
] unit-test

{ "++" } [
  "++--" PARTIAL-EBNF[=[ tokenizer=("++" | "--") main="++" ]=]
] unit-test

{ "\\" } [
  "\\" EBNF[=[ foo="\\" ]=]
] unit-test

[ "USE: peg.ebnf EBNF[=[ ]=]" eval( -- ) ] must-fail

[ "USE: peg.ebnf EBNF[=[
    lol = a
    lol = b
  ]=]" eval( -- )
] [
    error>> [ redefined-rule? ] [ name>> "lol" = ] bi and
] must-fail-with

{
    { "a" "a" }
} [
    EBNF: foo [=[  Bar = "a":a1 "a":a2 => [[ a1 a2 2array ]] ]=]
    "aa" foo
] unit-test

{
    { "a" "a" }
} [
    EBNF: foo2 [=[  Bar = "a":a-1 "a":a-2 => [[ a-1 a-2 2array ]] ]=]
    "aa" foo2
] unit-test

{ "abc" } [
    EBNF: parse-til-right-bracket [=[
    foo = [^\]]+
    ]=]
    PARTIAL-EBNF: parse-til-right-bracket* parse-til-right-bracket
    "abc]" parse-til-right-bracket* >string
] unit-test

! Doesn't match anything, don't run it.
{ } [
    EBNF: parse-empty-range [=[
    foo = []+
    ]=]
] unit-test

[
    [==[
      EBNF: parse-empty-squote [=[
        foo = ''
      ]=]
    ]==] parse-string
] must-fail

[
    [==[
      EBNF: parse-empty-squote [=[
        foo = ""
      ]=]
    ]==] parse-string
] must-fail

! Bugfix, ensure that ~ rules are ignored with local labels
{ { "a" "c" } } [
    "abc" EBNF[=[ rule="a":a "b"~ "c":c => [[ a c 2array ]] ]=]
] unit-test

{ { "a" "c" } } [
    "abc" EBNF[=[ rule="a":a "b"*~ "c":c => [[ a c 2array ]] ]=]
] unit-test

{ { "a" "c" } } [
    "abc" EBNF[=[ rule="a":a "b"+~ "c":c => [[ a c 2array ]] ]=]
] unit-test

! Bugfix, ensure that named vars work in groups
{ { "a" "b" } } [
    "ab" EBNF[=[ rule = ( "a":a "b":b ) => [[ { a b } ]] ]=]
] unit-test

{ { "a" "b" } } [
    "a b" EBNF[=[ rule = { "a":a "b":b } => [[ { a b } ]] ]=]
] unit-test
