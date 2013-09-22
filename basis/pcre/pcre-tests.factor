USING:
    accessors
    arrays
    kernel
    math math.ranges
    pcre pcre.ffi pcre.info
    random
    sequences
    splitting
    system
    tools.test ;
IN: pcre.tests

CONSTANT: iso-date "(?P<year>\\d{4})-(?P<month>\\d{2})-(?P<day>\\d{2})"

[ { f -1 } ] [ "foo" (pcre) 3array 1 tail ] unit-test

[ { 1 2 3 } ] [
    iso-date <pcre>
    { "year" "month" "day" } [ pcre_get_stringnumber ] with map
] unit-test

[ t ] [ "foo" <compiled-pcre> pcre>> options PCRE_UTF8 bitand 0 > ] unit-test

os unix? [ [ 10 ] [ PCRE_CONFIG_NEWLINE config ] unit-test ] when

! In this day and age, not supporting utf-8 is broken.
[ 1 ] [ PCRE_CONFIG_UTF8 config ] unit-test

[ 1 ] [ PCRE_CONFIG_UNICODE_PROPERTIES config ] unit-test

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

: long-string ( -- x )
    10000 [ CHAR: a CHAR: z [a,b] random ] "" replicate-as ;

! Performance
[ 0 ] [ long-string ".{0,15}foobar.{0,10}" findall length ] unit-test

! Tests for matches?
[ t ] [ "örjan" "örjan" matches? ] unit-test

[ t ] [ "abcö" "\\p{Ll}{4}" matches? ] unit-test
