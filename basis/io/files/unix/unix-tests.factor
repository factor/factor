USING: tools.test io.files io.files.temp io.pathnames
io.directories io.files.info io.files.info.unix continuations
kernel io.files.unix math.bitwise calendar accessors
math.functions math unix.users unix.groups arrays sequences
grouping io.pathnames.tests ;
IN: io.files.unix.tests

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

[ t ] [ test-file f set-other-execute perms OCT: 776 = ] unit-test
[ f ] [ test-file file-info other-execute? ] unit-test

[ t ] [ test-file f set-other-write perms OCT: 774 = ] unit-test
[ f ] [ test-file file-info other-write? ] unit-test

[ t ] [ test-file f set-other-read perms OCT: 770 = ] unit-test
[ f ] [ test-file file-info other-read? ] unit-test

[ t ] [ test-file f set-group-execute perms OCT: 760 = ] unit-test
[ f ] [ test-file file-info group-execute? ] unit-test

[ t ] [ test-file f set-group-write perms OCT: 740 = ] unit-test
[ f ] [ test-file file-info group-write? ] unit-test

[ t ] [ test-file f set-group-read perms OCT: 700 = ] unit-test
[ f ] [ test-file file-info group-read? ] unit-test

[ t ] [ test-file f set-user-execute perms OCT: 600 = ] unit-test
[ f ] [ test-file file-info other-execute? ] unit-test

[ t ] [ test-file f set-user-write perms OCT: 400 = ] unit-test
[ f ] [ test-file file-info other-write? ] unit-test

[ t ] [ test-file f set-user-read perms OCT: 000 = ] unit-test
[ f ] [ test-file file-info other-read? ] unit-test

[ t ]
[ test-file { USER-ALL GROUP-ALL OTHER-EXECUTE } flags set-file-permissions perms OCT: 771 = ] unit-test

prepare-test-file

[ t ]
[
    test-file now
    [ set-file-access-time ] 2keep
    [ file-info accessed>> ]
    [ [ [ truncate >integer ] change-second ] bi@ ] bi* =
] unit-test

[ t ]
[
    test-file now
    [ set-file-modified-time ] 2keep
    [ file-info modified>> ]
    [ [ [ truncate >integer ] change-second ] bi@ ] bi* =
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


[ ] [ test-file real-user-name set-file-user ] unit-test
[ ] [ test-file real-user-id set-file-user ] unit-test
[ ] [ test-file real-group-name set-file-group ] unit-test
[ ] [ test-file real-group-id set-file-group ] unit-test

[ t ] [ test-file file-user-name real-user-name = ] unit-test
[ t ] [ test-file file-group-name real-group-name = ] unit-test

[ ]
[ test-file real-user-id real-group-id set-file-ids ] unit-test

[ ]
[ test-file f real-group-id set-file-ids ] unit-test

[ ]
[ test-file real-user-id f set-file-ids ] unit-test

[ ]
[ test-file f f set-file-ids ] unit-test

[ t ] [ OCT: 4000 uid? ] unit-test
[ t ] [ OCT: 2000 gid? ] unit-test
[ t ] [ OCT: 1000 sticky? ] unit-test
[ t ] [ OCT: 400 user-read? ] unit-test
[ t ] [ OCT: 200 user-write? ] unit-test
[ t ] [ OCT: 100 user-execute? ] unit-test
[ t ] [ OCT: 040 group-read? ] unit-test
[ t ] [ OCT: 020 group-write? ] unit-test
[ t ] [ OCT: 010 group-execute? ] unit-test
[ t ] [ OCT: 004 other-read? ] unit-test
[ t ] [ OCT: 002 other-write? ] unit-test
[ t ] [ OCT: 001 other-execute? ] unit-test

[ f ] [ 0 uid? ] unit-test
[ f ] [ 0 gid? ] unit-test
[ f ] [ 0 sticky? ] unit-test
[ f ] [ 0 user-read? ] unit-test
[ f ] [ 0 user-write? ] unit-test
[ f ] [ 0 user-execute? ] unit-test
[ f ] [ 0 group-read? ] unit-test
[ f ] [ 0 group-write? ] unit-test
[ f ] [ 0 group-execute? ] unit-test
[ f ] [ 0 other-read? ] unit-test
[ f ] [ 0 other-write? ] unit-test
[ f ] [ 0 other-execute? ] unit-test
