! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar kernel math math.constants
math.functions prettyprint system threads timers ;
IN: rosetta-code.active-object

! https://rosettacode.org/wiki/Active_object

! In object-oriented programming an object is active when its
! state depends on clock. Usually an active object encapsulates a
! task that updates the object's state. To the outer world the
! object looks like a normal object with methods that can be
! called from outside. Implementation of such methods must have a
! certain synchronization mechanism with the encapsulated task in
! order to prevent object's state corruption.

! A typical instance of an active object is an animation widget.
! The widget state changes with the time, while as an object it
! has all properties of a normal widget.

! The task

! Implement an active integrator object. The object has an input
! and output. The input can be set using the method Input. The
! input is a function of time. The output can be queried using the
! method Output. The object integrates its input over the time and
! the result becomes the object's output. So if the input is K(t)
! and the output is S, the object state S is changed to S + (K(t1)
! + K(t0)) * (t1 - t0) / 2, i.e. it integrates K using the trapeze
! method. Initially K is constant 0 and S is 0.

! In order to test the object:
! * set its input to sin (2π f t), where the frequency f=0.5Hz.
!   The phase is irrelevant.
! * wait 2s
! * set the input to constant 0
! * wait 0.5s

! Verify that now the object's output is approximately 0 (the
! sine has the period of 2s). The accuracy of the result will
! depend on the OS scheduler time slicing and the accuracy of the
! clock.

TUPLE: active-object timer function state previous-time ;

: apply-stack-effect ( quot -- quot' )
    [ call( x -- x ) ] curry ; inline

: nano-to-seconds ( -- seconds ) nano-count 9 10^ / ;

: object-times ( active-object -- t1 t2 )
    [ previous-time>> ]
    [ nano-to-seconds [ >>previous-time drop ] keep ] bi ;

:: adding-function ( t1 t2 active-object -- function )
    t2 t1 active-object function>> apply-stack-effect bi@ +
    t2 t1 - * 2 / [ + ] curry ;

: integrate ( active-object -- )
    [ object-times ]
    [ adding-function ]
    [ swap apply-stack-effect change-state drop ] tri ;

: <active-object> ( -- object )
    active-object new
    0 >>state
    nano-to-seconds >>previous-time
    [ drop 0 ] >>function
    dup [ integrate ] curry 1 nanoseconds every >>timer ;

: destroy ( active-object -- ) timer>> stop-timer ;

: input ( object quot -- object ) >>function ;

: output ( object -- val ) state>> ;

: active-test ( -- )
    <active-object>
    [ 2 pi 0.5 * * * sin ] input
    2 seconds sleep
    [ drop 0 ] input
    0.5 seconds sleep
    [ output . ] [ destroy ] bi ;

MAIN: active-test
