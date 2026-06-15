USING: accessors alien.strings arrays assocs continuations
destructors io.encodings.utf8 kernel literals math pcre2 pcre2.ffi
pcre2.private ranges random sequences tools.test ;
QUALIFIED: regexp
IN: pcre2.tests

CONSTANT: iso-date "(?P<year>\\d{4})-(?P<month>\\d{2})-(?P<day>\\d{2})"

! ------------------------------------------------------------------
! Helpers

{ { "Bords" "words" "word" } } [
    "Bords, words, word." { ", " ", " "." } split-subseqs
] unit-test

! ------------------------------------------------------------------
! Compilation and pattern info

! Named capturing groups, sorted by group number.
{ { { 1 "year" } { 2 "month" } { 3 "day" } } } [
    iso-date <pcre2> [ handle>> pcre2-name-table-entries ] with-disposal
] unit-test

! Group names map to their capture numbers.
{ { 1 2 3 } } [
    iso-date <pcre2> [
        handle>> { "year" "month" "day" }
        [ utf8 string>alien pcre2_substring_number_from_name ] with map
    ] with-disposal
] unit-test

! A valid pattern compiles to a live handle.
{ t } [ "foo" <pcre2> [ handle>> >boolean ] with-disposal ] unit-test

! A malformed pattern reports an error code and offset.
{ t } [
    [ "foo(" <pcre2> ] [ [ number>> ] [ offset>> ] bi [ 0 > ] both? ] recover
] unit-test

! Patterns are utf8 and unicode aware by default.
{ t } [ "foo" <pcre2> [ PCRE2_UTF has-option? ] with-disposal ] unit-test
{ t } [ "foo" <pcre2> [ PCRE2_UCP has-option? ] with-disposal ] unit-test

! Requesting unknown pattern info throws bad-option.
{ 999 } [
    [
        "foo" <pcre2> [ handle>> 999 pcre2-pattern-info-number ] with-disposal
    ] [ what>> ] recover
] unit-test

! ------------------------------------------------------------------
! Configuration

! The configured newline convention is one of the known values.
{ t } [
    PCRE2_CONFIG_NEWLINE pcre2-config ${
        PCRE2_NEWLINE_CR PCRE2_NEWLINE_LF PCRE2_NEWLINE_CRLF
        PCRE2_NEWLINE_ANY PCRE2_NEWLINE_ANYCRLF PCRE2_NEWLINE_NUL
    } member?
] unit-test

! In this day and age, not supporting unicode is broken.
{ 1 } [ PCRE2_CONFIG_UNICODE pcre2-config ] unit-test

! The 8-bit library is always compiled in.
{ t } [ PCRE2_CONFIG_COMPILED_WIDTHS pcre2-config 1 bitand 0 > ] unit-test

! Requesting an unknown configuration option throws bad-option.
{ 999 } [ [ 999 pcre2-config ] [ what>> ] recover ] unit-test

! Version is reported as a float.
{ t } [ version 10 >= ] unit-test

! ------------------------------------------------------------------
! Tests for findall

{ { } } [ "hello" "goodbye" findall ] unit-test

{ { { { f "foo" } } { { f "bar" } } { { f "baz" } } } } [
    "foo bar baz" "\\w+" findall
] unit-test

{
    { { f "1999-01-12" } { "year" "1999" } { "month" "01" } { "day" "12" } }
} [ "1999-01-12" iso-date findall first ] unit-test

{
    {
        { { f "h" } }
        { { f "e" } }
        { { f "l" } }
        { { f "l" } }
        { { f "o" } }
    }
} [ "hello" "(.)" findall ] unit-test

{ 3 } [
    "2003-10-09 1999-09-01 1514-10-20" iso-date findall length
] unit-test

{ 5 } [ "abcdef" "[a-e]" findall length ] unit-test

{ 3 } [ "foo bar baz" "foo|bar|baz" findall length ] unit-test

{ 3 } [ "örjan är åtta" "[åäö]" findall length ] unit-test

{ 3 } [ "ÅÄÖ" "\\p{Lu}" findall length ] unit-test

{ 3 } [ "foobar" "foo(?=bar)" findall first first second length ] unit-test

{ { { { f ", " } } { { f ", " } } { { f "." } } } } [
    "Words, words, word." "\\W+" findall
] unit-test

{ { ", " ", " "." } } [
    "Words, words, word." "\\W+" findall [ first second ] map
] unit-test

: long-string ( -- x )
    10000 [ CHAR: a CHAR: z [a..b] random ] "" replicate-as ;

! Performance
{ 0 } [ long-string ".{0,15}foobar.{0,10}" findall length ] unit-test

! Empty matches, corner case behavior is copied from pcre2demo.c
{ { { { f "foo" } } { { f "" } } } }
[ "foo" ".*" findall ] unit-test

{ { { { f "" } } { { f "" } } { { f "" } } } }
[ "foo" "B*" findall ] unit-test

! Empty matches in strings with multi-byte characters are tricky.
{ { { { f "" } } { { f "" } } { { f "" } } { { f "" } } } }
[ "öööö" "x*" findall ] unit-test

! ------------------------------------------------------------------
! Tests for matches?

{ t } [ "örjan" "örjan" matches? ] unit-test

{ t } [ "abcö" "\\p{Ll}{4}" matches? ] unit-test

! Unlike PCRE1, PCRE2 does not report inline (?s)/(?i) option settings
! through PCRE2_INFO_ALLOPTIONS, so this is skipped just as it is for
! modern PCRE1 (it only worked up to 8.36).
version 8.36 <= [
    { t t } [
        "(?s)." <pcre2> [ PCRE2_DOTALL has-option? ] with-disposal
        "(?i)x" <pcre2> [ PCRE2_CASELESS has-option? ] with-disposal
    ] unit-test
] when

{ f } [ "\n" "." matches? ] unit-test
{ t } [ "\n" "(?s)." matches? ] unit-test

{ f t } [
    "hello\nthere" "^.*$" matches?
    "hello\nthere" "(?s)^.*$" matches?
] unit-test

! Modes off by default
{ f f } [
    ! Caseless mode
    "x" <pcre2> [ PCRE2_CASELESS has-option? ] with-disposal
    ! Dotall mode
    "." <pcre2> [ PCRE2_DOTALL has-option? ] with-disposal
] unit-test

! Backreferences
{ { t f } } [
    { "response and responsibility" "sense and responsibility" }
    [ "(sens|respons)e and \\1ibility" matches? ] map
] unit-test

{ { t t f } } [
    { "rah rah" "RAH RAH" "RAH rah" } [ "((?i)rah)\\s+\\1" matches? ] map
] unit-test

! ------------------------------------------------------------------
! Splitting

{ { { "Words" "words" "word" } { "Words" "words" "word" } } } [
    "Words, words, word." { "\\W+" "[,. ]" } [ split ] with map
] unit-test

! Test that the regexp syntax works.
{ t } [ "1234abcd" regexp:R/ ^\d+\w+$/ matches? ] unit-test
