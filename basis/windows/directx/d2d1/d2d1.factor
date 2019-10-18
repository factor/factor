USING: alien.c-types alien.syntax classes.struct windows.com
windows.com.syntax windows.directx windows.directx.d2dbasetypes
windows.directx.dcommon windows.directx.dxgi windows.directx.dxgiformat
windows.ole32 windows.types ;
IN: windows.directx.d2d1

LIBRARY: d2d1

CONSTANT: D2D1_INVALID_TAG 0xffffffffffffffff
CONSTANT: D2D1_DEFAULT_FLATTENING_TOLERANCE 0.25

CONSTANT: D2D1_ALPHA_MODE_UNKNOWN       0
CONSTANT: D2D1_ALPHA_MODE_PREMULTIPLIED 1
CONSTANT: D2D1_ALPHA_MODE_STRAIGHT      2
CONSTANT: D2D1_ALPHA_MODE_IGNORE        3
CONSTANT: D2D1_ALPHA_MODE_FORCE_DWORD   0xffffffff
TYPEDEF: int D2D1_ALPHA_MODE

CONSTANT: D2D1_GAMMA_2_2         0
CONSTANT: D2D1_GAMMA_1_0         1
CONSTANT: D2D1_GAMMA_FORCE_DWORD 0xffffffff
TYPEDEF: int D2D1_GAMMA

CONSTANT: D2D1_OPACITY_MASK_CONTENT_GRAPHICS            0
CONSTANT: D2D1_OPACITY_MASK_CONTENT_TEXT_NATURAL        1
CONSTANT: D2D1_OPACITY_MASK_CONTENT_TEXT_GDI_COMPATIBLE 2
CONSTANT: D2D1_OPACITY_MASK_CONTENT_FORCE_DWORD         0xffffffff
TYPEDEF: int D2D1_OPACITY_MASK_CONTENT

CONSTANT: D2D1_EXTEND_MODE_CLAMP       0
CONSTANT: D2D1_EXTEND_MODE_WRAP        1
CONSTANT: D2D1_EXTEND_MODE_MIRROR      2
CONSTANT: D2D1_EXTEND_MODE_FORCE_DWORD 0xffffffff
TYPEDEF: int D2D1_EXTEND_MODE

CONSTANT: D2D1_ANTIALIAS_MODE_PER_PRIMITIVE 0
CONSTANT: D2D1_ANTIALIAS_MODE_ALIASED       1
CONSTANT: D2D1_ANTIALIAS_MODE_FORCE_DWORD   0xffffffff
TYPEDEF: int D2D1_ANTIALIAS_MODE

CONSTANT: D2D1_TEXT_ANTIALIAS_MODE_DEFAULT     0
CONSTANT: D2D1_TEXT_ANTIALIAS_MODE_CLEARTYPE   1
CONSTANT: D2D1_TEXT_ANTIALIAS_MODE_GRAYSCALE   2
CONSTANT: D2D1_TEXT_ANTIALIAS_MODE_ALIASED     3
CONSTANT: D2D1_TEXT_ANTIALIAS_MODE_FORCE_DWORD 0xffffffff
TYPEDEF: int D2D1_TEXT_ANTIALIAS_MODE

CONSTANT: D2D1_BITMAP_INTERPOLATION_MODE_NEAREST_NEIGHBOR 0
CONSTANT: D2D1_BITMAP_INTERPOLATION_MODE_LINEAR           1
CONSTANT: D2D1_BITMAP_INTERPOLATION_MODE_FORCE_DWORD      0xffffffff
TYPEDEF: int D2D1_BITMAP_INTERPOLATION_MODE

CONSTANT: D2D1_DRAW_TEXT_OPTIONS_NO_SNAP     0x00000001
CONSTANT: D2D1_DRAW_TEXT_OPTIONS_CLIP        0x00000002
CONSTANT: D2D1_DRAW_TEXT_OPTIONS_NONE        0x00000000
CONSTANT: D2D1_DRAW_TEXT_OPTIONS_FORCE_DWORD 0xffffffff
TYPEDEF: int D2D1_DRAW_TEXT_OPTIONS

STRUCT: D2D1_PIXEL_FORMAT
    { format    DXGI_FORMAT     }
    { alphaMode D2D1_ALPHA_MODE } ;

TYPEDEF: D2D_POINT_2U D2D1_POINT_2U
TYPEDEF: D2D_POINT_2F D2D1_POINT_2F
TYPEDEF: D2D_RECT_F D2D1_RECT_F
TYPEDEF: D2D_RECT_U D2D1_RECT_U
TYPEDEF: D2D_SIZE_F D2D1_SIZE_F
TYPEDEF: D2D_SIZE_U D2D1_SIZE_U
TYPEDEF: D2D_COLOR_F D2D1_COLOR_F
TYPEDEF: D2D_MATRIX_3X2_F D2D1_MATRIX_3X2_F
TYPEDEF: UINT64 D2D1_TAG

STRUCT: D2D1_BITMAP_PROPERTIES
    { pixelFormat D2D1_PIXEL_FORMAT }
    { dpiX        FLOAT             }
    { dpiY        FLOAT             } ;

STRUCT: D2D1_GRADIENT_STOP
    { position FLOAT        }
    { color    D2D1_COLOR_F } ;

STRUCT: D2D1_BRUSH_PROPERTIES
    { opacity   FLOAT             }
    { transform D2D1_MATRIX_3X2_F } ;

STRUCT: D2D1_BITMAP_BRUSH_PROPERTIES
    { extendModeX       D2D1_EXTEND_MODE               }
    { extendModeY       D2D1_EXTEND_MODE               }
    { interpolationMode D2D1_BITMAP_INTERPOLATION_MODE } ;

STRUCT: D2D1_LINEAR_GRADIENT_BRUSH_PROPERTIES
    { startPoint D2D1_POINT_2F }
    { endPoint   D2D1_POINT_2F } ;

STRUCT: D2D1_RADIAL_GRADIENT_BRUSH_PROPERTIES
    { center               D2D1_POINT_2F }
    { gradientOriginOffset D2D1_POINT_2F }
    { radiusX              FLOAT         }
    { radiusY              FLOAT         } ;

CONSTANT: D2D1_ARC_SIZE_SMALL 0
CONSTANT: D2D1_ARC_SIZE_LARGE 1
CONSTANT: D2D1_ARC_SIZE_FORCE_DWORD 0xffffffff
TYPEDEF: int D2D1_ARC_SIZE

CONSTANT: D2D1_CAP_STYLE_FLAT        0
CONSTANT: D2D1_CAP_STYLE_SQUARE      1
CONSTANT: D2D1_CAP_STYLE_ROUND       2
CONSTANT: D2D1_CAP_STYLE_TRIANGLE    3
CONSTANT: D2D1_CAP_STYLE_FORCE_DWORD 0xffffffff
TYPEDEF: int D2D1_CAP_STYLE

CONSTANT: D2D1_DASH_STYLE_SOLID        0
CONSTANT: D2D1_DASH_STYLE_DASH         1
CONSTANT: D2D1_DASH_STYLE_DOT          2
CONSTANT: D2D1_DASH_STYLE_DASH_DOT     3
CONSTANT: D2D1_DASH_STYLE_DASH_DOT_DOT 4
CONSTANT: D2D1_DASH_STYLE_CUSTOM       5
CONSTANT: D2D1_DASH_STYLE_FORCE_DWORD  0xffffffff
TYPEDEF: int D2D1_DASH_STYLE

CONSTANT: D2D1_LINE_JOIN_MITER          0
CONSTANT: D2D1_LINE_JOIN_BEVEL          1
CONSTANT: D2D1_LINE_JOIN_ROUND          2
CONSTANT: D2D1_LINE_JOIN_MITER_OR_BEVEL 3
CONSTANT: D2D1_LINE_JOIN_FORCE_DWORD    0xffffffff
TYPEDEF: int D2D1_LINE_JOIN

CONSTANT: D2D1_COMBINE_MODE_UNION       0
CONSTANT: D2D1_COMBINE_MODE_INTERSECT   1
CONSTANT: D2D1_COMBINE_MODE_XOR         2
CONSTANT: D2D1_COMBINE_MODE_EXCLUDE     3
CONSTANT: D2D1_COMBINE_MODE_FORCE_DWORD 0xffffffff
TYPEDEF: int D2D1_COMBINE_MODE

CONSTANT: D2D1_GEOMETRY_RELATION_UNKNOWN      0
CONSTANT: D2D1_GEOMETRY_RELATION_DISJOINT     1
CONSTANT: D2D1_GEOMETRY_RELATION_IS_CONTAINED 2
CONSTANT: D2D1_GEOMETRY_RELATION_CONTAINS     3
CONSTANT: D2D1_GEOMETRY_RELATION_OVERLAP      4
CONSTANT: D2D1_GEOMETRY_RELATION_FORCE_DWORD  0xffffffff
TYPEDEF: int D2D1_GEOMETRY_RELATION

CONSTANT: D2D1_GEOMETRY_SIMPLIFICATION_OPTION_CUBICS_AND_LINES 0
CONSTANT: D2D1_GEOMETRY_SIMPLIFICATION_OPTION_LINES            1
CONSTANT: D2D1_GEOMETRY_SIMPLIFICATION_OPTION_FORCE_DWORD      0xffffffff
TYPEDEF: int D2D1_GEOMETRY_SIMPLIFICATION_OPTION

CONSTANT: D2D1_FIGURE_BEGIN_FILLED      0
CONSTANT: D2D1_FIGURE_BEGIN_HOLLOW      1
CONSTANT: D2D1_FIGURE_BEGIN_FORCE_DWORD 0xffffffff
TYPEDEF: int D2D1_FIGURE_BEGIN

CONSTANT: D2D1_FIGURE_END_OPEN        0
CONSTANT: D2D1_FIGURE_END_CLOSED      1
CONSTANT: D2D1_FIGURE_END_FORCE_DWORD 0xffffffff
TYPEDEF: int D2D1_FIGURE_END

STRUCT: D2D1_BEZIER_SEGMENT
    { point1 D2D1_POINT_2F }
    { point2 D2D1_POINT_2F }
    { point3 D2D1_POINT_2F } ;

STRUCT: D2D1_TRIANGLE
    { point1 D2D1_POINT_2F }
    { point2 D2D1_POINT_2F }
    { point3 D2D1_POINT_2F } ;

CONSTANT: D2D1_PATH_SEGMENT_NONE                  0x00000000
CONSTANT: D2D1_PATH_SEGMENT_FORCE_UNSTROKED       0x00000001
CONSTANT: D2D1_PATH_SEGMENT_FORCE_ROUND_LINE_JOIN 0x00000002
CONSTANT: D2D1_PATH_SEGMENT_FORCE_DWORD           0xffffffff
TYPEDEF: int D2D1_PATH_SEGMENT

CONSTANT: D2D1_SWEEP_DIRECTION_COUNTER_CLOCKWISE 0
CONSTANT: D2D1_SWEEP_DIRECTION_CLOCKWISE         1
CONSTANT: D2D1_SWEEP_DIRECTION_FORCE_DWORD       0xffffffff
TYPEDEF: int D2D1_SWEEP_DIRECTION

CONSTANT: D2D1_FILL_MODE_ALTERNATE   0
CONSTANT: D2D1_FILL_MODE_WINDING     1
CONSTANT: D2D1_FILL_MODE_FORCE_DWORD 0xffffffff
TYPEDEF: int D2D1_FILL_MODE

STRUCT: D2D1_ARC_SEGMENT
    { point          D2D1_POINT_2F        }
    { size           D2D1_SIZE_F          }
    { rotationAngle  FLOAT                }
    { sweepDirection D2D1_SWEEP_DIRECTION }
    { arcSize        D2D1_ARC_SIZE        } ;

STRUCT: D2D1_QUADRATIC_BEZIER_SEGMENT
    { point1 D2D1_POINT_2F }
    { point2 D2D1_POINT_2F } ;

STRUCT: D2D1_ELLIPSE
    { point   D2D1_POINT_2F }
    { radiusX FLOAT         }
    { radiusY FLOAT         } ;

STRUCT: D2D1_ROUNDED_RECT
    { rect    D2D1_RECT_F }
    { radiusX FLOAT       }
    { radiusY FLOAT       } ;

STRUCT: D2D1_STROKE_STYLE_PROPERTIES
    { startCap   D2D1_CAP_STYLE  }
    { endCap     D2D1_CAP_STYLE  }
    { dashCap    D2D1_CAP_STYLE  }
    { lineJoin   D2D1_LINE_JOIN  }
    { miterLimit FLOAT           }
    { dashStyle  D2D1_DASH_STYLE }
    { dashOffset FLOAT           } ;

CONSTANT: D2D1_LAYER_OPTIONS_NONE                     0x00000000
CONSTANT: D2D1_LAYER_OPTIONS_INITIALIZE_FOR_CLEARTYPE 0x00000001
CONSTANT: D2D1_LAYER_OPTIONS_FORCE_DWORD              0xffffffff
TYPEDEF: int D2D1_LAYER_OPTIONS

C-TYPE: ID2D1Geometry
C-TYPE: ID2D1Brush
C-TYPE: ID2D1RenderTarget

STRUCT: D2D1_LAYER_PARAMETERS
    { contentBounds     D2D1_RECT_F         }
    { geometricMask     ID2D1Geometry*      }
    { maskAntialiasMode D2D1_ANTIALIAS_MODE }
    { maskTransform     D2D1_MATRIX_3X2_F   }
    { opacity           FLOAT               }
    { opacityBrush      ID2D1Brush*         }
    { layerOptions      D2D1_LAYER_OPTIONS  } ;

CONSTANT: D2D1_WINDOW_STATE_NONE        0x00000000
CONSTANT: D2D1_WINDOW_STATE_OCCLUDED    0x00000001
CONSTANT: D2D1_WINDOW_STATE_FORCE_DWORD 0xffffffff
TYPEDEF: int D2D1_WINDOW_STATE

CONSTANT: D2D1_RENDER_TARGET_TYPE_DEFAULT     0
CONSTANT: D2D1_RENDER_TARGET_TYPE_SOFTWARE    1
CONSTANT: D2D1_RENDER_TARGET_TYPE_HARDWARE    2
CONSTANT: D2D1_RENDER_TARGET_TYPE_FORCE_DWORD 0xffffffff
TYPEDEF: int D2D1_RENDER_TARGET_TYPE

CONSTANT: D2D1_FEATURE_LEVEL_DEFAULT     0
CONSTANT: D2D1_FEATURE_LEVEL_9           0x9100
CONSTANT: D2D1_FEATURE_LEVEL_10          0xa000
CONSTANT: D2D1_FEATURE_LEVEL_FORCE_DWORD 0xffffffff
TYPEDEF: int D2D1_FEATURE_LEVEL

CONSTANT: D2D1_RENDER_TARGET_USAGE_NONE                  0x00000000
CONSTANT: D2D1_RENDER_TARGET_USAGE_FORCE_BITMAP_REMOTING 0x00000001
CONSTANT: D2D1_RENDER_TARGET_USAGE_GDI_COMPATIBLE        0x00000002
CONSTANT: D2D1_RENDER_TARGET_USAGE_FORCE_DWORD           0xffffffff
TYPEDEF: int D2D1_RENDER_TARGET_USAGE

CONSTANT: D2D1_PRESENT_OPTIONS_NONE            0x00000000
CONSTANT: D2D1_PRESENT_OPTIONS_RETAIN_CONTENTS 0x00000001
CONSTANT: D2D1_PRESENT_OPTIONS_IMMEDIATELY     0x00000002
CONSTANT: D2D1_PRESENT_OPTIONS_FORCE_DWORD     0xffffffff
TYPEDEF: int D2D1_PRESENT_OPTIONS

STRUCT: D2D1_RENDER_TARGET_PROPERTIES
    { type        D2D1_RENDER_TARGET_TYPE  }
    { pixelFormat D2D1_PIXEL_FORMAT        }
    { dpiX        FLOAT                    }
    { dpiY        FLOAT                    }
    { usage       D2D1_RENDER_TARGET_USAGE }
    { minLevel    D2D1_FEATURE_LEVEL       } ;

STRUCT: D2D1_HWND_RENDER_TARGET_PROPERTIES
    { hwnd           HWND                 }
    { pixelSize      D2D1_SIZE_U          }
    { presentOptions D2D1_PRESENT_OPTIONS } ;

CONSTANT: D2D1_COMPATIBLE_RENDER_TARGET_OPTIONS_NONE           0x00000000
CONSTANT: D2D1_COMPATIBLE_RENDER_TARGET_OPTIONS_GDI_COMPATIBLE 0x00000001
CONSTANT: D2D1_COMPATIBLE_RENDER_TARGET_OPTIONS_FORCE_DWORD    0xffffffff
TYPEDEF: int D2D1_COMPATIBLE_RENDER_TARGET_OPTIONS

STRUCT: D2D1_DRAWING_STATE_DESCRIPTION
    { antialiasMode     D2D1_ANTIALIAS_MODE      }
    { textAntialiasMode D2D1_TEXT_ANTIALIAS_MODE }
    { tag1              D2D1_TAG                 }
    { tag2              D2D1_TAG                 }
    { transform         D2D1_MATRIX_3X2_F        } ;

CONSTANT: D2D1_DC_INITIALIZE_MODE_COPY        0
CONSTANT: D2D1_DC_INITIALIZE_MODE_CLEAR       1
CONSTANT: D2D1_DC_INITIALIZE_MODE_FORCE_DWORD 0xffffffff
TYPEDEF: int D2D1_DC_INITIALIZE_MODE

CONSTANT: D2D1_DEBUG_LEVEL_NONE        0
CONSTANT: D2D1_DEBUG_LEVEL_ERROR       1
CONSTANT: D2D1_DEBUG_LEVEL_WARNING     2
CONSTANT: D2D1_DEBUG_LEVEL_INFORMATION 3
CONSTANT: D2D1_DEBUG_LEVEL_FORCE_DWORD 0xffffffff
TYPEDEF: int D2D1_DEBUG_LEVEL

CONSTANT: D2D1_FACTORY_TYPE_SINGLE_THREADED 0
CONSTANT: D2D1_FACTORY_TYPE_MULTI_THREADED  1
CONSTANT: D2D1_FACTORY_TYPE_FORCE_DWORD     0xffffffff
TYPEDEF: int D2D1_FACTORY_TYPE

STRUCT: D2D1_FACTORY_OPTIONS
    { debugLevel D2D1_DEBUG_LEVEL } ;

C-TYPE: ID2D1Factory
C-TYPE: ID2D1BitmapRenderTarget

COM-INTERFACE: ID2D1Resource IUnknown {2cd90691-12e2-11dc-9fed-001143a055f9}
    void GetFactory ( ID2D1Factory** factory ) ;

COM-INTERFACE: ID2D1Bitmap ID2D1Resource {a2296057-ea42-4099-983b-539fb6505426}
    D2D1_SIZE_F GetSize ( )
    D2D1_SIZE_U GetPixelSize ( )
    D2D1_PIXEL_FORMAT GetPixelFormat ( )
    void GetDpi ( FLOAT* dpiX, FLOAT* dpiY )
    HRESULT CopyFromBitmap ( D2D1_POINT_2U* destPoint, ID2D1Bitmap* bitmap, D2D1_RECT_U* srcRect )
    HRESULT CopyFromRenderTarget ( D2D1_POINT_2U* destPoint, ID2D1RenderTarget* renderTarget, D2D1_RECT_U* srcRect )
    HRESULT CopyFromMemory ( D2D1_RECT_U* dstRect, void* srcData, UINT32 pitch ) ;

COM-INTERFACE: ID2D1GradientStopCollection ID2D1Resource {2cd906a7-12e2-11dc-9fed-001143a055f9}
    UINT32 GetGradientStopCount ( )
    void GetGradientStops ( D2D1_GRADIENT_STOP* gradientStops, UINT gradientStopsCount )
    D2D1_GAMMA GetColorInterpolationGamma ( )
    D2D1_EXTEND_MODE GetExtendMode ( ) ;

COM-INTERFACE: ID2D1Brush ID2D1Resource {2cd906a8-12e2-11dc-9fed-001143a055f9}
    void SetOpacity ( FLOAT opacity )
    void SetTransform ( D2D1_MATRIX_3X2_F* transform )
    FLOAT GetOpacity ( )
    void GetTransform ( D2D1_MATRIX_3X2_F* transform ) ;

COM-INTERFACE: ID2D1BitmapBrush ID2D1Brush {2cd906aa-12e2-11dc-9fed-001143a055f9}
    void SetExtendModeX ( D2D1_EXTEND_MODE extendModeX )
    void SetExtendModeY ( D2D1_EXTEND_MODE extendModeY )
    void SetInterpolationMode ( D2D1_BITMAP_INTERPOLATION_MODE interpolationMode )
    void SetBitmap ( ID2D1Bitmap* bitmap )
    D2D1_EXTEND_MODE GetExtendModeX ( )
    D2D1_EXTEND_MODE GetExtendModeY ( )
    D2D1_BITMAP_INTERPOLATION_MODE GetInterpolationMode ( )
    void GetBitmap ( ID2D1Bitmap** bitmap ) ;

COM-INTERFACE: ID2D1SolidColorBrush ID2D1Brush {2cd906a9-12e2-11dc-9fed-001143a055f9}
    void SetColor ( D2D1_COLOR_F* color )
    D2D1_COLOR_F GetColor ( ) ;

COM-INTERFACE: ID2D1LinearGradientBrush ID2D1Brush {2cd906ab-12e2-11dc-9fed-001143a055f9}
    void SetStartPoint ( D2D1_POINT_2F startPoint )
    void SetEndPoint ( D2D1_POINT_2F endPoint )
    D2D1_POINT_2F GetStartPoint ( )
    D2D1_POINT_2F GetEndPoint ( )
    void GetGradientStopCollection ( ID2D1GradientStopCollection** gradientStopCollection ) ;

COM-INTERFACE: ID2D1RadialGradientBrush ID2D1Brush {2cd906ac-12e2-11dc-9fed-001143a055f9}
    void SetCenter ( D2D1_POINT_2F center )
    void SetGradientOriginOffset ( D2D1_POINT_2F gradientOriginOffset )
    void SetRadiusX ( FLOAT radiusX )
    void SetRadiusY ( FLOAT radiusY )
    D2D1_POINT_2F GetCenter ( )
    D2D1_POINT_2F GetGradientOriginOffset ( )
    FLOAT GetRadiusX ( )
    FLOAT GetRadiusY ( )
    void GetGradientStopCollection ( ID2D1GradientStopCollection** gradientStopCollection ) ;

COM-INTERFACE: ID2D1StrokeStyle ID2D1Resource {2cd9069d-12e2-11dc-9fed-001143a055f9}
    D2D1_CAP_STYLE GetStartCap ( )
    D2D1_CAP_STYLE GetEndCap ( )
    D2D1_CAP_STYLE GetDashCap ( )
    FLOAT GetMiterLimit ( )
    D2D1_LINE_JOIN GetLineJoin ( )
    FLOAT GetDashOffset ( )
    D2D1_DASH_STYLE GetDashStyle ( )
    UINT32 GetDashesCount ( )
    void GetDashes ( FLOAT* dashes, UINT dashesCount ) ;

C-TYPE: ID2D1SimplifiedGeometrySink
C-TYPE: ID2D1TessellationSink

COM-INTERFACE: ID2D1Geometry ID2D1Resource {2cd906a1-12e2-11dc-9fed-001143a055f9}
    HRESULT GetBounds ( D2D1_MATRIX_3X2_F* worldTransform, D2D1_RECT_F* bounds )
    HRESULT GetWidenedBounds ( FLOAT strokeWidth, ID2D1StrokeStyle* strokeStyle, D2D1_MATRIX_3X2_F* worldTransform, FLOAT flatteningTolerance, D2D1_RECT_F* bounds )
    HRESULT StrokeContainsPoint ( D2D1_POINT_2F point, FLOAT strokeWidth, ID2D1StrokeStyle* strokeStyle, D2D1_MATRIX_3X2_F* worldTransform, FLOAT flatteningTolerance, BOOL* contains )
    HRESULT FillContainsPoint ( D2D1_POINT_2F point, D2D1_MATRIX_3X2_F* worldTransform, FLOAT flatteningTolerance, BOOL* contains )
    HRESULT CompareWithGeometry ( ID2D1Geometry* inputGeometry, D2D1_MATRIX_3X2_F* inputGeometryTransform, FLOAT flatteningTolerance, D2D1_GEOMETRY_RELATION* relation )
    HRESULT Simplify ( D2D1_GEOMETRY_SIMPLIFICATION_OPTION simplificationOption, D2D1_MATRIX_3X2_F* worldTransform, FLOAT flatteningTolerance, ID2D1SimplifiedGeometrySink* geometrySink )
    HRESULT Tessellate ( D2D1_MATRIX_3X2_F* worldTransform, FLOAT flatteningTolerance, ID2D1TessellationSink* tessellationSink )
    HRESULT CombineWithGeometry ( ID2D1Geometry* inputGeometry, D2D1_COMBINE_MODE combineMode, D2D1_MATRIX_3X2_F* inputGeometryTransform, FLOAT flatteningTolerance, ID2D1SimplifiedGeometrySink* geometrySink )
    HRESULT Outline ( D2D1_MATRIX_3X2_F* worldTransform, FLOAT flatteningTolerance, ID2D1SimplifiedGeometrySink* geometrySink )
    HRESULT ComputeArea ( D2D1_MATRIX_3X2_F* worldTransform, FLOAT flatteningTolerance, FLOAT* area )
    HRESULT ComputeLength ( D2D1_MATRIX_3X2_F* worldTransform, FLOAT flatteningTolerance, FLOAT* length )
    HRESULT ComputePointAtLength ( FLOAT length, D2D1_MATRIX_3X2_F* worldTransform, FLOAT flatteningTolerance, D2D1_POINT_2F* point, D2D1_POINT_2F* unitTangentVector )
    HRESULT Widen ( FLOAT strokeWidth, ID2D1StrokeStyle* strokeStyle, D2D1_MATRIX_3X2_F* worldTransform, FLOAT flatteningTolerance, ID2D1SimplifiedGeometrySink* geometrySink ) ;

COM-INTERFACE: ID2D1RectangleGeometry ID2D1Geometry {2cd906a2-12e2-11dc-9fed-001143a055f9}
    void GetRect ( D2D1_RECT_F* rect ) ;

COM-INTERFACE: ID2D1RoundedRectangleGeometry ID2D1Geometry {2cd906a3-12e2-11dc-9fed-001143a055f9}
    void GetRoundedRect ( D2D1_ROUNDED_RECT* roundedRect ) ;

COM-INTERFACE: ID2D1EllipseGeometry ID2D1Geometry {2cd906a4-12e2-11dc-9fed-001143a055f9}
    void GetEllipse ( D2D1_ELLIPSE* ellipse ) ;

COM-INTERFACE: ID2D1GeometryGroup ID2D1Geometry {2cd906a6-12e2-11dc-9fed-001143a055f9}
    D2D1_FILL_MODE GetFillMode ( )
    UINT32 GetSourceGeometryCount ( )
    void GetSourceGeometries ( ID2D1Geometry** geometries, UINT geometriesCount ) ;

COM-INTERFACE: ID2D1TransformedGeometry ID2D1Geometry {2cd906bb-12e2-11dc-9fed-001143a055f9}
    void GetSourceGeometry ( ID2D1Geometry** sourceGeometry )
    void GetTransform ( D2D1_MATRIX_3X2_F* transform ) ;

COM-INTERFACE: ID2D1SimplifiedGeometrySink IUnknown {2cd9069e-12e2-11dc-9fed-001143a055f9}
    void SetFillMode ( D2D1_FILL_MODE fillMode )
    void SetSegmentFlags ( D2D1_PATH_SEGMENT vertexFlags )
    void BeginFigure ( D2D1_POINT_2F startPoint, D2D1_FIGURE_BEGIN figureBegin )
    void AddLines ( D2D1_POINT_2F* points, UINT pointsCount )
    void AddBeziers ( D2D1_BEZIER_SEGMENT* beziers, UINT beziersCount )
    void EndFigure ( D2D1_FIGURE_END figureEnd )
    HRESULT Close ( ) ;

COM-INTERFACE: ID2D1GeometrySink ID2D1SimplifiedGeometrySink {2cd9069f-12e2-11dc-9fed-001143a055f9}
    void AddLine ( D2D1_POINT_2F point )
    void AddBezier ( D2D1_BEZIER_SEGMENT* bezier )
    void AddQuadraticBezier ( D2D1_QUADRATIC_BEZIER_SEGMENT* bezier )
    void AddQuadraticBeziers ( D2D1_QUADRATIC_BEZIER_SEGMENT* beziers, UINT beziersCount )
    void AddArc ( D2D1_ARC_SEGMENT* arc ) ;

COM-INTERFACE: ID2D1TessellationSink IUnknown {2cd906c1-12e2-11dc-9fed-001143a055f9}
    void AddTriangles ( D2D1_TRIANGLE* triangles, UINT trianglesCount )
    HRESULT Close ( ) ;

COM-INTERFACE: ID2D1PathGeometry ID2D1Geometry {2cd906a5-12e2-11dc-9fed-001143a055f9}
    HRESULT Open ( ID2D1GeometrySink** geometrySink )
    HRESULT Stream ( ID2D1GeometrySink* geometrySink )
    HRESULT GetSegmentCount ( UINT32* count )
    HRESULT GetFigureCount ( UINT32* count ) ;

COM-INTERFACE: ID2D1Mesh ID2D1Resource {2cd906c2-12e2-11dc-9fed-001143a055f9}
    HRESULT Open ( ID2D1TessellationSink** tessellationSink ) ;

COM-INTERFACE: ID2D1Layer ID2D1Resource {2cd9069b-12e2-11dc-9fed-001143a055f9}
    D2D1_SIZE_F GetSize ( ) ;

C-TYPE: IDWriteRenderingParams

COM-INTERFACE: ID2D1DrawingStateBlock ID2D1Resource {28506e39-ebf6-46a1-bb47-fd85565ab957}
    void GetDescription ( D2D1_DRAWING_STATE_DESCRIPTION* stateDescription )
    void SetDescription ( D2D1_DRAWING_STATE_DESCRIPTION* stateDescription )
    void SetTextRenderingParams ( IDWriteRenderingParams* textRenderingParams )
    void GetTextRenderingParams ( IDWriteRenderingParams** textRenderingParams ) ;

C-TYPE: IWICBitmapSource
C-TYPE: IWICBitmap
C-TYPE: IDWriteTextFormat
C-TYPE: IDWriteTextLayout
C-TYPE: DWRITE_GLYPH_RUN

COM-INTERFACE: ID2D1RenderTarget ID2D1Resource {2cd90694-12e2-11dc-9fed-001143a055f9}
    HRESULT CreateBitmap ( D2D1_SIZE_U size, void* srcData, UINT32 pitch, D2D1_BITMAP_PROPERTIES* bitmapProperties, ID2D1Bitmap** bitmap )
    HRESULT CreateBitmapFromWicBitmap ( IWICBitmapSource* wicBitmapSource, D2D1_BITMAP_PROPERTIES* bitmapProperties, ID2D1Bitmap** bitmap )
    HRESULT CreateSharedBitmap ( REFIID riid, void* data, D2D1_BITMAP_PROPERTIES* bitmapProperties, ID2D1Bitmap** bitmap )
    HRESULT CreateBitmapBrush ( ID2D1Bitmap* bitmap, D2D1_BITMAP_BRUSH_PROPERTIES* bitmapBrushProperties, D2D1_BRUSH_PROPERTIES* brushProperties, ID2D1BitmapBrush** bitmapBrush )
    HRESULT CreateSolidColorBrush ( D2D1_COLOR_F* color, D2D1_BRUSH_PROPERTIES* brushProperties, ID2D1SolidColorBrush** solidColorBrush )
    HRESULT CreateGradientStopCollection ( D2D1_GRADIENT_STOP* gradientStops, UINT gradientStopsCount, D2D1_GAMMA colorInterpolationGamma, D2D1_EXTEND_MODE extendMode, ID2D1GradientStopCollection** gradientStopCollection )
    HRESULT CreateLinearGradientBrush ( D2D1_LINEAR_GRADIENT_BRUSH_PROPERTIES* linearGradientBrushProperties, D2D1_BRUSH_PROPERTIES* brushProperties, ID2D1GradientStopCollection* gradientStopCollection, ID2D1LinearGradientBrush** linearGradientBrush )
    HRESULT CreateRadialGradientBrush ( D2D1_RADIAL_GRADIENT_BRUSH_PROPERTIES* radialGradientBrushProperties, D2D1_BRUSH_PROPERTIES* brushProperties, ID2D1GradientStopCollection* gradientStopCollection, ID2D1RadialGradientBrush** radialGradientBrush )
    HRESULT CreateCompatibleRenderTarget ( D2D1_SIZE_F* desiredSize, D2D1_SIZE_U* desiredPixelSize, D2D1_PIXEL_FORMAT* desiredFormat, D2D1_COMPATIBLE_RENDER_TARGET_OPTIONS options, ID2D1BitmapRenderTarget** bitmapRenderTarget )
    HRESULT CreateLayer ( D2D1_SIZE_F* size, ID2D1Layer** layer )
    HRESULT CreateMesh ( ID2D1Mesh** mesh )
    void DrawLine ( D2D1_POINT_2F point0, D2D1_POINT_2F point1, ID2D1Brush* brush, FLOAT strokeWidth, ID2D1StrokeStyle* strokeStyle )
    void DrawRectangle ( D2D1_RECT_F* rect, ID2D1Brush* brush, FLOAT strokeWidth, ID2D1StrokeStyle* strokeStyle )
    void FillRectangle ( D2D1_RECT_F* rect, ID2D1Brush* brush )
    void DrawRoundedRectangle ( D2D1_ROUNDED_RECT* roundedRect, ID2D1Brush* brush, FLOAT strokeWidth, ID2D1StrokeStyle* strokeStyle )
    void FillRoundedRectangle ( D2D1_ROUNDED_RECT* roundedRect, ID2D1Brush* brush )
    void DrawEllipse ( D2D1_ELLIPSE* ellipse, ID2D1Brush* brush, FLOAT strokeWidth, ID2D1StrokeStyle* strokeStyle )
    void FillEllipse ( D2D1_ELLIPSE* ellipse, ID2D1Brush* brush )
    void DrawGeometry ( ID2D1Geometry* geometry, ID2D1Brush* brush, FLOAT strokeWidth, ID2D1StrokeStyle* strokeStyle )
    void FillGeometry ( ID2D1Geometry* geometry, ID2D1Brush* brush, ID2D1Brush* opacityBrush )
    void FillMesh ( ID2D1Mesh* mesh, ID2D1Brush* brush )
    void FillOpacityMask ( ID2D1Bitmap* opacityMask, ID2D1Brush* brush, D2D1_OPACITY_MASK_CONTENT content, D2D1_RECT_F* destinationRectangle, D2D1_RECT_F* sourceRectangle )
    void DrawBitmap ( ID2D1Bitmap* bitmap, D2D1_RECT_F* destinationRectangle, FLOAT opacity, D2D1_BITMAP_INTERPOLATION_MODE interpolationMode, D2D1_RECT_F* sourceRectangle )
    void DrawText ( WCHAR* string, UINT stringLength, IDWriteTextFormat* textFormat, D2D1_RECT_F* layoutRect, ID2D1Brush* defaultForegroundBrush, D2D1_DRAW_TEXT_OPTIONS options, DWRITE_MEASURING_MODE measuringMode )
    void DrawTextLayout ( D2D1_POINT_2F origin, IDWriteTextLayout* textLayout, ID2D1Brush* defaultForegroundBrush, D2D1_DRAW_TEXT_OPTIONS options )
    void DrawGlyphRun ( D2D1_POINT_2F baselineOrigin, DWRITE_GLYPH_RUN* glyphRun, ID2D1Brush* foregroundBrush, DWRITE_MEASURING_MODE measuringMode )
    void SetTransform ( D2D1_MATRIX_3X2_F* transform )
    void GetTransform ( D2D1_MATRIX_3X2_F* transform )
    void SetAntialiasMode ( D2D1_ANTIALIAS_MODE antialiasMode )
    D2D1_ANTIALIAS_MODE GetAntialiasMode ( )
    void SetTextAntialiasMode ( D2D1_TEXT_ANTIALIAS_MODE textAntialiasMode )
    D2D1_TEXT_ANTIALIAS_MODE GetTextAntialiasMode ( )
    void SetTextRenderingParams ( IDWriteRenderingParams* textRenderingParams )
    void GetTextRenderingParams ( IDWriteRenderingParams** textRenderingParams )
    void SetTags ( D2D1_TAG tag1, D2D1_TAG tag2 )
    void GetTags ( D2D1_TAG* tag1, D2D1_TAG* tag2 )
    void PushLayer ( D2D1_LAYER_PARAMETERS* layerParameters, ID2D1Layer* layer )
    void PopLayer ( )
    HRESULT Flush ( D2D1_TAG* tag1, D2D1_TAG* tag2 )
    void SaveDrawingState ( ID2D1DrawingStateBlock* drawingStateBlock )
    void RestoreDrawingState ( ID2D1DrawingStateBlock* drawingStateBlock )
    void PushAxisAlignedClip ( D2D1_RECT_F* clipRect, D2D1_ANTIALIAS_MODE antialiasMode )
    void PopAxisAlignedClip ( )
    void Clear ( D2D1_COLOR_F* clearColor )
    void BeginDraw ( )
    HRESULT EndDraw ( D2D1_TAG* tag1, D2D1_TAG* tag2 )
    D2D1_PIXEL_FORMAT GetPixelFormat ( )
    void SetDpi ( FLOAT dpiX, FLOAT dpiY )
    void GetDpi ( FLOAT* dpiX, FLOAT* dpiY )
    D2D1_SIZE_F GetSize ( )
    D2D1_SIZE_U GetPixelSize ( )
    UINT32 GetMaximumBitmapSize ( )
    BOOL IsSupported ( D2D1_RENDER_TARGET_PROPERTIES* renderTargetProperties ) ;

COM-INTERFACE: ID2D1BitmapRenderTarget ID2D1RenderTarget {2cd90695-12e2-11dc-9fed-001143a055f9}
    HRESULT GetBitmap ( ID2D1Bitmap** bitmap ) ;

COM-INTERFACE: ID2D1HwndRenderTarget ID2D1RenderTarget {2cd90698-12e2-11dc-9fed-001143a055f9}
    D2D1_WINDOW_STATE CheckWindowState ( )
    HRESULT Resize ( D2D1_SIZE_U* pixelSize )
    HWND GetHwnd ( ) ;

COM-INTERFACE: ID2D1GdiInteropRenderTarget IUnknown {e0db51c3-6f77-4bae-b3d5-e47509b35838}
    HRESULT GetDC ( D2D1_DC_INITIALIZE_MODE mode, HDC* hdc )
    HRESULT ReleaseDC ( RECT* update ) ;

COM-INTERFACE: ID2D1DCRenderTarget ID2D1RenderTarget {1c51bc64-de61-46fd-9899-63a5d8f03950}
    HRESULT BindDC ( HDC hDC, RECT* pSubRect ) ;

COM-INTERFACE: ID2D1Factory IUnknown {06152247-6f50-465a-9245-118bfd3b6007}
    HRESULT ReloadSystemMetrics ( )
    void GetDesktopDpi ( FLOAT* dpiX, FLOAT* dpiY )
    HRESULT CreateRectangleGeometry ( D2D1_RECT_F* rectangle, ID2D1RectangleGeometry** rectangleGeometry )
    HRESULT CreateRoundedRectangleGeometry ( D2D1_ROUNDED_RECT* roundedRectangle, ID2D1RoundedRectangleGeometry** roundedRectangleGeometry )
    HRESULT CreateEllipseGeometry ( D2D1_ELLIPSE* ellipse, ID2D1EllipseGeometry** ellipseGeometry )
    HRESULT CreateGeometryGroup ( D2D1_FILL_MODE fillMode, ID2D1Geometry** geometries, UINT geometriesCount, ID2D1GeometryGroup** geometryGroup )
    HRESULT CreateTransformedGeometry ( ID2D1Geometry* sourceGeometry, D2D1_MATRIX_3X2_F* transform, ID2D1TransformedGeometry** transformedGeometry )
    HRESULT CreatePathGeometry ( ID2D1PathGeometry** pathGeometry )
    HRESULT CreateStrokeStyle ( D2D1_STROKE_STYLE_PROPERTIES* strokeStyleProperties, FLOAT* dashes, UINT dashesCount, ID2D1StrokeStyle** strokeStyle )
    HRESULT CreateDrawingStateBlock ( D2D1_DRAWING_STATE_DESCRIPTION* drawingStateDescription, IDWriteRenderingParams* textRenderingParams, ID2D1DrawingStateBlock** drawingStateBlock )
    HRESULT CreateWicBitmapRenderTarget ( IWICBitmap* target, D2D1_RENDER_TARGET_PROPERTIES* renderTargetProperties, ID2D1RenderTarget** renderTarget )
    HRESULT CreateHwndRenderTarget ( D2D1_RENDER_TARGET_PROPERTIES* renderTargetProperties, D2D1_HWND_RENDER_TARGET_PROPERTIES* hwndRenderTargetProperties, ID2D1HwndRenderTarget** hwndRenderTarget )
    HRESULT CreateDxgiSurfaceRenderTarget ( IDXGISurface* dxgiSurface, D2D1_RENDER_TARGET_PROPERTIES* renderTargetProperties, ID2D1RenderTarget** renderTarget )
    HRESULT CreateDCRenderTarget ( D2D1_RENDER_TARGET_PROPERTIES* renderTargetProperties, ID2D1DCRenderTarget** dcRenderTarget ) ;

FUNCTION: HRESULT D2D1CreateFactory (
        D2D1_FACTORY_TYPE     factoryType,
        REFIID                riid,
        D2D1_FACTORY_OPTIONS* pFactoryOptions,
        void**                ppIFactory )

FUNCTION: void D2D1MakeRotateMatrix (
        FLOAT              angle,
        D2D1_POINT_2F      center,
        D2D1_MATRIX_3X2_F* matrix )

FUNCTION: void D2D1MakeSkewMatrix (
        FLOAT              angleX,
        FLOAT              angleY,
        D2D1_POINT_2F      center,
        D2D1_MATRIX_3X2_F* matrix )

FUNCTION: BOOL D2D1IsMatrixInvertible (
        D2D1_MATRIX_3X2_F* matrix )

FUNCTION: BOOL D2D1InvertMatrix (
        D2D1_MATRIX_3X2_F* matrix )
