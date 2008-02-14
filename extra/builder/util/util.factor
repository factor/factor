
USING: kernel words namespaces classes parser continuations
       io io.files io.launcher io.sockets
       math math.parser
       combinators sequences splitting quotations arrays strings tools.time
       parser-combinators accessors assocs.lib
       combinators.cleave bake calendar new-slots ;

IN: builder.util

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: runtime ( quot -- time ) benchmark nip ;

: minutes>ms ( min -- ms ) 60 * 1000 * ;

: file>string ( file -- string ) [ stdio get contents ] with-file-in ;

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

: eval-file ( file -- obj ) <file-reader> contents eval ;

: cat ( file -- ) <file-reader> contents print ;

: run-or-bail ( desc quot -- )
  [ [ try-process ] curry   ]
  [ [ throw       ] compose ]
  bi*
  recover ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

