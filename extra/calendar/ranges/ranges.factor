! Copyright (C) 2023 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors calendar kernel math math.order ranges.private
sequences sequences.private ;

IN: calendar.ranges

TUPLE: timestamp-range
    { from timestamp read-only }
    { length integer read-only }
    { step duration read-only } ;

: <timestamp-range> ( from to step -- timestamp-range )
    [ dup duration? [ over time+ ] when over time- ] dip [
        [ duration>seconds ] bi@ sign/mod 0 < [ 1 + ] unless 0 max
    ] keep timestamp-range boa ;

M: timestamp-range length length>> ;

M: timestamp-range nth-unsafe
    [ step>> duration* ] keep from>> time+ ;

INSTANCE: timestamp-range sequence
