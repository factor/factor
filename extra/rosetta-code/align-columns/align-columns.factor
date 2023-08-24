! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: io kernel math math.functions sequences splitting strings ;
IN: rosetta.align-columns

! https://rosettacode.org/wiki/Align_columns

! Given a text file of many lines, where fields within a line
! are delineated by a single 'dollar' character, write a program
! that aligns each column of fields by ensuring that words in each
! column are separated by at least one space. Further, allow for
! each word in a column to be either left justified, right
! justified, or center justified within its column.

! Use the following text to test your programs:

! Given$a$text$file$of$many$lines,$where$fields$within$a$line$
! are$delineated$by$a$single$'dollar'$character,$write$a$program
! that$aligns$each$column$of$fields$by$ensuring$that$words$in$each$
! column$are$separated$by$at$least$one$space.
! Further,$allow$for$each$word$in$a$column$to$be$either$left$
! justified,$right$justified,$or$center$justified$within$its$column.

! Note that:

! * The example input texts lines may, or may not, have trailing
!   dollar characters.
! * All columns should share the same alignment.
! * Consecutive space characters produced adjacent to the end of
!   lines are insignificant for the purposes of the task.
! * Output text will be viewed in a mono-spaced font on a plain
!   text editor or basic terminal.
! * The minimum space between columns should be computed from
!   the text and not hard-coded.
! * It is not a requirement to add separating characters between
!   or around columns.

CONSTANT: example-text "Given$a$text$file$of$many$lines,$where$fields$within$a$line$
are$delineated$by$a$single$'dollar'$character,$write$a$program
that$aligns$each$column$of$fields$by$ensuring$that$words$in$each$
column$are$separated$by$at$least$one$space.
Further,$allow$for$each$word$in$a$column$to$be$either$left$
justified,$right$justified,$or$center$justified$within$its$column."

: split-and-pad ( text -- lines )
    split-lines [ "$" split harvest ] map
    dup longest length
    '[ _ "" pad-tail ] map ;

: column-widths ( columns -- widths )
    [ longest length ] map ;

SINGLETONS: +left+ +middle+ +right+ ;

GENERIC: align-string ( str n alignment -- str' )

M: +left+ align-string  drop CHAR: space pad-tail ;
M: +right+ align-string drop CHAR: space pad-head ;

M: +middle+ align-string
    drop
    over length - 2 /
    [ floor CHAR: space <string> ]
    [ ceiling CHAR: space <string> ] bi surround ;

: align-columns ( columns alignment -- columns' )
    [ dup column-widths ] dip '[
        [ _ align-string ] curry map
    ] 2map ;

: print-aligned ( text alignment -- )
    [ split-and-pad flip ] dip align-columns flip
    [ [ write bl ] each nl ] each ;

! USAGE: example-text +left+ print-aligned
