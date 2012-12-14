USING: tools.test ;
IN: webbrowser

{ t } [ "http://reddit.com" url-string? ] unit-test
{ t } [ "https://reddit.com" url-string? ] unit-test
{ f } [ "ftp://reddit.com" url-string? ] unit-test
{ f } [ 123 url-string? ] unit-test
