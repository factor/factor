USING: arrays kernel libs-io sequences prettyprint unix-internals
calendar namespaces math ;
USE: io
IN: shell

TUPLE: unix-shell ;

T{ unix-shell } \ shell set-global

TUPLE: file name mode nlink uid gid size mtime symbol ;

M: unix-shell directory* ( path -- seq )
    dup (directory) [ tuck >r "/" r> 3append stat* 2array ] map-with ;

M: unix-shell make-file ( path -- file )
    first2
    [ stat-mode ] keep
    [ stat-nlink ] keep
    [ stat-uid ] keep
    [ stat-gid ] keep
    [ stat-size ] keep
    [ stat-mtime timespec>timestamp >local-time ] keep
    stat-mode mode>symbol <file> ;

M: unix-shell file. ( file -- )
    [ [ file-mode >oct write ] keep ] with-cell
    [ bl ] with-cell
    [ [ file-nlink unparse write ] keep ] with-cell
    [ bl ] with-cell
    [ [ file-uid unparse write ] keep ] with-cell
    [ bl ] with-cell
    [ [ file-gid unparse write ] keep ] with-cell
    [ bl ] with-cell
    [ [ file-size unparse write ] keep ] with-cell
    [ bl ] with-cell
    [ [ file-mtime file-time-string write ] keep ] with-cell
    [ bl ] with-cell
    [ file-name write ] with-cell ;

USE: unix-internals
M: unix-shell touch-file ( path -- )
    dup open-append dup -1 = [
        drop now dup set-file-times
    ] [
        nip [ now dup set-file-times* ] keep close
    ] if ;
