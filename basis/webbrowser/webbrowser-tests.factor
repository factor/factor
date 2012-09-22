USING: tools.test ;
IN: webbrowser

{ t } [ "http://reddit.com" url-like? ] unit-test
{ t } [ "https://reddit.com" url-like? ] unit-test
{ f } [ "ftp://reddit.com" url-like? ] unit-test
{ f } [ 123 url-like? ] unit-test
