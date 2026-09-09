USING: help.markup help.syntax ;
IN: windows.directwrite

HELP: <directwrite-layout>
{ $values { "font" "a font, optionally carrying fonts.shaping options" } { "string" "a string or selection" } { "layout" "a disposable DirectWrite layout" } }
{ $description "Shapes text with the system DirectWrite implementation. The layout owns its native COM text layout. Font sizes and tab intervals are scaled to the current backing scale. Typography features, paragraph reading direction, locale, native fallback fonts, and Unicode cluster hit testing share the same layout used for rendering." }
{ $notes "The size slot contains bitmap bounds including glyph overhang. The metrics slot contains logical text dimensions; the origin slot is the translation required when drawing into the bitmap. Tab intervals are uniform, not arbitrary tab-stop lists. Unavailable font families resolve to Segoe UI for both shaping and font metrics." } ;

HELP: directwrite-offset>x
{ $values { "index" "a Factor codepoint index" } { "layout" "a DirectWrite layout" } { "x" "a backing-pixel coordinate" } }
{ $description "Finds the native leading caret edge, translating the Factor codepoint index to a UTF-16 position." } ;

HELP: directwrite-x>offset
{ $values { "x" "a backing-pixel coordinate" } { "layout" "a DirectWrite layout" } { "index" "a Factor codepoint index" } }
{ $description "Hits the native visual cluster and returns its leading or trailing logical boundary in Factor codepoints. Surrogate pairs and combining clusters are not split." } ;

HELP: directwrite-selection-rects
{ $values { "layout" "a DirectWrite layout" } { "rects" "native DWRITE_HIT_TEST_METRICS structures" } }
{ $description "Returns the visual rectangles of a logical selection. Bidirectional selections can occupy several disjoint rectangles." } ;

ARTICLE: "windows.directwrite" "DirectWrite text layout"
"Windows text layout using DirectWrite."
{ $subsections <directwrite-layout> directwrite-offset>x directwrite-x>offset directwrite-selection-rects }
{ $url "https://learn.microsoft.com/en-us/windows/win32/api/dwrite/nn-dwrite-idwritetextlayout" }
{ $url "https://learn.microsoft.com/en-us/windows/win32/api/dwrite/nf-dwrite-idwritetextformat-setincrementaltabstop" } ;

ABOUT: "windows.directwrite"
