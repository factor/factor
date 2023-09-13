! Copyright (C) 2023 CapitalEx.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays help.markup help.syntax
kernel make math math.parser quotations sequences strings urls ;
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

    { $enum-members ConfigFlags }
} ;

HELP: FLAG_VSYNC_HINT
{ $class-description
    Setting this flag will attempt to enable v-sync on the GPU.
    { $see-also ConfigFlags }
} ;

HELP: FLAG_FULLSCREEN_MODE
{ $class-description
    Setting this flag will run the program in fullscreen
    { $see-also ConfigFlags }
} ;

HELP: FLAG_WINDOW_RESIZABLE
{ $class-description
    Setting this flag allows for resizing the window.
    { $see-also ConfigFlags }
} ;

HELP: FLAG_WINDOW_UNDECORATED
{ $class-description
    Setting this flag remove window decorations (frame and buttons).
    { $see-also ConfigFlags }
} ;

HELP: FLAG_WINDOW_HIDDEN
{ $class-description
    Setting this flag will hide the window.
    { $see-also ConfigFlags }
} ;

HELP: FLAG_WINDOW_MINIMIZED
{ $class-description
    Setting this flag will minize the window.
    { $see-also ConfigFlags }
} ;

HELP: FLAG_WINDOW_MAXIMIZED
{ $class-description
    Setting this flag will maximize the window to the monitor size.
    { $see-also ConfigFlags }
} ;

HELP: FLAG_WINDOW_UNFOCUSED
{ $class-description
    Setting this flag will set the window to be unfocused.
    { $see-also ConfigFlags }
} ;

HELP: FLAG_WINDOW_TOPMOST
{ $class-description
    Setting this flag sets the window to always be on top.
    { $see-also ConfigFlags }
} ;

HELP: FLAG_WINDOW_ALWAYS_RUN
{ $class-description
    Setting this flag allows the window to run while minimized.
    { $see-also ConfigFlags }
} ;

HELP: FLAG_WINDOW_TRANSPARENT
{ $class-description
    Setting this flag allows for transparent framebuffer.
    { $see-also ConfigFlags }
} ;

HELP: FLAG_WINDOW_HIGHDPI
{ $class-description
    Setting this flag will enable HighDPI support.
    { $see-also ConfigFlags }
} ;

HELP: FLAG_MSAA_4X_HINT
{ $class-description
    Setting this flag will attempt to enable MSAA 4x.
    { $see-also ConfigFlags }
} ;

HELP: FLAG_INTERLACED_HINT
{ $class-description
    Setting this flag will attempt to enable the interlaced video
    format for V3D.
    { $see-also ConfigFlags }
} ;


! Trace log level enum
HELP: TraceLogLevel
{ $var-description
    Represents the various logging levels in Raylib.
    Logs are displayed using the system's standard output.

    { $enum-members TraceLogLevel }
} ;

HELP: LOG_ALL
{ $class-description
    Displays all logs.

    { $see-also TraceLogLevel }
} ;

HELP: LOG_TRACE
{ $class-description
    Deplays trace logging. \ LOG_TRACE meant for internal usage.

    { $see-also TraceLogLevel }
} ;

HELP: LOG_INFO
{ $class-description
    Displays debugging logs. { $snippet LOG_INFO } is used for internal
    debugging and should be disabled on release builds.

    { $see-also TraceLogLevel }
} ;

HELP: LOG_WARNING
{ $class-description
    Displays warning logs. Warnings are recoverable failures.

    { $see-also TraceLogLevel }
} ;

HELP: LOG_ERROR
{ $class-description
    Displays error logs. Errors are unrecoverable failures.

    { $see-also TraceLogLevel }
} ;

HELP: LOG_FATAL
{ $class-description
    Displays fatal logs. Fatal errors are used while aborting
    the program.
    { $see-also TraceLogLevel }
} ;

HELP: LOG_NONE
{ $class-description
    Disables raylib logging.

    { $see-also TraceLogLevel }
} ;


! Keyboard key enum
HELP: KeyboardKey
{ $var-description
    An enum representing the various key codes Raylib can produce.
    These codes are based on the physical layout of a US QWERTY
    keyboard layout. Use \ get-key-pressed to allow for defining
    alternative layouts.

    { $enum-members KeyboardKey }
} ;

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

    { $enum-members MouseButton }
} ;

HELP: MOUSE_BUTTON_LEFT
{ $class-description
    Represents the left mouse button.

    { $see-also MouseButton }
} ;

HELP: MOUSE_BUTTON_RIGHT
{ $class-description
    Represents the right mouse button.

    { $see-also MouseButton }
} ;

HELP: MOUSE_BUTTON_MIDDLE
{ $class-description
    Represents the middle mouse button. On most mice, this is clicking
    the scroll wheel.

    { $see-also MouseButton }
} ;

HELP: MOUSE_BUTTON_SIDE
{ $class-description
    Represents a side button on mice that have additional buttons.

    { $see-also MouseButton }
} ;

HELP: MOUSE_BUTTON_EXTRA
{ $class-description
    Represents an extra button on mice that have additional buttons.

    { $see-also MouseButton }
} ;

HELP: MOUSE_BUTTON_FORWARD
{ $class-description
    Represents the " \"forward\" " button on mice that have additional buttons.

    { $see-also MouseButton }
} ;

HELP: MOUSE_BUTTON_BACK
{ $class-description
    Represents the " \"back\" " button on mice that have additional buttons.

    { $see-also MouseButton }
} ;


! Mouse cursor enum
HELP: MouseCursor
{ $var-description
    An enum representing the various states the cursor can be in.
    This is used to change the cursor icon " / " shape.


    { $enum-members MouseCursor }
} ;

HELP: MOUSE_CURSOR_DEFAULT
{ $var-description
    Default pointer shape.

    { $see-also MouseCursor }
} ;

HELP: MOUSE_CURSOR_ARROW
{ $var-description
    Arrow shape.

    { $see-also MouseCursor }
} ;

HELP: MOUSE_CURSOR_IBEAM
{ $var-description
    Text writing cursor shape.

    { $see-also MouseCursor }
} ;

HELP: MOUSE_CURSOR_CROSSHAIR
{ $var-description
    Cross shape.

    { $see-also MouseCursor }
} ;

HELP: MOUSE_CURSOR_POINTING_HAND
{ $var-description
    Pointing hand cursor.

    { $see-also MouseCursor }
} ;

HELP: MOUSE_CURSOR_RESIZE_EW
{ $var-description
    Horizontal resize/move arrow shape.

    { $see-also MouseCursor }
} ;

HELP: MOUSE_CURSOR_RESIZE_NS
{ $var-description
    Vertical resize/move arrow shape.

    { $see-also MouseCursor }
} ;

HELP: MOUSE_CURSOR_RESIZE_NWSE
{ $var-description
    Top-left to bottom-right diagonal resize/move arrow shape.

    { $see-also MouseCursor }
} ;

HELP: MOUSE_CURSOR_RESIZE_NESW
{ $var-description
    The top-right to bottom-left diagonal resize/move arrow shape.

    { $see-also MouseCursor }
} ;

HELP: MOUSE_CURSOR_RESIZE_ALL
{ $var-description
    The omni-directional resize/move cursor shape.

    { $see-also MouseCursor }
} ;

HELP: MOUSE_CURSOR_NOT_ALLOWED
{ $var-description
    The operation-not-allowed shape.

    { $see-also MouseCursor }
} ;


! Gamepad button enum
HELP: GamepadButton
{ $var-description
    This enum represents the various buttons a gamepad might have.

    It's important to keep in mind different controllers may have
    different button orderings. Each enum member notes the
    differences in their respective documentation sections.

    { $see-also GamepadAxis }

    { $enum-members GamepadButton }
} ;

HELP: GAMEPAD_BUTTON_UNKNOWN
{ $class-description
     Unknown button, just for error checking

     { $see-also GamepadButton }
} ;

HELP: GAMEPAD_BUTTON_LEFT_FACE_UP
{ $class-description
     Gamepad left DPAD up button

     { $see-also GamepadButton }
} ;

HELP: GAMEPAD_BUTTON_LEFT_FACE_RIGHT
{ $class-description
     Gamepad left DPAD right button

     { $see-also GamepadButton }
} ;

HELP: GAMEPAD_BUTTON_LEFT_FACE_DOWN
{ $class-description
     Gamepad left DPAD down button

     { $see-also GamepadButton }
} ;

HELP: GAMEPAD_BUTTON_LEFT_FACE_LEFT
{ $class-description
     Gamepad left DPAD left button

     { $see-also GamepadButton }
} ;

HELP: GAMEPAD_BUTTON_RIGHT_FACE_UP
{ $class-description
     Gamepad right button up (i.e. PS3: Triangle, Xbox: Y)

     { $see-also GamepadButton }
} ;

HELP: GAMEPAD_BUTTON_RIGHT_FACE_RIGHT
{ $class-description
     Gamepad right button right (i.e. PS3: Square, Xbox: X)

     { $see-also GamepadButton }
} ;

HELP: GAMEPAD_BUTTON_RIGHT_FACE_DOWN
{ $class-description
     Gamepad right button down (i.e. PS3: Cross, Xbox: A)

     { $see-also GamepadButton }
} ;

HELP: GAMEPAD_BUTTON_RIGHT_FACE_LEFT
{ $class-description
     Gamepad right button left (i.e. PS3: Circle, Xbox: B)

     { $see-also GamepadButton }
} ;

HELP: GAMEPAD_BUTTON_LEFT_TRIGGER_1
{ $class-description
     Gamepad top/back trigger left (first), it could be a trailing button

     { $see-also GamepadButton }
} ;

HELP: GAMEPAD_BUTTON_LEFT_TRIGGER_2
{ $class-description
     Gamepad top/back trigger left (second), it could be a trailing button

     { $see-also GamepadButton }
} ;

HELP: GAMEPAD_BUTTON_RIGHT_TRIGGER_1
{ $class-description
     Gamepad top/back trigger right (one), it could be a trailing button

     { $see-also GamepadButton }
} ;

HELP: GAMEPAD_BUTTON_RIGHT_TRIGGER_2
{ $class-description
     Gamepad top/back trigger right (second), it could be a trailing button

     { $see-also GamepadButton }
} ;

HELP: GAMEPAD_BUTTON_MIDDLE_LEFT
{ $class-description
     Gamepad center buttons, left one (i.e. PS3: Select)

     { $see-also GamepadButton }
} ;

HELP: GAMEPAD_BUTTON_MIDDLE
{ $class-description
     Gamepad center buttons, middle one (i.e. PS3: PS, Xbox: XBOX)

     { $see-also GamepadButton }
} ;

HELP: GAMEPAD_BUTTON_MIDDLE_RIGHT
{ $class-description
     Gamepad center buttons, right one (i.e. PS3: Start)

     { $see-also GamepadButton }
} ;

HELP: GAMEPAD_BUTTON_LEFT_THUMB
{ $class-description
     Gamepad joystick pressed button left

     { $see-also GamepadButton }
} ;

HELP: GAMEPAD_BUTTON_RIGHT_THUMB
{ $class-description
     Gamepad joystick pressed button right

     { $see-also GamepadButton }
} ;


! Gamepad axis enum
HELP: GamepadAxis
{ $var-description
    Contains a set of flags for each axis a gamepad may have. Raylib
    supports controllers with two triggers and two joysticks.

    { $enum-members GamepadAxis }
} ;

HELP: GAMEPAD_AXIS_LEFT_X
{ $class-description
    Represents the left gamepad stick and its tilt on the X axis (left/right).
    { $see-also GamepadAxis }
} ;

HELP: GAMEPAD_AXIS_LEFT_Y
{ $class-description
    Represents the left gamepad stick and its tilt on the Y axis (up/down).
    { $see-also GamepadAxis }
} ;

HELP: GAMEPAD_AXIS_RIGHT_X
{ $class-description
    Represents the right gamepad stick and its tilt on the X axis (left/right).
    { $see-also GamepadAxis }
} ;

HELP: GAMEPAD_AXIS_RIGHT_Y
{ $class-description
    Represents the right gamepad stick and its tilt on the Y axis (up/down).
    { $see-also GamepadAxis }
} ;

HELP: GAMEPAD_AXIS_LEFT_TRIGGER
{ $class-description
    Represents the left gamepad trigger. Trigger has the value
    range [1..-1].
    { $see-also GamepadAxis }
} ;

HELP: GAMEPAD_AXIS_RIGHT_TRIGGER
{ $class-description
    Represents the left gamepad trigger. Trigger has the value
    range [1..-1].
    { $see-also GamepadAxis }
} ;


! Material map index enum
HELP: MaterialMapIndex
{ $var-description
    Provides convient names for each index into a texture's various
    material maps.

    { $enum-members MaterialMapIndex }
} ;
HELP: MATERIAL_MAP_ALBEDO
{ $class-description
    Represents the index for a texture's albedo material (same as: \ MATERIAL_MAP_DIFFUSE ).

    { $see-also MaterialMapIndex }
} ;

HELP: MATERIAL_MAP_METALNESS
{ $class-description
    Represents the index for a texture's metalness material (same as: \ MATERIAL_MAP_SPECULAR ).

    { $see-also MaterialMapIndex }
} ;

HELP: MATERIAL_MAP_NORMAL
{ $class-description
    Represents the index for a texture's normal material.

    { $see-also MaterialMapIndex }
} ;

HELP: MATERIAL_MAP_ROUGHNESS
{ $class-description
    Represents the index for a texture's roughness material.

    { $see-also MaterialMapIndex }
} ;

HELP: MATERIAL_MAP_OCCLUSION
{ $class-description
    Represents the index for a texture's ambient occlusion material.

    { $see-also MaterialMapIndex }
} ;

HELP: MATERIAL_MAP_EMISSION
{ $class-description
    Represents the index for a texture's emission material.

    { $see-also MaterialMapIndex }
} ;

HELP: MATERIAL_MAP_HEIGHT
{ $class-description
    Represents the index for a texture's heightmap material.

    { $see-also MaterialMapIndex }
} ;

HELP: MATERIAL_MAP_CUBEMAP
{ $class-description
    Represents the index for a texture's Cubemap material (NOTE: Uses GL_TEXTURE_CUBE_MAP).

    { $see-also MaterialMapIndex }
} ;

HELP: MATERIAL_MAP_IRRADIANCE
{ $class-description
    Represents the index for a texture's irradiance material (NOTE: Uses GL_TEXTURE_CUBE_MAP).

    { $see-also MaterialMapIndex }
} ;

HELP: MATERIAL_MAP_PREFILTER
{ $class-description
    Represents the index for a texture's prefilter material (NOTE: Uses GL_TEXTURE_CUBE_MAP).

    { $see-also MaterialMapIndex }
} ;

HELP: MATERIAL_MAP_BRDF
{ $class-description
    Represents the index for a texture's brdf material.

    { $see-also MaterialMapIndex }
} ;

! Shader Location Index
! TODO: make a better description of these. They are kinda bad...
HELP: ShaderLocationIndex
{ $var-description
    Shader location index enum.

    { $enum-members ShaderLocationIndex }
} ;

HELP: SHADER_LOC_VERTEX_POSITION
{ $class-description
    Shader location: vertex attribute: position

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_VERTEX_TEXCOORD01
{ $class-description
    Shader location: vertex attribute: texcoord01

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_VERTEX_TEXCOORD02
{ $class-description
    Shader location: vertex attribute: texcoord02

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_VERTEX_NORMAL
{ $class-description
    Shader location: vertex attribute: normal

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_VERTEX_TANGENT
{ $class-description
    Shader location: vertex attribute: tangent

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_VERTEX_COLOR
{ $class-description
    Shader location: vertex attribute: color

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_MATRIX_MVP
{ $class-description
    Shader location: matrix uniform: model-view-projection

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_MATRIX_VIEW
{ $class-description
    Shader location: matrix uniform: view (camera transform)

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_MATRIX_PROJECTION
{ $class-description
    Shader location: matrix uniform: projection

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_MATRIX_MODEL
{ $class-description
    Shader location: matrix uniform: model (transform)

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_MATRIX_NORMAL
{ $class-description
    Shader location: matrix uniform: normal

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_VECTOR_VIEW
{ $class-description
    Shader location: vector uniform: view

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_COLOR_DIFFUSE
{ $class-description
    Shader location: vector uniform: diffuse color

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_COLOR_SPECULAR
{ $class-description
    Shader location: vector uniform: specular color

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_COLOR_AMBIENT
{ $class-description
    Shader location: vector uniform: ambient color

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_MAP_ALBEDO
{ $class-description
    Shader location: sampler2d texture: albedo (same as: SHADER_LOC_MAP_DIFFUSE)

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_MAP_METALNESS
{ $class-description
    Shader location: sampler2d texture: metalness (same as: SHADER_LOC_MAP_SPECULAR)

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_MAP_NORMAL
{ $class-description
    Shader location: sampler2d texture: normal

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_MAP_ROUGHNESS
{ $class-description
    Shader location: sampler2d texture: roughness

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_MAP_OCCLUSION
{ $class-description
    Shader location: sampler2d texture: occlusion

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_MAP_EMISSION
{ $class-description
    Shader location: sampler2d texture: emission

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_MAP_HEIGHT
{ $class-description
    Shader location: sampler2d texture: height

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_MAP_CUBEMAP
{ $class-description
    Shader location: samplerCube texture: cubemap

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_MAP_IRRADIANCE
{ $class-description
    Shader location: samplerCube texture: irradiance

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_MAP_PREFILTER
{ $class-description
    Shader location: samplerCube texture: prefilter

    { $see-also ShaderLocationIndex }
} ;

HELP: SHADER_LOC_MAP_BRDF
{ $class-description
    Shader location: sampler2d texture: brdf

    { $see-also ShaderLocationIndex }
} ;



! Shader uniform data type
! TODO: Better descriptions for these...
HELP: ShaderUniformDataType
{ $var-description
    Represents the various types a uniform shader can be.

    { $enum-members MaterialMapIndex }
} ;

HELP: SHADER_UNIFORM_FLOAT
{ $class-description
    Shader uniform type: float
    { $see-also ShaderUniformDataType }
} ;

HELP: SHADER_UNIFORM_VEC2
{ $class-description
    Shader uniform type: vec2 (2 float)
    { $see-also ShaderUniformDataType }
} ;

HELP: SHADER_UNIFORM_VEC3
{ $class-description
    Shader uniform type: vec3 (3 float)
    { $see-also ShaderUniformDataType }
} ;

HELP: SHADER_UNIFORM_VEC4
{ $class-description
    Shader uniform type: vec4 (4 float)
    { $see-also ShaderUniformDataType }
} ;

HELP: SHADER_UNIFORM_INT
{ $class-description
    Shader uniform type: int
    { $see-also ShaderUniformDataType }
} ;

HELP: SHADER_UNIFORM_IVEC2
{ $class-description
    Shader uniform type: ivec2 (2 int)
    { $see-also ShaderUniformDataType }
} ;

HELP: SHADER_UNIFORM_IVEC3
{ $class-description
    Shader uniform type: ivec3 (3 int)
    { $see-also ShaderUniformDataType }
} ;

HELP: SHADER_UNIFORM_IVEC4
{ $class-description
    Shader uniform type: ivec4 (4 int)
    { $see-also ShaderUniformDataType }
} ;

HELP: SHADER_UNIFORM_SAMPLER2D
{ $class-description
    Shader uniform type: sampler2d
    { $see-also ShaderUniformDataType }
} ;


! Shader attribute data type enum
HELP: ShaderAttributeDataType
{ $var-description
    Shader attribute data types

    { $enum-members ShaderAttributeDataType }
} ;

HELP: SHADER_ATTRIB_FLOAT
{ $class-description
    Shader attribute type: float
    
    { $see-also ShaderAttributeDataType }
} ;

HELP: SHADER_ATTRIB_VEC2
{ $class-description
    Shader attribute type: vec2 (2 float)
    
    { $see-also ShaderAttributeDataType }
} ;

HELP: SHADER_ATTRIB_VEC3
{ $class-description
    Shader attribute type: vec3 (3 float)
    
    { $see-also ShaderAttributeDataType }
} ;

HELP: SHADER_ATTRIB_VEC4
{ $class-description
    Shader attribute type: vec4 (4 float)
    
    { $see-also ShaderAttributeDataType }
} ;


! Pixel format enum.
HELP: PixelFormat
{ $var-description
    The various pixel formats that can be used by Raylib.
    This enum's values start from { $snippet 1 } .

    { $warning Support depends on OpenGL version and platform. }
    { $enum-members PixelFormat }
} ;

HELP: PIXELFORMAT_UNCOMPRESSED_GRAYSCALE
{ $class-description
    8 bit per pixel (no alpha).

    { $see-also PixelFormat }
} ;

HELP: PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA
{ $class-description
    8*2 bits per pixel (2 channels).

    { $see-also PixelFormat }
} ;

HELP: PIXELFORMAT_UNCOMPRESSED_R5G6B5
{ $class-description
    16 bits per pixel.

    { $see-also PixelFormat }
} ;

HELP: PIXELFORMAT_UNCOMPRESSED_R8G8B8
{ $class-description
    24 bits per pixel.

    { $see-also PixelFormat }
} ;

HELP: PIXELFORMAT_UNCOMPRESSED_R5G5B5A1
{ $class-description
    16 bits per pixel (1 bit alpha).

    { $see-also PixelFormat }
} ;

HELP: PIXELFORMAT_UNCOMPRESSED_R4G4B4A4
{ $class-description
    16 bits per pixel (4 bit alpha).

    { $see-also PixelFormat }
} ;

HELP: PIXELFORMAT_UNCOMPRESSED_R8G8B8A8
{ $class-description
    32 bits per pixel.

    { $see-also PixelFormat }
} ;

HELP: PIXELFORMAT_UNCOMPRESSED_R32
{ $class-description
    32 bits per pixel (1 channel - float).

    { $see-also PixelFormat }
} ;

HELP: PIXELFORMAT_UNCOMPRESSED_R32G32B32
{ $class-description
    32*3 bits per pixel (3 channels - float).

    { $see-also PixelFormat }
} ;

HELP: PIXELFORMAT_UNCOMPRESSED_R32G32B32A32
{ $class-description
    32*4 bits per pixel (4 channels - float).

    { $see-also PixelFormat }
} ;

HELP: PIXELFORMAT_COMPRESSED_DXT1_RGB
{ $class-description
    4 bits per pixel (no alpha).

    { $see-also PixelFormat }
} ;

HELP: PIXELFORMAT_COMPRESSED_DXT1_RGBA
{ $class-description
    4 bits per pixel (1 bit alpha).

    { $see-also PixelFormat }
} ;

HELP: PIXELFORMAT_COMPRESSED_DXT3_RGBA
{ $class-description
    8 bits per pixel.

    { $see-also PixelFormat }
} ;

HELP: PIXELFORMAT_COMPRESSED_DXT5_RGBA
{ $class-description
    8 bits per pixel.

    { $see-also PixelFormat }
} ;

HELP: PIXELFORMAT_COMPRESSED_ETC1_RGB
{ $class-description
    4 bits per pixel.

    { $see-also PixelFormat }
} ;

HELP: PIXELFORMAT_COMPRESSED_ETC2_RGB
{ $class-description
    4 bits per pixel.

    { $see-also PixelFormat }
} ;

HELP: PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA
{ $class-description
    8 bits per pixel.

    { $see-also PixelFormat }
} ;

HELP: PIXELFORMAT_COMPRESSED_PVRT_RGB
{ $class-description
    4 bits per pixel.

    { $see-also PixelFormat }
} ;

HELP: PIXELFORMAT_COMPRESSED_PVRT_RGBA
{ $class-description
    4 bits per pixel.

    { $see-also PixelFormat }
} ;

HELP: PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA
{ $class-description
    8 bits per pixel.

    { $see-also PixelFormat }
} ;

HELP: PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA
{ $class-description
    2 bits per pixel.

    { $see-also PixelFormat }
} ;


! Texture filter mode enum
HELP: TextureFilterMode
{ $var-description
    Controls the filter mode of the texture. In Raylib, filtering will
    consider mipmaps if available in the current texture. Additionally,
    filter is accordingly set for minification and magnification.

    { $enum-members TextureFilterMode }
} ;

HELP: TEXTURE_FILTER_POINT
{ $class-description
    No filter just pixel aproximation.

    { $see-also TextureFilterMode }
} ;

HELP: TEXTURE_FILTER_BILINEAR
{ $class-description
    Linear filtering.

    { $see-also TextureFilterMode }
} ;

HELP: TEXTURE_FILTER_TRILINEAR
{ $class-description
    Trilinear filtering (linear with mipmaps).

    { $see-also TextureFilterMode }
} ;

HELP: TEXTURE_FILTER_ANISOTROPIC_4X
{ $class-description
    Anisotropic filtering 4x.

    { $see-also TextureFilterMode }
} ;

HELP: TEXTURE_FILTER_ANISOTROPIC_8X
{ $class-description
    Anisotropic filtering 8x.

    { $see-also TextureFilterMode }
} ;

HELP: TEXTURE_FILTER_ANISOTROPIC_16X
{ $class-description
    Anisotropic filtering 16x.

    { $see-also TextureFilterMode }
} ;


! Texture wrap mode enume
HELP: TextureWrapMode
{ $var-description
    Represents the way a texture will repeate when reading
    past the image bounds.

    { $enum-members TextureWrapMode }
} ;

HELP: TEXTURE_WRAP_REPEAT
{ $class-description
    Using this mode, a texture will repeate infinitely in all directions.

    { $see-also TextureWrapMode }
} ;

HELP: TEXTURE_WRAP_CLAMP
{ $class-description
    Using this mode, the edge pixels in a texture will
    be stretched out into infinity.

    { $see-also TextureWrapMode }
} ;

HELP:
TEXTURE_WRAP_MIRROR_REPEAT
{ $class-description
    Using this mode, the texture will repeat infinitely in all directions.
    However, each tiling will be mirrored compared to the previous tiling.


    { $see-also TextureWrapMode }
} ;

HELP: TEXTURE_WRAP_MIRROR_CLAMP
{ $class-description
    This mode combines mirrored with clamped. The texture will infinitely
    tile the last pixel from the oppisite side.

    { $see-also TextureWrapMode }
} ;


! Cubemap layout enum
HELP: CubemapLayout
{ $var-description
    Represents the layout a cube map is using.

    { $enum-members CubemapLayout }
} ;

HELP: CUBEMAP_LAYOUT_AUTO_DETECT
{ $class-description
    Raylib will attempt to automatically detect the cubemap's layout type.

    { $see-also CubemapLayout }
} ;

HELP: CUBEMAP_LAYOUT_LINE_VERTICAL
{ $class-description
    A cubemap who's layout is defined by a horizontal line with faces.

    { $see-also CubemapLayout }
} ;

HELP: CUBEMAP_LAYOUT_LINE_HORIZONTAL
{ $class-description
    A cubemap who's layout is defined by a vertical line with faces.

    { $see-also CubemapLayout }
} ;

HELP: CUBEMAP_LAYOUT_CROSS_THREE_BY_FOUR
{ $class-description
    A cubemap who's layout is defined by a 3x4 cross with cubemap faces.

    { $see-also CubemapLayout }
} ;

HELP: CUBEMAP_LAYOUT_CROSS_FOUR_BY_THREE
{ $class-description
    A cubemap who's layout is defined by a 4x3 cross with cubemap faces.

    { $see-also CubemapLayout }
} ;

HELP: CUBEMAP_LAYOUT_PANORAMA
{ $class-description
    A cubemap who's layout is defined by a panoramic image (equirectangular map).

    { $see-also CubemapLayout }
} ;


! font type enum
HELP: FontType
{ $var-description
    A C-enum defining the various font generation methods in Raylib.

    { $enum-members FontType }
} ;

HELP: FONT_DEFAULT
{ $class-description
    Default font generation with anti-aliasing.

    { $see-also FontType }
} ;

HELP: FONT_BITMAP
{ $class-description
    Bitmap font generation without anti-aliasing.

    { $see-also FontType }
} ;

HELP: FONT_SDF
{ $class-description
    SDF font generation. Requires an external shader.

    { $see-also FontType }
} ;


! Blend mode enum
HELP: BlendMode
{ $var-description
    A C-enum holding the OpenGL texture blend modes.


    { $enum-members BlendMode }
} ;

HELP: BLEND_ALPHA
{ $class-description
    Blend mode for blending texturing while considering the alpha channel.
    This is the default mode.
    { $see-also BlendMode }
} ;

HELP: BLEND_ADDITIVE
{ $class-description
    Blend mode for blending textures while adding colors
    { $see-also BlendMode }
} ;

HELP: BLEND_MULTIPLIED
{ $class-description
    Blend mode for blending textures while multiplying colors.
    { $see-also BlendMode }
} ;

HELP: BLEND_ADD_COLORS
{ $class-description
    Alternative blend mode to \ BLEND_ADDITIVE
    { $see-also BlendMode }
} ;

HELP: BLEND_SUBTRACT_COLORS
{ $class-description
    Blend mode for blending textures while subtracting colors.
    { $see-also BlendMode }
} ;

HELP: BLEND_ALPHA_PREMULTIPLY
{ $class-description
    Blend mode for blending premultipled textures while considering the alpha channel
    { $see-also BlendMode }
} ;

HELP: BLEND_CUSTOM
{ $class-description
    Blend mode for using custom src/dst factors. This is intended for use with
    { $snippet rl-set-blend-factors } from { $vocab-link "rlgl" } .
    { $see-also BlendMode }
} ;

HELP: BLEND_CUSTOM_SEPARATE
{ $class-description
    Blend mode for using custom rgb/alpha seperate src/dst
    factors. This is intended for use with { $snippet rl-set-blend-factors-seperate }
    from { $vocab-link "rlgl" } .
    { $see-also BlendMode }
} ;


! Gestures enum
HELP: Gestures
{ $var-description
    Represents the various touch gestures Raylib supports.
    This enum is a set of bitflags to enable desired
    gestures individually.

    { $enum-members Gestures }
} ;

HELP: GESTURE_NONE
{ $class-description
    Used as the empty set of gestures.

    Has the value: { $snippet 0 }
    { $see-also Gestures }
} ;

HELP: GESTURE_TAP
{ $class-description
    Represents a tap gesture.

    Has the value: { $snippet 1 }
    { $see-also Gestures }
} ;

HELP: GESTURE_DOUBLETAP
{ $class-description
    Represents a double tap gesture.

    Has the value: { $snippet 2 }
    { $see-also Gestures }
} ;

HELP: GESTURE_HOLD
{ $class-description
    Represents a hold gesture.

    Has the value: { $snippet 4 }
    { $see-also Gestures }
} ;

HELP: GESTURE_DRAG
{ $class-description
    Represents a drag gesture.

    Has the value: { $snippet 8 }
    { $see-also Gestures }
} ;
HELP: GESTURE_SWIPE_RIGHT
{ $class-description
    Represents a swipe to the right.

    Has the value: { $snippet 16 }
    { $see-also Gestures }
} ;

HELP: GESTURE_SWIPE_LEFT
{ $class-description
    Represents a swipe to the left

    Has the value: { $snippet 32 }
    { $see-also Gestures }
} ;

HELP: GESTURE_SWIPE_UP
{ $class-description
    Represents a swap upwards.

    Has the value: { $snippet 64 }
    { $see-also Gestures }
} ;

HELP: GESTURE_SWIPE_DOWN
{ $class-description
    Represents a swap downwards.

    Has the value: { $snippet 128 }
    { $see-also Gestures }
} ;

HELP: GESTURE_PINCH_IN
{ $class-description
    Represents a inwards pinch.

    Has the value: { $snippet 256 }
    { $see-also Gestures }
} ;

HELP: GESTURE_PINCH_OUT
{ $class-description
    Represents a outwards pinch.

    Has the value: { $snippet 512 }
    { $see-also Gestures }
} ;


! Camera mode enum
HELP: CameraMode
{ $var-description
    The various modes a camera can behave in Raylib.

    { $enum-members CameraMode }
} ;

HELP: CAMERA_CUSTOM
{ $class-description
    A 3D camera with custom behavior.

    { $see-also CameraMode }
} ;

HELP: CAMERA_FREE
{ $class-description
    A \ Camera3D with unrestricted movement.

    { $see-also CameraMode }
} ;

HELP: CAMERA_ORBITAL
{ $class-description
    A \ Camera3D that will orbit a fixed point in 3D space.

    { $see-also CameraMode }
} ;

HELP: CAMERA_FIRST_PERSON
{ $class-description
    A \ Camera3D that cannot roll and looked on the up-axis.

    { $see-also CameraMode }
} ;

HELP: CAMERA_THIRD_PERSON
{ $class-description
    Similiar to \ CAMERA_FIRST_PERSON , however the camera is focused
    to a target point.

    { $see-also CameraMode }
} ;


! Camera projection enum
HELP: CameraProjection
{ $var-description
    Represents the projects a camera can use.

    { $enum-members CameraProjection }
} ;

HELP: CAMERA_PERSPECTIVE
{ $class-description
    Sets a \ Camera3D to use a perspective projection.

    { $see-also CameraProjection }
} ;

HELP: CAMERA_ORTHOGRAPHIC
{ $class-description
    Sets a \ Camera3D to use an orthographic projection. Parallel lines
    will stay parallel in this projection.

    { $see-also CameraProjection }
} ;


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
    { $enum-members NPatchLayout }
} ;

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

    { $see-also NPatchLayout }
} ;

HELP: NPATCH_THREE_PATCH_VERTICAL
{ $class-description
    Represents a 1x3 tiling that can be stretched vertically.

    { $see-also NPatchLayout }
} ;

HELP: NPATCH_THREE_PATCH_HORIZONTAL
{ $class-description
    Represents a 3x1 tiling that can be streched vertically.

    { $see-also NPatchLayout }
} ;



HELP: AudioCallback
{ $values
    { "quot" quotation }
    { "alien" object }
}
{ $description "" } ;

HELP: AudioStream
{ $class-description
    Represents a stream of audio data in Raylib.
    { $table
        { { $snippet buffer }     " a pointer to the internal data used by the audio system." }
        { { $snippet processor }  " a pointer to the interanl data processor, useful for audio effects." }
        { { $snippet sampleRate } " the frequence of the samples." }
        { { $snippet sampleSize } " the bit depth of the samples: spport values are 8, 16, and 32." }
        { { $snippet channels }   " the number of channels: 1 for mono, 2 for stereo." }
    }
} ;


HELP: Color
{ $class-description
    Represents a RGBA color with 8-bit unsigned components.
    Raylibe comes with 25 default colors.

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
        RAYWHITE }
} ;



HELP: Camera3D
{ $class-description
    Represents a camera in 3D space. The fields are defined as followed:
    { $table
        { { $snippet position   } " is the camera position in 3D space." }
        { { $snippet target     } " is the target the camera is looking at." }
        { { $snippet up         } " is the direction that faces up relative to the camera." }
        { { $snippet fovy       } " is the camera's field of view aperature in degrees. Used as the near-plane for orthogrphic projections." }
        { { $snippet projection } " is the camera's projection:" { $link CAMERA_PERSPECTIVE } " or " { $link CAMERA_ORTHOGRAPHIC } }
    }
} ;

HELP: Camera2D
{ $class-description
    Represents a camera in 2D space. The fields are defined
    as followed:
    { $table
        { { $snippet offset   } " is the camera offset (dispacement from target)" }
        { { $snippet target   } " is the camera target (rotation and zoom origin)." }
        { { $snippet rotation } " is the camera rotation in degrees." }
        { { $snippet zoom     } " is the camera zoom/scalling, should be 1.0f by default." }
    }
} ;

HELP: Camera
{ $var-description
    A c-typedef alias for \ Camera3D .
} ;




HELP: BoneInfo
{ $class-description
    A skeletal animation bone.
    { $table
        { { $snippet name }     " is the name of the bone. Max 32 characters." }
        { { $snippet processor }  " the parent index." }
    }
} ;

HELP: BoundingBox
{ $class-description
    Represents a 3D bounding box defined by two points:
    { $table
        { { $snippet min }  " The minimum vertex box-corner." }
        { { $snippet max }  " The maxium vertex box-corner." }
    } } ;





HELP: FilePathList
{ $class-description
    A list of file paths returned from \ load-directory-files ,
    \ load-directory-files-ex . Must be freed with
    \ unload-directory-files .

    The fields are defined as followed:
    { $table
        { { $snippet capacity } " the max number of entries." }
        { { $snippet count } " the number of entries found." }
        { { $snippet paths } " array of string where each member is a file path." }
    }

    { $see-also
        load-directory-files
        load-directory-files-ex
        unload-directory-files
    }
} ;

HELP: Font
{ $class-description
    Represents a collections of glyphs that can be drawn to the screen.
    The fields are defined as followed:

    { $table
        { { $snippet baseSize     } { " the base size of the characters. This is how tall a glyph is." } }
        { { $snippet glyphCount   } { " the number of glyph characters." } }
        { { $snippet glyphPadding } { " the padding around each glyph." } }
        { { $snippet texture      } { " the texture atlas continaing the glyphs." } }
        { { $snippet recs         } { " an array of rectangles used to find each glyph in " { $snippet texture } "." } }
        { { $snippet glyphs       } { " metadata about each glyph." } }
    }

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
