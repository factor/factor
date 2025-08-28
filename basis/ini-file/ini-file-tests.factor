! Copyright (C) 2010 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: ini-file linked-assocs tools.test ;

{ LH{ } } [ "" string>ini ] unit-test

{ LH{ { "section" LH{ } } } } [ "[section]" string>ini ] unit-test

{ "[\"test \\\"section with quotes\\\"\"]\n\n" } [
    "[test \"section with quotes\"]" string>ini ini>string
] unit-test

{ LH{ { "section" LH{ } } } } [ "[\"section\" ]" string>ini ] unit-test

{ LH{ { "   some name with spaces " LH{ } } } }
[ "[ \"   some name with spaces \"]" string>ini ] unit-test

{ LH{ { "[]" LH{ } } } } [ "[\\[\\]]" string>ini ] unit-test

{ LH{ { "foo" "bar" } } } [ "foo=bar" string>ini ] unit-test

{ LH{ { "foo" "bar" } { "baz" "quz" } } }
[ "foo=bar\nbaz= quz" string>ini ] unit-test

{ LH{ { "section" LH{ { "foo" "abc def" } } } } }
[
    "
    [section]
    foo = abc def
    " string>ini
] unit-test

{ LH{ { "section" LH{ { "foo" "abc def" } } } } }
[
    "
    [section]
    foo = abc    \\
          \"def\"
    " string>ini
] unit-test

{ LH{ { "section" LH{ { "foo" "abc def" } } } } }
[
    "
    [section]
    foo = \"abc \" \\
          def
    " string>ini
] unit-test

{ LH{ { "section" LH{ { "foo" "abc def" } } } } }
[
    "
    [section]   foo = \"abc def\"
    " string>ini
] unit-test

{ LH{ { "section" LH{ { "foo" "abc def" } } } } }
[
    "
    [section]   foo = abc \\
    \"def\"
    " string>ini
] unit-test

{ LH{ { "section" LH{ { "foo" "" } } } } }
[
    "
    [section]
    foo=
    " string>ini
] unit-test

{ LH{ { "section" LH{ { "foo" "" } } } } }
[
    "
    [section]
    foo
    " string>ini
] unit-test

{ LH{ { "" LH{ { "" "" } } } } }
[
    "
    []
    =
    " string>ini
] unit-test

{ LH{ { "owner" LH{ { "name" "John Doe" }
                    { "organization" "Acme Widgets Inc." } } }
    { "database" LH{ { "server" "192.0.2.62" }
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

{ LH{ { "a long section name"
       LH{ { "a long key name" "a long value name" } } } } }
[
    "
    [a long section name ]
    a long key name=  a long value name
    " string>ini
] unit-test

{ LH{ { "section with \n escape codes"
    LH{ { "a long key name" "a long value name" } } } } }
[
    "
    [section with \\n escape codes]
    a long key name=  a long value name
    " string>ini
] unit-test

{ LH{ { "key with \n esc\ape \r codes \""
        "value with \t esc\ape codes" } } }
[
    "
    key with \\n esc\\ape \\r codes \\\" = value with \\t esc\\ape codes
    " string>ini
] unit-test


{ "\"key with \\n esc\\ape \\r codes \\\"\"=value with \\t esc\\ape codes\n" }
[
    LH{ { "key with \n esc\ape \r codes \""
         "value with \t esc\ape codes" } } ini>string
] unit-test

{ LH{ { "save_path" "C:\\Temp\\" } } } [
    "save_path = \"C:\\\\Temp\\\\\"" string>ini
] unit-test

{ "save_path=\"C\\:\\\\Temp\\\\\"\n" } [
    LH{ { "save_path" "C:\\Temp\\" } } ini>string
] unit-test
