
USING: kernel sequences math math.constants accessors
       processing
       processing.color ;

IN: bubble-chamber.particle.muon.colors

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: good-colors ( -- seq )
  {
    T{ rgba f 0.23 0.14 0.17 1 }
    T{ rgba f 0.23 0.14 0.15 1 }
    T{ rgba f 0.21 0.14 0.15 1 }
    T{ rgba f 0.51 0.39 0.33 1 }
    T{ rgba f 0.49 0.33 0.20 1 }
    T{ rgba f 0.55 0.45 0.32 1 }
    T{ rgba f 0.69 0.63 0.51 1 }
    T{ rgba f 0.64 0.39 0.18 1 }
    T{ rgba f 0.73 0.42 0.20 1 }
    T{ rgba f 0.71 0.45 0.29 1 }
    T{ rgba f 0.79 0.45 0.22 1 }
    T{ rgba f 0.82 0.56 0.34 1 }
    T{ rgba f 0.88 0.72 0.49 1 }
    T{ rgba f 0.85 0.69 0.40 1 }
    T{ rgba f 0.96 0.92 0.75 1 }
    T{ rgba f 0.99 0.98 0.87 1 }
    T{ rgba f 0.85 0.82 0.69 1 }
    T{ rgba f 0.99 0.98 0.87 1 }
    T{ rgba f 0.82 0.82 0.79 1 }
    T{ rgba f 0.65 0.69 0.67 1 }
    T{ rgba f 0.53 0.60 0.55 1 }
    T{ rgba f 0.57 0.53 0.68 1 }
    T{ rgba f 0.47 0.42 0.56 1 }
  } ;

: anti-colors ( -- seq ) good-colors <reversed> ; 

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: color-fraction ( particle -- particle fraction ) dup theta>> pi + 2 pi * / ;

: set-good-color ( particle -- particle )
  color-fraction dup 0 1 between?
    [ good-colors at-fraction-of >>myc ]
    [ drop ]
  if ;

: set-anti-color ( particle -- particle )
  color-fraction dup 0 1 between?
    [ anti-colors at-fraction-of >>mya ]
    [ drop ]
  if ;
