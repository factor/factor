! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io.files.info io.pathnames kernel math
math.parser namespaces sequences mason.config ;
IN: mason.disk

: gb ( -- n ) 30 2^ ; inline

: sufficient-disk-space? ( -- ? )
    ! We want at least 300Mb to be available before starting
    ! a build.
    current-directory get file-system-info available-space>>
    gb > ;

: check-disk-space ( -- )
    sufficient-disk-space? [
        "Less than 1 Gb free disk space." throw
    ] unless ;

: mb-str ( n -- string ) gb /i number>string ;

: disk-usage ( -- string )
    builds-dir get file-system-info
    [ used-space>> ] [ total-space>> ] bi
    [ [ mb-str ] bi@ " / " glue " Gb used" append ]
    [ [ 100 * ] dip /i number>string "(" "%)" surround ] 2bi
    " " glue ;
