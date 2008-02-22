
USING: kernel words namespaces classes parser continuations
       io io.files io.launcher io.sockets
       math math.parser
       combinators sequences splitting quotations arrays strings tools.time
       parser-combinators new-slots accessors assocs.lib
       combinators.cleave bake calendar  ;

IN: builder.util

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: runtime ( quot -- time ) benchmark nip ;

: minutes>ms ( min -- ms ) 60 * 1000 * ;

: file>string ( file -- string ) [ stdio get contents ] with-file-reader ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: to-strings

: to-string ( obj -- str )
  dup class
    {
      { string    [ ] }
      { quotation [ call ] }
      { word      [ execute ] }
      { fixnum    [ number>string ] }
      { array     [ to-strings concat ] }
    }
  case ;

: to-strings ( seq -- str )
  dup [ string? ] all?
    [ ]
    [ [ to-string ] map flatten ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: process* arguments stdin stdout stderr timeout ;

: <process*> process* construct-empty ;

: >desc ( process* -- desc )
  H{ } clone
    over arguments>> [ +arguments+ swap put-at ] when*
    over stdin>>     [ +stdin+     swap put-at ] when*
    over stdout>>    [ +stdout+    swap put-at ] when*
    over stderr>>    [ +stderr+    swap put-at ] when*
    over timeout>>   [ +timeout+   swap put-at ] when*
  nip ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: host-name* ( -- name ) host-name "." split first ;

: datestamp ( -- string )
  now `{ ,[ dup timestamp-year   ]
         ,[ dup timestamp-month  ]
         ,[ dup timestamp-day    ]
         ,[ dup timestamp-hour   ]
         ,[     timestamp-minute ] }
  [ pad-00 ] map "-" join ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: milli-seconds>time ( n -- string )
  1000 /i 60 /mod >r 60 /mod r> 3array [ pad-00 ] map ":" join ;

: eval-file ( file -- obj ) file-contents eval ;

: cat ( file -- ) file-contents print ;

: run-or-bail ( desc quot -- )
  [ [ try-process ] curry   ]
  [ [ throw       ] compose ]
  bi*
  recover ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: bootstrap.image bootstrap.image.download io.streams.null ;

: retrieve-image ( -- ) [ my-arch download-image ] with-null-stream ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: longer? ( seq seq -- ? ) [ length ] 2apply > ; 

: maybe-tail* ( seq n -- seq )
  2dup longer?
    [ tail* ]
    [ drop  ]
  if ;

: cat-n ( file n -- )
  [ file-lines ] [ ] bi*
  maybe-tail*
  [ print ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USE: prettyprint

: to-file ( object file -- ) [ . ] with-file-writer ;