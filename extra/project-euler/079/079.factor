! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs io.encodings.ascii io.files kernel make math
math.parser sequences sets project-euler.common ;
IN: project-euler.079

! https://projecteuler.net/problem=79

! DESCRIPTION
! -----------

! A common security method used for online banking is to ask the
! user for three random characters from a passcode. For example,
! if the passcode was 531278, they may asked for the 2nd, 3rd,
! and 5th characters; the expected reply would be: 317.

! The text file, keylog.txt, contains fifty successful login
! attempts.

! Given that the three characters are always asked for in order,
! analyse the file so as to determine the shortest possible
! secret passcode of unknown length.


! SOLUTION
! --------

<PRIVATE

: source-079 ( -- seq )
    "resource:extra/project-euler/079/keylog.txt" ascii file-lines ;

: >edges ( seq -- seq )
    [
        [ string>digits [ 2 head , ] keep 2 tail* , ] each
    ] { } make ;

: find-source ( seq -- elt )
    unzip diff
    [ "Topological sort failed" throw ] [ first ] if-empty ;

: remove-source ( seq elt -- seq )
    [ swap member? ] curry reject ;

: (topological-sort) ( seq -- )
    dup length 1 > [
        dup find-source dup , remove-source (topological-sort)
    ] [
        [ first [ , ] each ] unless-empty
    ] if ;

PRIVATE>

: topological-sort ( seq -- seq )
    [ [ (topological-sort) ] { } make ] keep
    union-all over diff append ;

: euler079 ( -- answer )
    source-079 >edges topological-sort digits>number ;

! [ euler079 ] 100 ave-time
! 1 ms ave run time - 0.46 SD (100 trials)

! TODO: set words on sequences are relatively slow; topological sort could be
! cleaned up and generalized much better, but it works for this problem

SOLUTION: euler079
