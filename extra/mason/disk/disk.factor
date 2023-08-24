! Copyright (C) 2010 Slava Pestov, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors formatting io.files.info io.pathnames kernel
mason.config math namespaces ;
IN: mason.disk

: Gi ( n -- gibibits ) 30 2^ * ; inline

: sufficient-disk-space? ( -- ? )
    current-directory get find-mount-point mount-point>>
    file-system-info available-space>> 1 Gi > ;

: check-disk-space ( -- )
    sufficient-disk-space? [
        "Less than 1 Gi free disk space." throw
    ] unless ;

: Gi-str ( n -- string ) 1 Gi /f ;

: path>disk-usage ( path -- string )
    find-mount-point mount-point>> file-system-info
    [ used-space>> ] [ available-space>> ] [ total-space>> ] tri
    2dup /f 100 *
    [ [ Gi-str ] tri@ ] dip
    "%0.2fGi used, %0.2fGi avail, %0.2fGi total, %0.2f%% free" sprintf ;

: disk-usage ( -- string )
    builds-dir get path>disk-usage ;
