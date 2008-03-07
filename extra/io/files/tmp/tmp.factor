USING: continuations io io.files kernel sequences strings.lib ;
IN: io.files.tmp

: tmpdir ( -- dirname )
    #! ensure that a tmp dir exists and return its name
    #! I'm using a sub-directory of factor for crossplatconformity (windows doesn't have /tmp)
    "tmp" resource-path dup directory? [ dup make-directory ] unless ;

: touch ( filename -- )
    <file-writer> dispose ;

: tmpfile ( extension -- filename )
    16 random-alphanumeric-string over append
    tmpdir swap path+ dup exists? [
        drop tmpfile
    ] [
        nip dup touch
    ] if ;

: with-tmpfile ( extension quot -- )
    #! quot should have stack effect ( filename -- )
    swap tmpfile tuck swap curry swap [ delete-file ] curry [ ] cleanup ;
