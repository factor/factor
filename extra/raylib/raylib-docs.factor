! Copyright (C) 2023 CapitalEx.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays help.markup
help.syntax kernel make math math.parser quotations sequences
strings urls ;
FROM: alien.c-types => float ;
IN: raylib

<PRIVATE
: $enum-members ( element -- )
    "Enum members" $heading
    first lookup-c-type members>> [ first ] map $subsections ;

: $raylib-color ( element -- )
    "Word description" $heading
    { { "value" Color } } $values
    "Represents the color (" print-element print-element ")" print-element
    "\n\n" print-element
    "For a visual guide, see the following:\n" print-element
    { "https://raw.githubusercontent.com/raysan5/raylib/master/examples/shapes/shapes_colors_palette.png" }
        $url ;

GENERIC: ($raylib-key) ( array -- )
PREDICATE: triple < array length>> 3 = ;

M: pair ($raylib-key)
    "Represents the key " print-element
    first2 [ % " (" % # ")" % ] "" make $snippet
    "." print-element ;

M: triple ($raylib-key)
    unclip-last swap ($raylib-key) " " [ print-element ] bi@ ;


: $raylib-key ( element -- )
    "Enum value description" $heading
    ($raylib-key)
    { $see-also KeyboardKey } print-element ;

PRIVATE>

! Raylib version info
HELP: RAYLIB_VERSION_MAJOR
{ $values
    value: fixnum
}
{ $description
    The current major version of raylib.
} ;

HELP: RAYLIB_VERSION_MINOR
{ $values
    value: fixnum
}
{ $description
    The current minor version of raylib.
} ;

HELP: RAYLIB_VERSION_PATCH
{ $values
    value: fixnum
}
{ $description
    The current patch version of raylib.
} ;

HELP: RAYLIB_VERSION
{ $values
    value: string
}
{ $description
    A string representing the current version of raylib.
} ;


! Config flag enum
HELP: ConfigFlags
{ $var-description
    An enum representing the various configuration flags in Raylib.

    { $enum-members ConfigFlags } } ;

HELP: FLAG_VSYNC_HINT
{ $class-description
    Setting this flag will attempt to enable v-sync on the GPU.
    { $see-also ConfigFlags } } ;

HELP: FLAG_FULLSCREEN_MODE
{ $class-description
    Setting this flag will run the program in fullscreen
    { $see-also ConfigFlags } } ;

HELP: FLAG_WINDOW_RESIZABLE
{ $class-description
    Setting this flag allows for resizing the window.
    { $see-also ConfigFlags } } ;

HELP: FLAG_WINDOW_UNDECORATED
{ $class-description
    Setting this flag remove window decorations (frame and buttons).
    { $see-also ConfigFlags } } ;

HELP: FLAG_WINDOW_HIDDEN
{ $class-description
    Setting this flag will hide the window.
    { $see-also ConfigFlags } } ;

HELP: FLAG_WINDOW_MINIMIZED
{ $class-description
    Setting this flag will minize the window.
    { $see-also ConfigFlags } } ;

HELP: FLAG_WINDOW_MAXIMIZED
{ $class-description
    Setting this flag will maximize the window to the monitor size.
    { $see-also ConfigFlags } } ;

HELP: FLAG_WINDOW_UNFOCUSED
{ $class-description
    Setting this flag will set the window to be unfocused.
    { $see-also ConfigFlags } } ;

HELP: FLAG_WINDOW_TOPMOST
{ $class-description
    Setting this flag sets the window to always be on top.
    { $see-also ConfigFlags } } ;

HELP: FLAG_WINDOW_ALWAYS_RUN
{ $class-description
    Setting this flag allows the window to run while minimized.
    { $see-also ConfigFlags } } ;

HELP: FLAG_WINDOW_TRANSPARENT
{ $class-description
    Setting this flag allows for transparent framebuffer.
    { $see-also ConfigFlags } } ;

HELP: FLAG_WINDOW_HIGHDPI
{ $class-description
    Setting this flag will enable HighDPI support.
    { $see-also ConfigFlags } } ;

HELP: FLAG_BORDERLESS_WINDOWED_MODE
{ $class-description
    Setting this flag to run program in borderless windowed mode.
    { $see-also ConfigFlags } } ;

HELP: FLAG_MSAA_4X_HINT
{ $class-description
    Setting this flag will attempt to enable MSAA 4x.
    { $see-also ConfigFlags } } ;

HELP: FLAG_INTERLACED_HINT
{ $class-description
    Setting this flag will attempt to enable the interlaced video
    format for V3D.
    { $see-also ConfigFlags } } ;


! Trace log level enum
HELP: TraceLogLevel
{ $var-description
    Represents the various logging levels in Raylib.
    Logs are displayed using the system's standard output.

    { $enum-members TraceLogLevel } } ;

HELP: LOG_ALL
{ $class-description
    Displays all logs.

    { $see-also TraceLogLevel } } ;

HELP: LOG_TRACE
{ $class-description
    Deplays trace logging. \ LOG_TRACE meant for internal usage.

    { $see-also TraceLogLevel } } ;

HELP: LOG_INFO
{ $class-description
    Displays debugging logs. { $snippet LOG_INFO } is used for internal
    debugging and should be disabled on release builds.

    { $see-also TraceLogLevel } } ;

HELP: LOG_WARNING
{ $class-description
    Displays warning logs. Warnings are recoverable failures.

    { $see-also TraceLogLevel } } ;

HELP: LOG_ERROR
{ $class-description
    Displays error logs. Errors are unrecoverable failures.

    { $see-also TraceLogLevel } } ;

HELP: LOG_FATAL
{ $class-description
    Displays fatal logs. Fatal errors are used while aborting
    the program.
    { $see-also TraceLogLevel } } ;

HELP: LOG_NONE
{ $class-description
    Disables raylib logging.

    { $see-also TraceLogLevel } } ;


! Keyboard key enum
HELP: KeyboardKey
{ $var-description
    An enum representing the various key codes Raylib can produce.
    These codes are based on the physical layout of a US QWERTY
    keyboard layout. Use \ get-key-pressed to allow for defining
    alternative layouts.

    { $enum-members KeyboardKey } } ;

HELP: KEY_NULL          { $raylib-key 0    "NULL" " Used for no key pressed." } ;
HELP: KEY_APOSTROPHE    { $raylib-key 39   "'"                                } ;
HELP: KEY_COMMA         { $raylib-key 44   ","                                } ;
HELP: KEY_MINUS         { $raylib-key 45   "-"                                } ;
HELP: KEY_PERIOD        { $raylib-key 46   "."                                } ;
HELP: KEY_SLASH         { $raylib-key 47   "/"                                } ;
HELP: KEY_ZERO          { $raylib-key 48   "0"                                } ;
HELP: KEY_ONE           { $raylib-key 49   "1"                                } ;
HELP: KEY_TWO           { $raylib-key 50   "2"                                } ;
HELP: KEY_THREE         { $raylib-key 51   "3"                                } ;
HELP: KEY_FOUR          { $raylib-key 52   "4"                                } ;
HELP: KEY_FIVE          { $raylib-key 53   "5"                                } ;
HELP: KEY_SIX           { $raylib-key 54   "6"                                } ;
HELP: KEY_SEVEN         { $raylib-key 55   "7"                                } ;
HELP: KEY_EIGHT         { $raylib-key 56   "8"                                } ;
HELP: KEY_NINE          { $raylib-key 57   "9"                                } ;
HELP: KEY_SEMICOLON     { $raylib-key 59   ";"                                } ;
HELP: KEY_EQUAL         { $raylib-key 61   "="                                } ;
HELP: KEY_A             { $raylib-key 65   "lowercase and uppercase A"        } ;
HELP: KEY_B             { $raylib-key 66   "lowercase and uppercase B"        } ;
HELP: KEY_C             { $raylib-key 67   "lowercase and uppercase C"        } ;
HELP: KEY_D             { $raylib-key 68   "lowercase and uppercase D"        } ;
HELP: KEY_E             { $raylib-key 69   "lowercase and uppercase E"        } ;
HELP: KEY_F             { $raylib-key 70   "lowercase and uppercase F"        } ;
HELP: KEY_G             { $raylib-key 71   "lowercase and uppercase G"        } ;
HELP: KEY_H             { $raylib-key 72   "lowercase and uppercase H"        } ;
HELP: KEY_I             { $raylib-key 73   "lowercase and uppercase I"        } ;
HELP: KEY_J             { $raylib-key 74   "lowercase and uppercase J"        } ;
HELP: KEY_K             { $raylib-key 75   "lowercase and uppercase K"        } ;
HELP: KEY_L             { $raylib-key 76   "lowercase and uppercase L"        } ;
HELP: KEY_M             { $raylib-key 77   "lowercase and uppercase M"        } ;
HELP: KEY_N             { $raylib-key 78   "lowercase and uppercase N"        } ;
HELP: KEY_O             { $raylib-key 79   "lowercase and uppercase O"        } ;
HELP: KEY_P             { $raylib-key 80   "lowercase and uppercase P"        } ;
HELP: KEY_Q             { $raylib-key 81   "lowercase and uppercase Q"        } ;
HELP: KEY_R             { $raylib-key 82   "lowercase and uppercase R"        } ;
HELP: KEY_S             { $raylib-key 83   "lowercase and uppercase S"        } ;
HELP: KEY_T             { $raylib-key 84   "lowercase and uppercase T"        } ;
HELP: KEY_U             { $raylib-key 85   "lowercase and uppercase U"        } ;
HELP: KEY_V             { $raylib-key 86   "lowercase and uppercase V"        } ;
HELP: KEY_W             { $raylib-key 87   "lowercase and uppercase W"        } ;
HELP: KEY_X             { $raylib-key 88   "lowercase and uppercase X"        } ;
HELP: KEY_Y             { $raylib-key 89   "lowercase and uppercase Y"        } ;
HELP: KEY_Z             { $raylib-key 90   "lowercase and uppercase Z"        } ;
HELP: KEY_LEFT_BRACKET  { $raylib-key 91   "["                                } ;
HELP: KEY_BACKSLASH     { $raylib-key 92   "\\"                               } ;
HELP: KEY_RIGHT_BRACKET { $raylib-key 93   "]"                                } ;
HELP: KEY_GRAVE         { $raylib-key 96   "`"                                } ;
HELP: KEY_SPACE         { $raylib-key 32   "Space"                            } ;
HELP: KEY_ESCAPE        { $raylib-key 256  "Esc"                              } ;
HELP: KEY_ENTER         { $raylib-key 257  "Enter"                            } ;
HELP: KEY_TAB           { $raylib-key 258  "Tab"                              } ;
HELP: KEY_BACKSPACE     { $raylib-key 259  "Backspace"                        } ;
HELP: KEY_INSERT        { $raylib-key 260  "Ins"                              } ;
HELP: KEY_DELETE        { $raylib-key 261  "Del"                              } ;
HELP: KEY_RIGHT         { $raylib-key 262  "Cursor right"                     } ;
HELP: KEY_LEFT          { $raylib-key 263  "Cursor left"                      } ;
HELP: KEY_DOWN          { $raylib-key 264  "Cursor down"                      } ;
HELP: KEY_UP            { $raylib-key 265  "Cursor up"                        } ;
HELP: KEY_PAGE_UP       { $raylib-key 266  "Page up"                          } ;
HELP: KEY_PAGE_DOWN     { $raylib-key 267  "Page down"                        } ;
HELP: KEY_HOME          { $raylib-key 268  "Home"                             } ;
HELP: KEY_END           { $raylib-key 269  "End"                              } ;
HELP: KEY_CAPS_LOCK     { $raylib-key 280  "Caps lock"                        } ;
HELP: KEY_SCROLL_LOCK   { $raylib-key 281  "Scroll down"                      } ;
HELP: KEY_NUM_LOCK      { $raylib-key 282  "Num lock"                         } ;
HELP: KEY_PRINT_SCREEN  { $raylib-key 283  "Print screen"                     } ;
HELP: KEY_PAUSE         { $raylib-key 284  "Pause"                            } ;
HELP: KEY_F1            { $raylib-key 290  "F1"                               } ;
HELP: KEY_F2            { $raylib-key 291  "F2"                               } ;
HELP: KEY_F3            { $raylib-key 292  "F3"                               } ;
HELP: KEY_F4            { $raylib-key 293  "F4"                               } ;
HELP: KEY_F5            { $raylib-key 294  "F5"                               } ;
HELP: KEY_F6            { $raylib-key 295  "F6"                               } ;
HELP: KEY_F7            { $raylib-key 296  "F7"                               } ;
HELP: KEY_F8            { $raylib-key 297  "F8"                               } ;
HELP: KEY_F9            { $raylib-key 298  "F9"                               } ;
HELP: KEY_F10           { $raylib-key 299  "F10"                              } ;
HELP: KEY_F11           { $raylib-key 300  "F11"                              } ;
HELP: KEY_F12           { $raylib-key 301  "F12"                              } ;
HELP: KEY_LEFT_SHIFT    { $raylib-key 340  "Shift left"                       } ;
HELP: KEY_LEFT_CONTROL  { $raylib-key 341  "Control left"                     } ;
HELP: KEY_LEFT_ALT      { $raylib-key 342  "Alt left"                         } ;
HELP: KEY_LEFT_SUPER    { $raylib-key 343  "Super left"                       } ;
HELP: KEY_RIGHT_SHIFT   { $raylib-key 344  "Shift right"                      } ;
HELP: KEY_RIGHT_CONTROL { $raylib-key 345  "Control right"                    } ;
HELP: KEY_RIGHT_ALT     { $raylib-key 346  "Alt right"                        } ;
HELP: KEY_RIGHT_SUPER   { $raylib-key 347  "Super right"                      } ;
HELP: KEY_KB_MENU       { $raylib-key 348  "KB menu"                          } ;
HELP: KEY_KP_0          { $raylib-key 320  "Keypad 0"                         } ;
HELP: KEY_KP_1          { $raylib-key 321  "Keypad 1"                         } ;
HELP: KEY_KP_2          { $raylib-key 322  "Keypad 2"                         } ;
HELP: KEY_KP_3          { $raylib-key 323  "Keypad 3"                         } ;
HELP: KEY_KP_4          { $raylib-key 324  "Keypad 4"                         } ;
HELP: KEY_KP_5          { $raylib-key 325  "Keypad 5"                         } ;
HELP: KEY_KP_6          { $raylib-key 326  "Keypad 6"                         } ;
HELP: KEY_KP_7          { $raylib-key 327  "Keypad 7"                         } ;
HELP: KEY_KP_8          { $raylib-key 328  "Keypad 8"                         } ;
HELP: KEY_KP_9          { $raylib-key 329  "Keypad 9"                         } ;
HELP: KEY_KP_DECIMAL    { $raylib-key 330  "Keypad ."                         } ;
HELP: KEY_KP_DIVIDE     { $raylib-key 331  "Keypad /"                         } ;
HELP: KEY_KP_MULTIPLY   { $raylib-key 332  "Keypad *"                         } ;
HELP: KEY_KP_SUBTRACT   { $raylib-key 333  "Keypad -"                         } ;
HELP: KEY_KP_ADD        { $raylib-key 334  "Keypad +"                         } ;
HELP: KEY_KP_ENTER      { $raylib-key 335  "Keypad Enter"                     } ;
HELP: KEY_KP_EQUAL      { $raylib-key 336  "Keypad ="                         } ;
HELP: KEY_BACK          { $raylib-key 4    "Android back button"              } ;
HELP: KEY_MENU          { $raylib-key 82   "Android menu button"              } ;
HELP: KEY_VOLUME_UP     { $raylib-key 24   "Android volume up button"         } ;
HELP: KEY_VOLUME_DOWN   { $raylib-key 25   "Android volume down button"       } ;


! Mouse button enum
HELP: MouseButton
{ $var-description
    An enum representing the various key mouse buttons Ralyb has support for.

    { $enum-members MouseButton } } ;

HELP: MOUSE_BUTTON_LEFT
{ $class-description
    Represents the left mouse button.

    { $see-also MouseButton } } ;

HELP: MOUSE_BUTTON_RIGHT
{ $class-description
    Represents the right mouse button.

    { $see-also MouseButton } } ;

HELP: MOUSE_BUTTON_MIDDLE
{ $class-description
    Represents the middle mouse button. On most mice, this is clicking
    the scroll wheel.

    { $see-also MouseButton } } ;

HELP: MOUSE_BUTTON_SIDE
{ $class-description
    Represents a side button on mice that have additional buttons.

    { $see-also MouseButton } } ;

HELP: MOUSE_BUTTON_EXTRA
{ $class-description
    Represents an extra button on mice that have additional buttons.

    { $see-also MouseButton } } ;

HELP: MOUSE_BUTTON_FORWARD
{ $class-description
    Represents the " \"forward\" " button on mice that have additional buttons.

    { $see-also MouseButton } } ;

HELP: MOUSE_BUTTON_BACK
{ $class-description
    Represents the " \"back\" " button on mice that have additional buttons.

    { $see-also MouseButton } } ;


! Mouse cursor enum
HELP: MouseCursor
{ $var-description
    An enum representing the various states the cursor can be in.
    This is used to change the cursor icon " / " shape.


    { $enum-members MouseCursor } } ;

HELP: MOUSE_CURSOR_DEFAULT
{ $var-description
    Default pointer shape.

    { $see-also MouseCursor } } ;

HELP: MOUSE_CURSOR_ARROW
{ $var-description
    Arrow shape.

    { $see-also MouseCursor } } ;

HELP: MOUSE_CURSOR_IBEAM
{ $var-description
    Text writing cursor shape.

    { $see-also MouseCursor } } ;

HELP: MOUSE_CURSOR_CROSSHAIR
{ $var-description
    Cross shape.

    { $see-also MouseCursor } } ;

HELP: MOUSE_CURSOR_POINTING_HAND
{ $var-description
    Pointing hand cursor.

    { $see-also MouseCursor } } ;

HELP: MOUSE_CURSOR_RESIZE_EW
{ $var-description
    Horizontal resize/move arrow shape.

    { $see-also MouseCursor } } ;

HELP: MOUSE_CURSOR_RESIZE_NS
{ $var-description
    Vertical resize/move arrow shape.

    { $see-also MouseCursor } } ;

HELP: MOUSE_CURSOR_RESIZE_NWSE
{ $var-description
    Top-left to bottom-right diagonal resize/move arrow shape.

    { $see-also MouseCursor } } ;

HELP: MOUSE_CURSOR_RESIZE_NESW
{ $var-description
    The top-right to bottom-left diagonal resize/move arrow shape.

    { $see-also MouseCursor } } ;

HELP: MOUSE_CURSOR_RESIZE_ALL
{ $var-description
    The omni-directional resize/move cursor shape.

    { $see-also MouseCursor } } ;

HELP: MOUSE_CURSOR_NOT_ALLOWED
{ $var-description
    The operation-not-allowed shape.

    { $see-also MouseCursor } } ;


! Gamepad button enum
HELP: GamepadButton
{ $var-description
    This enum represents the various buttons a gamepad might have.

    It's important to keep in mind different controllers may have
    different button orderings. Each enum member notes the
    differences in their respective documentation sections.

    { $see-also GamepadAxis }

    { $enum-members GamepadButton } } ;

HELP: GAMEPAD_BUTTON_UNKNOWN
{ $class-description
     Unknown button, just for error checking

     { $see-also GamepadButton } } ;

HELP: GAMEPAD_BUTTON_LEFT_FACE_UP
{ $class-description
     Gamepad left DPAD up button

     { $see-also GamepadButton } } ;

HELP: GAMEPAD_BUTTON_LEFT_FACE_RIGHT
{ $class-description
     Gamepad left DPAD right button

     { $see-also GamepadButton } } ;

HELP: GAMEPAD_BUTTON_LEFT_FACE_DOWN
{ $class-description
     Gamepad left DPAD down button

     { $see-also GamepadButton } } ;

HELP: GAMEPAD_BUTTON_LEFT_FACE_LEFT
{ $class-description
     Gamepad left DPAD left button

     { $see-also GamepadButton } } ;

HELP: GAMEPAD_BUTTON_RIGHT_FACE_UP
{ $class-description
     Gamepad right button up (i.e. PS3: Triangle, Xbox: Y)

     { $see-also GamepadButton } } ;

HELP: GAMEPAD_BUTTON_RIGHT_FACE_RIGHT
{ $class-description
     Gamepad right button right (i.e. PS3: Square, Xbox: X)

     { $see-also GamepadButton } } ;

HELP: GAMEPAD_BUTTON_RIGHT_FACE_DOWN
{ $class-description
     Gamepad right button down (i.e. PS3: Cross, Xbox: A)

     { $see-also GamepadButton } } ;

HELP: GAMEPAD_BUTTON_RIGHT_FACE_LEFT
{ $class-description
     Gamepad right button left (i.e. PS3: Circle, Xbox: B)

     { $see-also GamepadButton } } ;

HELP: GAMEPAD_BUTTON_LEFT_TRIGGER_1
{ $class-description
     Gamepad top/back trigger left (first), it could be a trailing button

     { $see-also GamepadButton } } ;

HELP: GAMEPAD_BUTTON_LEFT_TRIGGER_2
{ $class-description
     Gamepad top/back trigger left (second), it could be a trailing button

     { $see-also GamepadButton } } ;

HELP: GAMEPAD_BUTTON_RIGHT_TRIGGER_1
{ $class-description
     Gamepad top/back trigger right (one), it could be a trailing button

     { $see-also GamepadButton } } ;

HELP: GAMEPAD_BUTTON_RIGHT_TRIGGER_2
{ $class-description
     Gamepad top/back trigger right (second), it could be a trailing button

     { $see-also GamepadButton } } ;

HELP: GAMEPAD_BUTTON_MIDDLE_LEFT
{ $class-description
     Gamepad center buttons, left one (i.e. PS3: Select)

     { $see-also GamepadButton } } ;

HELP: GAMEPAD_BUTTON_MIDDLE
{ $class-description
     Gamepad center buttons, middle one (i.e. PS3: PS, Xbox: XBOX)

     { $see-also GamepadButton } } ;

HELP: GAMEPAD_BUTTON_MIDDLE_RIGHT
{ $class-description
     Gamepad center buttons, right one (i.e. PS3: Start)

     { $see-also GamepadButton } } ;

HELP: GAMEPAD_BUTTON_LEFT_THUMB
{ $class-description
     Gamepad joystick pressed button left

     { $see-also GamepadButton } } ;

HELP: GAMEPAD_BUTTON_RIGHT_THUMB
{ $class-description
     Gamepad joystick pressed button right

     { $see-also GamepadButton } } ;


! Gamepad axis enum
HELP: GamepadAxis
{ $var-description
    Contains a set of flags for each axis a gamepad may have. Raylib
    supports controllers with two triggers and two joysticks.

    { $enum-members GamepadAxis } } ;

HELP: GAMEPAD_AXIS_LEFT_X
{ $class-description
    Represents the left gamepad stick and its tilt on the X axis (left/right).
    { $see-also GamepadAxis } } ;

HELP: GAMEPAD_AXIS_LEFT_Y
{ $class-description
    Represents the left gamepad stick and its tilt on the Y axis (up/down).
    { $see-also GamepadAxis } } ;

HELP: GAMEPAD_AXIS_RIGHT_X
{ $class-description
    Represents the right gamepad stick and its tilt on the X axis (left/right).
    { $see-also GamepadAxis } } ;

HELP: GAMEPAD_AXIS_RIGHT_Y
{ $class-description
    Represents the right gamepad stick and its tilt on the Y axis (up/down).
    { $see-also GamepadAxis } } ;

HELP: GAMEPAD_AXIS_LEFT_TRIGGER
{ $class-description
    Represents the left gamepad trigger. Trigger has the value
    range [1..-1].
    { $see-also GamepadAxis } } ;

HELP: GAMEPAD_AXIS_RIGHT_TRIGGER
{ $class-description
    Represents the left gamepad trigger. Trigger has the value
    range [1..-1].
    { $see-also GamepadAxis } } ;


! Material map index enum
HELP: MaterialMapIndex
{ $var-description
    Provides convient names for each index into a texture's various
    material maps.

    { $enum-members MaterialMapIndex } } ;
HELP: MATERIAL_MAP_ALBEDO
{ $class-description
    Represents the index for a texture's albedo material (same as: \ MATERIAL_MAP_DIFFUSE ).

    { $see-also MaterialMapIndex } } ;

HELP: MATERIAL_MAP_METALNESS
{ $class-description
    Represents the index for a texture's metalness material (same as: \ MATERIAL_MAP_SPECULAR ).

    { $see-also MaterialMapIndex } } ;

HELP: MATERIAL_MAP_NORMAL
{ $class-description
    Represents the index for a texture's normal material.

    { $see-also MaterialMapIndex } } ;

HELP: MATERIAL_MAP_ROUGHNESS
{ $class-description
    Represents the index for a texture's roughness material.

    { $see-also MaterialMapIndex } } ;

HELP: MATERIAL_MAP_OCCLUSION
{ $class-description
    Represents the index for a texture's ambient occlusion material.

    { $see-also MaterialMapIndex } } ;

HELP: MATERIAL_MAP_EMISSION
{ $class-description
    Represents the index for a texture's emission material.

    { $see-also MaterialMapIndex } } ;

HELP: MATERIAL_MAP_HEIGHT
{ $class-description
    Represents the index for a texture's heightmap material.

    { $see-also MaterialMapIndex } } ;

HELP: MATERIAL_MAP_CUBEMAP
{ $class-description
    Represents the index for a texture's Cubemap material (NOTE: Uses GL_TEXTURE_CUBE_MAP).

    { $see-also MaterialMapIndex } } ;

HELP: MATERIAL_MAP_IRRADIANCE
{ $class-description
    Represents the index for a texture's irradiance material (NOTE: Uses GL_TEXTURE_CUBE_MAP).

    { $see-also MaterialMapIndex } } ;

HELP: MATERIAL_MAP_PREFILTER
{ $class-description
    Represents the index for a texture's prefilter material (NOTE: Uses GL_TEXTURE_CUBE_MAP).

    { $see-also MaterialMapIndex } } ;

HELP: MATERIAL_MAP_BRDF
{ $class-description
    Represents the index for a texture's brdf material.

    { $see-also MaterialMapIndex } } ;

! Shader Location Index
! TODO: make a better description of these. They are kinda bad...
HELP: ShaderLocationIndex
{ $var-description
    Shader location index enum.

    { $enum-members ShaderLocationIndex } } ;

HELP: SHADER_LOC_VERTEX_POSITION
{ $class-description
    Shader location: vertex attribute: position

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_VERTEX_TEXCOORD01
{ $class-description
    Shader location: vertex attribute: texcoord01

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_VERTEX_TEXCOORD02
{ $class-description
    Shader location: vertex attribute: texcoord02

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_VERTEX_NORMAL
{ $class-description
    Shader location: vertex attribute: normal

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_VERTEX_TANGENT
{ $class-description
    Shader location: vertex attribute: tangent

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_VERTEX_COLOR
{ $class-description
    Shader location: vertex attribute: color

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_MATRIX_MVP
{ $class-description
    Shader location: matrix uniform: model-view-projection

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_MATRIX_VIEW
{ $class-description
    Shader location: matrix uniform: view (camera transform)

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_MATRIX_PROJECTION
{ $class-description
    Shader location: matrix uniform: projection

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_MATRIX_MODEL
{ $class-description
    Shader location: matrix uniform: model (transform)

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_MATRIX_NORMAL
{ $class-description
    Shader location: matrix uniform: normal

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_VECTOR_VIEW
{ $class-description
    Shader location: vector uniform: view

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_COLOR_DIFFUSE
{ $class-description
    Shader location: vector uniform: diffuse color

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_COLOR_SPECULAR
{ $class-description
    Shader location: vector uniform: specular color

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_COLOR_AMBIENT
{ $class-description
    Shader location: vector uniform: ambient color

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_MAP_ALBEDO
{ $class-description
    Shader location: sampler2d texture: albedo (same as: SHADER_LOC_MAP_DIFFUSE)

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_MAP_METALNESS
{ $class-description
    Shader location: sampler2d texture: metalness (same as: SHADER_LOC_MAP_SPECULAR)

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_MAP_NORMAL
{ $class-description
    Shader location: sampler2d texture: normal

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_MAP_ROUGHNESS
{ $class-description
    Shader location: sampler2d texture: roughness

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_MAP_OCCLUSION
{ $class-description
    Shader location: sampler2d texture: occlusion

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_MAP_EMISSION
{ $class-description
    Shader location: sampler2d texture: emission

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_MAP_HEIGHT
{ $class-description
    Shader location: sampler2d texture: height

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_MAP_CUBEMAP
{ $class-description
    Shader location: samplerCube texture: cubemap

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_MAP_IRRADIANCE
{ $class-description
    Shader location: samplerCube texture: irradiance

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_MAP_PREFILTER
{ $class-description
    Shader location: samplerCube texture: prefilter

    { $see-also ShaderLocationIndex } } ;

HELP: SHADER_LOC_MAP_BRDF
{ $class-description
    Shader location: sampler2d texture: brdf

    { $see-also ShaderLocationIndex } } ;



! Shader uniform data type
! TODO: Better descriptions for these...
HELP: ShaderUniformDataType
{ $var-description
    Represents the various types a uniform shader can be.

    { $enum-members MaterialMapIndex } } ;

HELP: SHADER_UNIFORM_FLOAT
{ $class-description
    Shader uniform type: float
    { $see-also ShaderUniformDataType } } ;

HELP: SHADER_UNIFORM_VEC2
{ $class-description
    Shader uniform type: vec2 (2 float)
    { $see-also ShaderUniformDataType } } ;

HELP: SHADER_UNIFORM_VEC3
{ $class-description
    Shader uniform type: vec3 (3 float)
    { $see-also ShaderUniformDataType } } ;

HELP: SHADER_UNIFORM_VEC4
{ $class-description
    Shader uniform type: vec4 (4 float)
    { $see-also ShaderUniformDataType } } ;

HELP: SHADER_UNIFORM_INT
{ $class-description
    Shader uniform type: int
    { $see-also ShaderUniformDataType } } ;

HELP: SHADER_UNIFORM_IVEC2
{ $class-description
    Shader uniform type: ivec2 (2 int)
    { $see-also ShaderUniformDataType } } ;

HELP: SHADER_UNIFORM_IVEC3
{ $class-description
    Shader uniform type: ivec3 (3 int)
    { $see-also ShaderUniformDataType } } ;

HELP: SHADER_UNIFORM_IVEC4
{ $class-description
    Shader uniform type: ivec4 (4 int)
    { $see-also ShaderUniformDataType } } ;

HELP: SHADER_UNIFORM_SAMPLER2D
{ $class-description
    Shader uniform type: sampler2d
    { $see-also ShaderUniformDataType } } ;


! Shader attribute data type enum
HELP: ShaderAttributeDataType
{ $var-description
    Shader attribute data types

    { $enum-members ShaderAttributeDataType } } ;

HELP: SHADER_ATTRIB_FLOAT
{ $class-description
    Shader attribute type: float

    { $see-also ShaderAttributeDataType } } ;

HELP: SHADER_ATTRIB_VEC2
{ $class-description
    Shader attribute type: vec2 (2 float)

    { $see-also ShaderAttributeDataType } } ;

HELP: SHADER_ATTRIB_VEC3
{ $class-description
    Shader attribute type: vec3 (3 float)

    { $see-also ShaderAttributeDataType } } ;

HELP: SHADER_ATTRIB_VEC4
{ $class-description
    Shader attribute type: vec4 (4 float)

    { $see-also ShaderAttributeDataType } } ;


! Pixel format enum.
HELP: PixelFormat
{ $var-description
    The various pixel formats that can be used by Raylib.
    This enum's values start from { $snippet 1 } .

    { $warning Support depends on OpenGL version and platform. }
    { $enum-members PixelFormat } } ;

HELP: PIXELFORMAT_UNCOMPRESSED_GRAYSCALE
{ $class-description
    8 bit per pixel (no alpha).

    { $see-also PixelFormat } } ;

HELP: PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA
{ $class-description
    8*2 bits per pixel (2 channels).

    { $see-also PixelFormat } } ;

HELP: PIXELFORMAT_UNCOMPRESSED_R5G6B5
{ $class-description
    16 bits per pixel.

    { $see-also PixelFormat } } ;

HELP: PIXELFORMAT_UNCOMPRESSED_R8G8B8
{ $class-description
    24 bits per pixel.

    { $see-also PixelFormat } } ;

HELP: PIXELFORMAT_UNCOMPRESSED_R5G5B5A1
{ $class-description
    16 bits per pixel (1 bit alpha).

    { $see-also PixelFormat } } ;

HELP: PIXELFORMAT_UNCOMPRESSED_R4G4B4A4
{ $class-description
    16 bits per pixel (4 bit alpha).

    { $see-also PixelFormat } } ;

HELP: PIXELFORMAT_UNCOMPRESSED_R8G8B8A8
{ $class-description
    32 bits per pixel.

    { $see-also PixelFormat } } ;

HELP: PIXELFORMAT_UNCOMPRESSED_R32
{ $class-description
    32 bits per pixel (1 channel - float).

    { $see-also PixelFormat } } ;

HELP: PIXELFORMAT_UNCOMPRESSED_R32G32B32
{ $class-description
    32*3 bits per pixel (3 channels - float).

    { $see-also PixelFormat } } ;

HELP: PIXELFORMAT_UNCOMPRESSED_R32G32B32A32
{ $class-description
    32*4 bits per pixel (4 channels - float).

    { $see-also PixelFormat } } ;

HELP: PIXELFORMAT_UNCOMPRESSED_R16
{ $class-description
    16 bits per pixel (1 channel - half float).

    { $see-also PixelFormat } } ;

HELP: PIXELFORMAT_UNCOMPRESSED_R16G16B16
{ $class-description
    16*3 bits per pixel (3 channels - half float).

    { $see-also PixelFormat } } ;

HELP: PIXELFORMAT_UNCOMPRESSED_R16G16B16A16
{ $class-description
    16*4 bits per pixel (4 channels - half float).

    { $see-also PixelFormat } } ;

HELP: PIXELFORMAT_COMPRESSED_DXT1_RGB
{ $class-description
    4 bits per pixel (no alpha).

    { $see-also PixelFormat } } ;

HELP: PIXELFORMAT_COMPRESSED_DXT1_RGBA
{ $class-description
    4 bits per pixel (1 bit alpha).

    { $see-also PixelFormat } } ;

HELP: PIXELFORMAT_COMPRESSED_DXT3_RGBA
{ $class-description
    8 bits per pixel.

    { $see-also PixelFormat } } ;

HELP: PIXELFORMAT_COMPRESSED_DXT5_RGBA
{ $class-description
    8 bits per pixel.

    { $see-also PixelFormat } } ;

HELP: PIXELFORMAT_COMPRESSED_ETC1_RGB
{ $class-description
    4 bits per pixel.

    { $see-also PixelFormat } } ;

HELP: PIXELFORMAT_COMPRESSED_ETC2_RGB
{ $class-description
    4 bits per pixel.

    { $see-also PixelFormat } } ;

HELP: PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA
{ $class-description
    8 bits per pixel.

    { $see-also PixelFormat } } ;

HELP: PIXELFORMAT_COMPRESSED_PVRT_RGB
{ $class-description
    4 bits per pixel.

    { $see-also PixelFormat } } ;

HELP: PIXELFORMAT_COMPRESSED_PVRT_RGBA
{ $class-description
    4 bits per pixel.

    { $see-also PixelFormat } } ;

HELP: PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA
{ $class-description
    8 bits per pixel.

    { $see-also PixelFormat } } ;

HELP: PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA
{ $class-description
    2 bits per pixel.

    { $see-also PixelFormat } } ;


! Texture filter mode enum
HELP: TextureFilterMode
{ $var-description
    Controls the filter mode of the texture. In Raylib, filtering will
    consider mipmaps if available in the current texture. Additionally,
    filter is accordingly set for minification and magnification.

    { $enum-members TextureFilterMode } } ;

HELP: TEXTURE_FILTER_POINT
{ $class-description
    No filter just pixel aproximation.

    { $see-also TextureFilterMode } } ;

HELP: TEXTURE_FILTER_BILINEAR
{ $class-description
    Linear filtering.

    { $see-also TextureFilterMode } } ;

HELP: TEXTURE_FILTER_TRILINEAR
{ $class-description
    Trilinear filtering (linear with mipmaps).

    { $see-also TextureFilterMode } } ;

HELP: TEXTURE_FILTER_ANISOTROPIC_4X
{ $class-description
    Anisotropic filtering 4x.

    { $see-also TextureFilterMode } } ;

HELP: TEXTURE_FILTER_ANISOTROPIC_8X
{ $class-description
    Anisotropic filtering 8x.

    { $see-also TextureFilterMode } } ;

HELP: TEXTURE_FILTER_ANISOTROPIC_16X
{ $class-description
    Anisotropic filtering 16x.

    { $see-also TextureFilterMode } } ;


! Texture wrap mode enume
HELP: TextureWrapMode
{ $var-description
    Represents the way a texture will repeate when reading
    past the image bounds.

    { $enum-members TextureWrapMode } } ;

HELP: TEXTURE_WRAP_REPEAT
{ $class-description
    Using this mode, a texture will repeate infinitely in all directions.

    { $see-also TextureWrapMode } } ;

HELP: TEXTURE_WRAP_CLAMP
{ $class-description
    Using this mode, the edge pixels in a texture will
    be stretched out into infinity.

    { $see-also TextureWrapMode } } ;

HELP:
TEXTURE_WRAP_MIRROR_REPEAT
{ $class-description
    Using this mode, the texture will repeat infinitely in all directions.
    However, each tiling will be mirrored compared to the previous tiling.


    { $see-also TextureWrapMode } } ;

HELP: TEXTURE_WRAP_MIRROR_CLAMP
{ $class-description
    This mode combines mirrored with clamped. The texture will infinitely
    tile the last pixel from the oppisite side.

    { $see-also TextureWrapMode } } ;


! Cubemap layout enum
HELP: CubemapLayout
{ $var-description
    Represents the layout a cube map is using.

    { $enum-members CubemapLayout } } ;

HELP: CUBEMAP_LAYOUT_AUTO_DETECT
{ $class-description
    Raylib will attempt to automatically detect the cubemap's layout type.

    { $see-also CubemapLayout } } ;

HELP: CUBEMAP_LAYOUT_LINE_VERTICAL
{ $class-description
    A cubemap who's layout is defined by a horizontal line with faces.

    { $see-also CubemapLayout } } ;

HELP: CUBEMAP_LAYOUT_LINE_HORIZONTAL
{ $class-description
    A cubemap who's layout is defined by a vertical line with faces.

    { $see-also CubemapLayout } } ;

HELP: CUBEMAP_LAYOUT_CROSS_THREE_BY_FOUR
{ $class-description
    A cubemap who's layout is defined by a 3x4 cross with cubemap faces.

    { $see-also CubemapLayout } } ;

HELP: CUBEMAP_LAYOUT_CROSS_FOUR_BY_THREE
{ $class-description
    A cubemap who's layout is defined by a 4x3 cross with cubemap faces.

    { $see-also CubemapLayout } } ;

! font type enum
HELP: FontType
{ $var-description
    A C-enum defining the various font generation methods in Raylib.

    { $enum-members FontType } } ;

HELP: FONT_DEFAULT
{ $class-description
    Default font generation with anti-aliasing.

    { $see-also FontType } } ;

HELP: FONT_BITMAP
{ $class-description
    Bitmap font generation without anti-aliasing.

    { $see-also FontType } } ;

HELP: FONT_SDF
{ $class-description
    SDF font generation. Requires an external shader.

    { $see-also FontType } } ;


! Blend mode enum
HELP: BlendMode
{ $var-description
    A C-enum holding the OpenGL texture blend modes.


    { $enum-members BlendMode } } ;

HELP: BLEND_ALPHA
{ $class-description
    Blend mode for blending texturing while considering the alpha channel.
    This is the default mode.
    { $see-also BlendMode } } ;

HELP: BLEND_ADDITIVE
{ $class-description
    Blend mode for blending textures while adding colors
    { $see-also BlendMode } } ;

HELP: BLEND_MULTIPLIED
{ $class-description
    Blend mode for blending textures while multiplying colors.
    { $see-also BlendMode } } ;

HELP: BLEND_ADD_COLORS
{ $class-description
    Alternative blend mode to \ BLEND_ADDITIVE
    { $see-also BlendMode } } ;

HELP: BLEND_SUBTRACT_COLORS
{ $class-description
    Blend mode for blending textures while subtracting colors.
    { $see-also BlendMode } } ;

HELP: BLEND_ALPHA_PREMULTIPLY
{ $class-description
    Blend mode for blending premultipled textures while considering the alpha channel
    { $see-also BlendMode } } ;

HELP: BLEND_CUSTOM
{ $class-description
    Blend mode for using custom src/dst factors. This is intended for use with
    { $snippet rl-set-blend-factors } from { $vocab-link "rlgl" } .
    { $see-also BlendMode } } ;

HELP: BLEND_CUSTOM_SEPARATE
{ $class-description
    Blend mode for using custom rgb/alpha separate src/dst
    factors. This is intended for use with { $snippet rl-set-blend-factors-separate }
    from { $vocab-link "rlgl" } .
    { $see-also BlendMode } } ;


! Gestures enum
HELP: Gestures
{ $var-description
    Represents the various touch gestures Raylib supports.
    This enum is a set of bitflags to enable desired
    gestures individually.

    { $enum-members Gestures } } ;

HELP: GESTURE_NONE
{ $class-description
    Used as the empty set of gestures.

    Has the value: { $snippet 0 }
    { $see-also Gestures } } ;

HELP: GESTURE_TAP
{ $class-description
    Represents a tap gesture.

    Has the value: { $snippet 1 }
    { $see-also Gestures } } ;

HELP: GESTURE_DOUBLETAP
{ $class-description
    Represents a double tap gesture.

    Has the value: { $snippet 2 }
    { $see-also Gestures } } ;

HELP: GESTURE_HOLD
{ $class-description
    Represents a hold gesture.

    Has the value: { $snippet 4 }
    { $see-also Gestures } } ;

HELP: GESTURE_DRAG
{ $class-description
    Represents a drag gesture.

    Has the value: { $snippet 8 }
    { $see-also Gestures } } ;
HELP: GESTURE_SWIPE_RIGHT
{ $class-description
    Represents a swipe to the right.

    Has the value: { $snippet 16 }
    { $see-also Gestures } } ;

HELP: GESTURE_SWIPE_LEFT
{ $class-description
    Represents a swipe to the left

    Has the value: { $snippet 32 }
    { $see-also Gestures } } ;

HELP: GESTURE_SWIPE_UP
{ $class-description
    Represents a swap upwards.

    Has the value: { $snippet 64 }
    { $see-also Gestures } } ;

HELP: GESTURE_SWIPE_DOWN
{ $class-description
    Represents a swap downwards.

    Has the value: { $snippet 128 }
    { $see-also Gestures } } ;

HELP: GESTURE_PINCH_IN
{ $class-description
    Represents a inwards pinch.

    Has the value: { $snippet 256 }
    { $see-also Gestures } } ;

HELP: GESTURE_PINCH_OUT
{ $class-description
    Represents a outwards pinch.

    Has the value: { $snippet 512 }
    { $see-also Gestures } } ;


! Camera mode enum
HELP: CameraMode
{ $var-description
    The various modes a camera can behave in Raylib.

    { $enum-members CameraMode } } ;

HELP: CAMERA_CUSTOM
{ $class-description
    A 3D camera with custom behavior.

    { $see-also CameraMode } } ;

HELP: CAMERA_FREE
{ $class-description
    A \ Camera3D with unrestricted movement.

    { $see-also CameraMode } } ;

HELP: CAMERA_ORBITAL
{ $class-description
    A \ Camera3D that will orbit a fixed point in 3D space.

    { $see-also CameraMode } } ;

HELP: CAMERA_FIRST_PERSON
{ $class-description
    A \ Camera3D that cannot roll and looked on the up-axis.

    { $see-also CameraMode } } ;

HELP: CAMERA_THIRD_PERSON
{ $class-description
    Similiar to \ CAMERA_FIRST_PERSON , however the camera is focused
    to a target point.

    { $see-also CameraMode } } ;


! Camera projection enum
HELP: CameraProjection
{ $var-description
    Represents the projects a camera can use.

    { $enum-members CameraProjection } } ;

HELP: CAMERA_PERSPECTIVE
{ $class-description
    Sets a \ Camera3D to use a perspective projection.

    { $see-also CameraProjection } } ;

HELP: CAMERA_ORTHOGRAPHIC
{ $class-description
    Sets a \ Camera3D to use an orthographic projection. Parallel lines
    will stay parallel in this projection.

    { $see-also CameraProjection } } ;


! N-patch layout enum
HELP: NPatchLayout
{ $var-description
    Raylib features support for " \"n-patch\" " tiles. N-patches allow
    for texture to be automatically repeated and stretched. Raylib
    has support for the follow n-patch styles:
    { $list
        { "3x3 (" { $link NPATCH_NINE_PATCH } ")"           }
        { "1x3 (" { $link NPATCH_THREE_PATCH_VERTICAL } ")" }
        { "3x1 (" { $link NPATCH_THREE_PATCH_HORIZONTAL } ")" }
    }
    $nl
    See the following page for an example:
    $nl
    { $url "https://www.raylib.com/examples/textures/loader.html?name=textures_npatch_drawing" }
    { $enum-members NPatchLayout } } ;

HELP: NPATCH_NINE_PATCH
{ $class-description
    Represents a 3x3 n-patch tile. This tile type can expand both horizontally
    and vertically. It has the following sections:
    { $list
        { "4 corners that are neither stretched nor scaled." }
        { "4 edge tiles (top, bottom, left, right) that will be repeated
            vertically and horizontally." }
        { "1 center tile that will be stretched to fill the space between
            the edge tiles and corner tiles." }
    }

    { $see-also NPatchLayout } } ;

HELP: NPATCH_THREE_PATCH_VERTICAL
{ $class-description
    Represents a 1x3 tiling that can be stretched vertically.

    { $see-also NPatchLayout } } ;

HELP: NPATCH_THREE_PATCH_HORIZONTAL
{ $class-description
    Represents a 3x1 tiling that can be streched vertically.

    { $see-also NPatchLayout } } ;

HELP: Vector2
{ $class-description
    Represents a 2D vector in Raylib. Implements the
    { $link "sequence-protocol" } .

    { $warning
        Values are all single-precision where
        as Factor is double precision (see \ alien.c-types:float ) } } ;

HELP: Vector3
{ $class-description
    Represents a 3D vector in Raylib. Implements the
    { $link "sequence-protocol" } .

    { $warning
        Values are all single-precision where
        as Factor is double precision (see \ alien.c-types:float ) } } ;

HELP: Vector4
{ $class-description
    Represents a 4D vector in Raylib. Implements the
    { $link "sequence-protocol" } .

    { $warning
        Values are all single-precision where
        as Factor is double precision (see \ alien.c-types:float ) } } ;

HELP: Quaternion
{ $description
    A c-typedef for a \ Vector4 . } ;

HELP: invalid-vector-length 
{ $error-description 
    Raised when calling functions such as \ like
    and \ new-sequence . Indicates that the 
    converted sequence doesn't fit into the bounds
    of the given \ Vector2 , \ Vector3 , \ Vector4 . } ;

HELP: <Vector2> 
{ $values 
    x: float 
    y: float 
    Vector2: Vector2 }
{ $description
    Constructs a new \ Vector2 . } ;

HELP: <Vector3> 
{ $values 
    x: float 
    y: float 
    z: float 
    Vector3: Vector3 }
{ $description
    Constructs a new \ Vector3 . } ;

HELP: <Vector4> 
{ $values 
    x: float 
    y: float 
    z: float 
    w: float 
    Vector4: Vector4 }
{ $description
    Constructs a new \ Vector4 . } ;

HELP: Matrix
{ $class-description
    Represents a 4x4 OpenGL style matrix. It's right handed
    and column major.

    { $warning
        Values are all single-precision where
        as Factor is double precision (see \ alien.c-types:float ) } } ;
HELP: Color
{ $class-description
    Represents a RGBA color with 8-bit unsigned components.
    Raylib comes with 25 default colors.

    { $heading Builtin colors }
    { $subsections
        LIGHTGRAY
        GRAY
        DARKGRAY
        YELLOW
        GOLD
        ORANGE
        PINK
        RED
        MAROON
        GREEN
        LIME
        DARKGREEN
        SKYBLUE
        BLUE
        DARKBLUE
        PURPLE
        VIOLET
        DARKPURPLE
        BEIGE
        BROWN
        DARKBROWN
        WHITE
        BLACK
        MAGENTA
        RAYWHITE } } ;

HELP: Rectangle
{ $class-description
    Represents a 2D rectangle defined by a x position, y position, width, and height.
    { $warning
        Values are all single-precision where
        as Factor is double precision (see \ alien.c-types:float ) } } ;

HELP: Image
{ $class-description 
    Represents a RGBA (32bit) image in Raylib. 
    Data is always stored in main memory. }
{ $heading Fields }
{ $table 
    { "data"    { $link void* }       "Image raw data"                 }
    { "width"   { $link int }         "Image base width"               }
    { "height"  { $link int }         "Image base height"              }
    { "mipmaps" { $link int }         "Mipmap levels, 1 by default"    }
    { "format"  { $link PixelFormat } "Data format (PixelFormat type)" } 
} ;

HELP: Texture2D
{ $class-description 
    Represents an texture stored on the GPU. }
{ $heading Fields }
{ $table 
    { "id"      { $link uint        }  "OpenGL Texture ID"              }   
    { "width"   { $link int         }  "Texture Base Width"             }  
    { "height"  { $link int         }  "Texture Base Height"            }                 
    { "mipmaps" { $link int         }  "Mipmap Levels, 1 by default"    }               
    { "format"  { $link PixelFormat }  "Data Format (PixelFormat type)" }     
}  ;

HELP: RenderTexture2D
{ $class-description
    FBO for texture rendering. }
{ $heading Fields }
{ $table 
    { "id"       { $link uint      } "OpenGL Framebuffer Object (FBO) id" }                         
    { "texture"  { $link Texture2D } "Color buffer attachment texture"    }               
    { "depth"    { $link Texture2D } "Depth buffer attachment texture"    } 
} ;               


HELP: NPatchInfo
{ $class-description
    Information about a n-patch tile. }
{ $heading Fields }
{ $table 
    { "source"  { $link Rectangle } "Texture source rectangle"               }
    { "left"    { $link int       } "Left border offset"                     }
    { "top"     { $link int       } "Top border offset"                      }
    { "right"   { $link int       } "Right border offset"                    }
    { "bottom"  { $link int       } "Bottom border offset"                   }
    { "layout"  { $link int       } "Layout of the n-patch: 3x3, 1x3 or 3x1" }
} ;

HELP: GlyphInfo
{ $class-description 
    Contains information about the gyphs in a font. }
{ $heading Fields }
{ $table 
    { "value"    { $link int    } "Texture source rectangle"  }
    { "offsetX"  { $link int    } "Texture source rectangle"  }
    { "offsetY"  { $link int    } "Left border offset"        }
    { "advanceX" { $link int    } "Top border offset"         }
    { "image"    { $link Image  } "Right border offset"       }
} ;

HELP: Font
{ $class-description
    Represents a collections of glyphs that can be drawn to the screen.
    The fields are defined as followed: }
{ $heading Fields }
{ $table
    { { $snippet baseSize     } { " the base size of the characters. This is how tall a glyph is." } }
    { { $snippet glyphCount   } { " the number of glyph characters." } }
    { { $snippet glyphPadding } { " the padding around each glyph." } }
    { { $snippet texture      } { " the texture atlas continaing the glyphs." } }
    { { $snippet recs         } { " an array of rectangles used to find each glyph in " { $snippet texture } "." } }
    { { $snippet glyphs       } { " metadata about each glyph." } }
} ;

HELP: Camera3D
{ $class-description
    Represents a camera in 3D space. The fields are defined as followed: }
{ $heading Fields }
{ $table
    { { $snippet position   } " is the camera position in 3D space." }
    { { $snippet target     } " is the target the camera is looking at." }
    { { $snippet up         } " is the direction that faces up relative to the camera." }
    { { $snippet fovy       } " is the camera's field of view aperature in degrees. Used as the near-plane for orthogrphic projections." }
    { { $snippet projection } " is the camera's projection:" { $link CAMERA_PERSPECTIVE } " or " { $link CAMERA_ORTHOGRAPHIC } }
} ;

HELP: Camera2D
{ $class-description
    Represents a camera in 2D space. The fields are defined
    as followed: }
{ $heading Fields }
{ $table
    { { $snippet offset   } " is the camera offset (dispacement from target)" }
    { { $snippet target   } " is the camera target (rotation and zoom origin)." }
    { { $snippet rotation } " is the camera rotation in degrees." }
    { { $snippet zoom     } " is the camera zoom/scalling, should be 1.0f by default." } } ;

HELP: Camera
{ $var-description
    A c-typedef alias for \ Camera3D .
} ;

HELP: Mesh 
{ $class-description
    Holds the vertex data and VAO/VBO for a 3D mesh. } 
 
{ $heading Fields }
{ $table
    { "vertexCount"   { $link int } "Number of vertices stored in arrays" }    
    { "triangleCount" { $link int } "Number of triangles stored (indexed or not)" }  
    { "_vertices"     { { $link float  } { $snippet "*" } } "Vertex position (XYZ - 3 components per vertex)"                                }   
    { "_texcoords"    { { $link float  } { $snippet "*" } } "Vertex texture coordinates (UV - 2 components per vertex)"                     }  
    { "_texcoords2"   { { $link float  } { $snippet "*" } } "Vertex second texture coordinates (useful for lightmaps)"                       } 
    { "_normals"      { { $link float  } { $snippet "*" } } "Vertex normals (XYZ - 3 components per vertex)"                                 }   
    { "tangents"      { { $link float  } { $snippet "*" } } "Vertex tangents (XYZW - 4 components per vertex)"                              }    
    { "colors"        { { $link uchar  } { $snippet "*" } } "Vertex colors (RGBA - 4 components per vertex)"                                 }      
    { "indices"       { { $link ushort } { $snippet "*" } } "Vertex indices (in case vertex data comes indexed)"                             }    
    
    { "animVertices"  { { $link float  } { $snippet "*" } } "Animated vertex positions (after bones transformations)"                        }
    { "animNormals"   { { $link float  } { $snippet "*" } } "Animated normals (after bones transformation)"                                  }
    { "boneIds"       { { $link uchar  } { $snippet "*" } } "Vertex bone ids, max 255 bone ids, up to 4 bones influence by vertex (skining)" }
    { "boneWeights"   { { $link float  } { $snippet "*" } } "Vertex bone weight, up to 4 bones influence by vertex (skinning)"               }
    
    { "vaoId"         { $link uint                      } "OpenGL Vertex Array Object id"                                                    } 
    { "vboId"         { { $link uint } { $snippet "*" } } "OpenGL Vertex Buffer Objects id (7 types of vertex data)"                         } } ;   


HELP: Shader
{ $class-description 
    Represents a graphics shader in Raylib. The size of 
    { $snippet locs } depends on { $snippet MAX_SHADER_LOCATIONS } . 
    
    { $warning 
        { $snippet MAX_SHADER_LOCATIONS } is set when raylib is compiled
        to a shared library. This cannot be changed from Factor. } }
{ $heading Fields }
{ $table
    { "id"   { $link uint                     } "Shader program id"      } 
    { "locs" { { $link int } { $snippet "*" } } "Shader locations array" } } ;


HELP: MaterialMap

{ $heading Fields }
{ $table 
    { "texture" { $link Texture2D } "Material map Texture" }     
    { "color"   { $link Color }     "Material map color"   }          
    { "value"   { $link float }     "Material map value"   } } ;        

HELP: Material

{ $heading Fields } 
{ $table 
    { "shader" { $link Shader                             }  "Material shader"                           }
    { "_maps"  { { $link MaterialMap } { $snippet "*"   } } "Material maps.  Uses MAX_MATERIAL_MAPS."    }   
    { "params" { { $link float       } { $snippet "[4]" } }  "Material generic parameters (if required)" } } ;    

HELP: Transform
{ $class-description 
    Represents a 3D vertex transformation. }
{ $heading Fields }
{ $table
    { "translation" { $link Vector3    } }
    { "rotation"    { $link Quaternion } }
    { "scale"       { $link Vector3    } } } ;


HELP: BoneInfo
{ $class-description
    A skeletal animation bone. }
{ $heading Fields }
{ $table
    { { $snippet name }     " is the name of the bone. Max 32 characters." }
    { { $snippet processor }  " the parent index." } } ;

HELP: Model
{ $class-description
    Meshes, materials and animation data }
{ $heading Fields }
{ $table
    { "transform"     { $link Matrix                     } "Local transform matrix."           }
    { "meshCount"     { $link int                        } "Number of meshes."                 }
    { "materialCount" { $link int                        } "Number of materials."              }
    { "_meshes"       { { $link void } { $snippet "*" }  } "Meshes array."                     }
    { "_materials"    { { $link void } { $snippet "*" }  } "Materials array."                  }
    { "meshMaterial"  { { $link int  } { $snippet "*" }  } "Mesh material number."             }
    { "boneCount"     { $link int                        } "Number of bones."                  }
    { "_bones"        { { $link void } { $snippet "*"  } } "Bones information (skeleton)."     }
    { "bindPose"      { { $link void } { $snippet "*"  } } "Bones base transformation (pose)." } } ;


HELP: ModelAnimation
{ $class-description 
    Represents information about a animation for a 3D model. }
{ $heading Fields }
{ $table
    { "boneCount"  { $link int                             }  "Number of bones."              }
    { "frameCount" { $link int                             }  "Number of animation frames."   }
    { "_bones"     { { $link BoneInfo  } { $snippet "**" } }  "Bones information (skeleton)." }
    { "framePoses" { { $link Transform } { $snippet "**" } }  "Poses array by frame"          }
    { "name"       { { $link char } { $snippet "[32]" }    }  "Animation name"                } } ;

HELP: AutomationEvent
{ $class-description 
    Represents information about an automation event. }
{ $heading Fields }
{ $table
    { "frame"  { $link uint                             }  "Event frame."                     }
    { "type"   { $link uint                             }  "Event type (AutomationEventType)" }
    { "params" { { $link int } { $snippet "[4]" }       }  "Event parameters (if required)"   } } ;

HELP: AutomationEventList
{ $class-description 
    Represents information about an automation event. }
{ $heading Fields }
{ $table
    { "capacity" { $link uint                                 }  "Events max entries (MAX_AUTOMATION_EVENTS)" }
    { "count"    { $link uint                                 }  "Events entries count"                       }
    { "events"   { { $link AutomationEvent } { $snippet "*" } }  "Pointer to events entries."                 } } ;

HELP: Ray
{ $class-description
    Represents a ray casted across 3D space. }
{ $heading Fields } 
{ $table 
    { "position"  { $link Vector3 } "Ray position (origin)" }   
    { "direction" { $link Vector3 } "Ray direction"         } } ;

HELP: RayCollision
{ $class-description
    Represents collision information from a Ray. }
{ $heading Fields } 
{ $table
    { "hit"      { $link bool    } "Did the ray hit something?" }  
    { "distance" { $link float   } "Distance to nearest hit"    }  
    { "point"    { $link Vector3 } "Point of nearest hit"       }  
    { "normal"   { $link Vector3 } "Surface normal of hit"      } } ;

HELP: BoundingBox
{ $class-description
    Represents a 3D bounding box defined by two points: }
{ $heading Fields }
{ $table
    { { $snippet min }  " The minimum vertex box-corner." }
    { { $snippet max }  " The maxium vertex box-corner." }
} ;

HELP: Wave
{ $class-description 
    Audio wave data }
{ $heading Fields } 
{ $table 
    { "frameCount" { $link uint  } "Total number of frames (considering channels)" }   
    { "sampleRate" { $link uint  } "Frequency (samples per second)"                }   
    { "sampleSize" { $link uint  } "Bit depth (bits per sample): 8,16,32"          }   
    { "channels"   { $link uint  } "Number of channels (1-mono, 2-stereo)"         }     
    { "data"       { $link void* } "Buffer data pointer"                           } } ;      

HELP: AudioStream
{ $class-description
    Represents a stream of audio data in Raylib. }
{ $heading Fields }
{ $table
    { { $snippet buffer }     " a pointer to the internal data used by the audio system."            }
    { { $snippet processor }  " a pointer to the interanl data processor, useful for audio effects." }
    { { $snippet sampleRate } " the frequence of the samples."                                       }
    { { $snippet sampleSize } " the bit depth of the samples: spport values are 8, 16, and 32."      }
    { { $snippet channels }   " the number of channels: 1 for mono, 2 for stereo."                   }
} ;

HELP: Sound

{ $heading Fields } 
{ $table 
    { "stream"     { $link AudioStream } "Audio stream"                                  }  
    { "frameCount" { $link uint        } "Total number of frames (considering channels)" } } ; 

HELP: Music
{ $class-description 
    Audio stream, anything longer than ~10 seconds should be streamed. }
{ $heading Fields } 
{ $table
    { "stream"     { $link AudioStream } "Audio stream"                                  }
    { "frameCount" { $link uint        } "Total number of frames (considering channels)" }
    { "looping"    { $link bool        } "Music looping enable"                          }
    { "ctxType"    { $link int         } "Type of music context (audio filetype)"        }
    { "ctxData"    { $link void*       } "Audio context data, depends on type"           } } ;

HELP: VrDeviceInfo
{ $class-description 
    Hold the configuation for a VR device. }
{ $heading Fields }
{ $table
    { "hResolution"            { $link int                          } "HMD horizontal resolution in pixels"            }               
    { "vResolution"            { $link int                          } "HMD verticle resolution in pixels"              }               
    { "hScreenSize"            { $link float                        } "HMD horizontal size in meters"                  }             
    { "vScreenSize"            { $link float                        } "HMD verticle size in meters"                    }             
    { "vScreenCenter"          { $link float                        } "HMD screen center in meters"                    }           
    { "eyeToScreenDistance"    { $link float                        } "HMD distance between eye and display in meters" }     
    { "lensSeparationDistance" { $link float                        } "HMD lens separation distance in meters"         }  
    { "interpupillaryDistance" { $link float                        } "HMD IPD in meters"                              }  
    { "lensDistortionValues"   { { $link float } { $snippet "[4]" } } "HMD lens distortion constant parameters"        } 
    { "chromaAbCorrection"     { { $link float } { $snippet "[4]" } } "HMD chromatic abberation correction parameters" } } ; 

HELP: VrStereoConfig
{ $class-description 
    VR stereo rendering configuration for simulator. }
{ $heading Fields }
{ $table 
    { "projection"        { { $link Matrix } { $snippet [2] } "VR projection matrices (per eye)"  } }
    { "viewOffset"        { { $link Matrix } { $snippet [2] } "VR view offset matrices (per eye)" } }  
    { "leftLensCenter"    { { $link float }  { $snippet [2] } "VR left lens center"               } }     
    { "rightLensCenter"   { { $link float }  { $snippet [2] } "VR right lens center"              } }    
    { "leftScreenCenter"  { { $link float }  { $snippet [2] } "VR left screen center"             } }   
    { "rightScreenCenter" { { $link float }  { $snippet [2] } "VR right screen center"            } }  
    { "scale"             { { $link float }  { $snippet [2] } "VR distortion scale"               } }              
    { "scaleIn"           { { $link float }  { $snippet [2] } "VR distortion scale in"            } }
} ;

HELP: FilePathList
{ $class-description
    A list of file paths returned from \ load-directory-files ,
    \ load-directory-files-ex . Must be freed with
    \ unload-directory-files . }

{ $heading Fields }
{ $table
    { { $snippet capacity } " the max number of entries." }
    { { $snippet count } " the number of entries found." }
    { { $snippet paths } " array of string where each member is a file path." }
}

{ $see-also
    load-directory-files
    load-directory-files-ex
    unload-directory-files
} ;


HELP: LIGHTGRAY  { $raylib-color "200, 200, 200, 255" } ;
HELP: GRAY       { $raylib-color "130, 130, 130, 255" } ;
HELP: DARKGRAY   { $raylib-color "80, 80, 80, 255" } ;
HELP: YELLOW     { $raylib-color "253, 249, 0, 255" } ;
HELP: GOLD       { $raylib-color "255, 203, 0, 255" } ;
HELP: ORANGE     { $raylib-color "255, 161, 0, 255" } ;
HELP: PINK       { $raylib-color "255, 109, 194, 255" } ;
HELP: RED        { $raylib-color "230, 41, 55, 255" } ;
HELP: MAROON     { $raylib-color "190, 33, 55, 255" } ;
HELP: GREEN      { $raylib-color "0, 228, 48, 255" } ;
HELP: LIME       { $raylib-color "0, 158, 47, 255" } ;
HELP: DARKGREEN  { $raylib-color "0, 117, 44, 255" } ;
HELP: SKYBLUE    { $raylib-color "102,  191, 255, 255" } ;
HELP: BLUE       { $raylib-color "0, 121, 241, 255" } ;
HELP: DARKBLUE   { $raylib-color "0, 82, 172, 255" } ;
HELP: PURPLE     { $raylib-color "200, 122, 255, 255" } ;
HELP: VIOLET     { $raylib-color "135, 60, 190, 255 " } ;
HELP: DARKPURPLE { $raylib-color "112, 31, 126, 255 " } ;
HELP: BEIGE      { $raylib-color "211, 176, 131, 255" } ;
HELP: BROWN      { $raylib-color "127, 106, 79, 255 " } ;
HELP: DARKBROWN  { $raylib-color "76, 63, 47, 255" } ;

HELP: WHITE      { $raylib-color "255, 255, 255, 255" } ;
HELP: BLACK      { $raylib-color "0, 0, 0, 255" } ;
HELP: BLANK      { $raylib-color "0, 0, 0, 0" } ;
HELP: MAGENTA    { $raylib-color "255, 0, 255, 255" } ;
HELP: RAYWHITE   { $raylib-color "245, 245, 245, 255" } ;

! Window-related functions
HELP: init-window
{ $values
    width: int
    height: int
    title: c-string }
{ $description
    "Initialize window and OpenGL context" } ;

HELP: window-should-close
{ $values
    bool: bool }
{ $description
    "Check if application should close (KEY_ESCAPE pressed or windows close icon clicked)" } ;

HELP: close-window
{ $description
    "Close window and unload OpenGL context" } ;

HELP: is-window-ready
{ $values
    bool: boolean }
{ $description
    "Check if window has been initialized successfully" } ;

HELP: is-window-fullscreen
{ $values
    bool: boolean }
{ $description
    "Check if window is currently fullscreen" } ;

HELP: is-window-hidden
{ $values
    bool: boolean }
{ $description
    "Check if window is currently hidden (only PLATFORM_DESKTOP)" } ;

HELP: is-window-minimized
{ $values
    bool: boolean }
{ $description
    "Check if window is currently minimized (only PLATFORM_DESKTOP)" } ;

HELP: is-window-maximized
{ $values
    bool: boolean }
{ $description
    "Check if window is currently maximized (only PLATFORM_DESKTOP)" } ;

HELP: is-window-focused
{ $values
    bool: boolean }
{ $description
    "Check if window is currently focused (only PLATFORM_DESKTOP)" } ;

HELP: is-window-resized
{ $values
    bool: boolean }
{ $description
    "Check if window has been resized last frame" } ;

HELP: is-window-state

{ $values
    flag: uint
    bool: boolean }
{ $description
    "Check if one specific window flag is enabled" } ;

HELP: set-window-state
{ $values
    flags: uint }
{ $description
    "Set window configuration state using flags" } ;

HELP: clear-window-state
{ $values
    flags: uint }
{ $description
    "Clear window configuration state flags" } ;

HELP: toggle-fullscreen
{ $description
    "Toggle window state: fullscreen/windowed (only PLATFORM_DESKTOP)" } ;

HELP: toggle-borderless-windowed
{ $description
    "Toggle window state: fullscreen/windowed (only PLATFORM_DESKTOP)" } ;

HELP: maximize-window
{ $description
    "Set window state: maximized, if resizable (only PLATFORM_DESKTOP)" } ;

HELP: minimize-window
{ $description
    "Set window state: minimized, if resizable (only PLATFORM_DESKTOP)" } ;

HELP: restore-window
{ $description
    "Set window state: not minimized/maximized (only PLATFORM_DESKTOP)" } ;

HELP: set-window-icon
{ $values
    image: Image }
{ $description
    "Set icon for window (only PLATFORM_DESKTOP)" } ;

HELP: set-window-icons
{ $values
    images: { "a " { $link pointer } " to an array of " { $link Image } }
    count: int } ;

HELP: set-window-title
{ $values
    title: c-string }
{ $description
    "Set title for window (only PLATFORM_DESKTOP and PLATFORM_WEB)" } ;

HELP: set-window-position
{ $values
    x: int
    y: int }
{ $description
    "Set window position on screen (only PLATFORM_DESKTOP)" } ;

HELP: set-window-monitor
{ $values
    monitor: int }
{ $description
    "Set monitor for the current window" } ;

HELP: set-window-min-size
{ $values
    width: int
    height: int }
{ $description
    "Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE)" } ;

HELP: set-window-max-size
{ $values
    width: int
    height: int }
{ $description
    "Set window maximum dimensions (for FLAG_WINDOW_RESIZABLE)" } ;

HELP: set-window-size
{ $values
    width: int
    height: int }
{ $description
    "Set window dimensions" } ;

HELP: set-window-opacity
{ $values
    opacity: float }
{ $description
    "Set window opacity [0.0f..1.0f] (only PLATFORM_DESKTOP)" } ;

HELP: set-window-focused
{ $description
    "Set window focused (only PLATFORM_DESKTOP)" } ;

HELP: get-window-handle
{ $values
    void*: void* }
{ $description
    "Get native window handle" } ;

HELP: get-screen-width
{ $values
    int: int }
{ $description
    "Get current screen width" } ;

HELP: get-screen-height
{ $values
    int: int }
{ $description
    "Get current screen height" } ;

HELP: get-render-width
{ $values
    int: int }
{ $description
    "Get current render width (it considers HiDPI)" } ;

HELP: get-render-height
{ $values
    int: int }
{ $description
    "Get current render height (it considers HiDPI)" } ;

HELP: get-monitor-count
{ $values
    int: int }
{ $description
    "Get number of connected monitors" } ;

HELP: get-current-monitor
{ $values
    int: int }
{ $description
    "Get current connected monitor" } ;

HELP: get-monitor-position
{ $values
    monitor: int
    Vector2: Vector2 }
{ $description
    "Get specified monitor position" } ;

HELP: get-monitor-width
{ $values
    monitor: int
    int: int }
{ $description
    "Get specified monitor width (max available by monitor)" } ;

HELP: get-monitor-height
{ $values
    monitor: int
    int: int }
{ $description
    "Get specified monitor height (max available by monitor)" } ;

HELP: get-monitor-physical-width
{ $values
    monitor: int
    int: int }
{ $description
    "Get specified monitor physical width in millimetres" } ;

HELP: get-monitor-physical-height
{ $values
    monitor: int
    int: int }
{ $description
    "Get specified monitor physical height in millimetres" } ;

HELP: get-monitor-refresh-rate
{ $values
    monitor: int
    int: int }
{ $description
    "Get specified monitor refresh rate" } ;

HELP: get-window-position
{ $values
    Vector2: Vector2 }
{ $description
    "Get window position XY on monitor" } ;

HELP: get-window-scale-dpi
{ $values
    Vector2: Vector2 }
{ $description
    "Get window scale DPI factor" } ;

HELP: get-monitor-name
{ $values
    monitor: int
    c-string: c-string }
{ $description
    "Get the human-readable, UTF-8 encoded name of the specified monitor" } ;

HELP: set-clipboard-text
{ $values
    text: c-string }
{ $description
    "Set clipboard text content" } ;

HELP: get-clipboard-text
{ $values
    c-string: c-string }
{ $description
    "Get clipboard text content" } ;

HELP: enable-event-waiting
{ $description
    "Enable waiting for events on EndDrawing(), no automatic event polling" } ;

HELP: disable-event-waiting
{ $description
    "Disable waiting for events on EndDrawing(), automatic events polling" } ;


! Custom frame control functions
HELP: swap-screen-buffer
{ $description
    "Swap back buffer with front buffer (screen drawing)"

    { $warning
        "Those functions are intended for advance users that want"
        " full control over the frame processing. By default"
        " EndDrawing() does this job: \n\t- draws everything"
        "\n\t- " { $link swap-screen-buffer }
        "\n\t- manage frame timming"
        "\n\t- " { $link poll-input-events } ".\n"
        "To avoid that behavior and control frame processes manually,"
        " enable in config.h: SUPPORT_CUSTOM_FRAME_CONTROL" } } ;

HELP: poll-input-events
{ $description
    "Register all input events"

    { $warning
        "Those functions are intended for advance users that want"
        " full control over the frame processing. By default"
        " EndDrawing() does this job: \n\t- draws everything"
        "\n\t- " { $link swap-screen-buffer }
        "\n\t- manage frame timming"
        "\n\t- " { $link poll-input-events } ".\n"
        "To avoid that behavior and control frame processes manually,"
        " enable in config.h: SUPPORT_CUSTOM_FRAME_CONTROL" } } ;

HELP: wait-time
{ $values
    seconds: double }
{ $description
    "Wait for some milliseconds (halt program execution)"

    { $warning
        "Those functions are intended for advance users that want"
        " full control over the frame processing. By default"
        " EndDrawing() does this job: \n\t- draws everything"
        "\n\t- " { $link swap-screen-buffer }
        "\n\t- manage frame timming"
        "\n\t- " { $link poll-input-events } ".\n"
        "To avoid that behavior and control frame processes manually,"
        " enable in config.h: SUPPORT_CUSTOM_FRAME_CONTROL" } } ;


! Cursor-related functions
HELP: show-cursor
{ $description
    "Shows cursor" } ;

HELP: hide-cursor
{ $description
    "Hides cursor" } ;

HELP: is-cursor-hidden
{ $values
    bool: boolean }
{ $description
    "Check if cursor is not visible" } ;

HELP: enable-cursor
{ $description
    "Enables cursor (unlock cursor)" } ;

HELP: disable-cursor
{ $description
    "Disables cursor (lock cursor)" } ;

HELP: is-cursor-on-screen
{ $values 
    bool: bool }
{ $description
    "Check if cursor is on the screen" } ;


! Drawing-related functions
HELP: clear-background
{ $values
    color: Color }
{ $description
    "Set background color (framebuffer clear color)" } ;

HELP: begin-drawing
{ $description
    "Setup canvas (framebuffer) to start drawing" } ;

HELP: end-drawing
{ $description
    "End canvas drawing and swap buffers (double buffering)" } ;

HELP: begin-mode-2d
{ $values
    camera: Camera2D }
{ $description
    "Begin 2D mode with custom camera (2D)" } ;

HELP: end-mode-2d
{ $description
    "Ends 2D mode with custom camera" } ;

HELP: begin-mode-3d
{ $values
    camera: Camera3D }
{ $description
    "Begin 3D mode with custom camera (3D)" } ;

HELP: end-mode-3d
{ $description
    "Ends 3D mode and returns to default 2D orthographic mode" } ;

HELP: begin-texture-mode
{ $values
    target: RenderTexture2D }
{ $description
    "Begin drawing to render texture" } ;

HELP: end-texture-mode
{ $description
    "Ends drawing to render texture" } ;

HELP: begin-shader-mode
{ $values
    shader: Shader }
{ $description
    "Begin custom shader drawing" } ;

HELP: end-shader-mode
{ $description
    "End custom shader drawing (use default shader)" } ;

HELP: begin-blend-mode
{ $values
    mode: BlendMode }
{ $description
    "Begin blending mode (alpha, additive, multiplied, subtract, custom)" } ;

HELP: end-blend-mode
{ $description
    "End blending mode (reset to default: alpha blending)" } ;

HELP: begin-scissor-mode
{ $values
    x: int
    y: int
    width: int
    height: int }
{ $description
    "Begin scissor mode (define screen area for following drawing)" } ;

HELP: end-scissor-mode
{ $description
    "End scissor mode" } ;

HELP: begin-vr-stereo-mode
{ $values
    config: VrStereoConfig }
{ $description
    "Begin stereo rendering (requires VR simulator)" } ;

HELP: end-vr-stereo-mode
{ $description
    "End stereo rendering (requires VR simulator)" } ;


! VR stereo config functions for VR simulator
HELP: load-vr-stereo-config
{ $values
    device: VrDeviceInfo
    VrStereoConfig: VrStereoConfig }
{ $description
    "Load VR stereo config for VR simulator device parameters" } ;

HELP: unload-vr-stereo-config
{ $values
    config: VrStereoConfig }
{ $description
    "Unload VR stereo config" } ;


! Shader management functions
HELP: load-shader
{ $values
    vsFileName: c-string
    fsFileName: c-string
    Shader: Shader }
{ $description
    "Load shader from files and bind default locations"

    { $warning
        "Shader functionality is not available on OpenGL 1.1" } } ;

HELP: load-shader-from-memory
{ $values
    vsCode: c-string
    fsCode: c-string
    Shader: Shader }
{ $description
    "Load shader from code strings and bind default locations"
    { $warning
        "Shader functionality is not available on OpenGL 1.1" } } ;

HELP: is-shader-valid
{ $values
    shader: Shader
    bool: boolean }
{ $description
    "Check if a shader is ready"
    { $warning
        "Shader functionality is not available on OpenGL 1.1" } } ;

HELP: get-shader-location
{ $values
    shader: Shader
    uniformName: c-string
    int: int }
{ $description
    "Get shader uniform location"
    { $warning
        "Shader functionality is not available on OpenGL 1.1" } } ;

HELP: get-shader-location-attrib
{ $values
    shader: Shader
    attribName: c-string
    int: int }
{ $description
    "Get shader attribute location"
    { $warning
        "Shader functionality is not available on OpenGL 1.1" } } ;

HELP: set-shader-value
{ $values
    shader: Shader
    locIndex: int
    value: void*
    uniformType: ShaderUniformDataType }
{ $description
    "Set shader uniform value"
    { $warning
        "Shader functionality is not available on OpenGL 1.1" } } ;

HELP: set-shader-value-v
{ $values
    shader: Shader
    locIndex: int
    value: void*
    uniformType: ShaderUniformDataType
    count: int }
{ $description
    "Set shader uniform value vector"
    { $warning
        "Shader functionality is not available on OpenGL 1.1" } } ;

HELP: set-shader-value-matrix
{ $values
    shader: Shader
    locIndex: int
    mat: Matrix }
{ $description
    "Set shader uniform value (matrix 4x4)"
    { $warning
        "Shader functionality is not available on OpenGL 1.1" } } ;

HELP: set-shader-value-texture
{ $values
    shader: Shader
    locIndex: int
    texture: Texture2D }
{ $description
    "Set shader uniform value for texture (sampler2d)"
    { $warning
        "Shader functionality is not available on OpenGL 1.1" } } ;

HELP: unload-shader
{ $values
    shader: Shader }
{ $description
    "Unload shader from GPU memory (VRAM)"
    { $warning
        "Shader functionality is not available on OpenGL 1.1" } } ;


! Screen-space-related functions
HELP: get-screen-to-world-ray
{ $values
    position: Vector2
    camera: Camera
    Ray: Ray }
{ $description
    "Get a ray trace from screen position" } ;

HELP: get-camera-matrix
{ $values
    camera: Camera
    Matrix: Matrix }
{ $description
    "Get camera transform matrix (view matrix)" } ;

HELP: get-camera-matrix-2d
{ $values
    camera: Camera2D
    Matrix: Matrix }
{ $description
    "Get camera 2d transform matrix" } ;

HELP: get-world-to-screen
{ $values
    position: Vector3
    camera: Camera
    Vector2: Vector2 }
{ $description
    "Get the screen space position for a 3d world space position" } ;

HELP: get-world-to-screen-2d
{ $values
    position: Vector2
    camera: Camera2D
    Vector2: Vector2 }
{ $description
    "Get the screen space position for a 2d camera world space position" } ;

HELP: get-world-to-screen-ex
{ $values
    position: Vector3
    camera: Camera
    width: int
    height: int
    Vector2: Vector2 }
{ $description
    "Get size position for a 3d world space position" } ;

HELP: get-screen-to-world-2d
{ $values
    position: Vector2
    camera: Camera2D
    Vector2: Vector2 }
{ $description
    "Get the world space position for a 2d camera screen space position" } ;


! Timing-related functions
HELP: set-target-fps
{ $values
    fps: int }
{ $description
    "Set target FPS (maximum)" } ;

HELP: get-fps
{ $values
    int: int }
{ $description
    "Get current FPS" } ;

HELP: get-frame-time
{ $values
    float: float }
{ $description
    "Get time in seconds for last frame drawn (delta time)" } ;

HELP: get-time
{ $values
    double: double }
{ $description
    "Get elapsed time in seconds since InitWindow()" } ;


! Misc. functions
HELP: get-random-value
{ $values
    min: int
    max: int
    int: int }
{ $description
    "Get a random value between min and max (both included)" } ;

HELP: set-random-seed
{ $values
    seed: uint }
{ $description
    "Set the seed for the random number generator" } ;

HELP: load-random-sequence
{ $values
    count: uint
    min: int
    max: int
    int*: { "a " { $link pointer } " to a " { $link int } } }
{ $description
    "Load random values sequence, no values repeated" } ;

HELP: unload-random-sequence
{ $values
    sequence: { "a " { $link pointer } " to a " { $link int } } }
{ $description
    "Unload random values sequence" } ;

HELP: take-screenshot
{ $values
    fileName: c-string }
{ $description
    "Takes a screenshot of current screen (filename extension defines format)" } ;

HELP: set-config-flags
{ $values
    flags: uint }
{ $description
    "Setup init configuration flags (view FLAGS)" } ;



HELP: set-trace-log-level
{ $values
    logLevel: int }
{ $description
    "Set the current threshold (minimum) log level" } ;

HELP: mem-alloc
{ $values
    size: uint
    void*: void* }
{ $description
    "Internal memory allocator" } ;

HELP: mem-realloc
{ $values
    ptr: void*
    size: uint
    void*: void* }
{ $description
    "Internal memory reallocator" } ;

HELP: mem-free
{ $values
    ptr: void* }
{ $description
    "Internal memory free" } ;


HELP: open-url
{ $values
    url: c-string }
{ $description
    "Open URL with default system browser (if available)" } ;


! Files management functions
HELP: load-file-data
{ $values
    fileName: c-string
    bytesRead: { "a " { $link pointer } " to a " { $link int } }
    c-string: c-string }
{ $description
    "Load file data as byte array (read)" } ;

HELP: unload-file-data
{ $values
    data: c-string }
{ $description
    "Unload file data allocated by LoadFileData()" } ;

HELP: save-file-data
{ $values
    fileName: c-string
    data: void*
    bytesToWrite: int
    bool: bool }
{ $description
    "Save data to file from byte array (write), returns true on success" } ;

HELP: export-data-as-code
{ $values
    data: { "a " { $link pointer } " to a " { $link uchar } }
    size: int
    fileName: c-string
    bool: bool }
{ $description
    "Export data to code (.h), returns true on success" } ;

HELP: load-file-text
{ $values
    fileName: c-string
    c-string: c-string }
{ $description
    "Load text data from file (read), returns a '\0' terminated string" } ;

HELP: unload-file-text
{ $values
    text: c-string }
{ $description
    "Unload file text data allocated by LoadFileText()" } ;

HELP: save-file-text
{ $values
    fileName: c-string
    text: c-string
    bool: bool }
{ $description
    "Save text data to file (write), string must be '\0' terminated, returns true on success" } ;

HELP: file-exists
{ $values
    fileName: c-string
    bool: bool }
{ $description
    "Check if file exists" } ;

HELP: directory-exists
{ $values
    dirPath: c-string
    bool: bool }
{ $description
    "Check if a directory path exists" } ;

HELP: is-file-extension
{ $values
    fileName: c-string
    ext: c-string
    bool: bool }
{ $description
    "Check file extension (including point: .png, .wav)" } ;

HELP: get-file-length
{ $values
    fileName: c-string
    int: int }
{ $description
    "Get file length in bytes (NOTE: GetFileSize() conflicts with windows.h)" } ;

HELP: get-file-extension
{ $values
    fileName: c-string
    c-string: c-string }
{ $description
    "Get pointer to extension for a filename string (includes dot: '.png')" } ;

HELP: get-file-name
{ $values
    filePath: c-string
    c-string: c-string }
{ $description
    "Get pointer to filename for a path string" } ;

HELP: get-file-name-without-ext
{ $values
    filePath: c-string
    c-string: c-string }
{ $description
    "Get filename string without extension (uses static string)" } ;

HELP: get-directory-path
{ $values
    filePath: c-string
    c-string: c-string }
{ $description
    "Get full path for a given fileName with path (uses static string)" } ;

HELP: get-prev-directory-path
{ $values
    dirPath: c-string
    c-string: c-string }
{ $description
    "Get previous directory path for a given path (uses static string)" } ;

HELP: get-working-directory
{ $values
    c-string: c-string }
{ $description
    "Get current working directory (uses static string)" } ;

HELP: get-application-directory
{ $values
    c-string: c-string }
{ $description
    "Get the directory if the running application (uses static string)" } ;

HELP: change-directory
{ $values
    dir: c-string
    bool: bool }
{ $description
    "Change working directory, return true on success" } ;

HELP: is-path-file
{ $values
    path: c-string
    bool: bool }
{ $description
    "Check if a given path is a file or a directory" } ;

HELP: load-directory-files
{ $values
    dirPath: c-string
    FilePathList: FilePathList }
{ $description
    "Get filenames in a directory path (memory should be freed)" } ;

HELP: load-directory-files-ex
{ $values
    dirPath: c-string
    filter: c-string
    scanSubDirs: bool
    FilePathList: FilePathList }
{ $description
    "Get filenames in a directory path (memory should be freed)" } ;

HELP: unload-directory-files
{ $values
    files: FilePathList }
{ $description
    "Clear directory files paths buffers (free memory)" } ;

HELP: is-file-dropped
{ $values
    bool: bool }
{ $description
    "Check if a file has been dropped into window" } ;

HELP: load-dropped-files
{ $values
    FilePathList: FilePathList }
{ $description
    "Get dropped files names (memory should be freed)" } ;

HELP: unload-dropped-files
{ $values
    files: FilePathList }
{ $description
    "Clear dropped files paths buffer (free memory)" } ;

HELP: get-file-mod-time
{ $values
    fileName: c-string
    long: long }
{ $description
    "Get file modification time (last write time)" } ;


! Compression/Encoding functionality
HELP: compress-data
{ $values
    data: { "a " { $link pointer } " to a " { $link uchar } }
    dataLength: int
    compDataLength: { "a " { $link pointer } " to a " { $link int } }
    uchar*: { "a" { $link pointer } " to a " { $link uchar } } }
{ $description
    "Compress data (DEFLATE algorithm)" } ;

HELP: decompress-data
{ $values
    compData: { "a " { $link pointer } " to a " { $link uchar } }
    compDataLength: int
    dataLength: { "a " { $link pointer } " to a " { $link int } }
    uchar*: { "a" { $link pointer } " to a " { $link uchar } } }
{ $description
    "Decompress data (DEFLATE algorithm)" } ;

HELP: encode-data-base64
{ $values
    data: { "a " { $link pointer } " to a " { $link uchar } }
    dataLength: int
    outputLength: { "a " { $link pointer } " to a " { $link int } }
    c-string: c-string }
{ $description
    "Encode data to Base64 string" } ;

HELP: decode-data-base64
{ $values
    data: { "a " { $link pointer } " to a " { $link uchar } }
    outputLength: { "a " { $link pointer } " to a " { $link int } }
    uchar*: { "a" { $link pointer } " to a " { $link uchar } } }
{ $description
    "Decode Base64 string data" } ;

! Automation events functionality
HELP: load-automation-event-list
{ $values
    fileName: c-string
    AutomationEventList: AutomationEventList
}
{ $description
    "Load automation events list from file" } ;

HELP: unload-automation-event-list
{ $values
    list: { "a " { $link pointer } " to a " { $link AutomationEventList } }
}
{ $description
    "Unload automation events list" } ;

HELP: export-automation-event-list
{ $values
    list: { "a " { $link pointer } " to a " { $link AutomationEventList } }
    fileName: c-string
    bool: bool
}
{ $description
    "Export automation events list as text file" } ;

HELP: set-automation-event-list
{ $values
    list: { "a " { $link pointer } " to a " { $link AutomationEventList } }
}
{ $description
    "Set automation event list to record to" } ;

HELP: set-automation-event-base-frame
{ $values
    frame: int
}
{ $description
    "Set automation event internal base frame to start recording" } ;

HELP: start-automation-event-recording
{ $description
    "Start recording automation events" } ;

HELP: stop-automation-event-recording
{ $description
    "Stop recording automation events" } ;

HELP: play-automation-event
{ $values
    event: AutomationEvent
}
{ $description
    "Play a recorded automation event" } ;

! Input-related functions: keyboard
HELP: is-key-pressed
{ $values
    key: KeyboardKey
    bool: bool }
{ $description
    "Check if a key has been pressed once" } ;

HELP: is-key-pressed-repeat
{ $values
    key: KeyboardKey
    bool: bool }
{ $description
    "Check if a key has been pressed again (Only PLATFORM_DESKTOP)" } ;

HELP: is-key-down
{ $values
    key: KeyboardKey
    bool: bool }
{ $description
    "Check if a key is being pressed" } ;

HELP: is-key-released
{ $values
    key: KeyboardKey
    bool: bool }
{ $description
    "Check if a key has been released once" } ;

HELP: is-key-up
{ $values
    key: KeyboardKey
    bool: bool }
{ $description
    "Check if a key is NOT being pressed" } ;

HELP: set-exit-key
{ $values
    key: KeyboardKey }
{ $description
    "Set a custom key to exit program (default is ESC)" } ;

HELP: get-key-pressed
{ $values
    KeyboardKey: KeyboardKey }
{ $description
    "Get key pressed (keycode), call it multiple times for keys queued, returns 0 when the queue is empty" } ;

HELP: get-char-pressed
{ $values
    int: int }
{ $description
    "Get char pressed (unicode), call it multiple times for chars queued, returns 0 when the queue is empty" } ;


! Input-related functions: gamepads
HELP: is-gamepad-available
{ $values
    gamepad: int
    bool: bool }
{ $description
    "Check if a gamepad is available" } ;

HELP: get-gamepad-name
{ $values
    gamepad: int
    c-string: c-string }
{ $description
    "Get gamepad internal name id" } ;

HELP: is-gamepad-button-pressed
{ $values
    gamepad: int
    button: GamepadButton
    bool: bool }
{ $description
    "Check if a gamepad button has been pressed once" } ;

HELP: is-gamepad-button-down
{ $values
    gamepad: int
    button: GamepadButton
    bool: bool }
{ $description
    "Check if a gamepad button is being pressed" } ;

HELP: is-gamepad-button-released
{ $values
    gamepad: int
    button: GamepadButton
    bool: bool }
{ $description
    "Check if a gamepad button has been released once" } ;

HELP: is-gamepad-button-up
{ $values
    gamepad: int
    button: GamepadButton
    bool: bool }
{ $description
    "Check if a gamepad button is NOT being pressed" } ;

HELP: get-gamepad-button-pressed
{ $values
    int: int }
{ $description
    "Get the last gamepad button pressed" } ;

HELP: get-gamepad-axis-count
{ $values
    gamepad: int
    int: int }
{ $description
    "Get gamepad axis count for a gamepad" } ;

HELP: get-gamepad-axis-movement
{ $values
    gamepad: int
    axis: GamepadAxis
    float: float }
{ $description
    "Get axis movement value for a gamepad axis" } ;

HELP: set-gamepad-mappings
{ $values
    mappings: c-string
    int: int }
{ $description
    "Set internal gamepad mappings (SDL_GameControllerDB)" } ;


! Input-related functions: mouse
HELP: is-mouse-button-pressed
{ $values
    button: MouseButton
    bool: bool }
{ $description
    "Check if a mouse button has been pressed once" } ;

HELP: is-mouse-button-down
{ $values
    button: MouseButton
    bool: bool }
{ $description
    "Check if a mouse button is being pressed" } ;

HELP: is-mouse-button-released
{ $values
    button: MouseButton
    bool: bool }
{ $description
    "Check if a mouse button has been released once" } ;

HELP: is-mouse-button-up
{ $values
    button: MouseButton
    bool: bool }
{ $description
    "Check if a mouse button is NOT being pressed" } ;

HELP: get-mouse-x
{ $values
    int: int }
{ $description
    "Get mouse position X" } ;

HELP: get-mouse-y
{ $values
    int: int }
{ $description
    "Get mouse position Y" } ;

HELP: get-mouse-position
{ $values
    Vector2: Vector2 }
{ $description
    "Get mouse position XY" } ;

HELP: get-mouse-delta
{ $values
    Vector2: Vector2 }
{ $description
    "Get mouse delta between frames" } ;

HELP: set-mouse-position
{ $values
    x: int
    y: int }
{ $description
    "Set mouse position XY" } ;

HELP: set-mouse-offset
{ $values
    offsetX: int
    offsetY: int }
{ $description
    "Set mouse offset" } ;

HELP: set-mouse-scale
{ $values
    scaleX: float
    scaleY: float }
{ $description
    "Set mouse scaling" } ;

HELP: get-mouse-wheel-move
{ $values
    float: float }
{ $description
    "Get mouse wheel movement Y" } ;

HELP: get-mouse-wheel-move-v
{ $values
    Vector2: Vector2 }
{ $description
    "Get mouse wheel movement for both X and Y" } ;

HELP: set-mouse-cursor
{ $values
    cursor: MouseCursor }
{ $description
    "Set mouse cursor" } ;


! Input-related functions: touch
HELP: get-touch-x
{ $values
    int: int }
{ $description
    "Get touch position X for touch point 0 (relative to screen size)" } ;

HELP: get-touch-y
{ $values
    int: int }
{ $description
    "Get touch position Y for touch point 0 (relative to screen size)" } ;

HELP: get-touch-position
{ $values
    index: int
    Vector2: Vector2 }
{ $description
    "Get touch position XY for a touch point index (relative to screen size)" } ;

HELP: get-touch-point-id
{ $values
    index: int
    int: int }
{ $description
    "Get touch point identifier for given index" } ;

HELP: get-touch-point-count
{ $values
    int: int }
{ $description
    "Get number of touch points" } ;


! ------------------------------------------------------------------------------------
! Gestures and Touch Handling Functions (Module: rgestures)
! ------------------------------------------------------------------------------------
HELP: set-gestures-enabled
{ $values
    flags: uint }
{ $description
    "Enable a set of gestures using flags" } ;

HELP: is-gesture-detected
{ $values
    gesture: uint
    bool: bool }
{ $description
    "Check if a gesture have been detected" } ;

HELP: get-gesture-detected
{ $values
    int: int }
{ $description
    "Get latest detected gesture" } ;

HELP: get-gesture-hold-duration
{ $values
    float: float }
{ $description
    "Get gesture hold time in milliseconds" } ;

HELP: get-gesture-drag-vector
{ $values
    Vector2: Vector2 }
{ $description
    "Get gesture drag vector" } ;

HELP: get-gesture-drag-angle
{ $values
    float: float }
{ $description
    "Get gesture drag angle" } ;

HELP: get-gesture-pinch-vector
{ $values
    Vector2: Vector2 }
{ $description
    "Get gesture pinch delta" } ;

HELP: get-gesture-pinch-angle
{ $values
    float: float }
{ $description
    "Get gesture pinch angle" } ;


! ------------------------------------------------------------------------------------
! Camera System Functions (Module: rcamera)
! ------------------------------------------------------------------------------------

HELP: update-camera
{ $values
    camera: { "a " { $link pointer } " to a " { $link Camera } }
    mode: CameraMode }
{ $description
    "Update camera position for selected mode" } ;

HELP: update-camera-pro
{ $values
    camera: { "a " { $link pointer } " to a " { $link Camera } }
    movement: Vector3
    rotation: Vector3
    zoom: float }
{ $description
    "Update camera movement/rotation" } ;

HELP: set-shapes-texture
{ $values
    texture: Texture2D
    source: Rectangle
}
{ $description
    "Set texture and rectangle to be used on shapes drawing" } ;


! Basic shapes drawing functions
HELP: draw-pixel
{ $values
    posX: int
    posY: int
    color: Color }
{ $description
    "Draw a pixel" } ;

HELP: draw-pixel-v
{ $values
    position: Vector2
    color: Color }
{ $description
    "Draw a pixel (Vector version)" } ;

HELP: draw-line
{ $values
    startPosX: int
    startPosY: int
    endPosX: int
    endPosY: int
    color: Color }
{ $description
    "Draw a line" } ;

HELP: draw-line-v
{ $values
    startPos: Vector2
    endPos: Vector2
    color: Color }
{ $description
    "Draw a line (Vector version)" } ;

HELP: draw-line-ex
{ $values
    startPos: Vector2
    endPos: Vector2
    thick: float
    color: Color }
{ $description
    "Draw a line defining thickness" } ;

HELP: draw-line-bezier
{ $values
    startPos: Vector2
    endPos: Vector2
    thick: float
    color: Color }
{ $description
    "Draw a line using cubic-bezier curves in-out" } ;

HELP: draw-line-strip
{ $values
    points: { "a " { $link pointer } " to a " { $link Vector2 } }
    pointCount: int
    color: Color }
{ $description
    "Draw lines sequence" } ;

HELP: draw-circle
{ $values
    centerX: int
    centerY: int
    radius: float
    color: Color }
{ $description
    "Draw a color-filled circle" } ;

HELP: draw-circle-sector
{ $values
    center: Vector2
    radius: float
    startAngle: float
    endAngle: float
    segments: int
    color: Color }
{ $description
    "Draw a piece of a circle" } ;

HELP: draw-circle-sector-lines
{ $values
    center: Vector2
    radius: float
    startAngle: float
    endAngle: float
    segments: int
    color: Color }
{ $description
    "Draw circle sector outline" } ;

HELP: draw-circle-gradient
{ $values
    centerX: int
    centerY: int
    radius: float
    inner: Color
    outer: Color }
{ $description
    "Draw a gradient-filled circle" } ;

HELP: draw-circle-v
{ $values
    center: Vector2
    radius: float
    color: Color }
{ $description
    "Draw a color-filled circle (Vector version)" } ;

HELP: draw-circle-lines
{ $values
    centerX: int
    centerY: int
    radius: float
    color: Color }
{ $description
    "Draw circle outline" } ;

HELP: draw-circle-lines-v
{ $values
    center: Vector2
    radius: float
    color: Color }
{ $description
    "Draw circle outline (Vector version)" } ;

HELP: draw-ellipse
{ $values
    centerX: int
    centerY: int
    radiusH: float
    radiusV: float
    color: Color }
{ $description
    "Draw ellipse" } ;

HELP: draw-ellipse-lines
{ $values
    centerX: int
    centerY: int
    radiusH: float
    radiusV: float
    color: Color }
{ $description
    "Draw ellipse outline" } ;

HELP: draw-ring
{ $values
    center: Vector2
    innerRadius: float
    outerRadius: float
    startAngle: float
    endAngle: float
    segments: int
    color: Color }
{ $description
    "Draw ring" } ;

HELP: draw-ring-lines
{ $values
    center: Vector2
    innerRadius: float
    outerRadius: float
    startAngle: float
    endAngle: float
    segments: int
    color: Color }
{ $description
    "Draw ring outline" } ;

HELP: draw-rectangle
{ $values
    posX: int
    posY: int
    width: int
    height: int
    color: Color }
{ $description
    "Draw a color-filled rectangle" } ;

HELP: draw-rectangle-v
{ $values
    position: Vector2
    size: Vector2
    color: Color }
{ $description
    "Draw a color-filled rectangle (Vector version)" } ;

HELP: draw-rectangle-rec
{ $values
    rec: Rectangle
    color: Color }
{ $description
    "Draw a color-filled rectangle" } ;

HELP: draw-rectangle-pro
{ $values
    rec: Rectangle
    origin: Vector2
    rotation: float
    color: Color }
{ $description
    "Draw a color-filled rectangle with pro parameters" } ;

HELP: draw-rectangle-gradient-v
{ $values
    posX: int
    posY: int
    width: int
    height: int
    top: Color
    bottom: Color }
{ $description
    "Draw a vertical-gradient-filled rectangle" } ;

HELP: draw-rectangle-gradient-h
{ $values
    posX: int
    posY: int
    width: int
    height: int
    left: Color
    right: Color }
{ $description
    "Draw a horizontal-gradient-filled rectangle" } ;

HELP: draw-rectangle-gradient-ex
{ $values
    rec: Rectangle
    topLeft: Color
    bottomLeft: Color
    topRight: Color
    bottomRight: Color }
{ $description
    "Draw a gradient-filled rectangle with custom vertex colors" } ;

HELP: draw-rectangle-lines
{ $values
    posX: int
    posY: int
    width: int
    height: int
    color: Color }
{ $description
    "Draw rectangle outline" } ;

HELP: draw-rectangle-lines-ex
{ $values
    rec: Rectangle
    lineThick: float
    color: Color }
{ $description
    "Draw rectangle outline with extended parameters" } ;

HELP: draw-rectangle-rounded
{ $values
    rec: Rectangle
    roundness: float
    segments: int
    color: Color }
{ $description
    "Draw rectangle with rounded edges" } ;

HELP: draw-rectangle-rounded-lines
{ $values
    rec: Rectangle
    roundness: float
    segments: int
    color: Color }
{ $description
    "Draw rectangle with rounded edges outline" } ;

HELP: draw-triangle
{ $values
    v1: Vector2
    v2: Vector2
    v3: Vector2
    color: Color }
{ $description
    "Draw a color-filled triangle (vertex in counter-clockwise order!)" } ;

HELP: draw-triangle-lines
{ $values
    v1: Vector2
    v2: Vector2
    v3: Vector2
    color: Color }
{ $description
    "Draw triangle outline (vertex in counter-clockwise order!)" } ;

HELP: draw-triangle-fan
{ $values
    points: { "a " { $link pointer } " to a " { $link Vector2 } }
    pointCount: int
    color: Color }
{ $description
    "Draw a triangle fan defined by points (first vertex is the center)" } ;

HELP: draw-triangle-strip
{ $values
    points: { "a " { $link pointer } " to a " { $link Vector2 } }
    pointCount: int
    color: Color }
{ $description
    "Draw a triangle strip defined by points" } ;

HELP: draw-poly
{ $values
    center: Vector2
    sides: int
    radius: float
    rotation: float
    color: Color }
{ $description
    "Draw a regular polygon (Vector version)" } ;

HELP: draw-poly-lines
{ $values
    center: Vector2
    sides: int
    radius: float
    rotation: float
    color: Color }
{ $description
    "Draw a polygon outline of n sides" } ;

HELP: draw-poly-lines-ex
{ $values
    center: Vector2
    sides: int
    radius: float
    rotation: float
    lineThick: float
    color: Color }
{ $description
    "Draw a polygon outline of n sides with extended parameters" } ;

! Shapes Module - Splines Drawing Functions
HELP: draw-spline-linear
{ $values
    points: { "a " { $link pointer } " to a " { $link Vector2 } }
    pointCount: int
    thick: float
    color: Color }
{ $description
    "Draw spline: Linear, minimum 2 points" } ;

HELP: draw-spline-basis
{ $values
    points: { "a " { $link pointer } " to a " { $link Vector2 } }
    pointCount: int
    thick: float
    color: Color }
{ $description
    "Draw spline: B-Spline, minimum 4 points" } ;

HELP: draw-spline-catmull-rom
{ $values
    points: { "a " { $link pointer } " to a " { $link Vector2 } }
    pointCount: int
    thick: float
    color: Color }
{ $description
    "Draw spline: Catmull-Rom, minimum 4 points" } ;

HELP: draw-spline-bezier-quadratic
{ $values
    points: { "a " { $link pointer } " to a " { $link Vector2 } }
    pointCount: int
    thick: float
    color: Color }
{ $description
    "Draw spline: Quadratic Bezier, minimum 3 points" } ;

HELP: draw-spline-bezier-cubic
{ $values
    points: { "a " { $link pointer } " to a " { $link Vector2 } }
    pointCount: int
    thick: float
    color: Color }
{ $description
    "Draw spline: Cubic Bezier, minimum 4 points" } ;

HELP: draw-spline-segment-linear
{ $values
    p1: Vector2
    p2: Vector2
    thick: float
    color: Color
}
{ $description
    "Draw spline segment: Linear, 2 points" } ;

HELP: draw-spline-segment-basis
{ $values
    p1: Vector2
    p2: Vector2
    p3: Vector2
    p4: Vector2
    thick: float
    color: Color
}
{ $description
    "Draw spline segment: B-Spline, 4 points" } ;

HELP: draw-spline-segment-catmull-rom
{ $values
    p1: Vector2
    p2: Vector2
    p3: Vector2
    p4: Vector2
    thick: float
    color: Color
}
{ $description
    "Draw spline segment: Catmull-Rom, 4 points" } ;

HELP: draw-spline-segment-bezier-quadratic
{ $values
    p1: Vector2
    c2: Vector2
    p3: Vector2
    thick: float
    color: Color
}
{ $description
    "Draw spline segment: Quadratic Bezier, 2 points, 1 control point" } ;

HELP: draw-spline-segment-bezier-cubic
{ $values
    p1: Vector2
    c2: Vector2
    c3: Vector2
    p4: Vector2
    thick: float
    color: Color
}
{ $description
    "Draw spline segment: Cubic Bezier, 2 points, 2 control points" } ;

! Spline segment point evaluation functions, for a given t [0.0f .. 1.0f]
HELP: get-spline-point-linear
{ $values
    startPos: Vector2
    endPos: Vector2
    t: float
    Vector2: Vector2
}
{ $description
    "Get spline point: Linear" } ;

HELP: get-spline-point-basis
{ $values
    p1: Vector2
    p2: Vector2
    p3: Vector2
    p4: Vector2
    t: float
    Vector2: Vector2
}
{ $description
    "Get spline point: B-Spline" } ;

HELP: get-spline-point-catmull-rom
{ $values
    p1: Vector2
    p2: Vector2
    p3: Vector2
    p4: Vector2
    t: float
    Vector2: Vector2
}
{ $description
    "Get spline point: Catmull-Rom" } ;

HELP: get-spline-point-bezier-quad
{ $values
    p1: Vector2
    c2: Vector2
    p3: Vector2
    t: float
    Vector2: Vector2
}
{ $description
    "Get spline point: Quadratic Bezier" } ;

HELP: get-spline-point-bezier-cubic
{ $values
    p1: Vector2
    c2: Vector2
    c3: Vector2
    p4: Vector2
    t: float
    Vector2: Vector2
}
{ $description
    "Get spline point: Cubic Bezier" } ;

! Basic shapes collision detection functions
HELP: check-collision-recs
{ $values
    rec1: Rectangle
    rec2: Rectangle
    bool: bool }
{ $description
    "Check collision between two rectangles" } ;

HELP: check-collision-circles
{ $values
    center1: Vector2
    radius1: float
    center2: Vector2
    radius2: float
    bool: bool }
{ $description
    "Check collision between two circles" } ;

HELP: check-collision-circle-rec
{ $values
    center: Vector2
    radius: float
    rec: Rectangle
    bool: bool }
{ $description
    "Check collision between circle and rectangle" } ;

HELP: check-collision-point-rec
{ $values
    point: Vector2
    rec: Rectangle
    bool: bool }
{ $description
    "Check if point is inside rectangle" } ;

HELP: check-collision-point-circle
{ $values
    point: Vector2
    center: Vector2
    radius: float
    bool: bool }
{ $description
    "Check if point is inside circle" } ;

HELP: check-collision-point-triangle
{ $values
    point: Vector2
    p1: Vector2
    p2: Vector2
    p3: Vector2
    bool: bool }
{ $description
    "Check if point is inside a triangle" } ;

HELP: check-collision-point-poly
{ $values
    point: Vector2
    points: { "a " { $link pointer } " to a " { $link Vector2 } }
    pointCount: int
    bool: bool }
{ $description
    "Check if point is within a polygon described by array of vertices" } ;

HELP: check-collision-lines
{ $values
    startPos1: Vector2
    endPos1: Vector2
    startPos2: Vector2
    endPos2: Vector2
    collisionPoint: { "a " { $link pointer } " to a " { $link Vector2 } }
    bool: bool }
{ $description
    "Check the collision between two lines defined by two points each, returns collision point by reference" } ;

HELP: check-collision-point-line
{ $values
    point: Vector2
    p1: Vector2
    p2: Vector2
    threshold: int
    bool: bool }
{ $description
    "Check if point belongs to line created between two points [p1] and [p2] with defined margin in pixels [threshold]" } ;

HELP: get-collision-rec
{ $values
    rec1: Rectangle
    rec2: Rectangle
    Rectangle Rectangle }
{ $description
    "Get collision rectangle for two rectangles collision" } ;

! Image loading functions
HELP: load-image
{ $values
    fileName: c-string
    Image: Image }
{ $description
    "Load image from file into CPU memory (RAM). " } ;

HELP: load-image-raw
{ $values
    fileName: c-string
    width: int
    height: int
    format: int
    headerSize: int
    Image: Image }
{ $description
    "Load image from RAW file data." } ;

HELP: load-image-anim
{ $values
    fileName: c-string
    frames: { "a " { $link pointer } " to a " { $link int } }
    Image: Image }
{ $description
    "Load image sequence from file (frames appended to image.data)" } ;

HELP: load-image-from-memory
{ $values
    fileType: c-string
    fileData: c-string
    dataSize: int
    Image: Image }
{ $description
    "Load image from memory buffer, fileType refers to extension: i.e. '.png'" } ;

HELP: load-image-from-texture
{ $values
    texture: Texture2D
    Image: Image }
{ $description
    "Load image from GPU texture data" } ;

HELP: load-image-from-screen
{ $values
    Image: Image }
{ $description
    "Load image from screen buffer and (screenshot)" } ;

HELP: is-image-valid
{ $values
    image: Image
    bool: bool }
{ $description
    "Check if an image is ready" } ;

HELP: unload-image
{ $values
    image: Image }
{ $description
    "Unload image from CPU memory (RAM)" } ;

HELP: export-image
{ $values
    image: Image
    fileName: c-string
    bool: bool }
{ $description
    "Export image data to file, returns true on success" } ;

HELP: export-image-as-code
{ $values
    image: Image
    fileName: c-string
    bool: bool }
{ $description
    "Export image as code file defining an array of bytes, returns true on success" } ;


! Image generation functions
HELP: gen-image-color
{ $values
    width: int
    height: int
    color: Color
    Image: Image }
{ $description
    "Generate image: plain color" } ;

HELP: gen-image-gradient-linear
{ $values
    width: int
    height: int
    direction: int
    start: Color
    end: Color
    Image: Image }
{ $description
    "Generate image: linear gradient, direction in degrees [0..360], 0=Vertical gradient" } ;

HELP: gen-image-gradient-radial
{ $values
    width: int
    height: int
    density: float
    inner: Color
    outer: Color
    Image: Image }
{ $description
    "Generate image: radial gradient" } ;

HELP: gen-image-gradient-square
{ $values
    width: int
    height: int
    density: float
    inner: Color
    outer: Color
    Image: Image }
{ $description
    "Generate image: square gradient" } ;

HELP: gen-image-checked
{ $values
    width: int
    height: int
    checksX: int
    checksY: int
    col1: Color
    col2: Color
    Image: Image }
{ $description
    "Generate image: checked" } ;

HELP: gen-image-white-noise
{ $values
    width: int
    height: int
    factor: float
    Image: Image }
{ $description
    "Generate image: white noise" } ;

HELP: gen-image-perlin-noise
{ $values
    width: int
    height: int
    offsetX: int
    offsetY: int
    scale: float
    Image: Image }
{ $description
    "Generate image: perlin noise" } ;

HELP: gen-image-cellular
{ $values
    width: int
    height: int
    tileSize: int
    Image: Image }
{ $description
    "Generate image: cellular algorithm, bigger tileSize means bigger cells" } ;

HELP: gen-image-text
{ $values
    width: int
    height: int
    text: c-string
    Image: Image }
{ $description
    "Generate image: text" } ;


! Image manipulation functions
HELP: image-copy
{ $values
    image: Image
    Image: Image }
{ $description
    "Create an image duplicate (useful for transformations)" } ;

HELP: image-from-image
{ $values
    image: Image
    rec: Rectangle
    Image: Image }
{ $description
    "Create an image from another image piece" } ;

HELP: image-text
{ $values
    text: c-string
    fontSize: int
    color: Color
    Image: Image }
{ $description
    "Create an image from text (default font)" } ;

HELP: image-text-ex
{ $values
    font: Font
    text: c-string
    fontSize: float
    spacing: float
    tint: Color
    Image: Image }
{ $description
    "Create an image from text (custom sprite font)" } ;

HELP: image-format
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } }
    newformat: int }
{ $description
    "Convert image data to desired format" } ;

HELP: image-to-pot
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } }
    fill: Color }
{ $description
    "Convert image to POT (power-of-two)" } ;

HELP: image-crop
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } }
    crop: Rectangle }
{ $description
    "Crop an image to a defined rectangle" } ;

HELP: image-alpha-crop
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } }
    threshold: float }
{ $description
    "Crop image depending on alpha value" } ;

HELP: image-alpha-clear
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } }
    color: Color
    threshold: float }
{ $description
    "Clear alpha channel to desired color" } ;

HELP: image-alpha-mask
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } }
    alphaMask: Image }
{ $description
    "Apply alpha mask to image" } ;

HELP: image-alpha-premultiply
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } } }
{ $description
    "Premultiply alpha channel" } ;

HELP: image-blur-gaussian
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } }
    blurSize: int }
{ $description
    "Blur image with gaussian" } ;

HELP: image-resize
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } }
    newWidth: int
    newHeight: int }
{ $description
    "Resize image (Bicubic scaling algorithm)" } ;

HELP: image-resize-nn
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } }
    newWidth: int
    newHeight: int }
{ $description
    "Resize image (Nearest-Neighbor scaling algorithm)" } ;

HELP: image-resize-canvas
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } }
    newWidth: int
    newHeight: int
    offsetX: int
    offsetY: int
    fill: Color }
{ $description
    "Resize canvas and fill with color" } ;

HELP: image-mipmaps
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } } }
{ $description
    "Compute all mipmap levels for a provided image" } ;

HELP: image-dither
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } }
    rBpp: int
    gBpp: int
    bBpp: int
    aBpp: int }
{ $description
    "Dither image data to 16bpp or lower (Floyd-Steinberg dithering)" } ;

HELP: image-flip-vertical
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } } }
{ $description
    "Flip image vertically" } ;

HELP: image-flip-horizontal
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } } }
{ $description
    "Flip image horizontally" } ;

HELP: image-rotate
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } }
    degrees: int }
{ $description
    "Rotate image by input angle in degrees (-359 to 359)" } ;

HELP: image-rotate-cw
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } } }
{ $description
    "Rotate image clockwise 90deg" } ;

HELP: image-rotate-ccw
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } } }
{ $description
    "Rotate image counter-clockwise 90deg" } ;

HELP: image-color-tint
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } }
    color: Color }
{ $description
    "Modify image color: tint" } ;

HELP: image-color-invert
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } } }
{ $description
    "Modify image color: invert" } ;

HELP: image-color-grayscale
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } } }
{ $description
    "Modify image color: grayscale" } ;

HELP: image-color-contrast
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } }
    contrast: float }
{ $description
    "Modify image color: contrast (-100 to 100)" } ;

HELP: image-color-brightness
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } }
    brightness: int }
{ $description
    "Modify image color: brightness (-255 to 255)" } ;

HELP: image-color-replace
{ $values
    image: { "a " { $link pointer } " to a " { $link Image } }
    color: Color
    replace: Color }
{ $description
    "Modify image color: replace color" } ;

HELP: load-image-colors
{ $values
    image: Image 
    Color*: { "a " { $link pointer } " to an array of " { $link Color } "s" } }
{ $description
    "Load color data from image as a Color array (RGBA - 32bit)" } ;

HELP: load-image-palette
{ $values
    image: Image
    maxPaletteSize: int
    colorCount: { "a " { $link pointer } " to a " { $link int } } 
    Color*: { "a " { $link pointer } " to an array of " { $link Color } "s" } }
{ $description
    "Load colors palette from image as a Color array (RGBA - 32bit)" } ;

HELP: unload-image-colors
{ $values
    colors: { "a " { $link pointer } " to a " { $link Color } } }
{ $description
    "Unload color data loaded with LoadImageColors()" } ;

HELP: unload-image-palette
{ $values
    colors: { "a " { $link pointer } " to a " { $link Color } } }
{ $description
    "Unload colors palette loaded with LoadImagePalette()" } ;

HELP: get-image-alpha-border
{ $values
    image: Image
    threshold: float
    Rectangle: Rectangle }
{ $description
    "Get image alpha border rectangle" } ;

HELP: get-image-color
{ $values
    image: Image
    x: int
    y: int
    Color: Color }
{ $description
    "Get image pixel color at (x, y) position" } ;


! Image drawing functions
HELP: image-clear-background
{ $values
    dst: { "a " { $link pointer } " to a " { $link Image } }
    color: Color }
{ $description
    "Clear image background with given color" } ;

HELP: image-draw-pixel
{ $values
    dst: { "a " { $link pointer } " to a " { $link Image } }
    posX: int
    posY: int
    color: Color }
{ $description
    "Draw pixel within an image" } ;

HELP: image-draw-pixel-v
{ $values
    dst: { "a " { $link pointer } " to a " { $link Image } }
    position: Vector2
    color: Color }
{ $description
    "Draw pixel within an image (Vector version)" } ;

HELP: image-draw-line
{ $values
    dst: { "a " { $link pointer } " to a " { $link Image } }
    startPosX: int
    startPosY: int
    endPosX: int
    endPosY: int
    color: Color }
{ $description
    "Draw line within an image" } ;

HELP: image-draw-line-v
{ $values
    dst: { "a " { $link pointer } " to a " { $link Image } }
    start: Vector2
    end: Vector2
    color: Color }
{ $description
    "Draw line within an image (Vector version)" } ;

HELP: image-draw-circle
{ $values
    dst: { "a " { $link pointer } " to a " { $link Image } }
    centerX: int
    centerY: int
    radius: int
    color: Color }
{ $description
    "Draw circle within an image" } ;

HELP: image-draw-circle-v
{ $values
    dst: { "a " { $link pointer } " to a " { $link Image } }
    center: Vector2
    radius: int
    color: Color }
{ $description
    "Draw circle within an image (Vector version)" } ;

HELP: image-draw-circle-lines
{ $values
    dst: { "a " { $link pointer } " to a " { $link Image } }
    centerX: int
    centerY: int
    radius: int
    color: Color }
{ $description
    "Draw circle within an image" } ;

HELP: image-draw-circle-lines-v
{ $values
    dst: { "a " { $link pointer } " to a " { $link Image } }
    center: Vector2
    radius: int
    color: Color }
{ $description
    "Draw circle within an image (Vector version)" } ;

HELP: image-draw-rectangle
{ $values
    dst: { "a " { $link pointer } " to a " { $link Image } }
    posX: int
    posY: int
    width: int
    height: int
    color: Color }
{ $description
    "Draw rectangle within an image" } ;

HELP: image-draw-rectangle-v
{ $values
    dst: { "a " { $link pointer } " to a " { $link Image } }
    position: Vector2
    size: Vector2
    color: Color }
{ $description
    "Draw rectangle within an image (Vector version)" } ;

HELP: image-draw-rectangle-rec
{ $values
    dst: { "a " { $link pointer } " to a " { $link Image } }
    rec: Rectangle
    color: Color }
{ $description
    "Draw rectangle within an image" } ;

HELP: image-draw-rectangle-lines
{ $values
    dst: { "a " { $link pointer } " to a " { $link Image } }
    rec: Rectangle
    thick: int
    color: Color }
{ $description
    "Draw rectangle lines within an image" } ;

HELP: image-draw
{ $values
    dst: { "a " { $link pointer } " to a " { $link Image } }
    src: Image
    srcRec: Rectangle
    dstRec: Rectangle
    tint: Color }
{ $description
    "Draw a source image within a destination image (tint applied to source)" } ;

HELP: image-draw-text
{ $values
    dst: { "a " { $link pointer } " to a " { $link Image } }
    text: c-string
    posX: int
    posY: int
    fontSize: int
    color: Color }
{ $description
    "Draw text (using default font) within an image (destination)" } ;

HELP: image-draw-text-ex
{ $values
    dst: { "a " { $link pointer } " to a " { $link Image } }
    font: Font
    text: c-string
    position: Vector2
    fontSize: float
    spacing: float
    tint: Color }
{ $description
    "Draw text (custom sprite font) within an image (destination)" } ;


! Texture loading functions
! NOTE: These functions require GPU access
HELP: load-texture
{ $values
    fileName: c-string
    Texture2D: Texture2D }
{ $description
    "Load texture from file into GPU memory (VRAM)" } ;

HELP: load-texture-from-image
{ $values
    image: Image
    Texture2D: Texture2D }
{ $description
    "Load texture from image data" } ;

HELP: load-texture-cubemap
{ $values
    image: Image
    layout: CubemapLayout
    TextureCubemap: TextureCubemap }
{ $description
    "Load cubemap from image, multiple image cubemap layouts supported" } ;

HELP: load-render-texture
{ $values
    width: int
    height: int
    RenderTexture2D: RenderTexture2D }
{ $description
    "Load texture for rendering (framebuffer)" } ;

HELP: is-texture-valid
{ $values
    texture: Texture2D
    bool: bool }
{ $description
    "Check if a texture is ready" } ;

HELP: unload-texture
{ $values
    texture: Texture2D }
{ $description
    "Unload texture from GPU memory (VRAM)" } ;

HELP: is-render-texture-valid
{ $values
    target: RenderTexture2D }
{ $description
    "Check if a render texture is ready" } ;

HELP: unload-render-texture
{ $values
    target: RenderTexture2D }
{ $description
    "Unload render texture from GPU memory (VRAM)" } ;

HELP: update-texture
{ $values
    texture: Texture2D
    pixels: void* }
{ $description
    "Update GPU texture with new data" } ;

HELP: update-texture-rec
{ $values
    texture: Texture2D
    rec: Rectangle
    pixels: void* }
{ $description
    "Update GPU texture rectangle with new data" } ;


! Texture configuration functions
HELP: gen-texture-mipmaps
{ $values
    texture: { "a " { $link pointer } " to a " { $link Texture2D } } }
{ $description
    "Generate GPU mipmaps for a texture" } ;

HELP: set-texture-filter
{ $values
    texture: Texture2D
    filter: TextureFilterMode }
{ $description
    "Set texture scaling filter mode" } ;

HELP: set-texture-wrap
{ $values
    texture: Texture2D
    wrap: TextureWrapMode }
{ $description
    "Set texture wrapping mode" } ;


! Texture drawing functions
HELP: draw-texture
{ $values
    texture: Texture2D
    posX: int
    posY: int
    tint: Color }
{ $description
    "Draw a Texture2D" } ;

HELP: draw-texture-v
{ $values
    texture: Texture2D
    position: Vector2
    tint: Color }
{ $description
    "Draw a Texture2D with position defined as Vector2" } ;

HELP: draw-texture-ex
{ $values
    texture: Texture2D
    position: Vector2
    rotation: float
    scale: float
    tint: Color }
{ $description
    "Draw a Texture2D with extended parameters" } ;

HELP: draw-texture-rec
{ $values
    texture: Texture2D
    source: Rectangle
    position: Vector2
    tint: Color }
{ $description
    "Draw a part of a texture defined by a rectangle" } ;

HELP: draw-texture-pro
{ $values
    texture: Texture2D
    source: Rectangle
    dest: Rectangle
    origin: Vector2
    rotation: float
    tint: Color }
{ $description
    "Draw a part of a texture defined by a rectangle with 'pro' parameters" } ;

HELP: draw-texture-npatch
{ $values
    texture: Texture2D
    nPatchInfo: NPatchInfo
    dest: Rectangle
    origin: Vector2
    rotation: float
    tint: Color }
{ $description
    "Draws a texture (or part of it) that stretches or shrinks nicely" } ;


! Color/pixel related functions
HELP: fade
{ $values
    color: Color
    alpha: float
    Color: Color }
{ $description
    "Get color with alpha applied, alpha goes from 0.0f to 1.0f" } ;

HELP: color-to-int
{ $values
    color: Color
    int: int }
{ $description
    "Get hexadecimal value for a Color" } ;

HELP: color-normalize
{ $values
    color: Color
    Vector4: Vector4 }
{ $description
    "Get Color normalized as float [0..1]" } ;

HELP: color-from-normalized
{ $values
    normalized: Vector4
    Color: Color }
{ $description
    "Get Color from normalized values [0..1]" } ;

HELP: color-to-hsv
{ $values
    color: Color
    Vector3: Vector3 }
{ $description
    "Get HSV values for a Color, hue [0..360], saturation/value [0..1]" } ;

HELP: color-from-hsv
{ $values
    hue: float
    saturation: float
    value: float
    Color: Color }
{ $description
    "Get a Color from HSV values, hue [0..360], saturation/value [0..1]" } ;

HELP: color-tint
{ $values
    color: Color
    tint: Color
    Color: Color }
{ $description
    "Get color with tint" } ;

HELP: color-brightness
{ $values
    color: Color
    factor: float
    Color: Color }
{ $description
    "Get color with brightness" } ;

HELP: color-contrast
{ $values
    color: Color
    contrast: float
    Color: Color }
{ $description
    "Get color with contrast" } ;

HELP: color-alpha
{ $values
    color: Color
    alpha: float
    Color: Color }
{ $description
    "Get color with alpha applied, alpha goes from 0.0f to 1.0f" } ;

HELP: color-alpha-blend
{ $values
    dst: Color
    src: Color
    tint: Color
    Color: Color }
{ $description
    "Get src alpha-blended into dst color with tint" } ;

HELP: get-color
{ $values
    hexValue: uint
    Color: Color }
{ $description
    "Get Color structure from hexadecimal value" } ;

HELP: get-pixel-color
{ $values
    srcPtr: void*
    format: PixelFormat
    Color: Color }
{ $description
    "Get Color from a source pixel pointer of certain format" } ;

HELP: set-pixel-color
{ $values
    dstPtr: void*
    color: Color
    format: PixelFormat }
{ $description
    "Set color formatted into destination pixel pointer" } ;

HELP: get-pixel-data-size
{ $values
    width: int
    height: int
    format: PixelFormat
    int: int }
{ $description
    "Get pixel data size in bytes for certain format" } ;


! Font loading/unloading functions
HELP: get-font-default
{ $values
    Font: Font }
{ $description
    "Get the default Font" } ;

HELP: load-font
{ $values
    fileName: c-string
    Font: Font }
{ $description
    "Load font from file into GPU memory (VRAM)" } ;

HELP: load-font-ex
{ $values
    fileName: c-string
    fontSize: int
    fontChars: { "a " { $link pointer } " to a " { $link int } }
    glyphCount: int
    Font: Font }
{ $description
    "Load font from file with extended parameters, use NULL for fontChars and 0 for glyphCount to load the default character set" } ;

HELP: load-font-from-image
{ $values
    image: Image
    key: Color
    firstChar: int
    Font: Font }
{ $description
    "Load font from Image (XNA style)" } ;

HELP: load-font-from-memory
{ $values
    fileType: c-string
    fileData: c-string
    dataSize: int
    fontSize: int
    fontChars: { "a " { $link pointer } " to a " { $link int } }
    glyphCount: int
    Font: Font }
{ $description
    "Load font from memory buffer, fileType refers to extension: i.e. '.ttf'" } ;

HELP: is-font-valid
{ $values
    font: Font
    bool: bool }
{ $description
    "Check if a font is ready" } ;

HELP: load-font-data
{ $values
    fileData: c-string
    dataSize: int
    fontSize: int
    codepoints: { "a " { $link pointer } " to a " { $link int } }
    codepointCount: int
    type: FontType
    GlyphInfo*: { "a " { $link pointer } " to " { $link GlyphInfo } } }
{ $description
    "Load font data for further use" } ;

HELP: gen-image-font-atlas
{ $values
    chars: { "a " { $link pointer } " to a " { $link GlyphInfo } }
    recs: { "a double " { $link pointer } " to a " { $link Rectangle } }
    glyphCount: int
    fontSize: int
    padding: int
    packMethod: int
    Image: Image }
{ $description
    "Generate image font atlas using chars info" } ;

HELP: unload-font-data
{ $values
    chars: { "a " { $link pointer } " to a " { $link GlyphInfo } }
    glyphCount: int }
{ $description
    "Unload font chars info data (RAM)" } ;

HELP: unload-font
{ $values
    font: Font }
{ $description
    "Unload Font from GPU memory (VRAM)" } ;

HELP: export-font-as-code
{ $values
    font: Font
    fileName: c-string
    bool: bool }
{ $description
    "Export font as code file, returns true on success" } ;


! Text drawing functions
HELP: draw-fps
{ $values
    posX: int
    posY: int }
{ $description
    "Draw current FPS" } ;

HELP: draw-text
{ $values
    text: c-string
    posX: int
    posY: int
    fontSize: int
    color: Color }
{ $description
    "Draw text (using default font)" } ;

HELP: draw-text-ex
{ $values
    font: Font
    text: c-string
    position: Vector2
    fontSize: float
    spacing: float
    tint: Color }
{ $description
    "Draw text using font and additional parameters" } ;

HELP: draw-text-pro
{ $values
    font: Font
    text: c-string
    position: Vector2
    origin: Vector2
    rotation: float
    fontSize: float
    spacing: float
    tint: Color }
{ $description
    "Draw text using Font and pro parameters (rotation)" } ;

HELP: draw-text-codepoint
{ $values
    font: Font
    codepoint: int
    position: Vector2
    fontSize: float
    tint: Color }
{ $description
    "Draw one character (codepoint)" } ;

HELP: draw-text-codepoints
{ $values
    font: Font
    codepoints: { "a " { $link pointer } " to a " { $link int } }
    codepointCount: int
    position: Vector2
    fontSize: float
    spacing: float
    tint: Color }
{ $description
    "Draw multiple character (codepoint)" } ;


! Text font info functions
HELP: set-text-line-spacing
{ $values
    spacing: int
}
{ $description
    "Set vertical line spacing when drawing with line breaks" } ;

HELP: measure-text
{ $values
    text: c-string
    fontSize: int
    int: int }
{ $description
    "Measure string width for default font" } ;

HELP: measure-text-ex
{ $values
    font: Font
    text: c-string
    fontSize: float
    spacing: float
    Vector2: Vector2 }
{ $description
    "Measure string size for Font" } ;

HELP: get-glyph-index
{ $values
    font: Font
    codepoint: int
    int: int }
{ $description
    "Get glyph index position in font for a codepoint (unicode character), fallback to '?' if not found" } ;

HELP: get-glyph-info
{ $values
    font: Font
    codepoint: int
    GlyphInfo: GlyphInfo }
{ $description
    "Get glyph font info data for a codepoint (unicode character), fallback to '?' if not found" } ;

HELP: get-glyph-atlas-rec
{ $values
    font: Font
    codepoint: int
    Rectangle: Rectangle }
{ $description
    "Get glyph rectangle in font atlas for a codepoint (unicode character), fallback to '?' if not found" } ;


! Text codepoints management functions (unicode characters)
HELP: load-utf8
{ $values
    codepoints: { "a " { $link pointer } " to a " { $link int } }
    length: int
    c-string: c-string }
{ $description
    "Load UTF-8 text encoded from codepoints array" } ;

HELP: unload-utf8
{ $values
    text: c-string }
{ $description
    "Unload UTF-8 text encoded from codepoints array" } ;

HELP: load-codepoints
{ $values
    text: c-string
    count: { "a " { $link pointer } " to a " { $link int } }
    int*:  { "a " { $link pointer } " to a " { $link int } } }
{ $description
    "Load all codepoints from a UTF-8 text string, codepoints count returned by parameter" } ;

HELP: unload-codepoints
{ $values
    codepoints: { "a " { $link pointer } " to a " { $link int } } }
{ $description
    "Unload codepoints data from memory" } ;

HELP: get-codepoint-count
{ $values
    text: c-string
    int: int }
{ $description
    "Get total number of codepoints in a UTF-8 encoded string" } ;

HELP: get-codepoint
{ $values
    text: c-string
    bytesProcessed: { "a " { $link pointer } " to a " { $link int } }
    int: int }
{ $description
    "Get next codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure" } ;

HELP: get-codepoint-next
{ $values
    text: c-string
    codepointSize: { "a " { $link pointer } " to a " { $link int } }
    int: int }
{ $description
    "Get next codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure" } ;

HELP: get-codepoint-previous
{ $values
    text: c-string
    codepointSize: { "a " { $link pointer } " to a " { $link int } }
    int: int }
{ $description
    "Get previous codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure" } ;

HELP: codepoint-to-utf8
{ $values
    codepoint: int
    byteSize: { "a " { $link pointer } " to a " { $link int } }
    c-string: c-string  }
{ $description
    "Encode one codepoint into UTF-8 byte array (array length returned as parameter)" } ;


! Text strings management functions (no UTF-8 strings, only byte chars)
! NOTE: Some strings allocate memory internally for returned strings, just be careful!
HELP: text-copy
{ $values
    dst: c-string
    src: c-string
    int: int }
{ $description
    "Copy one string to another, returns bytes copied" } ;

HELP: text-is-equal
{ $values
    text1: c-string
    text2: c-string
    bool: bool }
{ $description
    "Check if two text string are equal" } ;

HELP: text-length
{ $values
    text: c-string
    uint: uint }
{ $description
    "Get text length, checks for '\0' ending" } ;

HELP: text-format
{ $values
    text: c-string
    c-string: c-string }
{ $description
    "Text formatting with variables (sprintf() style)" } ;

HELP: text-subtext
{ $values
    text: c-string
    position: int
    length: int
    c-string: c-string }
{ $description
    "Get a piece of a text string" } ;

HELP: text-replace
{ $values
    text: c-string
    replace: c-string
    by: c-string
    c-string: c-string }
{ $description
    "Replace text string"
    { $warning
        "Memory must be freed!" } } ;

HELP: text-insert
{ $values
    text: c-string
    insert: c-string
    position: int
    c-string: c-string }
{ $description
    "Insert text in a position"
    { $warning
        "Memory must be freed!" } } ;

HELP: text-join
{ $values
    textList: { "a " { $link pointer } " to a " { $link c-string } }
    count: int
    delimiter: c-string
    c-string: c-string }
{ $description
    "Join text strings with delimiter" } ;

HELP: text-split
{ $values
    text: c-string
    delimiter: char
    count: { "a " { $link pointer } " to a " { $link int } }
    c-string*: { "a " { $link pointer } " to an array of " { $link c-string } } }
{ $description
    "Split text into multiple strings" } ;

HELP: text-append
{ $values
    text: c-string
    append: c-string
    position: { "a " { $link pointer } " to a " { $link int } } }
{ $description
    "Append text at specific position and move cursor!" } ;

HELP: text-find-index
{ $values
    text: c-string
    find: c-string
    int: int }
{ $description
    "Find first text occurrence within a string" } ;

HELP: text-to-upper
{ $values
    text: c-string
    c-string: c-string }
{ $description
    "Get upper case version of provided string" } ;

HELP: text-to-lower
{ $values
    text: c-string
    c-string: c-string }
{ $description
    "Get lower case version of provided string" } ;

HELP: text-to-pascal
{ $values
    text: c-string
    c-string: c-string }
{ $description
    "Get Pascal case notation version of provided string" } ;

HELP: text-to-integer
{ $values
    text: c-string
    int: int }
{ $description
    "Get integer value from text."
    { $warning
        "Negative values not supported" } } ;

! Basic geometric 3D shapes drawing functions
HELP: draw-line-3d
{ $values
    startPos: Vector3
    endPos: Vector3
    color: Color }
{ $description
    "Draw a line in 3D world space" } ;

HELP: draw-point-3d
{ $values
    position: Vector3
    color: Color }
{ $description
    "Draw a point in 3D space, actually a small line" } ;

HELP: draw-circle-3d
{ $values
    center: Vector3
    radius: float
    rotationAxis: Vector3
    rotationAngle: float
    color: Color }
{ $description
    "Draw a circle in 3D world space" } ;

HELP: draw-triangle-3d
{ $values
    v1: Vector3
    v2: Vector3
    v3: Vector3
    color: Color }
{ $description
    "Draw a color-filled triangle (vertex in counter-clockwise order!)" } ;

HELP: draw-triangle-strip-3d
{ $values
    points: { "a " { $link pointer } " to a " { $link Vector3 } }
    pointCount: int
    color: Color }
{ $description
    "Draw a triangle strip defined by points" } ;

HELP: draw-cube
{ $values
    position: Vector3
    width: float
    height: float
    length: float
    color: Color }
{ $description
    "Draw cube" } ;

HELP: draw-cube-v
{ $values
    position: Vector3
    size: Vector3
    color: Color }
{ $description
    "Draw cube (Vector version)" } ;

HELP: draw-cube-wires
{ $values
    position: Vector3
    width: float
    height: float
    length: float
    color: Color }
{ $description
    "Draw cube wires" } ;

HELP: draw-cube-wires-v
{ $values
    position: Vector3
    size: Vector3
    color: Color }
{ $description
    "Draw cube wires (Vector version)" } ;

HELP: draw-sphere
{ $values
    centerPos: Vector3
    radius: float
    color: Color }
{ $description
    "Draw sphere" } ;

HELP: draw-sphere-ex
{ $values
    centerPos: Vector3
    radius: float
    rings: int
    slices: int
    color: Color }
{ $description
    "Draw sphere with extended parameters" } ;

HELP: draw-sphere-wires
{ $values
    centerPos: Vector3
    radius: float
    rings: int
    slices: int
    color: Color }
{ $description
    "Draw sphere wires" } ;

HELP: draw-cylinder
{ $values
    position: Vector3
    radiusTop: float
    radiusBottom: float
    height: float
    slices: int
    color: Color }
{ $description
    "Draw a cylinder/cone" } ;

HELP: draw-cylinder-ex
{ $values
    startPos: Vector3
    endPos: Vector3
    startRadius: float
    endRadius: float
    sides: int
    color: Color }
{ $description
    "Draw a cylinder with base at startPos and top at endPos" } ;

HELP: draw-cylinder-wires
{ $values
    position: Vector3
    radiusTop: float
    radiusBottom: float
    height: float
    slices: int
    color: Color }
{ $description
    "Draw a cylinder/cone wires" } ;

HELP: draw-cylinder-wires-ex
{ $values
    startPos: Vector3
    endPos: Vector3
    startRadius: float
    endRadius: float
    sides: int
    color: Color }
{ $description
    "Draw a cylinder wires with base at startPos and top at endPos" } ;

HELP: draw-capsule
{ $values
    startPos: Vector3
    endPos: Vector3
    radius: float
    slices: int
    rings: int
    color: Color }
{ $description
    "Draw a capsule with the center of its sphere caps at startPos and endPos" } ;

HELP: draw-capsule-wires
{ $values
    startPos: Vector3
    endPos: Vector3
    radius: float
    slices: int
    rings: int
    color: Color }
{ $description
    "Draw capsule wireframe with the center of its sphere caps at startPos and endPos" } ;

HELP: draw-plane
{ $values
    centerPos: Vector3
    size: Vector2
    color: Color }
{ $description
    "Draw a plane XZ" } ;

HELP: draw-ray
{ $values
    ray: Ray
    color: Color }
{ $description
    "Draw a ray line" } ;

HELP: draw-grid
{ $values
    slices: int
    spacing: float }
{ $description
    "Draw a grid (centered at (0, 0, 0))" } ;


! Model management functions
HELP: load-model
{ $values
    fileName: c-string
    Model: Model }
{ $description
    "Load model from files (meshes and materials)" } ;

HELP: load-model-from-mesh
{ $values
    mesh: Mesh
    Model: Model }
{ $description
    "Load model from generated mesh (default material)" } ;

HELP: is-model-valid
{ $values
    model: Model
    bool: bool }
{ $description
    "Check if a model is ready" } ;

HELP: unload-model
{ $values
    model: Model }
{ $description
    "Unload model (including meshes) from memory (RAM and/or VRAM)" } ;

HELP: get-model-bounding-box
{ $values
    model: Model
    BoundingBox: BoundingBox }
{ $description
    "Compute model bounding box limits (considers all meshes)" } ;


! Model drawing functions
HELP: draw-model
{ $values
    model: Model
    position: Vector3
    scale: float
    tint: Color }
{ $description
    "Draw a model (with texture if set)" } ;

HELP: draw-model-ex
{ $values
    model: Model
    position: Vector3
    rotationAxis: Vector3
    rotationAngle: float
    scale: Vector3
    tint: Color }
{ $description
    "Draw a model with extended parameters" } ;

HELP: draw-model-wires
{ $values
    model: Model
    position: Vector3
    scale: float
    tint: Color }
{ $description
    "Draw a model wires (with texture if set)" } ;

HELP: draw-model-wires-ex
{ $values
    model: Model
    position: Vector3
    rotationAxis: Vector3
    rotationAngle: float
    scale: Vector3
    tint: Color }
{ $description
    "Draw a model wires (with texture if set) with extended parameters" } ;

HELP: draw-bounding-box
{ $values
    box: BoundingBox
    color: Color }
{ $description
    "Draw bounding box (wires)" } ;

HELP: draw-billboard
{ $values
    camera: Camera
    texture: Texture2D
    position: Vector3
    scale: float
    tint: Color }
{ $description
    "Draw a billboard texture" } ;

HELP: draw-billboard-rec
{ $values
    camera: Camera
    texture: Texture2D
    source: Rectangle
    position: Vector3
    size: Vector2
    tint: Color }
{ $description
    "Draw a billboard texture defined by source" } ;

HELP: draw-billboard-pro
{ $values
    camera: Camera
    texture: Texture2D
    source: Rectangle
    position: Vector3
    up: Vector3
    size: Vector2
    origin: Vector2
    rotation: float
    tint: Color }
{ $description
    "Draw a billboard texture defined by source and rotation" } ;


! Mesh management functions
HELP: upload-mesh
{ $values
    mesh: { "a " { $link pointer } " to a " { $link Mesh } }
    dynamic: bool }
{ $description
    "Upload mesh vertex data in GPU and provide VAO/VBO ids" } ;

HELP: update-mesh-buffer
{ $values
    mesh: Mesh
    index: int
    data: void*
    dataSize: int
    offset: int }
{ $description
    "Update mesh vertex data in GPU for a specific buffer index" } ;

HELP: unload-mesh
{ $values
    mesh: Mesh }
{ $description
    "Unload mesh data from CPU and GPU" } ;

HELP: draw-mesh
{ $values
    mesh: Mesh
    material: Material
    transform: Matrix }
{ $description
    "Draw a 3d mesh with material and transform" } ;

HELP: draw-mesh-instanced
{ $values
    mesh: Mesh
    material: Material
    transforms: { "a " { $link pointer } " to a " { $link Matrix } }
    instances: int }
{ $description
    "Draw multiple mesh instances with material and different transforms" } ;

HELP: export-mesh
{ $values
    mesh: Mesh
    fileName: c-string
    bool: bool }
{ $description
    "Export mesh data to file, returns true on success" } ;

HELP: get-mesh-bounding-box
{ $values
    mesh: Mesh
    BoundingBox: BoundingBox }
{ $description
    "Compute mesh bounding box limits" } ;

HELP: gen-mesh-tangents
{ $values
    mesh: { "a " { $link pointer } " to a " { $link Mesh } } }
{ $description
    "Compute mesh tangents" } ;


! Mesh generation functions
HELP: gen-mesh-poly
{ $values
    sides: int
    radius: float
    Mesh: Mesh }
{ $description
    "Generate polygonal mesh" } ;

HELP: gen-mesh-plane
{ $values
    width: float
    length: float
    resX: int
    resZ: int
    Mesh: Mesh }
{ $description
    "Generate plane mesh (with subdivisions)" } ;

HELP: gen-mesh-cube
{ $values
    width: float
    height: float
    length: float
    Mesh: Mesh }
{ $description
    "Generate cuboid mesh" } ;

HELP: gen-mesh-sphere
{ $values
    radius: float
    rings: int
    slices: int
    Mesh: Mesh }
{ $description
    "Generate sphere mesh (standard sphere)" } ;

HELP: gen-mesh-hemi-sphere
{ $values
    radius: float
    rings: int
    slices: int
    Mesh: Mesh }
{ $description
    "Generate half-sphere mesh (no bottom cap)" } ;

HELP: gen-mesh-cylinder
{ $values
    radius: float
    height: float
    slices: int
    Mesh: Mesh }
{ $description
    "Generate cylinder mesh" } ;

HELP: gen-mesh-cone
{ $values
    radius: float
    height: float
    slices: int
    Mesh: Mesh }
{ $description
    "Generate cone/pyramid mesh" } ;

HELP: gen-mesh-torus
{ $values
    radius: float
    size: float
    radSeg: int
    sides: int
    Mesh: Mesh }
{ $description
    "Generate torus mesh" } ;

HELP: gen-mesh-knot
{ $values
    radius: float
    size: float
    radSeg: int
    sides: int
    Mesh: Mesh }
{ $description
    "Generate trefoil knot mesh" } ;

HELP: gen-mesh-heightmap
{ $values
    heightmap: Image
    size: Vector3
    Mesh: Mesh }
{ $description
    "Generate heightmap mesh from image data" } ;

HELP: gen-mesh-cubicmap
{ $values
    cubicmap: Image
    cubeSize: Vector3
    Mesh: Mesh }
{ $description
    "Generate cubes-based map mesh from image data" } ;


! Material loading/unloading functions
HELP: load-materials
{ $values
    fileName: c-string
    materialCount: { "a " { $link pointer } " to a " { $link int } }
    Material*: { "a " { $link pointer } " to a " { $link Material } } }
{ $description
    "Load materials from model file" } ;

HELP: load-material-default
{ $values
    Material: Material }
{ $description
    "Load default material (Supports: DIFFUSE, SPECULAR, NORMAL maps)" } ;

HELP: is-material-valid
{ $values
    material: Material
    bool: bool }
{ $description
    "check if a material is ready" } ;

HELP: unload-material
{ $values
    material: Material }
{ $description
    "Unload material from GPU memory (VRAM)" } ;

HELP: set-material-texture
{ $values
    material: { "a " { $link pointer } " to a " { $link Material } }
    mapType: int
    texture: Texture2D }
{ $description
    "Set texture for a material map type  ( Material_MAP_DIFFUSE, MATERIAL_MAP_SPECULAR...)" } ;

HELP: set-model-mesh-material
{ $values
    model: { "a " { $link pointer } " to a " { $link Model } }
    meshId: int
    materialId: int }
{ $description
    "Set material for a mesh" } ;


! Model animations loading/unloading functions
HELP: load-model-animations
{ $values
    fileName: c-string
    animCount: { "a " { $link pointer } " to a " { $link int } }
    ModelAnimation*: { "a " { $link pointer } " to a " { $link ModelAnimation } } }
{ $description
    "Load model animations from file" } ;

HELP: update-model-animation
{ $values
    model: Model
    anim: ModelAnimation
    frame: int }
{ $description
    "Update model animation pose" } ;

HELP: unload-model-animation
{ $values
    anim: ModelAnimation }
{ $description
    "Unload animation data" } ;

HELP: unload-model-animations
{ $values
    animations: { "a " { $link pointer } " to a "  { $link ModelAnimation } }
    count: int }
{ $description
    "Unload animation array data" } ;

HELP: is-model-animation-valid
{ $values
    model: Model
    anim: ModelAnimation
    bool: bool }
{ $description
    "Check model animation skeleton match" } ;


! Collision detection functions
HELP: check-collision-spheres
{ $values
    center1: Vector3
    radius1: float
    center2: Vector3
    radius2: float
    bool: bool }
{ $description
    "Check collision between two spheres" } ;

HELP: check-collision-boxes
{ $values
    box1: BoundingBox
    box2: BoundingBox
    bool: bool }
{ $description
    "Check collision between two bounding boxes" } ;

HELP: check-collision-box-sphere
{ $values
    box: BoundingBox
    center: Vector3
    radius: float
    bool: bool }
{ $description
    "Check collision between box and sphere" } ;

HELP: get-ray-collision-sphere
{ $values
    ray: Ray
    center: Vector3
    radius: float
    RayCollision: RayCollision }
{ $description
    "Get collision info between ray and sphere" } ;

HELP: get-ray-collision-box
{ $values
    ray: Ray
    box: BoundingBox
    RayCollision: RayCollision }
{ $description
    "Get collision info between ray and box" } ;

HELP: get-ray-collision-mesh
{ $values
    ray: Ray
    mesh: Mesh
    transform: Matrix
    RayCollision: RayCollision }
{ $description
    "Get collision info between ray and mesh" } ;

HELP: get-ray-collision-triangle
{ $values
    ray: Ray
    p1: Vector3
    p2: Vector3
    p3: Vector3
    RayCollision: RayCollision }
{ $description
    "Get collision info between ray and triangle" } ;

HELP: get-ray-collision-quad
{ $values
    ray: Ray
    p1: Vector3
    p2: Vector3
    p3: Vector3
    p4: Vector3
    RayCollision: RayCollision }
{ $description
    "Get collision info between ray and quad" } ;

HELP: get-ray-collision-model
{ $values 
    ray: Ray
    model: Model 
    ray-collision: RayCollision } ;

HELP: get-ray-collision-ground 
{ $values 
    ray: Ray
    ground-height: float 
    ray-collision: RayCollision } ;

HELP: AudioCallback
{ $values
    quot: { $quotation ( void* int -- ) }
    alien: c-ptr }
{ $description
    Constructs a \ alien-callback that can be passed to
    raylib's audio processing functions. }
{ $see-also
    set-audio-stream-callback
    attach-audio-stream-processor
    detach-audio-stream-processor
    attach-audio-mixed-processor
    detach-audio-mixed-processor } ;

! Audio device management functions
HELP: init-audio-device
{ $description
    "Initialize audio device and context " } ;

HELP: close-audio-device
{ $description
    "Close the audio device and context " } ;

HELP: is-audio-device-ready
{ $values 
    bool: bool }
{ $description
    "Check if audio device has been initialized successfully " } ;

HELP: set-master-volume
{ $values
    volume: float }
{ $description
    "Set master volume (listener)" } ;

HELP: get-master-volume
{ $values
    float: float }
{ $description
    "Get master volume (listener)" } ;

! Wave/Sound loading/unloading functions
HELP: load-wave
{ $values
    fileName: c-string
    Wave: Wave }
{ $description
    Load wave data from file } ;

HELP: load-wave-from-memory
{ $values
    fileType: c-string
    fileData: c-string
    dataSize: int
    Wave: Wave }
{ $description
    Load wave from memory buffer, fileType refers to extension: i.e. '.wav' } ;

HELP: is-wave-valid
{ $values
    wave: Wave
    bool: bool }
{ $description
    "Checks if wave data is ready " } ;

HELP: load-sound
{ $values
    fileName: c-string
    Sound: Sound }
{ $description
    "Load sound from file" } ;

HELP: load-sound-from-wave
{ $values
    wave: Wave
    Sound: Sound }
{ $description
    "Load sound from wave data " } ;

HELP: load-sound-alias
{ $values
    source: Sound
    Sound: Sound }
{ $description
    "Create a new sound that shares the same sample data as the source sound, does not own the sound data" } ;

HELP: unload-sound-alias
{ $values
    alias: Sound }
{ $description
    "Unload a sound alias (does not deallocate sample data)" } ;

HELP: is-sound-valid
{ $values
    sound: Sound
    bool: bool }
{ $description
    "Checks if a sound is ready" } ;

HELP: update-sound
{ $values
    sound: Sound
    data: void*
    sampleCount: int }
{ $description
    "Update sound buffer with new data" } ;

HELP: unload-wave
{ $values
    wave: Wave }
{ $description
    "Unload wave data" } ;

HELP: unload-sound
{ $values
    sound: Sound }
{ $description
    Unload sound } ;

HELP: export-wave
{ $values
    wave: Wave
    fileName: c-string
    bool: bool }
{ $description
    "Export wave data to file, returns true on success " } ;

HELP: export-wave-as-code
{ $values
    wave: Wave
    fileName: c-string
    bool: bool }
{ $description
    "Export wave sample data to code (.h), returns true on success " } ;


! Wave/Sound management functions
HELP: play-sound
{ $values
    sound: Sound }
{ $description
    Play a sound } ;

HELP: stop-sound
{ $values
    sound: Sound }
{ $description
    Stop playing a sound } ;

HELP: pause-sound
{ $values
    sound: Sound }
{ $description
    Pause a sound } ;

HELP: resume-sound
{ $values
    sound: Sound }
{ $description
    Resume a paused sound } ;

HELP: is-sound-playing
{ $values
    sound: Sound
    bool: bool }
{ $description
    Check if a sound is currently playing } ;

HELP: set-sound-volume
{ $values
    sound: Sound
    volume: float }
{ $description
    Set volume for a sound (1.0 is max level) } ;

HELP: set-sound-pitch
{ $values
    sound: Sound
    pitch: float }
{ $description
    Set pitch for a sound (1.0 is base level) } ;

HELP: set-sound-pan
{ $values
    sound: Sound
    pan: float }
{ $description
    Set pan for a sound (0.5 is center) } ;

HELP: wave-copy
{ $values
    wave: Wave
    Wave: Wave }
{ $description
    "Copy a wave to a new wave " } ;

HELP: wave-crop
{ $values
    wave: { "a " { $link pointer } " to a " { $link Wave } }
    initFrame: int
    finalFrame: int  }
{ $description
    Crop a wave to defined samples range } ;

HELP: wave-format
{ $values
    wave: { "a " { $link pointer } " to a " { $link Wave } }
    sampleRate: int
    sampleSize: int
    channels: int  }
{ $description
    Convert wave data to desired format } ;

HELP: load-wave-samples
{ $values
    wave: Wave
    float*: { "a " { $link pointer } " to some " { $link float } "s" } }
{ $description
    "Load samples data from wave as a floats array " } ;

HELP: unload-wave-samples
{ $values
    samples: { "a " { $link pointer } " to some " { $link float } "s" } }
{ $description
    "Unload samples data loaded with " { $link load-wave-samples } } ;

! Music management functions
HELP: load-music-stream
{ $values
    fileName: c-string
    Music: Music }
{ $description
    Load music stream from file } ;

HELP: load-music-stream-from-memory
{ $values
    fileType: c-string
    data: c-string
    dataSize: int
    Music: Music }
{ $description
    Load music stream from data } ;

HELP: is-music-valid
{ $values
    music: Music
    bool: bool }
{ $description
    "Checks if a music stream is ready " } ;

HELP: unload-music-stream
{ $values
    music: Music }
{ $description
    "Unload music stream " } ;

HELP: play-music-stream
{ $values
    music: Music }
{ $description
    "Start music playing " } ;

HELP: is-music-stream-playing
{ $values
    music: Music
    bool: bool }
{ $description
    "Check if music is playing " } ;

HELP: update-music-stream
{ $values
    music: Music }
{ $description
    "Updates buffers for music streaming " } ;

HELP: stop-music-stream
{ $values
    music: Music }
{ $description
    "Stop music playing " } ;

HELP: pause-music-stream
{ $values
    music: Music }
{ $description
    "Pause music playing " } ;

HELP: resume-music-stream
{ $values
    music: Music }
{ $description
    "Resume playing paused music " } ;

HELP: seek-music-stream
{ $values
    music: Music
    position: float }
{ $description
    "Seek music to a position (in seconds)" } ;

HELP: set-music-volume
{ $values
    music: Music
    volume: float }
{ $description
    "Set volume for music (1.0 is max level)" } ;

HELP: set-music-pitch
{ $values
    music: Music
    pitch: float }
{ $description
    "Set pitch for a music (1.0 is base level)" } ;

HELP: set-music-pan
{ $values
    sound: Music
    pan: float }
{ $description
    "Set pan for a music (0.5 is center)" } ;

HELP: get-music-time-length
{ $values
    music: Music
    float: float }
{ $description
    "Get music time length (in seconds) " } ;

HELP: get-music-time-played
{ $values
    music: Music
    float: float }
{ $description
    "Get current music time played (in seconds) " } ;

! AudioStream management functions
HELP: load-audio-stream
{ $values
    sampleRate: uint
    sampleSize: uint
    channels: uint
    AudioStream: AudioStream }
{ $description
    "Load audio stream (to stream raw audio pcm data)" } ;

HELP: is-audio-stream-valid
{ $values
    stream: AudioStream
    bool: bool }
{ $description
    "Checks if an audio stream is ready " } ;

HELP: unload-audio-stream
{ $values
    stream: AudioStream }
{ $description
    "Unload audio stream and free memory " } ;

HELP: update-audio-stream
{ $values
    stream: AudioStream
    data: void*
    frameCount: int }
{ $description
    "Update audio stream buffers with data" } ;

HELP: is-audio-stream-processed
{ $values
    stream: AudioStream
    bool: bool }
{ $description
    "Check if any audio stream buffers requires refill " } ;

HELP: play-audio-stream
{ $values
    stream: AudioStream }
{ $description
    "Play audio stream " } ;

HELP: pause-audio-stream
{ $values
    stream: AudioStream }
{ $description
    "Pause audio stream " } ;

HELP: resume-audio-stream
{ $values
    stream: AudioStream }
{ $description
    "Resume audio stream " } ;

HELP: is-audio-stream-playing
{ $values
    stream: AudioStream
    bool: bool }
{ $description
    "Check if audio stream is playing " } ;

HELP: stop-audio-stream
{ $values
    stream: AudioStream }
{ $description
    "Stop audio stream " } ;

HELP: set-audio-stream-volume
{ $values
    stream: AudioStream
    volume: float }
{ $description
    "Set volume for audio stream (1.0 is max level)" } ;

HELP: set-audio-stream-pitch
{ $values
    stream: AudioStream
    pitch: float }
{ $description
    "Set pitch for audio stream (1.0 is base level)" } ;

HELP: set-audio-stream-pan
{ $values
    stream: AudioStream
    pan: float }
{ $description
    "Set pan for audio stream (0.5 is center)" } ;

HELP: set-audio-stream-buffer-size-default
{ $values
    size: int }
{ $description
    "Default size for new audio streams" } ;

HELP: set-audio-stream-callback
{ $values
    stream: AudioStream
    callback: AudioCallback }
{ $description
    "Audio thread callback to request new data" } ;


HELP: attach-audio-stream-processor
    { $values
        stream: AudioStream
        processor: AudioCallback }
{ $description
    "Attach audio stream processor to stream, receives the samples as <float>s" } ;

HELP: detach-audio-stream-processor
    { $values
        stream: AudioStream
        processor: AudioCallback }
{ $description
    "Detach audio stream processor from stream" } ;


HELP: attach-audio-mixed-processor
{ $values
    processor: AudioCallback }
{ $description
    "Attach audio stream processor to the entire audio pipeline, receives the samples as <float>s" } ;

HELP: detach-audio-mixed-processor
{ $values
    processor: AudioCallback }
{ $description
    "Detach audio stream processor from the entire audio pipeline" } ;


ARTICLE: "raylib" "Raylib"
    { $heading About Raylib  }
        Raylib attempts to be a simple and easy-to-use library for writing
        graphical applications.

    { $subheading Main Website }
        { $url "https://www.raylib.com/index.html" }

    { $subheading Raylib Cheat Sheet }
        { $url "https://www.raylib.com/cheatsheet/cheatsheet.html" }

    { $heading About These Bindings }
        The { $vocab-link "raylib" } vocabulary provides bindings to
        Raylib 4.5. The vocab is fully documented using Factor's help
        system. So, you can reliably use the browser to find information about
        the various functions in raylib.

    { $warning
        Use caution when attempting to leverage concurrency features.
        Raylib and the UI tools can interact in nasty ways: { $link "raylib-and-threads" } .
    }
;

ARTICLE: "raylib-and-threads" "Raylib and Threads"
    Factor features a powerful UI tool kit. However, Raylibe is designed
    under a single threaded model. Running a Raylib program will lock up
    the UI until the program finishes. However, attempting to use
    concurrency and threading features can corrupt the UI if done wrong.
;

ABOUT: "raylib"
