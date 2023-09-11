! Copyright (C) 2023 CapitalEx.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel quotations urls ;
IN: raylib

<PRIVATE
: $related-subsections ( element -- )
    [ related-words ] [ $subsections ] bi ;

: $enum-members ( element -- )
    "Enum members" $heading $related-subsections ;

: $raylib-color ( element -- )
    "Word description" $heading
    { { "value" Color } } $values
    "Represents the color (" print-element print-element ")" print-element
    "\n\n" print-element
    "For a visual guide, see the following:\n" print-element
    { "https://raw.githubusercontent.com/raysan5/raylib/master/examples/shapes/shapes_colors_palette.png" }
        $url ;


PRIVATE>

HELP: &unload-audio-stream
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: &unload-file-data
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: &unload-file-text
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: &unload-font
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: &unload-image
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: &unload-image-colors
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: &unload-image-palette
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: &unload-material
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: &unload-mesh
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: &unload-model
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: &unload-model-animation
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: &unload-music-stream
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: &unload-render-texture
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: &unload-shader
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: &unload-sound
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: &unload-texture
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: &unload-wave
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: <BlendMode>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <CameraMode>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <CameraProjection>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <ConfigFlags>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <CubemapLayout>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <FontType>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <GamepadAxis>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <GamepadButton>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <Gestures>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <KeyboardKey>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <MaterialMapIndex>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <MouseButton>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <MouseCursor>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <NPatchLayout>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <PixelFormat>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <ShaderAttributeDataType>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <ShaderLocationIndex>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <ShaderUniformDataType>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <TextureFilterMode>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <TextureWrapMode>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <TraceLogLevel>
{ $values
    { "number" object }
    { "enum" object }
}
{ $description "" } ;

HELP: <Vector2>
{ $values
    { "x" object } { "y" object }
    { "obj" object }
}
{ $description "" } ;

HELP: <Vector3>
{ $values
    { "x" object } { "y" object } { "z" object }
    { "obj" object }
}
{ $description "" } ;

HELP: <Vector4>
{ $values
    { "x" object } { "y" object } { "z" object } { "w" object }
    { "obj" object }
}
{ $description "" } ;

HELP: <unload-audio-stream-destructor>
{ $values
    { "alien" object }
    { "destructor" object }
}
{ $description "" } ;

HELP: <unload-file-data-destructor>
{ $values
    { "alien" object }
    { "destructor" object }
}
{ $description "" } ;

HELP: <unload-file-text-destructor>
{ $values
    { "alien" object }
    { "destructor" object }
}
{ $description "" } ;

HELP: <unload-font-destructor>
{ $values
    { "alien" object }
    { "destructor" object }
}
{ $description "" } ;

HELP: <unload-image-colors-destructor>
{ $values
    { "alien" object }
    { "destructor" object }
}
{ $description "" } ;

HELP: <unload-image-destructor>
{ $values
    { "alien" object }
    { "destructor" object }
}
{ $description "" } ;

HELP: <unload-image-palette-destructor>
{ $values
    { "alien" object }
    { "destructor" object }
}
{ $description "" } ;

HELP: <unload-material-destructor>
{ $values
    { "alien" object }
    { "destructor" object }
}
{ $description "" } ;

HELP: <unload-mesh-destructor>
{ $values
    { "alien" object }
    { "destructor" object }
}
{ $description "" } ;

HELP: <unload-model-animation-destructor>
{ $values
    { "alien" object }
    { "destructor" object }
}
{ $description "" } ;

HELP: <unload-model-destructor>
{ $values
    { "alien" object }
    { "destructor" object }
}
{ $description "" } ;

HELP: <unload-music-stream-destructor>
{ $values
    { "alien" object }
    { "destructor" object }
}
{ $description "" } ;

HELP: <unload-render-texture-destructor>
{ $values
    { "alien" object }
    { "destructor" object }
}
{ $description "" } ;

HELP: <unload-shader-destructor>
{ $values
    { "alien" object }
    { "destructor" object }
}
{ $description "" } ;

HELP: <unload-sound-destructor>
{ $values
    { "alien" object }
    { "destructor" object }
}
{ $description "" } ;

HELP: <unload-texture-destructor>
{ $values
    { "alien" object }
    { "destructor" object }
}
{ $description "" } ;

HELP: <unload-wave-destructor>
{ $values
    { "alien" object }
    { "destructor" object }
}
{ $description "" } ;

HELP: AudioCallback
{ $values
    { "quot" quotation }
    { "alien" object }
}
{ $description "" } ;

HELP: AudioStream
{ $class-description 
    Represents a stream of audio data in Raylib.
    { $list
        { { $snippet buffer }     " a pointer to the internal data used by the audio system." }
        { { $snippet processor }  " a pointer to the interanl data processor, useful for audio effects." }
        { { $snippet sampleRate } " the frequence of the samples." }
        { { $snippet sampleSize } " the bit depth of the samples: spport values are 8, 16, and 32." }
        { { $snippet channels }   " the number of channels: 1 for mono, 2 for stereo." }
    }
} ;

HELP: BEIGE
{ $values
    { "value" Color }
}
{ $description 
    Represents the RGBA color (211, 176, 131, 255).


    See, the following reference for a visual guide:
    
    { $url "https://raw.githubusercontent.com/raysan5/raylib/master/examples/shapes/shapes_colors_palette.png" }
} ;

HELP: BLACK
{ $values
    { "value" object }
}
{ $description
    Represents the RGBA color (0, 0, 0, 255).

    
    See, the following reference for a visual guide:
    { $url "https://raw.githubusercontent.com/raysan5/raylib/master/examples/shapes/shapes_colors_palette.png" }
} ;

HELP: BLANK
{ $values
    { "value" object }
}
{ $description 
    Represents the RGBA color (0, 0, 0, 0).

    
    See, the following reference for a visual guide:
    { $url "https://raw.githubusercontent.com/raysan5/raylib/master/examples/shapes/shapes_colors_palette.png" }
} ;

HELP: BLEND_ADDITIVE
{ $class-description 
    Blend mode for blending textures while adding colors
} ;

HELP: BLEND_ADD_COLORS
{ $class-description 
    Alternative blend mode to \ BLEND_ADDITIVE 
} ;

HELP: BLEND_ALPHA
{ $class-description 
    Blend mode for blending texturing while considering the alpha channel.
    This is the default mode.
} ;

HELP: BLEND_ALPHA_PREMULTIPLY
{ $class-description 
    Blend mode for blending premultipled textures while considering the alpha channel
} ;

HELP: BLEND_CUSTOM
{ $class-description 
    Blend mode for using custom src/dst factors. This is intended for use with
    { $snippet rl-set-blend-factors } from { $vocab-link "rlgl" } .
} ;

HELP: BLEND_CUSTOM_SEPARATE
{ $class-description 
    Blend mode for using custom rgb/alpha seperate src/dst 
    factors. This is intended for use with { $snippet rl-set-blend-factors-seperate } 
    from { $vocab-link "rlgl" } .
} ;

HELP: BLEND_MULTIPLIED
{ $class-description 
    Blend mode for blending textures while multiplying colors.
} ;

HELP: BLEND_SUBTRACT_COLORS
{ $class-description 
    Blend mode for blending textures while subtracting colors.
} ;

HELP: BLUE
{ $values
    { "value" Color }
}
{ $description 
    Represents the RGBA color (0, 121, 241, 255).

    
    See, the following reference for a visual guide:
    
    { $url "https://raw.githubusercontent.com/raysan5/raylib/master/examples/shapes/shapes_colors_palette.png" }
} ;

HELP: BROWN
{ $values
    { "value" Color }
}
{ $description 
    Represents the RGBA color (127, 106, 79, 255).

    
    See, the following reference for a visual guide:
    
    { $url "https://raw.githubusercontent.com/raysan5/raylib/master/examples/shapes/shapes_colors_palette.png" }
} ;

HELP: BlendMode
{ $var-description 
    A C-enum holding the OpenGL texture blend modes.

    
    { $enum-members 
        BLEND_ALPHA
        BLEND_ADDITIVE
        BLEND_MULTIPLIED
        BLEND_ADD_COLORS
        BLEND_SUBTRACT_COLORS
        BLEND_ALPHA_PREMULTIPLY
        BLEND_CUSTOM
        BLEND_CUSTOM_SEPARATE }
} ;

HELP: BoneInfo
{ $class-description 
    A skeletal animation bone.
    { $list
        { { $snippet name }     " is the name of the bone. Max 32 characters." }
        { { $snippet processor }  " the parent index." }
    }
} ;

HELP: BoundingBox
{ $class-description 
    Represents a 3D bounding box defined by two points:
    { $list
        { { $snippet min }     " The minimum vertex box-corner." }
        { { $snippet max }  " The maxium vertex box-corner." }
    } } ;

HELP: CAMERA_CUSTOM
{ $class-description 
    A 3D camera with custom behavior.

    { $see-also CameraMode }
} ;

HELP: CAMERA_FIRST_PERSON
{ $class-description 
    A \ Camera3D that cannot roll and looked on the up-axis.

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

HELP: CAMERA_ORTHOGRAPHIC
{ $class-description 
    Sets a \ Camera3D to use an orthographic projection. Parallel lines 
    will stay parallel in this projection.

    { $see-also CameraProjection }
} ;

HELP: CAMERA_PERSPECTIVE
{ $class-description 
    Sets a \ Camera3D to use a perspective projection.

    { $see-also CameraProjection }
} ;

HELP: CAMERA_THIRD_PERSON
{ $class-description 
    Similiar to \ CAMERA_FIRST_PERSON , however the camera is focused
    to a target point.

    { $see-also CameraMode }
} ;

HELP: CUBEMAP_LAYOUT_AUTO_DETECT
{ $class-description 
    Raylib will attempt to automatically detect the cubemap's layout type.

    { $see-also CubemapLayout }
} ;

HELP: CUBEMAP_LAYOUT_CROSS_FOUR_BY_THREE
{ $class-description 
    A cubemap who's layout is defined by a 4x3 cross with cubemap faces.

    { $see-also CubemapLayout }
} ;

HELP: CUBEMAP_LAYOUT_CROSS_THREE_BY_FOUR
{ $class-description 
    A cubemap who's layout is defined by a 3x4 cross with cubemap faces.

    { $see-also CubemapLayout }
} ;

HELP: CUBEMAP_LAYOUT_LINE_HORIZONTAL
{ $class-description 
    A cubemap who's layout is defined by a vertical line with faces.

    { $see-also CubemapLayout }
} ;

HELP: CUBEMAP_LAYOUT_LINE_VERTICAL
{ $class-description 
    A cubemap who's layout is defined by a horizontal line with faces.

    { $see-also CubemapLayout }
} ;

HELP: CUBEMAP_LAYOUT_PANORAMA
{ $class-description 
    A cubemap who's layout is defined by a panoramic image (equirectangular map).

    { $see-also CubemapLayout }
} ;

HELP: Camera
{ $var-description 
    A c-typedef alias for \ Camera3D .
} ;

HELP: Camera2D
{ $class-description 
    Represents a camera in 2D space. The fields are defined
    as followed:
    { $list 
        { { $snippet offset   } " is the camera offset (dispacement from target)" } 
        { { $snippet target   } " is the camera target (rotation and zoom origin)." }
        { { $snippet rotation } " is the camera rotation in degrees." }
        { { $snippet zoom     } " is the camera zoom/scalling, should be 1.0f by default." }
    }
} ;

HELP: Camera3D
{ $class-description 
    Represents a camera in 3D space. The fields are defined as followed:
    { $list 
        { { $snippet position   } " is the camera position in 3D space." }  
        { { $snippet target     } " is the target the camera is looking at." }
        { { $snippet up         } " is the direction that faces up relative to the camera." }
        { { $snippet fovy       } " is the camera's field of view aperature in degrees. Used as the near-plane for orthogrphic projections." }
        { { $snippet projection } " is the camera's projection:" { $link CAMERA_PERSPECTIVE } " or " { $link CAMERA_ORTHOGRAPHIC } }     
    } 
} ;

HELP: CameraMode
{ $var-description 
    The various modes a camera can behave in Raylib.

    { $enum-members
        CAMERA_CUSTOM
        CAMERA_FREE
        CAMERA_ORBITAL
        CAMERA_FIRST_PERSON
        CAMERA_THIRD_PERSON }
} ;

HELP: CameraProjection
{ $var-description "" } ;

HELP: Color
{ $class-description 
    Represents a RGBA color with 8-bit unsigned components.
    Raylibe comes with 25 default colors.
    
    { $heading Builtin colors }
    { $related-subsections 
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

HELP: ConfigFlags
{ $var-description 
    An enum representing the configuration flags raylib has
     
    { $enum-members
        FLAG_VSYNC_HINT
        FLAG_FULLSCREEN_MODE
        FLAG_WINDOW_RESIZABLE
        FLAG_WINDOW_UNDECORATED
        FLAG_WINDOW_HIDDEN
        FLAG_WINDOW_MINIMIZED
        FLAG_WINDOW_MAXIMIZED
        FLAG_WINDOW_UNFOCUSED
        FLAG_WINDOW_TOPMOST
        FLAG_WINDOW_ALWAYS_RUN
        FLAG_WINDOW_TRANSPARENT
        FLAG_WINDOW_HIDDEN
        FLAG_MSAA_4X_HINT
        FLAG_INTERLACED_HINT
    } 
} ;

HELP: CubemapLayout
{ $var-description
    Represents the layout a cube map is using.

    { $enum-members
        CUBEMAP_LAYOUT_AUTO_DETECT
        CUBEMAP_LAYOUT_LINE_VERTICAL
        CUBEMAP_LAYOUT_LINE_HORIZONTAL
        CUBEMAP_LAYOUT_CROSS_THREE_BY_FOUR
        CUBEMAP_LAYOUT_CROSS_FOUR_BY_THREE
        CUBEMAP_LAYOUT_PANORAMA
    }    
} ;

HELP: DARKBLUE   { $raylib-color "0, 82, 172, 255" } ;
HELP: DARKBROWN  { $raylib-color "76, 63, 47, 255" } ;
HELP: DARKGRAY   { $raylib-color "80, 80, 80, 255" } ;
HELP: DARKGREEN  { $raylib-color "0, 117, 44, 255" } ;
HELP: DARKPURPLE { $raylib-color "112, 31, 126, 255" } ;

HELP: FLAG_FULLSCREEN_MODE
{ $class-description 
    Setting this flag will run the program in fullscreen
} ;

HELP: FLAG_INTERLACED_HINT
{ $class-description
    Setting this flag will attempt to enable the interlaced video
    format for V3D.
} ;

HELP: FLAG_MSAA_4X_HINT
{ $class-description
    Setting this flag will attempt to enable MSAA 4x
} ;

HELP: FLAG_VSYNC_HINT
{ $class-description
    Setting this flag will attempt to enable v-sync on the GPU.
} ;

HELP: FLAG_WINDOW_ALWAYS_RUN
{ $class-description
    Setting this flag allows the window to run while minimized.
} ;

HELP: FLAG_WINDOW_HIDDEN
{ $class-description
    Setting this flag will hide the window. 
} ;

HELP: FLAG_WINDOW_HIGHDPI
{ $class-description
    Setting this flag will enable HighDPI support.
} ;

HELP: FLAG_WINDOW_MAXIMIZED
{ $class-description
    Setting this flag will maximize the window to the monitor size.
} ;

HELP: FLAG_WINDOW_MINIMIZED
{ $class-description
    Setting this flag will minize the window.
} ;

HELP: FLAG_WINDOW_RESIZABLE
{ $class-description
    Setting this flag allows for resizing the window.
} ;

HELP: FLAG_WINDOW_TOPMOST
{ $class-description
    Setting this flag sets the window to always be on top.
} ;

HELP: FLAG_WINDOW_TRANSPARENT
{ $class-description
    Setting this flag allows for transparent framebuffer.
} ;

HELP: FLAG_WINDOW_UNDECORATED
{ $class-description
    Setting this flag remove window decorations (frame and buttons)
} ;

HELP: FLAG_WINDOW_UNFOCUSED
{ $class-description
    Setting this flag will set the window to be unfocused.
} ;

HELP: FONT_BITMAP
{ $class-description 
    Bitmap font generation without anti-aliasing.
} ;

HELP: FONT_DEFAULT
{ $class-description
    Default font generation with anti-aliasing.
} ;

HELP: FONT_SDF
{ $class-description 
    SDF font generation. Requires an external shader.
} ;

HELP: FilePathList
{ $class-description
    A list of file paths returned from \ load-directory-files ,
    \ load-directory-files-ex . Must be freed with 
    \ unload-directory-files .

    The fields are defined as followed:
    { $list 
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

    { $list
        { { $snippet baseSize     } { " the base size of the characters. This is how tall a glyph is." } }
        { { $snippet glyphCount   } { " the number of glyph characters." } }
        { { $snippet glyphPadding } { " the padding around each glyph." } }
        { { $snippet texture      } { " the texture atlas continaing the glyphs." } }
        { { $snippet recs         } { " an array of rectangles used to find each glyph in " { $snippet texture } "." } }
        { { $snippet glyphs       } { " metadata about each glyph." } }
    }

} ;

HELP: FontType
{ $var-description 
    A C-enum defining the various font generation methods in Raylib.

    { $enum-members
        FONT_DEFAULT
        FONT_BITMAP
        FONT_SDF
    }
} ;

HELP: GAMEPAD_AXIS_LEFT_TRIGGER
{ $class-description 
    Represents the left gamepad trigger. Trigger has the value 
    range [1..-1]. 
} ;

HELP: GAMEPAD_AXIS_LEFT_X
{ $class-description 
    Represents the left gamepad stick and its tilt on the X axis (left/right).
} ;

HELP: GAMEPAD_AXIS_LEFT_Y
{ $class-description 
    Represents the left gamepad stick and its tilt on the Y axis (up/down).
} ;

HELP: GAMEPAD_AXIS_RIGHT_TRIGGER
{ $class-description 
    Represents the left gamepad trigger. Trigger has the value
    range [1..-1].
} ;

HELP: GAMEPAD_AXIS_RIGHT_X
{ $class-description 
    Represents the right gamepad stick and its tilt on the X axis (left/right).
} ;

HELP: GAMEPAD_AXIS_RIGHT_Y
{ $class-description
    Represents the right gamepad stick and its tilt on the Y axis (up/down).
} ;

HELP: GAMEPAD_BUTTON_LEFT_FACE_DOWN
{ $class-description "" } ;

HELP: GAMEPAD_BUTTON_LEFT_FACE_LEFT
{ $class-description "" } ;

HELP: GAMEPAD_BUTTON_LEFT_FACE_RIGHT
{ $class-description "" } ;

HELP: GAMEPAD_BUTTON_LEFT_FACE_UP
{ $class-description "" } ;

HELP: GAMEPAD_BUTTON_LEFT_THUMB
{ $class-description "" } ;

HELP: GAMEPAD_BUTTON_LEFT_TRIGGER_1
{ $class-description "" } ;

HELP: GAMEPAD_BUTTON_LEFT_TRIGGER_2
{ $class-description "" } ;

HELP: GAMEPAD_BUTTON_MIDDLE
{ $class-description "" } ;

HELP: GAMEPAD_BUTTON_MIDDLE_LEFT
{ $class-description "" } ;

HELP: GAMEPAD_BUTTON_MIDDLE_RIGHT
{ $class-description "" } ;

HELP: GAMEPAD_BUTTON_RIGHT_FACE_DOWN
{ $class-description "" } ;

HELP: GAMEPAD_BUTTON_RIGHT_FACE_LEFT
{ $class-description "" } ;

HELP: GAMEPAD_BUTTON_RIGHT_FACE_RIGHT
{ $class-description "" } ;

HELP: GAMEPAD_BUTTON_RIGHT_FACE_UP
{ $class-description "" } ;

HELP: GAMEPAD_BUTTON_RIGHT_THUMB
{ $class-description "" } ;

HELP: GAMEPAD_BUTTON_RIGHT_TRIGGER_1
{ $class-description "" } ;

HELP: GAMEPAD_BUTTON_RIGHT_TRIGGER_2
{ $class-description "" } ;

HELP: GAMEPAD_BUTTON_UNKNOWN
{ $class-description "" } ;

HELP: GESTURE_DOUBLETAP
{ $class-description "" } ;

HELP: GESTURE_DRAG
{ $class-description "" } ;

HELP: GESTURE_HOLD
{ $class-description "" } ;

HELP: GESTURE_NONE
{ $class-description "" } ;

HELP: GESTURE_PINCH_IN
{ $class-description "" } ;

HELP: GESTURE_PINCH_OUT
{ $class-description "" } ;

HELP: GESTURE_SWIPE_DOWN
{ $class-description "" } ;

HELP: GESTURE_SWIPE_LEFT
{ $class-description "" } ;

HELP: GESTURE_SWIPE_RIGHT
{ $class-description "" } ;

HELP: GESTURE_SWIPE_UP
{ $class-description "" } ;

HELP: GESTURE_TAP
{ $class-description "" } ;

HELP: GOLD { $raylib-color "255, 203, 0, 255" } ;
HELP: GRAY { $raylib-color "130, 130, 130, 255" } ;
HELP: GREEN { $raylib-color "0, 228, 48, 255" } ;

HELP: GamepadAxis
{ $var-description 
    Contains a set of flags for each axis a gamepad may have. Raylib 
    supports controllers with two triggers and two joysticks.

    { $enum-members 
        GAMEPAD_AXIS_LEFT_X              
        GAMEPAD_AXIS_LEFT_Y                
        GAMEPAD_AXIS_RIGHT_X               
        GAMEPAD_AXIS_RIGHT_Y               
        GAMEPAD_AXIS_LEFT_TRIGGER 
        GAMEPAD_AXIS_RIGHT_TRIGGER
    }
} ;

HELP: GamepadButton
{ $var-description "" } ;

HELP: Gestures
{ $var-description "" } ;

HELP: GlyphInfo
{ $class-description "" } ;

HELP: Image
{ $class-description "" } ;

HELP: KEY_A
{ $class-description "" } ;

HELP: KEY_APOSTROPHE
{ $class-description "" } ;

HELP: KEY_B
{ $class-description "" } ;

HELP: KEY_BACK
{ $class-description "" } ;

HELP: KEY_BACKSLASH
{ $class-description "" } ;

HELP: KEY_BACKSPACE
{ $class-description "" } ;

HELP: KEY_C
{ $class-description "" } ;

HELP: KEY_CAPS_LOCK
{ $class-description "" } ;

HELP: KEY_COMMA
{ $class-description "" } ;

HELP: KEY_D
{ $class-description "" } ;

HELP: KEY_DELETE
{ $class-description "" } ;

HELP: KEY_DOWN
{ $class-description "" } ;

HELP: KEY_E
{ $class-description "" } ;

HELP: KEY_EIGHT
{ $class-description "" } ;

HELP: KEY_END
{ $class-description "" } ;

HELP: KEY_ENTER
{ $class-description "" } ;

HELP: KEY_EQUAL
{ $class-description "" } ;

HELP: KEY_ESCAPE
{ $class-description "" } ;

HELP: KEY_F
{ $class-description "" } ;

HELP: KEY_F1
{ $class-description "" } ;

HELP: KEY_F10
{ $class-description "" } ;

HELP: KEY_F11
{ $class-description "" } ;

HELP: KEY_F12
{ $class-description "" } ;

HELP: KEY_F2
{ $class-description "" } ;

HELP: KEY_F3
{ $class-description "" } ;

HELP: KEY_F4
{ $class-description "" } ;

HELP: KEY_F5
{ $class-description "" } ;

HELP: KEY_F6
{ $class-description "" } ;

HELP: KEY_F7
{ $class-description "" } ;

HELP: KEY_F8
{ $class-description "" } ;

HELP: KEY_F9
{ $class-description "" } ;

HELP: KEY_FIVE
{ $class-description "" } ;

HELP: KEY_FOUR
{ $class-description "" } ;

HELP: KEY_G
{ $class-description "" } ;

HELP: KEY_GRAVE
{ $class-description "" } ;

HELP: KEY_H
{ $class-description "" } ;

HELP: KEY_HOME
{ $class-description "" } ;

HELP: KEY_I
{ $class-description "" } ;

HELP: KEY_INSERT
{ $class-description "" } ;

HELP: KEY_J
{ $class-description "" } ;

HELP: KEY_K
{ $class-description "" } ;

HELP: KEY_KB_MENU
{ $class-description "" } ;

HELP: KEY_KP_0
{ $class-description "" } ;

HELP: KEY_KP_1
{ $class-description "" } ;

HELP: KEY_KP_2
{ $class-description "" } ;

HELP: KEY_KP_3
{ $class-description "" } ;

HELP: KEY_KP_4
{ $class-description "" } ;

HELP: KEY_KP_5
{ $class-description "" } ;

HELP: KEY_KP_6
{ $class-description "" } ;

HELP: KEY_KP_7
{ $class-description "" } ;

HELP: KEY_KP_8
{ $class-description "" } ;

HELP: KEY_KP_9
{ $class-description "" } ;

HELP: KEY_KP_ADD
{ $class-description "" } ;

HELP: KEY_KP_DECIMAL
{ $class-description "" } ;

HELP: KEY_KP_DIVIDE
{ $class-description "" } ;

HELP: KEY_KP_ENTER
{ $class-description "" } ;

HELP: KEY_KP_EQUAL
{ $class-description "" } ;

HELP: KEY_KP_MULTIPLY
{ $class-description "" } ;

HELP: KEY_KP_SUBTRACT
{ $class-description "" } ;

HELP: KEY_L
{ $class-description "" } ;

HELP: KEY_LEFT
{ $class-description "" } ;

HELP: KEY_LEFT_ALT
{ $class-description "" } ;

HELP: KEY_LEFT_BRACKET
{ $class-description "" } ;

HELP: KEY_LEFT_CONTROL
{ $class-description "" } ;

HELP: KEY_LEFT_SHIFT
{ $class-description "" } ;

HELP: KEY_LEFT_SUPER
{ $class-description "" } ;

HELP: KEY_M
{ $class-description "" } ;

HELP: KEY_MENU
{ $class-description "" } ;

HELP: KEY_MINUS
{ $class-description "" } ;

HELP: KEY_N
{ $class-description "" } ;

HELP: KEY_NINE
{ $class-description "" } ;

HELP: KEY_NULL
{ $class-description "" } ;

HELP: KEY_NUM_LOCK
{ $class-description "" } ;

HELP: KEY_O
{ $class-description "" } ;

HELP: KEY_ONE
{ $class-description "" } ;

HELP: KEY_P
{ $class-description "" } ;

HELP: KEY_PAGE_DOWN
{ $class-description "" } ;

HELP: KEY_PAGE_UP
{ $class-description "" } ;

HELP: KEY_PAUSE
{ $class-description "" } ;

HELP: KEY_PERIOD
{ $class-description "" } ;

HELP: KEY_PRINT_SCREEN
{ $class-description "" } ;

HELP: KEY_Q
{ $class-description "" } ;

HELP: KEY_R
{ $class-description "" } ;

HELP: KEY_RIGHT
{ $class-description "" } ;

HELP: KEY_RIGHT_ALT
{ $class-description "" } ;

HELP: KEY_RIGHT_BRACKET
{ $class-description "" } ;

HELP: KEY_RIGHT_CONTROL
{ $class-description "" } ;

HELP: KEY_RIGHT_SHIFT
{ $class-description "" } ;

HELP: KEY_RIGHT_SUPER
{ $class-description "" } ;

HELP: KEY_S
{ $class-description "" } ;

HELP: KEY_SCROLL_LOCK
{ $class-description "" } ;

HELP: KEY_SEMICOLON
{ $class-description "" } ;

HELP: KEY_SEVEN
{ $class-description "" } ;

HELP: KEY_SIX
{ $class-description "" } ;

HELP: KEY_SLASH
{ $class-description "" } ;

HELP: KEY_SPACE
{ $class-description "" } ;

HELP: KEY_T
{ $class-description "" } ;

HELP: KEY_TAB
{ $class-description "" } ;

HELP: KEY_THREE
{ $class-description "" } ;

HELP: KEY_TWO
{ $class-description "" } ;

HELP: KEY_U
{ $class-description "" } ;

HELP: KEY_UP
{ $class-description "" } ;

HELP: KEY_V
{ $class-description "" } ;

HELP: KEY_VOLUME_DOWN
{ $class-description "" } ;

HELP: KEY_VOLUME_UP
{ $class-description "" } ;

HELP: KEY_W
{ $class-description "" } ;

HELP: KEY_X
{ $class-description "" } ;

HELP: KEY_Y
{ $class-description "" } ;

HELP: KEY_Z
{ $class-description "" } ;

HELP: KEY_ZERO
{ $class-description "" } ;

HELP: KeyboardKey
{ $var-description "" } ;

HELP: LIGHTGRAY
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: LIME
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: LOG_ALL
{ $class-description "" } ;

HELP: LOG_DEBUG
{ $class-description "" } ;

HELP: LOG_ERROR
{ $class-description "" } ;

HELP: LOG_FATAL
{ $class-description "" } ;

HELP: LOG_INFO
{ $class-description "" } ;

HELP: LOG_NONE
{ $class-description "" } ;

HELP: LOG_TRACE
{ $class-description "" } ;

HELP: LOG_WARNING
{ $class-description "" } ;

HELP: MAGENTA
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: MAROON
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: MATERIAL_MAP_ALBEDO
{ $class-description "" } ;

HELP: MATERIAL_MAP_BRDF
{ $class-description "" } ;

HELP: MATERIAL_MAP_CUBEMAP
{ $class-description "" } ;

HELP: MATERIAL_MAP_DIFFUSE
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: MATERIAL_MAP_EMISSION
{ $class-description "" } ;

HELP: MATERIAL_MAP_HEIGHT
{ $class-description "" } ;

HELP: MATERIAL_MAP_IRRADIANCE
{ $class-description "" } ;

HELP: MATERIAL_MAP_METALNESS
{ $class-description "" } ;

HELP: MATERIAL_MAP_NORMAL
{ $class-description "" } ;

HELP: MATERIAL_MAP_OCCLUSION
{ $class-description "" } ;

HELP: MATERIAL_MAP_PREFILTER
{ $class-description "" } ;

HELP: MATERIAL_MAP_ROUGHNESS
{ $class-description "" } ;

HELP: MATERIAL_MAP_SPECULAR
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: MAX_MATERIAL_MAPS
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: MOUSE_BUTTON_BACK
{ $class-description "" } ;

HELP: MOUSE_BUTTON_EXTRA
{ $class-description "" } ;

HELP: MOUSE_BUTTON_FORWARD
{ $class-description "" } ;

HELP: MOUSE_BUTTON_LEFT
{ $class-description "" } ;

HELP: MOUSE_BUTTON_MIDDLE
{ $class-description "" } ;

HELP: MOUSE_BUTTON_RIGHT
{ $class-description "" } ;

HELP: MOUSE_BUTTON_SIDE
{ $class-description "" } ;

HELP: MOUSE_CURSOR_ARROW
{ $class-description "" } ;

HELP: MOUSE_CURSOR_CROSSHAIR
{ $class-description "" } ;

HELP: MOUSE_CURSOR_DEFAULT
{ $class-description "" } ;

HELP: MOUSE_CURSOR_IBEAM
{ $class-description "" } ;

HELP: MOUSE_CURSOR_NOT_ALLOWED
{ $class-description "" } ;

HELP: MOUSE_CURSOR_POINTING_HAND
{ $class-description "" } ;

HELP: MOUSE_CURSOR_RESIZE_ALL
{ $class-description "" } ;

HELP: MOUSE_CURSOR_RESIZE_EW
{ $class-description "" } ;

HELP: MOUSE_CURSOR_RESIZE_NESW
{ $class-description "" } ;

HELP: MOUSE_CURSOR_RESIZE_NS
{ $class-description "" } ;

HELP: MOUSE_CURSOR_RESIZE_NWSE
{ $class-description "" } ;

HELP: Material
{ $class-description "" } ;

HELP: MaterialMap
{ $class-description "" } ;

HELP: MaterialMapIndex
{ $var-description "" } ;

HELP: Matrix
{ $class-description "" } ;

HELP: Mesh
{ $class-description "" } ;

HELP: Model
{ $class-description "" } ;

HELP: ModelAnimation
{ $class-description "" } ;

HELP: MouseButton
{ $var-description "" } ;

HELP: MouseCursor
{ $var-description "" } ;

HELP: Music
{ $class-description "" } ;

HELP: NPATCH_NINE_PATCH
{ $class-description "" } ;

HELP: NPATCH_THREE_PATCH_HORIZONTAL
{ $class-description "" } ;

HELP: NPATCH_THREE_PATCH_VERTICAL
{ $class-description "" } ;

HELP: NPatchInfo
{ $class-description "" } ;

HELP: NPatchLayout
{ $var-description "" } ;

HELP: ORANGE
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: PINK
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA
{ $class-description "" } ;

HELP: PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA
{ $class-description "" } ;

HELP: PIXELFORMAT_COMPRESSED_DXT1_RGB
{ $class-description "" } ;

HELP: PIXELFORMAT_COMPRESSED_DXT1_RGBA
{ $class-description "" } ;

HELP: PIXELFORMAT_COMPRESSED_DXT3_RGBA
{ $class-description "" } ;

HELP: PIXELFORMAT_COMPRESSED_DXT5_RGBA
{ $class-description "" } ;

HELP: PIXELFORMAT_COMPRESSED_ETC1_RGB
{ $class-description "" } ;

HELP: PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA
{ $class-description "" } ;

HELP: PIXELFORMAT_COMPRESSED_ETC2_RGB
{ $class-description "" } ;

HELP: PIXELFORMAT_COMPRESSED_PVRT_RGB
{ $class-description "" } ;

HELP: PIXELFORMAT_COMPRESSED_PVRT_RGBA
{ $class-description "" } ;

HELP: PIXELFORMAT_UNCOMPRESSED_GRAYSCALE
{ $class-description "" } ;

HELP: PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA
{ $class-description "" } ;

HELP: PIXELFORMAT_UNCOMPRESSED_R32
{ $class-description "" } ;

HELP: PIXELFORMAT_UNCOMPRESSED_R32G32B32
{ $class-description "" } ;

HELP: PIXELFORMAT_UNCOMPRESSED_R32G32B32A32
{ $class-description "" } ;

HELP: PIXELFORMAT_UNCOMPRESSED_R4G4B4A4
{ $class-description "" } ;

HELP: PIXELFORMAT_UNCOMPRESSED_R5G5B5A1
{ $class-description "" } ;

HELP: PIXELFORMAT_UNCOMPRESSED_R5G6B5
{ $class-description "" } ;

HELP: PIXELFORMAT_UNCOMPRESSED_R8G8B8
{ $class-description "" } ;

HELP: PIXELFORMAT_UNCOMPRESSED_R8G8B8A8
{ $class-description "" } ;

HELP: PURPLE
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: PixelFormat
{ $var-description "" } ;

HELP: Quaternion
{ $var-description "" } ;

HELP: RAYLIB_VERSION
{ $values
    { "value" string }
}
{ $description "A string representing the current version of raylib." } ;

HELP: RAYLIB_VERSION_MAJOR
{ $values
    { "value" fixnum }
}
{ $description "The current major version of raylib." } ;

HELP: RAYLIB_VERSION_MINOR
{ $values
    { "value" fixnum }
}
{ $description "The current minor version of raylib." } ;

HELP: RAYLIB_VERSION_PATCH
{ $values
    { "value" fixnum }
}
{ $description "The current patch version of raylib." } ;

HELP: RAYWHITE
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: RED
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: Ray
{ $class-description "" } ;

HELP: RayCollision
{ $class-description "" } ;

HELP: Rectangle
{ $class-description "" } ;

HELP: RenderTexture
{ $var-description "" } ;

HELP: RenderTexture2D
{ $class-description "" } ;

HELP: SHADER_ATTRIB_FLOAT
{ $class-description "" } ;

HELP: SHADER_ATTRIB_VEC2
{ $class-description "" } ;

HELP: SHADER_ATTRIB_VEC3
{ $class-description "" } ;

HELP: SHADER_ATTRIB_VEC4
{ $class-description "" } ;

HELP: SHADER_LOC_COLOR_AMBIENT
{ $class-description "" } ;

HELP: SHADER_LOC_COLOR_DIFFUSE
{ $class-description "" } ;

HELP: SHADER_LOC_COLOR_SPECULAR
{ $class-description "" } ;

HELP: SHADER_LOC_MAP_ALBEDO
{ $class-description "" } ;

HELP: SHADER_LOC_MAP_BRDF
{ $class-description "" } ;

HELP: SHADER_LOC_MAP_CUBEMAP
{ $class-description "" } ;

HELP: SHADER_LOC_MAP_DIFFUSE
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: SHADER_LOC_MAP_EMISSION
{ $class-description "" } ;

HELP: SHADER_LOC_MAP_HEIGHT
{ $class-description "" } ;

HELP: SHADER_LOC_MAP_IRRADIANCE
{ $class-description "" } ;

HELP: SHADER_LOC_MAP_METALNESS
{ $class-description "" } ;

HELP: SHADER_LOC_MAP_NORMAL
{ $class-description "" } ;

HELP: SHADER_LOC_MAP_OCCLUSION
{ $class-description "" } ;

HELP: SHADER_LOC_MAP_PREFILTER
{ $class-description "" } ;

HELP: SHADER_LOC_MAP_ROUGHNESS
{ $class-description "" } ;

HELP: SHADER_LOC_MAP_SPECULAR
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: SHADER_LOC_MATRIX_MODEL
{ $class-description "" } ;

HELP: SHADER_LOC_MATRIX_MVP
{ $class-description "" } ;

HELP: SHADER_LOC_MATRIX_NORMAL
{ $class-description "" } ;

HELP: SHADER_LOC_MATRIX_PROJECTION
{ $class-description "" } ;

HELP: SHADER_LOC_MATRIX_VIEW
{ $class-description "" } ;

HELP: SHADER_LOC_VECTOR_VIEW
{ $class-description "" } ;

HELP: SHADER_LOC_VERTEX_COLOR
{ $class-description "" } ;

HELP: SHADER_LOC_VERTEX_NORMAL
{ $class-description "" } ;

HELP: SHADER_LOC_VERTEX_POSITION
{ $class-description "" } ;

HELP: SHADER_LOC_VERTEX_TANGENT
{ $class-description "" } ;

HELP: SHADER_LOC_VERTEX_TEXCOORD01
{ $class-description "" } ;

HELP: SHADER_LOC_VERTEX_TEXCOORD02
{ $class-description "" } ;

HELP: SHADER_UNIFORM_FLOAT
{ $class-description "" } ;

HELP: SHADER_UNIFORM_INT
{ $class-description "" } ;

HELP: SHADER_UNIFORM_IVEC2
{ $class-description "" } ;

HELP: SHADER_UNIFORM_IVEC3
{ $class-description "" } ;

HELP: SHADER_UNIFORM_IVEC4
{ $class-description "" } ;

HELP: SHADER_UNIFORM_SAMPLER2D
{ $class-description "" } ;

HELP: SHADER_UNIFORM_VEC2
{ $class-description "" } ;

HELP: SHADER_UNIFORM_VEC3
{ $class-description "" } ;

HELP: SHADER_UNIFORM_VEC4
{ $class-description "" } ;

HELP: SKYBLUE
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: Shader
{ $class-description "" } ;

HELP: ShaderAttributeDataType
{ $var-description "" } ;

HELP: ShaderLocationIndex
{ $var-description "" } ;

HELP: ShaderUniformDataType
{ $var-description "" } ;

HELP: Sound
{ $class-description "" } ;

HELP: SpriteFont
{ $var-description "" } ;

HELP: TEXTURE_FILTER_ANISOTROPIC_16X
{ $class-description "" } ;

HELP: TEXTURE_FILTER_ANISOTROPIC_4X
{ $class-description "" } ;

HELP: TEXTURE_FILTER_ANISOTROPIC_8X
{ $class-description "" } ;

HELP: TEXTURE_FILTER_BILINEAR
{ $class-description "" } ;

HELP: TEXTURE_FILTER_POINT
{ $class-description "" } ;

HELP: TEXTURE_FILTER_TRILINEAR
{ $class-description "" } ;

HELP: TEXTURE_WRAP_CLAMP
{ $class-description "" } ;

HELP: TEXTURE_WRAP_MIRROR_CLAMP
{ $class-description "" } ;

HELP: TEXTURE_WRAP_MIRROR_REPEAT
{ $class-description "" } ;

HELP: TEXTURE_WRAP_REPEAT
{ $class-description "" } ;

HELP: Texture
{ $var-description "" } ;

HELP: Texture2D
{ $class-description "" } ;

HELP: TextureCubemap
{ $var-description "" } ;

HELP: TextureFilterMode
{ $var-description "" } ;

HELP: TextureWrapMode
{ $var-description "" } ;

HELP: TraceLogLevel
{ $var-description "" } ;

HELP: Transform
{ $class-description "" } ;

HELP: VIOLET
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: Vector2
{ $class-description "" } ;

HELP: Vector3
{ $class-description "" } ;

HELP: Vector4
{ $class-description "" } ;

HELP: VrDeviceInfo
{ $class-description "" } ;

HELP: VrStereoConfig
{ $class-description "" } ;

HELP: WHITE
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: Wave
{ $class-description "" } ;

HELP: YELLOW
{ $values
    { "value" object }
}
{ $description "" } ;

HELP: attach-audio-mixed-processor
{ $values
    { "processor" object }
}
{ $description "" } ;

HELP: attach-audio-stream-processor
{ $values
    { "stream" object } { "processor" object }
}
{ $description "" } ;

HELP: begin-blend-mode
{ $values
    { "mode" object }
}
{ $description "" } ;

HELP: begin-drawing
{ $description "" } ;

HELP: begin-mode-2d
{ $values
    { "camera" object }
}
{ $description "" } ;

HELP: begin-mode-3d
{ $values
    { "camera" object }
}
{ $description "" } ;

HELP: begin-scissor-mode
{ $values
    { "x" object } { "y" object } { "width" object } { "height" object }
}
{ $description "" } ;

HELP: begin-shader-mode
{ $values
    { "shader" object }
}
{ $description "" } ;

HELP: begin-texture-mode
{ $values
    { "target" object }
}
{ $description "" } ;

HELP: begin-vr-stereo-mode
{ $values
    { "config" object }
}
{ $description "" } ;

HELP: change-directory
{ $values
    { "dir" object }
    { "bool" object }
}
{ $description "" } ;

HELP: check-collision-box-sphere
{ $values
    { "box" object } { "center" object } { "radius" object }
    { "bool" object }
}
{ $description "" } ;

HELP: check-collision-boxes
{ $values
    { "box1" object } { "box2" object }
    { "bool" object }
}
{ $description "" } ;

HELP: check-collision-circle-rec
{ $values
    { "center" object } { "radius" object } { "rec" object }
    { "bool" object }
}
{ $description "" } ;

HELP: check-collision-circles
{ $values
    { "center1" object } { "radius1" object } { "center2" object } { "radius2" object }
    { "bool" object }
}
{ $description "" } ;

HELP: check-collision-lines
{ $values
    { "startPos1" object } { "endPos1" object } { "startPos2" object } { "endPos2" object } { "collisionPoint" object }
    { "bool" object }
}
{ $description "" } ;

HELP: check-collision-point-circle
{ $values
    { "point" object } { "center" object } { "radius" object }
    { "bool" object }
}
{ $description "" } ;

HELP: check-collision-point-line
{ $values
    { "point" object } { "p1" object } { "p2" object } { "threshold" object }
    { "bool" object }
}
{ $description "" } ;

HELP: check-collision-point-poly
{ $values
    { "point" object } { "points" object } { "pointCount" object }
    { "bool" object }
}
{ $description "" } ;

HELP: check-collision-point-rec
{ $values
    { "point" object } { "rec" object }
    { "bool" object }
}
{ $description "" } ;

HELP: check-collision-point-triangle
{ $values
    { "point" object } { "p1" object } { "p2" object } { "p3" object }
    { "bool" object }
}
{ $description "" } ;

HELP: check-collision-recs
{ $values
    { "rec1" object } { "rec2" object }
    { "bool" object }
}
{ $description "" } ;

HELP: check-collision-spheres
{ $values
    { "center1" object } { "radius1" object } { "center2" object } { "radius2" object }
    { "bool" object }
}
{ $description "" } ;

HELP: clear-background
{ $values
    { "color" object }
}
{ $description "" } ;

HELP: clear-window-state
{ $values
    { "flags" object }
}
{ $description "" } ;

HELP: close-audio-device
{ $description "" } ;

HELP: close-window
{ $description "" } ;

HELP: codepoint-to-utf8
{ $values
    { "codepoint" object } { "byteSize" object }
    { "c-string" object }
}
{ $description "" } ;

HELP: color-alpha
{ $values
    { "color" object } { "alpha" object }
    { "Color" object }
}
{ $description "" } ;

HELP: color-alpha-blend
{ $values
    { "dst" object } { "src" object } { "tint" object }
    { "Color" object }
}
{ $description "" } ;

HELP: color-brightness
{ $values
    { "color" object } { "factor" object }
    { "Color" object }
}
{ $description "" } ;

HELP: color-contrast
{ $values
    { "color" object } { "contrast" object }
    { "Color" object }
}
{ $description "" } ;

HELP: color-from-hsv
{ $values
    { "hue" object } { "saturation" object } { "value" object }
    { "Color" object }
}
{ $description "" } ;

HELP: color-from-normalized
{ $values
    { "normalized" object }
    { "Color" object }
}
{ $description "" } ;

HELP: color-normalize
{ $values
    { "color" object }
    { "Vector4" object }
}
{ $description "" } ;

HELP: color-tint
{ $values
    { "color" object } { "tint" object }
    { "Color" object }
}
{ $description "" } ;

HELP: color-to-hsv
{ $values
    { "color" object }
    { "Vector3" object }
}
{ $description "" } ;

HELP: color-to-int
{ $values
    { "color" object }
    { "int" object }
}
{ $description "" } ;

HELP: compress-data
{ $values
    { "data" object } { "dataLength" object } { "compDataLength" object }
    { "uchar*" object }
}
{ $description "" } ;

HELP: decode-data-base64
{ $values
    { "data" object } { "outputLength" object }
    { "uchar*" object }
}
{ $description "" } ;

HELP: decompress-data
{ $values
    { "compData" object } { "compDataLength" object } { "dataLength" object }
    { "uchar*" object }
}
{ $description "" } ;

HELP: detach-audio-mixed-processor
{ $values
    { "processor" object }
}
{ $description "" } ;

HELP: detach-audio-stream-processor
{ $values
    { "stream" object } { "processor" object }
}
{ $description "" } ;

HELP: directory-exists
{ $values
    { "dirPath" object }
    { "bool" object }
}
{ $description "" } ;

HELP: disable-cursor
{ $description "" } ;

HELP: disable-event-waiting
{ $description "" } ;

HELP: draw-billboard
{ $values
    { "camera" object } { "texture" object } { "position" object } { "size" object } { "tint" object }
}
{ $description "" } ;

HELP: draw-billboard-pro
{ $values
    { "camera" object } { "texture" object } { "source" object } { "position" object } { "up" object } { "size" object } { "origin" object } { "rotation" object } { "tint" object }
}
{ $description "" } ;

HELP: draw-billboard-rec
{ $values
    { "camera" object } { "texture" object } { "source" object } { "position" object } { "size" object } { "tint" object }
}
{ $description "" } ;

HELP: draw-bounding-box
{ $values
    { "box" object } { "color" object }
}
{ $description "" } ;

HELP: draw-capsule
{ $values
    { "startPos" object } { "endPos" object } { "radius" object } { "slices" object } { "rings" object } { "color" object }
}
{ $description "" } ;

HELP: draw-capsule-wires
{ $values
    { "startPos" object } { "endPos" object } { "radius" object } { "slices" object } { "rings" object } { "color" object }
}
{ $description "" } ;

HELP: draw-circle
{ $values
    { "centerX" object } { "centerY" object } { "radius" object } { "color" object }
}
{ $description "" } ;

HELP: draw-circle-3d
{ $values
    { "center" object } { "radius" object } { "rotationAxis" object } { "rotationAngle" object } { "color" object }
}
{ $description "" } ;

HELP: draw-circle-gradient
{ $values
    { "centerX" object } { "centerY" object } { "radius" object } { "color1" object } { "color2" object }
}
{ $description "" } ;

HELP: draw-circle-lines
{ $values
    { "centerX" object } { "centerY" object } { "radius" object } { "color" object }
}
{ $description "" } ;

HELP: draw-circle-sector
{ $values
    { "center" object } { "radius" object } { "startAngle" object } { "endAngle" object } { "segments" object } { "color" object }
}
{ $description "" } ;

HELP: draw-circle-sector-lines
{ $values
    { "center" object } { "radius" object } { "startAngle" object } { "endAngle" object } { "segments" object } { "color" object }
}
{ $description "" } ;

HELP: draw-circle-v
{ $values
    { "center" object } { "radius" object } { "color" object }
}
{ $description "" } ;

HELP: draw-cube
{ $values
    { "position" object } { "width" object } { "height" object } { "length" object } { "color" object }
}
{ $description "" } ;

HELP: draw-cube-v
{ $values
    { "position" object } { "size" object } { "color" object }
}
{ $description "" } ;

HELP: draw-cube-wires
{ $values
    { "position" object } { "width" object } { "height" object } { "length" object } { "color" object }
}
{ $description "" } ;

HELP: draw-cube-wires-v
{ $values
    { "position" object } { "size" object } { "color" object }
}
{ $description "" } ;

HELP: draw-cylinder
{ $values
    { "position" object } { "radiusTop" object } { "radiusBottom" object } { "height" object } { "slices" object } { "color" object }
}
{ $description "" } ;

HELP: draw-cylinder-ex
{ $values
    { "startPos" object } { "endPos" object } { "startRadius" object } { "endRadius" object } { "sides" object } { "color" object }
}
{ $description "" } ;

HELP: draw-cylinder-wires
{ $values
    { "position" object } { "radiusTop" object } { "radiusBottom" object } { "height" object } { "slices" object } { "color" object }
}
{ $description "" } ;

HELP: draw-cylinder-wires-ex
{ $values
    { "startPos" object } { "endPos" object } { "startRadius" object } { "endRadius" object } { "sides" object } { "color" object }
}
{ $description "" } ;

HELP: draw-ellipse
{ $values
    { "centerX" object } { "centerY" object } { "radiusH" object } { "radiusV" object } { "color" object }
}
{ $description "" } ;

HELP: draw-ellipse-lines
{ $values
    { "centerX" object } { "centerY" object } { "radiusH" object } { "radiusV" object } { "color" object }
}
{ $description "" } ;

HELP: draw-fps
{ $values
    { "posX" object } { "posY" object }
}
{ $description "" } ;

HELP: draw-grid
{ $values
    { "slices" object } { "spacing" object }
}
{ $description "" } ;

HELP: draw-line
{ $values
    { "startPosX" object } { "startPosY" object } { "endPosX" object } { "endPosY" object } { "color" object }
}
{ $description "" } ;

HELP: draw-line-3d
{ $values
    { "startPos" object } { "endPos" object } { "color" object }
}
{ $description "" } ;

HELP: draw-line-bezier
{ $values
    { "startPos" object } { "endPos" object } { "thick" object } { "color" object }
}
{ $description "" } ;

HELP: draw-line-bezier-cubic
{ $values
    { "startPos" object } { "endPos" object } { "startControlPos" object } { "endControlPos" object } { "thick" object } { "color" object }
}
{ $description "" } ;

HELP: draw-line-bezier-quad
{ $values
    { "startPos" object } { "endPos" object } { "controlPos" object } { "thick" object } { "color" object }
}
{ $description "" } ;

HELP: draw-line-ex
{ $values
    { "startPos" object } { "endPos" object } { "thick" object } { "color" object }
}
{ $description "" } ;

HELP: draw-line-strip
{ $values
    { "points" object } { "pointCount" object } { "color" object }
}
{ $description "" } ;

HELP: draw-line-v
{ $values
    { "startPos" object } { "endPos" object } { "color" object }
}
{ $description "" } ;

HELP: draw-mesh
{ $values
    { "mesh" object } { "material" object } { "transform" object }
}
{ $description "" } ;

HELP: draw-mesh-instanced
{ $values
    { "mesh" object } { "material" object } { "transforms" object } { "instances" object }
}
{ $description "" } ;

HELP: draw-model
{ $values
    { "model" object } { "position" object } { "scale" object } { "tint" object }
}
{ $description "" } ;

HELP: draw-model-ex
{ $values
    { "model" object } { "position" object } { "rotationAxis" object } { "rotationAngle" object } { "scale" object } { "tint" object }
}
{ $description "" } ;

HELP: draw-model-wires
{ $values
    { "model" object } { "position" object } { "scale" object } { "tint" object }
}
{ $description "" } ;

HELP: draw-model-wires-ex
{ $values
    { "model" object } { "position" object } { "rotationAxis" object } { "rotationAngle" object } { "scale" object } { "tint" object }
}
{ $description "" } ;

HELP: draw-pixel
{ $values
    { "posX" object } { "posY" object } { "color" object }
}
{ $description "" } ;

HELP: draw-pixel-v
{ $values
    { "position" object } { "color" object }
}
{ $description "" } ;

HELP: draw-plane
{ $values
    { "centerPos" object } { "size" object } { "color" object }
}
{ $description "" } ;

HELP: draw-point-3d
{ $values
    { "position" object } { "color" object }
}
{ $description "" } ;

HELP: draw-poly
{ $values
    { "center" object } { "sides" object } { "radius" object } { "rotation" object } { "color" object }
}
{ $description "" } ;

HELP: draw-poly-lines
{ $values
    { "center" object } { "sides" object } { "radius" object } { "rotation" object } { "color" object }
}
{ $description "" } ;

HELP: draw-poly-lines-ex
{ $values
    { "center" object } { "sides" object } { "radius" object } { "rotation" object } { "lineThick" object } { "color" object }
}
{ $description "" } ;

HELP: draw-ray
{ $values
    { "ray" object } { "color" object }
}
{ $description "" } ;

HELP: draw-rectangle
{ $values
    { "posX" object } { "posY" object } { "width" object } { "height" object } { "color" object }
}
{ $description "" } ;

HELP: draw-rectangle-gradient-ex
{ $values
    { "rec" object } { "col1" object } { "col2" object } { "col3" object } { "col4" object }
}
{ $description "" } ;

HELP: draw-rectangle-gradient-h
{ $values
    { "posX" object } { "posY" object } { "width" object } { "height" object } { "color1" object } { "color2" object }
}
{ $description "" } ;

HELP: draw-rectangle-gradient-v
{ $values
    { "posX" object } { "posY" object } { "width" object } { "height" object } { "color1" object } { "color2" object }
}
{ $description "" } ;

HELP: draw-rectangle-lines
{ $values
    { "posX" object } { "posY" object } { "width" object } { "height" object } { "color" object }
}
{ $description "" } ;

HELP: draw-rectangle-lines-ex
{ $values
    { "rec" object } { "lineThick" object } { "color" object }
}
{ $description "" } ;

HELP: draw-rectangle-pro
{ $values
    { "rec" object } { "origin" object } { "rotation" object } { "color" object }
}
{ $description "" } ;

HELP: draw-rectangle-rec
{ $values
    { "rec" object } { "color" object }
}
{ $description "" } ;

HELP: draw-rectangle-rounded
{ $values
    { "rec" object } { "roundness" object } { "segments" object } { "color" object }
}
{ $description "" } ;

HELP: draw-rectangle-rounded-lines
{ $values
    { "rec" object } { "roundness" object } { "segments" object } { "lineThick" object } { "color" object }
}
{ $description "" } ;

HELP: draw-rectangle-v
{ $values
    { "position" object } { "size" object } { "color" object }
}
{ $description "" } ;

HELP: draw-ring
{ $values
    { "center" object } { "innerRadius" object } { "outerRadius" object } { "startAngle" object } { "endAngle" object } { "segments" object } { "color" object }
}
{ $description "" } ;

HELP: draw-ring-lines
{ $values
    { "center" object } { "innerRadius" object } { "outerRadius" object } { "startAngle" object } { "endAngle" object } { "segments" object } { "color" object }
}
{ $description "" } ;

HELP: draw-sphere
{ $values
    { "centerPos" object } { "radius" object } { "color" object }
}
{ $description "" } ;

HELP: draw-sphere-ex
{ $values
    { "centerPos" object } { "radius" object } { "rings" object } { "slices" object } { "color" object }
}
{ $description "" } ;

HELP: draw-sphere-wires
{ $values
    { "centerPos" object } { "radius" object } { "rings" object } { "slices" object } { "color" object }
}
{ $description "" } ;

HELP: draw-text
{ $values
    { "text" object } { "posX" object } { "posY" object } { "fontSize" object } { "color" object }
}
{ $description "" } ;

HELP: draw-text-codepoint
{ $values
    { "font" object } { "codepoint" object } { "position" object } { "fontSize" object } { "tint" object }
}
{ $description "" } ;

HELP: draw-text-codepoints
{ $values
    { "font" object } { "codepoint" object } { "count" object } { "position" object } { "fontSize" object } { "spacing" object } { "tint" object }
}
{ $description "" } ;

HELP: draw-text-ex
{ $values
    { "font" object } { "text" object } { "position" object } { "fontSize" object } { "spacing" object } { "tint" object }
}
{ $description "" } ;

HELP: draw-text-pro
{ $values
    { "font" object } { "text" object } { "position" object } { "origin" object } { "rotation" object } { "fontSize" object } { "spacing" object } { "tint" object }
}
{ $description "" } ;

HELP: draw-texture
{ $values
    { "texture" object } { "posX" object } { "posY" object } { "tint" object }
}
{ $description "" } ;

HELP: draw-texture-ex
{ $values
    { "texture" object } { "position" object } { "rotation" object } { "scale" object } { "tint" object }
}
{ $description "" } ;

HELP: draw-texture-npatch
{ $values
    { "texture" object } { "nPatchInfo" object } { "dest" object } { "origin" object } { "rotation" object } { "tint" object }
}
{ $description "" } ;

HELP: draw-texture-pro
{ $values
    { "texture" object } { "source" object } { "dest" object } { "origin" object } { "rotation" object } { "tint" object }
}
{ $description "" } ;

HELP: draw-texture-rec
{ $values
    { "texture" object } { "source" object } { "position" object } { "tint" object }
}
{ $description "" } ;

HELP: draw-texture-v
{ $values
    { "texture" object } { "position" object } { "tint" object }
}
{ $description "" } ;

HELP: draw-triangle
{ $values
    { "v1" object } { "v2" object } { "v3" object } { "color" object }
}
{ $description "" } ;

HELP: draw-triangle-3d
{ $values
    { "v1" object } { "v2" object } { "v3" object } { "color" object }
}
{ $description "" } ;

HELP: draw-triangle-fan
{ $values
    { "points" object } { "pointCount" object } { "color" object }
}
{ $description "" } ;

HELP: draw-triangle-lines
{ $values
    { "v1" object } { "v2" object } { "v3" object } { "color" object }
}
{ $description "" } ;

HELP: draw-triangle-strip
{ $values
    { "points" object } { "pointCount" object } { "color" object }
}
{ $description "" } ;

HELP: draw-triangle-strip-3d
{ $values
    { "points" object } { "pointCount" object } { "color" object }
}
{ $description "" } ;

HELP: enable-cursor
{ $description "" } ;

HELP: enable-event-waiting
{ $description "" } ;

HELP: encode-data-base64
{ $values
    { "data" object } { "dataLength" object } { "outputLength" object }
    { "c-string" object }
}
{ $description "" } ;

HELP: end-blend-mode
{ $description "" } ;

HELP: end-drawing
{ $description "" } ;

HELP: end-mode-2d
{ $description "" } ;

HELP: end-mode-3d
{ $description "" } ;

HELP: end-scissor-mode
{ $description "" } ;

HELP: end-shader-mode
{ $description "" } ;

HELP: end-texture-mode
{ $description "" } ;

HELP: end-vr-stereo-mode
{ $description "" } ;

HELP: export-data-as-code
{ $values
    { "data" object } { "size" object } { "fileName" object }
    { "bool" object }
}
{ $description "" } ;

HELP: export-font-as-code
{ $values
    { "font" object } { "fileName" object }
    { "bool" object }
}
{ $description "" } ;

HELP: export-image
{ $values
    { "image" object } { "fileName" object }
    { "bool" object }
}
{ $description "" } ;

HELP: export-image-as-code
{ $values
    { "image" object } { "fileName" object }
    { "bool" object }
}
{ $description "" } ;

HELP: export-mesh
{ $values
    { "mesh" object } { "fileName" object }
    { "bool" object }
}
{ $description "" } ;

HELP: export-wave
{ $values
    { "wave" object } { "fileName" object }
    { "bool" object }
}
{ $description "" } ;

HELP: export-wave-as-code
{ $values
    { "wave" object } { "fileName" object }
    { "bool" object }
}
{ $description "" } ;

HELP: fade
{ $values
    { "color" object } { "alpha" object }
    { "Color" object }
}
{ $description "" } ;

HELP: file-exists
{ $values
    { "fileName" object }
    { "bool" object }
}
{ $description "" } ;

HELP: gen-image-cellular
{ $values
    { "width" object } { "height" object } { "tileSize" object }
    { "Image" object }
}
{ $description "" } ;

HELP: gen-image-checked
{ $values
    { "width" object } { "height" object } { "checksX" object } { "checksY" object } { "col1" object } { "col2" object }
    { "Image" object }
}
{ $description "" } ;

HELP: gen-image-color
{ $values
    { "width" object } { "height" object } { "color" object }
    { "Image" object }
}
{ $description "" } ;

HELP: gen-image-font-atlas
{ $values
    { "chars" object } { "recs" object } { "glyphCount" object } { "fontSize" object } { "padding" object } { "packMethod" object }
    { "Image" object }
}
{ $description "" } ;

HELP: gen-image-gradient-h
{ $values
    { "width" object } { "height" object } { "left" object } { "right" object }
    { "Image" object }
}
{ $description "" } ;

HELP: gen-image-gradient-radial
{ $values
    { "width" object } { "height" object } { "density" object } { "inner" object } { "outer" object }
    { "Image" object }
}
{ $description "" } ;

HELP: gen-image-gradient-v
{ $values
    { "width" object } { "height" object } { "top" object } { "bottom" object }
    { "Image" object }
}
{ $description "" } ;

HELP: gen-image-perlin-noise
{ $values
    { "width" object } { "height" object } { "offsetX" object } { "offsetY" object } { "scale" object }
    { "Image" object }
}
{ $description "" } ;

HELP: gen-image-text
{ $values
    { "width" object } { "height" object } { "text" object }
    { "Image" object }
}
{ $description "" } ;

HELP: gen-image-white-noise
{ $values
    { "width" object } { "height" object } { "factor" object }
    { "Image" object }
}
{ $description "" } ;

HELP: gen-mesh-cone
{ $values
    { "radius" object } { "height" object } { "slices" object }
    { "Mesh" object }
}
{ $description "" } ;

HELP: gen-mesh-cube
{ $values
    { "width" object } { "height" object } { "length" object }
    { "Mesh" object }
}
{ $description "" } ;

HELP: gen-mesh-cubicmap
{ $values
    { "cubicmap" object } { "cubeSize" object }
    { "Mesh" object }
}
{ $description "" } ;

HELP: gen-mesh-cylinder
{ $values
    { "radius" object } { "height" object } { "slices" object }
    { "Mesh" object }
}
{ $description "" } ;

HELP: gen-mesh-heightmap
{ $values
    { "heightmap" object } { "size" object }
    { "Mesh" object }
}
{ $description "" } ;

HELP: gen-mesh-hemi-sphere
{ $values
    { "radius" object } { "rings" object } { "slices" object }
    { "Mesh" object }
}
{ $description "" } ;

HELP: gen-mesh-knot
{ $values
    { "radius" object } { "size" object } { "radSeg" object } { "sides" object }
    { "Mesh" object }
}
{ $description "" } ;

HELP: gen-mesh-plane
{ $values
    { "width" object } { "length" object } { "resX" object } { "resZ" object }
    { "Mesh" object }
}
{ $description "" } ;

HELP: gen-mesh-poly
{ $values
    { "sides" object } { "radius" object }
    { "Mesh" object }
}
{ $description "" } ;

HELP: gen-mesh-sphere
{ $values
    { "radius" object } { "rings" object } { "slices" object }
    { "Mesh" object }
}
{ $description "" } ;

HELP: gen-mesh-tangents
{ $values
    { "mesh" object }
}
{ $description "" } ;

HELP: gen-mesh-torus
{ $values
    { "radius" object } { "size" object } { "radSeg" object } { "sides" object }
    { "Mesh" object }
}
{ $description "" } ;

HELP: gen-texture-mipmaps
{ $values
    { "texture" object }
}
{ $description "" } ;

HELP: get-application-directory
{ $values
    { "c-string" object }
}
{ $description "" } ;

HELP: get-camera-matrix
{ $values
    { "camera" object }
    { "Matrix" object }
}
{ $description "" } ;

HELP: get-camera-matrix-2d
{ $values
    { "camera" object }
    { "Matrix" object }
}
{ $description "" } ;

HELP: get-char-pressed
{ $values
    { "int" object }
}
{ $description "" } ;

HELP: get-clipboard-text
{ $values
    { "c-string" object }
}
{ $description "" } ;

HELP: get-codepoint
{ $values
    { "text" object } { "bytesProcessed" object }
    { "int" object }
}
{ $description "" } ;

HELP: get-codepoint-count
{ $values
    { "text" object }
    { "int" object }
}
{ $description "" } ;

HELP: get-codepoint-next
{ $values
    { "text" object } { "codepointSize" object }
    { "int" object }
}
{ $description "" } ;

HELP: get-codepoint-previous
{ $values
    { "text" object } { "codepointSize" object }
    { "int" object }
}
{ $description "" } ;

HELP: get-collision-rec
{ $values
    { "rec1" object } { "rec2" object }
    { "Rectangle" object }
}
{ $description "" } ;

HELP: get-color
{ $values
    { "hexValue" object }
    { "Color" object }
}
{ $description "" } ;

HELP: get-current-monitor
{ $values
    { "int" object }
}
{ $description "" } ;

HELP: get-directory-path
{ $values
    { "filePath" object }
    { "c-string" object }
}
{ $description "" } ;

HELP: get-file-extension
{ $values
    { "fileName" object }
    { "c-string" object }
}
{ $description "" } ;

HELP: get-file-length
{ $values
    { "fileName" object }
    { "int" object }
}
{ $description "" } ;

HELP: get-file-mod-time
{ $values
    { "fileName" object }
    { "long" object }
}
{ $description "" } ;

HELP: get-file-name
{ $values
    { "filePath" object }
    { "c-string" object }
}
{ $description "" } ;

HELP: get-file-name-without-ext
{ $values
    { "filePath" object }
    { "c-string" object }
}
{ $description "" } ;

HELP: get-font-default
{ $values
    { "Font" object }
}
{ $description "" } ;

HELP: get-fps
{ $values
    { "int" object }
}
{ $description "" } ;

HELP: get-frame-time
{ $values
    { "float" object }
}
{ $description "" } ;

HELP: get-gamepad-axis-count
{ $values
    { "gamepad" object }
    { "int" object }
}
{ $description "" } ;

HELP: get-gamepad-axis-movement
{ $values
    { "gamepad" object } { "axis" object }
    { "float" object }
}
{ $description "" } ;

HELP: get-gamepad-button-pressed
{ $values
    { "int" object }
}
{ $description "" } ;

HELP: get-gamepad-name
{ $values
    { "gamepad" object }
    { "c-string" object }
}
{ $description "" } ;

HELP: get-gesture-detected
{ $values
    { "int" object }
}
{ $description "" } ;

HELP: get-gesture-drag-angle
{ $values
    { "float" object }
}
{ $description "" } ;

HELP: get-gesture-drag-vector
{ $values
    { "Vector2" object }
}
{ $description "" } ;

HELP: get-gesture-hold-duration
{ $values
    { "float" object }
}
{ $description "" } ;

HELP: get-gesture-pinch-angle
{ $values
    { "float" object }
}
{ $description "" } ;

HELP: get-gesture-pinch-vector
{ $values
    { "Vector2" object }
}
{ $description "" } ;

HELP: get-glyph-atlas-rec
{ $values
    { "font" object } { "codepoint" object }
    { "Rectangle" object }
}
{ $description "" } ;

HELP: get-glyph-index
{ $values
    { "font" object } { "codepoint" object }
    { "int" object }
}
{ $description "" } ;

HELP: get-glyph-info
{ $values
    { "font" object } { "codepoint" object }
    { "GlyphInfo" object }
}
{ $description "" } ;

HELP: get-image-alpha-border
{ $values
    { "image" object } { "threshold" object }
    { "Rectangle" object }
}
{ $description "" } ;

HELP: get-image-color
{ $values
    { "image" object } { "x" object } { "y" object }
    { "Color" object }
}
{ $description "" } ;

HELP: get-key-pressed
{ $values
    { "KeyboardKey" object }
}
{ $description "" } ;

HELP: get-mesh-bounding-box
{ $values
    { "mesh" object }
    { "BoundingBox" object }
}
{ $description "" } ;

HELP: get-model-bounding-box
{ $values
    { "model" object }
    { "BoundingBox" object }
}
{ $description "" } ;

HELP: get-monitor-count
{ $values
    { "int" object }
}
{ $description "" } ;

HELP: get-monitor-height
{ $values
    { "monitor" object }
    { "int" object }
}
{ $description "" } ;

HELP: get-monitor-name
{ $values
    { "monitor" object }
    { "c-string" object }
}
{ $description "" } ;

HELP: get-monitor-physical-height
{ $values
    { "monitor" object }
    { "int" object }
}
{ $description "" } ;

HELP: get-monitor-physical-width
{ $values
    { "monitor" object }
    { "int" object }
}
{ $description "" } ;

HELP: get-monitor-position
{ $values
    { "monitor" object }
    { "Vector2" object }
}
{ $description "" } ;

HELP: get-monitor-refresh-rate
{ $values
    { "monitor" object }
    { "int" object }
}
{ $description "" } ;

HELP: get-monitor-width
{ $values
    { "monitor" object }
    { "int" object }
}
{ $description "" } ;

HELP: get-mouse-delta
{ $values
    { "Vector2" object }
}
{ $description "" } ;

HELP: get-mouse-position
{ $values
    { "Vector2" object }
}
{ $description "" } ;

HELP: get-mouse-ray
{ $values
    { "mousePosition" object } { "camera" object }
    { "Ray" object }
}
{ $description "" } ;

HELP: get-mouse-wheel-move
{ $values
    { "float" object }
}
{ $description "" } ;

HELP: get-mouse-wheel-move-v
{ $values
    { "Vector2" object }
}
{ $description "" } ;

HELP: get-mouse-x
{ $values
    { "int" object }
}
{ $description "" } ;

HELP: get-mouse-y
{ $values
    { "int" object }
}
{ $description "" } ;

HELP: get-music-time-length
{ $values
    { "music" object }
    { "float" object }
}
{ $description "" } ;

HELP: get-music-time-played
{ $values
    { "music" object }
    { "float" object }
}
{ $description "" } ;

HELP: get-pixel-color
{ $values
    { "srcPtr" object } { "format" object }
    { "Color" object }
}
{ $description "" } ;

HELP: get-pixel-data-size
{ $values
    { "width" object } { "height" object } { "format" object }
    { "int" object }
}
{ $description "" } ;

HELP: get-prev-directory-path
{ $values
    { "dirPath" object }
    { "c-string" object }
}
{ $description "" } ;

HELP: get-random-value
{ $values
    { "min" object } { "max" object }
    { "int" object }
}
{ $description "" } ;

HELP: get-ray-collision-box
{ $values
    { "ray" object } { "box" object }
    { "RayCollision" object }
}
{ $description "" } ;

HELP: get-ray-collision-ground
{ $values
    { "ray" object } { "ground-height" object }
    { "ray-collision" object }
}
{ $description "" } ;

HELP: get-ray-collision-mesh
{ $values
    { "ray" object } { "mesh" object } { "transform" object }
    { "RayCollision" object }
}
{ $description "" } ;

HELP: get-ray-collision-model
{ $values
    { "ray" object } { "model" object }
    { "ray-collision" object }
}
{ $description "" } ;

HELP: get-ray-collision-quad
{ $values
    { "ray" object } { "p1" object } { "p2" object } { "p3" object } { "p4" object }
    { "RayCollision" object }
}
{ $description "" } ;

HELP: get-ray-collision-sphere
{ $values
    { "ray" object } { "center" object } { "radius" object }
    { "RayCollision" object }
}
{ $description "" } ;

HELP: get-ray-collision-triangle
{ $values
    { "ray" object } { "p1" object } { "p2" object } { "p3" object }
    { "RayCollision" object }
}
{ $description "" } ;

HELP: get-render-height
{ $values
    { "int" object }
}
{ $description "" } ;

HELP: get-render-width
{ $values
    { "int" object }
}
{ $description "" } ;

HELP: get-screen-height
{ $values
    { "int" object }
}
{ $description "" } ;

HELP: get-screen-to-world-2d
{ $values
    { "position" object } { "camera" object }
    { "Vector2" object }
}
{ $description "" } ;

HELP: get-screen-width
{ $values
    { "int" object }
}
{ $description "" } ;

HELP: get-shader-location
{ $values
    { "shader" object } { "uniformName" object }
    { "int" object }
}
{ $description "" } ;

HELP: get-shader-location-attrib
{ $values
    { "shader" object } { "attribName" object }
    { "int" object }
}
{ $description "" } ;

HELP: get-time
{ $values
    { "double" object }
}
{ $description "" } ;

HELP: get-touch-point-count
{ $values
    { "int" object }
}
{ $description "" } ;

HELP: get-touch-point-id
{ $values
    { "index" object }
    { "int" object }
}
{ $description "" } ;

HELP: get-touch-position
{ $values
    { "index" object }
    { "Vector2" object }
}
{ $description "" } ;

HELP: get-touch-x
{ $values
    { "int" object }
}
{ $description "" } ;

HELP: get-touch-y
{ $values
    { "int" object }
}
{ $description "" } ;

HELP: get-window-handle
{ $values
    { "void*" object }
}
{ $description "" } ;

HELP: get-window-position
{ $values
    { "Vector2" object }
}
{ $description "" } ;

HELP: get-window-scale-dpi
{ $values
    { "Vector2" object }
}
{ $description "" } ;

HELP: get-working-directory
{ $values
    { "c-string" object }
}
{ $description "" } ;

HELP: get-world-to-screen
{ $values
    { "position" object } { "camera" object }
    { "Vector2" object }
}
{ $description "" } ;

HELP: get-world-to-screen-2d
{ $values
    { "position" object } { "camera" object }
    { "Vector2" object }
}
{ $description "" } ;

HELP: get-world-to-screen-ex
{ $values
    { "position" object } { "camera" object } { "width" object } { "height" object }
    { "Vector2" object }
}
{ $description "" } ;

HELP: hide-cursor
{ $description "" } ;

HELP: image-alpha-clear
{ $values
    { "image" object } { "color" object } { "threshold" object }
}
{ $description "" } ;

HELP: image-alpha-crop
{ $values
    { "image" object } { "threshold" object }
}
{ $description "" } ;

HELP: image-alpha-mask
{ $values
    { "image" object } { "alphaMask" object }
}
{ $description "" } ;

HELP: image-alpha-premultiply
{ $values
    { "image" object }
}
{ $description "" } ;

HELP: image-blur-gaussian
{ $values
    { "image" object } { "blurSize" object }
}
{ $description "" } ;

HELP: image-clear-background
{ $values
    { "dst" object } { "color" object }
}
{ $description "" } ;

HELP: image-color-brightness
{ $values
    { "image" object } { "brightness" object }
}
{ $description "" } ;

HELP: image-color-contrast
{ $values
    { "image" object } { "contrast" object }
}
{ $description "" } ;

HELP: image-color-grayscale
{ $values
    { "image" object }
}
{ $description "" } ;

HELP: image-color-invert
{ $values
    { "image" object }
}
{ $description "" } ;

HELP: image-color-replace
{ $values
    { "image" object } { "color" object } { "replace" object }
}
{ $description "" } ;

HELP: image-color-tint
{ $values
    { "image" object } { "color" object }
}
{ $description "" } ;

HELP: image-copy
{ $values
    { "image" object }
    { "Image" object }
}
{ $description "" } ;

HELP: image-crop
{ $values
    { "image" object } { "crop" object }
}
{ $description "" } ;

HELP: image-dither
{ $values
    { "image" object } { "rBpp" object } { "gBpp" object } { "bBpp" object } { "aBpp" object }
}
{ $description "" } ;

HELP: image-draw
{ $values
    { "dst" object } { "src" object } { "srcRec" object } { "dstRec" object } { "tint" object }
}
{ $description "" } ;

HELP: image-draw-circle
{ $values
    { "dst" object } { "centerX" object } { "centerY" object } { "radius" object } { "color" object }
}
{ $description "" } ;

HELP: image-draw-circle-lines
{ $values
    { "dst" object } { "centerX" object } { "centerY" object } { "radius" object } { "color" object }
}
{ $description "" } ;

HELP: image-draw-circle-lines-v
{ $values
    { "dst" object } { "center" object } { "radius" object } { "color" object }
}
{ $description "" } ;

HELP: image-draw-circle-v
{ $values
    { "dst" object } { "center" object } { "radius" object } { "color" object }
}
{ $description "" } ;

HELP: image-draw-line
{ $values
    { "dst" object } { "startPosX" object } { "startPosY" object } { "endPosX" object } { "endPosY" object } { "color" object }
}
{ $description "" } ;

HELP: image-draw-line-v
{ $values
    { "dst" object } { "start" object } { "end" object } { "color" object }
}
{ $description "" } ;

HELP: image-draw-pixel
{ $values
    { "dst" object } { "posX" object } { "posY" object } { "color" object }
}
{ $description "" } ;

HELP: image-draw-pixel-v
{ $values
    { "dst" object } { "position" object } { "color" object }
}
{ $description "" } ;

HELP: image-draw-rectangle
{ $values
    { "dst" object } { "posX" object } { "posY" object } { "width" object } { "height" object } { "color" object }
}
{ $description "" } ;

HELP: image-draw-rectangle-lines
{ $values
    { "dst" object } { "rec" object } { "thick" object } { "color" object }
}
{ $description "" } ;

HELP: image-draw-rectangle-rec
{ $values
    { "dst" object } { "rec" object } { "color" object }
}
{ $description "" } ;

HELP: image-draw-rectangle-v
{ $values
    { "dst" object } { "position" object } { "size" object } { "color" object }
}
{ $description "" } ;

HELP: image-draw-text
{ $values
    { "dst" object } { "text" object } { "posX" object } { "posY" object } { "fontSize" object } { "color" object }
}
{ $description "" } ;

HELP: image-draw-text-ex
{ $values
    { "dst" object } { "font" object } { "text" object } { "position" object } { "fontSize" object } { "spacing" object } { "tint" object }
}
{ $description "" } ;

HELP: image-flip-horizontal
{ $values
    { "image" object }
}
{ $description "" } ;

HELP: image-flip-vertical
{ $values
    { "image" object }
}
{ $description "" } ;

HELP: image-format
{ $values
    { "image" object } { "newformat" object }
}
{ $description "" } ;

HELP: image-from-image
{ $values
    { "image" object } { "rec" object }
    { "Image" object }
}
{ $description "" } ;

HELP: image-mipmaps
{ $values
    { "image" object }
}
{ $description "" } ;

HELP: image-resize
{ $values
    { "image" object } { "newWidth" object } { "newHeight" object }
}
{ $description "" } ;

HELP: image-resize-canvas
{ $values
    { "image" object } { "newWidth" object } { "newHeight" object } { "offsetX" object } { "offsetY" object } { "fill" object }
}
{ $description "" } ;

HELP: image-resize-nn
{ $values
    { "image" object } { "newWidth" object } { "newHeight" object }
}
{ $description "" } ;

HELP: image-rotate-ccw
{ $values
    { "image" object }
}
{ $description "" } ;

HELP: image-rotate-cw
{ $values
    { "image" object }
}
{ $description "" } ;

HELP: image-text
{ $values
    { "text" object } { "fontSize" object } { "color" object }
    { "Image" object }
}
{ $description "" } ;

HELP: image-text-ex
{ $values
    { "font" object } { "text" object } { "fontSize" object } { "spacing" object } { "tint" object }
    { "Image" object }
}
{ $description "" } ;

HELP: image-to-pot
{ $values
    { "image" object } { "fill" object }
}
{ $description "" } ;

HELP: init-audio-device
{ $description "" } ;

HELP: init-window
{ $values
    { "width" object } { "height" object } { "title" object }
}
{ $description "" } ;

HELP: invalid-vector-length
{ $values
    { "obj" object } { "exemplar" object }
}
{ $description "Throws an " { $link invalid-vector-length } " error." }
{ $error-description "" } ;

HELP: is-audio-device-ready
{ $values
    { "bool" object }
}
{ $description "" } ;

HELP: is-audio-stream-playing
{ $values
    { "stream" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-audio-stream-processed
{ $values
    { "stream" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-audio-stream-ready
{ $values
    { "stream" object }
    { "AudioStream" object }
}
{ $description "" } ;

HELP: is-cursor-hidden
{ $values
    { "bool" object }
}
{ $description "" } ;

HELP: is-cursor-on-screen
{ $values
    { "bool" object }
}
{ $description "" } ;

HELP: is-file-dropped
{ $values
    { "bool" object }
}
{ $description "" } ;

HELP: is-file-extension
{ $values
    { "fileName" object } { "ext" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-font-ready
{ $values
    { "font" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-gamepad-available
{ $values
    { "gamepad" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-gamepad-button-down
{ $values
    { "gamepad" object } { "button" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-gamepad-button-pressed
{ $values
    { "gamepad" object } { "button" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-gamepad-button-released
{ $values
    { "gamepad" object } { "button" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-gamepad-button-up
{ $values
    { "gamepad" object } { "button" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-gesture-detected
{ $values
    { "gesture" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-image-ready
{ $values
    { "image" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-key-down
{ $values
    { "key" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-key-pressed
{ $values
    { "key" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-key-released
{ $values
    { "key" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-key-up
{ $values
    { "key" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-material-ready
{ $values
    { "material" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-model-animation-valid
{ $values
    { "model" object } { "anim" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-model-ready
{ $values
    { "model" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-mouse-button-down
{ $values
    { "button" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-mouse-button-pressed
{ $values
    { "button" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-mouse-button-released
{ $values
    { "button" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-mouse-button-up
{ $values
    { "button" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-music-ready
{ $values
    { "music" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-music-stream-playing
{ $values
    { "music" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-path-file
{ $values
    { "path" "a pathname string" }
    { "bool" object }
}
{ $description "" } ;

HELP: is-render-texture-ready
{ $values
    { "target" object }
}
{ $description "" } ;

HELP: is-shader-ready
{ $values
    { "shader" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-sound-playing
{ $values
    { "sound" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-sound-ready
{ $values
    { "sound" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-texture-ready
{ $values
    { "texture" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-wave-ready
{ $values
    { "wave" object }
    { "bool" object }
}
{ $description "" } ;

HELP: is-window-focused
{ $values
    { "bool" object }
}
{ $description "" } ;

HELP: is-window-fullscreen
{ $values
    { "bool" object }
}
{ $description "" } ;

HELP: is-window-hidden
{ $values
    { "bool" object }
}
{ $description "" } ;

HELP: is-window-maximized
{ $values
    { "bool" object }
}
{ $description "" } ;

HELP: is-window-minimized
{ $values
    { "bool" object }
}
{ $description "" } ;

HELP: is-window-ready
{ $values
    { "bool" object }
}
{ $description "" } ;

HELP: is-window-resized
{ $values
    { "bool" object }
}
{ $description "" } ;

HELP: is-window-state
{ $values
    { "flag" object }
    { "bool" object }
}
{ $description "" } ;

HELP: load-audio-stream
{ $values
    { "sampleRate" object } { "sampleSize" object } { "channels" object }
    { "AudioStream" object }
}
{ $description "" } ;

HELP: load-codepoints
{ $values
    { "text" object } { "count" object }
    { "int*" object }
}
{ $description "" } ;

HELP: load-directory-files
{ $values
    { "dirPath" object }
    { "FilePathList" object }
}
{ $description "" } ;

HELP: load-directory-files-ex
{ $values
    { "dirPath" object } { "filter" object } { "scanSubDirs" object }
    { "FilePathList" object }
}
{ $description "" } ;

HELP: load-dropped-files
{ $values
    { "FilePathList" object }
}
{ $description "" } ;

HELP: load-file-data
{ $values
    { "fileName" object } { "bytesRead" object }
    { "c-string" object }
}
{ $description "" } ;

HELP: load-file-text
{ $values
    { "fileName" object }
    { "c-string" object }
}
{ $description "" } ;

HELP: load-font
{ $values
    { "fileName" object }
    { "Font" object }
}
{ $description "" } ;

HELP: load-font-data
{ $values
    { "fileData" object } { "dataSize" object } { "fontSize" object } { "fontChars" object } { "glyphCount" object } { "type" object }
    { "GlyphInfo*" object }
}
{ $description "" } ;

HELP: load-font-ex
{ $values
    { "fileName" object } { "fontSize" object } { "fontChars" object } { "glyphCount" object }
    { "Font" object }
}
{ $description "" } ;

HELP: load-font-from-image
{ $values
    { "image" object } { "key" object } { "firstChar" object }
    { "Font" object }
}
{ $description "" } ;

HELP: load-font-from-memory
{ $values
    { "fileType" object } { "fileData" object } { "dataSize" object } { "fontSize" object } { "fontChars" object } { "glyphCount" object }
    { "Font" object }
}
{ $description "" } ;

HELP: load-image
{ $values
    { "fileName" object }
    { "Image" object }
}
{ $description "" } ;

HELP: load-image-anim
{ $values
    { "fileName" object } { "frames" object }
    { "Image" object }
}
{ $description "" } ;

HELP: load-image-colors
{ $values
    { "image" object }
    { "Color*" object }
}
{ $description "" } ;

HELP: load-image-from-memory
{ $values
    { "fileType" object } { "fileData" object } { "dataSize" object }
    { "Image" object }
}
{ $description "" } ;

HELP: load-image-from-screen
{ $values
    { "Image" object }
}
{ $description "" } ;

HELP: load-image-from-texture
{ $values
    { "texture" object }
    { "Image" object }
}
{ $description "" } ;

HELP: load-image-palette
{ $values
    { "image" object } { "maxPaletteSize" object } { "colorCount" object }
    { "Color*" object }
}
{ $description "" } ;

HELP: load-image-raw
{ $values
    { "fileName" object } { "width" object } { "height" object } { "format" object } { "headerSize" object }
    { "Image" object }
}
{ $description "" } ;

HELP: load-material-default
{ $values
    { "Material" object }
}
{ $description "" } ;

HELP: load-materials
{ $values
    { "fileName" object } { "materialCount" object }
    { "Material*" object }
}
{ $description "" } ;

HELP: load-model
{ $values
    { "fileName" object }
    { "Model" object }
}
{ $description "" } ;

HELP: load-model-animations
{ $values
    { "fileName" object } { "animCount" object }
    { "ModelAnimation*" object }
}
{ $description "" } ;

HELP: load-model-from-mesh
{ $values
    { "mesh" object }
    { "Model" object }
}
{ $description "" } ;

HELP: load-music-stream
{ $values
    { "fileName" object }
    { "Music" object }
}
{ $description "" } ;

HELP: load-music-stream-from-memory
{ $values
    { "fileType" object } { "data" object } { "dataSize" object }
    { "Music" object }
}
{ $description "" } ;

HELP: load-render-texture
{ $values
    { "width" object } { "height" object }
    { "RenderTexture2D" object }
}
{ $description "" } ;

HELP: load-shader
{ $values
    { "vsFileName" object } { "fsFileName" object }
    { "Shader" object }
}
{ $description "" } ;

HELP: load-shader-from-memory
{ $values
    { "vsCode" object } { "fsCode" object }
    { "Shader" object }
}
{ $description "" } ;

HELP: load-sound
{ $values
    { "fileName" object }
    { "Sound" object }
}
{ $description "" } ;

HELP: load-sound-from-wave
{ $values
    { "wave" object }
    { "Sound" object }
}
{ $description "" } ;

HELP: load-texture
{ $values
    { "fileName" object }
    { "Texture2D" object }
}
{ $description "" } ;

HELP: load-texture-cubemap
{ $values
    { "image" object } { "layout" object }
    { "TextureCubemap" object }
}
{ $description "" } ;

HELP: load-texture-from-image
{ $values
    { "image" object }
    { "Texture2D" object }
}
{ $description "" } ;

HELP: load-utf8
{ $values
    { "codepoints" object } { "length" object }
    { "c-string" object }
}
{ $description "" } ;

HELP: load-vr-stereo-config
{ $values
    { "device" object }
    { "VrStereoConfig" object }
}
{ $description "" } ;

HELP: load-wave
{ $values
    { "fileName" object }
    { "Wave" object }
}
{ $description "" } ;

HELP: load-wave-from-memory
{ $values
    { "fileType" object } { "fileData" object } { "dataSize" object }
    { "Wave" object }
}
{ $description "" } ;

HELP: load-wave-samples
{ $values
    { "wave" object }
    { "float*" object }
}
{ $description "" } ;

HELP: maximize-window
{ $description "" } ;

HELP: measure-text
{ $values
    { "text" object } { "fontSize" object }
    { "int" object }
}
{ $description "" } ;

HELP: measure-text-ex
{ $values
    { "font" object } { "text" object } { "fontSize" object } { "spacing" object }
    { "Vector2" object }
}
{ $description "" } ;

HELP: mem-alloc
{ $values
    { "size" object }
    { "void*" object }
}
{ $description "" } ;

HELP: mem-free
{ $values
    { "ptr" object }
}
{ $description "" } ;

HELP: mem-realloc
{ $values
    { "ptr" object } { "size" object }
    { "void*" object }
}
{ $description "" } ;

HELP: minimize-window
{ $description "" } ;

HELP: open-url
{ $values
    { "url" url }
}
{ $description "" } ;

HELP: pause-audio-stream
{ $values
    { "stream" object }
}
{ $description "" } ;

HELP: pause-music-stream
{ $values
    { "music" object }
}
{ $description "" } ;

HELP: pause-sound
{ $values
    { "sound" object }
}
{ $description "" } ;

HELP: play-audio-stream
{ $values
    { "stream" object }
}
{ $description "" } ;

HELP: play-music-stream
{ $values
    { "music" object }
}
{ $description "" } ;

HELP: play-sound
{ $values
    { "sound" object }
}
{ $description "" } ;

HELP: poll-input-events
{ $description "" } ;

HELP: restore-window
{ $description "" } ;

HELP: resume-audio-stream
{ $values
    { "stream" object }
}
{ $description "" } ;

HELP: resume-music-stream
{ $values
    { "music" object }
}
{ $description "" } ;

HELP: resume-sound
{ $values
    { "sound" object }
}
{ $description "" } ;

HELP: save-file-data
{ $values
    { "fileName" object } { "data" object } { "bytesToWrite" object }
    { "bool" object }
}
{ $description "" } ;

HELP: save-file-text
{ $values
    { "fileName" object } { "text" object }
    { "bool" object }
}
{ $description "" } ;

HELP: seek-music-stream
{ $values
    { "music" object } { "position" object }
}
{ $description "" } ;

HELP: set-audio-stream-buffer-size-default
{ $values
    { "size" object }
}
{ $description "" } ;

HELP: set-audio-stream-callback
{ $values
    { "stream" object } { "callback" object }
}
{ $description "" } ;

HELP: set-audio-stream-pan
{ $values
    { "stream" object } { "pan" object }
}
{ $description "" } ;

HELP: set-audio-stream-pitch
{ $values
    { "stream" object } { "pitch" object }
}
{ $description "" } ;

HELP: set-audio-stream-volume
{ $values
    { "stream" object } { "volume" object }
}
{ $description "" } ;

HELP: set-clipboard-text
{ $values
    { "text" object }
}
{ $description "" } ;

HELP: set-config-flags
{ $values
    { "flags" object }
}
{ $description "" } ;

HELP: set-exit-key
{ $values
    { "key" object }
}
{ $description "" } ;

HELP: set-gamepad-mappings
{ $values
    { "mappings" object }
    { "int" object }
}
{ $description "" } ;

HELP: set-gestures-enabled
{ $values
    { "flags" object }
}
{ $description "" } ;

HELP: set-master-volume
{ $values
    { "volume" object }
}
{ $description "" } ;

HELP: set-material-texture
{ $values
    { "material" object } { "mapType" object } { "texture" object }
}
{ $description "" } ;

HELP: set-model-mesh-material
{ $values
    { "model" object } { "meshId" object } { "materialId" object }
}
{ $description "" } ;

HELP: set-mouse-cursor
{ $values
    { "cursor" object }
}
{ $description "" } ;

HELP: set-mouse-offset
{ $values
    { "offsetX" object } { "offsetY" object }
}
{ $description "" } ;

HELP: set-mouse-position
{ $values
    { "x" object } { "y" object }
}
{ $description "" } ;

HELP: set-mouse-scale
{ $values
    { "scaleX" object } { "scaleY" object }
}
{ $description "" } ;

HELP: set-music-pan
{ $values
    { "sound" object } { "pan" object }
}
{ $description "" } ;

HELP: set-music-pitch
{ $values
    { "music" object } { "pitch" object }
}
{ $description "" } ;

HELP: set-music-volume
{ $values
    { "music" object } { "volume" object }
}
{ $description "" } ;

HELP: set-pixel-color
{ $values
    { "dstPtr" object } { "color" object } { "format" object }
}
{ $description "" } ;

HELP: set-random-seed
{ $values
    { "seed" object }
}
{ $description "" } ;

HELP: set-shader-value
{ $values
    { "shader" object } { "locIndex" object } { "value" object } { "uniformType" object }
}
{ $description "" } ;

HELP: set-shader-value-matrix
{ $values
    { "shader" object } { "locIndex" object } { "mat" object }
}
{ $description "" } ;

HELP: set-shader-value-texture
{ $values
    { "shader" object } { "locIndex" object } { "texture" object }
}
{ $description "" } ;

HELP: set-shader-value-v
{ $values
    { "shader" object } { "locIndex" object } { "value" object } { "uniformType" object } { "count" object }
}
{ $description "" } ;

HELP: set-shapes-texture
{ $values
    { "texture" object } { "source" object }
}
{ $description "" } ;

HELP: set-sound-pan
{ $values
    { "sound" object } { "pan" object }
}
{ $description "" } ;

HELP: set-sound-pitch
{ $values
    { "sound" object } { "pitch" object }
}
{ $description "" } ;

HELP: set-sound-volume
{ $values
    { "sound" object } { "volume" object }
}
{ $description "" } ;

HELP: set-target-fps
{ $values
    { "fps" object }
}
{ $description "" } ;

HELP: set-texture-filter
{ $values
    { "texture" object } { "filter" object }
}
{ $description "" } ;

HELP: set-texture-wrap
{ $values
    { "texture" object } { "wrap" object }
}
{ $description "" } ;

HELP: set-trace-log-level
{ $values
    { "logLevel" object }
}
{ $description "" } ;

HELP: set-window-icon
{ $values
    { "image" object }
}
{ $description "" } ;

HELP: set-window-icons
{ $values
    { "images" object } { "count" object }
}
{ $description "" } ;

HELP: set-window-min-size
{ $values
    { "width" object } { "height" object }
}
{ $description "" } ;

HELP: set-window-monitor
{ $values
    { "monitor" object }
}
{ $description "" } ;

HELP: set-window-opacity
{ $values
    { "opacity" object }
}
{ $description "" } ;

HELP: set-window-position
{ $values
    { "x" object } { "y" object }
}
{ $description "" } ;

HELP: set-window-size
{ $values
    { "width" object } { "height" object }
}
{ $description "" } ;

HELP: set-window-state
{ $values
    { "flags" object }
}
{ $description "" } ;

HELP: set-window-title
{ $values
    { "title" object }
}
{ $description "" } ;

HELP: show-cursor
{ $description "" } ;

HELP: stop-audio-stream
{ $values
    { "stream" object }
}
{ $description "" } ;

HELP: stop-music-stream
{ $values
    { "music" object }
}
{ $description "" } ;

HELP: stop-sound
{ $values
    { "sound" object }
}
{ $description "" } ;

HELP: swap-screen-buffer
{ $description "" } ;

HELP: take-screenshot
{ $values
    { "fileName" object }
}
{ $description "" } ;

HELP: text-append
{ $values
    { "text" object } { "append" object } { "position" object }
}
{ $description "" } ;

HELP: text-copy
{ $values
    { "dst" object } { "src" object }
    { "int" object }
}
{ $description "" } ;

HELP: text-find-index
{ $values
    { "text" object } { "find" object }
    { "int" object }
}
{ $description "" } ;

HELP: text-insert
{ $values
    { "text" object } { "insert" object } { "position" object }
    { "c-string" object }
}
{ $description "" } ;

HELP: text-is-equal
{ $values
    { "text1" object } { "text2" object }
    { "bool" object }
}
{ $description "" } ;

HELP: text-join
{ $values
    { "textList" object } { "count" object } { "delimiter" object }
    { "c-string" object }
}
{ $description "" } ;

HELP: text-length
{ $values
    { "text" object }
    { "uint" object }
}
{ $description "" } ;

HELP: text-replace
{ $values
    { "text" object } { "replace" object } { "by" object }
    { "c-string" object }
}
{ $description "" } ;

HELP: text-split
{ $values
    { "text" object } { "delimiter" object } { "count" object }
    { "c-string*" object }
}
{ $description "" } ;

HELP: text-subtext
{ $values
    { "text" object } { "position" object } { "length" object }
    { "c-string" object }
}
{ $description "" } ;

HELP: text-to-integer
{ $values
    { "text" object }
    { "int" object }
}
{ $description "" } ;

HELP: text-to-lower
{ $values
    { "text" object }
    { "c-string" object }
}
{ $description "" } ;

HELP: text-to-pascal
{ $values
    { "text" object }
    { "c-string" object }
}
{ $description "" } ;

HELP: text-to-upper
{ $values
    { "text" object }
    { "c-string" object }
}
{ $description "" } ;

HELP: toggle-fullscreen
{ $description "" } ;

HELP: unload-audio-stream
{ $values
    { "stream" object }
}
{ $description "" } ;

HELP: unload-audio-stream-destructor
{ $class-description "" } ;

HELP: unload-codepoints
{ $values
    { "codepoints" object }
}
{ $description "" } ;

HELP: unload-directory-files
{ $values
    { "files" object }
}
{ $description "" } ;

HELP: unload-dropped-files
{ $values
    { "files" object }
}
{ $description "" } ;

HELP: unload-file-data
{ $values
    { "data" object }
}
{ $description "" } ;

HELP: unload-file-data-destructor
{ $class-description "" } ;

HELP: unload-file-text
{ $values
    { "text" object }
}
{ $description "" } ;

HELP: unload-file-text-destructor
{ $class-description "" } ;

HELP: unload-font
{ $values
    { "font" object }
}
{ $description "" } ;

HELP: unload-font-data
{ $values
    { "chars" object } { "glyphCount" object }
}
{ $description "" } ;

HELP: unload-font-destructor
{ $class-description "" } ;

HELP: unload-image
{ $values
    { "image" object }
}
{ $description "" } ;

HELP: unload-image-colors
{ $values
    { "colors" object }
}
{ $description "" } ;

HELP: unload-image-colors-destructor
{ $class-description "" } ;

HELP: unload-image-destructor
{ $class-description "" } ;

HELP: unload-image-palette
{ $values
    { "colors" object }
}
{ $description "" } ;

HELP: unload-image-palette-destructor
{ $class-description "" } ;

HELP: unload-material
{ $values
    { "material" object }
}
{ $description "" } ;

HELP: unload-material-destructor
{ $class-description "" } ;

HELP: unload-mesh
{ $values
    { "mesh" object }
}
{ $description "" } ;

HELP: unload-mesh-destructor
{ $class-description "" } ;

HELP: unload-model
{ $values
    { "model" object }
}
{ $description "" } ;

HELP: unload-model-animation
{ $values
    { "anim" object }
}
{ $description "" } ;

HELP: unload-model-animation-destructor
{ $class-description "" } ;

HELP: unload-model-animations
{ $values
    { "animations" object } { "count" object }
}
{ $description "" } ;

HELP: unload-model-destructor
{ $class-description "" } ;

HELP: unload-music-stream
{ $values
    { "music" object }
}
{ $description "" } ;

HELP: unload-music-stream-destructor
{ $class-description "" } ;

HELP: unload-render-texture
{ $values
    { "target" object }
}
{ $description "" } ;

HELP: unload-render-texture-destructor
{ $class-description "" } ;

HELP: unload-shader
{ $values
    { "shader" object }
}
{ $description "" } ;

HELP: unload-shader-destructor
{ $class-description "" } ;

HELP: unload-sound
{ $values
    { "sound" object }
}
{ $description "" } ;

HELP: unload-sound-destructor
{ $class-description "" } ;

HELP: unload-texture
{ $values
    { "texture" object }
}
{ $description "" } ;

HELP: unload-texture-destructor
{ $class-description "" } ;

HELP: unload-utf8
{ $values
    { "text" object }
}
{ $description "" } ;

HELP: unload-vr-stereo-config
{ $values
    { "config" object }
}
{ $description "" } ;

HELP: unload-wave
{ $values
    { "wave" object }
}
{ $description "" } ;

HELP: unload-wave-destructor
{ $class-description "" } ;

HELP: unload-wave-samples
{ $values
    { "samples" object }
}
{ $description "" } ;

HELP: update-audio-stream
{ $values
    { "stream" object } { "data" object } { "frameCount" object }
}
{ $description "" } ;

HELP: update-camera
{ $values
    { "camera" object } { "mode" object }
}
{ $description "" } ;

HELP: update-camera-pro
{ $values
    { "camera" object } { "movement" object } { "rotation" object } { "zoom" object }
}
{ $description "" } ;

HELP: update-mesh-buffer
{ $values
    { "mesh" object } { "index" object } { "data" object } { "dataSize" object } { "offset" object }
}
{ $description "" } ;

HELP: update-model-animation
{ $values
    { "model" object } { "anim" object } { "frame" object }
}
{ $description "" } ;

HELP: update-music-stream
{ $values
    { "music" object }
}
{ $description "" } ;

HELP: update-sound
{ $values
    { "sound" object } { "data" object } { "sampleCount" object }
}
{ $description "" } ;

HELP: update-texture
{ $values
    { "texture" object } { "pixels" object }
}
{ $description "" } ;

HELP: update-texture-rec
{ $values
    { "texture" object } { "rec" object } { "pixels" object }
}
{ $description "" } ;

HELP: upload-mesh
{ $values
    { "mesh" object } { "dynamic" object }
}
{ $description "" } ;

HELP: wait-time
{ $values
    { "seconds" object }
}
{ $description "" } ;

HELP: wave-copy
{ $values
    { "wave" object }
    { "Wave" object }
}
{ $description "" } ;

HELP: wave-crop
{ $values
    { "wave" object } { "initSample" object } { "finalSample" object }
}
{ $description "" } ;

HELP: wave-format
{ $values
    { "wave" object } { "sampleRate" object } { "sampleSize" object } { "channels" object }
}
{ $description "" } ;

HELP: window-should-close
{ $values
    { "bool" object }
}
{ $description "" } ;

HELP: |unload-audio-stream
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: |unload-file-data
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: |unload-file-text
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: |unload-font
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: |unload-image
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: |unload-image-colors
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: |unload-image-palette
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: |unload-material
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: |unload-mesh
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: |unload-model
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: |unload-model-animation
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: |unload-music-stream
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: |unload-render-texture
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: |unload-shader
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: |unload-sound
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: |unload-texture
{ $values
    { "alien" object }
}
{ $description "" } ;

HELP: |unload-wave
{ $values
    { "alien" object }
}
{ $description "" } ;

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
