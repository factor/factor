USING: regexp4 tools.test kernel ;
IN: regexp4-tests

[ f ] [ "b" "a*" <regexp> matches? ] unit-test
[ t ] [ "" "a*" <regexp> matches? ] unit-test
[ t ] [ "a" "a*" <regexp> matches? ] unit-test
[ t ] [ "aaaaaaa" "a*"  <regexp> matches? ] unit-test
[ f ] [ "ab" "a*" <regexp> matches? ] unit-test

[ t ] [ "abc" "abc" <regexp> matches? ] unit-test
[ t ] [ "a" "a|b|c" <regexp> matches? ] unit-test
[ t ] [ "b" "a|b|c" <regexp> matches? ] unit-test
[ t ] [ "c" "a|b|c" <regexp> matches? ] unit-test
[ f ] [ "c" "d|e|f" <regexp> matches? ] unit-test

[ f ] [ "aa" "a|b|c" <regexp> matches? ] unit-test
[ f ] [ "bb" "a|b|c" <regexp> matches? ] unit-test
[ f ] [ "cc" "a|b|c" <regexp> matches? ] unit-test
[ f ] [ "cc" "d|e|f" <regexp> matches? ] unit-test

[ f ] [ "" "a+" <regexp> matches? ] unit-test
[ t ] [ "a" "a+" <regexp> matches? ] unit-test
[ t ] [ "aa" "a+" <regexp> matches? ] unit-test

[ t ] [ "" "a?" <regexp> matches? ] unit-test
[ t ] [ "a" "a?" <regexp> matches? ] unit-test
[ f ] [ "aa" "a?" <regexp> matches? ] unit-test

[ f ] [ "" "." <regexp> matches? ] unit-test
[ t ] [ "a" "." <regexp> matches? ] unit-test
[ t ] [ "." "." <regexp> matches? ] unit-test
! [ f ] [ "\n" "." <regexp> matches? ] unit-test

[ f ] [ "" ".+" <regexp> matches? ] unit-test
[ t ] [ "a" ".+" <regexp> matches? ] unit-test
[ t ] [ "ab" ".+" <regexp> matches? ] unit-test


[ t ] [ "" "a|b*|c+|d?" <regexp> matches? ] unit-test
[ t ] [ "a" "a|b*|c+|d?" <regexp> matches? ] unit-test
[ t ] [ "c" "a|b*|c+|d?" <regexp> matches? ] unit-test
[ t ] [ "cc" "a|b*|c+|d?" <regexp> matches? ] unit-test
[ f ] [ "ccd" "a|b*|c+|d?" <regexp> matches? ] unit-test
[ t ] [ "d" "a|b*|c+|d?" <regexp> matches? ] unit-test

[ t ] [ "foo" "foo|bar" <regexp> matches? ] unit-test
[ t ] [ "bar" "foo|bar" <regexp> matches? ] unit-test
[ f ] [ "foobar" "foo|bar" <regexp> matches? ] unit-test

[ f ] [ "" "(a)" <regexp> matches? ] unit-test
[ t ] [ "a" "(a)" <regexp> matches? ] unit-test
[ f ] [ "aa" "(a)" <regexp> matches? ] unit-test
[ t ] [ "aa" "(a*)" <regexp> matches? ] unit-test

[ f ] [ "aababaaabbac" "(a|b)+" <regexp> matches? ] unit-test
[ t ] [ "ababaaabba" "(a|b)+" <regexp> matches? ] unit-test

[ f ] [ "" "a{1}" <regexp> matches? ] unit-test
[ t ] [ "a" "a{1}" <regexp> matches? ] unit-test
[ f ] [ "aa" "a{1}" <regexp> matches? ] unit-test

[ f ] [ "a" "a{2,}" <regexp> matches? ] unit-test
[ t ] [ "aaa" "a{2,}" <regexp> matches? ] unit-test
[ t ] [ "aaaa" "a{2,}" <regexp> matches? ] unit-test
[ t ] [ "aaaaa" "a{2,}" <regexp> matches? ] unit-test

[ t ] [ "" "a{,2}" <regexp> matches? ] unit-test
[ t ] [ "a" "a{,2}" <regexp> matches? ] unit-test
[ t ] [ "aa" "a{,2}" <regexp> matches? ] unit-test
[ f ] [ "aaa" "a{,2}" <regexp> matches? ] unit-test
[ f ] [ "aaaa" "a{,2}" <regexp> matches? ] unit-test
[ f ] [ "aaaaa" "a{,2}" <regexp> matches? ] unit-test

[ f ] [ "" "a{1,3}" <regexp> matches? ] unit-test
[ t ] [ "a" "a{1,3}" <regexp> matches? ] unit-test
[ t ] [ "aa" "a{1,3}" <regexp> matches? ] unit-test
[ t ] [ "aaa" "a{1,3}" <regexp> matches? ] unit-test
[ f ] [ "aaaa" "a{1,3}" <regexp> matches? ] unit-test

! [ f ] [ "" "[a]" <regexp> matches? ] unit-test
! [ t ] [ "a" "[a]" <regexp> matches? ] unit-test
! [ t ] [ "a" "[abc]" <regexp> matches? ] unit-test
! [ f ] [ "b" "[a]" <regexp> matches? ] unit-test
! [ f ] [ "d" "[abc]" <regexp> matches? ] unit-test
! [ t ] [ "ab" "[abc]{1,2}" <regexp> matches? ] unit-test
! [ f ] [ "abc" "[abc]{1,2}" <regexp> matches? ] unit-test

! [ f ] [ "" "[^a]" <regexp> matches? ] unit-test
! [ f ] [ "a" "[^a]" <regexp> matches? ] unit-test
! [ f ] [ "a" "[^abc]" <regexp> matches? ] unit-test
! [ t ] [ "b" "[^a]" <regexp> matches? ] unit-test
! [ t ] [ "d" "[^abc]" <regexp> matches? ] unit-test
! [ f ] [ "ab" "[^abc]{1,2}" <regexp> matches? ] unit-test
! [ f ] [ "abc" "[^abc]{1,2}" <regexp> matches? ] unit-test

! [ t ] [ "]" "[]]" <regexp> matches? ] unit-test
! [ f ] [ "]" "[^]]" <regexp> matches? ] unit-test

! [ "^" "[^]" <regexp> matches? ] must-fail
! [ t ] [ "^" "[]^]" <regexp> matches? ] unit-test
! [ t ] [ "]" "[]^]" <regexp> matches? ] unit-test

! [ t ] [ "[" "[[]" <regexp> matches? ] unit-test
! [ f ] [ "^" "[^^]" <regexp> matches? ] unit-test
! [ t ] [ "a" "[^^]" <regexp> matches? ] unit-test

! [ t ] [ "-" "[-]" <regexp> matches? ] unit-test
! [ f ] [ "a" "[-]" <regexp> matches? ] unit-test
! [ f ] [ "-" "[^-]" <regexp> matches? ] unit-test
! [ t ] [ "a" "[^-]" <regexp> matches? ] unit-test

! [ t ] [ "-" "[-a]" <regexp> matches? ] unit-test
! [ t ] [ "a" "[-a]" <regexp> matches? ] unit-test
! [ t ] [ "-" "[a-]" <regexp> matches? ] unit-test
! [ t ] [ "a" "[a-]" <regexp> matches? ] unit-test
! [ f ] [ "b" "[a-]" <regexp> matches? ] unit-test
! [ f ] [ "-" "[^-]" <regexp> matches? ] unit-test
! [ t ] [ "a" "[^-]" <regexp> matches? ] unit-test

! [ f ] [ "-" "[a-c]" <regexp> matches? ] unit-test
! [ t ] [ "-" "[^a-c]" <regexp> matches? ] unit-test
! [ t ] [ "b" "[a-c]" <regexp> matches? ] unit-test
! [ f ] [ "b" "[^a-c]" <regexp> matches? ] unit-test

! [ t ] [ "-" "[a-c-]" <regexp> matches? ] unit-test
! [ f ] [ "-" "[^a-c-]" <regexp> matches? ] unit-test

! [ t ] [ "\\" "[\\\\]" <regexp> matches? ] unit-test
! [ f ] [ "a" "[\\\\]" <regexp> matches? ] unit-test
! [ f ] [ "\\" "[^\\\\]" <regexp> matches? ] unit-test
! [ t ] [ "a" "[^\\\\]" <regexp> matches? ] unit-test


! ((A)(B(C)))
! 1.  ((A)(B(C)))
! 2. (A)
! 3. (B(C))
! 4. (C) 
