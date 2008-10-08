USING: tools.test io.files continuations kernel io.unix.files
math.bitwise calendar accessors math.functions math unix.users
unix.groups arrays sequences ;
IN: io.unix.files.tests

[ "/usr/libexec/" ] [ "/usr/libexec/awk/" parent-directory ] unit-test
[ "/etc/" ] [ "/etc/passwd" parent-directory ] unit-test
[ "/" ] [ "/etc/" parent-directory ] unit-test
[ "/" ] [ "/etc" parent-directory ] unit-test
[ "/" ] [ "/" parent-directory ] unit-test

[ f ] [ "" root-directory? ] unit-test
[ t ] [ "/" root-directory? ] unit-test
[ t ] [ "//" root-directory? ] unit-test
[ t ] [ "///////" root-directory? ] unit-test

[ "/" ] [ "/" file-name ] unit-test
[ "///" ] [ "///" file-name ] unit-test

[ "/" ] [ "/" "../.." append-path ] unit-test
[ "/" ] [ "/" "../../" append-path ] unit-test
[ "/lib" ] [ "/" "../lib" append-path ] unit-test
[ "/lib/" ] [ "/" "../lib/" append-path ] unit-test
[ "/lib" ] [ "/" "../../lib" append-path ] unit-test
[ "/lib/" ] [ "/" "../../lib/" append-path ] unit-test

[ "/lib" ] [ "/usr/" "/lib" append-path ] unit-test
[ "/lib/" ] [ "/usr/" "/lib/" append-path ] unit-test
[ "/lib/bux" ] [ "/usr" "/lib/bux" append-path ] unit-test
[ "/lib/bux/" ] [ "/usr" "/lib/bux/" append-path ] unit-test
[ t ] [ "/foo" absolute-path? ] unit-test

: test-file ( -- path )
    "permissions" temp-file ;

: prepare-test-file ( -- )
    [ test-file delete-file ] ignore-errors
    test-file touch-file ;

: perms ( -- n )
    test-file file-permissions OCT: 7777 mask ;

prepare-test-file

[ t ]
[ test-file { USER-ALL GROUP-ALL OTHER-ALL } flags set-file-permissions perms OCT: 777 = ] unit-test

[ t ] [ test-file user-read? ] unit-test
[ t ] [ test-file user-write? ] unit-test
[ t ] [ test-file user-execute? ] unit-test
[ t ] [ test-file group-read? ] unit-test
[ t ] [ test-file group-write? ] unit-test
[ t ] [ test-file group-execute? ] unit-test
[ t ] [ test-file other-read? ] unit-test
[ t ] [ test-file other-write? ] unit-test
[ t ] [ test-file other-execute? ] unit-test

[ t ]
[ test-file f set-other-execute perms OCT: 776 = ] unit-test

[ t ]
[ test-file f set-other-write perms OCT: 774 = ] unit-test

[ t ]
[ test-file f set-other-read perms OCT: 770 = ] unit-test

[ t ]
[ test-file f set-group-execute perms OCT: 760 = ] unit-test

[ t ]
[ test-file f set-group-write perms OCT: 740 = ] unit-test

[ t ]
[ test-file f set-group-read perms OCT: 700 = ] unit-test

[ t ]
[ test-file f set-user-execute perms OCT: 600 = ] unit-test

[ t ]
[ test-file f set-user-write perms OCT: 400 = ] unit-test

[ t ]
[ test-file f set-user-read perms OCT: 000 = ] unit-test

[ t ]
[ test-file { USER-ALL GROUP-ALL OTHER-EXECUTE } flags set-file-permissions perms OCT: 771 = ] unit-test

prepare-test-file

[ t ]
[
    test-file now
    [ set-file-access-time ] 2keep
    [ file-info accessed>> ]
    [ [ truncate >integer ] change-second ] bi* =
] unit-test

[ t ]
[
    test-file now
    [ set-file-modified-time ] 2keep
    [ file-info modified>> ]
    [ [ truncate >integer ] change-second ] bi* =
] unit-test

[ t ]
[
    test-file now [ dup 2array set-file-times ] 2keep
    [ file-info [ modified>> ] [ accessed>> ] bi ] dip
    3array
    [ [ truncate >integer ] change-second ] map all-equal?
] unit-test

[ ] [ test-file f now 2array set-file-times ] unit-test
[ ] [ test-file now f 2array set-file-times ] unit-test
[ ] [ test-file f f 2array set-file-times ] unit-test


[ ] [ test-file real-username set-file-user ] unit-test
[ ] [ test-file real-user-id set-file-user ] unit-test
[ ] [ test-file real-group-name set-file-group ] unit-test
[ ] [ test-file real-group-id set-file-group ] unit-test

[ t ] [ test-file file-username real-username = ] unit-test
[ t ] [ test-file file-group-name real-group-name = ] unit-test

[ ]
[ test-file real-user-id real-group-id set-file-ids ] unit-test

[ ]
[ test-file f real-group-id set-file-ids ] unit-test

[ ]
[ test-file real-user-id f set-file-ids ] unit-test

[ ]
[ test-file f f set-file-ids ] unit-test
