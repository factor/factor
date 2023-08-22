! Copyright (C) 2009 Keith Lazuka.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax images ;
IN: images.normalization

HELP: normalize-image
{ $values
    { "image" image }
    { "image'" image }
}
{ $description "Converts the image to RGBA with ubyte-components. If the image is upside-down, it will be flipped right side up such that the 1st byte in the bitmap slot's byte array corresponds to the first color component of the pixel in the upper-left corner of the image." } ;

HELP: reorder-components
{ $values
    { "image" image } { "component-order" component-order }
    { "image'" image }
}
{ $description "Convert the bitmap in " { $snippet "image" } " such that the pixel sample layout corresponds to " { $snippet "component-order" } ". If the destination layout cannot find a corresponding value from the source layout, the value " { $snippet "255" } " will be substituted for that byte." }
{ $warning "The image's " { $snippet "component-type" } " will be changed to " { $snippet "ubyte-components" } " if it is not already in that format."
$nl
"You cannot use this word to reorder " { $link DEPTH } ", " { $link DEPTH-STENCIL } " or " { $link INTENSITY } " component orders." } ;

ARTICLE: "images.normalization" "Image normalization"
"The " { $vocab-link "images.normalization" } " vocab can be used to convert between " { $link image } " representations."
$nl
"You can normalize any image to a RGBA with ubyte-components representation:"
{ $subsections normalize-image }
"Convert an image's pixel layout to match an arbitrary " { $link component-order } ":"
{ $subsections reorder-components } ;

ABOUT: "images.normalization"
