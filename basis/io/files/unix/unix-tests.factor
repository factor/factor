USING: tools.test io.files io.files.temp io.pathnames
io.directories io.files.info io.files.info.unix continuations
kernel io.files.unix math.bitwise calendar accessors
math.functions math unix.users unix.groups arrays sequences
grouping io.pathnames.private literals ;
IN: io.files.unix.tests

{ "/usr/libexec/" } [ "/usr/libexec/awk/" parent-directory ] unit-test
{ "/etc/" } [ "/etc/passwd" parent-directory ] unit-test
{ "/" } [ "/etc/" parent-directory ] unit-test
{ "/" } [ "/etc" parent-directory ] unit-test
{ "/" } [ "/" parent-directory ] unit-test

{ f } [ "" root-directory? ] unit-test
{ t } [ "/" root-directory? ] unit-test
{ t } [ "//" root-directory? ] unit-test
{ t } [ "///////" root-directory? ] unit-test

{ "/" } [ "/" file-name ] unit-test
{ "///" } [ "///" file-name ] unit-test

{ "/" } [ "/" "../.." append-path ] unit-test
{ "/" } [ "/" "../../" append-path ] unit-test
{ "/lib" } [ "/" "../lib" append-path ] unit-test
{ "/lib/" } [ "/" "../lib/" append-path ] unit-test
{ "/lib" } [ "/" "../../lib" append-path ] unit-test
{ "/lib/" } [ "/" "../../lib/" append-path ] unit-test

{ "/lib" } [ "/usr/" "/lib" append-path ] unit-test
{ "/lib/" } [ "/usr/" "/lib/" append-path ] unit-test
{ "/lib/bux" } [ "/usr" "/lib/bux" append-path ] unit-test
{ "/lib/bux/" } [ "/usr" "/lib/bux/" append-path ] unit-test
{ t } [ "/foo" absolute-path? ] unit-test

: test-file ( -- path )
    "permissions" temp-file ;

: prepare-test-file ( -- )
    [ test-file delete-file ] ignore-errors
    test-file touch-file ;

: perms ( -- n )
    test-file file-permissions 0o7777 mask ;

prepare-test-file

{ t }
[ test-file flags{ USER-ALL GROUP-ALL OTHER-ALL } set-file-permissions perms 0o777 = ] unit-test

{ t } [ test-file user-read? ] unit-test
{ t } [ test-file user-write? ] unit-test
{ t } [ test-file user-execute? ] unit-test
{ t } [ test-file group-read? ] unit-test
{ t } [ test-file group-write? ] unit-test
{ t } [ test-file group-execute? ] unit-test
{ t } [ test-file other-read? ] unit-test
{ t } [ test-file other-write? ] unit-test
{ t } [ test-file other-execute? ] unit-test

{ t } [ test-file f set-other-execute perms 0o776 = ] unit-test
{ f } [ test-file file-info other-execute? ] unit-test

{ t } [ test-file f set-other-write perms 0o774 = ] unit-test
{ f } [ test-file file-info other-write? ] unit-test

{ t } [ test-file f set-other-read perms 0o770 = ] unit-test
{ f } [ test-file file-info other-read? ] unit-test

{ t } [ test-file f set-group-execute perms 0o760 = ] unit-test
{ f } [ test-file file-info group-execute? ] unit-test

{ t } [ test-file f set-group-write perms 0o740 = ] unit-test
{ f } [ test-file file-info group-write? ] unit-test

{ t } [ test-file f set-group-read perms 0o700 = ] unit-test
{ f } [ test-file file-info group-read? ] unit-test

{ t } [ test-file f set-user-execute perms 0o600 = ] unit-test
{ f } [ test-file file-info other-execute? ] unit-test

{ t } [ test-file f set-user-write perms 0o400 = ] unit-test
{ f } [ test-file file-info other-write? ] unit-test

{ t } [ test-file f set-user-read perms 0o000 = ] unit-test
{ f } [ test-file file-info other-read? ] unit-test

{ t }
[ test-file flags{ USER-ALL GROUP-ALL OTHER-EXECUTE } set-file-permissions perms 0o771 = ] unit-test

prepare-test-file

{ t }
[
    test-file now
    [ set-file-access-time ] 2keep
    [ file-info accessed>> ]
    [ [ [ truncate >integer ] change-second >gmt ] bi@ ] bi* =
] unit-test

{ t }
[
    test-file now
    [ set-file-modified-time ] 2keep
    [ file-info modified>> ]
    [ [ [ truncate >integer ] change-second >gmt ] bi@ ] bi* =
] unit-test

{ t }
[
    test-file now [ dup 2array set-file-times ] 2keep
    [ file-info [ modified>> ] [ accessed>> ] bi ] dip
    3array
    [ [ truncate >integer ] change-second >gmt ] map all-equal?
] unit-test

{ } [ test-file f now 2array set-file-times ] unit-test
{ } [ test-file now f 2array set-file-times ] unit-test
{ } [ test-file f f 2array set-file-times ] unit-test


{ } [ test-file real-user-name set-file-user ] unit-test
{ } [ test-file real-user-id set-file-user ] unit-test
{ } [ test-file real-group-name set-file-group ] unit-test
{ } [ test-file real-group-id set-file-group ] unit-test

{ t } [ test-file file-user-name real-user-name = ] unit-test
{ t } [ test-file file-group-name real-group-name = ] unit-test

{ }
[ test-file real-user-id real-group-id set-file-ids ] unit-test

{ }
[ test-file f real-group-id set-file-ids ] unit-test

{ }
[ test-file real-user-id f set-file-ids ] unit-test

{ }
[ test-file f f set-file-ids ] unit-test

{ t } [ 0o4000 uid? ] unit-test
{ t } [ 0o2000 gid? ] unit-test
{ t } [ 0o1000 sticky? ] unit-test
{ t } [ 0o400 user-read? ] unit-test
{ t } [ 0o200 user-write? ] unit-test
{ t } [ 0o100 user-execute? ] unit-test
{ t } [ 0o040 group-read? ] unit-test
{ t } [ 0o020 group-write? ] unit-test
{ t } [ 0o010 group-execute? ] unit-test
{ t } [ 0o004 other-read? ] unit-test
{ t } [ 0o002 other-write? ] unit-test
{ t } [ 0o001 other-execute? ] unit-test

{ f } [ 0 uid? ] unit-test
{ f } [ 0 gid? ] unit-test
{ f } [ 0 sticky? ] unit-test
{ f } [ 0 user-read? ] unit-test
{ f } [ 0 user-write? ] unit-test
{ f } [ 0 user-execute? ] unit-test
{ f } [ 0 group-read? ] unit-test
{ f } [ 0 group-write? ] unit-test
{ f } [ 0 group-execute? ] unit-test
{ f } [ 0 other-read? ] unit-test
{ f } [ 0 other-write? ] unit-test
{ f } [ 0 other-execute? ] unit-test
