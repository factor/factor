USING: kernel sequences namespaces math assocs words arrays tools.annotations vocabs sorting prettyprint io micros math.statistics accessors ;
IN: wordtimer

SYMBOL: *wordtimes*
SYMBOL: *calling*

: reset-word-timer ( -- ) 
  H{ } clone *wordtimes* set-global
  H{ } clone *calling* set-global ;
    
: lookup-word-time ( wordname -- utime n )
  *wordtimes* get-global [ drop { 0 0 } ] cache first2 ;

: update-times ( utime current-utime current-numinvokes -- utime' invokes' )
  rot [ + ] curry [ 1+ ] bi* ;

: register-time ( utime word -- )
  name>>
  [ lookup-word-time update-times 2array ] keep *wordtimes* get-global set-at ;

: calling ( word -- )
  dup *calling* get-global set-at ; inline

: finished ( word -- )
  *calling* get-global delete-at ; inline

: called-recursively? ( word -- t/f )
  *calling* get-global at ; inline
    
: timed-call ( quot word -- )
  [ calling ] [ >r micro-time r> register-time ] [ finished ] tri ; inline

: time-unless-recursing ( quot word -- )
  dup called-recursively? not
  [ timed-call ] [ drop call ] if ; inline
    
: (add-timer) ( word quot -- quot' )
  [ swap time-unless-recursing ] 2curry ; 

: add-timer ( word -- )
  dup [ (add-timer) ] annotate ;

: add-timers ( vocabspec -- )
  words [ add-timer ] each ;

: reset-vocab ( vocabspec -- )
  words [ reset ] each ;

: dummy-word ( -- ) ;

: time-dummy-word ( -- n )
  [ 100000 [ [ dummy-word ] micro-time , ] times ] { } make median ;

: subtract-overhead ( {oldtime,n} overhead -- {newtime,n} )
  [ first2 ] dip
  swap [ * - ] keep 2array ;
  
: change-global ( variable quot -- )
  global swap change-at ;

: (correct-for-timing-overhead) ( timingshash -- timingshash )
  time-dummy-word [ subtract-overhead ] curry assoc-map ;  

: correct-for-timing-overhead ( -- )
  *wordtimes* [ (correct-for-timing-overhead) ] change-global ;
    
: print-word-timings ( -- )
  *wordtimes* get-global [ swap suffix ] { } assoc>map natural-sort reverse pprint ;


: profile-vocab ( vocabspec quot -- )
  "annotating vocab..." print flush
  over [ reset-vocab ] [ add-timers ] bi
  reset-word-timer
  "executing quotation..." print flush
  [ call ] micro-time >r
  "resetting annotations..." print flush
  swap reset-vocab
  correct-for-timing-overhead
  "total time:" write r> pprint
  print-word-timings ;