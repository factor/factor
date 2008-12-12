USING: alien strings arrays help.markup help.syntax destructors ;
IN: core-foundation

HELP: &CFRelease
{ $values { "alien" "Pointer to a Core Foundation object" } }
{ $description "Marks the given Core Foundation object for unconditional release via " { $link CFRelease } " at the end of the enclosing " { $link with-destructors } " scope." } ;

HELP: |CFRelease
{ $values { "alien" "Pointer to a Core Foundation object" } }
{ $description "Marks the given Core Foundation object for release via " { $link CFRelease } " in the event of an error at the end of the enclosing " { $link with-destructors } " scope." } ;

{ CFRelease |CFRelease &CFRelease } related-words
