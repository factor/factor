USING: accessors arrays assocs http.client kernel math.ranges
pcre pcre.ffi pcre.private random sequences system tools.test ;
QUALIFIED: regexp
IN: pcre.tests

[ { "Bords" "words" "word" } ] [
    "Bords, words, word." { ", " ", " "." } split-subseqs
] unit-test

[ { { 3 "day" } { 2 "month" } { 1 "year" } } ] [
    "(?P<year>\\d{4})-(?P<month>\\d{2})-(?P<day>\\d{2})"
    <compiled-pcre> nametable>>
] unit-test

CONSTANT: iso-date "(?P<year>\\d{4})-(?P<month>\\d{2})-(?P<day>\\d{2})"

! On windows the erroffset appears to be set to 0 despite there being
! nothing wrong with the regexp.
[ t ] [
    "foo" (pcre) 3array rest { { f -1 } { f 0 } } member?
] unit-test

[ { 1 2 3 } ] [
    iso-date <pcre>
    { "year" "month" "day" } [ pcre_get_stringnumber ] with map
] unit-test

[ t ] [ "foo" <compiled-pcre> PCRE_UTF8 has-option? ] unit-test

os unix? [ [ 10 ] [ PCRE_CONFIG_NEWLINE pcre-config ] unit-test ] when

! In this day and age, not supporting utf-8 is broken.
[ 1 ] [ PCRE_CONFIG_UTF8 pcre-config ] unit-test

[ 1 ] [ PCRE_CONFIG_UNICODE_PROPERTIES pcre-config ] unit-test

! libpcre must not support 16 or 32 bit code points.
[ 0 ] [ PCRE_CONFIG_UTF16 pcre-config ] unit-test
[ 0 ] [ PCRE_CONFIG_UTF32 pcre-config ] unit-test

! Tests for findall
[
    { { f "1999-01-12" } { "year" "1999" } { "month" "01" } { "day" "12" } }
] [
    "1999-01-12" iso-date <compiled-pcre> findall first
] unit-test

[ 3 ] [
    "2003-10-09 1999-09-01 1514-10-20" iso-date <compiled-pcre> findall length
] unit-test

[ 5 ] [ "abcdef" "[a-e]" findall length ] unit-test

[ 3 ] [ "foo bar baz" "foo|bar|baz" findall length ] unit-test

[ 3 ] [ "örjan är åtta" "[åäö]" findall length ] unit-test

[ 3 ] [ "ÅÄÖ" "\\p{Lu}" findall length ] unit-test

[ 3 ] [ "foobar" "foo(?=bar)" findall first first second length ] unit-test

[ { { { f ", " } } { { f ", " } } { { f "." } } } ] [
    "Words, words, word." "\\W+" findall
] unit-test

[ { ", " ", " "." } ] [
    "Words, words, word." "\\W+" findall [ first second ] map
] unit-test

: long-string ( -- x )
    10000 [ CHAR: a CHAR: z [a,b] random ] "" replicate-as ;

! Performance
[ 0 ] [ long-string ".{0,15}foobar.{0,10}" findall length ] unit-test

! Empty matches, corner case behaviour is copied from pcredemo.c
[ { { { f "foo" } } { { f "" } } } ]
[ "foo" ".*" findall ] unit-test

[ { { { f "" } } { { f "" } } { { f "" } } } ]
[ "foo" "B*" findall ] unit-test

! Empty matches in strings with multi-byte characters are tricky.
[ { { { f "" } } { { f "" } } { { f "" } } { { f "" } } } ]
[ "öööö" "x*" findall ] unit-test

! Tests for matches?
[ t ] [ "örjan" "örjan" matches? ] unit-test

[ t ] [ "abcö" "\\p{Ll}{4}" matches? ] unit-test

! Dotall mode, off by default
[ f ] [ "." <compiled-pcre> PCRE_DOTALL has-option? ] unit-test
[ t ] [ "(?s)." <compiled-pcre> PCRE_DOTALL has-option? ] unit-test

[ f ] [ "\n" "." matches? ] unit-test
[ t ] [ "\n" "(?s)." matches? ] unit-test

! Caseless mode, off by default
[ { f t } ] [
    { "x" "(?i)x" } [ <compiled-pcre> PCRE_CASELESS has-option? ] map
] unit-test

! Backreferences
[ { t f } ] [
    { "response and responsibility" "sense and responsibility" }
    [ "(sens|respons)e and \\1ibility" matches? ] map
] unit-test

[ { t t f } ] [
    { "rah rah" "RAH RAH" "RAH rah" } [ "((?i)rah)\\s+\\1" matches? ] map
] unit-test

! Splitting
[ { { "Words" "words" "word" } { "Words" "words" "word" } } ] [
    "Words, words, word." { "\\W+" "[,. ]" } [ split ] with map
] unit-test

! Bigger tests
[ t ] [
    "http://factorcode.org/" http-get nip
    "href=\"(?P<link>[^\"]+)\"" findall [ "link" of ] map sequence?
] unit-test

! Test that the regexp syntax works.
[ t ] [ "1234abcd" regexp:R[ ^\d+\w+$] matches? ] unit-test
