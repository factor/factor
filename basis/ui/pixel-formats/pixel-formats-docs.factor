USING: destructors help.markup help.syntax kernel math sequences
vocabs vocabs.parser words namespaces ;
IN: ui.pixel-formats

! break circular dependency
<<
    "ui.gadgets.worlds" create-vocab drop
    "world" "ui.gadgets.worlds" create-word drop
    "ui.gadgets.worlds" vocab-words-assoc use-words
>>

ARTICLE: "ui.pixel-formats-attributes" "Pixel format attributes"
"The following pixel format attributes can be requested and queried of " { $link pixel-format } "s. Binary attributes are represented by the presence of a symbol in an attribute sequence:"
{ $subsections
    double-buffered
    stereo
    offscreen
    fullscreen
    windowed
    accelerated
    software-rendered
    backing-store
    multisampled
    supersampled
    sample-alpha
    color-float
}
"Integer attributes are represented by a " { $link tuple } " with a single " { $snippet "value" } " slot:"
{ $subsections
    color-bits
    red-bits
    green-bits
    blue-bits
    alpha-bits
    accum-bits
    accum-red-bits
    accum-green-bits
    accum-blue-bits
    accum-alpha-bits
    depth-bits
    stencil-bits
    aux-buffers
    sample-buffers
    samples
}
{ $examples
"The following " { $link world } " subclass will request a double-buffered window with minimum 24-bit color and depth buffers, and will throw an error if the requirements aren't met:"
{ $code "USING: kernel ui.gadgets.worlds ui.pixel-formats ;
IN: ui.pixel-formats.examples

TUPLE: picky-depth-buffered-world < world ;

M: picky-depth-buffered-world world-pixel-format-attributes
    drop {
        double-buffered
        T{ color-bits { value 24 } }
        T{ depth-bits { value 24 } }
    } ;

M: picky-depth-buffered-world check-world-pixel-format
    nip
    [ double-buffered pixel-format-attribute 0 = [ \"Not double buffered!\" throw ] when ]
    [ color-bits pixel-format-attribute 24 < [ \"Not enough color bits!\" throw ] when ]
    [ depth-bits pixel-format-attribute 24 < [ \"Not enough depth bits!\" throw ] when ]
    tri ;" } }
;

HELP: double-buffered
{ $description "Requests a double-buffered pixel format." } ;
HELP: stereo
{ $description "Requests a stereoscopic pixel format." } ;

HELP: offscreen
{ $description "Requests a pixel format suitable for offscreen rendering." } ;
HELP: fullscreen
{ $description "Requests a pixel format suitable for fullscreen rendering." }
{ $notes "On some window systems this is not distinct from " { $link windowed } "." } ;
HELP: windowed
{ $description "Requests a pixel format suitable for rendering to a window." } ;

{ offscreen fullscreen windowed } related-words

HELP: accelerated
{ $description "Requests a pixel format supported by GPU hardware acceleration." } ;
HELP: software-rendered
{ $description "Requests a pixel format only supported by the window system's default software renderer." } ;

{ accelerated software-rendered } related-words

HELP: backing-store
{ $description "Used with " { $link double-buffered } " to request a double-buffered pixel format where the back buffer contents are preserved and copied to the front when buffers are swapped." } ;

{ double-buffered backing-store } related-words

HELP: multisampled
{ $description "Requests a pixel format with multisampled antialiasing enabled. The " { $link sample-buffers } " and " { $link samples } " attributes must also be provided to specify the level of multisampling." }
{ $notes "On some window systems this is not distinct from " { $link supersampled } "." } ;

HELP: supersampled
{ $description "Requests a pixel format with supersampled antialiasing enabled. The " { $link sample-buffers } " and " { $link samples } " attributes must also be provided to specify the level of supersampling." }
{ $notes "On some window systems this is not distinct from " { $link multisampled } "." } ;

HELP: sample-alpha
{ $description "Used with " { $link multisampled } " or " { $link supersampled } " to request more accurate multisampling of alpha values." } ;

HELP: color-float
{ $description "Requests a pixel format where the color buffer is stored in floating-point format." } ;

HELP: color-bits
{ $class-description "Requests a pixel format with a color buffer of at least " { $snippet "value" } " bits per pixel." } ;
HELP: red-bits
{ $class-description "Requests a pixel format with a color buffer with at least " { $snippet "value" } " red bits per pixel." } ;
HELP: green-bits
{ $class-description "Requests a pixel format with a color buffer with at least " { $snippet "value" } " green bits per pixel." } ;
HELP: blue-bits
{ $class-description "Requests a pixel format with a color buffer with at least " { $snippet "value" } " blue bits per pixel." } ;
HELP: alpha-bits
{ $class-description "Requests a pixel format with a color buffer with at least " { $snippet "value" } " alpha bits per pixel." } ;

{ color-float color-bits red-bits green-bits blue-bits alpha-bits } related-words

HELP: accum-bits
{ $class-description "Requests a pixel format with an accumulation buffer of at least " { $snippet "value" } " bits per pixel." } ;
HELP: accum-red-bits
{ $class-description "Requests a pixel format with an accumulation buffer with at least " { $snippet "value" } " red bits per pixel." } ;
HELP: accum-green-bits
{ $class-description "Requests a pixel format with an accumulation buffer with at least " { $snippet "value" } " green bits per pixel." } ;
HELP: accum-blue-bits
{ $class-description "Requests a pixel format with an accumulation buffer with at least " { $snippet "value" } " blue bits per pixel." } ;
HELP: accum-alpha-bits
{ $class-description "Requests a pixel format with an accumulation buffer with at least " { $snippet "value" } " alpha bits per pixel." } ;

{ accum-bits accum-red-bits accum-green-bits accum-blue-bits accum-alpha-bits } related-words

HELP: depth-bits
{ $class-description "Requests a pixel format with a depth buffer of at least " { $snippet "value" } " bits per pixel." } ;

HELP: stencil-bits
{ $class-description "Requests a pixel format with a stencil buffer of at least " { $snippet "value" } " bits per pixel." } ;

HELP: aux-buffers
{ $class-description "Requests a pixel format with at least " { $snippet "value" } " auxiliary buffers." } ;

HELP: sample-buffers
{ $class-description "Used with " { $link multisampled } " or " { $link supersampled } " to request a pixel format with at least " { $snippet "value" } " sampling buffers." } ;

HELP: samples
{ $class-description "Used with " { $link multisampled } " or " { $link supersampled } " to request at least " { $snippet "value" } " samples per pixel." } ;

{ multisampled supersampled sample-alpha sample-buffers samples } related-words

HELP: world-pixel-format-attributes
{ $values { "world" world } { "attributes" sequence } }
{ $description "Returns the set of " { $link "ui.pixel-formats-attributes" } " that " { $snippet "world" } " requests when grafted. This generic can be overridden by subclasses of " { $snippet "world" } "." }
{ $notes "The pixel format provided by the window system will not necessarily exactly match the requested attributes. To 1guard required pixel format attributes, override " { $link check-world-pixel-format } "." } ;

HELP: check-world-pixel-format
{ $values { "world" world } { "pixel-format" pixel-format } }
{ $description "Verifies that " { $snippet "pixel-format" } " fulfills the requirements of " { $snippet "world" } ". The default method does nothing. Subclasses can override this generic to perform their own checks on the pixel format." } ;

HELP: pixel-format
{ $class-description "The type of pixel format objects. The tuple slot contents should be considered opaque by user code. To check the value of a pixel format's attributes, use the " { $link pixel-format-attribute } " word. Pixel format objects must be freed using the " { $link dispose } " word when they are no longer needed." } ;

HELP: <pixel-format>
{ $values { "world" world } { "attributes" sequence } { "pixel-format" pixel-format } }
{ $description "Requests a pixel format suitable for " { $snippet "world" } " with a set of " { $link "ui.pixel-formats-attributes" } ". If no pixel format can be found that satisfies the given attributes, an " { $link invalid-pixel-format-attributes } " error is thrown. Pixel format attributes not supported by the window system are ignored. The returned " { $snippet "pixel-format" } " must be released using the " { $link dispose } " word when it is no longer needed." }
{ $notes "Pixel formats don't normally need to be directly allocated by user code. If you need to control the pixel format requested by a window, subclass " { $snippet "world" } " and override the " { $link world-pixel-format-attributes } " and " { $link check-world-pixel-format } " words."
$nl
"The returned pixel format does not necessarily exactly match the requested attributes; the window system will try to find the format that best matches the given attributes. Use " { $link pixel-format-attribute } " to check the actual values of the attributes on the returned pixel format." }
;

HELP: pixel-format-attribute
{ $values { "pixel-format" pixel-format } { "attribute-name" "one of the " { $link "ui.pixel-formats-attributes" } } { "value" object } }
{ $description "Returns the value of the requested " { $snippet "attribute-name" } " in " { $snippet "pixel-format" } ". If " { "attribute-name" } " is unsupported by the window system, " { $link f } " is returned." } ;

HELP: invalid-pixel-format-attributes
{ $values { "world" world } { "attributes" sequence } }
{ $class-description "Thrown by " { $link <pixel-format> } " when the window system is unable to find a pixel format for " { $snippet "world" } " that satisfies the requested " { $snippet "attributes" } "." } ;

{ world-pixel-format-attributes check-world-pixel-format pixel-format <pixel-format> pixel-format-attribute }
related-words

ARTICLE: "ui.pixel-formats" "Pixel formats"
"The UI allows you to control the window system's OpenGL interface with a cross-platform set of pixel format specifiers:"
{ $subsections "ui.pixel-formats-attributes" }

"Pixel formats can be requested using these attributes:"
{ $subsections
    pixel-format
    <pixel-format>
    pixel-format-attribute
}

"If a request for a set of pixel format attributes cannot be satisfied, an error is thrown:"
{ $subsections invalid-pixel-format-attributes }

"Pixel formats are requested as part of opening a window for a " { $link world } ". These generics can be overridden on " { $snippet "world" } " subclasses to control pixel format selection:"
{ $subsections
    world-pixel-format-attributes
    check-world-pixel-format
}
;

ABOUT: "ui.pixel-formats"
