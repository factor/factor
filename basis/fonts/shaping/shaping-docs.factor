USING: help.markup help.syntax ;
IN: fonts.shaping

HELP: font-with-direction
{ $values { "font" "a font" } { "direction/f" "left-to-right, right-to-left, or f" } { "font'" "a new font" } }
{ $description "Sets paragraph reading direction. A false value uses the backend default (left-to-right on DirectWrite). Bidirectional runs within the paragraph still follow Unicode shaping rules." } ;

HELP: font-with-tab-width
{ $values { "font" "a font" } { "width/f" "a positive distance in logical pixels, or f" } { "font'" "a new font" } }
{ $description "Sets a uniform tab-stop interval. A false value restores the backend default." } ;

HELP: font-with-features
{ $values { "font" "a font" } { "assoc" "four-character OpenType tags mapped to unsigned 32-bit parameters" } { "font'" "a new font" } }
{ $description "Sets OpenType typography features over the text. Zero disables a feature; one enables it. Some features take a numeric alternative. Feature availability depends on the selected font." }
{ $code "monospace-font H{ { \"liga\" 0 } { \"kern\" 1 } } font-with-features" } ;

HELP: font-with-locale
{ $values { "font" "a font" } { "locale" "a nonempty locale name" } { "font'" "a new font" } }
{ $description "Sets the locale used for shaping, for example ar-sa. The default is en-us." } ;

HELP: font-with-color-fonts
{ $values { "font" "a font" } { "?" "a boolean" } { "font'" "a new font" } }
{ $description "Enables or disables native color glyph rendering. Enabled by default. Available color glyph formats depend on Windows and the installed font." } ;

ARTICLE: "fonts.shaping" "Font shaping options"
"These immutable font helpers configure the Windows DirectWrite text backend. Other text backends currently ignore these options. Options survive UI font derivation; omitted options inherit from the base font."
{ $subsections font-with-direction font-with-tab-width font-with-features font-with-locale font-with-color-fonts } ;

ABOUT: "fonts.shaping"
