USING: multiline tools.test ;
IN: multiline.tests

STRING: test-it
foo
bar

;

[ "foo\nbar\n" ] [ test-it ] unit-test
[ "foo\nbar\n" ] [ <" foo
bar
"> ] unit-test

[ "hello\nworld" ] [ <" hello
world"> ] unit-test

[ "hello" "world" ] [ <" hello"> <" world"> ] unit-test

[ "\nhi" ] [ <"
hi"> ] unit-test


! HEREDOC:

[ "foo\nbar\n" ] [ HEREDOC: END
foo
bar
END ] unit-test

[ "foo\nbar" ] [ HEREDOC: END
foo
barEND ] unit-test

[ "" ] [ HEREDOC: END
END ] unit-test

[ " " ] [ HEREDOC: END
 END ] unit-test

[ "\n" ] [ HEREDOC: END

END ] unit-test

[ "x" ] [ HEREDOC: END
xEND ] unit-test

[ "xyz " ] [ HEREDOC: END
xyz END ] unit-test

[ "} ! * # \" «\n" ] [ HEREDOC: END
} ! * # " «
END ] unit-test

[ 21 "foo\nbar" " HEREDOC: FOO\n FOO\n" 22 ] [ 21 HEREDOC: X
foo
barX HEREDOC: END ! mumble
 HEREDOC: FOO
 FOO
END 22 ] unit-test

