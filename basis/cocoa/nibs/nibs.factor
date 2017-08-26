! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data cocoa cocoa.application
cocoa.classes core-foundation.arrays kernel ;
IN: cocoa.nibs

: load-nib ( name -- )
    NSBundle
    swap <NSString> NSApp send\ loadNibNamed:owner:
    drop ;

: nib-named ( nib-name -- anNSNib )
    <NSString> NSNib send\ alloc swap f send\ initWithNibNamed:bundle:
    dup [ send\ autorelease ] when ;

: nib-objects ( anNSNib -- objects/f )
    f
    { void* } [ send\ instantiateNibWithOwner:topLevelObjects: ]
    with-out-parameters
    swap [ CF>array ] [ drop f ] if ;
