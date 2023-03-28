! Copyright (C) 2013 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: kernel io io.encodings.utf8 io.files math.parser namespaces
prettyprint sequences math combinators ;

IN: webpulse

CONSTANT: REPORT "~/Downloads/report_799030-" inline
CONSTANT: TEST "~/Downloads/report_799030-0.csv" 

TUPLE: webpulse type location period data ;
SYMBOL: current-report
CONSTANT: webpulses { } 
SYMBOL: linecount 1 linecount set

: <webpulse> (  -- )
  webpulse new
  current-report set ; 
   
: do-pulse-report ( line --  )
B  linecount get {
    { 1 [ <webpulse> swap  ] }
    [ drop ] 
  } case
  linecount get 1 +  linecount set
;
  
: do-lines ( -- )
  input-stream get  stream-lines [ do-pulse-report ] each ; 

: do-report ( path -- )
    utf8 [ do-lines ] with-file-reader ;

: do-reports ( -- )
    8 iota [ number>string REPORT prepend ".csv" append do-report ] each ;


