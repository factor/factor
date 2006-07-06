! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: objc

! In their infinite wisdom, Apple's struct-returning Objective C
! messages do not use their own documented ABI; instead they
! pop one of the input parameters off the stack. We compensate
! for that here.

! when calling an stret via objc_msgSend_stret, it pops the 
! struct off the stack for us!
: (post-stret) ;

\ (post-stret) [ EAX PUSH ] H{ } define-intrinsic

! when an _stret is being called, we must pop the struct off
! the stack before returning
: (pre-stret) ;

\ (pre-stret) [ EAX POP ECX POP EAX PUSH ] H{ } define-intrinsic
