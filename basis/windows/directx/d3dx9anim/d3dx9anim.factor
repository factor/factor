USING: alien.c-types alien.syntax classes.struct windows.com
windows.com.syntax windows.directx windows.directx.d3d9
windows.directx.d3dx9core windows.directx.d3dx9math
windows.directx.d3dx9mesh windows.directx.d3dx9xof
windows.types ;
IN: windows.directx.d3dx9anim

LIBRARY: d3dx9

TYPEDEF: int D3DXMESHDATATYPE
CONSTANT: D3DXMESHTYPE_MESH      1
CONSTANT: D3DXMESHTYPE_PMESH     2
CONSTANT: D3DXMESHTYPE_PATCHMESH 3
CONSTANT: D3DXMESHTYPE_FORCE_DWORD 0x7fffffff

STRUCT: D3DXMESHDATA
    { Type D3DXMESHDATATYPE }
    { Mesh void*            } ;
TYPEDEF: D3DXMESHDATA* LPD3DXMESHDATA

STRUCT: D3DXMESHCONTAINER
    { Name                LPSTR                }
    { MeshData            D3DXMESHDATA         }
    { pMaterials          LPD3DXMATERIAL       }
    { pEffects            LPD3DXEFFECTINSTANCE }
    { NumMaterials        DWORD                }
    { pAdjacency          DWORD*               }
    { pSkinInfo           LPD3DXSKININFO       }
    { pNextMeshContainer  D3DXMESHCONTAINER*   } ;
TYPEDEF: D3DXMESHCONTAINER* LPD3DXMESHCONTAINER

STRUCT: D3DXFRAME
    { Name                  LPSTR               }
    { TransformationMatrix  D3DXMATRIX          }
    { pMeshContainer        LPD3DXMESHCONTAINER }
    { pFrameSibling         D3DXFRAME*          }
    { pFrameFirstChild      D3DXFRAME*          } ;
TYPEDEF: D3DXFRAME* LPD3DXFRAME

C-TYPE: ID3DXAllocateHierarchy
TYPEDEF: ID3DXAllocateHierarchy* LPD3DXALLOCATEHIERARCHY

COM-INTERFACE: ID3DXAllocateHierarchy f {00000000-0000-0000-0000-000000000000}
    HRESULT CreateFrame ( LPCSTR Name, LPD3DXFRAME* ppNewFrame )
    HRESULT CreateMeshContainer (
        LPCSTR               Name,
        D3DXMESHDATA*        pMeshData,
        D3DXMATERIAL*        pMaterials,
        D3DXEFFECTINSTANCE*  pEffectInstances,
        DWORD                NumMaterials,
        DWORD*               pAdjacency,
        LPD3DXSKININFO       pSkinInfo,
        LPD3DXMESHCONTAINER* ppNewMeshContainer )
    HRESULT DestroyFrame ( LPD3DXFRAME pFrameToFree )
    HRESULT DestroyMeshContainer ( LPD3DXMESHCONTAINER pMeshContainerToFree )  ;

C-TYPE: ID3DXLoadUserData
TYPEDEF: ID3DXLoadUserData* LPD3DXLOADUSERDATA

COM-INTERFACE: ID3DXLoadUserData f {00000000-0000-0000-0000-000000000000}
    HRESULT LoadTopLevelData ( LPD3DXFILEDATA pXofChildData )
    HRESULT LoadFrameChildData ( LPD3DXFRAME pFrame,
                                 LPD3DXFILEDATA pXofChildData )
    HRESULT LoadMeshChildData ( LPD3DXMESHCONTAINER pMeshContainer,
                                LPD3DXFILEDATA pXofChildData ) ;

C-TYPE: ID3DXSaveUserData
TYPEDEF: ID3DXSaveUserData* LPD3DXSAVEUSERDATA

COM-INTERFACE: ID3DXSaveUserData f {00000000-0000-0000-0000-000000000000}
    HRESULT AddFrameChildData (
        D3DXFRAME*           pFrame,
        LPD3DXFILESAVEOBJECT pXofSave,
        LPD3DXFILESAVEDATA   pXofFrameData )

    HRESULT AddMeshChildData (
        D3DXMESHCONTAINER*   pMeshContainer,
        LPD3DXFILESAVEOBJECT pXofSave,
        LPD3DXFILESAVEDATA   pXofMeshData )
    HRESULT AddTopLevelDataObjectsPre ( LPD3DXFILESAVEOBJECT pXofSave )
    HRESULT AddTopLevelDataObjectsPost ( LPD3DXFILESAVEOBJECT pXofSave )
    HRESULT RegisterTemplates ( LPD3DXFILE pXFileApi )
    HRESULT SaveTemplates ( LPD3DXFILESAVEOBJECT pXofSave ) ;

TYPEDEF: int D3DXCALLBACK_SEARCH_FLAGS
CONSTANT: D3DXCALLBACK_SEARCH_EXCLUDING_INITIAL_POSITION 1
CONSTANT: D3DXCALLBACK_SEARCH_BEHIND_INITIAL_POSITION    2
CONSTANT: D3DXCALLBACK_SEARCH_FORCE_DWORD                0x7fffffff

C-TYPE: ID3DXAnimationSet
TYPEDEF: ID3DXAnimationSet* LPD3DXANIMATIONSET

COM-INTERFACE: ID3DXAnimationSet IUnknown {698CFB3F-9289-4d95-9A57-33A94B5A65F9}
    LPCSTR GetName ( )
    double GetPeriod ( )
    double GetPeriodicPosition ( double Position )
    UINT GetNumAnimations ( )
    HRESULT GetAnimationNameByIndex ( UINT Index, LPCSTR* ppName )
    HRESULT GetAnimationIndexByName ( LPCSTR pName, UINT* pIndex )
    HRESULT GetSRT (
        double          PeriodicPosition,
        UINT            Animation,
        D3DXVECTOR3*    pScale,
        D3DXQUATERNION* pRotation,
        D3DXVECTOR3*    pTranslation )
    HRESULT GetCallback (
        double  Position,
        DWORD   Flags,
        double* pCallbackPosition,
        LPVOID* ppCallbackData ) ;

TYPEDEF: int D3DXPLAYBACK_TYPE
CONSTANT: D3DXPLAY_LOOP          0
CONSTANT: D3DXPLAY_ONCE          1
CONSTANT: D3DXPLAY_PINGPONG      2
CONSTANT: D3DXPLAY_FORCE_DWORD   0x7fffffff

STRUCT: D3DXKEY_VECTOR3
    { Time  FLOAT       }
    { Value D3DXVECTOR3 } ;
TYPEDEF: D3DXKEY_VECTOR3* LPD3DXKEY_VECTOR3

STRUCT: D3DXKEY_QUATERNION
    { Time  FLOAT          }
    { Value D3DXQUATERNION } ;
TYPEDEF: D3DXKEY_QUATERNION* LPD3DXKEY_QUATERNION

STRUCT: D3DXKEY_CALLBACK
    { Time          FLOAT  }
    { pCallbackData LPVOID } ;
TYPEDEF: D3DXKEY_CALLBACK* LPD3DXKEY_CALLBACK

TYPEDEF: int D3DXCOMPRESSION_FLAGS
CONSTANT: D3DXCOMPRESS_DEFAULT 0
CONSTANT: D3DXCOMPRESS_FORCE_DWORD 0x7fffffff

C-TYPE: ID3DXKeyframedAnimationSet
TYPEDEF: ID3DXKeyframedAnimationSet* LPD3DXKEYFRAMEDANIMATIONSET

COM-INTERFACE: ID3DXKeyframedAnimationSet ID3DXAnimationSet {FA4E8E3A-9786-407d-8B4C-5995893764AF}
    D3DXPLAYBACK_TYPE GetPlaybackType ( )
    double GetSourceTicksPerSecond ( )
    UINT GetNumScaleKeys ( UINT Animation )
    HRESULT GetScaleKeys ( UINT Animation, LPD3DXKEY_VECTOR3 pScaleKeys )
    HRESULT GetScaleKey ( UINT Animation, UINT Key, LPD3DXKEY_VECTOR3 pScaleKey )
    HRESULT SetScaleKey ( UINT Animation, UINT Key, LPD3DXKEY_VECTOR3 pScaleKey )
    UINT GetNumRotationKeys ( UINT Animation )
    HRESULT GetRotationKeys ( UINT Animation, LPD3DXKEY_QUATERNION pRotationKeys )
    HRESULT GetRotationKey ( UINT Animation, UINT Key, LPD3DXKEY_QUATERNION pRotationKey )
    HRESULT SetRotationKey ( UINT Animation, UINT Key, LPD3DXKEY_QUATERNION pRotationKey )
    UINT GetNumTranslationKeys ( UINT Animation )
    HRESULT GetTranslationKeys ( UINT Animation, LPD3DXKEY_VECTOR3 pTranslationKeys )
    HRESULT GetTranslationKey ( UINT Animation, UINT Key, LPD3DXKEY_VECTOR3 pTranslationKey )
    HRESULT SetTranslationKey ( UINT Animation, UINT Key, LPD3DXKEY_VECTOR3 pTranslationKey )
    UINT GetNumCallbackKeys ( )
    HRESULT GetCallbackKeys ( LPD3DXKEY_CALLBACK pCallbackKeys )
    HRESULT GetCallbackKey ( UINT Key, LPD3DXKEY_CALLBACK pCallbackKey )
    HRESULT SetCallbackKey ( UINT Key, LPD3DXKEY_CALLBACK pCallbackKey )
    HRESULT UnregisterScaleKey ( UINT Animation, UINT Key )
    HRESULT UnregisterRotationKey ( UINT Animation, UINT Key )
    HRESULT UnregisterTranslationKey ( UINT Animation, UINT Key )
    HRESULT RegisterAnimationSRTKeys (
        LPCSTR              pName,
        UINT                NumScaleKeys,
        UINT                NumRotationKeys,
        UINT                NumTranslationKeys,
        D3DXKEY_VECTOR3*    pScaleKeys,
        D3DXKEY_QUATERNION* pRotationKeys,
        D3DXKEY_VECTOR3*    pTranslationKeys,
        DWORD*              pAnimationIndex )
    HRESULT Compress (
        DWORD         Flags,
        FLOAT         Lossiness,
        LPD3DXFRAME   pHierarchy,
        LPD3DXBUFFER* ppCompressedData )
    HRESULT UnregisterAnimation ( UINT Index ) ;

C-TYPE: ID3DXCompressedAnimationSet
TYPEDEF: ID3DXCompressedAnimationSet* LPD3DXCOMPRESSEDANIMATIONSET

COM-INTERFACE: ID3DXCompressedAnimationSet ID3DXAnimationSet {6CC2480D-3808-4739-9F88-DE49FACD8D4C}
    D3DXPLAYBACK_TYPE GetPlaybackType ( )
    double GetSourceTicksPerSecond ( )
    HRESULT GetCompressedData ( LPD3DXBUFFER* ppCompressedData )
    UINT GetNumCallbackKeys ( )
    HRESULT GetCallbackKeys ( LPD3DXKEY_CALLBACK pCallbackKeys ) ;

TYPEDEF: int D3DXPRIORITY_TYPE
CONSTANT: D3DXPRIORITY_LOW         0
CONSTANT: D3DXPRIORITY_HIGH        1
CONSTANT: D3DXPRIORITY_FORCE_DWORD 0x7fffffff

STRUCT: D3DXTRACK_DESC
    { Priority              D3DXPRIORITY_TYPE }
    { Weight                FLOAT             }
    { Speed                 FLOAT             }
    { Position              double            }
    { Enable                BOOL              } ;
TYPEDEF: D3DXTRACK_DESC* LPD3DXTRACK_DESC

TYPEDEF: int D3DXEVENT_TYPE
CONSTANT: D3DXEVENT_TRACKSPEED    0
CONSTANT: D3DXEVENT_TRACKWEIGHT   1
CONSTANT: D3DXEVENT_TRACKPOSITION 2
CONSTANT: D3DXEVENT_TRACKENABLE   3
CONSTANT: D3DXEVENT_PRIORITYBLEND 4
CONSTANT: D3DXEVENT_FORCE_DWORD   0x7fffffff

TYPEDEF: int D3DXTRANSITION_TYPE
CONSTANT: D3DXTRANSITION_LINEAR        0
CONSTANT: D3DXTRANSITION_EASEINEASEOUT 1
CONSTANT: D3DXTRANSITION_FORCE_DWORD   0x7fffffff

UNION-STRUCT: D3DXEVENT_DESC_UNION
    { Weight            FLOAT  }
    { Speed             FLOAT  }
    { Position          double }
    { Enable            BOOL   } ;
STRUCT: D3DXEVENT_DESC
    { Type                   D3DXEVENT_TYPE       }
    { Track                  UINT                 }
    { StartTime              double               }
    { Duration               double               }
    { Transition             D3DXTRANSITION_TYPE  }
    { Union                  D3DXEVENT_DESC_UNION } ;
TYPEDEF: D3DXEVENT_DESC* LPD3DXEVENT_DESC

TYPEDEF: DWORD D3DXEVENTHANDLE
TYPEDEF: D3DXEVENTHANDLE* LPD3DXEVENTHANDLE

C-TYPE: ID3DXAnimationCallbackHandler
TYPEDEF: ID3DXAnimationCallbackHandler* LPD3DXANIMATIONCALLBACKHANDLER

COM-INTERFACE: ID3DXAnimationCallbackHandler f {00000000-0000-0000-0000-000000000000}
    HRESULT HandleCallback ( UINT Track, LPVOID pCallbackData ) ;

C-TYPE: ID3DXAnimationController
TYPEDEF: ID3DXAnimationController* LPD3DXANIMATIONCONTROLLER

COM-INTERFACE: ID3DXAnimationController IUnknown {AC8948EC-F86D-43e2-96DE-31FC35F96D9E}
    UINT GetMaxNumAnimationOutputs ( )
    UINT GetMaxNumAnimationSets ( )
    UINT GetMaxNumTracks ( )
    UINT GetMaxNumEvents ( )
    HRESULT RegisterAnimationOutput (
        LPCSTR          pName,
        D3DXMATRIX*     pMatrix,
        D3DXVECTOR3*    pScale,
        D3DXQUATERNION* pRotation,
        D3DXVECTOR3*    pTranslation )
    HRESULT RegisterAnimationSet ( LPD3DXANIMATIONSET pAnimSet )
    HRESULT UnregisterAnimationSet ( LPD3DXANIMATIONSET pAnimSet )
    UINT GetNumAnimationSets ( )
    HRESULT GetAnimationSet ( UINT Index, LPD3DXANIMATIONSET* ppAnimationSet )
    HRESULT GetAnimationSetByName ( LPCSTR szName, LPD3DXANIMATIONSET* ppAnimationSet )
    HRESULT AdvanceTime ( double TimeDelta, LPD3DXANIMATIONCALLBACKHANDLER pCallbackHandler )
    HRESULT ResetTime ( )
    double GetTime ( )
    HRESULT SetTrackAnimationSet ( UINT Track, LPD3DXANIMATIONSET pAnimSet )
    HRESULT GetTrackAnimationSet ( UINT Track, LPD3DXANIMATIONSET* ppAnimSet )
    HRESULT SetTrackPriority ( UINT Track, D3DXPRIORITY_TYPE Priority )
    HRESULT SetTrackSpeed ( UINT Track, FLOAT Speed )
    HRESULT SetTrackWeight ( UINT Track, FLOAT Weight )
    HRESULT SetTrackPosition ( UINT Track, double Position )
    HRESULT SetTrackEnable ( UINT Track, BOOL Enable )
    HRESULT SetTrackDesc ( UINT Track, LPD3DXTRACK_DESC pDesc )
    HRESULT GetTrackDesc ( UINT Track, LPD3DXTRACK_DESC pDesc )
    HRESULT SetPriorityBlend ( FLOAT BlendWeight )
    FLOAT GetPriorityBlend ( )
    D3DXEVENTHANDLE KeyTrackSpeed ( UINT Track, FLOAT NewSpeed, double StartTime, double Duration, D3DXTRANSITION_TYPE Transition )
    D3DXEVENTHANDLE KeyTrackWeight ( UINT Track, FLOAT NewWeight, double StartTime, double Duration, D3DXTRANSITION_TYPE Transition )
    D3DXEVENTHANDLE KeyTrackPosition ( UINT Track, double NewPosition, double StartTime )
    D3DXEVENTHANDLE KeyTrackEnable ( UINT Track, BOOL NewEnable, double StartTime )
    D3DXEVENTHANDLE KeyPriorityBlend ( FLOAT NewBlendWeight, double StartTime, double Duration, D3DXTRANSITION_TYPE Transition )
    HRESULT UnkeyEvent ( D3DXEVENTHANDLE hEvent )
    HRESULT UnkeyAllTrackEvents ( UINT Track )
    HRESULT UnkeyAllPriorityBlends ( )
    D3DXEVENTHANDLE GetCurrentTrackEvent ( UINT Track, D3DXEVENT_TYPE EventType )
    D3DXEVENTHANDLE GetCurrentPriorityBlend ( )
    D3DXEVENTHANDLE GetUpcomingTrackEvent ( UINT Track, D3DXEVENTHANDLE hEvent )
    D3DXEVENTHANDLE GetUpcomingPriorityBlend ( D3DXEVENTHANDLE hEvent )
    HRESULT ValidateEvent ( D3DXEVENTHANDLE hEvent )
    HRESULT GetEventDesc ( D3DXEVENTHANDLE hEvent, LPD3DXEVENT_DESC pDesc )
    HRESULT CloneAnimationController (
        UINT                       MaxNumAnimationOutputs,
        UINT                       MaxNumAnimationSets,
        UINT                       MaxNumTracks,
        UINT                       MaxNumEvents,
        LPD3DXANIMATIONCONTROLLER* ppAnimController ) ;

FUNCTION: HRESULT
D3DXLoadMeshHierarchyFromXA
    (
    LPCSTR                     Filename,
    DWORD                      MeshOptions,
    LPDIRECT3DDEVICE9          pD3DDevice,
    LPD3DXALLOCATEHIERARCHY    pAlloc,
    LPD3DXLOADUSERDATA         pUserDataLoader,
    LPD3DXFRAME*               ppFrameHierarchy,
    LPD3DXANIMATIONCONTROLLER* ppAnimController
    )

FUNCTION: HRESULT
D3DXLoadMeshHierarchyFromXW
    (
    LPCWSTR                    Filename,
    DWORD                      MeshOptions,
    LPDIRECT3DDEVICE9          pD3DDevice,
    LPD3DXALLOCATEHIERARCHY    pAlloc,
    LPD3DXLOADUSERDATA         pUserDataLoader,
    LPD3DXFRAME*               ppFrameHierarchy,
    LPD3DXANIMATIONCONTROLLER* ppAnimController
    )

ALIAS: D3DXLoadMeshHierarchyFromX D3DXLoadMeshHierarchyFromXW

FUNCTION: HRESULT
D3DXLoadMeshHierarchyFromXInMemory
    (
    LPCVOID                    Memory,
    DWORD                      SizeOfMemory,
    DWORD                      MeshOptions,
    LPDIRECT3DDEVICE9          pD3DDevice,
    LPD3DXALLOCATEHIERARCHY    pAlloc,
    LPD3DXLOADUSERDATA         pUserDataLoader,
    LPD3DXFRAME*               ppFrameHierarchy,
    LPD3DXANIMATIONCONTROLLER* ppAnimController
    )

FUNCTION: HRESULT
D3DXSaveMeshHierarchyToFileA
    (
    LPCSTR                    Filename,
    DWORD                     XFormat,
    D3DXFRAME*                pFrameRoot,
    LPD3DXANIMATIONCONTROLLER pAnimcontroller,
    LPD3DXSAVEUSERDATA        pUserDataSaver
    )

FUNCTION: HRESULT
D3DXSaveMeshHierarchyToFileW
    (
    LPCWSTR                   Filename,
    DWORD                     XFormat,
    D3DXFRAME*                pFrameRoot,
    LPD3DXANIMATIONCONTROLLER pAnimController,
    LPD3DXSAVEUSERDATA        pUserDataSaver
    )

ALIAS: D3DXSaveMeshHierarchyToFile D3DXSaveMeshHierarchyToFileW

FUNCTION: HRESULT
D3DXFrameDestroy
    (
    LPD3DXFRAME             pFrameRoot,
    LPD3DXALLOCATEHIERARCHY pAlloc
    )

FUNCTION: HRESULT
D3DXFrameAppendChild
    (
    LPD3DXFRAME pFrameParent,
    D3DXFRAME*  pFrameChild
    )

FUNCTION: LPD3DXFRAME
D3DXFrameFind
    (
    D3DXFRAME* pFrameRoot,
    LPCSTR     Name
    )

FUNCTION: HRESULT
D3DXFrameRegisterNamedMatrices
    (
    LPD3DXFRAME               pFrameRoot,
    LPD3DXANIMATIONCONTROLLER pAnimController
    )

FUNCTION: UINT
D3DXFrameNumNamedMatrices
    (
    D3DXFRAME* pFrameRoot
    )

FUNCTION: HRESULT
D3DXFrameCalculateBoundingSphere
    (
    D3DXFRAME*    pFrameRoot,
    LPD3DXVECTOR3 pObjectCenter,
    FLOAT*        pObjectRadius
    )

FUNCTION: HRESULT
D3DXCreateKeyframedAnimationSet
    (
    LPCSTR                       pName,
    double                       TicksPerSecond,
    D3DXPLAYBACK_TYPE            Playback,
    UINT                         NumAnimations,
    UINT                         NumCallbackKeys,
    D3DXKEY_CALLBACK*            pCallbackKeys,
    LPD3DXKEYFRAMEDANIMATIONSET* ppAnimationSet
    )

FUNCTION: HRESULT
D3DXCreateCompressedAnimationSet
    (
    LPCSTR                        pName,
    double                        TicksPerSecond,
    D3DXPLAYBACK_TYPE             Playback,
    LPD3DXBUFFER                  pCompressedData,
    UINT                          NumCallbackKeys,
    D3DXKEY_CALLBACK*             pCallbackKeys,
    LPD3DXCOMPRESSEDANIMATIONSET* ppAnimationSet
    )

FUNCTION: HRESULT
D3DXCreateAnimationController
    (
    UINT                       MaxNumMatrices,
    UINT                       MaxNumAnimationSets,
    UINT                       MaxNumTracks,
    UINT                       MaxNumEvents,
    LPD3DXANIMATIONCONTROLLER* ppAnimController
    )
