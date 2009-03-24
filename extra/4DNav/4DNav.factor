! Copyright (C) 2008 Jeff Bigot
! See http://factorcode.org/license.txt for BSD license.
USING: kernel 
namespaces
accessors
assocs
make
math
math.functions
math.trig
math.parser
hashtables
sequences
combinators
continuations
colors
colors.constants
prettyprint
vars
quotations
io
io.directories
io.pathnames
help.markup
io.files
ui.gadgets.panes
 ui
       ui.gadgets
       ui.traverse
       ui.gadgets.borders
       ui.gadgets.frames
       ui.gadgets.tracks
       ui.gadgets.labels
       ui.gadgets.labeled       
       ui.gadgets.lists
       ui.gadgets.buttons
       ui.gadgets.packs
       ui.gadgets.grids
       ui.gadgets.corners
       ui.gestures
       ui.gadgets.scrollers
splitting
vectors
math.vectors
values
4DNav.turtle
4DNav.window3D
4DNav.deep
4DNav.space-file-decoder
models
fry
adsoda
adsoda.tools
;
QUALIFIED-WITH: ui.pens.solid s
QUALIFIED-WITH: ui.gadgets.wrappers w


IN: 4DNav
VALUE: selected-file
VALUE: translation-step
VALUE: rotation-step

3 to: translation-step 
5 to: rotation-step

VAR: selected-file-model
VAR: observer3d 
VAR: view1 
VAR: view2
VAR: view3
VAR: view4
VAR: present-space

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! namespace utilities
    
: make* ( seq -- seq ) [ dup quotation? [ call ] [ ] if ] map ;

: closed-quot ( quot -- quot )
  namestack swap '[ namestack [ _ set-namestack @ ] dip set-namestack ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! waiting for deep-cleave-quots

: 4D-Rxy ( angle -- Rx ) deg>rad
[ 1.0 , 0.0 , 0.0       , 0.0 ,
  0.0 , 1.0 , 0.0       , 0.0 ,
  0.0 , 0.0 , dup cos  , dup sin neg  ,
  0.0 , 0.0 , dup sin  , dup cos  ,  ] 4 make-matrix nip ;

: 4D-Rxz ( angle -- Ry ) deg>rad
[ 1.0 , 0.0       , 0.0 , 0.0 ,
  0.0 , dup cos  , 0.0 , dup sin neg  ,
  0.0 , 0.0       , 1.0 , 0.0 ,
  0.0 , dup sin  , 0.0 , dup cos  ,  ] 4 make-matrix nip ;

: 4D-Rxw ( angle -- Rz ) deg>rad
[ 1.0 , 0.0       , 0.0           , 0.0 ,
  0.0 , dup cos  , dup sin neg  , 0.0 ,
  0.0 , dup sin  , dup cos     , 0.0 ,
  0.0 , 0.0       , 0.0           , 1.0 , ] 4 make-matrix nip ;

: 4D-Ryz ( angle -- Rx ) deg>rad
[ dup cos  , 0.0 , 0.0 , dup sin neg  ,
  0.0       , 1.0 , 0.0 , 0.0 ,
  0.0       , 0.0 , 1.0 , 0.0 ,
  dup sin  , 0.0 , 0.0 , dup cos  ,   ] 4 make-matrix nip ;

: 4D-Ryw ( angle -- Ry ) deg>rad
[ dup cos  , 0.0 , dup sin neg  , 0.0 ,
  0.0       , 1.0 , 0.0           , 0.0 ,
  dup sin  , 0.0 , dup cos     , 0.0 ,
  0.0       , 0.0 , 0.0        , 1.0 ,  ] 4 make-matrix nip ;

: 4D-Rzw ( angle -- Rz ) deg>rad
[ dup cos  , dup sin neg  , 0.0 , 0.0 ,
  dup sin  , dup cos     , 0.0 , 0.0 ,
  0.0       , 0.0           , 1.0 , 0.0 ,
  0.0       , 0.0          , 0.0 , 1.0 ,  ] 4 make-matrix nip ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! UI
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: button* ( string quot -- button ) 
    closed-quot <repeat-button>  ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: model-projection-chooser ( -- gadget )
   observer3d> projection-mode>>
   { { 1 "perspective" } { 0 "orthogonal" } } 
   <radio-buttons> ;

: collision-detection-chooser ( -- gadget )
   observer3d> collision-mode>>
   { { t "on" } { f "off" }  } <radio-buttons> ;

: model-projection ( x -- space ) 
    present-space>  swap space-project ;

: update-observer-projections (  -- )
    view1> relayout-1 
    view2> relayout-1 
    view3> relayout-1 
    view4> relayout-1 ;

: update-model-projections (  -- )
    0 model-projection <model> view1> (>>model)
    1 model-projection <model> view2> (>>model)
    2 model-projection <model> view3> (>>model)
    3 model-projection <model> view4> (>>model) ;

: camera-action ( quot -- quot ) 
    [ drop [ ] observer3d>  
    with-self update-observer-projections ] 
    make* closed-quot ;

: win3D ( text gadget -- ) 
    "navigateur 4D : " rot append open-window ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 4D object manipulation
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: (mvt-4D) ( quot -- )   
    present-space>  
        swap call space-ensure-solids 
    >present-space 
    update-model-projections 
    update-observer-projections ; inline

: rotation-4D ( m -- ) 
    '[ _ [ [ middle-of-space dup vneg ] keep 
        swap space-translate ] dip
         space-transform 
         swap space-translate
    ] (mvt-4D) ;

: translation-4D ( v -- ) '[ _ space-translate ] (mvt-4D) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! menu
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: menu-rotations-4D ( -- gadget )
    3 3 <frame>
        { 1 1 } >>filled-cell
         <pile> 1 >>fill
          "XY +" [ drop rotation-step 4D-Rxy rotation-4D ] 
                button* add-gadget
          "XY -" [ drop rotation-step neg 4D-Rxy rotation-4D ] 
                button* add-gadget 
       @top-left grid-add    
        <pile> 1 >>fill
          "XZ +" [ drop rotation-step 4D-Rxz rotation-4D ] 
                button* add-gadget
          "XZ -" [ drop rotation-step neg 4D-Rxz rotation-4D ] 
                button* add-gadget 
       @top grid-add    
        <pile> 1 >>fill
          "YZ +" [ drop rotation-step 4D-Ryz rotation-4D ] 
                button* add-gadget
          "YZ -" [ drop rotation-step neg 4D-Ryz rotation-4D ] 
                button* add-gadget 
        @center grid-add
         <pile> 1 >>fill
          "XW +" [ drop rotation-step 4D-Rxw rotation-4D ] 
                button* add-gadget
          "XW -" [ drop rotation-step neg 4D-Rxw rotation-4D ] 
                button* add-gadget 
        @top-right grid-add   
         <pile> 1 >>fill
          "YW +" [ drop rotation-step 4D-Ryw rotation-4D ] 
                button* add-gadget
          "YW -" [ drop rotation-step neg 4D-Ryw rotation-4D ] 
                button* add-gadget 
       @right grid-add    
         <pile> 1 >>fill
          "ZW +" [ drop rotation-step 4D-Rzw rotation-4D ] 
                button* add-gadget
          "ZW -" [ drop rotation-step neg 4D-Rzw rotation-4D ] 
                button* add-gadget 
       @bottom-right grid-add    
;

: menu-translations-4D ( -- gadget )
    3 3 <frame> 
        { 1 1 } >>filled-cell
        <pile> 1 >>fill
            <shelf> 1 >>fill  
                "X+" [ drop {  1 0 0 0 } translation-step v*n 
                    translation-4D ] 
                    button* add-gadget
                "X-" [ drop { -1 0 0 0 } translation-step v*n 
                    translation-4D ] 
                    button* add-gadget 
            add-gadget
            "YZW" <label> add-gadget
         @bottom-right grid-add
         <pile> 1 >>fill
            "XZW" <label> add-gadget
            <shelf> 1 >>fill
                "Y+" [ drop  { 0  1 0 0 } translation-step v*n 
                    translation-4D ] 
                    button* add-gadget
                "Y-" [ drop  { 0 -1 0 0 } translation-step v*n 
                    translation-4D ] 
                    button* add-gadget 
                add-gadget
         @top-right grid-add
         <pile> 1 >>fill
            "XYW" <label> add-gadget
            <shelf> 1 >>fill
                "Z+" [ drop { 0 0  1 0 } translation-step v*n 
                    translation-4D ] 
                    button* add-gadget
                "Z-" [ drop { 0 0 -1 0 } translation-step v*n 
                    translation-4D ] 
                    button* add-gadget 
                add-gadget                 
        @top-left grid-add     
        <pile> 1 >>fill
            <shelf> 1 >>fill
                "W+" [ drop { 0 0 0 1  } translation-step v*n 
                    translation-4D ] 
                    button* add-gadget
                "W-" [ drop { 0 0 0 -1 } translation-step v*n 
                    translation-4D ] 
                    button* add-gadget 
                add-gadget
            "XYZ" <label> add-gadget
        @bottom-left grid-add 
        "X" <label> @center grid-add
;

: menu-4D ( -- gadget )  
    <shelf> 
        "rotations" <label>     add-gadget
        menu-rotations-4D       add-gadget
        "translations" <label>  add-gadget
        menu-translations-4D    add-gadget
        0.5 >>align
        { 0 10 } >>gap
;


! ------------------------------------------------------

: redraw-model ( space -- )
    >present-space 
    update-model-projections 
    update-observer-projections ;

: load-model-file ( -- )
  selected-file dup selected-file-model> set-model 
  read-model-file 
  redraw-model ;

: mvt-3D-X ( turn pitch -- quot )
    '[ turtle-pos> norm neg reset-turtle 
        _ turn-left 
        _ pitch-up 
        step-turtle ] ;

: mvt-3D-1 ( -- quot )      90  0 mvt-3D-X ; inline
: mvt-3D-2 ( -- quot )      0  90 mvt-3D-X ; inline
: mvt-3D-3 ( -- quot )      0   0 mvt-3D-X ; inline
: mvt-3D-4 ( -- quot )      45 45 mvt-3D-X ; inline

: camera-button ( string quot -- button ) 
    [ <label>  ] dip camera-action <repeat-button> ;

! ----------------------------------------------------------
! file chooser
! ----------------------------------------------------------
: <run-file-button> ( file-name -- button )
  dup '[ drop  _  \ selected-file set-value load-model-file 
   ] 
 closed-quot  <roll-button> { 0 0 } >>align ;

: <list-runner> ( -- gadget )
    "resource:extra/4DNav" 
  <pile> 1 >>fill 
    over dup directory-files  
    [ ".xml" tail? ] filter 
    [ append-path ] with map
    [ <run-file-button> add-gadget ] each
    swap <labeled-gadget> ;

! -----------------------------------------------------

: menu-rotations-3D ( -- gadget )
    3 3 <frame>
        { 1 1 } >>filled-cell
        "Turn\n left"  [ rotation-step  turn-left  ] 
            camera-button   @left grid-add     
        "Turn\n right" [ rotation-step turn-right ] 
            camera-button   @right grid-add     
        "Pitch down"   [ rotation-step  pitch-down ] 
            camera-button   @bottom grid-add     
        "Pitch up"     [ rotation-step  pitch-up   ] 
            camera-button   @top grid-add     
        <shelf>  1 >>fill
            "Roll left\n (ctl)"  [ rotation-step  roll-left  ] 
                camera-button   add-gadget  
            "Roll right\n(ctl)"  [ rotation-step  roll-right ] 
                camera-button   add-gadget  
        @center grid-add 
;

: menu-translations-3D ( -- gadget )
    3 3 <frame>
        { 1 1 } >>filled-cell
        "left\n(alt)"        [ translation-step  strafe-left  ]
            camera-button @left grid-add  
        "right\n(alt)"       [ translation-step  strafe-right ]
            camera-button @right grid-add     
        "Strafe up \n (alt)" [ translation-step strafe-up    ] 
            camera-button @top grid-add
        "Strafe down\n (alt)" [ translation-step strafe-down  ]
            camera-button @bottom grid-add    
        <pile>  1 >>fill
            "Forward (ctl)"  [  translation-step step-turtle ] 
                camera-button add-gadget
            "Backward (ctl)" 
                [ translation-step neg step-turtle ] 
                camera-button   add-gadget
        @center grid-add
;

: menu-quick-views ( -- gadget )
    <shelf>
        "View 1 (1)" mvt-3D-1 camera-button   add-gadget
        "View 2 (2)" mvt-3D-2 camera-button   add-gadget
        "View 3 (3)" mvt-3D-3 camera-button   add-gadget 
        "View 4 (4)" mvt-3D-4 camera-button   add-gadget 
;

: menu-3D ( -- gadget ) 
    <pile>
        <shelf>   
            menu-rotations-3D    add-gadget
            menu-translations-3D add-gadget
            0.5 >>align
            { 0 10 } >>gap
        add-gadget
        menu-quick-views add-gadget ; 

TUPLE: handler < w:wrapper table ;

: <handler> ( child -- handler ) handler w:new-wrapper ;

M: handler handle-gesture ( gesture gadget -- ? )
   tuck table>> at dup [ call( gadget -- ) f ] [ 2drop t ] if ;

: add-keyboard-delegate ( obj -- obj )
 <handler>
{
        { T{ key-down f f "LEFT" }  
            [ [ rotation-step turn-left ] camera-action ] }
        { T{ key-down f f "RIGHT" } 
            [ [ rotation-step turn-right ] camera-action ] }
        { T{ key-down f f "UP" }    
            [ [ rotation-step pitch-down ] camera-action ] }
        { T{ key-down f f "DOWN" }  
            [ [ rotation-step pitch-up ] camera-action ] }

        { T{ key-down f { C+ } "UP" } 
           [ [ translation-step step-turtle ] camera-action ] }
        { T{ key-down f { C+ } "DOWN" } 
            [ [ translation-step neg step-turtle ] 
                    camera-action ] }
        { T{ key-down f { C+ } "LEFT" } 
            [ [ rotation-step roll-left ] camera-action ] }
        { T{ key-down f { C+ } "RIGHT" } 
            [ [ rotation-step roll-right ] camera-action ] }

        { T{ key-down f { A+ } "LEFT" }  
           [ [ translation-step strafe-left ] camera-action ] }
        { T{ key-down f { A+ } "RIGHT" } 
          [ [ translation-step strafe-right ] camera-action ] }
        { T{ key-down f { A+ } "UP" }    
            [ [ translation-step strafe-up ] camera-action ] }
        { T{ key-down f { A+ } "DOWN" }  
           [ [ translation-step strafe-down ] camera-action ] }


        { T{ key-down f f "1" } [ mvt-3D-1 camera-action ] }
        { T{ key-down f f "2" } [ mvt-3D-2 camera-action ] }
        { T{ key-down f f "3" } [ mvt-3D-3  camera-action ] }
        { T{ key-down f f "4" } [ mvt-3D-4  camera-action ] }

    } [ make* ] map >hashtable >>table
    ;    

! --------------------------------------------
! print elements 
! --------------------------------------------
! print-content

GENERIC: adsoda-display-model ( x -- ) 

M: light adsoda-display-model 
"\n light : " .
     { 
        [ direction>> "direction : " pprint . ] 
        [ color>> "color : " pprint . ]
    }   cleave
    ;

M: face adsoda-display-model 
     {
        [ halfspace>> "halfspace : " pprint . ] 
        [ touching-corners>> "touching corners : " pprint . ]
    }   cleave
    ;
M: solid adsoda-display-model 
     {
        [ name>> "solid called : " pprint . ] 
        [ color>> "color : " pprint . ]
        [ dimension>> "dimension : " pprint . ]
        [ faces>> "composed of faces : " pprint 
            [ adsoda-display-model ] each ]
    }   cleave
    ;
M: space adsoda-display-model 
     {
        [ dimension>> "dimension : " pprint . ] 
        [ ambient-color>> "ambient-color : " pprint . ]
        [ solids>> "composed of solids : " pprint 
            [ adsoda-display-model ] each ]
        [ lights>> "composed of lights : " pprint 
            [ adsoda-display-model ] each ] 
    }   cleave
    ;

! ----------------------------------------------
: menu-bar ( -- gadget )
       <shelf>
          "reinit" [ drop load-model-file ] button* add-gadget
          selected-file-model> <label-control> add-gadget
    ;


: controller-window* ( -- gadget )
    { 0 1 } <track>
        menu-bar f track-add
        <list-runner>  
            <scroller>
        f track-add
        <shelf>
            "Projection mode : " <label> add-gadget
            model-projection-chooser add-gadget
        f track-add
        <shelf>
            "Collision detection (slow and buggy ) : " 
                <label> add-gadget
            collision-detection-chooser add-gadget
        f track-add
        <pile>
            0.5 >>align    
            menu-4D add-gadget 
            COLOR: purple s:<solid> >>interior
            "4D movements" <labeled-gadget>
        f track-add
        <pile>
            0.5 >>align
            { 2 2 } >>gap
            menu-3D add-gadget
            COLOR: purple s:<solid> >>interior
            "Camera 3D" <labeled-gadget>
        f track-add      
        COLOR: gray s:<solid> >>interior
 ;
 
: viewer-windows* ( --  )
    "YZW" view1> win3D 
    "XZW" view2> win3D 
    "XYW" view3> win3D 
    "XYZ" view4> win3D   
;

: navigator-window* ( -- )
    controller-window*
    viewer-windows*   
    add-keyboard-delegate
    "navigateur 4D" open-window
;

: windows ( -- ) [ [ navigator-window* ] with-scope ] with-ui ;


! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init-variables ( -- )
    "choose a file" <model> >selected-file-model  
    <observer> >observer3d
    [ observer3d> >self
      reset-turtle 
      45 turn-left 
      45 pitch-up 
      -300 step-turtle 
    ] with-scope
    
;


: init-models ( -- )
    0 model-projection observer3d> <window3D> >view1
    1 model-projection observer3d> <window3D> >view2
    2 model-projection observer3d> <window3D> >view3
    3 model-projection observer3d> <window3D> >view4
;

: 4DNav ( -- ) 
    init-variables
    selected-file read-model-file >present-space
    init-models
    windows
;

MAIN: 4DNav


