! Copyright (C) 2009 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: cgi cgi.private kernel tools.test ;

[ t ] [ H{ } "" (query-string) = ] unit-test

[ t ] [ H{ { "a" { "1" } } { "b" { "2" } } }
        "a=1&b=2" (query-string) = ] unit-test

[ t ] [ H{ { "a" { "1" } } { "b" { "2" "3" } } }
        "a=1&b=2&b=3" (query-string) = ] unit-test

[ t ] [ "text/html" (content-type)
        [ H{ } = ] [ "text/html" = ] bi* and ] unit-test

[ t ] [ "text/html; charset=utf-8" (content-type)
        [ H{ { "charset" { "utf-8" } } } = ]
        [ "text/html" = ] bi* and ] unit-test

