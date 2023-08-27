! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors alien.c-types alien.data alien.endian arrays
assocs calendar classes.struct combinators endian hashtables io
io.encodings.binary io.files kernel locals math math.order
sequences strings ;

IN: tzinfo

<PRIVATE

STRUCT: tzhead
    { tzh_reserved char[16] }
    { tzh_ttisgmtcnt be32 }
    { tzh_ttisstdcnt be32 }
    { tzh_leapcnt be32 }
    { tzh_timecnt be32 }
    { tzh_typecnt be32 }
    { tzh_charcnt be32 } ;

PACKED-STRUCT: ttinfo
    { tt_gmtoff be32 }
    { tt_isdst uchar }
    { tt_abbrind uchar } ;

ERROR: bad-magic ;

: check-magic ( -- )
    4 read "TZif" sequence= [ bad-magic ] unless ;

TUPLE: tzfile header transition-times local-times types abbrevs
leaps is-std is-gmt ;

C: <tzfile> tzfile

: read-be32 ( -- n )
    4 read be32 deref ;

: read-tzfile ( -- tzfile )
    check-magic tzhead read-struct dup {
        [ tzh_timecnt>> [ read-be32 ] replicate ]
        [ tzh_timecnt>> [ read1 ] replicate ]
        [ tzh_typecnt>> [ ttinfo read-struct ] replicate ]
        [ tzh_charcnt>> read ]
        [ tzh_leapcnt>> [ read-be32 read-be32 2array ] replicate ]
        [ tzh_ttisstdcnt>> read ]
        [ tzh_ttisgmtcnt>> read ]
    } cleave <tzfile> ;

:: tznames ( abbrevs -- assoc )
    0 [
        0 over abbrevs index-from dup
    ] [
        [ dupd abbrevs subseq >string 2array ] keep 1 + swap
    ] produce 2nip >hashtable ;

TUPLE: local-time gmt-offset dst? abbrev std? gmt? ;

C: <local-time> local-time

TUPLE: transition seconds timestamp local-time ;

C: <transition> transition

:: tzfile>transitions ( tzfile -- transitions )
    tzfile abbrevs>> tznames :> abbrevs
    tzfile is-std>> :> is-std
    tzfile is-gmt>> :> is-gmt
    tzfile types>> [
        [
            {
                [ tt_gmtoff>> seconds ]
                [ tt_isdst>> 1 = ]
                [ tt_abbrind>> abbrevs at ]
            } cleave
        ] dip
        [ is-std ?nth dup [ 1 = ] when ]
        [ is-gmt ?nth dup [ 1 = ] when ] bi <local-time>
    ] map-index :> local-times
    tzfile transition-times>>
    tzfile local-times>> [
        [ dup unix-time>timestamp ] [ local-times nth ] bi*
        <transition>
    ] 2map ;

TUPLE: tzinfo tzfile transitions ;

C: <tzinfo> tzinfo

: find-transition ( timestamp tzinfo -- transition )
    [ timestamp>unix-time ] [ transitions>> ] bi*
    [ [ seconds>> before? ] with find drop ]
    [ swap [ 1 [-] swap nth ] [ last ] if* ] bi ;

PRIVATE>

: file>tzinfo ( path -- tzinfo )
    binary [
        read-tzfile dup tzfile>transitions <tzinfo>
    ] with-file-reader ;

: from-utc ( timestamp tzinfo -- timestamp' )
    [ drop instant >>gmt-offset ]
    [ find-transition local-time>> gmt-offset>> ] 2bi
    convert-timezone ;

: normalize ( timestamp tzinfo -- timestamp' )
    [ instant convert-timezone ] [ from-utc ] bi* ;

: load-tzinfo ( name -- tzinfo )
    "/usr/share/zoneinfo/" prepend file>tzinfo ;
