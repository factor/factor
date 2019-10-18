! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: cocoa.application cocoa.messages cocoa.classes
cocoa.runtime kernel cocoa alien.c-types core-foundation
core-foundation.arrays ;
IN: cocoa.nibs

: load-nib ( name -- )
    NSBundle
    swap <NSString> NSApp -> loadNibNamed:owner:
    drop ;

: nib-named ( nib-name -- anNSNib )
    <NSString> NSNib -> alloc swap f -> initWithNibNamed:bundle:
    dup [ -> autorelease ] when ;

: nib-objects ( anNSNib -- objects/f )
    f f <void*> [ -> instantiateNibWithOwner:topLevelObjects: ] keep
    swap [ *void* CF>array ] [ drop f ] if ;