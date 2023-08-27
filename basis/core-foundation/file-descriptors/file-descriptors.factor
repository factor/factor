! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax core-foundation kernel
literals ;
IN: core-foundation.file-descriptors

TYPEDEF: void* CFFileDescriptorRef
TYPEDEF: int CFFileDescriptorNativeDescriptor

CALLBACK: void CFFileDescriptorCallBack (
   CFFileDescriptorRef f,
   CFOptionFlags callBackTypes,
   void *info
)

C-TYPE: CFFileDescriptorContext

FUNCTION: CFFileDescriptorRef CFFileDescriptorCreate (
    CFAllocatorRef allocator,
    CFFileDescriptorNativeDescriptor fd,
    Boolean closeOnInvalidate,
    CFFileDescriptorCallBack callout,
    CFFileDescriptorContext* context
)

CONSTANT: kCFFileDescriptorReadCallBack 1
CONSTANT: kCFFileDescriptorWriteCallBack 2

FUNCTION: void CFFileDescriptorEnableCallBacks (
    CFFileDescriptorRef f,
    CFOptionFlags callBackTypes
)

: enable-all-callbacks ( fd -- )
    flags{
        kCFFileDescriptorReadCallBack
        kCFFileDescriptorWriteCallBack
    } CFFileDescriptorEnableCallBacks ; inline

: <CFFileDescriptor> ( fd callback -- handle )
    [ f ] 2dip [ t ] dip f CFFileDescriptorCreate
    [ "CFFileDescriptorCreate failed" throw ] unless* ;
