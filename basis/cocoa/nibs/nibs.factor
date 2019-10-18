! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data cocoa.application cocoa.messages
cocoa.classes cocoa.runtime cocoa core-foundation
core-foundation.arrays kernel ;
IN: cocoa.nibs

: load-nib ( name -- )
    NSBundle
    swap <NSString> NSApp -> loadNibNamed:owner:
    drop ;

: nib-named ( nib-name -- anNSNib )
    <NSString> NSNib -> alloc swap f -> initWithNibNamed:bundle:
    dup [ -> autorelease ] when ;

: nib-objects ( anNSNib -- objects/f )
    f
    { void* } [ -> instantiateNibWithOwner:topLevelObjects: ]
    with-out-parameters
    swap [ CF>array ] [ drop f ] if ;