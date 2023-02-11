USING: smalltalk.parser smalltalk.ast peg.ebnf tools.test accessors
io.files io.encodings.ascii kernel multiline ;
IN: smalltalk.parser.tests

EBNF: test-Character [=[
test         = <foreign parse-smalltalk Character>
]=]

{ CHAR: a } [ "a" test-Character ] unit-test

EBNF: test-Comment [=[
test         = <foreign parse-smalltalk Comment>
]=]

{ T{ ast-comment f "Hello, this is a comment." } }
[ "\"Hello, this is a comment.\"" test-Comment ]
unit-test

{ T{ ast-comment f "Hello, \"this\" is a comment." } }
[ "\"Hello, \"\"this\"\" is a comment.\"" test-Comment ]
unit-test

EBNF: test-Identifier [=[
test         = <foreign parse-smalltalk Identifier>
]=]

{ "OrderedCollection" } [ "OrderedCollection" test-Identifier ] unit-test

EBNF: test-Literal [=[
test         = <foreign parse-smalltalk Literal>
]=]

{ nil } [ "nil" test-Literal ] unit-test
{ 123 } [ "123" test-Literal ] unit-test
{ 0xdeadbeef } [ "16rdeadbeef" test-Literal ] unit-test
{ -123 } [ "-123" test-Literal ] unit-test
{ 1.2 } [ "1.2" test-Literal ] unit-test
{ -1.24 } [ "-1.24" test-Literal ] unit-test
{ 12.4e7 } [ "12.4e7" test-Literal ] unit-test
{ 12.4e-7 } [ "12.4e-7" test-Literal ] unit-test
{ -12.4e7 } [ "-12.4e7" test-Literal ] unit-test
{ CHAR: x } [ "$x" test-Literal ] unit-test
{ "Hello, world" } [ "'Hello, world'" test-Literal ] unit-test
{ "Hello, 'funny' world" } [ "'Hello, ''funny'' world'" test-Literal ] unit-test
{ T{ symbol f "foo" } } [ "#foo" test-Literal ] unit-test
{ T{ symbol f "+" } } [ "#+" test-Literal ] unit-test
{ T{ symbol f "at:put:" } } [ "#at:put:" test-Literal ] unit-test
{ T{ symbol f "Hello world" } } [ "#'Hello world'" test-Literal ] unit-test
{ B{ 1 2 3 4 } } [ "#[1 2 3 4]" test-Literal ] unit-test
{ { nil t f } } [ "#(nil true false)" test-Literal ] unit-test
{ { nil { t f } } } [ "#(nil (true false))" test-Literal ] unit-test
{ T{ ast-block f { } { } { } } } [ "[]" test-Literal ] unit-test
{ T{ ast-block f { "x" } { } { T{ ast-return f T{ ast-name f "x" } } } } } [ "[ :x|^x]" test-Literal ] unit-test
{ T{ ast-block f { } { } { T{ ast-return f self } } } } [ "[^self]" test-Literal ] unit-test

{
    T{ ast-block
        { arguments { "i" } }
        { body
            {
                T{ ast-message-send
                    { receiver T{ ast-name { name "i" } } }
                    { selector "print" }
                }
            }
        }
    }
}
[ "[ :i | i print ]" test-Literal ] unit-test

{
    T{ ast-block
        { body { 5 self } }
    }
}
[ "[5. self]" test-Literal ] unit-test

EBNF: test-FormalBlockArgumentDeclarationList [=[
test         = <foreign parse-smalltalk FormalBlockArgumentDeclarationList>
]=]

{ V{ "x" "y" "elt" } } [ ":x :y :elt" test-FormalBlockArgumentDeclarationList ] unit-test

EBNF: test-Operand [=[
test         = <foreign parse-smalltalk Operand>
]=]

{ { 123 15.6 { t f } } } [ "#(123 15.6 (true false))" test-Operand ] unit-test
{ T{ ast-name f "x" } } [ "x" test-Operand ] unit-test

EBNF: test-Expression [=[
test         = <foreign parse-smalltalk Expression>
]=]

{ self } [ "self" test-Expression ] unit-test
{ { 123 15.6 { t f } } } [ "#(123 15.6 (true false))" test-Expression ] unit-test
{ T{ ast-name f "x" } } [ "x" test-Expression ] unit-test
{ T{ ast-message-send f 5 "print" { } } } [ "5 print" test-Expression ] unit-test
{ T{ ast-message-send f T{ ast-message-send f 5 "squared" { } } "print" { } } } [ "5 squared print" test-Expression ] unit-test
{ T{ ast-message-send f 2 "+" { 2 } } } [ "2+2" test-Expression ] unit-test

{
    T{ ast-message-send f
        T{ ast-message-send f 3 "factorial" { } }
        "+"
        { T{ ast-message-send f 4 "factorial" { } } }
    }
}
[ "3 factorial + 4 factorial" test-Expression ] unit-test

{
    T{ ast-message-send f
        T{ ast-message-send f 3 "factorial" { } }
        "+"
        { T{ ast-message-send f 4 "factorial" { } } }
    }
}
[ "   3 factorial + 4 factorial" test-Expression ] unit-test

{
    T{ ast-message-send f
        T{ ast-message-send f 3 "factorial" { } }
        "+"
        { T{ ast-message-send f 4 "factorial" { } } }
    }
}
[ "   3 factorial + 4 factorial     " test-Expression ] unit-test

{
    T{ ast-message-send f
        T{ ast-message-send f
            T{ ast-message-send f 3 "factorial" { } }
            "+"
            { 4 }
        }
        "factorial"
        { }
    }
}
[ "(3 factorial + 4) factorial" test-Expression ] unit-test

{
    T{ ast-message-send
        { receiver
            T{ ast-message-send
                { receiver
                T{ ast-message-send
                    { receiver 1 }
                    { selector "<" }
                    { arguments { 10 } }
                }
                }
                { selector "ifTrue:ifFalse:" }
                { arguments
                {
                    T{ ast-block { body { "HI" } } }
                    T{ ast-block { body { "BYE" } } }
                }
                }
            }
        }
        { selector "print" }
    }
}
[ "((1 < 10) ifTrue: [ 'HI' ] ifFalse: [ 'BYE' ]) print" test-Expression ] unit-test

{
    T{ ast-cascade
        { receiver 12 }
        { messages
            {
            T{ ast-message f "sqrt" }
            T{ ast-message f "+" { 2 } }
            }
        }
    }
}
[ "12 sqrt; + 2" test-Expression ] unit-test

{
    T{ ast-cascade
        { receiver T{ ast-message-send f 12 "sqrt" } }
        { messages
            {
                T{ ast-message f "+" { 1 } }
                T{ ast-message f "+" { 2 } }
            }
       }
    }
}
[ "12 sqrt + 1; + 2" test-Expression ] unit-test

{
    T{ ast-cascade
        { receiver T{ ast-message-send f 12 "squared" } }
        { messages
            {
                T{ ast-message f "to:" { 100 } }
                T{ ast-message f "sqrt" }
            }
       }
    }
}
[ "12 squared to: 100; sqrt" test-Expression ] unit-test

{
    T{ ast-message-send f
        T{ ast-message-send f 1 "+" { 2 } }
        "*"
        { 3 }
    }
}
[ "1+2*3" test-Expression ] unit-test

{
    T{ ast-message-send
        { receiver
            T{ ast-message-send
                { receiver { T{ ast-block { body { "a" } } } } }
                { selector "at:" }
                { arguments { 0 } }
            }
        }
        { selector "value" }
    }
}
[ "(#(['a']) at: 0) value" test-Expression ] unit-test

EBNF: test-FinalStatement [=[
test         = <foreign parse-smalltalk FinalStatement>
]=]

{ T{ ast-name f "value" } } [ "value" test-FinalStatement ] unit-test
{ T{ ast-return f T{ ast-name f "value" } } } [ "^value" test-FinalStatement ] unit-test
{ T{ ast-assignment f T{ ast-name f "value" } 5 } } [ "value:=5" test-FinalStatement ] unit-test

EBNF: test-LocalVariableDeclarationList [=[
test         = <foreign parse-smalltalk LocalVariableDeclarationList>
]=]

{ T{ ast-local-variables f { "i" "j" } } } [ " |  i j   |" test-LocalVariableDeclarationList ] unit-test


{ T{ ast-message-send f T{ ast-name f "x" } "foo:bar:" { 1 2 } } }
[ "x foo:1 bar:2" test-Expression ] unit-test

{
    T{ ast-message-send
        f
        T{ ast-message-send f
            T{ ast-message-send f 3 "factorial" { } }
            "+"
            { T{ ast-message-send f 4 "factorial" { } } }
        }
        "between:and:"
        { 10 100 }
    }
}
[ "3 factorial + 4 factorial between: 10 and: 100" test-Expression ] unit-test

{ T{ ast-sequence f { } { 1 2 } } } [ "1. 2" parse-smalltalk ] unit-test

{ T{ ast-sequence f { } { 1 2 } } } [ "1. 2." parse-smalltalk ] unit-test

{
    T{ ast-sequence f { }
        {
            T{ ast-class
               { name "Test" }
               { superclass "Object" }
               { ivars { "a" } }
            }
        }
    }
}
[ "class Test [|a|]" parse-smalltalk ] unit-test

{
    T{ ast-sequence f { }
        {
            T{ ast-class
               { name "Test1" }
               { superclass "Object" }
               { ivars { "a" } }
            }

            T{ ast-class
               { name "Test2" }
               { superclass "Test1" }
               { ivars { "b" } }
            }
        }
    }
}
[ "class Test1 [|a|]. class Test2 extends Test1 [|b|]" parse-smalltalk ] unit-test

[ "class Foo []. Tests blah " parse-smalltalk ] must-not-fail

[ "vocab:smalltalk/parser/test.st" ascii file-contents parse-smalltalk ] must-not-fail

[ "_abc_" parse-smalltalk ] must-not-fail
