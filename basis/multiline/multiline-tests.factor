USING: eval multiline sequences tools.test ;
IN: multiline.tests

STRING: test-it
foo
bar

;

{ "foo\nbar\n" } [ test-it ] unit-test


! HEREDOC:

{ "foo\nbar\n" } [ HEREDOC: END
foo
bar
END
] unit-test

{ "" } [ HEREDOC: END
END
] unit-test

{ " END\n" } [ HEREDOC: END
 END
END
] unit-test

{ "\n" } [ HEREDOC: END

END
] unit-test

{ "x\n" } [ HEREDOC: END
x
END
] unit-test

{ "x\n" } [ HEREDOC:       END
x
END
] unit-test

! there's a space after xyz
{ "xyz \n" } [ HEREDOC: END
xyz 
END
] unit-test

{ "} ! * # \" «\n" } [ HEREDOC: END
} ! * # " «
END
] unit-test

{ 21 "foo\nbar\n" " HEREDOC: FOO\n FOO\n" 22 } [ 21 HEREDOC: X
foo
bar
X
HEREDOC: END
 HEREDOC: FOO
 FOO
END
22 ] unit-test

{ "lol\n xyz\n" }
[
HEREDOC: xyz
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
