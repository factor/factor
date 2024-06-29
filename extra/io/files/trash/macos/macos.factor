! Copyright (C) 2010 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: alien.c-types alien.strings alien.syntax classes.struct
core-foundation io.backend io.encodings.utf8 io.files.trash
kernel system ;

IN: io.files.trash.macos

<PRIVATE

STRUCT: FSRef
    { hidden UInt8[80] } ;

TYPEDEF: SInt32 OSStatus

TYPEDEF: UInt32 OptionBits

CONSTANT: noErr 0

CONSTANT: kFSFileOperationDefaultOptions 0x00
CONSTANT: kFSFileOperationOverwrite 0x01
CONSTANT: kFSFileOperationSkipSourcePermissionErrors 0x02
CONSTANT: kFSFileOperationDoNotMoveAcrossVolumes 0x04
CONSTANT: kFSFileOperationSkipPreflight 0x08

CONSTANT: kFSPathMakeRefDefaultOptions 0x00
CONSTANT: kFSPathMakeRefDoNotFollowLeafSymlink 0x01

FUNCTION: OSStatus FSMoveObjectToTrashSync (
    FSRef* source,
    FSRef* target,
    OptionBits options
)

FUNCTION: char* GetMacOSStatusCommentString (
    OSStatus err
)

FUNCTION: OSStatus FSPathMakeRefWithOptions (
    UInt8* path,
    OptionBits options,
    FSRef* ref,
    Boolean* isDirectory
)

: check-err ( err -- )
    dup noErr = [ drop ] [
        GetMacOSStatusCommentString utf8 alien>string throw
    ] if ;

! FIXME: check isDirectory?

: <fs-ref> ( path -- fs-ref )
    utf8 string>alien
    kFSPathMakeRefDoNotFollowLeafSymlink
    FSRef new
    [ f FSPathMakeRefWithOptions check-err ] keep ;

PRIVATE>

M: macos send-to-trash ( path -- )
    normalize-path
    <fs-ref> f kFSFileOperationDefaultOptions
    FSMoveObjectToTrashSync check-err ;
