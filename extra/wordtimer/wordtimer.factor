USING: kernel sequences namespaces make math assocs words arrays
tools.annotations vocabs sorting prettyprint io system
math.statistics accessors tools.time fry ;
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
  [ calling ] [ [ benchmark ] dip register-time ] [ finished ] tri ; inline

: time-unless-recursing ( quot word -- )
  dup called-recursively? not
  [ timed-call ] [ drop call ] if ; inline
    
: (add-timer) ( word quot -- quot' )
  [ swap time-unless-recursing ] 2curry ; 

: add-timer ( word -- )
  dup '[ [ _ ] dip (add-timer) ] annotate ;

: add-timers ( vocab -- )
  words [ add-timer ] each ;

: reset-vocab ( vocab -- )
  words [ reset ] each ;

: dummy-word ( -- ) ;

: time-dummy-word ( -- n )
  [ 100000 [ [ dummy-word ] benchmark , ] times ] { } make median ;

: subtract-overhead ( {oldtime,n} overhead -- {newtime,n} )
  [ first2 ] dip
  swap [ * - ] keep 2array ;
  
: change-global ( variable quot -- )
  global swap change-at ; inline

: (correct-for-timing-overhead) ( timingshash -- timingshash )
  time-dummy-word [ subtract-overhead ] curry assoc-map ;  

: correct-for-timing-overhead ( -- )
  *wordtimes* [ (correct-for-timing-overhead) ] change-global ;
    
: print-word-timings ( -- )
  *wordtimes* get-global [ swap suffix ] { } assoc>map natural-sort reverse pprint ;

: wordtimer-call ( quot -- )
  reset-word-timer 
  benchmark [
      correct-for-timing-overhead
      "total time:" write
  ] dip pprint nl
  print-word-timings nl ; inline

: profile-vocab ( vocab quot -- )
  "annotating vocab..." print flush
  over [ reset-vocab ] [ add-timers ] bi
  reset-word-timer
  "executing quotation..." print flush
  benchmark [
      "resetting annotations..." print flush
      reset-vocab
      correct-for-timing-overhead
      "total time:" write
  ] dip pprint
  print-word-timings ; inline
