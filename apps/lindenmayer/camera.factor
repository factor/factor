USING: kernel math sequences opengl turtle ;
IN: turtle-camera

: camera-eye ( -- array ) position> ;

: camera-focus ( -- array )
push-turtle
1 step-turtle position>
pop-turtle ;

: camera-up ( -- array )
push-turtle
90 pitch-up position> 1 step-turtle position> swap v-
pop-turtle ;

: do-look-at ( -- )
camera-eye first3 camera-focus first3 camera-up first3 gluLookAt ;
