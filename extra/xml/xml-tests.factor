USING: io.files tools.test sequences namespaces kernel ;

{
    "arithmetic"
    "errors"
    "soap"
    "templating"
    "test"
}
[
    "resource:extra/xml/test/" swap ".factor" 3append run-test
    failures get push-all
] each
