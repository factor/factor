! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: regexp tools.test kernel sequences regexp.parser regexp.private
eval strings multiline accessors regexp.matchers ;
IN: regexp-tests

\ <regexp> must-infer
! the following don't compile because [ ] with-compilation-unit doesn't compile
! \ compile-regexp must-infer
! \ matches? must-infer

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
[ t ] [ "" "|" <regexp> matches? ] unit-test
[ t ] [ "" "|||||||" <regexp> matches? ] unit-test

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
[ t ] [ "\n" "(?s:.)" <regexp> matches? ] unit-test
[ t ] [ "\n" R/ ./s matches? ] unit-test
[ f ] [ "\n\n" "(?s:.)." <regexp> matches? ] unit-test

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

[ t ] [ "" "\\Q\\E" <regexp> matches? ] unit-test
[ f ] [ "a" "\\Q\\E" <regexp> matches? ] unit-test
[ t ] [ "|*+" "\\Q|*+\\E" <regexp> matches? ] unit-test
[ f ] [ "abc" "\\Q|*+\\E" <regexp> matches? ] unit-test
[ t ] [ "s" "\\Qs\\E" <regexp> matches? ] unit-test

[ t ] [ "S" "\\0123" <regexp> matches? ] unit-test
[ t ] [ "SXY" "\\0123XY" <regexp> matches? ] unit-test
[ t ] [ "x" "\\x78" <regexp> matches? ] unit-test
[ f ] [ "y" "\\x78" <regexp> matches? ] unit-test
[ t ] [ "x" "\\u0078" <regexp> matches? ] unit-test
[ f ] [ "y" "\\u0078" <regexp> matches? ] unit-test

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

[ 3 ] [ "aaacb" "a*" <regexp> match-index-head ] unit-test
[ 2 ] [ "aaacb" "aa?" <regexp> match-index-head ] unit-test

[ t ] [ "aaa" R/ AAA/i matches? ] unit-test
[ f ] [ "aax" R/ AAA/i matches? ] unit-test
[ t ] [ "aaa" R/ A*/i matches? ] unit-test
[ f ] [ "aaba" R/ A*/i matches? ] unit-test
[ t ] [ "b" R/ [AB]/i matches? ] unit-test
[ f ] [ "c" R/ [AB]/i matches? ] unit-test
[ t ] [ "c" R/ [A-Z]/i matches? ] unit-test
[ f ] [ "3" R/ [A-Z]/i matches? ] unit-test

[ t ] [ "a" "(?i:a)" <regexp> matches? ] unit-test
[ t ] [ "a" "(?i:a)" <regexp> matches? ] unit-test
[ t ] [ "A" "(?i:a)" <regexp> matches? ] unit-test
[ t ] [ "A" "(?i:a)" <regexp> matches? ] unit-test

[ t ] [ "a" R/ (?-i:a)/i matches? ] unit-test
[ t ] [ "a" R/ (?-i:a)/i matches? ] unit-test
[ f ] [ "A" R/ (?-i:a)/i matches? ] unit-test
[ f ] [ "A" R/ (?-i:a)/i matches? ] unit-test

[ f ] [ "A" "[a-z]" <regexp> matches? ] unit-test
[ t ] [ "A" R/ [a-z]/i matches? ] unit-test

[ f ] [ "A" "\\p{Lower}" <regexp> matches? ] unit-test
[ t ] [ "A" R/ \p{Lower}/i matches? ] unit-test

[ t ] [ "abc" reverse R/ abc/r matches? ] unit-test
[ t ] [ "abc" reverse R/ a[bB][cC]/r matches? ] unit-test

[ t ] [ 3 "xabc" R/ abc/ <reverse-matcher> match-index-from >boolean ] unit-test
[ t ] [ 3 "xabc" R/ a[bB][cC]/ <reverse-matcher> match-index-from >boolean ] unit-test

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

! Comment inside a regular expression
[ t ] [ "ac" "a(?#boo)c" <regexp> matches? ] unit-test

[ ] [ "USING: regexp kernel ; R' -{3}[+]{1,6}(?:!!)?\\s' drop" eval ] unit-test

[ ] [ "USING: regexp kernel ; R' (ftp|http|https)://(\\w+:?\\w*@)?(\\S+)(:[0-9]+)?(/|/([\\w#!:.?+=&%@!\\-/]))?' drop" eval ] unit-test

[ ] [ "USING: regexp kernel ; R' \\*[^\s*][^*]*\\*' drop" eval ] unit-test

[ "ab" ] [ "ab" "(a|ab)(bc)?" <regexp> match-head >string ] unit-test
[ "abc" ] [ "abc" "(a|ab)(bc)?" <regexp> match-head >string ] unit-test

[ "ab" ] [ "ab" "(ab|a)(bc)?" <regexp> match-head >string ] unit-test
[ "abc" ] [ "abc" "(ab|a)(bc)?" <regexp> match-head >string ] unit-test

[ "b" ] [ "aaaaaaaaaaaaaaaaaaaaaaab" "((a*)*b)*b" <regexp> match-head >string ] unit-test

[ { "1" "2" "3" "4" } ]
[ "1ABC2DEF3GHI4" R/ [A-Z]+/ re-split [ >string ] map ] unit-test

[ { "1" "2" "3" "4" "" } ]
[ "1ABC2DEF3GHI4JK" R/ [A-Z]+/ re-split [ >string ] map ] unit-test

[ { "" } ] [ "" R/ =/ re-split [ >string ] map ] unit-test

[ { "a" "" } ] [ "a=" R/ =/ re-split [ >string ] map ] unit-test

[ { "ABC" "DEF" "GHI" } ]
[ "1ABC2DEF3GHI4" R/ [A-Z]+/ all-matches [ >string ] map ] unit-test

[ 3 ]
[ "1ABC2DEF3GHI4" R/ [A-Z]+/ count-matches ] unit-test

[ 0 ]
[ "123" R/ [A-Z]+/ count-matches ] unit-test

[ "1.2.3.4." ]
[ "1ABC2DEF3GHI4JK" R/ [A-Z]+/ "." re-replace ] unit-test
  
[ "-- title --" ] [ "== title ==" R/ =/ "-" re-replace ] unit-test

[ "" ] [ "ab" "a(?!b)" <regexp> match-head >string ] unit-test
[ "a" ] [ "ac" "a(?!b)" <regexp> match-head >string ] unit-test
[ t ] [ "fxxbar" ".{3}(?!foo)bar" <regexp> matches? ] unit-test
[ t ] [ "foobar" ".{3}(?!foo)bar" <regexp> matches? ] unit-test
[ t ] [ "fxxbar" "(?!foo).{3}bar" <regexp> matches? ] unit-test
[ f ] [ "foobar" "(?!foo).{3}bar" <regexp> matches? ] unit-test
[ "a" ] [ "ab" "a(?=b)(?=b)" <regexp> match-head >string ] unit-test
[ "a" ] [ "ba" "(?<=b)(?<=b)a" <regexp> match-head >string ] unit-test
[ "a" ] [ "cab" "(?<=c)a(?=b)" <regexp> match-head >string ] unit-test

[ 3 ] [ "foobar" "foo(?=bar)" <regexp> match-index-head ] unit-test
[ f ] [ "foobxr" "foo(?=bar)" <regexp> match-index-head ] unit-test

! Bug in parsing word
[ t ] [ "a" R' a' matches? ] unit-test

! Testing negation
[ f ] [ "a" R/ (?~a)/ matches? ] unit-test
[ t ] [ "aa" R/ (?~a)/ matches? ] unit-test
[ t ] [ "bb" R/ (?~a)/ matches? ] unit-test
[ t ] [ "" R/ (?~a)/ matches? ] unit-test

[ f ] [ "a" R/ (?~a+|b)/ matches? ] unit-test
[ f ] [ "aa" R/ (?~a+|b)/ matches? ] unit-test
[ t ] [ "bb" R/ (?~a+|b)/ matches? ] unit-test
[ f ] [ "b" R/ (?~a+|b)/ matches? ] unit-test
[ t ] [ "" R/ (?~a+|b)/ matches? ] unit-test

! Intersecting classes
[ t ] [ "ab" R/ ac|\p{Lower}b/ matches? ] unit-test
[ t ] [ "ab" R/ ac|[a-z]b/ matches? ] unit-test
[ t ] [ "ac" R/ ac|\p{Lower}b/ matches? ] unit-test
[ t ] [ "ac" R/ ac|[a-z]b/ matches? ] unit-test
[ t ] [ "ac" R/ [a-zA-Z]c|\p{Lower}b/ matches? ] unit-test
[ t ] [ "ab" R/ [a-zA-Z]c|\p{Lower}b/ matches? ] unit-test
[ t ] [ "πb" R/ [a-zA-Z]c|\p{Lower}b/ matches? ] unit-test
[ f ] [ "πc" R/ [a-zA-Z]c|\p{Lower}b/ matches? ] unit-test
[ f ] [ "Ab" R/ [a-zA-Z]c|\p{Lower}b/ matches? ] unit-test

[ t ] [ "aaaa" R/ .*a./ matches? ] unit-test

! DFA is compiled when needed, or when literal
[ f ] [ "foo" <regexp> dfa>> >boolean ] unit-test
[ t ] [ R/ foo/ dfa>> >boolean ] unit-test

[ t ] [ "a" R/ ^a/ matches? ] unit-test
[ f ] [ "\na" R/ ^a/ matches? ] unit-test
[ f ] [ "\r\na" R/ ^a/ matches? ] unit-test
[ f ] [ "\ra" R/ ^a/ matches? ] unit-test

[ 1 ] [ "a" R/ ^a/ count-matches ] unit-test
[ 0 ] [ "\na" R/ ^a/ count-matches ] unit-test
[ 0 ] [ "\r\na" R/ ^a/ count-matches ] unit-test
[ 0 ] [ "\ra" R/ ^a/ count-matches ] unit-test

[ t ] [ "a" R/ a$/ matches? ] unit-test
[ f ] [ "a\n" R/ a$/ matches? ] unit-test
[ f ] [ "a\r" R/ a$/ matches? ] unit-test
[ f ] [ "a\r\n" R/ a$/ matches? ] unit-test

[ 1 ] [ "a" R/ a$/ count-matches ] unit-test
[ 0 ] [ "a\n" R/ a$/ count-matches ] unit-test
[ 0 ] [ "a\r" R/ a$/ count-matches ] unit-test
[ 0 ] [ "a\r\n" R/ a$/ count-matches ] unit-test

[ t ] [ "a" R/ a$|b$/ matches? ] unit-test
[ t ] [ "b" R/ a$|b$/ matches? ] unit-test
[ f ] [ "ab" R/ a$|b$/ matches? ] unit-test
[ t ] [ "ba" R/ ba$|b$/ matches? ] unit-test

[ t ] [ "a" R/ \Aa/ matches? ] unit-test
[ f ] [ "\na" R/ \Aaa/ matches? ] unit-test
[ f ] [ "\r\na" R/ \Aa/ matches? ] unit-test
[ f ] [ "\ra" R/ \Aa/ matches? ] unit-test

[ t ] [ "a" R/ \Aa/m matches? ] unit-test
[ f ] [ "\na" R/ \Aaa/m matches? ] unit-test
[ f ] [ "\r\na" R/ \Aa/m matches? ] unit-test
[ f ] [ "\ra" R/ \Aa/m matches? ] unit-test
[ 0 ] [ "\ra" R/ \Aa/m count-matches ] unit-test

[ f ] [ "\r\n\n\n\nam" R/ ^am/m matches? ] unit-test
[ 1 ] [ "\r\n\n\n\nam" R/ ^am/m count-matches ] unit-test

[ t ] [ "a" R/ \Aa\z/m matches? ] unit-test
[ f ] [ "a\n" R/ \Aa\z/m matches? ] unit-test

[ f ] [ "a\r\n" R/ \Aa\Z/m matches? ] unit-test
[ f ] [ "a\n" R/ \Aa\Z/m matches? ] unit-test
[ 1 ] [ "a\r\n" R/ \Aa\Z/m count-matches ] unit-test
[ 1 ] [ "a\n" R/ \Aa\Z/m count-matches ] unit-test

[ t ] [ "a" R/ \Aa\Z/m matches? ] unit-test
[ f ] [ "\na" R/ \Aaa\Z/m matches? ] unit-test
[ f ] [ "\r\na" R/ \Aa\Z/m matches? ] unit-test
[ f ] [ "\ra" R/ \Aa\Z/m matches? ] unit-test

[ 1 ] [ "a" R/ \Aa\Z/m count-matches ] unit-test
[ 0 ] [ "\na" R/ \Aaa\Z/m count-matches ] unit-test
[ 0 ] [ "\r\na" R/ \Aa\Z/m count-matches ] unit-test
[ 0 ] [ "\ra" R/ \Aa\Z/m count-matches ] unit-test

[ t ] [ "a" R/ ^a/m matches? ] unit-test
[ f ] [ "\na" R/ ^a/m matches? ] unit-test
[ 1 ] [ "\na" R/ ^a/m count-matches ] unit-test
[ 1 ] [ "\r\na" R/ ^a/m count-matches ] unit-test
[ 1 ] [ "\ra" R/ ^a/m count-matches ] unit-test

[ t ] [ "a" R/ a$/m matches? ] unit-test
[ f ] [ "a\n" R/ a$/m matches? ] unit-test
[ 1 ] [ "a\n" R/ a$/m count-matches ] unit-test
[ 1 ] [ "a\r" R/ a$/m count-matches ] unit-test
[ 1 ] [ "a\r\n" R/ a$/m count-matches ] unit-test

[ f ] [ "foobxr" "foo\\z" <regexp> match-index-head ] unit-test
[ 3 ] [ "foo" "foo\\z" <regexp> match-index-head ] unit-test

! [ t ] [ "foo" "\\bfoo\\b" <regexp> matches? ] unit-test
! [ t ] [ "afoob" "\\Bfoo\\B" <regexp> matches? ] unit-test
! [ t ] [ "afoob" "\\bfoo\\b" <regexp> matches? ] unit-test
! [ f ] [ "foo" "\\Bfoo\\B" <regexp> matches? ] unit-test

! [ 3 ] [ "foo bar" "foo\\b" <regexp> match-index-head ] unit-test
! [ f ] [ "fooxbar" "foo\\b" <regexp> matches? ] unit-test
! [ t ] [ "foo" "foo\\b" <regexp> matches? ] unit-test
! [ t ] [ "foo bar" "foo\\b bar" <regexp> matches? ] unit-test
! [ f ] [ "fooxbar" "foo\\bxbar" <regexp> matches? ] unit-test
! [ f ] [ "foo" "foo\\bbar" <regexp> matches? ] unit-test

! [ f ] [ "foo bar" "foo\\B" <regexp> matches? ] unit-test
! [ 3 ] [ "fooxbar" "foo\\B" <regexp> match-index-head ] unit-test
! [ t ] [ "foo" "foo\\B" <regexp> matches? ] unit-test
! [ f ] [ "foo bar" "foo\\B bar" <regexp> matches? ] unit-test
! [ t ] [ "fooxbar" "foo\\Bxbar" <regexp> matches? ] unit-test
! [ f ] [ "foo" "foo\\Bbar" <regexp> matches? ] unit-test

! [ 1 ] [ "aaacb" "a+?" <regexp> match-index-head ] unit-test
! [ 1 ] [ "aaacb" "aa??" <regexp> match-index-head ] unit-test
! [ f ] [ "aaaab" "a++ab" <regexp> matches? ] unit-test
! [ t ] [ "aaacb" "a++cb" <regexp> matches? ] unit-test
! [ 3 ] [ "aacb" "aa?c" <regexp> match-index-head ] unit-test
! [ 3 ] [ "aacb" "aa??c" <regexp> match-index-head ] unit-test

! "ab" "a(?=b*)" <regexp> match
! "abbbbbc" "a(?=b*c)" <regexp> match
! "ab" "a(?=b*)" <regexp> match

! "baz" "(az)(?<=b)" <regexp> first-match
! "cbaz" "a(?<=b*)" <regexp> first-match
! "baz" "a(?<=b)" <regexp> first-match

! "baz" "a(?<!b)" <regexp> first-match
! "caz" "a(?<!b)" <regexp> first-match

! "abcdefg" "a(?=bcdefg)bcd" <regexp> first-match
! "abcdefg" "a(?#bcdefg)bcd" <regexp> first-match
! "abcdefg" "a(?:bcdefg)" <regexp> first-match

! "caba" "a(?<=b)" <regexp> first-match

! capture group 1: "aaaa"  2: ""
! "aaaa" "(a*)(a*)" <regexp> match*
! "aaaa" "(a*)(a+)" <regexp> match*
