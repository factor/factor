IN: mason.common.tests
USING: prettyprint mason.common mason.config
namespaces calendar tools.test io.files io.files.temp io.encodings.utf8 ;

[ "00:01:02" ] [ 62,000,000,000 nanos>time ] unit-test

[ "/home/bobby/builds/factor" ] [
    [
        "/home/bobby/builds" builds-dir set
        builds/factor
    ] with-scope
] unit-test

[ "/home/bobby/builds/2008-09-11-12-23" ] [
    [
        "/home/bobby/builds" builds-dir set
        T{ timestamp
            { year 2008 }
            { month 9 }
            { day 11 }
            { hour 12 }
            { minute 23 }
        } datestamp stamp set
        build-dir
    ] with-scope
] unit-test

[ ] [ "empty-test" temp-file utf8 [ ] with-file-writer ] unit-test

[ "empty-test" temp-file eval-file ] must-fail

[ ] [ "eval-file-test" temp-file utf8 [ { 1 2 3 } . ] with-file-writer ] unit-test

[ { 1 2 3 } ] [ "eval-file-test" temp-file eval-file ] unit-test
