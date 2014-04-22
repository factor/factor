USING: tools.test ;
IN: html.entities

{ "&" } [ "&amp;" html-unescape ] unit-test
{ "a" } [ "&#x61" html-unescape ] unit-test
{ "<foo>" } [ "&lt;foo&gt;" html-unescape ] unit-test

{ "&amp;" } [ "&" html-escape ] unit-test
{ "&lt;foo&gt;" } [ "<foo>" html-escape ] unit-test
