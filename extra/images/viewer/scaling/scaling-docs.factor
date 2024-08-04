USING: help.markup help.syntax multiline ui.gadgets.frames
ui.gadgets.scrollers ui.gadgets.worlds ;
IN: images.viewer.scaling

HELP: scaling-image-gadget
{
  $class-description "Allows clicking and dragging on an image with the right-mouse button to resize an image."
  " It will always keep to the original aspect ratio"
  $nl
} ;

HELP: autoscaling-image-gadget
{
  $class-description "Allows auto-sizing an image to the scale of a root gadget (like a "
  { $link scroller } " or " { $link world } ")."
  $nl
  { $slots 
    {
      "fill"
      { "If " { $link f } ", the image will retain original dimenions. " $nl
        "If a number from 0 to 1 (can also multiply with numbers above 1 to exceed the visible dimensions of the viewport), the image will contain itself to that fraction of the occupied viewport (for example, giving the " { $snippet "fill" } " slot a 1 will ensure the image is as large as possible within the viewport without changing its aspect ratio or exceeding the viewport size along either dimension). " $nl
        "If a pair, like " { $snippet "{ 0.5 f }" } ", the image will stretch to fill half the width of the viewport while the empty y scale will be inferred according to aspect ratio. " $nl
        "Similarly, " { $snippet "{ f 0.75 }" } " will fill three-quarters of the height of the viewport while the width is inferred by aspect ratio. " $nl
        "A pair with both axes specified will ignore aspect ratio, for example, " { $snippet "{ 1 1 }" } " can be given to fill the occupied viewport by stretching the image outside of aspect ratio bounds. " $nl
        { $snippet "{ f f }" } " will infer both axes such that the viewport is always covered by the image (exceeding visible bounds where necessary), maintaining aspect ratio." $nl
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

"For a scrollable window of images where at least 1 image is completely contained and viewable regardless of the window dimensions: " $nl
  { $code [[ USE: images.viewer.scaling
{ P" ~/path-to-image-1.png"
  P" ~/path-to-image-2.png"
  P" ~/path-to-image-n.png" }
  [ absolute-path load-image <autoscaling-image-gadget> 1 >>fill ] map
<pile> 1 >>fill
[ '[ _ swap add-gadget drop ] each ]
[ <scroller> ]
bi "image-scroll" open-window ]] } $nl

"To instead ensure the image always completely covers the window so there are no empty regions, use " { $snippet "{ f f }" } " in the " { $snippet "fill" } " slot." $nl

"For a scrollable window of images where each image fills 90% of the height of the viewport, with the filename below it: "
{ $code [[ USE: images.viewer.scaling
{ P" ~/path-to-image-1.png"
  P" ~/path-to-image-2.png"
  P" ~/path-to-image-n.png" }
  [ absolute-path [ load-image <autoscaling-image-gadget> { f 0.9 } >>fill ]
  [ <label> ] bi 2array ] map flip
<grid> <scroller> "image-scroll" open-window ]]
} $nl

"For a window where an image automatically fills to the width of the parent gadget, wrap it in a viewport. The parent gadget gives the wrapping viewport the available dimensions and the image will stop at this viewport to calculate the scaling required. For example, with " { $link frame } " and its " { $snippet "filled-cell" } " slot:"
{ $code [[ USE: images.viewer.scaling
P" ~/path/to/image.jpg" absolute-path
[ <label> ] [ load-image <autoscaling-image-gadget> 1 >>fill f <viewport> t >>root? ] bi
1 2 <frame> swap { 0 0 } grid-add swap { 0 1 } grid-add
<scroller> "image-filling" open-window ]] } $nl

"Wrapping the image in a viewport can also be used to crop and position an image by using the " { $snippet "loc" } " slot of the viewport in conjunction with the scaling options described above."
} ;

ABOUT: "images.viewer.scaling"
