USING: html.forms furnace.chloe-tags tools.test ;
IN: furnace.chloe-tags.tests

{ f } [ f parse-query-attr ] unit-test

{ f } [ "" parse-query-attr ] unit-test

{ H{ { "a" "b" } } } [
    begin-form
    "b" "a" set-value
    "a" parse-query-attr
] unit-test

{ H{ { "a" "b" } { "c" "d" } } } [
    begin-form
    "b" "a" set-value
    "d" "c" set-value
    "a,c" parse-query-attr
] unit-test
