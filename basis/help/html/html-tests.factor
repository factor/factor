USING: help.html help.vocabs tools.test help.topics kernel sequences vocabs
math ;

{ } [ [ "xml" >link help>html drop ] with-test-directory ] unit-test

{ "article-foobar.html" }
[ "foobar" >link topic>filename ] unit-test

{ "article-foo,bar.html" }
[ { "foo" "bar" } >link topic>filename ] unit-test

{ "word-+,math.html" } [ \ + topic>filename ] unit-test

{ "word-+,math.html" } [ \ + >link topic>filename ] unit-test

{ "vocab-doesnotexist.html" }
[ "doesnotexist" >vocab-link topic>filename ] unit-test

{ "vocab-kernel.html" }
[ "kernel" lookup-vocab topic>filename ] unit-test

{ "tag-io.html" } [ "io" <vocab-tag> topic>filename ] unit-test

{ "author-Steve Jobs.html" }
[ "Steve Jobs" <vocab-author> topic>filename ] unit-test

{ "word-f,syntax.html" } [ f topic>filename ] unit-test

{ t } [ all-vocabs-really [ vocab-spec? ] all? ] unit-test

{ t } [ all-vocabs-really [ vocab-name "sequences" = ] any? ] unit-test

{ f } [ all-vocabs-really [ vocab-name "sequences.private" = ] any? ] unit-test

{ f } [ all-vocabs-really [ vocab-name "scratchpad" = ] any? ] unit-test
