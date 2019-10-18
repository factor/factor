USING: help.html tools.test help.topics kernel sequences vocabs ;
IN: help.html.tests

[ ] [ "xml" >link help>html drop ] unit-test

[ "article-foobar.html" ] [ "foobar" >link topic>filename ] unit-test

[ t ] [ all-vocabs-really [ vocab-spec? ] all? ] unit-test

[ t ] [ all-vocabs-really [ vocab-name "sequences.private" = ] any? ] unit-test

[ f ] [ all-vocabs-really [ vocab-name "scratchpad" = ] any? ] unit-test
