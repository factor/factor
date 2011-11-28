! Copyright (c) 2010 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays kernel http http.client sequences urls.encoding ;
IN: syndication.pubsubhubbub

<PRIVATE

: <ping-data> ( feeds -- post-data )
    [ url-encode "hub.url=" prepend ] map "&" join
    "hub.mode=publish&" prepend >byte-array
    "application/x-www-form-urlencoded" <post-data> [ data<< ] keep ;

PRIVATE>

: <ping-request> ( feeds url -- request )
    [ <ping-data> ] [ <post-request> ] bi* ;

: ping ( feeds url -- )
    <ping-request> http-request drop
    dup code>> 204 = [ drop ] [ download-failed ] if ;