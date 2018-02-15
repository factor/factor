USING: 24-game io.streams.string kernel math sequences
tools.test ;

{ t } [ make-24 first4 makes-24? ] unit-test

{ f } [ (operators) "hello" find-operator ] unit-test

{ + } [ "+" [ (operators) get-operator ] with-string-reader ] unit-test

{ swap } [
    "bad\ninput\nswap" [ (operators) get-operator ] with-string-reader
] unit-test
