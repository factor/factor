
USING: assocs combinators command-line command-line.parser
command-line.parser.private io.streams.string kernel math
math.parser namespaces sequences tools.test ;

IN: command-line.parser.tests

[
    { } command-line [
        { T{ option { name "--foo" } { required? t } } }
        [ drop ] (with-options)
    ] with-variable
] [ required-options? ] must-fail-with

[
    { } { "--foo" } (parse-options)
] [ unknown-option? ] must-fail-with

[
    { T{ option { name "--foo" } } }
    { "--foo" } (parse-options)
] [ expected-arguments? ] must-fail-with

{ H{ { "username" "test" } } } [
    { T{ option { name "--username" } } }
    { "--user" "test" } (parse-options)
] unit-test

{
    {
        H{ { "sum" maximum } }
        H{ { "sum" maximum } { "integers" { 1 } } }
        H{ { "sum" sum } }
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
        }
    } {
        { }
        { "1" }
        { "--sum" }
        { "--sum" "1" "2" "3" }
    } [ command-line [ [ ] (with-options) ] with-variable ] with map
] unit-test

[
    {
        T{ option { name "--fool" } }
        T{ option { name "--food" } }
    } { "--foo" } (parse-options)
] [ ambiguous-option? ] must-fail-with

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
    } [ command-line [ [ ] (with-options) ] with-variable ] with map
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
    } [ command-line [ [ ] (with-options) ] with-variable ] with map
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
    "Usage:\n    program [options] [arguments]\n\nOptions:\n    --help                 show this help and exit\n    --host HOST            set the hostname (default: 127.0.0.1)\n    --port PORT            set the port (default: 61613)\n    --username USERNAME    set the username\n    --password PASSWORD    set the password\n    --foo                  (default: 10)\n    --bar                  \n\n"
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
            } [ 2drop ] with-options
        ] with-variables
    ] with-string-writer
] unit-test
