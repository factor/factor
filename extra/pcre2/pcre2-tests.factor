USING: pcre2 sequences tools.test ;

{ { } } [ "hello" "goodbye" findall ] unit-test

{ { { { f "foo" } } { { f "bar" } } { { f "baz" } } } } [ "foo bar baz" "\\w+" findall ] unit-test

{
    { { f "1999-01-12" } { "day" "12" } { "month" "01" } { "year" "1999" } }
} [
    "1999-01-12" "(?P<year>\\d{4})-(?P<month>\\d{2})-(?P<day>\\d{2})"
    findall first
] unit-test
