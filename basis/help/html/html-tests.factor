IN: help.html.tests
USING: help.html tools.test help.topics kernel ;

[ ] [ "xml" >link help>html drop ] unit-test

[ "article-foobar.html" ] [ "foobar" >link topic>filename ] unit-test