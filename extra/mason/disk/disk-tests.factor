USING: mason.disk tools.test strings sequences ;
IN: mason.disk.tests

[ t ] [ disk-usage string? ] unit-test

[ t ] [ sufficient-disk-space? { t f } member? ] unit-test
