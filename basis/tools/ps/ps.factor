! Copyright (C) 2012 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs io.directories io.pathnames kernel
math.parser prettyprint sequences splitting unix.linux.proc ;
IN: tools.ps

! If cmdline is empty, read the filename from /proc/pid/stat
: ps-cmdline ( path -- path string )
    dup parse-proc-pid-cmdline [
        dup parse-proc-pid-stat filename>>
        [ "()" member? ] trim
        "[" "]" surround
    ] [
        "\0" split " " join
    ] if-empty ;

: ps ( -- assoc )
    "/proc" [
        "." directory-files
        [ file-name string>number ] filter
        [ ps-cmdline ] { } map>assoc
    ] with-directory ;

: ps. ( -- )
    ps simple-table. ;
