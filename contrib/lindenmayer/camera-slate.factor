
USING: kernel namespaces generic gadgets vars slate turtle turtle-camera ;

IN: camera-slate

TUPLE: camera-slate ;

C: camera-slate ( -- ) <slate> over set-delegate ;

VAR: camera

camera-slate H{
  { T{ key-down f f "LEFT" }
    [ slate-ns [ [ 5 turn-left ] camera> with-turtle .slate ] bind ] }
  { T{ key-down f f "RIGHT" }
    [ slate-ns [ [ 5 turn-right ] camera> with-turtle .slate ] bind ] }
  { T{ key-down f f "UP" }
    [ slate-ns [ [ 5 pitch-down ] camera> with-turtle .slate ] bind ] }
  { T{ key-down f f "DOWN" }
    [ slate-ns [ [ 5 pitch-up ] camera> with-turtle .slate ] bind ] }
  { T{ key-down f f "LEFT" }
    [ slate-ns [ [ 5 turn-left ] camera> with-turtle .slate ] bind ] }

  { T{ key-down f f "a" }
    [ slate-ns [ [ 1 step-turtle ] camera> with-turtle .slate ] bind ] }
  { T{ key-down f f "z" }
    [ slate-ns [ [ -1 step-turtle ] camera> with-turtle .slate ] bind ] }

  { T{ key-down f f "q" }
    [ slate-ns [ [ 5 roll-left ] camera> with-turtle .slate ] bind ] }
  { T{ key-down f f "w" }
    [ slate-ns [ [ 5 roll-right ] camera> with-turtle .slate ] bind ] }

  { T{ key-down f { A+ } "LEFT" }
    [ slate-ns [ [ 1 strafe-left ] camera> with-turtle .slate ] bind ] }
  { T{ key-down f { A+ } "RIGHT" }
    [ slate-ns [ [ 1 strafe-right ] camera> with-turtle .slate ] bind ] }
  { T{ key-down f { A+ } "UP" }
    [ slate-ns [ [ 1 strafe-up ] camera> with-turtle .slate ] bind ] }
  { T{ key-down f { A+ } "DOWN" }
    [ slate-ns [ [ 1 strafe-down ] camera> with-turtle .slate ] bind ] }
} set-gestures