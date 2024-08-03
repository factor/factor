! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.data arrays assocs colors combinators
destructors images images.tessellation kernel literals math
math.statistics math.vectors namespaces opengl
opengl.capabilities opengl.gl sequences specialized-arrays
system ;
FROM: alien.c-types => int float ;
SPECIALIZED-ARRAY: float
IN: opengl.textures

SYMBOL: non-power-of-2-textures?

: check-extensions ( -- )
    ! ATI frglx driver doesn't implement GL_ARB_texture_non_power_of_two properly.
    ! See thread 'Linux font display problem' April 2009 on Factor-talk
    gl-vendor "ATI Technologies Inc." = not os macos? or [
        "2.0" { "GL_ARB_texture_non_power_of_two" }
        has-gl-version-or-extensions?
        non-power-of-2-textures? set
    ] when ;

: gen-texture ( -- id ) [ glGenTextures ] (gen-gl-object) ;

: create-texture ( target -- id ) 
    [ glCreateTextures ] (gen-gl-object) ;

: delete-texture ( id -- ) [ glDeleteTextures ] (delete-gl-object) ;

ERROR: unsupported-component-order component-order component-type ;

CONSTANT: image-internal-formats H{
    { { A         ubyte-components          } $ GL_ALPHA8            }
    { { A         ushort-components         } $ GL_ALPHA16           }
    { { A         half-components           } $ GL_ALPHA16F_ARB      }
    { { A         float-components          } $ GL_ALPHA32F_ARB      }
    { { A         byte-integer-components   } $ GL_ALPHA8I_EXT       }
    { { A         ubyte-integer-components  } $ GL_ALPHA8UI_EXT      }
    { { A         short-integer-components  } $ GL_ALPHA16I_EXT      }
    { { A         ushort-integer-components } $ GL_ALPHA16UI_EXT     }
    { { A         int-integer-components    } $ GL_ALPHA32I_EXT      }
    { { A         uint-integer-components   } $ GL_ALPHA32UI_EXT     }

    { { L         ubyte-components          } $ GL_LUMINANCE8        }
    { { L         ushort-components         } $ GL_LUMINANCE16       }
    { { L         half-components           } $ GL_LUMINANCE16F_ARB  }
    { { L         float-components          } $ GL_LUMINANCE32F_ARB  }
    { { L         byte-integer-components   } $ GL_LUMINANCE8I_EXT   }
    { { L         ubyte-integer-components  } $ GL_LUMINANCE8UI_EXT  }
    { { L         short-integer-components  } $ GL_LUMINANCE16I_EXT  }
    { { L         ushort-integer-components } $ GL_LUMINANCE16UI_EXT }
    { { L         int-integer-components    } $ GL_LUMINANCE32I_EXT  }
    { { L         uint-integer-components   } $ GL_LUMINANCE32UI_EXT }

    { { R         ubyte-components          } $ GL_R8    }
    { { R         ushort-components         } $ GL_R16   }
    { { R         half-components           } $ GL_R16F  }
    { { R         float-components          } $ GL_R32F  }
    { { R         byte-integer-components   } $ GL_R8I   }
    { { R         ubyte-integer-components  } $ GL_R8UI  }
    { { R         short-integer-components  } $ GL_R16I  }
    { { R         ushort-integer-components } $ GL_R16UI }
    { { R         int-integer-components    } $ GL_R32I  }
    { { R         uint-integer-components   } $ GL_R32UI }

    { { INTENSITY ubyte-components          } $ GL_INTENSITY8        }
    { { INTENSITY ushort-components         } $ GL_INTENSITY16       }
    { { INTENSITY half-components           } $ GL_INTENSITY16F_ARB  }
    { { INTENSITY float-components          } $ GL_INTENSITY32F_ARB  }
    { { INTENSITY byte-integer-components   } $ GL_INTENSITY8I_EXT   }
    { { INTENSITY ubyte-integer-components  } $ GL_INTENSITY8UI_EXT  }
    { { INTENSITY short-integer-components  } $ GL_INTENSITY16I_EXT  }
    { { INTENSITY ushort-integer-components } $ GL_INTENSITY16UI_EXT }
    { { INTENSITY int-integer-components    } $ GL_INTENSITY32I_EXT  }
    { { INTENSITY uint-integer-components   } $ GL_INTENSITY32UI_EXT }

    { { DEPTH     ushort-components         } $ GL_DEPTH_COMPONENT16  }
    { { DEPTH     u-24-components           } $ GL_DEPTH_COMPONENT24  }
    { { DEPTH     uint-components           } $ GL_DEPTH_COMPONENT32  }
    { { DEPTH     float-components          } $ GL_DEPTH_COMPONENT32F }

    { { LA        ubyte-components          } $ GL_LUMINANCE8_ALPHA8       }
    { { LA        ushort-components         } $ GL_LUMINANCE16_ALPHA16     }
    { { LA        half-components           } $ GL_LUMINANCE_ALPHA16F_ARB  }
    { { LA        float-components          } $ GL_LUMINANCE_ALPHA32F_ARB  }
    { { LA        byte-integer-components   } $ GL_LUMINANCE_ALPHA8I_EXT   }
    { { LA        ubyte-integer-components  } $ GL_LUMINANCE_ALPHA8UI_EXT  }
    { { LA        short-integer-components  } $ GL_LUMINANCE_ALPHA16I_EXT  }
    { { LA        ushort-integer-components } $ GL_LUMINANCE_ALPHA16UI_EXT }
    { { LA        int-integer-components    } $ GL_LUMINANCE_ALPHA32I_EXT  }
    { { LA        uint-integer-components   } $ GL_LUMINANCE_ALPHA32UI_EXT }

    { { RG        ubyte-components          } $ GL_RG8    }
    { { RG        ushort-components         } $ GL_RG16   }
    { { RG        half-components           } $ GL_RG16F  }
    { { RG        float-components          } $ GL_RG32F  }
    { { RG        byte-integer-components   } $ GL_RG8I   }
    { { RG        ubyte-integer-components  } $ GL_RG8UI  }
    { { RG        short-integer-components  } $ GL_RG16I  }
    { { RG        ushort-integer-components } $ GL_RG16UI }
    { { RG        int-integer-components    } $ GL_RG32I  }
    { { RG        uint-integer-components   } $ GL_RG32UI }

    { { DEPTH-STENCIL u-24-8-components       } $ GL_DEPTH24_STENCIL8 }
    { { DEPTH-STENCIL float-32-u-8-components } $ GL_DEPTH32F_STENCIL8 }

    { { RGB       ubyte-components          } $ GL_RGB8               }
    { { RGB       ushort-components         } $ GL_RGB16              }
    { { RGB       half-components           } $ GL_RGB16F         }
    { { RGB       float-components          } $ GL_RGB32F         }
    { { RGB       byte-integer-components   } $ GL_RGB8I          }
    { { RGB       ubyte-integer-components  } $ GL_RGB8UI         }
    { { RGB       byte-integer-components   } $ GL_RGB8I          }
    { { RGB       ubyte-integer-components  } $ GL_RGB8UI         }
    { { RGB       short-integer-components  } $ GL_RGB16I         }
    { { RGB       ushort-integer-components } $ GL_RGB16UI        }
    { { RGB       int-integer-components    } $ GL_RGB32I         }
    { { RGB       uint-integer-components   } $ GL_RGB32UI        }
    { { RGB       u-5-6-5-components        } $ GL_RGB5               }
    { { RGB       u-9-9-9-e5-components     } $ GL_RGB9_E5        }
    { { RGB       float-11-11-10-components } $ GL_R11F_G11F_B10F }

    { { RGBA      ubyte-components          } $ GL_RGBA8              }
    { { RGBA      ushort-components         } $ GL_RGBA16             }
    { { RGBA      half-components           } $ GL_RGBA16F        }
    { { RGBA      float-components          } $ GL_RGBA32F        }
    { { RGBA      byte-integer-components   } $ GL_RGBA8I         }
    { { RGBA      ubyte-integer-components  } $ GL_RGBA8UI        }
    { { RGBA      byte-integer-components   } $ GL_RGBA8I         }
    { { RGBA      ubyte-integer-components  } $ GL_RGBA8UI        }
    { { RGBA      short-integer-components  } $ GL_RGBA16I        }
    { { RGBA      ushort-integer-components } $ GL_RGBA16UI       }
    { { RGBA      int-integer-components    } $ GL_RGBA32I        }
    { { RGBA      uint-integer-components   } $ GL_RGBA32UI       }
    { { RGBA      u-5-5-5-1-components      } $ GL_RGB5_A1            }
    { { RGBA      u-10-10-10-2-components   } $ GL_RGB10_A2           }
}

GENERIC: fix-internal-component-order ( order -- order' )

M: object fix-internal-component-order ;
M: BGR fix-internal-component-order drop RGB ;
M: BGRA fix-internal-component-order drop RGBA ;
M: ARGB fix-internal-component-order drop RGBA ;
M: ABGR fix-internal-component-order drop RGBA ;
M: RGBX fix-internal-component-order drop RGBA ;
M: BGRX fix-internal-component-order drop RGBA ;
M: XRGB fix-internal-component-order drop RGBA ;
M: XBGR fix-internal-component-order drop RGBA ;

: image-internal-format ( component-order component-type -- internal-format )
    2dup
    [ fix-internal-component-order ] dip 2array image-internal-formats at
    [ 2nip ] [ unsupported-component-order ] if* ;

: reversed-type? ( component-type -- ? )
    { u-9-9-9-e5-components float-11-11-10-components } member? ;

: (component-order>format) ( component-order component-type -- gl-format )
    dup unnormalized-integer-components? [
        swap {
            { A [ drop GL_ALPHA_INTEGER_EXT ] }
            { L [ drop GL_LUMINANCE_INTEGER_EXT ] }
            { R [ drop GL_RED_INTEGER ] }
            { LA [ drop GL_LUMINANCE_ALPHA_INTEGER_EXT ] }
            { RG [ drop GL_RG_INTEGER ] }
            { BGR [ drop GL_BGR_INTEGER ] }
            { RGB [ drop GL_RGB_INTEGER ] }
            { BGRA [ drop GL_BGRA_INTEGER ] }
            { RGBA [ drop GL_RGBA_INTEGER ] }
            { BGRX [ drop GL_BGRA_INTEGER ] }
            { RGBX [ drop GL_RGBA_INTEGER ] }
            [ swap unsupported-component-order ]
        } case
    ] [
        swap {
            { A [ drop GL_ALPHA ] }
            { L [ drop GL_LUMINANCE ] }
            { R [ drop GL_RED ] }
            { LA [ drop GL_LUMINANCE_ALPHA ] }
            { RG [ drop GL_RG ] }
            { BGR [ reversed-type? GL_RGB GL_BGR ? ] }
            { RGB [ reversed-type? GL_BGR GL_RGB ? ] }
            { BGRA [ drop GL_BGRA ] }
            { RGBA [ drop GL_RGBA ] }
            { ARGB [ drop GL_BGRA ] }
            { ABGR [ drop GL_RGBA ] }
            { BGRX [ drop GL_BGRA ] }
            { RGBX [ drop GL_RGBA ] }
            { XRGB [ drop GL_BGRA ] }
            { XBGR [ drop GL_RGBA ] }
            { INTENSITY [ drop GL_INTENSITY ] }
            { DEPTH [ drop GL_DEPTH_COMPONENT ] }
            { DEPTH-STENCIL [ drop GL_DEPTH_STENCIL ] }
            [ swap unsupported-component-order ]
        } case
    ] if ;

GENERIC: (component-type>type) ( component-order component-type -- gl-type )

M: object (component-type>type) unsupported-component-order ;

: four-channel-alpha-first? ( component-order component-type -- ? )
    over component-count 4 =
    [ drop alpha-channel-precedes-colors? ]
    [ unsupported-component-order ] if ;

: not-alpha-first ( component-order component-type -- )
    over alpha-channel-precedes-colors?
    [ unsupported-component-order ]
    [ 2drop ] if ;

M: ubyte-components          (component-type>type)
    drop alpha-channel-precedes-colors?
    [ GL_UNSIGNED_INT_8_8_8_8_REV ]
    [ GL_UNSIGNED_BYTE ] if ;

M: ushort-components         (component-type>type) not-alpha-first GL_UNSIGNED_SHORT ;
M: uint-components           (component-type>type) not-alpha-first GL_UNSIGNED_INT   ;
M: half-components           (component-type>type) not-alpha-first GL_HALF_FLOAT ;
M: float-components          (component-type>type) not-alpha-first GL_FLOAT          ;
M: byte-integer-components   (component-type>type) not-alpha-first GL_BYTE           ;
M: ubyte-integer-components  (component-type>type) not-alpha-first GL_UNSIGNED_BYTE  ;
M: short-integer-components  (component-type>type) not-alpha-first GL_SHORT          ;
M: ushort-integer-components (component-type>type) not-alpha-first GL_UNSIGNED_SHORT ;
M: int-integer-components    (component-type>type) not-alpha-first GL_INT            ;
M: uint-integer-components   (component-type>type) not-alpha-first GL_UNSIGNED_INT   ;

M: u-5-5-5-1-components      (component-type>type)
    four-channel-alpha-first?
    [ GL_UNSIGNED_SHORT_1_5_5_5_REV ]
    [ GL_UNSIGNED_SHORT_5_5_5_1     ] if ;

M: u-5-6-5-components        (component-type>type) 2drop GL_UNSIGNED_SHORT_5_6_5 ;

M: u-10-10-10-2-components   (component-type>type)
    four-channel-alpha-first?
    [ GL_UNSIGNED_INT_2_10_10_10_REV ]
    [ GL_UNSIGNED_INT_10_10_10_2     ] if ;

M: u-24-components           (component-type>type)
    over DEPTH =
    [ 2drop GL_UNSIGNED_INT ]
    [ unsupported-component-order ] if ;

M: u-24-8-components         (component-type>type)
    over DEPTH-STENCIL =
    [ 2drop GL_UNSIGNED_INT_24_8 ]
    [ unsupported-component-order ] if ;

M: u-9-9-9-e5-components     (component-type>type)
    over BGR =
    [ 2drop GL_UNSIGNED_INT_5_9_9_9_REV ]
    [ unsupported-component-order ] if ;

M: float-11-11-10-components (component-type>type)
    over BGR =
    [ 2drop GL_UNSIGNED_INT_10F_11F_11F_REV ]
    [ unsupported-component-order ] if ;

: image-data-format ( component-order component-type -- gl-format gl-type )
    [ (component-order>format) ] [ (component-type>type) ] 2bi ;

SLOT: display-list

: draw-texture ( texture -- ) display-list>> [ glCallList ] when* ;

GENERIC: draw-scaled-texture ( dim texture -- )

DEFER: make-texture

: (image-format) ( component-order component-type -- internal-format format type )
    [ image-internal-format ] [ image-data-format ] 2bi ;

: image-format ( image -- internal-format format type )
    [ component-order>> ] [ component-type>> ] bi (image-format) ;

<PRIVATE

TUPLE: single-texture < disposable image dim loc texture-coords texture display-list ;

: adjust-texture-dim ( dim -- dim' )
    non-power-of-2-textures? get [
        [ dup 1 = [ next-power-of-2 ] unless ] map
    ] unless ;

:: tex-image ( image bitmap -- )
    image image-format :> ( internal-format format type )
    GL_TEXTURE_2D 0 internal-format
    image dim>> adjust-texture-dim first2 0
    format type bitmap glTexImage2D ;

: tex-sub-image ( image -- )
    [ GL_TEXTURE_2D 0 0 0 ] dip
    [ dim>> first2 ]
    [ image-format nipd ]
    [ bitmap>> ] tri
    glTexSubImage2D ;

: init-texture ( -- )
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_REPEAT glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_REPEAT glTexParameteri ;

: with-texturing ( quot -- )
    GL_TEXTURE_2D [
        GL_TEXTURE_BIT [
            GL_TEXTURE_COORD_ARRAY [
                COLOR: white gl-color
                call
            ] do-enabled-client-state
        ] do-attribs
    ] do-enabled ; inline

: texture-dim ( texture -- dim )
    [ dim>> ] [ image>> ] bi 2x?>> [ [ 2.0 / ] map ] when ;

: (draw-textured-rect) ( dim texture -- )
    [ loc>> ]
    [ [ GL_TEXTURE_2D ] dip texture>> glBindTexture ]
    [ init-texture texture-coords>> gl-texture-coord-pointer ] tri
    swap gl-fill-rect ;

: set-blend-mode ( texture -- )
    image>> dup has-alpha?
    [ premultiplied-alpha?>> [ GL_ONE GL_ONE_MINUS_SRC_ALPHA glBlendFunc ] when ]
    [ drop GL_BLEND glDisable ] if ;

: reset-blend-mode ( texture -- )
    image>> dup has-alpha?
    [ premultiplied-alpha?>> [ GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc ] when ]
    [ drop GL_BLEND glEnable ] if ;

: draw-textured-rect ( dim texture -- )
    [
        [ set-blend-mode ]
        [ (draw-textured-rect) GL_TEXTURE_2D 0 glBindTexture ]
        [ reset-blend-mode ] tri
    ] with-texturing ;

: texture-coords ( texture -- coords )
    [ [ dim>> ] [ image>> dim>> adjust-texture-dim ] bi v/ ]
    [
        image>> upside-down?>>
        { { 0 1 } { 1 1 } { 1 0 } { 0 0 } }
        { { 0 0 } { 1 0 } { 1 1 } { 0 1 } } ?
    ] bi
    [ v* ] with map float-array{ } join ;

: make-texture-display-list ( texture -- dlist )
    GL_COMPILE [
        [ texture-dim ] keep draw-textured-rect
    ] make-dlist ;

: <single-texture> ( image loc -- texture )
    single-texture new-disposable
        swap >>loc
        swap [ >>image ] [ dim>> >>dim ] bi
    dup image>> dim>> product 0 = [
        dup texture-coords >>texture-coords
        dup image>> make-texture >>texture
        dup make-texture-display-list >>display-list
    ] unless ;

M: single-texture dispose*
    [ texture>> [ delete-texture ] when* ]
    [ display-list>> [ delete-dlist ] when* ] bi ;

M: single-texture draw-scaled-texture
    2dup dim>> = [ nip draw-texture ] [
        dup texture>> [ draw-textured-rect ] [ 2drop ] if
    ] if ;

TUPLE: multi-texture < disposable grid display-list loc ;

: image-locs ( image-grid -- loc-grid )
    [ first [ image-dim first ] map ]
    [ [ first image-dim second ] map ] bi
    [ cum-sum0 ] bi@ cartesian-product flip ;

: <texture-grid> ( image-grid loc -- grid )
    [ dup image-locs ] dip
    '[ [ _ v+ <single-texture> |dispose ] 2map ] 2map ;

: grid-has-alpha? ( grid -- ? )
    first first image>> has-alpha? ;

: make-textured-grid-display-list ( grid -- dlist )
    GL_COMPILE [
        [
            [ grid-has-alpha? [ GL_BLEND glDisable ] unless ]
            [ [ [ [ texture-dim ] keep (draw-textured-rect) ] each ] each ]
            [ grid-has-alpha? [ GL_BLEND glEnable ] unless ] tri
            GL_TEXTURE_2D 0 glBindTexture
        ] with-texturing
    ] make-dlist ;

: <multi-texture> ( image-grid loc -- multi-texture )
    [
        [ multi-texture new-disposable ] 2dip
        [ nip >>loc ] [ <texture-grid> >>grid ] 2bi
        dup grid>> make-textured-grid-display-list >>display-list
    ] with-destructors ;

: normalize-by-first-texture-max-dim ( multi-texture -- norms )
  [ first first dim>> maximum ] [ swap '[ [ dim>> _ v/n ] map ] map ] bi ;

: first-row-xs ( dims -- xs ) first flip first ;
: first-col-ys ( dims -- ys ) flip first flip second ; 
: normalize-scaling-dims ( scaling-dim norms -- scaled-dim )
  [ first-row-xs sum ] [ first-col-ys sum ] bi 2array v/ ;
: accumulate-divisions-to-grid ( scaled-dims -- x )
  [ first-row-xs ] [ first-col-ys ] bi
  [ 0 [ + ] accumulate nip ] bi@
  cartesian-product flip ;

: per-texture-scalings-in-grid ( norms scaled-dim -- scaled-dims ) 
  '[ [ _ v* ] map! ] map! ;
: shift-loc-offsets ( textures scaled-dims -- )
  accumulate-divisions-to-grid [ [ >>loc drop ] 2each ] 2each  ;

M: multi-texture draw-scaled-texture
  grid>>
  [ normalize-by-first-texture-max-dim [ normalize-scaling-dims ] keep ]
  [ spin per-texture-scalings-in-grid [ shift-loc-offsets ] keep ]
  [ [ [ draw-scaled-texture ] 2each ] 2each ] tri ;

M: multi-texture dispose* grid>> [ [ dispose ] each ] each ;

CONSTANT: max-texture-size { 512 512 }

PRIVATE>

: make-texture ( image -- id )
    ! We use glTexSubImage2D to work around the power of 2 texture size
    ! limitation
    gen-texture [
        GL_TEXTURE_BIT [
            GL_TEXTURE_2D swap glBindTexture
            non-power-of-2-textures? get
            [ dup bitmap>> tex-image ]
            [ [ f tex-image ] [ tex-sub-image ] bi ] if
        ] do-attribs
    ] keep ;

: <texture> ( image loc -- texture )
    over dim>> max-texture-size [ <= ] 2all?
    [ <single-texture> ]
    [ [ max-texture-size tesselate ] dip <multi-texture> ] if ;

: get-texture-float ( target level enum -- value )
    { float } [ glGetTexLevelParameterfv ] with-out-parameters ; inline

: get-texture-int ( target level enum -- value )
    { int } [ glGetTexLevelParameteriv ] with-out-parameters ; inline
