USING: regexp tools.test kernel ;
IN: regexp-tests

[ f ] [ "b" "a*" f <regexp> matches? ] unit-test
[ t ] [ "" "a*" f <regexp> matches? ] unit-test
[ t ] [ "a" "a*" f <regexp> matches? ] unit-test
[ t ] [ "aaaaaaa" "a*" f <regexp> matches? ] unit-test
[ f ] [ "ab" "a*" f <regexp> matches? ] unit-test

[ t ] [ "abc" "abc" f <regexp> matches? ] unit-test
[ t ] [ "a" "a|b|c" f <regexp> matches? ] unit-test
[ t ] [ "b" "a|b|c" f <regexp> matches? ] unit-test
[ t ] [ "c" "a|b|c" f <regexp> matches? ] unit-test
[ f ] [ "c" "d|e|f" f <regexp> matches? ] unit-test

[ f ] [ "aa" "a|b|c" f <regexp> matches? ] unit-test
[ f ] [ "bb" "a|b|c" f <regexp> matches? ] unit-test
[ f ] [ "cc" "a|b|c" f <regexp> matches? ] unit-test
[ f ] [ "cc" "d|e|f" f <regexp> matches? ] unit-test

[ f ] [ "" "a+" f <regexp> matches? ] unit-test
[ t ] [ "a" "a+" f <regexp> matches? ] unit-test
[ t ] [ "aa" "a+" f <regexp> matches? ] unit-test

[ t ] [ "" "a?" f <regexp> matches? ] unit-test
[ t ] [ "a" "a?" f <regexp> matches? ] unit-test
[ f ] [ "aa" "a?" f <regexp> matches? ] unit-test

[ f ] [ "" "." f <regexp> matches? ] unit-test
[ t ] [ "a" "." f <regexp> matches? ] unit-test
[ t ] [ "." "." f <regexp> matches? ] unit-test
! [ f ] [ "\n" "." f <regexp> matches? ] unit-test

[ f ] [ "" ".+" f <regexp> matches? ] unit-test
[ t ] [ "a" ".+" f <regexp> matches? ] unit-test
[ t ] [ "ab" ".+" f <regexp> matches? ] unit-test

[ t ] [ "" "a|b*|c+|d?" f <regexp> matches? ] unit-test
[ t ] [ "a" "a|b*|c+|d?" f <regexp> matches? ] unit-test
[ t ] [ "c" "a|b*|c+|d?" f <regexp> matches? ] unit-test
[ t ] [ "cc" "a|b*|c+|d?" f <regexp> matches? ] unit-test
[ f ] [ "ccd" "a|b*|c+|d?" f <regexp> matches? ] unit-test
[ t ] [ "d" "a|b*|c+|d?" f <regexp> matches? ] unit-test

[ t ] [ "foo" "foo|bar" f <regexp> matches? ] unit-test
[ t ] [ "bar" "foo|bar" f <regexp> matches? ] unit-test
[ f ] [ "foobar" "foo|bar" f <regexp> matches? ] unit-test

[ f ] [ "" "(a)" f <regexp> matches? ] unit-test
[ t ] [ "a" "(a)" f <regexp> matches? ] unit-test
[ f ] [ "aa" "(a)" f <regexp> matches? ] unit-test
[ t ] [ "aa" "(a*)" f <regexp> matches? ] unit-test

[ f ] [ "aababaaabbac" "(a|b)+" f <regexp> matches? ] unit-test
[ t ] [ "ababaaabba" "(a|b)+" f <regexp> matches? ] unit-test

[ f ] [ "" "a{1}" f <regexp> matches? ] unit-test
[ t ] [ "a" "a{1}" f <regexp> matches? ] unit-test
[ f ] [ "aa" "a{1}" f <regexp> matches? ] unit-test

[ f ] [ "a" "a{2,}" f <regexp> matches? ] unit-test
[ t ] [ "aaa" "a{2,}" f <regexp> matches? ] unit-test
[ t ] [ "aaaa" "a{2,}" f <regexp> matches? ] unit-test
[ t ] [ "aaaaa" "a{2,}" f <regexp> matches? ] unit-test

[ t ] [ "" "a{,2}" f <regexp> matches? ] unit-test
[ t ] [ "a" "a{,2}" f <regexp> matches? ] unit-test
[ t ] [ "aa" "a{,2}" f <regexp> matches? ] unit-test
[ f ] [ "aaa" "a{,2}" f <regexp> matches? ] unit-test
[ f ] [ "aaaa" "a{,2}" f <regexp> matches? ] unit-test
[ f ] [ "aaaaa" "a{,2}" f <regexp> matches? ] unit-test

[ f ] [ "" "a{1,3}" f <regexp> matches? ] unit-test
[ t ] [ "a" "a{1,3}" f <regexp> matches? ] unit-test
[ t ] [ "aa" "a{1,3}" f <regexp> matches? ] unit-test
[ t ] [ "aaa" "a{1,3}" f <regexp> matches? ] unit-test
[ f ] [ "aaaa" "a{1,3}" f <regexp> matches? ] unit-test

[ f ] [ "" "[a]" f <regexp> matches? ] unit-test
[ t ] [ "a" "[a]" f <regexp> matches? ] unit-test
[ t ] [ "a" "[abc]" f <regexp> matches? ] unit-test
[ f ] [ "b" "[a]" f <regexp> matches? ] unit-test
[ f ] [ "d" "[abc]" f <regexp> matches? ] unit-test
[ t ] [ "ab" "[abc]{1,2}" f <regexp> matches? ] unit-test
[ f ] [ "abc" "[abc]{1,2}" f <regexp> matches? ] unit-test

[ f ] [ "" "[^a]" f <regexp> matches? ] unit-test
[ f ] [ "a" "[^a]" f <regexp> matches? ] unit-test
[ f ] [ "a" "[^abc]" f <regexp> matches? ] unit-test
[ t ] [ "b" "[^a]" f <regexp> matches? ] unit-test
[ t ] [ "d" "[^abc]" f <regexp> matches? ] unit-test
[ f ] [ "ab" "[^abc]{1,2}" f <regexp> matches? ] unit-test
[ f ] [ "abc" "[^abc]{1,2}" f <regexp> matches? ] unit-test

[ t ] [ "]" "[]]" f <regexp> matches? ] unit-test
[ f ] [ "]" "[^]]" f <regexp> matches? ] unit-test

! [ "^" "[^]" f <regexp> matches? ] unit-test-fails
[ t ] [ "^" "[]^]" f <regexp> matches? ] unit-test
[ t ] [ "]" "[]^]" f <regexp> matches? ] unit-test

[ t ] [ "[" "[[]" f <regexp> matches? ] unit-test
[ f ] [ "^" "[^^]" f <regexp> matches? ] unit-test
[ t ] [ "a" "[^^]" f <regexp> matches? ] unit-test

[ t ] [ "-" "[-]" f <regexp> matches? ] unit-test
[ f ] [ "a" "[-]" f <regexp> matches? ] unit-test
[ f ] [ "-" "[^-]" f <regexp> matches? ] unit-test
[ t ] [ "a" "[^-]" f <regexp> matches? ] unit-test

[ t ] [ "-" "[-a]" f <regexp> matches? ] unit-test
[ t ] [ "a" "[-a]" f <regexp> matches? ] unit-test
[ t ] [ "-" "[a-]" f <regexp> matches? ] unit-test
[ t ] [ "a" "[a-]" f <regexp> matches? ] unit-test
[ f ] [ "b" "[a-]" f <regexp> matches? ] unit-test
[ f ] [ "-" "[^-]" f <regexp> matches? ] unit-test
[ t ] [ "a" "[^-]" f <regexp> matches? ] unit-test

[ f ] [ "-" "[a-c]" f <regexp> matches? ] unit-test
[ t ] [ "-" "[^a-c]" f <regexp> matches? ] unit-test
[ t ] [ "b" "[a-c]" f <regexp> matches? ] unit-test
[ f ] [ "b" "[^a-c]" f <regexp> matches? ] unit-test

[ t ] [ "-" "[a-c-]" f <regexp> matches? ] unit-test
[ f ] [ "-" "[^a-c-]" f <regexp> matches? ] unit-test

[ t ] [ "\\" "[\\\\]" f <regexp> matches? ] unit-test
[ f ] [ "a" "[\\\\]" f <regexp> matches? ] unit-test
[ f ] [ "\\" "[^\\\\]" f <regexp> matches? ] unit-test
[ t ] [ "a" "[^\\\\]" f <regexp> matches? ] unit-test

[ t ] [ "0" "[\\d]" f <regexp> matches? ] unit-test
[ f ] [ "a" "[\\d]" f <regexp> matches? ] unit-test
[ f ] [ "0" "[^\\d]" f <regexp> matches? ] unit-test
[ t ] [ "a" "[^\\d]" f <regexp> matches? ] unit-test

[ t ] [ "a" "[a-z]{1,}|[A-Z]{2,4}|b*|c|(f|g)*" f <regexp> matches? ] unit-test
[ t ] [ "a" "[a-z]{1,2}|[A-Z]{3,3}|b*|c|(f|g)*" f <regexp> matches? ] unit-test
[ t ] [ "a" "[a-z]{1,2}|[A-Z]{3,3}" f <regexp> matches? ] unit-test

[ t ] [ "1000" "\\d{4,6}" f <regexp> matches? ] unit-test
[ t ] [ "1000" "[0-9]{4,6}" f <regexp> matches? ] unit-test

[ t ] [ "abc" "\\p{Lower}{3}" f <regexp> matches? ] unit-test
[ f ] [ "ABC" "\\p{Lower}{3}" f <regexp> matches? ] unit-test
[ t ] [ "ABC" "\\p{Upper}{3}" f <regexp> matches? ] unit-test
[ f ] [ "abc" "\\p{Upper}{3}" f <regexp> matches? ] unit-test

[ f ] [ "abc" "[\\p{Upper}]{3}" f <regexp> matches? ] unit-test
[ t ] [ "ABC" "[\\p{Upper}]{3}" f <regexp> matches? ] unit-test

[ t ] [ "" "\\Q\\E" f <regexp> matches? ] unit-test
[ f ] [ "a" "\\Q\\E" f <regexp> matches? ] unit-test
[ t ] [ "|*+" "\\Q|*+\\E" f <regexp> matches? ] unit-test
[ f ] [ "abc" "\\Q|*+\\E" f <regexp> matches? ] unit-test

[ t ] [ "S" "\\0123" f <regexp> matches? ] unit-test
[ t ] [ "SXY" "\\0123XY" f <regexp> matches? ] unit-test
[ t ] [ "x" "\\x78" f <regexp> matches? ] unit-test
[ f ] [ "y" "\\x78" f <regexp> matches? ] unit-test
[ t ] [ "x" "\\u0078" f <regexp> matches? ] unit-test
[ f ] [ "y" "\\u0078" f <regexp> matches? ] unit-test

[ t ] [ "ab" "a+b" f <regexp> matches? ] unit-test
[ f ] [ "b" "a+b" f <regexp> matches? ] unit-test
[ t ] [ "aab" "a+b" f <regexp> matches? ] unit-test
[ f ] [ "abb" "a+b" f <regexp> matches? ] unit-test

[ t ] [ "abbbb" "ab*" f <regexp> matches? ] unit-test
[ t ] [ "a" "ab*" f <regexp> matches? ] unit-test
[ f ] [ "abab" "ab*" f <regexp> matches? ] unit-test

[ f ] [ "x" "\\." f <regexp> matches? ] unit-test
[ t ] [ "." "\\." f <regexp> matches? ] unit-test

[ t ] [ "aaaab" "a+ab" f <regexp> matches? ] unit-test
[ f ] [ "aaaxb" "a+ab" f <regexp> matches? ] unit-test
[ t ] [ "aaacb" "a+cb" f <regexp> matches? ] unit-test
[ f ] [ "aaaab" "a++ab" f <regexp> matches? ] unit-test
[ t ] [ "aaacb" "a++cb" f <regexp> matches? ] unit-test

[ 3 ] [ "aaacb" "a*" f <regexp> match-head ] unit-test
[ 1 ] [ "aaacb" "a+?" f <regexp> match-head ] unit-test
[ 2 ] [ "aaacb" "aa?" f <regexp> match-head ] unit-test
[ 1 ] [ "aaacb" "aa??" f <regexp> match-head ] unit-test
[ 3 ] [ "aacb" "aa?c" f <regexp> match-head ] unit-test
[ 3 ] [ "aacb" "aa??c" f <regexp> match-head ] unit-test

[ t ] [ "aaa" "AAA" t <regexp> matches? ] unit-test
[ f ] [ "aax" "AAA" t <regexp> matches? ] unit-test
[ t ] [ "aaa" "A*" t <regexp> matches? ] unit-test
[ f ] [ "aaba" "A*" t <regexp> matches? ] unit-test
[ t ] [ "b" "[AB]" t <regexp> matches? ] unit-test
[ f ] [ "c" "[AB]" t <regexp> matches? ] unit-test
[ t ] [ "c" "[A-Z]" t <regexp> matches? ] unit-test
[ f ] [ "3" "[A-Z]" t <regexp> matches? ] unit-test

[ ] [ 
    "(0[lL]?|[1-9]\\d{0,9}(\\d{0,9}[lL])?|0[xX]\\p{XDigit}{1,8}(\\p{XDigit}{0,8}[lL])?|0[0-7]{1,11}([0-7]{0,11}[lL])?|([0-9]+\\.[0-9]*|\\.[0-9]+)([eE][+-]?[0-9]+)?[fFdD]?|[0-9]+([eE][+-]?[0-9]+[fFdD]?|([eE][+-]?[0-9]+)?[fFdD]))"
    f <regexp> drop
] unit-test

[ t ] [ "fxxbar" "(?!foo).{3}bar" f <regexp> matches? ] unit-test
[ f ] [ "foobar" "(?!foo).{3}bar" f <regexp> matches? ] unit-test

[ 3 ] [ "foobar" "foo(?=bar)" f <regexp> match-head ] unit-test
[ f ] [ "foobxr" "foo(?=bar)" f <regexp> match-head ] unit-test

[ f ] [ "foobxr" "foo\\z" f <regexp> match-head ] unit-test
[ 3 ] [ "foo" "foo\\z" f <regexp> match-head ] unit-test

[ 3 ] [ "foo bar" "foo\\b" f <regexp> match-head ] unit-test
[ f ] [ "fooxbar" "foo\\b" f <regexp> matches? ] unit-test
[ t ] [ "foo" "foo\\b" f <regexp> matches? ] unit-test
[ t ] [ "foo bar" "foo\\b bar" f <regexp> matches? ] unit-test
[ f ] [ "fooxbar" "foo\\bxbar" f <regexp> matches? ] unit-test
[ f ] [ "foo" "foo\\bbar" f <regexp> matches? ] unit-test

[ f ] [ "foo bar" "foo\\B" f <regexp> matches? ] unit-test
[ 3 ] [ "fooxbar" "foo\\B" f <regexp> match-head ] unit-test
[ t ] [ "foo" "foo\\B" f <regexp> matches? ] unit-test
[ f ] [ "foo bar" "foo\\B bar" f <regexp> matches? ] unit-test
[ t ] [ "fooxbar" "foo\\Bxbar" f <regexp> matches? ] unit-test
[ f ] [ "foo" "foo\\Bbar" f <regexp> matches? ] unit-test
