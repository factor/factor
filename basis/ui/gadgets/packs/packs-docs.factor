USING: ui.gadgets help.markup help.syntax generic kernel
classes.tuple quotations ui.gadgets.packs.private
ui.baseline-alignment ;
IN: ui.gadgets.packs

ARTICLE: "ui-pack-layout" "Pack layouts"
"Pack gadgets layout their children along a single axis."
{ $subsections pack }
"Creating empty packs:"
{ $subsections
    <pack>
    <pile>
    <shelf>
}

"For more control, custom layouts can reuse portions of pack layout logic:"
{ $subsections
    pack-pref-dim
    pack-layout
} ;

HELP: pack
{ $class-description "A gadget which lays out its children along a single axis stored in the " { $snippet "orientation" } " slot. Can be constructed with one of the following words:"
{ $list
    { $link <pack> }
    { $link <pile> }
    { $link <shelf> }
}
"Packs have the following slots:"
{ $list
    { { $snippet "align" } " a rational number between 0 and 1, or " { $link +baseline+ } "; the alignment of gadgets along the axis perpendicular to the pack's orientation" }
    { { $snippet "fill" } " a rational number between 0 and 1, where 0 gives each gadget its preferred size and 1 fills the dimension perpendicular to the pack's orientation" }
    { { $snippet "gap" } " a pair of integers, the horizontal and vertical gap between children" }
}
"Custom gadgets can inherit from the " { $link pack } " class and implement their own " { $link pref-dim* } " and " { $link layout* } " methods, reusing pack layout logic by calling " { $link pack-pref-dim } " and " { $link pack-layout } "." } ;

HELP: pack-layout
{ $values { "pack" "a new " { $link pack } } { "sizes" "a sequence of pairs of integers" } }
{ $description "Lays out the pack's children along the " { $snippet "orientation" } " of the pack, with each gadget receiving its size from the corresponding index of the " { $snippet "sizes" } " sequence." }
{ $notes
    "This word is useful if you are writing your own layout gadget which inherits from " { $link pack } ". This allows you to reuse layout logic while computing gadget sizes using a custom procedure."
} ;

HELP: <pack>
{ $values { "orientation" "an orientation specifier" } { "pack" "a new " { $link pack } } }
{ $description "Creates a new pack which lays out children with the given orientation, either " { $link horizontal } " or " { $link vertical } "." } ;

{ <pack> <pile> <shelf> } related-words

HELP: <pile>
{ $values { "pack" "a new " { $link pack } } }
{ $description "Creates a new " { $link pack } " which lays out its children vertically." } ;

HELP: <shelf>
{ $values { "pack" "a new " { $link pack } } }
{ $description "Creates a new " { $link pack } " which lays out its children horizontally." } ;

HELP: pack-pref-dim
{ $values { "pack" pack } { "sizes" "a sequence of pairs of integers" } { "dim" "a pair of integers" } }
{ $description "Computes the preferred size of a pack, with each gadget receiving its size from the corresponding index of the " { $snippet "sizes" } " sequence." }
{ $notes
    "This word is useful if you are writing your own layout gadget which inherits from " { $link pack } ". This allows you to reuse layout logic while computing gadget sizes using a custom procedure."
} ;

ABOUT: "ui-pack-layout"
