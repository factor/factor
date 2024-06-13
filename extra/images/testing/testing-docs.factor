! Copyright (C) 2009 Keith Lazuka.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax images images.viewer kernel
quotations strings ;
IN: images.testing

HELP: decode-test
{ $values
    { "path" "a pathname string" } { "image-class" object }
}
{ $description "Runs a unit-test on the image at " { $snippet "path" } " to test the image decoder. The image is decoded and compared against its corresponding " { $link { "images" "testing" "reference" } } "." } ;

HELP: encode-test
{ $values
    { "path" "a pathname string" } { "image-class" object }
}
{ $description "Runs a unit-test on the image at " { $snippet "path" } " to test the image encoder. The image is decoded, encoded, and then decoded again to 1guard that the final decoded output matches the original decoded output. Before comparison for equality, the images are normalized in order to accommodate differences in representation between the two potential encoders." }
{ $warning "This test assumes that the image decoder is working correctly. If the image fails both the " { $link decode-test } " and the " { $link encode-test } ", then you should first debug the decoder. Once the decoder is working correctly, proceed with testing the encoder." } ;

HELP: images.
{ $values
    { "dirpath" "a pathname string" } { "extension" string }
}
{ $description "Renders each image at " { $snippet "dirpath" } " directly to the listener tool." } ;
{ images. image. } related-words

HELP: load-reference-image
{ $values
    { "path" "a pathname string" }
    { "image" image }
}
{ $description "Loads the " { $link { "images" "testing" "reference" } } " that corresponds to the original image at " { $snippet "path" } " into memory." } ;

HELP: ls
{ $values
    { "dirpath" "a pathname string" } { "extension" object }
}
{ $description "Prints out the name of each file surrounded in double quotes so that you can easily copy and paste into your unit test." } ;

HELP: save-all-as-reference-images
{ $values
    { "dirpath" "a pathname string" } { "extension" object }
}
{ $description "Saves a " { $link { "images" "testing" "reference" } } " for each image in " { $snippet "dirpath" } " with file extension " { $snippet "extension" } "." }
{ $warning "You should only call this word after you have manually verified that every image in " { $snippet "dirpath" } " decodes and renders correctly!" } ;

HELP: save-as-reference-image
{ $values
    { "path" "a pathname string" }
}
{ $description "Saves a " { $link { "images" "testing" "reference" } } " for the image at " { $snippet "path" } "." }
{ $warning "You should only call this word after you have manually verified that the image at " { $snippet "path" } " decodes and renders correctly!" } ;

HELP: with-matching-files
{ $values
    { "dirpath" "a pathname string" } { "extension" string } { "quot" quotation }
}
{ $description "Perform an operation on each file in " { $snippet "dirpath" } " with file extension " { $snippet "extension" } "." } ;

ARTICLE: { "images" "testing" "reference" } "Reference image"
"For the purposes of the " { $vocab-link "images.testing" } " vocab, a reference image is an " { $link image } " which has been serialized to disk by the " { $vocab-link "serialize" } " vocab. The file on disk has a " { $snippet ".fig" } " extension."
$nl
"Reference images are used by " { $link decode-test } " to compare the decoder's output against a saved image that is known to be correct."
$nl
"You can create your own reference image after you 1guard that the image has been correctly decoded:"
{ $subsections
    save-as-reference-image
    save-all-as-reference-images
}
"A reference image can be loaded by the path of the original image:"
{ $subsections load-reference-image }
;

ARTICLE: "images.testing" "Testing image encoders and decoders"
"The " { $vocab-link "images.testing" } " vocab facilitates writing unit tests for image encoders and decoders by providing common functionality"
$nl
"Creating a unit test:"
{ $subsections
    decode-test
    encode-test
}
"Establishing a " { $link { "images" "testing" "reference" } } ":"
{ $subsections save-as-reference-image }
"You should only create a reference image after you manually 1guard that your decoder is generating a valid " { $link image } " object and that it renders correctly to the screen. The following words are useful for manual verification:"
{ $subsections
    image.
    images.
}
"Helpful words for writing potentially tedious unit tests for each image file under test:"
{ $subsections
    save-all-as-reference-images
    ls
    with-matching-files
}
{ $notes "This vocabulary is only intended for implementors of image encoders and image decoders. If you are an end-user, you are in the wrong place :-)" }
;

ABOUT: "images.testing"
