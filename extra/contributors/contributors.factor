! Copyright (C) 2007, 2008 Slava Pestov, 2020 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: io.directories io.launcher io.pathnames math.statistics
prettyprint sorting system ;
IN: contributors

: changelog ( -- authors )
    image-path parent-directory [
        "git log --no-merges --pretty=format:%aN" process-lines
    ] with-directory ;

: contributors ( -- assoc )
    changelog histogram inv-sort-values ;

: contributors. ( -- )
    contributors simple-table. ;

MAIN: contributors.
