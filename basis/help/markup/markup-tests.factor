USING: accessors arrays assocs definitions fry generic help
help.markup io.streams.string kernel math namespaces parser
sequences sets strings tools.test words ;
IN: help.markup.tests

: with-markup-test ( quot -- )
    [ f last-element ] dip
    '[ _ with-string-writer ] with-variable ; inline

TUPLE: blahblah quux ;

{ "int" } [ [ { "int" } $instance ] with-markup-test ] unit-test

{ } [ \ quux>> print-topic ] unit-test
{ } [ \ >>quux print-topic ] unit-test
{ } [ \ blahblah? print-topic ] unit-test

: fooey ( -- * ) "fooey" throw ;

{ } [ \ fooey print-topic ] unit-test

{ } [ gensym print-topic ] unit-test

{ "a string" }
[ [ { $or string } print-element ] with-markup-test ] unit-test

{ "a string or an integer" }
[ [ { $or string integer } print-element ] with-markup-test ] unit-test

{ "a string, a fixnum, or an integer" }
[ [ { $or string fixnum integer } print-element ] with-markup-test ] unit-test

! Layout

{ "span" }
[ [ { "span" } print-content ] with-markup-test ] unit-test

{ "span1span2" }
[ [ { "span1" "span2" } print-content ] with-markup-test ] unit-test

{ "span1\n\nspan2" }
[ [ { "span1" { $nl } "span2" } print-content ] with-markup-test ] unit-test

{ "\nspan" }
[ [ { { $nl } "span" } print-content ] with-markup-test ] unit-test

{ "2 2 +\nspan" }
[ [ { { $code "2 2 +" } "span" } print-content ] with-markup-test ] unit-test

{ "2 2 +" }
[ [ { { $code "2 2 +" } } print-content ] with-markup-test ] unit-test

{ "span\n2 2 +" }
[ [ { "span" { $code "2 2 +" } } print-content ] with-markup-test ] unit-test

{ "\n2 2 +" }
[ [ { { $nl } { $code "2 2 +" } } print-content ] with-markup-test ] unit-test

{ "span\n\n2 2 +" }
[ [ { "span" { $nl } { $code "2 2 +" } } print-content ] with-markup-test ] unit-test

{ "Heading" }
[ [ { { $heading "Heading" } } print-content ] with-markup-test ] unit-test

{ "Heading1\n\nHeading2" }
[ [ { { $heading "Heading1" } { $heading "Heading2" } } print-content ] with-markup-test ] unit-test

{ "span\n\nHeading" }
[ [ { "span" { $heading "Heading" } } print-content ] with-markup-test ] unit-test

{ "\nHeading" }
[ [ { { $nl } { $heading "Heading" } } print-content ] with-markup-test ] unit-test

{ "span\n\nHeading" }
[ [ { "span" { $nl } { $heading "Heading" } } print-content ] with-markup-test ] unit-test

: word-related-words ( word -- word related-words )
    dup [ "related" word-prop ] [ 1array ] bi diff ;

SYMBOLS:
    1foo 2foo 3foo
    1bar 2bar 3bar ;

{
    1foo { 2foo 3foo }
    1bar { 2bar 3bar }

    1foo { 1bar }
    2foo { 3foo }
    2bar { 3bar }
} [
    { 1foo 2foo 3foo } related-words
    { 1bar 2bar 3bar } related-words

    1foo word-related-words
    1bar word-related-words

    { 2foo 3foo } related-words
    { 1foo 1bar } related-words

    1foo word-related-words
    2foo word-related-words
    2bar word-related-words
] unit-test
