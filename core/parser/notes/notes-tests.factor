USING: lexer namespaces parser.notes source-files tools.test ;

{ } [ f lexer set f current-source-file set "Hello world" note. ] unit-test
