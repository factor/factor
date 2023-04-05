! File: solar.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2016 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: arrays assocs calendar calendar.format formatting.private
http.client io io.encodings.utf8 io.files kernel math
math.parser mysql mysql.db2 mysql.db2.connections mysql.db2.lib
prettyprint sequences splitting strings timers urls ;

IN: solar

CONSTANT: url URL" http://10.1.1.91/api/v1/production" 
CONSTANT: solar.csv "~/solar.csv"

SYMBOL: solarData

: write-csv-string ( string -- )
    solar.csv 
    utf8 [ write ] with-file-appender
    ;

: prepend-timestamp ( seq -- seq )
    now [ timestamp>ymd " " append ] keep 
    timestamp>hms  append
    "date" swap 2array 
    prefix
    ;

: solar-http-fetch ( -- seq )
    url http-get nip >string
    string-lines [ ":" split1 ] { } map>assoc
    [ second f = ] reject
    [ [ [ [ 34 = ] keep [ CHAR: , = ] keep 32 = or or ] trim ] map ] map
    ;

: format-slice ( slice -- slice string )
    unclip-slice dup  first ": " append 
    [ second ] dip swap append 
    ;

: unslice ( slice -- seq )
    unclip prefix ;

: show-timestamp ( slice -- )
    format-slice  pprint nl
    format-slice  pprint nl
    drop
    ;

: watts>kw ( number -- string )
    1000 /f  3 format-decimal ;

: get-solar-data ( -- seq )
    solar-http-fetch prepend-timestamp
    ;

: show-solar ( -- )
    get-solar-data    2 cut-slice  swap
    show-timestamp
    unslice
    [ [ first ": " append ] keep second 
      string>number watts>kw append       
      " kW" append
      pprint nl
    ] each
    nl
    ;

FROM: mysql.db2 => new ;

: save-mysql ( -- )
    mysql-args{ "pve.local" "davec" "PMN2213pmn!" "solar" } <mysql-db> new
    "insert into pv (`date`, `today`, `week`, `life`, `now`) values "
    get-solar-data
    [ second dup  string>number  dup
      [ nip  watts>kw ]
      [ drop ]
      if
    ] map
    [ "'" prepend "'" append ] map
    "," join
    "(" prepend  ");" append append
    [ MYSQL ] dip
    mysql-query  2drop
    ;

: save-solar ( -- )
    get-solar-data
    [ second 
      dup  string>number  dup
      [ nip  watts>kw ]
      [ drop ]
      if
      "," append
    ] map
    concat
    [ CHAR: , = ] trim-tail
    "\n" append
    write-csv-string
    ;

: start-solar ( -- )
    [ show-solar save-mysql ] 5 minutes every start-timer ;

MAIN: save-mysql

! : <time-display> ( model -- gadget )
!     [ timestamp>hms ] <arrow> <label-control>
!     "99:99:99" >>string
!     monospace-font >>font ;

! MAIN-WINDOW: solar-window { { title "Solar" } }
!     time get <time-display> >>gadgets ;
