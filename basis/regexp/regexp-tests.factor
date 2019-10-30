USING: arrays regexp tools.test kernel sequences regexp.parser
regexp.private eval strings multiline accessors ;
IN: regexp.tests

{ f } [ "b" "a*" <regexp> matches? ] unit-test
{ t } [ "" "a*" <regexp> matches? ] unit-test
{ t } [ "a" "a*" <regexp> matches? ] unit-test
{ t } [ "aaaaaaa" "a*"  <regexp> matches? ] unit-test
{ f } [ "ab" "a*" <regexp> matches? ] unit-test

{ t } [ "abc" "abc" <regexp> matches? ] unit-test
{ t } [ "a" "a|b|c" <regexp> matches? ] unit-test
{ t } [ "b" "a|b|c" <regexp> matches? ] unit-test
{ t } [ "c" "a|b|c" <regexp> matches? ] unit-test
{ f } [ "c" "d|e|f" <regexp> matches? ] unit-test

{ t } [ "b" "|b" <regexp> matches? ] unit-test
{ t } [ "b" "b|" <regexp> matches? ] unit-test
{ t } [ "" "b|" <regexp> matches? ] unit-test
{ t } [ "" "b|" <regexp> matches? ] unit-test
{ t } [ "" "|" <regexp> matches? ] unit-test
{ t } [ "" "|||||||" <regexp> matches? ] unit-test

{ f } [ "aa" "a|b|c" <regexp> matches? ] unit-test
{ f } [ "bb" "a|b|c" <regexp> matches? ] unit-test
{ f } [ "cc" "a|b|c" <regexp> matches? ] unit-test
{ f } [ "cc" "d|e|f" <regexp> matches? ] unit-test

{ f } [ "" "a+" <regexp> matches? ] unit-test
{ t } [ "a" "a+" <regexp> matches? ] unit-test
{ t } [ "aa" "a+" <regexp> matches? ] unit-test

{ t } [ "" "a?" <regexp> matches? ] unit-test
{ t } [ "a" "a?" <regexp> matches? ] unit-test
{ f } [ "aa" "a?" <regexp> matches? ] unit-test

{ f } [ "" "." <regexp> matches? ] unit-test
{ t } [ "a" "." <regexp> matches? ] unit-test
{ t } [ "." "." <regexp> matches? ] unit-test

! Dotall mode -- when on, . matches newlines.
! Off by default.
{ f } [ "\n" "." <regexp> matches? ] unit-test
{ t } [ "\n" "(?s:.)" <regexp> matches? ] unit-test
{ t } [ "\n" re:: "." "s" matches? ] unit-test
{ f } [ "\n\n" "(?s:.)." <regexp> matches? ] unit-test

{ f } [ "" ".+" <regexp> matches? ] unit-test
{ t } [ "a" ".+" <regexp> matches? ] unit-test
{ t } [ "ab" ".+" <regexp> matches? ] unit-test

{ t } [ "\0" "[\\0]" <regexp> matches? ] unit-test
{ f } [ "0" "[\\0]" <regexp> matches? ] unit-test

{ t } [ " " "[\\s]" <regexp> matches? ] unit-test
{ f } [ "a" "[\\s]" <regexp> matches? ] unit-test
{ f } [ " " "[\\S]" <regexp> matches? ] unit-test
{ t } [ "a" "[\\S]" <regexp> matches? ] unit-test
{ f } [ " " "[\\w]" <regexp> matches? ] unit-test
{ t } [ "a" "[\\w]" <regexp> matches? ] unit-test
{ t } [ " " "[\\W]" <regexp> matches? ] unit-test
{ f } [ "a" "[\\W]" <regexp> matches? ] unit-test

{ t } [ "/" "\\/" <regexp> matches? ] unit-test

{ t } [ "a" re:: "a" "i" matches? ] unit-test

{ t } [ "" "a|b*|c+|d?" <regexp> matches? ] unit-test
{ t } [ "a" "a|b*|c+|d?" <regexp> matches? ] unit-test
{ t } [ "c" "a|b*|c+|d?" <regexp> matches? ] unit-test
{ t } [ "cc" "a|b*|c+|d?" <regexp> matches? ] unit-test
{ f } [ "ccd" "a|b*|c+|d?" <regexp> matches? ] unit-test
{ t } [ "d" "a|b*|c+|d?" <regexp> matches? ] unit-test

{ t } [ "foo" "foo|bar" <regexp> matches? ] unit-test
{ t } [ "bar" "foo|bar" <regexp> matches? ] unit-test
{ f } [ "foobar" "foo|bar" <regexp> matches? ] unit-test

{ f } [ "" "(a)" <regexp> matches? ] unit-test
{ t } [ "a" "(a)" <regexp> matches? ] unit-test
{ f } [ "aa" "(a)" <regexp> matches? ] unit-test
{ t } [ "aa" "(a*)" <regexp> matches? ] unit-test

{ f } [ "aababaaabbac" "(a|b)+" <regexp> matches? ] unit-test
{ t } [ "ababaaabba" "(a|b)+" <regexp> matches? ] unit-test

{ f } [ "" "a{1}" <regexp> matches? ] unit-test
{ t } [ "a" "a{1}" <regexp> matches? ] unit-test
{ f } [ "aa" "a{1}" <regexp> matches? ] unit-test

{ f } [ "a" "a{2,}" <regexp> matches? ] unit-test
{ t } [ "aaa" "a{2,}" <regexp> matches? ] unit-test
{ t } [ "aaaa" "a{2,}" <regexp> matches? ] unit-test
{ t } [ "aaaaa" "a{2,}" <regexp> matches? ] unit-test

{ t } [ "" "a{,2}" <regexp> matches? ] unit-test
{ t } [ "a" "a{,2}" <regexp> matches? ] unit-test
{ t } [ "aa" "a{,2}" <regexp> matches? ] unit-test
{ f } [ "aaa" "a{,2}" <regexp> matches? ] unit-test
{ f } [ "aaaa" "a{,2}" <regexp> matches? ] unit-test
{ f } [ "aaaaa" "a{,2}" <regexp> matches? ] unit-test

{ f } [ "" "a{1,3}" <regexp> matches? ] unit-test
{ t } [ "a" "a{1,3}" <regexp> matches? ] unit-test
{ t } [ "aa" "a{1,3}" <regexp> matches? ] unit-test
{ t } [ "aaa" "a{1,3}" <regexp> matches? ] unit-test
{ f } [ "aaaa" "a{1,3}" <regexp> matches? ] unit-test

{ f } [ "" "[a]" <regexp> matches? ] unit-test
{ t } [ "a" "[a]" <regexp> matches? ] unit-test
{ t } [ "a" "[abc]" <regexp> matches? ] unit-test
{ f } [ "b" "[a]" <regexp> matches? ] unit-test
{ f } [ "d" "[abc]" <regexp> matches? ] unit-test
{ t } [ "ab" "[abc]{1,2}" <regexp> matches? ] unit-test
{ f } [ "abc" "[abc]{1,2}" <regexp> matches? ] unit-test

{ f } [ "" "[^a]" <regexp> matches? ] unit-test
{ f } [ "a" "[^a]" <regexp> matches? ] unit-test
{ f } [ "a" "[^abc]" <regexp> matches? ] unit-test
{ t } [ "b" "[^a]" <regexp> matches? ] unit-test
{ t } [ "d" "[^abc]" <regexp> matches? ] unit-test
{ f } [ "ab" "[^abc]{1,2}" <regexp> matches? ] unit-test
{ f } [ "abc" "[^abc]{1,2}" <regexp> matches? ] unit-test

{ t } [ "]" "[]]" <regexp> matches? ] unit-test
{ f } [ "]" "[^]]" <regexp> matches? ] unit-test
{ t } [ "a" "[^]]" <regexp> matches? ] unit-test

[ "^" "[^]" <regexp> matches? ] must-fail
{ t } [ "^" "[]^]" <regexp> matches? ] unit-test
{ t } [ "]" "[]^]" <regexp> matches? ] unit-test

{ t } [ "[" "[[]" <regexp> matches? ] unit-test
{ f } [ "^" "[^^]" <regexp> matches? ] unit-test
{ t } [ "a" "[^^]" <regexp> matches? ] unit-test

{ t } [ "-" "[-]" <regexp> matches? ] unit-test
{ f } [ "a" "[-]" <regexp> matches? ] unit-test
{ f } [ "-" "[^-]" <regexp> matches? ] unit-test
{ t } [ "a" "[^-]" <regexp> matches? ] unit-test

{ t } [ "-" "[-a]" <regexp> matches? ] unit-test
{ t } [ "a" "[-a]" <regexp> matches? ] unit-test
{ t } [ "-" "[a-]" <regexp> matches? ] unit-test
{ t } [ "a" "[a-]" <regexp> matches? ] unit-test
{ f } [ "b" "[a-]" <regexp> matches? ] unit-test
{ f } [ "-" "[^-]" <regexp> matches? ] unit-test
{ t } [ "a" "[^-]" <regexp> matches? ] unit-test

{ f } [ "-" "[a-c]" <regexp> matches? ] unit-test
{ t } [ "-" "[^a-c]" <regexp> matches? ] unit-test
{ t } [ "b" "[a-c]" <regexp> matches? ] unit-test
{ f } [ "b" "[^a-c]" <regexp> matches? ] unit-test

{ t } [ "-" "[a-c-]" <regexp> matches? ] unit-test
{ f } [ "-" "[^a-c-]" <regexp> matches? ] unit-test

{ t } [ "\\" "[\\\\]" <regexp> matches? ] unit-test
{ f } [ "a" "[\\\\]" <regexp> matches? ] unit-test
{ f } [ "\\" "[^\\\\]" <regexp> matches? ] unit-test
{ t } [ "a" "[^\\\\]" <regexp> matches? ] unit-test

{ t } [ "0" "[\\d]" <regexp> matches? ] unit-test
{ f } [ "a" "[\\d]" <regexp> matches? ] unit-test
{ f } [ "0" "[^\\d]" <regexp> matches? ] unit-test
{ t } [ "a" "[^\\d]" <regexp> matches? ] unit-test

{ t } [ "a" "[a-z]{1,}|[A-Z]{2,4}|b*|c|(f|g)*" <regexp> matches? ] unit-test
{ t } [ "a" "[a-z]{1,2}|[A-Z]{3,3}|b*|c|(f|g)*" <regexp> matches? ] unit-test
{ t } [ "a" "[a-z]{1,2}|[A-Z]{3,3}" <regexp> matches? ] unit-test

{ t } [ "1000" "\\d{4,6}" <regexp> matches? ] unit-test
{ t } [ "1000" "[0-9]{4,6}" <regexp> matches? ] unit-test

{ t } [ "abc" "\\p{Lower}{3}" <regexp> matches? ] unit-test
{ f } [ "ABC" "\\p{Lower}{3}" <regexp> matches? ] unit-test
{ t } [ "ABC" "\\p{Upper}{3}" <regexp> matches? ] unit-test
{ f } [ "abc" "\\p{Upper}{3}" <regexp> matches? ] unit-test
{ f } [ "abc" "[\\p{Upper}]{3}" <regexp> matches? ] unit-test
{ t } [ "ABC" "[\\p{Upper}]{3}" <regexp> matches? ] unit-test

{ t } [ "" "\\Q\\E" <regexp> matches? ] unit-test
{ f } [ "a" "\\Q\\E" <regexp> matches? ] unit-test
{ t } [ "|*+" "\\Q|*+\\E" <regexp> matches? ] unit-test
{ f } [ "abc" "\\Q|*+\\E" <regexp> matches? ] unit-test
{ t } [ "s" "\\Qs\\E" <regexp> matches? ] unit-test

{ t } [ "S" "\\0123" <regexp> matches? ] unit-test
{ t } [ "SXY" "\\0123XY" <regexp> matches? ] unit-test
{ t } [ "x" "\\x78" <regexp> matches? ] unit-test
{ f } [ "y" "\\x78" <regexp> matches? ] unit-test
{ t } [ "x" "\\u0078" <regexp> matches? ] unit-test
{ f } [ "y" "\\u0078" <regexp> matches? ] unit-test

{ t } [ "ab" "a+b" <regexp> matches? ] unit-test
{ f } [ "b" "a+b" <regexp> matches? ] unit-test
{ t } [ "aab" "a+b" <regexp> matches? ] unit-test
{ f } [ "abb" "a+b" <regexp> matches? ] unit-test

{ t } [ "abbbb" "ab*" <regexp> matches? ] unit-test
{ t } [ "a" "ab*" <regexp> matches? ] unit-test
{ f } [ "abab" "ab*" <regexp> matches? ] unit-test

{ f } [ "x" "\\." <regexp> matches? ] unit-test
{ t } [ "." "\\." <regexp> matches? ] unit-test

{ t } [ "aaaab" "a+ab" <regexp> matches? ] unit-test
{ f } [ "aaaxb" "a+ab" <regexp> matches? ] unit-test
{ t } [ "aaacb" "a+cb" <regexp> matches? ] unit-test

{ "aaa" } [ "aaacb" "a*" <regexp> first-match >string ] unit-test
{ "aa" } [ "aaacb" "aa?" <regexp> first-match >string ] unit-test

{ t } [ "aaa" re:: "AAA" "i" matches? ] unit-test
{ f } [ "aax" re:: "AAA" "i" matches? ] unit-test
{ t } [ "aaa" re:: "A*" "i" matches? ] unit-test
{ f } [ "aaba" re:: "A*" "i" matches? ] unit-test
{ t } [ "b" re:: "[AB]" "i" matches? ] unit-test
{ f } [ "c" re:: "[AB]" "i" matches? ] unit-test
{ t } [ "c" re:: "[A-Z]" "i" matches? ] unit-test
{ f } [ "3" re:: "[A-Z]" "i" matches? ] unit-test

{ t } [ "a" "(?i:a)" <regexp> matches? ] unit-test
{ t } [ "a" "(?i:a)" <regexp> matches? ] unit-test
{ t } [ "A" "(?i:a)" <regexp> matches? ] unit-test
{ t } [ "A" "(?i:a)" <regexp> matches? ] unit-test

{ t } [ "a" re:: "(?-i:a)" "i" matches? ] unit-test
{ t } [ "a" re:: "(?-i:a)" "i" matches? ] unit-test
{ f } [ "A" re:: "(?-i:a)" "i" matches? ] unit-test
{ f } [ "A" re:: "(?-i:a)" "i" matches? ] unit-test

{ f } [ "A" "[a-z]" <regexp> matches? ] unit-test
{ t } [ "A" re:: "[a-z]" "i" matches? ] unit-test

{ f } [ "A" "\\p{Lower}" <regexp> matches? ] unit-test
{ t } [ "A" re:: [[\p{Lower}]] "i" matches? ] unit-test

{ t } [ "abc" re:: "abc" "r" matches? ] unit-test
{ t } [ "abc" re:: "a[bB][cC]" "r" matches? ] unit-test

{ t } [ 3 "xabc" re:: "abc" "r"  match-index-from >boolean ] unit-test
{ t } [ 3 "xabc" re:: "a[bB][cC]" "r" match-index-from >boolean ] unit-test

{ 2 } [ 0 "llamallol" re"ll" match-index-from ] unit-test
{ 5 } [ 8 "lolmallol" re:: "lol" "r" match-index-from ] unit-test

{ t } [ "s@f" "[a-z.-]@[a-z]" <regexp> matches? ] unit-test
{ f } [ "a" "[a-z.-]@[a-z]" <regexp> matches? ] unit-test
{ t } [ ".o" "\\.[a-z]" <regexp> matches? ] unit-test

{ t } [ "abc*" "[^\\*]*\\*" <regexp> matches? ] unit-test
{ t } [ "bca" "[^a]*a" <regexp> matches? ] unit-test

{ } [
    "(0[lL]?|[1-9]\\d{0,9}(\\d{0,9}[lL])?|0[xX]\\p{XDigit}{1,8}(\\p{XDigit}{0,8}[lL])?|0[0-7]{1,11}([0-7]{0,11}[lL])?|([0-9]+\\.[0-9]*|\\.[0-9]+)([eE][+-]?[0-9]+)?[fFdD]?|[0-9]+([eE][+-]?[0-9]+[fFdD]?|([eE][+-]?[0-9]+)?[fFdD]))"
    <regexp> drop
] unit-test

{ } [ "(\\$[\\p{XDigit}]|[\\p{Digit}])" <regexp> drop ] unit-test

! Comment inside a regular expression
{ t } [ "ac" "a(?#boo)c" <regexp> matches? ] unit-test

{ } [ "USING: regexp kernel ; re[[-{3}[+]{1,6}(?:!!)?\\s]] drop" eval( -- ) ] unit-test

{ } [ "USING: regexp kernel ; re[[(ftp|http|https):\\/\\/(\\w+:?\\w*@)?(\\S+)(:[0-9]+)?(\\/\\|\\/([\\w#!:.?+=&%@!\\-\\/]))?]] drop" eval( -- ) ] unit-test

{ } [ "USING: regexp kernel ; re[[\\*[^\s*][^*]*\\*]] drop" eval( -- ) ] unit-test

{ "ab" } [ "ab" "(a|ab)(bc)?" <regexp> first-match >string ] unit-test
{ "abc" } [ "abc" "(a|ab)(bc)?" <regexp> first-match >string ] unit-test

{ "ab" } [ "ab" "(ab|a)(bc)?" <regexp> first-match >string ] unit-test
{ "abc" } [ "abc" "(ab|a)(bc)?" <regexp> first-match >string ] unit-test

{ "b" } [ "aaaaaaaaaaaaaaaaaaaaaaab" "((a*)*b)*b" <regexp> first-match >string ] unit-test

{ T{ slice { from 5 } { to 10 } { seq "hellohello" } } }
[ "hellohello" re:: "hello" "r" first-match ]
unit-test

{ { "1" "2" "3" "4" } }
[ "1ABC2DEF3GHI4" re"[A-Z]+" re-split [ >string ] map ] unit-test

{ { "1" "2" "3" "4" "" } }
[ "1ABC2DEF3GHI4JK" re"[A-Z]+" re-split [ >string ] map ] unit-test

{ { "" } } [ "" re"=" re-split [ >string ] map ] unit-test

{ { "a" "" } } [ "a=" re"=" re-split [ >string ] map ] unit-test

{ { "he" "o" } } [ "hello" re"l+" re-split [ >string ] map ] unit-test

{ { "h" "llo" } } [ "hello" re"e+" re-split [ >string ] map ] unit-test

{ { "" "h" "" "l" "l" "o" "" } } [ "hello" re"e*" re-split [ >string ] map ] unit-test

{ { { 0 5 "hellohello" } { 5 10 "hellohello" } } }
[ "hellohello" re"hello" [ 3array ] map-matches ]
unit-test

{ { { 5 10 "hellohello" } { 0 5 "hellohello" } } }
[ "hellohello" re:: "hello" "r" [ 3array ] map-matches ]
unit-test

{ { "ABC" "DEF" "GHI" } }
[ "1ABC2DEF3GHI4" re"[A-Z]+" all-matching-subseqs ] unit-test

{ { "ee" "e" } } [ "heellohello" re"e+" all-matching-subseqs ] unit-test
{ { "e" "ee" } } [ "heellohello" re:: "e+" "r" all-matching-subseqs ] unit-test

{ 3 } [ "1ABC2DEF3GHI4" re"[A-Z]+" count-matches ] unit-test

{ 3 } [ "1ABC2DEF3GHI4" re:: "[A-Z]+" "r" count-matches ] unit-test

{ 1 } [ "" re"" count-matches ] unit-test

{ 1 } [ "" re:: "" "r" count-matches ] unit-test

{ 0 } [ "123" re"[A-Z]+" count-matches ] unit-test

{ 0 } [ "123" re:: "[A-Z]+" "r" count-matches ] unit-test

{ 6 } [ "hello" re"e*" count-matches ] unit-test

{ 6 } [ "hello" re:: "e*" "r" count-matches ] unit-test

{ 11 } [ "hello world" re"l*" count-matches ] unit-test

{ 11 } [ "hello world" re:: "l*" "r" count-matches ] unit-test

{ 1 } [ "hello" re"e+" count-matches ] unit-test

{ 2 } [ "hello world" re:: "l+" "r" count-matches ] unit-test

{ "1.2.3.4." } [ "1ABC2DEF3GHI4JK" re"[A-Z]+" "." re-replace ] unit-test
{ "XhXXlXlXoX XwXoXrXlXdX" } [ "hello world" re"e*" "X" re-replace ] unit-test
{ "-- title --" } [ "== title ==" re"=" "-" re-replace ] unit-test

{ "abc" } [ "a/   \\bc" "/.*\\" <regexp> "" re-replace ] unit-test
{ "ac" } [ "a/   \\bc" re[[\/.*\\.]] "" re-replace ] unit-test
{ "abc" } [ "a/   \\bc" re[[\/.*\\]] "" re-replace ] unit-test

{ "" } [ "ab" "a(?!b)" <regexp> first-match >string ] unit-test
{ "a" } [ "ac" "a(?!b)" <regexp> first-match >string ] unit-test
{ t } [ "fxxbar" ".{3}(?!foo)bar" <regexp> matches? ] unit-test
{ t } [ "foobar" ".{3}(?!foo)bar" <regexp> matches? ] unit-test
{ t } [ "fxxbar" "(?!foo).{3}bar" <regexp> matches? ] unit-test
{ f } [ "foobar" "(?!foo).{3}bar" <regexp> matches? ] unit-test
{ "a" } [ "ab" "a(?=b)(?=b)" <regexp> first-match >string ] unit-test
{ "a" } [ "ba" "(?<=b)(?<=b)a" <regexp> first-match >string ] unit-test
{ "a" } [ "cab" "(?<=c)a(?=b)" <regexp> first-match >string ] unit-test

{ 3 } [ "foobar" "foo(?=bar)" <regexp> first-match length ] unit-test
{ f } [ "foobxr" "foo(?=bar)" <regexp> first-match ] unit-test

! Bug in parsing word
{ t } [ "a" re"a" matches? ] unit-test

! Testing negation
{ f } [ "a" re"(?~a)" matches? ] unit-test
{ t } [ "aa" re"(?~a)" matches? ] unit-test
{ t } [ "bb" re"(?~a)" matches? ] unit-test
{ t } [ "" re"(?~a)" matches? ] unit-test

{ f } [ "a" re"(?~a+|b)" matches? ] unit-test
{ f } [ "aa" re"(?~a+|b)" matches? ] unit-test
{ t } [ "bb" re"(?~a+|b)" matches? ] unit-test
{ f } [ "b" re"(?~a+|b)" matches? ] unit-test
{ t } [ "" re"(?~a+|b)" matches? ] unit-test

! Intersecting classes
{ t } [ "ab" re[[ac|\p{Lower}b]] matches? ] unit-test
{ t } [ "ab" re[[ac|[a-z]b]] matches? ] unit-test
{ t } [ "ac" re[[ac|\p{Lower}b]] matches? ] unit-test
{ t } [ "ac" re[[ac|[a-z]b]] matches? ] unit-test
{ t } [ "ac" re[[[a-zA-Z]c|\p{Lower}b]] matches? ] unit-test
{ t } [ "ab" re[[[a-zA-Z]c|\p{Lower}b]] matches? ] unit-test
{ t } [ "πb" re[[[a-zA-Z]c|\p{Lower}b]] matches? ] unit-test
{ f } [ "πc" re[[[a-zA-Z]c|\p{Lower}b]] matches? ] unit-test
{ f } [ "Ab" re[[[a-zA-Z]c|\p{Lower}b]] matches? ] unit-test

{ t } [ "aaaa" re".*a." matches? ] unit-test

{ f } [ "ab" re[[(?~ac|\p{Lower}b)]] matches? ] unit-test
{ f } [ "ab" re[[(?~ac|[a-z]b)]] matches? ] unit-test
{ f } [ "ac" re[[(?~ac|\p{Lower}b)]] matches? ] unit-test
{ f } [ "ac" re[[(?~ac|[a-z]b)]] matches? ] unit-test
{ f } [ "ac" re[[(?~[a-zA-Z]c|\p{Lower}b)]] matches? ] unit-test
{ f } [ "ab" re[[(?~[a-zA-Z]c|\p{Lower}b)]] matches? ] unit-test
{ f } [ "πb" re[[(?~[a-zA-Z]c|\p{Lower}b)]] matches? ] unit-test
{ t } [ "πc" re[[(?~[a-zA-Z]c|\p{Lower}b)]] matches? ] unit-test
{ t } [ "Ab" re[[(?~[a-zA-Z]c|\p{Lower}b)]] matches? ] unit-test

! DFA is compiled when needed, or when literal
{ regexp-initial-word } [ "foo" <regexp> dfa>> ] unit-test
{ f } [ re"foo" dfa>> \ regexp-initial-word = ] unit-test

{ t } [ "a" re"^a" matches? ] unit-test
{ f } [ "\na" re"^a" matches? ] unit-test
{ f } [ "\r\na" re"^a" matches? ] unit-test
{ f } [ "\ra" re"^a" matches? ] unit-test

{ 1 } [ "a" re"^a" count-matches ] unit-test
{ 0 } [ "\na" re"^a" count-matches ] unit-test
{ 0 } [ "\r\na" re"^a" count-matches ] unit-test
{ 0 } [ "\ra" re"^a" count-matches ] unit-test

{ t } [ "a" re"a$" matches? ] unit-test
{ f } [ "a\n" re"a$" matches? ] unit-test
{ f } [ "a\r" re"a$" matches? ] unit-test
{ f } [ "a\r\n" re"a$" matches? ] unit-test

{ 1 } [ "a" re"a$" count-matches ] unit-test
{ 0 } [ "a\n" re"a$" count-matches ] unit-test
{ 0 } [ "a\r" re"a$" count-matches ] unit-test
{ 0 } [ "a\r\n" re"a$" count-matches ] unit-test

{ t } [ "a" re"a$|b$" matches? ] unit-test
{ t } [ "b" re"a$|b$" matches? ] unit-test
{ f } [ "ab" re"a$|b$" matches? ] unit-test
{ t } [ "ba" re"ba$|b$" matches? ] unit-test

{ t } [ "a" re[[\Aa]] matches? ] unit-test
{ f } [ "\na" re[[\Aaa]] matches? ] unit-test
{ f } [ "\r\na" re[[\Aa]] matches? ] unit-test
{ f } [ "\ra" re[[\Aa]] matches? ] unit-test

{ t } [ "a" re:: [[\Aa]] "m" matches? ] unit-test
{ f } [ "\na" re:: [[\Aaa]] "m" matches? ] unit-test
{ f } [ "\r\na" re:: [[\Aa]] "m" matches? ] unit-test
{ f } [ "\ra" re:: [[\Aa]] "m" matches? ] unit-test
{ 0 } [ "\ra" re:: [[\Aa]] "m" count-matches ] unit-test

{ f } [ "\r\n\n\n\nam" re:: [[^am]] "m" matches? ] unit-test
{ 1 } [ "\r\n\n\n\nam" re:: [[^am]] "m" count-matches ] unit-test

{ t } [ "a" re:: [[\Aa\z]] "m" matches? ] unit-test
{ f } [ "a\n" re:: [[\Aa\z]] "m" matches? ] unit-test

{ f } [ "a\r\n" re:: [[\Aa\Z]] "m" matches? ] unit-test
{ f } [ "a\n" re:: [[\Aa\Z]] "m" matches? ] unit-test
{ 1 } [ "a\r\n" re:: [[\Aa\Z]] "m" count-matches ] unit-test
{ 1 } [ "a\n" re:: [[\Aa\Z]] "m" count-matches ] unit-test

{ t } [ "a" re:: [[\Aa\Z]] "m" matches? ] unit-test
{ f } [ "\na" re:: [[\Aaa\Z]] "m" matches? ] unit-test
{ f } [ "\r\na" re:: [[\Aa\Z]] "m" matches? ] unit-test
{ f } [ "\ra" re:: [[\Aa\Z]] "m" matches? ] unit-test

{ 1 } [ "a" re:: [[\Aa\Z]] "m" count-matches ] unit-test
{ 0 } [ "\na" re:: [[\Aaa\Z]] "m" count-matches ] unit-test
{ 0 } [ "\r\na" re:: [[\Aa\Z]] "m" count-matches ] unit-test
{ 0 } [ "\ra" re:: [[\Aa\Z]] "m" count-matches ] unit-test

{ t } [ "a" re:: "^a" "m" matches? ] unit-test
{ f } [ "\na" re:: "^a" "m" matches? ] unit-test
{ 1 } [ "\na" re:: "^a" "m" count-matches ] unit-test
{ 1 } [ "\r\na" re:: "^a" "m" count-matches ] unit-test
{ 1 } [ "\ra" re:: "^a" "m" count-matches ] unit-test

{ t } [ "a" re:: "a$" "m" matches? ] unit-test
{ f } [ "a\n" re:: "a$" "m" matches? ] unit-test
{ 1 } [ "a\n" re:: "a$" "m" count-matches ] unit-test
{ 1 } [ "a\r" re:: "a$" "m" count-matches ] unit-test
{ 1 } [ "a\r\n" re:: "a$" "m" count-matches ] unit-test

{ f } [ "foobxr" "foo\\z" <regexp> first-match ] unit-test
{ 3 } [ "foo" "foo\\z" <regexp> first-match length ] unit-test

{ t } [ "a foo b" re"foo" re-contains? ] unit-test
{ f } [ "a bar b" re"foo" re-contains? ] unit-test
{ t } [ "foo" re"foo" re-contains? ] unit-test

{ { "foo" "fxx" "fab" } } [ "fab fxx foo" re:: "f.." "r" all-matching-subseqs ] unit-test

{ t } [ "foo" "\\bfoo\\b" <regexp> re-contains? ] unit-test
{ t } [ "afoob" "\\Bfoo\\B" <regexp> re-contains? ] unit-test
{ f } [ "afoob" "\\bfoo\\b" <regexp> re-contains? ] unit-test
{ f } [ "foo" "\\Bfoo\\B" <regexp> re-contains? ] unit-test

{ 3 } [ "foo bar" "foo\\b" <regexp> first-match length ] unit-test
{ f } [ "fooxbar" "foo\\b" <regexp> re-contains? ] unit-test
{ t } [ "foo" "foo\\b" <regexp> re-contains? ] unit-test
{ t } [ "foo bar" "foo\\b bar" <regexp> matches? ] unit-test
{ f } [ "fooxbar" "foo\\bxbar" <regexp> matches? ] unit-test
{ f } [ "foo" "foo\\bbar" <regexp> matches? ] unit-test

{ f } [ "foo bar" "foo\\B" <regexp> re-contains? ] unit-test
{ 3 } [ "fooxbar" "foo\\B" <regexp> first-match length ] unit-test
{ f } [ "foo" "foo\\B" <regexp> re-contains? ] unit-test
{ f } [ "foo bar" "foo\\B bar" <regexp> matches? ] unit-test
{ t } [ "fooxbar" "foo\\Bxbar" <regexp> matches? ] unit-test
{ f } [ "foo" "foo\\Bbar" <regexp> matches? ] unit-test

{ t } [ "ab" "a(?=b*)" <regexp> re-contains? ] unit-test
{ t } [ "abbbbbc" "a(?=b*c)" <regexp> re-contains? ] unit-test
{ f } [ "abbbbb" "a(?=b*c)" <regexp> re-contains? ] unit-test
{ t } [ "ab" "a(?=b*)" <regexp> re-contains? ] unit-test

{ "az" } [ "baz" "(?<=b)(az)" <regexp> first-match >string ] unit-test
{ f } [ "chaz" "(?<=b)(az)" <regexp> re-contains? ] unit-test
{ "a" } [ "cbaz" "(?<=b*)a" <regexp> first-match >string ] unit-test
{ f } [ "baz" "a(?<=b)" <regexp> re-contains? ] unit-test

{ f } [ "baz" "(?<!b)a" <regexp> re-contains? ] unit-test
{ t } [ "caz" "(?<!b)a" <regexp> re-contains? ] unit-test

{ "abcd" } [ "abcdefg" "a(?=bcdefg)bcd" <regexp> first-match >string ] unit-test
{ t } [ "abcdefg" "a(?#bcdefg)bcd" <regexp> re-contains? ] unit-test
{ t } [ "abcdefg" "a(?:bcdefg)" <regexp> matches? ] unit-test

{ 3 } [ "caba" "(?<=b)a" <regexp> first-match from>> ] unit-test

{ t } [ "\ra" re:: ".^a" "ms" matches? ] unit-test
{ f } [ "\ra" re:: ".^a" "mds" matches? ] unit-test
{ t } [ "\na" re:: ".^a" "ms" matches? ] unit-test
{ t } [ "\na" re:: ".^a" "mds" matches? ] unit-test

{ t } [ "a\r" re:: "a$." "ms" matches? ] unit-test
{ f } [ "a\r" re:: "a$." "mds" matches? ] unit-test
{ t } [ "a\n" re:: "a$." "ms" matches? ] unit-test
{ t } [ "a\n" re:: "a$." "mds" matches? ] unit-test

! Unicode categories
{ t } [ "a" re[[\p{L}]] matches? ] unit-test
{ t } [ "A" re[[\p{L}]] matches? ] unit-test
{ f } [ " " re[[\p{L}]] matches? ] unit-test
{ f } [ "a" re[[\P{L}]] matches? ] unit-test
{ f } [ "A" re[[\P{L}]] matches? ] unit-test
{ t } [ " " re[[\P{L}]] matches? ] unit-test

{ t } [ "a" re[[\p{Ll}]] matches? ] unit-test
{ f } [ "A" re[[\p{Ll}]] matches? ] unit-test
{ f } [ " " re[[\p{Ll}]] matches? ] unit-test
{ f } [ "a" re[[\P{Ll}]] matches? ] unit-test
{ t } [ "A" re[[\P{Ll}]] matches? ] unit-test
{ t } [ " " re[[\P{Ll}]] matches? ] unit-test

{ t } [ "a" re[[\p{script=Latin}]] matches? ] unit-test
{ f } [ " " re[[\p{script=Latin}]] matches? ] unit-test
{ f } [ "a" re[[\P{script=Latin}]] matches? ] unit-test
{ t } [ " " re[[\P{script=Latin}]] matches? ] unit-test

! These should be case-insensitive
{ f } [ " " re[[\p{l}]] matches? ] unit-test
{ f } [ "a" re[[\P{l}]] matches? ] unit-test
{ f } [ "a" re[[\P{ll}]] matches? ] unit-test
{ t } [ " " re[[\P{LL}]] matches? ] unit-test
{ f } [ "a" re[[\P{sCriPt = latin}]] matches? ] unit-test
{ t } [ " " re[[\P{SCRIPT = laTIn}]] matches? ] unit-test

! Logical operators
{ t } [ "a" re[=[[\p{script=latin}\p{lower}]]=] matches? ] unit-test
{ t } [ "π" re[=[[\p{script=latin}\p{lower}]]=] matches? ] unit-test
{ t } [ "A" re[=[[\p{script=latin}\p{lower}]]=] matches? ] unit-test
{ f } [ "3" re[=[[\p{script=latin}\p{lower}]]=] matches? ] unit-test

{ t } [ "a" re[=[[\p{script=latin}||\p{lower}]]=] matches? ] unit-test
{ t } [ "π" re[=[[\p{script=latin}||\p{lower}]]=] matches? ] unit-test
{ t } [ "A" re[=[[\p{script=latin}||\p{lower}]]=] matches? ] unit-test
{ f } [ "3" re[=[[\p{script=latin}||\p{lower}]]=] matches? ] unit-test

{ t } [ "a" re[=[[\p{script=latin}&&\p{lower}]]=] matches? ] unit-test
{ f } [ "π" re[=[[\p{script=latin}&&\p{lower}]]=] matches? ] unit-test
{ f } [ "A" re[=[[\p{script=latin}&&\p{lower}]]=] matches? ] unit-test
{ f } [ "3" re[=[[\p{script=latin}&&\p{lower}]]=] matches? ] unit-test

{ f } [ "a" re[=[[\p{script=latin}~~\p{lower}]]=] matches? ] unit-test
{ t } [ "π" re[=[[\p{script=latin}~~\p{lower}]]=] matches? ] unit-test
{ t } [ "A" re[=[[\p{script=latin}~~\p{lower}]]=] matches? ] unit-test
{ f } [ "3" re[=[[\p{script=latin}~~\p{lower}]]=] matches? ] unit-test

{ f } [ "a" re[=[[\p{script=latin}--\p{lower}]]=] matches? ] unit-test
{ f } [ "π" re[=[[\p{script=latin}--\p{lower}]]=] matches? ] unit-test
{ t } [ "A" re[=[[\p{script=latin}--\p{lower}]]=] matches? ] unit-test
{ f } [ "3" re[=[[\p{script=latin}--\p{lower}]]=] matches? ] unit-test

{ t } [ " " re[[\P{alpha}]] matches? ] unit-test
{ f } [ "" re[[\P{alpha}]] matches? ] unit-test
{ f } [ "a " re[[\P{alpha}]] matches? ] unit-test
{ f } [ "a" re[[\P{alpha}]] matches? ] unit-test
