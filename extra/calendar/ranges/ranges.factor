! Copyright (C) 2023 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors calendar kernel math math.functions sequences
sequences.private ;

IN: calendar.ranges

TUPLE: timestamp-range
    { from timestamp read-only }
    { length integer read-only }
    { step duration read-only } ;

:: <timestamp-range> ( from to step -- timestamp-range )
    from
    to from time- step [ duration>seconds ] bi@ /f floor >integer
    step
    timestamp-range boa ;


M: timestamp-range length length>> ;

M: timestamp-range nth-unsafe
    [ step>> duration* ] keep from>> time+ ;

INSTANCE: timestamp-range sequence
