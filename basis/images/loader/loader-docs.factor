USING: help.markup help.syntax images images.loader strings ;
IN: images.loader+docs

HELP: save-graphic-image
{ $values { "image" image } { "path" string } }
{ $description "Saves a (graphic) image to disk. The extension of the path string is used to select which save format to save the image with." }
{ $examples
  "This example renders a text on an image and then saves the image to /tmp/foo.jpg"
  { $code
    "USING: fonts images.loader ui.text ;"
    "monospace-font \"Hello, there!\" string>image drop "
    "\"/tmp/hello.jpg\" save-graphic-image"
  }
} ;
