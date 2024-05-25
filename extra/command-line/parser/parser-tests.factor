
USING: assocs combinators command-line command-line.parser
command-line.parser.private io.streams.string kernel math
math.parser namespaces sequences tools.test ;

IN: command-line.parser.tests

TUPLE: foo ;

[
    { T{ option { name "--foo" } { type foo } } }
    { "--foo" "abcd" } (parse-options)
] [ cannot-convert-value? ] must-fail-with

[
    { T{ option { name "--foo" } { required? t } } }
    { } (parse-options)
] [ required-options? ] must-fail-with

[
    { } { "--foo" } (parse-options)
] [ unknown-option? ] must-fail-with

[
    { T{ option { name "--foo" } } }
    { "--foo" } (parse-options)
] [ expected-arguments? ] must-fail-with

{
    {
        H{ { "foo" 10 } }
        H{ { "foo" 12 } }
        H{ { "foo" f } }
    }
} [
    { T{ option { name "--foo" } { default 10 } { const 12 } } }
    {
        { }
        { "--foo" }
        { "--no-foo" }
    } [ (parse-options) ] with map
] unit-test

{ H{ { "username" "test" } } } [
    { T{ option { name "--username" } } }
    { "--user" "test" } (parse-options)
] unit-test

{ H{ { "username" "test" } } } [
    { "--username" } { "--user" "test" } (parse-options)
] unit-test

{
    {
        H{ { "sum" maximum } { "integers" { 1 } } }
        H{ { "sum" sum } { "integers" { 1 2 3 } } }
    }
} [
    {
        T{ option
            { name "--sum" }
            { const sum }
            { default maximum }
        }
        T{ option
            { name "integers" }
            { type integer }
            { #args "+" }
        }
    } {
        { "1" }
        { "--sum" "1" "2" "3" }
    } [ (parse-options) ] with map
] unit-test

[
    {
        T{ option { name "--fool" } }
        T{ option { name "--food" } }
    } { "--foo" } (parse-options)
] [ ambiguous-option? ] must-fail-with

{ H{ { "c" "1" } } } [
    {
        T{ option { name "--force" } }
        T{ option { name "--c" } }
    } { "--c" "1" } (parse-options)
] unit-test

{
    {
        H{ { "foo" 12 } }
        H{ { "foo" 10 } }
        H{ { "foo" f } }
    }
} [
    {
        T{ option
            { name "--foo" }
            { const 10 }
            { default 12 }
        }
    } {
        { }
        { "--foo" }
        { "--no-foo" }
    } [ (parse-options) ] with map
] unit-test

{
    {
        H{ { "port" 1234 } }
        H{ { "port" 4567 } }
    }
} [
    {
        T{ option
            { name "--port" }
            { type integer }
            { convert [ string>number ] }
            { default 1234 }
        }
    } {
        { }
        { "--port" "4567" }
    } [ (parse-options) ] with map
] unit-test

[
    {
        T{ option
            { name "--port" }
            { type integer }
            { convert [ string>number ] }
            { default 1234 }
        }
    } { "--port" "food" } (parse-options)
] [ invalid-value? ] must-fail-with

{
    "Usage:\n    program [--help] [--host HOST] [--port PORT] [--username USERNAME] [--password PASSWORD] [--foo] [--bar]\n\nOptions:\n    --help                 show this help and exit\n    --host HOST            set the hostname (default: 127.0.0.1)\n    --port PORT            set the port (default: 61613)\n    --username USERNAME    set the username\n    --password PASSWORD    set the password\n    --foo                  (default: 10)\n    --bar                  \n"
} [
    [
        H{
            { command-line { "--help" } }
            { program-name "program" }
        } [
            {
                T{ option
                    { name "--host" }
                    { help "set the hostname" }
                    { default "127.0.0.1" }
                }
                T{ option
                    { name "--port" }
                    { type integer }
                    { help "set the port" }
                    { default 61613 }
                }
                T{ option
                    { name "--username" }
                    { help "set the username" }
                }
                T{ option
                    { name "--password" }
                    { help "set the password" }
                }
                T{ option
                    { name "--foo" }
                    { default 10 }
                    { const 12.34 }
                    { required? t }
                }
                T{ option
                    { name "--bar" }
                    { const "12" }
                    { required? t }
                }
            } [ ] with-options
        ] with-variables
    ] with-string-writer
] unit-test

{ H{ { "foo" { "a" "b" } } { "bar" "c" } } } [
    {
        T{ option { name "--foo" } { #args 2 } }
        T{ option { name "bar" } { #args 1 } }
    } { "c" "--foo" "a" "b" } (parse-options)
] unit-test

{
    {
        H{ { "bar" "XX" } { "foo" "YY" } }
        H{ { "bar" "XX" } { "foo" "c" } }
        H{ { "bar" "d" } { "foo" "d" } }
    }
} [
    {
        T{ option { name "--foo" } { #args "?" } { const "c" } { default "d" } }
        T{ option { name "bar" } { #args "?" } { default "d" } }
    } {
        { "XX" "--foo" "YY" }
        { "XX" "--foo" }
        { }
    } [ (parse-options) ] with map
] unit-test

{
    H{
        { "foo" { "x" "y" } }
        { "bar" { "1" "2" } }
        { "baz" { "a" "b" } }
    }
} [
    {
        T{ option { name "--foo" } { #args "*" } }
        T{ option { name "--bar" } { #args "*" } }
        T{ option { name "baz" } { #args "*" } }
    } { "a" "b" "--foo" "x" "y" "--bar" "1" "2" }
    (parse-options)
] unit-test

{ H{ { "foo" { "a" "b" } } } } [
    { T{ option { name "foo" } { #args "+" } } }
    { "a" "b" } (parse-options)
] unit-test

[
    { T{ option { name "foo" } { #args "+" } } }
    { } (parse-options)
] [ required-options? ] must-fail-with

[
    {
        T{ option { name "-n" } { #args "+" } }
        T{ option { name "args" } { #args "*" } }
    } { "-f" } (parse-options)
] [ unknown-option? ] must-fail-with

{
    {
        H{ { "args" { "-f" } } }
        H{ { "n" { "1" "2" "3" } } }
        H{ { "n" { "1" } } { "args" { "2" "3" } } }
    }
} [
    {
        T{ option { name "-n" } { #args "+" } }
        T{ option { name "args" } { #args "*" } }
    } {
        { "--" "-f" }
        { "-n" "1" "2" "3" }
        { "-n" "1" "--" "2" "3" }
    } [ (parse-options) ] with map
] unit-test
