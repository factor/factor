! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.syntax combinators csv
io.backend io.encodings.utf8 io.files io.streams.string
io.unix.files kernel math.order namespaces sequences sorting
system unix unix.statfs.linux unix.statvfs.linux
specialized-arrays.direct.uint arrays ;
IN: io.unix.files.linux

TUPLE: linux-file-system-info < unix-file-system-info
namelen ;

M: linux new-file-system-info linux-file-system-info new ;

M: linux file-system-statfs ( path -- byte-array )
    "statfs64" <c-object> tuck statfs64 io-error ;

M: linux statfs>file-system-info ( struct -- statfs )
    {
        [ statfs64-f_type >>type ]
        [ statfs64-f_bsize >>block-size ]
        [ statfs64-f_blocks >>blocks ]
        [ statfs64-f_bfree >>blocks-free ]
        [ statfs64-f_bavail >>blocks-available ]
        [ statfs64-f_files >>files ]
        [ statfs64-f_ffree >>files-free ]
        [ statfs64-f_fsid 2 <direct-uint-array> >array >>id ]
        [ statfs64-f_namelen >>namelen ]
        [ statfs64-f_frsize >>preferred-block-size ]
        ! [ statfs64-f_spare >>spare ]
    } cleave ;

M: linux file-system-statvfs ( path -- byte-array )
    "statvfs64" <c-object> tuck statvfs64 io-error ;

M: linux statvfs>file-system-info ( struct -- statfs )
    {
        [ statvfs64-f_flag >>flags ]
        [ statvfs64-f_namemax >>name-max ]
    } cleave ;

TUPLE: mtab-entry file-system-name mount-point type options
frequency pass-number ;

: mtab-csv>mtab-entry ( csv -- mtab-entry )
    [ mtab-entry new ] dip
    {
        [ first >>file-system-name ]
        [ second >>mount-point ]
        [ third >>type ]
        [ fourth <string-reader> csv first >>options ]
        [ 4 swap nth >>frequency ]
        [ 5 swap nth >>pass-number ]
    } cleave ;

: parse-mtab ( -- array )
    [
        "/etc/mtab" utf8 <file-reader>
        CHAR: \s delimiter set csv
    ] with-scope
    [ mtab-csv>mtab-entry ] map ;

M: linux file-systems
    parse-mtab [
        [ mount-point>> file-system-info ] keep
        {
            [ file-system-name>> >>device-name ]
            [ mount-point>> >>mount-point ]
            [ type>> >>type ]
        } cleave
    ] map ;

ERROR: file-system-not-found ;

M: linux file-system-info ( path -- )
    normalize-path
    [
        [ new-file-system-info ] dip
        [ file-system-statfs statfs>file-system-info ]
        [ file-system-statvfs statvfs>file-system-info ] bi
        file-system-calculations
    ] keep
    
    parse-mtab [ [ mount-point>> ] bi@ <=> invert-comparison ] sort
    [ mount-point>> head? ] with find nip [ file-system-not-found ] unless*
    {
        [ file-system-name>> >>device-name drop ]
        [ mount-point>> >>mount-point drop ]
        [ type>> >>type ]
    } 2cleave ;
