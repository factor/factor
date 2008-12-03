
USING: kernel namespaces sequences random math math.constants math.libm vars
       ui
       processing
       processing.gadget
       bubble-chamber.common
       bubble-chamber.particle
       bubble-chamber.particle.muon
       bubble-chamber.particle.quark
       bubble-chamber.particle.hadron
       bubble-chamber.particle.axion ;

IN: bubble-chamber

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VARS: particles muons quarks hadrons axions ;

VAR: boom

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: collide-all ( -- )

  2 pi * 1random >collision-theta

  particles> [ collide ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: collide-one ( -- )

  dim 2 / mouse-x - dim 2 / mouse-y - fatan2 >collision-theta

  hadrons> random collide
  quarks>  random collide
  muons>   random collide ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: mouse-pressed ( -- )
  boom on
  1 background ! kludge
  11 [ drop collide-one ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: key-released ( -- )
  key " " =
    [
      boom on
      1 background
      collide-all
    ]
  when ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bubble-chamber ( -- )

  1000 1000 size*

  [
    1 background
    no-stroke
  
    1789 [ drop <muon>   ] map >muons
    1300 [ drop <quark>  ] map >quarks
    1000 [ drop <hadron> ] map >hadrons
    111  [ drop <axion>  ] map >axions

    muons> quarks> hadrons> axions> 3append append >particles

    collide-one
  ] setup

  [
    boom>
      [ particles> [ move ] each ]
    when
  ] draw

  [ mouse-pressed ] button-down
  [ key-released  ] key-up ;

: go ( -- ) [ bubble-chamber run ] with-ui ;

MAIN: go