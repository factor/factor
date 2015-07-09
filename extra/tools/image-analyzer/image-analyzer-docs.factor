USING: assocs help.markup help.syntax sequences strings ;
IN: tools.image-analyzer
FROM: tools.image-analyzer.vm => image-header ;

HELP: load-image
{ $values
  { "image" string }
  { "header" image-header }
  { "data-heap" sequence }
  { "code-heap" sequence }
}
{ $description "Loads and decodes Factor image." } ;

ARTICLE: "tools.image-analyzer" "Loader for Factor images"
"The " { $vocab-link "tools.image-analyzer" } " loads and decodes Factor images."
$nl
"Main word:"
{ $subsections load-image }
{ $notes "A limitation of the vocab is that cpu architecture of the image must match the Factor process. So 32 bit Factor can only load 32 bit images and 64 bit Factor 64 bit images." } ;

ABOUT: "tools.image-analyzer"
