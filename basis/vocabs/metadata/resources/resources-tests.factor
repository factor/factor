! (c)2010 Joe Groff bsd license
USING: sorting tools.test vocabs.metadata.resources ;
IN: vocabs.metadata.resources.tests

[ { "bar" "bas" "foo" } ]
[ "vocabs.metadata.resources.test.1" vocab-resource-files natural-sort ] unit-test

[ { "bar.wtf" "foo.wtf" } ]
[ "vocabs.metadata.resources.test.2" vocab-resource-files natural-sort ] unit-test

[ {
    "resource-dir"
    "resource-dir/bar"
    "resource-dir/bas"
    "resource-dir/bas/zang"
    "resource-dir/bas/zim"
    "resource-dir/foo"
} ] [ "vocabs.metadata.resources.test.3" vocab-resource-files natural-sort ] unit-test
