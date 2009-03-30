IN: smalltalk.parser.tests
USING: smalltalk.parser smalltalk.ast peg.ebnf tools.test accessors
io.files io.encodings.ascii kernel ;

EBNF: test-Character
test         = <foreign parse-smalltalk Character>
;EBNF

[ CHAR: a ] [ "a" test-Character ] unit-test

EBNF: test-Comment
test         = <foreign parse-smalltalk Comment>
;EBNF

[ T{ ast-comment f "Hello, this is a comment." } ]
[ "\"Hello, this is a comment.\"" test-Comment ]
unit-test

[ T{ ast-comment f "Hello, \"this\" is a comment." } ]
[ "\"Hello, \"\"this\"\" is a comment.\"" test-Comment ]
unit-test

EBNF: test-Identifier
test         = <foreign parse-smalltalk Identifier>
;EBNF

[ "OrderedCollection" ] [ "OrderedCollection" test-Identifier ] unit-test

EBNF: test-Literal
test         = <foreign parse-smalltalk Literal>
;EBNF

[ nil ] [ "nil" test-Literal ] unit-test
[ 123 ] [ "123" test-Literal ] unit-test
[ HEX: deadbeef ] [ "16rdeadbeef" test-Literal ] unit-test
[ -123 ] [ "-123" test-Literal ] unit-test
[ 1.2 ] [ "1.2" test-Literal ] unit-test
[ -1.24 ] [ "-1.24" test-Literal ] unit-test
[ 12.4e7 ] [ "12.4e7" test-Literal ] unit-test
[ 12.4e-7 ] [ "12.4e-7" test-Literal ] unit-test
[ -12.4e7 ] [ "-12.4e7" test-Literal ] unit-test
[ CHAR: x ] [ "$x" test-Literal ] unit-test
[ "Hello, world" ] [ "'Hello, world'" test-Literal ] unit-test
[ "Hello, 'funny' world" ] [ "'Hello, ''funny'' world'" test-Literal ] unit-test
[ T{ symbol f "foo" } ] [ "#foo" test-Literal ] unit-test
[ T{ symbol f "+" } ] [ "#+" test-Literal ] unit-test
[ T{ symbol f "at:put:" } ] [ "#at:put:" test-Literal ] unit-test
[ T{ symbol f "Hello world" } ] [ "#'Hello world'" test-Literal ] unit-test
[ B{ 1 2 3 4 } ] [ "#[1 2 3 4]" test-Literal ] unit-test
[ { nil t f } ] [ "#(nil true false)" test-Literal ] unit-test
[ { nil { t f } } ] [ "#(nil (true false))" test-Literal ] unit-test
[ T{ ast-block f { } { } } ] [ "[]" test-Literal ] unit-test
[ T{ ast-block f { "x" } { T{ ast-return f T{ ast-name f "x" } } } } ] [ "[ :x|^x]" test-Literal ] unit-test
[ T{ ast-block f { } { T{ ast-return f self } } } ] [ "[^self]" test-Literal ] unit-test

EBNF: test-FormalBlockArgumentDeclarationList
test         = <foreign parse-smalltalk FormalBlockArgumentDeclarationList>
;EBNF

[ V{ "x" "y" "elt" } ] [ ":x :y :elt" test-FormalBlockArgumentDeclarationList ] unit-test

EBNF: test-Operand
test         = <foreign parse-smalltalk Operand>
;EBNF

[ { 123 15.6 { t f } } ] [ "#(123 15.6 (true false))" test-Operand ] unit-test
[ T{ ast-name f "x" } ] [ "x" test-Operand ] unit-test

EBNF: test-Expression
test         = <foreign parse-smalltalk Expression>
;EBNF

[ self ] [ "self" test-Expression ] unit-test
[ { 123 15.6 { t f } } ] [ "#(123 15.6 (true false))" test-Expression ] unit-test
[ T{ ast-name f "x" } ] [ "x" test-Expression ] unit-test
[ T{ ast-message-send f 5 "print" { } } ] [ "5 print" test-Expression ] unit-test
[ T{ ast-message-send f T{ ast-message-send f 5 "squared" { } } "print" { } } ] [ "5 squared print" test-Expression ] unit-test
[ T{ ast-message-send f 2 "+" { 2 } } ] [ "2+2" test-Expression ] unit-test

[
    T{ ast-message-send f
        T{ ast-message-send f 3 "factorial" { } }
        "+"
        { T{ ast-message-send f 4 "factorial" { } } }
    }
]
[ "3 factorial + 4 factorial" test-Expression ] unit-test

[
    T{ ast-message-send f
        T{ ast-message-send f
            T{ ast-message-send f 3 "factorial" { } }
            "+"
            { 4 }
        }
        "factorial"
        { }
    }
]
[ "(3 factorial + 4) factorial" test-Expression ] unit-test
EBNF: test-FinalStatement
test         = <foreign parse-smalltalk FinalStatement>
;EBNF

[ T{ ast-return f T{ ast-name f "value" } } ] [ "value" test-FinalStatement ] unit-test
[ T{ ast-return f T{ ast-name f "value" } } ] [ "^value" test-FinalStatement ] unit-test
[ T{ ast-return f T{ ast-assignment f T{ ast-name f "value" } 5 } } ] [ "value:=5" test-FinalStatement ] unit-test

EBNF: test-LocalVariableDeclarationList
test         = <foreign parse-smalltalk LocalVariableDeclarationList>
;EBNF

[ T{ ast-local-variables f { "i" "j" } } ] [ " |  i j   |" test-LocalVariableDeclarationList ] unit-test


EBNF: test-KeywordMessageSend
test         = <foreign parse-smalltalk KeywordMessageSend>
;EBNF

[ T{ ast-message-send f T{ ast-name f "x" } "foo:bar:" { 1 2 } } ]
[ "x foo:1 bar:2" test-KeywordMessageSend ] unit-test

[
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
]
[ "3 factorial + 4 factorial between: 10 and: 100" test-KeywordMessageSend ] unit-test

[ ] [ "vocab:smalltalk/parser/test.st" ascii file-contents parse-smalltalk drop ] unit-test
