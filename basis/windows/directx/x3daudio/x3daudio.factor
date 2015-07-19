USING: alien.c-types alien.syntax classes.struct windows.directx
windows.directx.d3dx10math windows.types ;
IN: windows.directx.x3daudio

LIBRARY: x3daudio

CONSTANT: X3DAUDIO_HANDLE_BYTESIZE 20

CONSTANT: X3DAUDIO_PI  3.141592654
CONSTANT: X3DAUDIO_2PI 6.283185307

CONSTANT: X3DAUDIO_SPEED_OF_SOUND 343.5

CONSTANT: X3DAUDIO_CALCULATE_MATRIX          0x00000001
CONSTANT: X3DAUDIO_CALCULATE_DELAY           0x00000002
CONSTANT: X3DAUDIO_CALCULATE_LPF_DIRECT      0x00000004
CONSTANT: X3DAUDIO_CALCULATE_LPF_REVERB      0x00000008
CONSTANT: X3DAUDIO_CALCULATE_REVERB          0x00000010
CONSTANT: X3DAUDIO_CALCULATE_DOPPLER         0x00000020
CONSTANT: X3DAUDIO_CALCULATE_EMITTER_ANGLE   0x00000040
CONSTANT: X3DAUDIO_CALCULATE_ZEROCENTER      0x00010000
CONSTANT: X3DAUDIO_CALCULATE_REDIRECT_TO_LFE 0x00020000

TYPEDEF: float FLOAT32
TYPEDEF: D3DVECTOR X3DAUDIO_VECTOR

TYPEDEF: BYTE[20] X3DAUDIO_HANDLE

STRUCT: X3DAUDIO_DISTANCE_CURVE_POINT
    { Distance   FLOAT32 }
    { DSPSetting FLOAT32 } ;
TYPEDEF: X3DAUDIO_DISTANCE_CURVE_POINT* LPX3DAUDIO_DISTANCE_CURVE_POINT

STRUCT: X3DAUDIO_DISTANCE_CURVE
    { pPoints                            X3DAUDIO_DISTANCE_CURVE_POINT* }
    { PointCount                         UINT32                         } ;
TYPEDEF: X3DAUDIO_DISTANCE_CURVE* LPX3DAUDIO_DISTANCE_CURVE

STRUCT: X3DAUDIO_CONE
    { InnerAngle  FLOAT32 }
    { OuterAngle  FLOAT32 }
    { InnerVolume FLOAT32 }
    { OuterVolume FLOAT32 }
    { InnerLPF    FLOAT32 }
    { OuterLPF    FLOAT32 }
    { InnerReverb FLOAT32 }
    { OuterReverb FLOAT32 } ;
TYPEDEF: X3DAUDIO_CONE* LPX3DAUDIO_CONE

STRUCT: X3DAUDIO_LISTENER
    { OrientFront X3DAUDIO_VECTOR }
    { OrientTop   X3DAUDIO_VECTOR }
    { Position    X3DAUDIO_VECTOR }
    { Velocity    X3DAUDIO_VECTOR }
    { pCone       X3DAUDIO_CONE*  } ;
TYPEDEF: X3DAUDIO_LISTENER* LPX3DAUDIO_LISTENER

STRUCT: X3DAUDIO_EMITTER
    { pCone               X3DAUDIO_CONE*           }
    { OrientFront         X3DAUDIO_VECTOR          }
    { OrientTop           X3DAUDIO_VECTOR          }
    { Position            X3DAUDIO_VECTOR          }
    { Velocity            X3DAUDIO_VECTOR          }
    { InnerRadius         FLOAT32                  }
    { InnerRadiusAngle    FLOAT32                  }
    { ChannelCount        UINT32                   }
    { ChannelRadius       FLOAT32                  }
    { pChannelAzimuths    FLOAT32*                 }
    { pVolumeCurve        X3DAUDIO_DISTANCE_CURVE* }
    { pLFECurve           X3DAUDIO_DISTANCE_CURVE* }
    { pLPFDirectCurve     X3DAUDIO_DISTANCE_CURVE* }
    { pLPFReverbCurve     X3DAUDIO_DISTANCE_CURVE* }
    { pReverbCurve        X3DAUDIO_DISTANCE_CURVE* }
    { CurveDistanceScaler FLOAT32                  }
    { DopplerScaler       FLOAT32                  } ;
TYPEDEF: X3DAUDIO_EMITTER* LPX3DAUDIO_EMITTER

STRUCT: X3DAUDIO_DSP_SETTINGS
    { pMatrixCoefficients       FLOAT32* }
    { pDelayTimes               FLOAT32* }
    { SrcChannelCount           UINT32   }
    { DstChannelCount           UINT32   }
    { LPFDirectCoefficient      FLOAT32  }
    { LPFReverbCoefficient      FLOAT32  }
    { ReverbLevel               FLOAT32  }
    { DopplerFactor             FLOAT32  }
    { EmitterToListenerAngle    FLOAT32  }
    { EmitterToListenerDistance FLOAT32  }
    { EmitterVelocityComponent  FLOAT32  }
    { ListenerVelocityComponent FLOAT32  } ;
TYPEDEF: X3DAUDIO_DSP_SETTINGS* LPX3DAUDIO_DSP_SETTINGS


FUNCTION: void X3DAudioInitialize ( UINT32 SpeakerChannelMask, FLOAT32 SpeedOfSound, X3DAUDIO_HANDLE Instance )

FUNCTION: void X3DAudioCalculate ( X3DAUDIO_HANDLE Instance, X3DAUDIO_LISTENER* pListener, X3DAUDIO_EMITTER* pEmitter, UINT32 Flags, X3DAUDIO_DSP_SETTINGS* pDSPSettings )
