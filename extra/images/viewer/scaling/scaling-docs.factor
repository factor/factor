USING: help.markup help.syntax ;
IN: images.viewer.scaling

HELP: scaling-image-gadget
{
  $class-description "Allows clicking and dragging on an image with the middle mouse button no resize an image. It will always keep to the original aspet ratio"
  $nl
} ;

HELP: autoscaling-image-gadget
{
  $class-description "Allows auto-sizing an image to the scale of a root gadget (like a " { $link scroller } " or " { $link world } "."
  $nl
  { $slots 
    {
      "fill"
      { "If " { $link f } ", the image will retain original dimenions. If a number from 0 to 1 (can also multiply with numbers above 1 to exceed the visible dimensions of the viewport), the image will contain itself to that fraction of the occupied viewport for the viewports smallest axis (for example, giving the " { $snippet "fill" } " slot a 1 will ensure the image is as large as possible within the viewport without changing its aspect ratio or exceeding the viewport size along either dimension). If a pair, like " { $snippet "{ 0.5 f }" } ", the image will stretch to fill half the width of the viewport while the empty y specification will be stretched according to aspect ratio. " { $snippet "{ f 0.75 }" } " will fill three-quarters of the height of the viewport while the width is given dimensions that maintain aspect ratio. " { $snippet "{ 1 1 }" } " can be given to fill the occupied viewport by stretching the image outside of aspect ratio bounds."
      }
    }
  }
} ;

ARTICLE: "images.viewer.scaling" "Scaling images in a gadget"

{
"For a manually resizable image:" 
{ $subsections scaling-image-gadget }

"For an image that scales depending on the viewport size:"
{ $subsections autoscaling-image-gadget }

"For a scrollable window of images where at least 1 image is completely viewable, regardless of the window dimensions: " $nl
  { $code [[ USE: images.viewer.scaling
{ P" ~/path-to-image-1.png"
  P" ~/path-to-image-2.png"
  P" ~/path-to-image-n.png" }
  [ absolute-path load-image <autoscaling-image-gadget> 1 >>fill ] map
<pile> 1 >>fill
[ '[ _ swap add-gadget drop ] each ]
[ <scroller> ]
bi "image-scroll" open-window ]] }
} ;

ABOUT: "images.viewer.scaling"
