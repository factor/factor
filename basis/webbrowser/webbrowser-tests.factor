USING: io.pathnames tools.test urls webbrowser ;

{ t } [ "http://reddit.com" url-string? ] unit-test
{ t } [ "https://reddit.com" url-string? ] unit-test
{ t } [ "ftp://reddit.com" url-string? ] unit-test
{ f } [ "moo" url-string? ] unit-test
{ f } [ 123 url-string? ] unit-test

! Disabled these tests, which would be nice to have, but hard
! on automated build machines to test and verify.
! { } [ "" absolute-path open-item ] unit-test
! { } [ URL" http://www.google.com" open-item ] unit-test
