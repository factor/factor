! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data alien.syntax continuations
core-foundation core-foundation.strings core-foundation.urls
destructors kernel sequences specialized-arrays strings unix.ffi ;
SPECIALIZED-ARRAY: char
IN: core-foundation.launch-services

FUNCTION: OSStatus LSFindApplicationForInfo (
   OSType inCreator,
   CFStringRef inBundleID,
   CFStringRef inName,
   FSRef *outAppRef,
   CFURLRef *outAppURL
)

FUNCTION: OSStatus FSRefMakePath (
   FSRef *ref,
   UInt8 *path,
   UInt32 maxPathSize
)

! Abstract base types
CFSTRING: kUTTypeItem "public.item"
CFSTRING: kUTTypeContent "public.content"
CFSTRING: kUTTypeCompositeContent "public.composite-content"
CFSTRING: kUTTypeApplication "com.apple.application"
CFSTRING: kUTTypeMessage "public.message"
CFSTRING: kUTTypeContact "public.contact"
CFSTRING: kUTTypeArchive "public.archive"
CFSTRING: kUTTypeDiskImage "public.disk-image"

! Concrete base types
CFSTRING: kUTTypeData "public.data"
CFSTRING: kUTTypeDirectory "public.directory"
CFSTRING: kUTTypeResolvable "com.apple.resolvable"
CFSTRING: kUTTypeSymLink "public.symlink"
CFSTRING: kUTTypeMountPoint "com.apple.mount-point"
CFSTRING: kUTTypeAliasFile "com.apple.alias-file"
CFSTRING: kUTTypeAliasRecord "com.apple.alias-record"
CFSTRING: kUTTypeURL "public.url"
CFSTRING: kUTTypeFileURL "public.file-url"

! Text types
CFSTRING: kUTTypeText "public.text"
CFSTRING: kUTTypePlainText "public.plain-text"
CFSTRING: kUTTypeUTF8PlainText "public.utf8-plain-text"
CFSTRING: kUTTypeUTF16ExternalPlainText "public.utf16-external-plain-text"
CFSTRING: kUTTypeUTF16PlainText "public.utf16-plain-text"
CFSTRING: kUTTypeRTF "public.rtf"
CFSTRING: kUTTypeHTML "public.html"
CFSTRING: kUTTypeXML "public.xml"
CFSTRING: kUTTypeSourceCode "public.source-code"
CFSTRING: kUTTypeCSource "public.c-source"
CFSTRING: kUTTypeObjectiveCSource "public.objective-c-source"
CFSTRING: kUTTypeCPlusPlusSource "public.c-plus-plus-source"
CFSTRING: kUTTypeObjectiveCPlusPlusSource "public.objective-c-plus-plus-source"
CFSTRING: kUTTypeCHeader "public.c-header"
CFSTRING: kUTTypeCPlusPlusHeader "public.c-plus-plus-header"
CFSTRING: kUTTypeJavaSource "com.sun.java-source"

! Composite content types
CFSTRING: kUTTypePDF "com.adobe.pdf"
CFSTRING: kUTTypeRTFD "com.apple.rtfd"
CFSTRING: kUTTypeFlatRTFD "com.apple.flat-rtfd"
CFSTRING: kUTTypeTXNTextAndMultimediaData "com.apple.txn.text-multimedia-data"
CFSTRING: kUTTypeWebArchive "com.apple.webarchive"

! Image content types
CFSTRING: kUTTypeImage "public.image"
CFSTRING: kUTTypeJPEG "public.jpeg"
CFSTRING: kUTTypeJPEG2000 "public.jpeg-2000"
CFSTRING: kUTTypeTIFF "public.tiff"
CFSTRING: kUTTypePICT "com.apple.pict"
CFSTRING: kUTTypeGIF "com.compuserve.gif"
CFSTRING: kUTTypePNG "public.png"
CFSTRING: kUTTypeQuickTimeImage "com.apple.quicktime-image"
CFSTRING: kUTTypeAppleICNS "com.apple.icns"
CFSTRING: kUTTypeBMP "com.microsoft.bmp"
CFSTRING: kUTTypeICO "com.microsoft.ico"

! Audiovisual content types
CFSTRING: kUTTypeAudiovisualContent "public.audiovisual-content"
CFSTRING: kUTTypeMovie "public.movie"
CFSTRING: kUTTypeVideo "public.video"
CFSTRING: kUTTypeAudio "public.audio"
CFSTRING: kUTTypeQuickTimeMovie "com.apple.quicktime-movie"
CFSTRING: kUTTypeMPEG "public.mpeg"
CFSTRING: kUTTypeMPEG4 "public.mpeg-4"
CFSTRING: kUTTypeMP3 "public.mp3"
CFSTRING: kUTTypeMPEG4Audio "public.mpeg-4-audio"
CFSTRING: kUTTypeAppleProtectedMPEG4Audio "com.apple.protected-mpeg-4-audio"

! Directory types
CFSTRING: kUTTypeFolder "public.folder"
CFSTRING: kUTTypeVolume "public.volume"
CFSTRING: kUTTypePackage "com.apple.package"
CFSTRING: kUTTypeBundle "com.apple.bundle"
CFSTRING: kUTTypeFramework "com.apple.framework"

! Application types
CFSTRING: kUTTypeApplicationBundle "com.apple.application-bundle"
CFSTRING: kUTTypeApplicationFile "com.apple.application-file"

! Contact types
CFSTRING: kUTTypeVCard "public.vcard"

! Misc. types
CFSTRING: kUTTypeInkText "com.apple.ink.inktext"

CONSTANT: kLSUnknownCreator f

ERROR: core-foundation-error n ;

: cf-error ( n -- )
    dup 0 = [ drop ] [ core-foundation-error ] if ;

: fsref>string ( fsref -- string )
    MAXPATHLEN [ char <c-array> ] [ ] bi
    [ FSRefMakePath cf-error ] [ drop ] 2bi
    [ 0 = ] trim-tail >string ;

: (launch-services-path) ( string -- string' )
    [
        kLSUnknownCreator
        swap <CFString> &CFRelease
        f
        FSRef new
        [ f LSFindApplicationForInfo cf-error ] keep
        fsref>string
    ] with-destructors ;

: launch-services-path ( string -- path/f )
    [ (launch-services-path) ] [ 2drop f ] recover ;
