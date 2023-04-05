! File: containing.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Collects folders containing a file extension.
!    Example: In my downloads folder I want to find all folders containing .stl files
!    in order to move them to a different folder.
! Copyright (C) 2018 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors assocs checksums checksums.sha continuations
folder io io.directories io.files.links io.pathnames kernel
layouts locals math namespaces prettyprint regexp sequences
sequences.extras serialize splitting threads unix.ffi variables
words ;

IN: folder.containing

VARIABLE: ROOTFOLDER "~/Downloads"

