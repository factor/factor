! Copyright (c) 2008 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs hashtables io.files kernel math math.parser namespaces
io.encodings.ascii sequences sets ;
IN: project-euler.079

! http://projecteuler.net/index.php?section=problems&id=79

! DESCRIPTION
! -----------

! A common security method used for online banking is to ask the user for three
! random characters from a passcode. For example, if the passcode was 531278,
! they may asked for the 2nd, 3rd, and 5th characters; the expected reply would
! be: 317.

! The text file, keylog.txt, contains fifty successful login attempts.

! Given that the three characters are always asked for in order, analyse the
! file so as to determine the shortest possible secret passcode of unknown
! length.


! SOLUTION
! --------

<PRIVATE

: source-079 ( -- seq )
    "extra/project-euler/079/keylog.txt" resource-path ascii file-lines ;

: >edges ( seq -- seq )
    [
        [ string>digits [ 2 head , ] keep 2 tail* , ] each
    ] { } make ;

: find-source ( seq -- elt )
    [ keys ] [ values ] bi diff prune
    dup empty? [ "Topological sort failed" throw ] [ first ] if ;

: remove-source ( seq elt -- seq )
    [ swap member? not ] curry filter ;

: (topological-sort) ( seq -- )
    dup length 1 > [
        dup find-source dup , remove-source (topological-sort)
    ] [
        dup empty? [ drop ] [ first [ , ] each ] if
    ] if ;

PRIVATE>

: topological-sort ( seq -- seq )
    [ [ (topological-sort) ] { } make ] keep
    concat prune over diff append ;

: euler079 ( -- answer )
    source-079 >edges topological-sort 10 digits>integer ;

! [ euler079 ] 100 ave-time
! 2 ms run / 0 ms GC ave time - 100 trials

! TODO: prune and diff are relatively slow; topological sort could be
! cleaned up and generalized much better, but it works for this problem

MAIN: euler079
