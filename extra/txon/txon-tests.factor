USING: tools.test txon ;

{ "ABC" } [ "ABC" >txon ] unit-test

{ "A\\`C" } [ "A`C" >txon ] unit-test

{ "123" } [ 123 >txon ] unit-test

{ "1\n2\n3" } [ { 1 2 3 } >txon ] unit-test

{ "a:`123`\nb:`456`" } [ H{ { "a" 123 } { "b" 456 } } >txon ] unit-test

{ "foo" } [ "foo" txon> ] unit-test

{ "foo" } [ "   foo   " txon> ] unit-test

{ LH{ { "foo" "" } } }
[ "foo:``" txon> ] unit-test

{ LH{ { "foo" " " } } }
[ "foo:` `" txon> ] unit-test

{ LH{ { "name" "value" } } }
[ "name:`value`" txon> ] unit-test

{ LH{ { "name" "value" } } }
[ "  name:`value`  " txon> ] unit-test

{ LH{ { "foo`bar" "value" } } }
[ "foo\\`bar:`value`" txon> ] unit-test

{ LH{ { "foo" "bar`baz" } } }
[ "foo:`bar\\`baz`" txon> ] unit-test

{ LH{ { "name1" "value1" } { "name2" "value2" } } }
[ "name1:`value1`name2:`value2`" txon> ] unit-test

{ LH{ { "name1" LH{ { "name2" "nested value" } } } } }
[ "name1:`  name2:`nested value` `" txon> ] unit-test

{ "name1:`name2:`nested value``" }
[
    LH{ { "name1" LH{ { "name2" "nested value" } } } } >txon
] unit-test

{
    LH{
        { "name1" LH{ { "name2" "value2" } { "name3" "value3" } } }
    }
} [
    "
    name1:`
        name2:`value2`
        name3:`value3`
    `
    " txon>
] unit-test

{
    LH{
        { "name1" LH{ { "name2" LH{ { "name3" "value3" } } } } }
    }
} [
    "
    name1:`
        name2:`
            name3:`value3`
        `
    `
    " txon>
] unit-test

{ LH{ { "a" { "1" "2" "3" } } } } [ "a:`1\n2\n3`" txon> ] unit-test
