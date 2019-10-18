
USING: kernel namespaces math.vectors opengl.lib pos ori turtle self ;

IN: opengl.camera

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: camera-eye ( -- point ) pos> ;

: camera-focus ( -- point ) [ 1 step-turtle pos> ] save-self ;

: camera-up ( -- dirvec )
[ 90 pitch-up pos> 1 step-turtle pos> swap v- ] save-self ;

: do-look-at ( camera -- )
[ >self camera-eye camera-focus camera-up glu-look-at ] with-scope ;
