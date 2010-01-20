USING: kernel namespaces math.vectors opengl opengl.glu 4DNav.turtle  ;

IN: 4DNav.camera

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: camera-eye ( -- point ) turtle-pos> ;

: camera-focus ( -- point ) 
    [ 1 step-turtle turtle-pos> ] save-self ;

: camera-up ( -- dirvec )
[ 90 pitch-up turtle-pos> 1 step-turtle turtle-pos> swap v- ] 
    save-self ;

: do-look-at ( camera -- )
[ >self camera-eye camera-focus camera-up gl-look-at ] 
    with-scope ;
