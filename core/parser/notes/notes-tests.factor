USING: lexer namespaces parser.notes source-files tools.test ;
IN: parser.notes.tests

{ } [ f lexer set f current-source-file set "Hello world" note. ] unit-test
