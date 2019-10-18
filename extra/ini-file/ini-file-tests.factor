! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: ini-file tools.test ;

{ H{ } } [ "" string>ini ] unit-test

{ H{ { "section" H{ } } } } [ "[section]" string>ini ] unit-test

{ H{ { "section" H{ } } } } [ "[\"section\" ]" string>ini ] unit-test

{ H{ { "   some name with spaces " H{ } } } }
[ "[ \"   some name with spaces \"]" string>ini ] unit-test

{ H{ { "[]" H{ } } } } [ "[\\[\\]]" string>ini ] unit-test

{ H{ { "foo" "bar" } } } [ "foo=bar" string>ini ] unit-test

{ H{ { "foo" "bar" } { "baz" "quz" } } }
[ "foo=bar\nbaz= quz" string>ini ] unit-test

{ H{ { "section" H{ { "foo" "abc def" } } } } }
[
    "
    [section]
    foo = abc def
    " string>ini
] unit-test

{ H{ { "section" H{ { "foo" "abc def" } } } } }
[
    "
    [section]
    foo = abc    \\
          \"def\"
    " string>ini
] unit-test

{ H{ { "section" H{ { "foo" "abc def" } } } } }
[
    "
    [section]
    foo = \"abc \" \\
          def
    " string>ini
] unit-test

{ H{ { "section" H{ { "foo" "abc def" } } } } }
[
    "
    [section]   foo = \"abc def\"
    " string>ini
] unit-test

{ H{ { "section" H{ { "foo" "abc def" } } } } }
[
    "
    [section]   foo = abc \\
    \"def\"
    " string>ini
] unit-test

{ H{ { "section" H{ { "foo" "" } } } } }
[
    "
    [section]
    foo=
    " string>ini
] unit-test

{ H{ { "section" H{ { "foo" "" } } } } }
[
    "
    [section]
    foo
    " string>ini
] unit-test

{ H{ { "" H{ { "" "" } } } } }
[
    "
    []
    =
    " string>ini
] unit-test

{ H{ { "owner" H{ { "name" "John Doe" }
                  { "organization" "Acme Widgets Inc." } } }
     { "database" H{ { "server" "192.0.2.62" }
                     { "port" "143" }
                     { "file" "payroll.dat" } } } } }
[
    "
    ; last modified 1 April 2001 by John Doe
    [owner]
    name=John Doe
    organization=Acme Widgets Inc.

    [database]
    server=192.0.2.62     ; use IP address in case network name resolution is not working
    port=143
    file = \"payroll.dat\"
    " string>ini
] unit-test

{ H{ { "a long section name"
       H{ { "a long key name" "a long value name" } } } } }
[
    "
    [a long section name ]
    a long key name=  a long value name
    " string>ini
] unit-test

{ H{ { "key with \n esc\ape \r codes \""
       "value with \t esc\ape codes" } } }
[
    "
    key with \\n esc\\ape \\r codes \\\" = value with \\t esc\\ape codes
    " string>ini
] unit-test


{ "key with \\n esc\\ape \\r codes \\\"=value with \\t esc\\ape codes\n" }
[
    H{ { "key with \n esc\ape \r codes \""
         "value with \t esc\ape codes" } } ini>string
] unit-test
