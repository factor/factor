USING: eval multiline sequences tools.test ;
IN: multiline::tests

STRING: test-it
foo
bar

;

{ "foo\nbar\n" } [ test-it ] unit-test

/*
<<
SYNTAX: MULTILINE-LITERAL: parse-here suffix! ;
>>

{ { "bar" } }
[
    CONSTANT: foo { MULTILINE-LITERAL:
bar
;
} foo
] unit-test

! Make sure parse-here fails if extra crap appears on the first line
[
    "CONSTANT: foo { MULTILINE-LITERAL: asdfasfdasdfas
bar
;
}" eval
] must-fail
*/
