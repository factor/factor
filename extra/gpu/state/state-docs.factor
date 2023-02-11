! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math math.rectangles
sequences ;
IN: gpu.state

HELP: <blend-mode>
{ $values
    { "equation" blend-equation } { "source-function" blend-function } { "dest-function" blend-function }
    { "blend-mode" blend-mode }
}
{ $description "Constructs a " { $link blend-mode } " tuple." } ;

{ blend-mode <blend-mode> } related-words

HELP: <blend-state>
{ $values
    { "constant-color" sequence } { "rgb-mode" { $maybe blend-mode } } { "alpha-mode" { $maybe blend-mode } }
    { "blend-state" blend-state }
}
{ $description "Constructs a " { $link blend-state } " tuple." } ;

{ blend-state <blend-state> get-blend-state } related-words

HELP: <depth-range-state>
{ $values
    { "near" float } { "far" float }
    { "depth-range-state" depth-range-state }
}
{ $description "Constructs a " { $link depth-range-state } " tuple." } ;

{ depth-range-state <depth-range-state> get-depth-range-state } related-words

HELP: <depth-state>
{ $values
    { "comparison" comparison }
    { "depth-state" depth-state }
}
{ $description "Constructs a " { $link depth-state } " tuple." } ;

{ depth-state <depth-state> get-depth-state } related-words

HELP: <line-state>
{ $values
    { "width" float } { "antialias?" boolean }
    { "line-state" line-state }
}
{ $description "Constructs a " { $link line-state } " tuple." } ;

{ line-state <line-state> get-line-state } related-words

HELP: <mask-state>
{ $values
    { "color" sequence } { "depth" boolean } { "stencil-front" boolean } { "stencil-back" boolean }
    { "mask-state" mask-state }
}
{ $description "Constructs a " { $link mask-state } " tuple." } ;

{ mask-state <mask-state> get-mask-state } related-words

HELP: <multisample-state>
{ $values
    { "multisample?" boolean } { "sample-alpha-to-coverage?" boolean } { "sample-alpha-to-one?" boolean } { "sample-coverage" { $maybe float } } { "invert-sample-coverage?" boolean }
    { "multisample-state" multisample-state }
}
{ $description "Constructs a " { $link multisample-state } " tuple." } ;

{ multisample-state <multisample-state> get-multisample-state } related-words

HELP: <point-state>
{ $values
    { "size" { $maybe float } } { "sprite-origin" point-sprite-origin } { "fade-threshold" float }
    { "point-state" point-state }
}
{ $description "Constructs a " { $link point-state } " tuple." } ;

{ point-state <point-state> get-point-state } related-words

HELP: <scissor-state>
{ $values
    { "rect" { $maybe rect } }
    { "scissor-state" scissor-state }
}
{ $description "Constructs a " { $link scissor-state } " tuple." } ;

{ scissor-state <scissor-state> get-scissor-state } related-words

HELP: <stencil-mode>
{ $values
    { "value" integer } { "mask" integer } { "comparison" comparison } { "stencil-fail-op" stencil-op } { "depth-fail-op" stencil-op } { "depth-pass-op" stencil-op }
    { "stencil-mode" stencil-mode }
}
{ $description "Constructs a " { $link stencil-mode } " tuple." } ;

{ stencil-mode <stencil-mode> } related-words

HELP: <stencil-state>
{ $values
    { "front-mode" { $maybe stencil-mode } } { "back-mode" { $maybe stencil-mode } }
    { "stencil-state" stencil-state }
}
{ $description "Constructs a " { $link stencil-state } " tuple." } ;

{ stencil-state <stencil-state> get-stencil-state } related-words

HELP: <triangle-cull-state>
{ $values
    { "front-face" triangle-face } { "cull" { $maybe triangle-cull } }
    { "triangle-cull-state" triangle-cull-state }
}
{ $description "Constructs a " { $link triangle-cull-state } " tuple." } ;

{ triangle-cull-state <triangle-cull-state> get-triangle-cull-state } related-words

HELP: <triangle-state>
{ $values
    { "front-mode" triangle-mode } { "back-mode" triangle-mode } { "antialias?" boolean }
    { "triangle-state" triangle-state }
}
{ $description "Constructs a " { $link triangle-state } " tuple." } ;

{ triangle-state <triangle-state> get-triangle-state } related-words

HELP: <viewport-state>
{ $values
    { "rect" rect }
    { "viewport-state" viewport-state }
}
{ $description "Constructs a " { $link viewport-state } " tuple." } ;

{ viewport-state <viewport-state> get-viewport-state } related-words

HELP: blend-equation
{ $class-description "The " { $snippet "blend-equation" } " of a " { $link blend-mode } " determines how the source and destination color values are combined after they have been multiplied by the result of their respective " { $link blend-function } "s."
{ $list
{ { $link eq-add } " indicates that the source and destination results are added." }
{ { $link eq-subtract } " indicates that the destination result is subtracted from the source." }
{ { $link eq-reverse-subtract } " indicates that the source result is subtracted from the destination." }
{ { $link eq-min } " indicates that the componentwise minimum of the source and destination results is taken." }
{ { $link eq-max } " indicates that the componentwise maximum of the source and destination results is taken." }
} } ;

HELP: blend-function
{ $class-description "The " { $snippet "blend-function" } "s of a " { $link blend-mode } " multiply the source and destination colors being blended by a function of their values before they are combined by the " { $link blend-equation } "."
{ $list
    { { $link func-zero } " returns a constant factor of zero." }
    { { $link func-one } " returns a constant factor of one." }
    { { $link func-source } " returns the corresponding source color component for every result component." }
    { { $link func-one-minus-source } " returns one minus the corresponding source color component for every result component." }
    { { $link func-dest } " returns the corresponding destination color component for every result component." }
    { { $link func-one-minus-dest } " returns one minus the corresponding destination color component for every result component." }
    { { $link func-constant } " returns the corresponding component of the current " { $link blend-state } "'s " { $snippet "constant-color" } " for every result component." }
    { { $link func-one-minus-constant } " returns one minus the corresponding component of the current " { $link blend-state } "'s " { $snippet "constant-color" } " for every result component." }
    { { $link func-source-alpha } " returns the source alpha component for every result component." }
    { { $link func-one-minus-source-alpha } " returns one minus the source alpha component for every result component." }
    { { $link func-dest-alpha } " returns the destination alpha component for every result component." }
    { { $link func-one-minus-dest-alpha } " returns one minus the destination alpha component for every result component." }
    { { $link func-constant-alpha } " returns the alpha component of the current " { $link blend-state } "'s " { $snippet "constant-color" } " for every result component." }
    { { $link func-one-minus-constant-alpha } " returns one minus the alpha component of the current " { $link blend-state } "'s " { $snippet "constant-color" } " for every result component." }
} } ;

HELP: blend-mode
{ $class-description "A " { $link blend-mode } " is specified as part of the " { $link blend-state } " to determine the blending equation used between the source (incoming fragment) and destination (existing framebuffer value) colors of blended pixels."
{ $list
{ "The " { $snippet "equation" } " slot determines how the source and destination colors are combined after the " { $snippet "source-function" } " and " { $snippet "dest-function" } " have been applied."
    { $list
    { { $link eq-add } " indicates that the source and destination results are added." }
    { { $link eq-subtract } " indicates that the destination result is subtracted from the source." }
    { { $link eq-reverse-subtract } " indicates that the source result is subtracted from the destination." }
    { { $link eq-min } " indicates that the componentwise minimum of the source and destination results is taken." }
    { { $link eq-max } " indicates that the componentwise maximum of the source and destination results is taken." }
    }
}
{ "The " { $snippet "source-function" } " and " { $snippet "dest-function" } " slots each specify a function to apply to the source, destination, or constant color values to generate a blending factor that is multiplied respectively against the source or destination value before feeding the results to the " { $snippet "equation" } "."
}
    { $list
    { { $link func-zero } " returns a constant factor of zero." }
    { { $link func-one } " returns a constant factor of one." }
    { { $link func-source } " returns the corresponding source color component for every result component." }
    { { $link func-one-minus-source } " returns one minus the corresponding source color component for every result component." }
    { { $link func-dest } " returns the corresponding destination color component for every result component." }
    { { $link func-one-minus-dest } " returns one minus the corresponding destination color component for every result component." }
    { { $link func-constant } " returns the corresponding component of the current " { $link blend-state } "'s " { $snippet "constant-color" } " for every result component." }
    { { $link func-one-minus-constant } " returns one minus the corresponding component of the current " { $link blend-state } "'s " { $snippet "constant-color" } " for every result component." }
    { { $link func-source-alpha } " returns the source alpha component for every result component." }
    { { $link func-one-minus-source-alpha } " returns one minus the source alpha component for every result component." }
    { { $link func-dest-alpha } " returns the destination alpha component for every result component." }
    { { $link func-one-minus-dest-alpha } " returns one minus the destination alpha component for every result component." }
    { { $link func-constant-alpha } " returns the alpha component of the current " { $link blend-state } "'s " { $snippet "constant-color" } " for every result component." }
    { { $link func-one-minus-constant-alpha } " returns one minus the alpha component of the current " { $link blend-state } "'s " { $snippet "constant-color" } " for every result component." }
}
"A typical transparency effect will use the values:"
{ $code "T{ blend-mode
    { equation eq-add }
    { source-function func-source-alpha }
    { dest-function func-one-minus-source-alpha }
}" }
} } ;

HELP: blend-state
{ $class-description "The " { $snippet "blend-state" } " controls how alpha blending between the current framebuffer contents and newly drawn pixels."
{ $list
{ "The " { $snippet "constant-color" } " slot contains an optional four-" { $link float } " sequence that specifies a constant parameter to the " { $snippet "func-*constant*" } " " { $link blend-function } "s. If constant blend functions are not used, the slot can be " { $link f } "." }
{ "The " { $snippet "rgb-mode" } " and " { $snippet "alpha-mode" } " slots both contain " { $link blend-mode } " values that determine the blending equation used between RGB and alpha channel values, respectively. If both slots are " { $link f } ", blending is disabled." }
} } ;

HELP: cmp-always
{ $class-description "This " { $link comparison } " test always succeeds." } ;

HELP: cmp-equal
{ $class-description "This " { $link comparison } " test succeeds if the compared values are equal." } ;

HELP: cmp-greater
{ $class-description "This " { $link comparison } " test succeeds if the incoming value is greater than the buffer value." } ;

HELP: cmp-greater-equal
{ $class-description "This " { $link comparison } " test succeeds if the incoming value is greater than or equal to the buffer value." } ;

HELP: cmp-less
{ $class-description "This " { $link comparison } " test succeeds if the incoming value is less than the buffer value." } ;

HELP: cmp-less-equal
{ $class-description "This " { $link comparison } " test succeeds if the incoming value is less than or equal to the buffer value." } ;

HELP: cmp-never
{ $class-description "This " { $link comparison } " test always fails." } ;

HELP: cmp-not-equal
{ $class-description "This " { $link comparison } " test succeeds if the compared values are not equal." } ;

HELP: comparison
{ $class-description { $snippet "comparison" } " values are used in the " { $link stencil-state } " and " { $link depth-state } " and control how the fragment stencil and depth tests are performed. For the stencil test, a reference value (the " { $snippet "value" } " slot of the active " { $link stencil-mode } ") is compared to the stencil buffer value using the comparison operator. For the depth test, the incoming fragment depth is compared to the depth buffer value."
{ $list
{ { $link cmp-always } " always succeeds." }
{ { $link cmp-never } " always fails." }
{ { $link cmp-equal } " succeeds if the compared values are equal." }
{ { $link cmp-not-equal } " succeeds if the compared values are not equal." }
{ { $link cmp-less } " succeeds if the incoming value is less than the buffer value." }
{ { $link cmp-less-equal } " succeeds if the incoming value is less than or equal to the buffer value." }
{ { $link cmp-greater } " succeeds if the incoming value is greater than the buffer value." }
{ { $link cmp-greater-equal } " succeeds if the incoming value is greater than or equal to the buffer value." }
} } ;

HELP: cull-all
{ $class-description "This " { $link triangle-cull } " value culls all triangles." } ;

HELP: cull-back
{ $class-description "This " { $link triangle-cull } " value culls back-facing triangles." } ;

HELP: cull-front
{ $class-description "This " { $link triangle-cull } " value culls front-facing triangles." } ;

HELP: depth-range-state
{ $class-description "The " { $snippet "depth-range-state" } " controls the range of depth values that are generated for fragments and used for depth testing and writing to the depth buffer."
{ $list
{ "The " { $snippet "near" } " slot contains a " { $link float } " value that will be assigned to fragments on the near plane. The default value is " { $snippet "0.0" } "." }
{ "The " { $snippet "far" } " slot contains a " { $link float } " value that will be assigned to fragments on the far plane. The default value is " { $snippet "1.0" } "." }
} } ;

HELP: depth-state
{ $class-description "The " { $snippet "depth-state" } " controls how incoming fragments' depth values are tested against the depth buffer. The " { $link comparison } " slot, if not " { $link f } ", determines the condition that must be true between the incoming fragment depth and depth buffer depth to pass a fragment. If the " { $snippet "comparison" } " is " { $link f } ", depth testing is disabled and all fragments pass. " { $link cmp-less } " is typically used for depth culling." } ;

HELP: eq-add
{ $var-description "This " { $link blend-equation } " adds the source and destination colors together." } ;

HELP: eq-max
{ $var-description "This " { $link blend-equation } " takes the componentwise maximum of the source and destination colors." } ;

HELP: eq-min
{ $var-description "This " { $link blend-equation } " takes the componentwise minimum of the source and destination colors." } ;

HELP: eq-reverse-subtract
{ $var-description "This " { $link blend-equation } " subtracts the source color from the destination color." } ;

HELP: eq-subtract
{ $var-description "This " { $link blend-equation } " subtracts the destination color from the source color." } ;

HELP: face-ccw
{ $class-description "This " { $link triangle-face } " value refers to the face with counterclockwise-wound vertices." } ;

HELP: face-cw
{ $class-description "This " { $link triangle-face } " value refers to the face with clockwise-wound vertices." } ;

HELP: func-constant
{ $class-description "This " { $link blend-function } " componentwise multiplies the input color by the current " { $link blend-state } "'s " { "constant-color" } " slot value." } ;

HELP: func-constant-alpha
{ $class-description "This " { $link blend-function } " multiplies the input color by the alpha component of the current " { $link blend-state } "'s " { "constant-color" } " slot value." } ;

HELP: func-dest
{ $class-description "This " { $link blend-function } " componentwise multiplies the input color by the destination color value." } ;

HELP: func-dest-alpha
{ $class-description "This " { $link blend-function } " componentwise multiplies the input color by the alpha component of the destination color value." } ;

HELP: func-one
{ $class-description "This " { $link blend-function } " multiplies the input color by one; that is, the input color is unchanged." } ;

HELP: func-one-minus-constant
{ $class-description "This " { $link blend-function } " componentwise multiplies the input color by one minus the current " { $link blend-state } "'s " { "constant-color" } " slot value." } ;

HELP: func-one-minus-constant-alpha
{ $class-description "This " { $link blend-function } " multiplies the input color by one minus the alpha component of the current " { $link blend-state } "'s " { "constant-color" } " slot value." } ;

HELP: func-one-minus-dest
{ $class-description "This " { $link blend-function } " componentwise multiplies the input color by one minus the destination color value." } ;

HELP: func-one-minus-dest-alpha
{ $class-description "This " { $link blend-function } " multiplies the input color by one minus the alpha component of the destination color value." } ;

HELP: func-one-minus-source
{ $class-description "This " { $link blend-function } " componentwise multiplies the input color by one minus the source color value." } ;

HELP: func-one-minus-source-alpha
{ $class-description "This " { $link blend-function } " multiplies the input color by one minus the alpha component source color value." } ;

HELP: func-source
{ $class-description "This " { $link blend-function } " componentwise multiplies the input color by the source color value." } ;

HELP: func-source-alpha
{ $class-description "This " { $link blend-function } " multiplies the input color by the alpha component of the source color value." } ;

HELP: func-source-alpha-saturate
{ $class-description "This " { $link blend-function } " multiplies the input color by the minimum of the alpha component of the source color value and one minus the alpha component of the destination color value. It is only valid as the " { $snippet "source-function" } " of a " { $link blend-mode } "." } ;

HELP: func-zero
{ $class-description "This " { $link blend-function } " multiplies the input color by zero." } ;

HELP: get-blend-state
{ $values

    { "blend-state" blend-state }
}
{ $description "Retrieves the current GPU " { $link blend-state } "." } ;

HELP: get-depth-range-state
{ $values

    { "depth-range-state" depth-range-state }
}
{ $description "Retrieves the current GPU " { $link depth-range-state } "." } ;

HELP: get-depth-state
{ $values

    { "depth-state" depth-state }
}
{ $description "Retrieves the current GPU " { $link depth-state } "." } ;

HELP: get-line-state
{ $values

    { "line-state" line-state }
}
{ $description "Retrieves the current GPU " { $link line-state } "." } ;

HELP: get-mask-state
{ $values

    { "mask-state" mask-state }
}
{ $description "Retrieves the current GPU " { $link mask-state } "." } ;

HELP: get-multisample-state
{ $values

    { "multisample-state" multisample-state }
}
{ $description "Retrieves the current GPU " { $link multisample-state } "." } ;

HELP: get-point-state
{ $values

    { "point-state" point-state }
}
{ $description "Retrieves the current GPU " { $link point-state } "." } ;

HELP: get-scissor-state
{ $values

    { "scissor-state" scissor-state }
}
{ $description "Retrieves the current GPU " { $link scissor-state } "." } ;

HELP: get-stencil-state
{ $values

    { "stencil-state" stencil-state }
}
{ $description "Retrieves the current GPU " { $link stencil-state } "." } ;

HELP: get-triangle-cull-state
{ $values

    { "triangle-cull-state" triangle-cull-state }
}
{ $description "Retrieves the current GPU " { $link triangle-cull-state } "." } ;

HELP: get-triangle-state
{ $values

    { "triangle-state" triangle-state }
}
{ $description "Retrieves the current GPU " { $link triangle-state } "." } ;

HELP: get-viewport-state
{ $values

    { "viewport-state" viewport-state }
}
{ $description "Retrieves the current GPU " { $link viewport-state } "." } ;

HELP: gpu-state
{ $class-description "This class is a union of all the GPU state tuple classes that can be passed to " { $link set-gpu-state } ":"
{ $list
{ { $link viewport-state } }
{ { $link scissor-state } }
{ { $link multisample-state } }
{ { $link stencil-state } }
{ { $link depth-range-state } }
{ { $link depth-state } }
{ { $link blend-state } }
{ { $link mask-state } }
{ { $link triangle-cull-state } }
{ { $link triangle-state } }
{ { $link point-state } }
{ { $link line-state } }
} } ;

HELP: line-state
{ $class-description "The " { $snippet "line-state" } " controls how lines are rendered."
{ $list
{ "The " { $snippet "width" } " slot is a " { $link float } " value specifying the line width in pixels." }
{ "The " { $snippet "antialias?" } " slot is a " { $link boolean } " value specifying whether line edges should be smoothed." }
}
} ;

HELP: mask-state
{ $class-description "The " { $snippet "mask-state" } " controls what parts of the framebuffer are written to."
{ $list
{ "The " { $snippet "color" } " slot is a sequence of four " { $link boolean } " values specifying whether the red, green, blue, and alpha channels of the color buffer will be written to." }
{ "The " { $snippet "depth" } " slot is a " { $link boolean } " value specifying whether the depth buffer will be written to." }
{ "The " { $snippet "stencil-front" } " and " { $snippet "stencil-back" } " slots are " { $link integer } " values that indicate which bits of the stencil buffer will be written to for front- and back-facing triangles, respectively." }
} } ;

HELP: multisample-state
{ $class-description "The " { $snippet "multisample-state" } " controls whether and how multisampling occurs."
{ $list
{ "The " { $snippet "multisample?" } " slot is a " { $link boolean } " value that determines whether multisampling is enabled." }
{ "The " { $snippet "sample-alpha-to-coverage?" } " slot is a " { $link boolean } " value that determines whether sample coverage values are determined from their alpha components." }
{ "The " { $snippet "sample-alpha-to-one?" } " slot is a " { $link boolean } " value that determines whether a sample's alpha value is replaced with one after its alpha-based coverage is calculated." }
{ "The " { $snippet "sample-coverage" } " slot is an optional " { $link float } " value that is used to calculate another coverage value that is then combined with the alpha-based coverage. If " { $link f } ", the alpha-based coverage is untouched." }
{ "The " { $snippet "invert-sample-coverage?" } " slot is a " { $link boolean } " value that, if true, indicates that the coverage value derived from " { $snippet "sample-coverage" } " should be inverted before being combined." }
} } ;

HELP: op-dec-sat
{ $class-description "This " { $link stencil-op } " subtracts one from the stencil buffer value, leaving it unchanged if it is already zero." } ;

HELP: op-dec-wrap
{ $class-description "This " { $link stencil-op } " subtracts one from the stencil buffer value, wrapping the value to the maximum storable value if it was zero." } ;

HELP: op-inc-sat
{ $class-description "This " { $link stencil-op } " adds one to the stencil buffer value, leaving it unchanged if it is already the maximum storable value." } ;

HELP: op-inc-wrap
{ $class-description "This " { $link stencil-op } " adds one to the stencil buffer value, wrapping the value to zero if it was the maximum storable value." } ;

HELP: op-invert
{ $class-description "This " { $link stencil-op } " bitwise NOTs the stencil buffer value." } ;

HELP: op-keep
{ $class-description "This " { $link stencil-op } " leaves the stencil buffer value unchanged." } ;

HELP: op-replace
{ $class-description "This " { $link stencil-op } " sets the stencil buffer value to the reference " { $snippet "value" } "." } ;

HELP: op-zero
{ $class-description "This " { $link stencil-op } " sets the stencil buffer value to zero." } ;

HELP: origin-lower-left
{ "This " { $link point-sprite-origin } " value sets the point sprite coordinate origin to the lower left corner of the point and increases the Y coordinate upward." } ;

HELP: origin-upper-left
{ "This " { $link point-sprite-origin } " value sets the point sprite coordinate origin to the upper left corner of the point and increases the Y coordinate downward." } ;

HELP: point-sprite-origin
{ $class-description "The " { $snippet "point-sprite-origin" } " is set as part of the " { $link point-state } " and determines how point sprite coordinates are generated over the rendered area of a point."
{ $list
{ { $link origin-lower-left } " sets the coordinate origin to the lower left corner of the point and increases the Y coordinate upward." }
{ { $link origin-upper-left } " sets the coordinate origin to the upper left corner of the point and increases the Y coordinate downward." }
} } ;

HELP: point-state
{ $class-description "The " { $snippet "point-state" } " controls how points are drawn."
{ $list
{ "The " { $snippet "size" } " slot contains either a " { $link float } " value specifying a constant pixel radius for all points drawn, or " { $link f } ", in which case the vertex shader determines the size of each point independently." }
{ "The " { $snippet "sprite-origin" } " slot contains either " { $link origin-lower-left } " or " { $link origin-upper-left } ", and determines whether the vertical point sprite coordinates fed to the fragment shader start at zero in the bottom corner and increase upward or start at zero in the upper corner and increase downward." }
{ "If multisampling is enabled in the " { $link multisample-state } ", the " { $snippet "fade-threshold" } " slot specifies a pixel width at which the multisampling implementation may fade the alpha component of point fragments." }
} } ;

HELP: scissor-state
{ $class-description "The " { $snippet "scissor-state" } " allows rendering output to be clipped to a rectangular region of the framebuffer. If the " { $snippet "rect" } " slot is set to a " { $link rect } " value, fragments outside that rectangle will be discarded. If it is " { $link f } ", fragments are allowed anywhere on the framebuffer." } ;

HELP: set-gpu-state
{ $values
    { "states" "a " { $link sequence } " or " { $link gpu-state } }
}
{ $description "Changes the GPU state using the values passed in " { $snippet "states" } "." } ;

HELP: set-gpu-state*
{ $values
    { "state" gpu-state }
}
{ $description "Changes the GPU state using a single " { $link gpu-state } " value." } ;

HELP: stencil-mode
{ $class-description "A " { $snippet "stencil-mode" } " is specified as part of the " { $link stencil-state } " to define the interaction between an incoming fragment and the stencil buffer."
{ $list
{ "The " { $snippet "value" } " slot contains an " { $link integer } " value that is used as the reference value for the " { $snippet "comparison" } " of the stencil test." }
{ "The " { $snippet "mask" } " slot contains an " { $link integer } " mask value that indicates which bits are relevant to the stencil test." }
{ "The " { $snippet "comparison" } " slot contains a " { $link comparison } " value that indicates the comparison taken between the masked reference value and stored stencil buffer value to determine whether the fragment is allowed to pass." }
{ "The " { $snippet "stencil-fail-op" } ", " { $snippet "depth-fail-op" } ", and " { $snippet "depth-pass-op" } " slots all contain " { $link stencil-op } " values that determine how the value in the stencil buffer is affected when the stencil test fails, the stencil test succeeds but depth test fails, and both stencil and depth tests succeed, respectively."
    { $list
    { { $link op-keep } " leaves the stencil buffer value unchanged." }
    { { $link op-zero } " sets the stencil buffer value to zero." }
    { { $link op-replace } " sets the stencil buffer value to the reference " { $snippet "value" } "." }
    { { $link op-invert } " bitwise NOTs the stencil buffer value." }
    { { $link op-inc-sat } " adds one to the stencil buffer value, leaving it unchanged if it is already the maximum storable value." }
    { { $link op-dec-sat } " subtracts one from the stencil buffer value, leaving it unchanged if it is already zero." }
    { { $link op-inc-wrap } " adds one to the stencil buffer value, wrapping the value to zero if it was the maximum storable value." }
    { { $link op-dec-wrap } " subtracts one from the stencil buffer value, wrapping the value to the maximum storable value if it was zero." }
    }
}
} } ;

HELP: stencil-op
{ $class-description { $snippet "stencil-op" } "s are set as part of a " { $link stencil-mode } " and determine how the stencil buffer is modified by incoming fragments."
{ $list
{ { $link op-keep } " leaves the stencil buffer value unchanged." }
{ { $link op-zero } " sets the stencil buffer value to zero." }
{ { $link op-replace } " sets the stencil buffer value to the reference " { $snippet "value" } "." }
{ { $link op-invert } " bitwise NOTs the stencil buffer value." }
{ { $link op-inc-sat } " adds one to the stencil buffer value, leaving it unchanged if it is already the maximum storable value." }
{ { $link op-dec-sat } " subtracts one from the stencil buffer value, leaving it unchanged if it is already zero." }
{ { $link op-inc-wrap } " adds one to the stencil buffer value, wrapping the value to zero if it was the maximum storable value." }
{ { $link op-dec-wrap } " subtracts one from the stencil buffer value, wrapping the value to the maximum storable value if it was zero." }
} } ;

HELP: stencil-state
{ $class-description "The " { $snippet "stencil-state" } " controls how incoming fragments interact with the stencil buffer. The " { $snippet "front-mode" } " and " { $snippet "back-mode" } " slots are both " { $link stencil-mode } " tuples that define the stencil buffer interaction for front- and back-facing triangle fragments, respectively. If both slots are " { $link f } ", stencil testing is disabled." } ;

HELP: triangle-cull
{ $class-description "The " { $snippet "cull" } " slot of the " { $link triangle-cull-state } " determines which triangle faces are culled, if any."
{ $list
{ { $link cull-all } " culls all triangles." }
{ { $link cull-front } " culls front-facing triangles." }
{ { $link cull-back } " culls back-facing triangles." }
} } ;

HELP: triangle-cull-state
{ $class-description "The " { $snippet "triangle-cull-state" } " controls what faces of triangles are rasterized."
{ $list
{ "The " { $snippet "front-face" } " slot determines which vertex winding order is considered the front face of a triangle: " { $link face-ccw } " or " { $link face-cw } "." }
{ "The " { $snippet "cull" } " slot determines which triangle faces are discarded: " { $link cull-front } ", " { $link cull-back } ", " { $link cull-all } ", or " { $link f } " to disable triangle culling." }
} } ;

HELP: triangle-face
{ $class-description "A " { $snippet "triangle-face" } " value names a vertex winding order for triangles."
{ $list
{ { $link face-ccw } " indicates counterclockwise winding." }
{ { $link face-cw } " indicates clockwise winding." }
} } ;

HELP: triangle-fill
{ $class-description "This " { $link triangle-mode } " fills the entire surface of triangles." } ;

HELP: triangle-lines
{ $class-description "This " { $link triangle-mode } " renders lines across the edges of triangles." } ;

HELP: triangle-mode
{ $class-description "The " { $snippet "triangle-mode" } " is set as part of the " { $link triangle-state } " to determine how triangles are rendered."
{ $list
{ { $link triangle-points } " renders the vertices of triangles as if they were points." }
{ { $link triangle-lines } " renders lines across the edges of triangles." }
{ { $link triangle-fill } ", the default, fills the entire surface of triangles." }
} } ;

HELP: triangle-points
{ $class-description "This " { $link triangle-mode } " renders the vertices of triangles as if they were points." } ;

HELP: triangle-state
{ $class-description "The " { $snippet "triangle-state" } " controls how triangles are rasterized."
{ $list
{ "The " { $snippet "front-mode" } " and " { $snippet "back-mode" } " slots determine how a front- or back-facing triangle is rendered."
    { $list
    { { $link triangle-points } " renders the vertices of triangles as if they were points." }
    { { $link triangle-lines } " renders lines across the edges of triangles." }
    { { $link triangle-fill } ", the default, fills the entire surface of triangles." }
    }
}
{ "The " { $snippet "antialias?" } " slot contains a " { $link boolean } " value that decides whether the edges of triangles should be smoothed." }
} } ;

HELP: viewport-state
{ $class-description "The " { $snippet "viewport-state" } " controls the rectangular region of the framebuffer to which window-space coordinates are mapped. Window-space vertices are mapped from the rectangle <-1.0, -1.0>­<1.0, 1.0> to the rectangular region specified by the " { $snippet "rect" } " slot." } ;

ARTICLE: "gpu.state" "GPU state"
"The " { $vocab-link "gpu.state" } " vocabulary provides words for querying and setting GPU state."
{ $subsections set-gpu-state }
"The following state tuples are available:"
{ $subsections
    viewport-state
    scissor-state
    multisample-state
    stencil-state
    depth-range-state
    depth-state
    blend-state
    mask-state
    triangle-cull-state
    triangle-state
    point-state
    line-state
} ;

ABOUT: "gpu.state"
