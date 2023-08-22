! Copyright (C) 2010 Jon Harper.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel strings io.pathnames images
models opengl.textures classes ui.gadgets ;
IN: images.viewer

HELP: <image-gadget>
{ $values
    { "object" { $or pathname string image } }
    { "gadget" image-gadget }
}
{ $description "Creates " { $instance image-gadget } " with the given image. See " { $link set-image } "." } ;
HELP: <image-control>
{ $values
    { "model" model }
    { "gadget" image-control }
}
{ $description "Creates " { $instance image-control } " with the given image. See " { $link set-image } "." } ;

HELP: new-image-gadget
{ $values
    { "class" class }
    { "gadget" image-gadget }
}
{ $description "Use this if the image is not available when you want to construct the gadget. Don't forget to call "
{ $link set-image } " before grafting this gadget. You can also use this constructor if you want to extend image-gadget or image-control."
} ;

HELP: new-image-gadget*
{ $values
    { "object" { $or pathname string image } } { "class" class }
    { "gadget" image-gadget }
}
{ $description "Use this constructor when you want to extend image-gadget or image-control." } ;

HELP: set-image
{ $values
    { "gadget" image-gadget } { "object" { $or pathname string image } }
}
{ $description "Sets the image of this gadget. This word loads the image from disk if the input is a string or a pathname. "
"If the input is a model, gadget has to be " { $instance image-control } "." } ;

HELP: image-control
{ $var-description "This gadget is like " { $instance image-gadget } ", but it's image must be in " { $instance model } ". It's used to display changing images." } ;

HELP: image-gadget
{ $var-description "This gadget can render " { $instance image } "." } ;

HELP: image-window
{ $values
    { "object" { $or pathname string image } }
}
{ $description "Opens a new window displaying the image." } ;

HELP: image.
{ $values
    { "object" { $or pathname string image } }
}
{ $description "Displays the image in the listener." } ;

ARTICLE: "images.viewer" "Displaying Images"
"The " { $vocab-link "images.viewer" } " vocabulary uses the " { $vocab-link "opengl.textures" }
" vocabulary to display any instance of " { $link image } "." $nl
"An " { $link image-gadget } " can be used for static images and " { $instance image-control }
" for changing images (for example a video feed). For changing images, the image should be contained in " { $instance model }
". Change the model value with " { $link set-model } " or mutate the image and call "
{ $link notify-connections } " when you want to update the image."

$nl
"If the " { $link image } " or " { $link model } " containing the image "
"is available when the object is created, use the following words to create the gadget:"
{ $subsections <image-gadget> <image-control> }
"The " { $link image } " or " { $link model }
" can also be given after the construction of the object. In this case, use "
{ $link new-image-gadget } " and " { $link set-image } "."
" The gadget will automatically detect if the image changes size or format and reallocate a new texture if needed."
" This means images can be set even after the gadget has been grafted. Grafted gadgets without an image will display a blank screen."

{ $notes "The image can be set after the gadget has been grafted. However, for " { $instance image-gadget } ", this can "
" be done only once. If your image is changing, you should be using " { $instance image-control } " and " { $instance model } "."
$nl
"Performance will be greatly reduced if you are using images that have more than 512 pixels on one of their"
" axis." }


$nl
"Utility words for displaying images:"
{ $subsections
image. image-window }

;
ABOUT: "images.viewer"
