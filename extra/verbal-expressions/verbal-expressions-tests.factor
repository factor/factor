USING: kernel regexp tools.test ;
IN: verbal-expressions

{ f t } [
    <verbexp> something >regexp
    [ "" swap matches? ]
    [ "a" swap matches? ] bi
] unit-test

{ t } [
    "what" <verbexp> anything >regexp matches?
] unit-test

{ f t } [
    <verbexp> start-of-line "w" anything-but >regexp
    [ "what" swap matches? ]
    [ "time" swap matches? ] bi
] unit-test

{ f t f } [
    <verbexp> "a" something-but >regexp
    [ "" swap matches? ]
    [ "b" swap matches? ]
    [ "a" swap matches? ] tri
] unit-test

{ t f } [
    <verbexp> start-of-line "a" then >regexp
    [ "a" swap matches? ]
    [ "ba" swap matches? ] bi
] unit-test

{ t f } [
    <verbexp> "a" then end-of-line >regexp
    [ "a" swap matches? ]
    [ "ab" swap matches? ] bi
] unit-test

{ t t } [
    <verbexp> start-of-line "a" then "b" maybe >regexp
    [ "acb" swap re-contains? ]
    [ "abc" swap re-contains? ] bi
] unit-test

{ t f } [
    <verbexp> start-of-line "a" then "xyz" any-of >regexp
    [ "ay" swap matches? ]
    [ "abc" swap matches? ] bi
] unit-test

{ t f } [
    <verbexp> start-of-line "abc" then -or- "def" then >regexp
    [ "defzz" swap re-contains? ]
    [ "xyzabc" swap re-contains? ] bi
] unit-test

{ t t f } [
    <verbexp> start-of-line "abc" then line-break "def" then >regexp
    [ "abc\r\ndef" swap matches? ]
    [ "abc\ndef" swap matches? ]
    [ "abc\r\n def" swap matches? ] tri
] unit-test

{ t f } [
    <verbexp> start-of-line tab "abc" then >regexp
    [ "\tabc" swap matches? ]
    [ "abc" swap matches? ] bi
] unit-test

{ f } [ "A" <verbexp> start-of-line "a" then >regexp matches? ] unit-test
{ t t } [
    <verbexp> start-of-line "a" then case-insensitive >regexp
    [ "A" swap matches? ]
    [ "a" swap matches? ] bi
] unit-test

! TODO: single-line

{ t } [
    "https://www.google.com"
    <verbexp>
        start-of-line
        "http" then
        "s" maybe
        "://" then
        "www." maybe
        " " anything-but
        end-of-line
    >regexp matches?
] unit-test

