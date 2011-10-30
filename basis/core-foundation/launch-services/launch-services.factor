! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data alien.syntax classes.struct
continuations core-foundation core-foundation.strings
core-foundation.urls destructors kernel sequences
specialized-arrays.instances.alien.c-types.char strings
unix.ffi ;
IN: core-foundation.launch-services

FUNCTION: OSStatus LSFindApplicationForInfo (
   OSType inCreator,
   CFStringRef inBundleID,
   CFStringRef inName,
   FSRef *outAppRef,
   CFURLRef *outAppURL
) ;

FUNCTION: OSStatus FSRefMakePath (
   FSRef *ref,
   UInt8 *path,
   UInt32 maxPathSize
) ;

CONSTANT: kCFAllocatorDefault f
CONSTANT: kLSUnknownCreator f

ERROR: core-foundation-error n ;

: cf-error ( n -- )
    dup 0 = [ drop ] [ core-foundation-error ] if ;

: fsref>string ( fsref -- string )
    MAXPATHLEN [ <char-array> ] [ ] bi
    [ FSRefMakePath cf-error ] [ drop ] 2bi
    [ 0 = ] trim-tail >string ;

: (launch-services-path) ( string -- string' )
    [
        kLSUnknownCreator
        swap <CFString> &CFRelease
        f
        FSRef <struct>
        [ f LSFindApplicationForInfo cf-error ] keep
        fsref>string
    ] with-destructors ;

: launch-services-path ( string -- path/f )
    [ (launch-services-path) ] [ 2drop f ] recover ;
    
