USING: help.html tools.test help.topics kernel ;
IN: help.html.tests

[ ] [ "xml" >link help>html drop ] unit-test

[ "article-foobar.html" ] [ "foobar" >link topic>filename ] unit-test
