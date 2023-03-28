! File: itunes.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2017 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors assocs binary-search checksums checksums.fnv1
checksums.sha debugger folder id3 io io.directories
io.encodings.utf8 io.files io.pathnames kernel math math.order
namespaces prettyprint regexp sequences sequences.extras
folder.duplicates splitting string threads xml ;

FROM: string => to-folder ;
FROM: folder => pathname ;
IN: itunes

CONSTANT: ITUNES-FOLDER "/Users/davec/Music/iTunes"
CONSTANT: CHECK-FOLDER "/Volumes/alpha_music"

: get-xml ( -- xml )
    ITUNES-FOLDER "/iTunes Music Library.xml" append
    file>xml ; 
