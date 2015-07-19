! (c)2012 Joe Groff bsd license
USING: alien.c-types alien.syntax cocoa.plists cocoa.runtime
cocoa.types core-foundation.strings io.directories io.files
io.files.temp io.pathnames kernel sequences system ;
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

: (make-factor-bundle-subdir) ( path -- path )
    factor-bundle-name append-path dup make-directories ;

: (first-existing) ( paths -- path )
    [ exists? ] map-find nip
    [ "no user cache directory found" throw ] unless* ; inline

PRIVATE>

: (temp-directory) ( -- path )
    NSTemporaryDirectory CF>string (make-factor-bundle-subdir) ;

M: macosx temp-directory (temp-directory) ;

: (cache-directory) ( -- path )
    NSCachesDirectory NSUserDomainMask 1 NSSearchPathForDirectoriesInDomains
    plist> (first-existing) (make-factor-bundle-subdir) ;

M: macosx cache-directory (cache-directory) ;
