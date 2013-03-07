! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax kernel math.bitwise core-foundation
literals ;
IN: core-foundation.file-descriptors

TYPEDEF: void* CFFileDescriptorRef
TYPEDEF: int CFFileDescriptorNativeDescriptor
TYPEDEF: void* CFFileDescriptorCallBack
C-TYPE: CFFileDescriptorContext

FUNCTION: CFFileDescriptorRef CFFileDescriptorCreate (
    CFAllocatorRef allocator,
    CFFileDescriptorNativeDescriptor fd,
    Boolean closeOnInvalidate,
    CFFileDescriptorCallBack callout, 
    CFFileDescriptorContext* context
) ;

CONSTANT: kCFFileDescriptorReadCallBack 1
CONSTANT: kCFFileDescriptorWriteCallBack 2
   
FUNCTION: void CFFileDescriptorEnableCallBacks (
    CFFileDescriptorRef f,
    CFOptionFlags callBackTypes
) ;

: enable-all-callbacks ( fd -- )
    flags{ kCFFileDescriptorReadCallBack kCFFileDescriptorWriteCallBack }
    CFFileDescriptorEnableCallBacks ; inline

: <CFFileDescriptor> ( fd callback -- handle )
    [ f swap ] [ t swap ] bi* f CFFileDescriptorCreate
    [ "CFFileDescriptorCreate failed" throw ] unless* ;
