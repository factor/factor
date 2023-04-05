#!/usr/local/bin/factor -no-user-init
! Copyright (C) 2020 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors http.client io kernel sequences urls xml
xml.traversal splitting.extras ;
IN: wx

SYMBOL: wx-url

FROM: sequences => last ;
: wx-feed ( -- string )
    URL" https://w1.weather.gov/xml/current_obs/KCXO.rss" http-get
    swap code>> 200 = [
        [let 
         bytes>xml body>>
         "channel" tag-named :> channel
         channel "item" tag-named :> item
         item "title" tag-named  children>string
         rest  :> title
         item "description" tag-named  :> description
         description children>> last  rest  
         "\n" split-harvest  [ first ] keep
         second rest  "\n" prepend  append :> wx
         title "\n" append  wx append
        ]
    ]
    [ drop "No WX found" ]
    if
    ;

: wx-print ( -- )   wx-feed print ;
MAIN: wx-print

