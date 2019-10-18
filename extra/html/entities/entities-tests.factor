USING: tools.test ;
IN: html.entities

{ "&" } [ "&amp;" html-unescape ] unit-test
{ "a" } [ "&#x61" html-unescape ] unit-test
{ "<foo>" } [ "&lt;foo&gt;" html-unescape ] unit-test
{ "This &that" } [ "This &amp;that" html-unescape ] unit-test
{ "This &that" } [ "This &ampthat" html-unescape ] unit-test
{ "a&b<c>d" } [ "a&amp;b&lt;c&gt;d" html-unescape ] unit-test

{ "&amp;" } [ "&" html-escape ] unit-test
{ "&lt;foo&gt;" } [ "<foo>" html-escape ] unit-test
{ "a&amp;b&lt;c&gt;d" } [ "a&b<c>d" html-escape ] unit-test
