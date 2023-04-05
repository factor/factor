! Copyright (C) 2013 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs assocs.extras io io.encodings.ascii
io.launcher kernel locals math math.parser prettyprint sequences
splitting strings vectors ;

IN: unix.ps

TUPLE: psStatus  args fields offsets data ;

: .string+columns ( str -- )
    dup length iota [ 10 mod number>string ] { } map-as "" join . . ;

:: field-offsets ( str -- seq )
    ! str first .string+columns
    str first >vector :> rest!
    f :> next!
    f :> wlist!  f :> olist!
    f :> plist!  f :> inword!  0 :> first!
    0 :> pos!    0 :> count!
    [ rest unclip next!  rest!
      next 32 =
      [  inword
        [ 32 wlist ?push wlist!
          pos first + plist ?push plist!  count 1- pos!
          count 1- olist ?push olist!
          1 first!
          ! "plist: " write plist . "olist: " write olist .
        ] when
        f inword! ]
      [ next wlist ?push wlist!  t inword! ]
      if
      count 1+ count!
      rest length 0= not
    ] loop
    wlist >string " " split
    pos first + plist ?push plist!
    count first - olist ?push olist!
    ! "plist: " write plist . "olist: " write olist .
    plist olist [ 2array ] { } 2map-as  
    H{ } zip-as
    ! dup .
    ;

: ps-status ( args -- psStatus )
    psStatus new  over >>args
    <process>  rot "ps " prepend  >>command
    ascii <process-reader> stream-lines
    1 detach-nth  [ >>data ] dip
    field-offsets >>fields ; 

:: ps-status-data ( psStatus columns -- seq )
    psStatus fields>> :> fields
    columns [ fields at ] map :> cols
    f :> data!  psStatus data>>
    [ :> line  f :> field!  cols
      [ [ second 1+ ] keep first swap
        line subseq  field ?push field!  
      ] each  field data ?push data!  
    ] each data
    ;

: find-command-offset ( processes -- 'processes offset )
    1 detach-nth  first "COMMAND"  swap  start ;

: get-commands ( processes offset -- commands )
    swap [ over tail ] map  nip ;

