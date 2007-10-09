
USING: kernel namespaces math.vectors opengl pos ori turtle self ;

IN: opengl.camera

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: camera-eye ( -- point ) pos> ;

: camera-focus ( -- point ) [ 1 step-turtle pos> ] save-self ;

: camera-up ( -- dirvec )
[ 90 pitch-up pos> 1 step-turtle pos> swap v- ] save-self ;

: do-look-at ( camera -- )
[ >self camera-eye camera-focus camera-up gl-look-at ] with-scope ;
