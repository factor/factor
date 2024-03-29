USING: destructors help.markup help.syntax math models strings
ui.backend ui.gadgets ui.gestures ui.render ;
IN: ui.gadgets.worlds

HELP: user-input
{ $values { "string" string } { "world" world } }
{ $description "Calls " { $link user-input* } " on every parent of the world's currently-focused child." } ;

HELP: origin
{ $var-description "Within the dynamic extent of " { $link draw-world } ", holds the coordinate system origin for the gadget currently being drawn." } ;

HELP: hand-world
{ $var-description "Global variable. The " { $link world } " containing the gadget at the mouse location." } ;

HELP: grab-input
{ $values { "gadget" gadget } }
{ $description "Sets the " { $link world } " containing " { $snippet "gadget" } " to grab mouse and keyboard input while focused." }
{ $notes "Normal mouse gestures may not be available while input is grabbed." } ;

HELP: ungrab-input
{ $values { "gadget" gadget } }
{ $description "Sets the " { $link world } " containing " { $snippet "gadget" } " not to grab mouse and keyboard input while focused." } ;

{ grab-input ungrab-input } related-words

HELP: set-title
{ $values { "string" string } { "world" world } }
{ $description "Sets the title bar of the native window containing the world." } ;

HELP: set-gl-context
{ $values { "world" world } }
{ $description "Selects an OpenGL context to be the implicit destination for subsequent GL rendering calls. This word is called automatically by the UI before drawing a " { $link world } "." } ;

HELP: window-resource
{ $values { "resource" disposable } }
{ $description "Marks " { $snippet "resource" } " to be destroyed with " { $link dispose } " when the window with the currently active OpenGL context (set by " { $link set-gl-context } ") is closed. " { $snippet "resource" } " is left unmodified at the top of the stack." } ;

HELP: flush-gl-context
{ $values { "handle" "a backend-specific handle" } }
{ $description "Ensures all GL rendering calls made to an OpenGL context finish rendering to the screen. This word is called automatically by the UI after drawing a " { $link world } "." } ;

HELP: focus-path
{ $values { "gadget" gadget } { "seq" "a new sequence" } }
{ $description "If the gadget has focus, outputs a sequence of parents of the currently focused gadget, otherwise outputs " { $link f } "." }
{ $notes "This word is used to avoid sending " { $link gain-focus } " gestures to a gadget which requests focus on an unfocused top-level window, so that, for instance, a text editing caret does not appear in this case." } ;

HELP: world
{ $class-description "A gadget which appears at the top of the gadget hieararchy, and in turn may be displayed in a native window. Worlds have the following slots:"
  { $slots
    {
        "active?"
        { "an " { $link integer } " initially set to 0. The active " { $link ui-backend } " increases the value in steps up to 100 while the native window containing the world is being initialized but not yet visible on the screen. The world is only redrawn when the value is 100 which prevents redundant redraws from happening during initialization. The slot is set to 0 if an error is thrown while drawing the world; this prevents multiple debugger windows from being shown." }
    }
    {
        "layers"
        { "a sequence of glass panes in front of the primary gadget, used to implement behaviors such as popup menus which are hidden when the mouse is clicked outside the menu. See " { $link "ui.gadgets.glass" } "." }
    }
    {
        "title"
        { "a string to be displayed in the title bar of the native window containing the world." }
    }
    {
        "status"
        { "a " { $link model } " holding a string to be displayed in the world's status bar." }
    }
    {
        "status-owner"
        { "the gadget that displayed the most recent status message." }
    }
    {
        "focus"
        { "the current owner of the keyboard focus in the world." }
    }
    {
        "focused?"
        { "a boolean indicating if the native window containing the world has keyboard focus." }
    }
    {
        "grab-input?"
        { "if set to " { $link t } ", the world will hide the mouse cursor and disable normal mouse input while focused. Use " { $link grab-input } " and " { $link ungrab-input } " to change this setting." }
    }
    {
        "handle"
        { "a backend-specific native handle representing the native window containing the world, or " { $link f } " if the world is not grafted." }
    }
    {
        "window-loc"
        { "the on-screen location of the native window containing the world. The coordinate system here is backend-specific." }
    }
    {
        "window-controls"
        { "the set of " { $link "ui.gadgets.worlds-window-controls" } " with which the world window was created." }
    }
  }
} ;

HELP: <world>
{ $values { "world-attributes" world-attributes } { "world" "a new " { $link world } } }
{ $description "Creates a new " { $link world } " or world subclass with the given attributes." } ;

HELP: find-world
{ $values { "gadget" gadget } { "world/f" { $maybe world } } }
{ $description "Finds the " { $link world } " containing the gadget, or outputs " { $link f } " if the gadget is not grafted." } ;

HELP: draw-world
{ $values { "world" world } }
{ $description "Redraws a world." }
{ $notes "This word should only be called by the UI backend. To force a gadget to redraw from user code, call " { $link relayout-1 } "." } ;

HELP: find-gl-context
{ $values { "gadget" gadget } }
{ $description "Makes the OpenGL context of the gadget's containing native window the current OpenGL context." }
{ $notes "This word should be called from " { $link graft* } " and " { $link ungraft* } " methods which need to allocate and deallocate OpenGL resources, such as textures, display lists, and so on." } ;

HELP: begin-world
{ $values { "world" world } }
{ $description "Called immediately after " { $snippet "world" } "'s OpenGL context has been created. The world's OpenGL context is current when this method is called." } ;

HELP: end-world
{ $values { "world" world } }
{ $description "Called immediately before " { $snippet "world" } "'s OpenGL context is destroyed. The world's OpenGL context is current when this method is called." } ;

HELP: resize-world
{ $values { "world" world } }
{ $description "Called when the window containing " { $snippet "world" } " is resized. The " { $snippet "loc" } " and " { $snippet "dim" } " slots of " { $snippet "world" } " will be updated with the world's new position and size. The world's OpenGL context is current when this method is called." } ;

HELP: draw-world*
{ $values { "world" world } }
{ $description "Called when " { $snippet "world" } " needs to be redrawn. The world's OpenGL context is current when this method is called." } ;

HELP: ui-error-hook
{ $var-description "A quotation that is called if an error occurs in the UI updating thread." }
{ $see-also ui-error } ;

ARTICLE: "ui.gadgets.worlds-subclassing" "Subclassing worlds"
"The " { $link world } " gadget can be subclassed, giving Factor code full control of the window's OpenGL context. The following generic words can be overridden to replace standard UI behavior:"
{ $subsections
    begin-world
    end-world
    resize-world
    draw-world*
}
"See the " { $vocab-link "spheres" } " and " { $vocab-link "bunny" } " demos for examples." ;

ARTICLE: "ui-paint-custom" "Implementing custom drawing logic"
"The UI uses OpenGL to render gadgets. Custom rendering logic can be plugged in with the " { $link "ui-pen-protocol" } ", or by implementing a generic word:"
{ $subsections draw-gadget* }
"Custom drawing code has access to the full OpenGL API in the " { $vocab-link "opengl" } " vocabulary."
$nl
"Gadgets which need to allocate and deallocate OpenGL resources such as textures, display lists, and so on, should perform the allocation in the " { $link graft* } " method, and the deallocation in the " { $link ungraft* } " method. Since those words are not necessarily called with the gadget's OpenGL context active, a utility word can be used to find and make the correct OpenGL context current:"
{ $subsections find-gl-context }
"OpenGL state must not be altered as a result of drawing a gadget, so any flags which were enabled should be disabled, and vice versa. To take full control of the OpenGL context, see " { $link "ui.gadgets.worlds-subclassing" } "."
{ $subsections
    "ui-paint-coord"
    "ui.gadgets.worlds-subclassing"
    "gl-utilities"
    "text-rendering"
} ;
