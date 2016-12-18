USING: io.pathnames tools.test ;
IN: webbrowser

{ t } [ "http://reddit.com" url-string? ] unit-test
{ t } [ "https://reddit.com" url-string? ] unit-test
{ t } [ "ftp://reddit.com" url-string? ] unit-test
{ f } [ "moo" url-string? ] unit-test
{ f } [ 123 url-string? ] unit-test

{ } [ "" absolute-path open-item ] unit-test
