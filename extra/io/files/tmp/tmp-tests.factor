USING: io.files io.files.tmp kernel strings tools.test ;
IN: temporary

[ t ] [ tmpdir string? ] unit-test
[ t f ] [ ".tmp" [ dup exists? swap ] with-tmpfile exists? ] unit-test
