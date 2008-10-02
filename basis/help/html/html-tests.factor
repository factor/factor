IN: help.html.tests
USING: html.streams classes.predicate help.topics help.markup
io.streams.string accessors prettyprint kernel tools.test ;

[ ] [ [ [ \ predicate-instance? def>> . ] with-html-writer ] with-string-writer drop ] unit-test
