USING: eval multiline sequences tools.test ;
IN: multiline.tests

STRING: test-it
foo
bar

;

{ "foo\nbar\n" } [ test-it ] unit-test


! heredoc:

{ "foo\nbar\n" } [ heredoc: END
foo
bar
END
] unit-test

{ "" } [ heredoc: END
END
] unit-test

{ " END\n" } [ heredoc: END
 END
END
] unit-test

{ "\n" } [ heredoc: END

END
] unit-test

{ "x\n" } [ heredoc: END
x
END
] unit-test

{ "x\n" } [ heredoc:       END
x
END
] unit-test

! there's a space after xyz
{ "xyz \n" } [ heredoc: END
xyz 
END
] unit-test

{ "} ! * # \" «\n" } [ heredoc: END
} ! * # " «
END
] unit-test

{ 21 "foo\nbar\n" " heredoc: FOO\n FOO\n" 22 } [ 21 heredoc: X
foo
bar
X
heredoc: END
 heredoc: FOO
 FOO
END
22 ] unit-test

{ "lol\n xyz\n" }
[
heredoc: xyz
lol
 xyz
xyz
] unit-test

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
