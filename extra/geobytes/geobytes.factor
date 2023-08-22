! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators combinators.smart csv io.encodings.latin1
kernel math.parser memoize money sequences unicode ;
IN: geobytes

! GeoBytes is not free software.
! Please read their license should you choose to use it.
! This is just a binding to the GeoBytes CSV files.
! Download and install GeoBytes yourself should you wish to use it.
! https://www.geobytes.com/GeoWorldMap.zip

CONSTANT: geobytes-cities-path "resource:GeoWorldMap/Cities.txt"
CONSTANT: geobytes-countries-path "resource:GeoWorldMap/Countries.txt"
CONSTANT: geobytes-regions-path "resource:GeoWorldMap/Regions.txt"
CONSTANT: geobytes-version-path "resource:GeoWorldMap/version.txt"

TUPLE: country country-id country fips104 iso2 iso3 ison internet capital map-reference
nationality-singular nationality-plural currency currency-code population title
comment ;

TUPLE: region region-id country-id region code adm1-code ;

TUPLE: city city-id country-id region-id city longitude latitude timezone code ;

TUPLE: version component version rows ;

MEMO: load-countries ( -- seq )
    geobytes-countries-path latin1 file>csv rest-slice [
        [
            {
                [ string>number ]
                [ ]
                [ ]
                [ ]
                [ ]
                [ ]
                [ ]
                [ ]
                [ ]
                [ ]
                [ ]
                [ ]
                [ ]
                [ string>number ]
                [ ]
                [ ]
            } spread country boa
        ] input<sequence
    ] map ;

MEMO: load-regions ( -- seq )
    geobytes-regions-path latin1 file>csv rest-slice [
        [
            {
                [ string>number ]
                [ string>number ]
                [ ]
                [ ]
                [ [ blank? ] trim ]
            } spread region boa
        ] input<sequence
    ] map ;

MEMO: load-cities ( -- seq )
    geobytes-cities-path latin1 file>csv rest-slice [
        [
            {
                [ string>number ]
                [ string>number ]
                [ string>number ]
                [ ]
                [ parse-decimal ]
                [ parse-decimal ]
                [ ]
                [ string>number ]
            } spread city boa
        ] input<sequence
    ] map ;

MEMO: load-version ( -- seq )
    geobytes-version-path latin1 file>csv rest-slice [
        [
            {
                [ ]
                [ ]
                [ string>number ]
            } spread version boa
        ] input<sequence
    ] map ;
