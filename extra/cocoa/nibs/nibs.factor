USING: cocoa.application cocoa.messages cocoa.classes cocoa.runtime 
kernel cocoa core-foundation alien.c-types ;
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