USING: smalltalk.compiler.lexenv tools.test kernel namespaces accessors ;
IN: smalltalk.compiler.lexenv.tests

TUPLE: some-class x y z ;

SYMBOL: fake-self

SYMBOL: fake-local

<lexenv>
    some-class >>class
    fake-self >>self
    H{ { "mumble" fake-local } } >>local-readers
    H{ { "jumble" fake-local } } >>local-writers
lexenv set

[ [ fake-local ] ] [ "mumble" lexenv get lookup-reader ] unit-test
[ [ fake-self x>> ] ] [ "x" lexenv get lookup-reader ] unit-test
[ [ \ tuple ] ] [ "Object" lexenv get lookup-reader ] unit-test

[ [ fake-local ] ] [ "jumble" lexenv get lookup-writer ] unit-test
[ [ fake-self (>>y) ] ] [ "y" lexenv get lookup-writer ] unit-test

[ "blahblah" lexenv get lookup-writer ] must-fail