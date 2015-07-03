USING: help.html help.vocabs tools.test help.topics kernel sequences vocabs
math ;
IN: help.html.tests

{ } [ "xml" >link help>html drop ] unit-test

{ } [ "foobar" >link topic>filename drop ] unit-test

{ } [ { "foo" "bar" } >link topic>filename drop ] unit-test

{ } [ \ + topic>filename drop ] unit-test

{ } [ \ + >link topic>filename drop ] unit-test

{ } [ "doesnotexist" >vocab-link topic>filename drop ] unit-test

{ } [ "kernel" lookup-vocab topic>filename drop ] unit-test

{ } [ "io" <vocab-tag> topic>filename drop ] unit-test

{ } [ "Steve Jobs" <vocab-author> topic>filename drop ] unit-test

{ } [ f topic>filename drop ] unit-test

{ t } [ all-vocabs-really [ vocab-spec? ] all? ] unit-test

{ t } [ all-vocabs-really [ vocab-name "sequences.private" = ] any? ] unit-test

{ f } [ all-vocabs-really [ vocab-name "scratchpad" = ] any? ] unit-test
