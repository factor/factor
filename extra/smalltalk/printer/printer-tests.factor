USING: smalltalk.printer tools.test ;

{ "#((1 2) 'hi')" } [ { { 1 2 } "hi" } smalltalk>string ] unit-test
