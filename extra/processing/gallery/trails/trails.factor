
USING: kernel arrays sequences math qualified
       sequences.lib circular processing ui newfx ;

IN: processing.gallery.trails

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Example 33-15 from the Processing book

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: point-list ( n -- seq ) [ drop 0 0 2array ] map <circular> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: dot ( pos percent -- ) 1 swap - 25 * 5 max circle ;

: step ( seq -- )

  no-stroke
  { 1 0.4 } fill

  0 background

  mouse push-circular
    [ dot ]
  each-percent ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: go* ( -- )

  500 500 size*

  [
    100 point-list
      [ step ]
    curry
      draw
  ] setup

  run ;

: go ( -- ) [ go* ] with-ui ;

MAIN: go