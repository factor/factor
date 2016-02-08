! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.directories io.encodings.utf8 io.launcher io.pathnames
math.statistics prettyprint sequences sorting system ;
IN: contributors

: changelog ( -- authors )
    image-path parent-directory [
        "git log --no-merges --pretty=format:%an"
        utf8 [ lines ] with-process-reader
    ] with-directory ;

: contributors ( -- )
    changelog histogram
    sort-values <reversed>
    simple-table. ;

MAIN: contributors
