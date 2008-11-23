USING: regexp tools.test kernel sequences regexp.parser
regexp.traversal eval strings ;
IN: regexp-tests

\ <regexp> must-infer
\ matches? must-infer

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

[ t ] [ "b" "|b" <regexp> matches? ] unit-test
[ t ] [ "b" "b|" <regexp> matches? ] unit-test
[ t ] [ "" "b|" <regexp> matches? ] unit-test
[ t ] [ "" "b|" <regexp> matches? ] unit-test
[ f ] [ "" "|" <regexp> matches? ] unit-test
[ f ] [ "" "|||||||" <regexp> matches? ] unit-test

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

! Dotall mode -- when on, . matches newlines.
! Off by default.
[ f ] [ "\n" "." <regexp> matches? ] unit-test
[ t ] [ "\n" "(?s)." <regexp> matches? ] unit-test
[ f ] [ "\n\n" "(?s).(?-s)." <regexp> matches? ] unit-test

[ f ] [ "" ".+" <regexp> matches? ] unit-test
[ t ] [ "a" ".+" <regexp> matches? ] unit-test
[ t ] [ "ab" ".+" <regexp> matches? ] unit-test

[ t ] [ " " "[\\s]" <regexp> matches? ] unit-test
[ f ] [ "a" "[\\s]" <regexp> matches? ] unit-test
[ f ] [ " " "[\\S]" <regexp> matches? ] unit-test
[ t ] [ "a" "[\\S]" <regexp> matches? ] unit-test
[ f ] [ " " "[\\w]" <regexp> matches? ] unit-test
[ t ] [ "a" "[\\w]" <regexp> matches? ] unit-test
[ t ] [ " " "[\\W]" <regexp> matches? ] unit-test
[ f ] [ "a" "[\\W]" <regexp> matches? ] unit-test

[ t ] [ "/" "\\/" <regexp> matches? ] unit-test

[ t ] [ "a" R' a'i matches? ] unit-test

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

[ f ] [ "" "[a]" <regexp> matches? ] unit-test
[ t ] [ "a" "[a]" <regexp> matches? ] unit-test
[ t ] [ "a" "[abc]" <regexp> matches? ] unit-test
[ f ] [ "b" "[a]" <regexp> matches? ] unit-test
[ f ] [ "d" "[abc]" <regexp> matches? ] unit-test
[ t ] [ "ab" "[abc]{1,2}" <regexp> matches? ] unit-test
[ f ] [ "abc" "[abc]{1,2}" <regexp> matches? ] unit-test

[ f ] [ "" "[^a]" <regexp> matches? ] unit-test
[ f ] [ "a" "[^a]" <regexp> matches? ] unit-test
[ f ] [ "a" "[^abc]" <regexp> matches? ] unit-test
[ t ] [ "b" "[^a]" <regexp> matches? ] unit-test
[ t ] [ "d" "[^abc]" <regexp> matches? ] unit-test
[ f ] [ "ab" "[^abc]{1,2}" <regexp> matches? ] unit-test
[ f ] [ "abc" "[^abc]{1,2}" <regexp> matches? ] unit-test

[ t ] [ "]" "[]]" <regexp> matches? ] unit-test
[ f ] [ "]" "[^]]" <regexp> matches? ] unit-test
[ t ] [ "a" "[^]]" <regexp> matches? ] unit-test

[ "^" "[^]" <regexp> matches? ] must-fail
[ t ] [ "^" "[]^]" <regexp> matches? ] unit-test
[ t ] [ "]" "[]^]" <regexp> matches? ] unit-test

[ t ] [ "[" "[[]" <regexp> matches? ] unit-test
[ f ] [ "^" "[^^]" <regexp> matches? ] unit-test
[ t ] [ "a" "[^^]" <regexp> matches? ] unit-test

[ t ] [ "-" "[-]" <regexp> matches? ] unit-test
[ f ] [ "a" "[-]" <regexp> matches? ] unit-test
[ f ] [ "-" "[^-]" <regexp> matches? ] unit-test
[ t ] [ "a" "[^-]" <regexp> matches? ] unit-test

[ t ] [ "-" "[-a]" <regexp> matches? ] unit-test
[ t ] [ "a" "[-a]" <regexp> matches? ] unit-test
[ t ] [ "-" "[a-]" <regexp> matches? ] unit-test
[ t ] [ "a" "[a-]" <regexp> matches? ] unit-test
[ f ] [ "b" "[a-]" <regexp> matches? ] unit-test
[ f ] [ "-" "[^-]" <regexp> matches? ] unit-test
[ t ] [ "a" "[^-]" <regexp> matches? ] unit-test

[ f ] [ "-" "[a-c]" <regexp> matches? ] unit-test
[ t ] [ "-" "[^a-c]" <regexp> matches? ] unit-test
[ t ] [ "b" "[a-c]" <regexp> matches? ] unit-test
[ f ] [ "b" "[^a-c]" <regexp> matches? ] unit-test

[ t ] [ "-" "[a-c-]" <regexp> matches? ] unit-test
[ f ] [ "-" "[^a-c-]" <regexp> matches? ] unit-test

[ t ] [ "\\" "[\\\\]" <regexp> matches? ] unit-test
[ f ] [ "a" "[\\\\]" <regexp> matches? ] unit-test
[ f ] [ "\\" "[^\\\\]" <regexp> matches? ] unit-test
[ t ] [ "a" "[^\\\\]" <regexp> matches? ] unit-test

[ t ] [ "0" "[\\d]" <regexp> matches? ] unit-test
[ f ] [ "a" "[\\d]" <regexp> matches? ] unit-test
[ f ] [ "0" "[^\\d]" <regexp> matches? ] unit-test
[ t ] [ "a" "[^\\d]" <regexp> matches? ] unit-test

[ t ] [ "a" "[a-z]{1,}|[A-Z]{2,4}|b*|c|(f|g)*" <regexp> matches? ] unit-test
[ t ] [ "a" "[a-z]{1,2}|[A-Z]{3,3}|b*|c|(f|g)*" <regexp> matches? ] unit-test
[ t ] [ "a" "[a-z]{1,2}|[A-Z]{3,3}" <regexp> matches? ] unit-test

[ t ] [ "1000" "\\d{4,6}" <regexp> matches? ] unit-test
[ t ] [ "1000" "[0-9]{4,6}" <regexp> matches? ] unit-test

[ t ] [ "abc" "\\p{Lower}{3}" <regexp> matches? ] unit-test
[ f ] [ "ABC" "\\p{Lower}{3}" <regexp> matches? ] unit-test
[ t ] [ "ABC" "\\p{Upper}{3}" <regexp> matches? ] unit-test
[ f ] [ "abc" "\\p{Upper}{3}" <regexp> matches? ] unit-test
[ f ] [ "abc" "[\\p{Upper}]{3}" <regexp> matches? ] unit-test
[ t ] [ "ABC" "[\\p{Upper}]{3}" <regexp> matches? ] unit-test

[ f ] [ "" "\\Q\\E" <regexp> matches? ] unit-test
[ f ] [ "a" "\\Q\\E" <regexp> matches? ] unit-test
[ t ] [ "|*+" "\\Q|*+\\E" <regexp> matches? ] unit-test
[ f ] [ "abc" "\\Q|*+\\E" <regexp> matches? ] unit-test
[ t ] [ "s" "\\Qs\\E" <regexp> matches? ] unit-test

[ t ] [ "S" "\\0123" <regexp> matches? ] unit-test
[ t ] [ "SXY" "\\0123XY" <regexp> matches? ] unit-test
[ t ] [ "x" "\\x78" <regexp> matches? ] unit-test
[ f ] [ "y" "\\x78" <regexp> matches? ] unit-test
[ t ] [ "x" "\\u000078" <regexp> matches? ] unit-test
[ f ] [ "y" "\\u000078" <regexp> matches? ] unit-test

[ t ] [ "ab" "a+b" <regexp> matches? ] unit-test
[ f ] [ "b" "a+b" <regexp> matches? ] unit-test
[ t ] [ "aab" "a+b" <regexp> matches? ] unit-test
[ f ] [ "abb" "a+b" <regexp> matches? ] unit-test

[ t ] [ "abbbb" "ab*" <regexp> matches? ] unit-test
[ t ] [ "a" "ab*" <regexp> matches? ] unit-test
[ f ] [ "abab" "ab*" <regexp> matches? ] unit-test

[ f ] [ "x" "\\." <regexp> matches? ] unit-test
[ t ] [ "." "\\." <regexp> matches? ] unit-test

[ t ] [ "aaaab" "a+ab" <regexp> matches? ] unit-test
[ f ] [ "aaaxb" "a+ab" <regexp> matches? ] unit-test
[ t ] [ "aaacb" "a+cb" <regexp> matches? ] unit-test

[ 3 ] [ "aaacb" "a*" <regexp> match-head ] unit-test
[ 2 ] [ "aaacb" "aa?" <regexp> match-head ] unit-test

[ t ] [ "aaa" "AAA" <iregexp> matches? ] unit-test
[ f ] [ "aax" "AAA" <iregexp> matches? ] unit-test
[ t ] [ "aaa" "A*" <iregexp> matches? ] unit-test
[ f ] [ "aaba" "A*" <iregexp> matches? ] unit-test
[ t ] [ "b" "[AB]" <iregexp> matches? ] unit-test
[ f ] [ "c" "[AB]" <iregexp> matches? ] unit-test
[ t ] [ "c" "[A-Z]" <iregexp> matches? ] unit-test
[ f ] [ "3" "[A-Z]" <iregexp> matches? ] unit-test

[ t ] [ "a" "(?i)a" <regexp> matches? ] unit-test
[ t ] [ "a" "(?i)a" <regexp> matches? ] unit-test
[ t ] [ "A" "(?i)a" <regexp> matches? ] unit-test
[ t ] [ "A" "(?i)a" <regexp> matches? ] unit-test

[ t ] [ "a" "(?-i)a" <iregexp> matches? ] unit-test
[ t ] [ "a" "(?-i)a" <iregexp> matches? ] unit-test
[ f ] [ "A" "(?-i)a" <iregexp> matches? ] unit-test
[ f ] [ "A" "(?-i)a" <iregexp> matches? ] unit-test

[ f ] [ "A" "[a-z]" <regexp> matches? ] unit-test
[ t ] [ "A" "[a-z]" <iregexp> matches? ] unit-test

[ f ] [ "A" "\\p{Lower}" <regexp> matches? ] unit-test
[ t ] [ "A" "\\p{Lower}" <iregexp> matches? ] unit-test

[ t ] [ "abc" <reversed> "abc" <rregexp> matches? ] unit-test
[ t ] [ "abc" <reversed> "a[bB][cC]" <rregexp> matches? ] unit-test
[ t ] [ "adcbe" "a(?r)(bcd)(?-r)e" <rregexp> matches? ] unit-test

[ t ] [ "s@f" "[a-z.-]@[a-z]" <regexp> matches? ] unit-test
[ f ] [ "a" "[a-z.-]@[a-z]" <regexp> matches? ] unit-test
[ t ] [ ".o" "\\.[a-z]" <regexp> matches? ] unit-test

[ t ] [ "abc*" "[^\\*]*\\*" <regexp> matches? ] unit-test
[ t ] [ "bca" "[^a]*a" <regexp> matches? ] unit-test

[ ] [
    "(0[lL]?|[1-9]\\d{0,9}(\\d{0,9}[lL])?|0[xX]\\p{XDigit}{1,8}(\\p{XDigit}{0,8}[lL])?|0[0-7]{1,11}([0-7]{0,11}[lL])?|([0-9]+\\.[0-9]*|\\.[0-9]+)([eE][+-]?[0-9]+)?[fFdD]?|[0-9]+([eE][+-]?[0-9]+[fFdD]?|([eE][+-]?[0-9]+)?[fFdD]))"
    <regexp> drop
] unit-test

[ ] [ "(\\$[\\p{XDigit}]|[\\p{Digit}])" <regexp> drop ] unit-test

! Comment
[ t ] [ "ac" "a(?#boo)c" <regexp> matches? ] unit-test

[ ] [ "USING: regexp kernel ; R' -{3}[+]{1,6}(?:!!)?\\s' drop" eval ] unit-test

[ ] [ "USING: regexp kernel ; R' (ftp|http|https)://(\\w+:?\\w*@)?(\\S+)(:[0-9]+)?(/|/([\\w#!:.?+=&%@!\\-/]))?' drop" eval ] unit-test

[ ] [ "USING: regexp kernel ; R' \\*[^\s*][^*]*\\*' drop" eval ] unit-test

[ "ab" ] [ "ab" "(a|ab)(bc)?" <regexp> first-match >string ] unit-test
[ "abc" ] [ "abc" "(a|ab)(bc)?" <regexp> first-match >string ] unit-test

[ "ab" ] [ "ab" "(ab|a)(bc)?" <regexp> first-match >string ] unit-test
[ "abc" ] [ "abc" "(ab|a)(bc)?" <regexp> first-match >string ] unit-test

[ "b" ] [ "aaaaaaaaaaaaaaaaaaaaaaab" "((a*)*b)*b" <regexp> first-match >string ] unit-test

[ t ] [ "a:b" ".+:?" <regexp> matches? ] unit-test

[ 1 ] [ "hello" ".+?" <regexp> match length ] unit-test

[ { "1" "2" "3" "4" } ]
[ "1ABC2DEF3GHI4" R/ [A-Z]+/ re-split [ >string ] map ] unit-test

[ { "1" "2" "3" "4" } ]
[ "1ABC2DEF3GHI4JK" R/ [A-Z]+/ re-split [ >string ] map ] unit-test

[ { "ABC" "DEF" "GHI" } ]
[ "1ABC2DEF3GHI4" R/ [A-Z]+/ all-matches [ >string ] map ] unit-test

[ "1.2.3.4" ]
[ "1ABC2DEF3GHI4JK" R/ [A-Z]+/ "." re-replace ] unit-test

[ f ] [ "ab" "a(?!b)" <regexp> first-match ] unit-test
[ "a" ] [ "ab" "a(?=b)(?=b)" <regexp> first-match >string ] unit-test
[ "a" ] [ "ba" "a(?<=b)(?<=b)" <regexp> first-match >string ] unit-test
[ "a" ] [ "cab" "a(?=b)(?<=c)" <regexp> first-match >string ] unit-test

! [ "{Lower}" <regexp> ] [ invalid-range? ] must-fail-with

! [ 1 ] [ "aaacb" "a+?" <regexp> match-head ] unit-test
! [ 1 ] [ "aaacb" "aa??" <regexp> match-head ] unit-test
! [ f ] [ "aaaab" "a++ab" <regexp> matches? ] unit-test
! [ t ] [ "aaacb" "a++cb" <regexp> matches? ] unit-test
! [ 3 ] [ "aacb" "aa?c" <regexp> match-head ] unit-test
! [ 3 ] [ "aacb" "aa??c" <regexp> match-head ] unit-test

! [ t ] [ "fxxbar" "(?!foo).{3}bar" <regexp> matches? ] unit-test
! [ f ] [ "foobar" "(?!foo).{3}bar" <regexp> matches? ] unit-test

[ 3 ] [ "foobar" "foo(?=bar)" <regexp> match-head ] unit-test
[ f ] [ "foobxr" "foo(?=bar)" <regexp> match-head ] unit-test

! [ f ] [ "foobxr" "foo\\z" <regexp> match-head ] unit-test
! [ 3 ] [ "foo" "foo\\z" <regexp> match-head ] unit-test

! [ 3 ] [ "foo bar" "foo\\b" <regexp> match-head ] unit-test
! [ f ] [ "fooxbar" "foo\\b" <regexp> matches? ] unit-test
! [ t ] [ "foo" "foo\\b" <regexp> matches? ] unit-test
! [ t ] [ "foo bar" "foo\\b bar" <regexp> matches? ] unit-test
! [ f ] [ "fooxbar" "foo\\bxbar" <regexp> matches? ] unit-test
! [ f ] [ "foo" "foo\\bbar" <regexp> matches? ] unit-test

! [ f ] [ "foo bar" "foo\\B" <regexp> matches? ] unit-test
! [ 3 ] [ "fooxbar" "foo\\B" <regexp> match-head ] unit-test
! [ t ] [ "foo" "foo\\B" <regexp> matches? ] unit-test
! [ f ] [ "foo bar" "foo\\B bar" <regexp> matches? ] unit-test
! [ t ] [ "fooxbar" "foo\\Bxbar" <regexp> matches? ] unit-test
! [ f ] [ "foo" "foo\\Bbar" <regexp> matches? ] unit-test


! Bug in parsing word
! [ t ] [ "a" R' a' matches?  ] unit-test

! clear "a(?=b*)" <regexp> "ab" over match
! clear "a(?=b*c)" <regexp> "abbbbbc" over match
! clear "a(?=b*)" <regexp> "ab" over match

! clear "^a" <regexp> "a" over match
! clear "^a" <regexp> "\na" over match
! clear "^a" <regexp> "\r\na" over match
! clear "^a" <regexp> "\ra" over match

! clear "a$" <regexp> "a" over match
! clear "a$" <regexp> "a\n" over match
! clear "a$" <regexp> "a\r" over match
! clear "a$" <regexp> "a\r\n" over match

! "(az)(?<=b)" <regexp> "baz" over first-match
! "a(?<=b*)" <regexp> "cbaz" over first-match
! "a(?<=b)" <regexp> "baz" over first-match

! "a(?<!b)" <regexp> "baz" over first-match
! "a(?<!b)" <regexp> "caz" over first-match

! "a(?=bcdefg)bcd" <regexp> "abcdefg" over first-match
! "a(?#bcdefg)bcd" <regexp> "abcdefg" over first-match
! "a(?:bcdefg)" <regexp> "abcdefg" over first-match

[ "a" ] [ "ac" "a(?!b)" <regexp> first-match >string ] unit-test

! "a(?<=b)" <regexp> "caba" over first-match


! capture group 1: "aaaa"  2: ""
! "aaaa" "(a*)(a*)" <regexp> match*
! "aaaa" "(a*)(a+)" <regexp> match*
