USING: help.html help.topics help.vocabs io.encodings.utf8 io.files
kernel math sequences tools.test vocabs ;

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

{ t } [ all-vocabs-really [ vocab-name "bootstrap" = ] any? ] unit-test

{ f } [
    all-vocabs-really
    [ vocab-name "xml.tests.xmltest.valid.sa.out" = ] any?
] unit-test

{ t } [
    [
        "bootstrap" >vocab-link generate-help-file
        "vocab-bootstrap.html" utf8 file-contents
        "vocab-bootstrap.image.html" subseq-of?
    ] with-test-directory
] unit-test

{ f } [ all-vocabs-really [ vocab-name "sequences.private" = ] any? ] unit-test

{ f } [ all-vocabs-really [ vocab-name "scratchpad" = ] any? ] unit-test
