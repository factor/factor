USING: tools.test txon ;

{ "ABC" } [ "ABC" >txon ] unit-test

{ "A\\`C" } [ "A`C" >txon ] unit-test

{ "123" } [ 123 >txon ] unit-test

{ "1\n2\n3" } [ { 1 2 3 } >txon ] unit-test

{ "a:`123`\nb:`456`" } [ H{ { "a" 123 } { "b" 456 } } >txon ] unit-test

{ "foo" } [ "foo" txon> ] unit-test

{ "foo" } [ "   foo   " txon> ] unit-test

{ H{ { "foo" "" } } }
[ "foo:``" txon> ] unit-test

{ H{ { "foo" " " } } }
[ "foo:` `" txon> ] unit-test

{ H{ { "name" "value" } } }
[ "name:`value`" txon> ] unit-test

{ H{ { "name" "value" } } }
[ "  name:`value`  " txon> ] unit-test

{ H{ { "foo`bar" "value" } } }
[ "foo\\`bar:`value`" txon> ] unit-test

{ H{ { "foo" "bar`baz" } } }
[ "foo:`bar\\`baz`" txon> ] unit-test

{ { H{ { "name1" "value1" } } H{ { "name2" "value2" } } } }
[ "name1:`value1`name2:`value2`" txon> ] unit-test

{ H{ { "name1" H{ { "name2" "nested value" } } } } }
[ "name1:`  name2:`nested value` `" txon> ] unit-test

{ "name1:`name2:`nested value``" }
[
    H{ { "name1" H{ { "name2" "nested value" } } } } >txon
] unit-test

{
    H{
        { "name1" H{ { "name2" "value2" } { "name3" "value3" } } }
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
    H{
        { "name1" H{ { "name2" H{ { "name3" "value3" } } } } }
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

{ H{ { "a" { "1" "2" "3" } } } } [ "a:`1\n2\n3`" txon> ] unit-test
