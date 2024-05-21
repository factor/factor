
USING: assocs combinators command-line.parser
command-line.parser.private kernel math math.parser sequences
tools.test ;

IN: command-line.parser.tests

[
    { } { "--foo" } (parse-options)
] [ unknown-option? ] must-fail-with

[
    { T{ option { name "foo" } } }
    { "--foo" } (parse-options)
] [ expected-arguments? ] must-fail-with

{ H{ { "username" "test" } } { } } [
    { T{ option { name "username" } } }
    { "--user" "test" } (parse-options)
] unit-test

{
    {
        { H{ { "sum" maximum } } { } }
        { H{ { "sum" maximum } } { "1" } }
        { H{ { "sum" sum } } { } }
        { H{ { "sum" sum } } { "1" "2" "3" } }
    }
} [
    {
        T{ option
            { name "sum" }
            { const sum }
            { default maximum }
        }
    } {
        { }
        { "1" }
        { "--sum" }
        { "--sum" "1" "2" "3" }
    } [ (parse-options) ] with map>alist
] unit-test

[
    {
        T{ option { name "fool" } }
        T{ option { name "food" } }
    } { "--foo" } (parse-options)
] [ ambiguous-option? ] must-fail-with

{
    {
        { H{ { "foo" 12 } } { } }
        { H{ { "foo" 10 } } { } }
        { H{ { "foo" f } } { } }
    }
} [
    {
        T{ option
            { name "foo" }
            { const 10 }
            { default 12 }
        }
    } {
        { }
        { "--foo" }
        { "--no-foo" }
    } [ (parse-options) ] with map>alist
] unit-test

{
    {
        { H{ { "port" 1234 } } { } }
        { H{ { "port" 4567 } } { } }
    }
} [
    {
        T{ option
            { name "port" }
            { type integer }
            { convert [ string>number ] }
            { default 1234 }
        }
    } {
        { }
        { "--port" "4567" }
    } [ (parse-options) ] with map>alist
] unit-test

[
    {
        T{ option
            { name "port" }
            { type integer }
            { convert [ string>number ] }
            { default 1234 }
        }
    } { "--port" "food" } (parse-options)
] [ invalid-value? ] must-fail-with
