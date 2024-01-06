! Copyright (C) 2012 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax cocoa.plists cocoa.runtime
cocoa.types core-foundation.strings io.files io.files.temp
io.pathnames kernel sequences system ;
IN: io.files.temp.macosx

<PRIVATE

FUNCTION: id NSTemporaryDirectory ( )

TYPEDEF: NSUInteger NSSearchPathDirectory
CONSTANT: NSCachesDirectory 13

TYPEDEF: NSUInteger NSSearchPathDomainMask
CONSTANT: NSUserDomainMask 1

FUNCTION: id NSSearchPathForDirectoriesInDomains (
   NSSearchPathDirectory directory,
   NSSearchPathDomainMask domainMask,
   char expandTilde
)

CONSTANT: factor-bundle-name "org.factorcode.Factor"

: factor-bundle-subdir ( path -- path )
    factor-bundle-name append-path ;

: first-existing ( paths -- path/f )
    [ file-exists? ] find nip ; inline

PRIVATE>

M: macosx default-temp-directory
    NSTemporaryDirectory CF>string factor-bundle-subdir ;

M: macosx default-cache-directory
    NSCachesDirectory NSUserDomainMask 1 NSSearchPathForDirectoriesInDomains
    plist> first-existing [ call-next-method ] unless* factor-bundle-subdir ;
