USING: alien.syntax alien.c-types windows.directx.d3d9types math
classes.struct windows.types windows.com.syntax windows.com windows.directx
windows.directx.d3d9 windows.directx.d3dx9core windows.directx.d3dx9math
windows.directx.d3dx9xof ;
IN: windows.directx.d3dx9mesh

LIBRARY: d3dx9

TYPEDEF: int D3DXPATCHMESHTYPE
CONSTANT: D3DXPATCHMESH_RECT   1
CONSTANT: D3DXPATCHMESH_TRI    2
CONSTANT: D3DXPATCHMESH_NPATCH 3
CONSTANT: D3DXPATCHMESH_FORCE_DWORD 0x7fffffff

TYPEDEF: int D3DXMESH
CONSTANT: D3DXMESH_32BIT                  0x001
CONSTANT: D3DXMESH_DONOTCLIP              0x002
CONSTANT: D3DXMESH_POINTS                 0x004
CONSTANT: D3DXMESH_RTPATCHES              0x008
CONSTANT: D3DXMESH_NPATCHES               0x4000
CONSTANT: D3DXMESH_VB_SYSTEMMEM           0x010
CONSTANT: D3DXMESH_VB_MANAGED             0x020
CONSTANT: D3DXMESH_VB_WRITEONLY           0x040
CONSTANT: D3DXMESH_VB_DYNAMIC             0x080
CONSTANT: D3DXMESH_VB_SOFTWAREPROCESSING  0x8000
CONSTANT: D3DXMESH_IB_SYSTEMMEM           0x100
CONSTANT: D3DXMESH_IB_MANAGED             0x200
CONSTANT: D3DXMESH_IB_WRITEONLY           0x400
CONSTANT: D3DXMESH_IB_DYNAMIC             0x800
CONSTANT: D3DXMESH_IB_SOFTWAREPROCESSING  0x10000
CONSTANT: D3DXMESH_VB_SHARE               0x1000
CONSTANT: D3DXMESH_USEHWONLY              0x2000
CONSTANT: D3DXMESH_SYSTEMMEM              0x110
CONSTANT: D3DXMESH_MANAGED                0x220
CONSTANT: D3DXMESH_WRITEONLY              0x440
CONSTANT: D3DXMESH_DYNAMIC                0x880
CONSTANT: D3DXMESH_SOFTWAREPROCESSING     0x18000

TYPEDEF: int D3DXPATCHMESH
CONSTANT: D3DXPATCHMESH_DEFAULT 0

TYPEDEF: int D3DXMESHSIMP
CONSTANT: D3DXMESHSIMP_VERTEX   1
CONSTANT: D3DXMESHSIMP_FACE     2

TYPEDEF: int D3DXCLEANTYPE
CONSTANT: D3DXCLEAN_BACKFACING     1
CONSTANT: D3DXCLEAN_BOWTIES        2
CONSTANT: D3DXCLEAN_SKINNING       1
CONSTANT: D3DXCLEAN_OPTIMIZATION   1
CONSTANT: D3DXCLEAN_SIMPLIFICATION 3

: MAX_FVF_DECL_SIZE ( -- n ) MAXD3DDECLLENGTH 1 + ; inline

TYPEDEF: int D3DXTANGENT
CONSTANT: D3DXTANGENT_WRAP_U                  0x01
CONSTANT: D3DXTANGENT_WRAP_V                  0x02
CONSTANT: D3DXTANGENT_WRAP_UV                 0x03
CONSTANT: D3DXTANGENT_DONT_NORMALIZE_PARTIALS 0x04
CONSTANT: D3DXTANGENT_DONT_ORTHOGONALIZE      0x08
CONSTANT: D3DXTANGENT_ORTHOGONALIZE_FROM_V    0x010
CONSTANT: D3DXTANGENT_ORTHOGONALIZE_FROM_U    0x020
CONSTANT: D3DXTANGENT_WEIGHT_BY_AREA          0x040
CONSTANT: D3DXTANGENT_WEIGHT_EQUAL            0x080
CONSTANT: D3DXTANGENT_WIND_CW                 0x0100
CONSTANT: D3DXTANGENT_CALCULATE_NORMALS       0x0200
CONSTANT: D3DXTANGENT_GENERATE_IN_PLACE       0x0400

TYPEDEF: int D3DXIMT
CONSTANT: D3DXIMT_WRAP_U  0x01
CONSTANT: D3DXIMT_WRAP_V  0x02
CONSTANT: D3DXIMT_WRAP_UV 0x03

TYPEDEF: int D3DXUVATLAS
CONSTANT: D3DXUVATLAS_DEFAULT               0x00
CONSTANT: D3DXUVATLAS_GEODESIC_FAST         0x01
CONSTANT: D3DXUVATLAS_GEODESIC_QUALITY      0x02

C-TYPE: ID3DXBaseMesh
TYPEDEF: ID3DXBaseMesh* LPD3DXBASEMESH
C-TYPE: ID3DXMesh
TYPEDEF: ID3DXMesh* LPD3DXMESH
C-TYPE: ID3DXPMesh
TYPEDEF: ID3DXPMesh* LPD3DXPMESH
C-TYPE: ID3DXSPMesh
TYPEDEF: ID3DXSPMesh* LPD3DXSPMESH
C-TYPE: ID3DXSkinInfo
TYPEDEF: ID3DXSkinInfo* LPD3DXSKININFO
C-TYPE: ID3DXPatchMesh
TYPEDEF: ID3DXPatchMesh* LPD3DXPATCHMESH
C-TYPE: ID3DXTextureGutterHelper
TYPEDEF: ID3DXTextureGutterHelper* LPD3DXTEXTUREGUTTERHELPER
C-TYPE: ID3DXPRTBuffer
TYPEDEF: ID3DXPRTBuffer* LPD3DXPRTBUFFER

STRUCT: D3DXATTRIBUTERANGE
    { AttribId    DWORD }
    { FaceStart   DWORD }
    { FaceCount   DWORD }
    { VertexStart DWORD }
    { VertexCount DWORD } ;
TYPEDEF: D3DXATTRIBUTERANGE* LPD3DXATTRIBUTERANGE

STRUCT: D3DXMATERIAL
    { MatD3D           D3DMATERIAL9 }
    { pTextureFilename LPSTR        } ;
TYPEDEF: D3DXMATERIAL* LPD3DXMATERIAL

TYPEDEF: int D3DXEFFECTDEFAULTTYPE
CONSTANT: D3DXEDT_STRING     0x1
CONSTANT: D3DXEDT_FLOATS     0x2
CONSTANT: D3DXEDT_DWORD      0x3
CONSTANT: D3DXEDT_FORCEDWORD 0x7fffffff

STRUCT: D3DXEFFECTDEFAULT
    { pParamName    LPSTR                 }
    { Type          D3DXEFFECTDEFAULTTYPE }
    { NumBytes      DWORD                 }
    { pValue        LPVOID                } ;
TYPEDEF: D3DXEFFECTDEFAULT* LPD3DXEFFECTDEFAULT

STRUCT: D3DXEFFECTINSTANCE
    { pEffectFilename               LPSTR               }
    { NumDefaults                   DWORD               }
    { pDefaults                     LPD3DXEFFECTDEFAULT } ;
TYPEDEF: D3DXEFFECTINSTANCE* LPD3DXEFFECTINSTANCE

STRUCT: D3DXATTRIBUTEWEIGHTS
    { Position FLOAT    }
    { Boundary FLOAT    }
    { Normal   FLOAT    }
    { Diffuse  FLOAT    }
    { Specular FLOAT    }
    { Texcoord FLOAT[8] }
    { Tangent  FLOAT    }
    { Binormal FLOAT    } ;
TYPEDEF: D3DXATTRIBUTEWEIGHTS* LPD3DXATTRIBUTEWEIGHTS

CONSTANT: D3DXWELDEPSILONS_WELDALL             0x1
CONSTANT: D3DXWELDEPSILONS_WELDPARTIALMATCHES  0x2
CONSTANT: D3DXWELDEPSILONS_DONOTREMOVEVERTICES 0x4
CONSTANT: D3DXWELDEPSILONS_DONOTSPLIT          0x8

STRUCT: D3DXWELDEPSILONS
    { Position     FLOAT    }
    { BlendWeights FLOAT    }
    { Normal       FLOAT    }
    { PSize        FLOAT    }
    { Specular     FLOAT    }
    { Diffuse      FLOAT    }
    { Texcoord     FLOAT[8] }
    { Tangent      FLOAT    }
    { Binormal     FLOAT    }
    { TessFactor   FLOAT    } ;
TYPEDEF: D3DXWELDEPSILONS* LPD3DXWELDEPSILONS

COM-INTERFACE: ID3DXBaseMesh IUnknown {7ED943DD-52E8-40b5-A8D8-76685C406330}
    HRESULT DrawSubset ( DWORD AttribId )
    DWORD GetNumFaces ( )
    DWORD GetNumVertices ( )
    DWORD GetFVF ( )
    HRESULT GetDeclaration ( D3DVERTEXELEMENT9* Declaration )
    DWORD GetNumBytesPerVertex ( )
    DWORD GetOptions ( )
    HRESULT GetDevice ( LPDIRECT3DDEVICE9* ppDevice )
    HRESULT CloneMeshFVF ( DWORD Options, DWORD FVF, LPDIRECT3DDEVICE9 pD3DDevice, LPD3DXMESH* ppCloneMesh )
    HRESULT CloneMesh ( DWORD Options, D3DVERTEXELEMENT9* pDeclaration, LPDIRECT3DDEVICE9 pD3DDevice, LPD3DXMESH* ppCloneMesh )
    HRESULT GetVertexBuffer ( LPDIRECT3DVERTEXBUFFER9* ppVB )
    HRESULT GetIndexBuffer ( LPDIRECT3DINDEXBUFFER9* ppIB )
    HRESULT LockVertexBuffer ( DWORD Flags, LPVOID* ppData )
    HRESULT UnlockVertexBuffer ( )
    HRESULT LockIndexBuffer ( DWORD Flags, LPVOID* ppData )
    HRESULT UnlockIndexBuffer ( )
    HRESULT GetAttributeTable ( D3DXATTRIBUTERANGE* pAttribTable, DWORD* pAttribTableSize )
    HRESULT ConvertPointRepsToAdjacency ( DWORD* pPRep, DWORD* pAdjacency )
    HRESULT ConvertAdjacencyToPointReps ( DWORD* pAdjacency, DWORD* pPRep )
    HRESULT GenerateAdjacency ( FLOAT Epsilon, DWORD* pAdjacency )
    HRESULT UpdateSemantics ( D3DVERTEXELEMENT9* Declaration ) ;

COM-INTERFACE: ID3DXMesh ID3DXBaseMesh {4020E5C2-1403-4929-883F-E2E849FAC195}
    HRESULT LockAttributeBuffer ( DWORD Flags, DWORD** ppData )
    HRESULT UnlockAttributeBuffer ( )
    HRESULT Optimize ( DWORD Flags, DWORD* pAdjacencyIn, DWORD* pAdjacencyOut,
                       DWORD* pFaceRemap, LPD3DXBUFFER* ppVertexRemap,
                       LPD3DXMESH* ppOptMesh )
    HRESULT OptimizeInplace ( DWORD Flags, DWORD* pAdjacencyIn, DWORD* pAdjacencyOut,
                              DWORD* pFaceRemap, LPD3DXBUFFER* ppVertexRemap )
    HRESULT SetAttributeTable ( D3DXATTRIBUTERANGE* pAttribTable, DWORD cAttribTableSize ) ;

COM-INTERFACE: ID3DXPMesh ID3DXBaseMesh {8875769A-D579-4088-AAEB-534D1AD84E96}
    HRESULT ClonePMeshFVF ( DWORD Options,
                            DWORD FVF, LPDIRECT3DDEVICE9 pD3DDevice, LPD3DXPMESH* ppCloneMesh )
    HRESULT ClonePMesh ( DWORD Options,
                         D3DVERTEXELEMENT9* pDeclaration, LPDIRECT3DDEVICE9 pD3DDevice, LPD3DXPMESH* ppCloneMesh )
    HRESULT SetNumFaces ( DWORD Faces )
    HRESULT SetNumVertices ( DWORD Vertices )
    DWORD GetMaxFaces ( )
    DWORD GetMinFaces ( )
    DWORD GetMaxVertices ( )
    DWORD GetMinVertices ( )
    HRESULT Save ( IStream* pStream, D3DXMATERIAL* pMaterials, D3DXEFFECTINSTANCE* pEffectInstances, DWORD NumMaterials )
    HRESULT Optimize ( DWORD Flags, DWORD* pAdjacencyOut,
                       DWORD* pFaceRemap, LPD3DXBUFFER* ppVertexRemap,
                       LPD3DXMESH* ppOptMesh )
    HRESULT OptimizeBaseLOD ( DWORD Flags, DWORD* pFaceRemap )
    HRESULT TrimByFaces ( DWORD NewFacesMin, DWORD NewFacesMax, DWORD* rgiFaceRemap, DWORD* rgiVertRemap )
    HRESULT TrimByVertices ( DWORD NewVerticesMin, DWORD NewVerticesMax, DWORD* rgiFaceRemap, DWORD* rgiVertRemap )
    HRESULT GetAdjacency ( DWORD* pAdjacency )
    HRESULT GenerateVertexHistory ( DWORD* pVertexHistory ) ;

COM-INTERFACE: ID3DXSPMesh IUnknown {667EA4C7-F1CD-4386-B523-7C0290B83CC5}
    DWORD GetNumFaces ( )
    DWORD GetNumVertices ( )
    DWORD GetFVF ( )
    HRESULT GetDeclaration ( D3DVERTEXELEMENT9* Declaration )
    DWORD GetOptions ( )
    HRESULT GetDevice ( LPDIRECT3DDEVICE9* ppDevice )
    HRESULT CloneMeshFVF ( DWORD Options,
                           DWORD FVF, LPDIRECT3DDEVICE9 pD3DDevice, DWORD* pAdjacencyOut, DWORD* pVertexRemapOut, LPD3DXMESH* ppCloneMesh )
    HRESULT CloneMesh ( DWORD Options,
                        D3DVERTEXELEMENT9* pDeclaration, LPDIRECT3DDEVICE9 pD3DDevice, DWORD* pAdjacencyOut, DWORD* pVertexRemapOut, LPD3DXMESH* ppCloneMesh )
    HRESULT ClonePMeshFVF ( DWORD Options,
                            DWORD FVF, LPDIRECT3DDEVICE9 pD3DDevice, DWORD* pVertexRemapOut, FLOAT* pErrorsByFace, LPD3DXPMESH* ppCloneMesh )
    HRESULT ClonePMesh ( DWORD Options,
                         D3DVERTEXELEMENT9* pDeclaration, LPDIRECT3DDEVICE9 pD3DDevice, DWORD* pVertexRemapOut, FLOAT* pErrorsbyFace, LPD3DXPMESH* ppCloneMesh )
    HRESULT ReduceFaces ( DWORD Faces )
    HRESULT ReduceVertices ( DWORD Vertices )
    DWORD GetMaxFaces ( )
    DWORD GetMaxVertices ( )
    HRESULT GetVertexAttributeWeights ( LPD3DXATTRIBUTEWEIGHTS pVertexAttributeWeights )
    HRESULT GetVertexWeights ( FLOAT* pVertexWeights ) ;

CONSTANT: D3DXMESHOPT_COMPACT           0x01000000
CONSTANT: D3DXMESHOPT_ATTRSORT          0x02000000
CONSTANT: D3DXMESHOPT_VERTEXCACHE       0x04000000
CONSTANT: D3DXMESHOPT_STRIPREORDER      0x08000000
CONSTANT: D3DXMESHOPT_IGNOREVERTS       0x10000000
CONSTANT: D3DXMESHOPT_DONOTSPLIT        0x20000000
CONSTANT: D3DXMESHOPT_DEVICEINDEPENDENT 0x00400000

STRUCT: D3DXBONECOMBINATION
    { AttribId    DWORD  }
    { FaceStart   DWORD  }
    { FaceCount   DWORD  }
    { VertexStart DWORD  }
    { VertexCount DWORD  }
    { BoneId      DWORD* } ;
TYPEDEF: D3DXBONECOMBINATION* LPD3DXBONECOMBINATION

STRUCT: D3DXPATCHINFO
    { PatchType D3DXPATCHMESHTYPE }
    { Degree    D3DDEGREETYPE     }
    { Basis     D3DBASISTYPE      } ;
TYPEDEF: D3DXPATCHINFO* LPD3DXPATCHINFO

COM-INTERFACE: ID3DXPatchMesh IUnknown {3CE6CC22-DBF2-44f4-894D-F9C34A337139}
    DWORD GetNumPatches ( )
    DWORD GetNumVertices ( )
    HRESULT GetDeclaration ( D3DVERTEXELEMENT9* Declaration )
    DWORD GetControlVerticesPerPatch ( )
    DWORD GetOptions ( )
    HRESULT GetDevice ( LPDIRECT3DDEVICE9* ppDevice )
    HRESULT GetPatchInfo ( LPD3DXPATCHINFO PatchInfo )
    HRESULT GetVertexBuffer ( LPDIRECT3DVERTEXBUFFER9* ppVB )
    HRESULT GetIndexBuffer ( LPDIRECT3DINDEXBUFFER9* ppIB )
    HRESULT LockVertexBuffer ( DWORD flags, LPVOID* ppData )
    HRESULT UnlockVertexBuffer ( )
    HRESULT LockIndexBuffer ( DWORD flags, LPVOID* ppData )
    HRESULT UnlockIndexBuffer ( )
    HRESULT LockAttributeBuffer ( DWORD flags, DWORD** ppData )
    HRESULT UnlockAttributeBuffer ( )
    HRESULT GetTessSize ( FLOAT fTessLevel, DWORD Adaptive, DWORD* NumTriangles, DWORD* NumVertices )
    HRESULT GenerateAdjacency ( FLOAT Tolerance )
    HRESULT CloneMesh ( DWORD Options, D3DVERTEXELEMENT9* pDecl, LPD3DXPATCHMESH* pMesh )
    HRESULT Optimize ( DWORD flags )
    HRESULT SetDisplaceParam (
        LPDIRECT3DBASETEXTURE9 Texture,
        D3DTEXTUREFILTERTYPE   MinFilter,
        D3DTEXTUREFILTERTYPE   MagFilter,
        D3DTEXTUREFILTERTYPE   MipFilter,
        D3DTEXTUREADDRESS      Wrap,
        DWORD                  dwLODBias )
    HRESULT GetDisplaceParam (
        LPDIRECT3DBASETEXTURE9* Texture,
        D3DTEXTUREFILTERTYPE*   MinFilter,
        D3DTEXTUREFILTERTYPE*   MagFilter,
        D3DTEXTUREFILTERTYPE*   MipFilter,
        D3DTEXTUREADDRESS*      Wrap,
        DWORD*                  dwLODBias )
    HRESULT Tessellate ( FLOAT fTessLevel, LPD3DXMESH pMesh )
    HRESULT TessellateAdaptive (
        D3DXVECTOR4* pTrans,
        DWORD        dwMaxTessLevel,
        DWORD        dwMinTessLevel,
        LPD3DXMESH   pMesh ) ;

COM-INTERFACE: ID3DXSkinInfo IUnknown {11EAA540-F9A6-4d49-AE6A-E19221F70CC4}
    HRESULT SetBoneInfluence ( DWORD bone, DWORD numInfluences, DWORD* vertices, FLOAT* weights )
    HRESULT SetBoneVertexInfluence ( DWORD boneNum, DWORD influenceNum, FLOAT weight )
    DWORD GetNumBoneInfluences ( DWORD bone )
    HRESULT GetBoneInfluence ( DWORD bone, DWORD* vertices, FLOAT* weights )
    HRESULT GetBoneVertexInfluence ( DWORD boneNum, DWORD influenceNum, FLOAT* pWeight, DWORD* pVertexNum )
    HRESULT GetMaxVertexInfluences ( DWORD* maxVertexInfluences )
    DWORD GetNumBones ( )
    HRESULT FindBoneVertexInfluenceIndex ( DWORD boneNum, DWORD vertexNum, DWORD* pInfluenceIndex )
    HRESULT GetMaxFaceInfluences ( LPDIRECT3DINDEXBUFFER9 pIB, DWORD NumFaces, DWORD* maxFaceInfluences )
    HRESULT SetMinBoneInfluence ( FLOAT MinInfl )
    FLOAT GetMinBoneInfluence ( )
    HRESULT SetBoneName ( DWORD Bone, LPCSTR pName )
    LPCSTR GetBoneName ( DWORD Bone )
    HRESULT SetBoneOffsetMatrix ( DWORD Bone, D3DXMATRIX* pBoneTransform )
    LPD3DXMATRIX GetBoneOffsetMatrix ( DWORD Bone )
    HRESULT Clone ( LPD3DXSKININFO* ppSkinInfo )
    HRESULT Remap ( DWORD NumVertices, DWORD* pVertexRemap )
    HRESULT SetFVF ( DWORD FVF )
    HRESULT SetDeclaration ( D3DVERTEXELEMENT9* pDeclaration )
    DWORD GetFVF ( )
    HRESULT GetDeclaration ( D3DVERTEXELEMENT9* Declaration )
    HRESULT UpdateSkinnedMesh (
        D3DXMATRIX* pBoneTransforms,
        D3DXMATRIX* pBoneInvTransposeTransforms,
        LPCVOID     pVerticesSrc,
        PVOID       pVerticesDst )
    HRESULT ConvertToBlendedMesh (
        LPD3DXMESH    pMesh,
        DWORD         Options,
        DWORD*        pAdjacencyIn,
        LPDWORD       pAdjacencyOut,
        DWORD*        pFaceRemap,
        LPD3DXBUFFER* ppVertexRemap,
        DWORD*        pMaxFaceInfl,
        DWORD*        pNumBoneCombinations,
        LPD3DXBUFFER* ppBoneCombinationTable,
        LPD3DXMESH*   ppMesh )
    HRESULT ConvertToIndexedBlendedMesh (
        LPD3DXMESH    pMesh,
        DWORD         Options,
        DWORD         paletteSize,
        DWORD*        pAdjacencyIn,
        LPDWORD       pAdjacencyOut,
        DWORD*        pFaceRemap,
        LPD3DXBUFFER* ppVertexRemap,
        DWORD*        pMaxVertexInfl,
        DWORD*        pNumBoneCombinations,
        LPD3DXBUFFER* ppBoneCombinationTable,
        LPD3DXMESH*   ppMesh ) ;

FUNCTION: HRESULT
    D3DXCreateMesh (
        DWORD              NumFaces,
        DWORD              NumVertices,
        DWORD              Options,
        D3DVERTEXELEMENT9* pDeclaration,
        LPDIRECT3DDEVICE9  pD3DDevice,
        LPD3DXMESH*        ppMesh )

FUNCTION: HRESULT
    D3DXCreateMeshFVF (
        DWORD             NumFaces,
        DWORD             NumVertices,
        DWORD             Options,
        DWORD             FVF,
        LPDIRECT3DDEVICE9 pD3DDevice,
        LPD3DXMESH*       ppMesh )

FUNCTION: HRESULT
    D3DXCreateSPMesh (
        LPD3DXMESH            pMesh,
        DWORD*                pAdjacency,
        D3DXATTRIBUTEWEIGHTS* pVertexAttributeWeights,
        FLOAT*                pVertexWeights,
        LPD3DXSPMESH*         ppSMesh )

FUNCTION: HRESULT
    D3DXCleanMesh (
    D3DXCLEANTYPE CleanType,
    LPD3DXMESH    pMeshIn,
    DWORD*        pAdjacencyIn,
    LPD3DXMESH*   ppMeshOut,
    DWORD*        pAdjacencyOut,
    LPD3DXBUFFER* ppErrorsAndWarnings )

FUNCTION: HRESULT
    D3DXValidMesh (
    LPD3DXMESH    pMeshIn,
    DWORD*        pAdjacency,
    LPD3DXBUFFER* ppErrorsAndWarnings )

FUNCTION: HRESULT
    D3DXGeneratePMesh (
        LPD3DXMESH            pMesh,
        DWORD*                pAdjacency,
        D3DXATTRIBUTEWEIGHTS* pVertexAttributeWeights,
        FLOAT*                pVertexWeights,
        DWORD                 MinValue,
        DWORD                 Options,
        LPD3DXPMESH*          ppPMesh )

FUNCTION: HRESULT
    D3DXSimplifyMesh (
        LPD3DXMESH            pMesh,
        DWORD*                pAdjacency,
        D3DXATTRIBUTEWEIGHTS* pVertexAttributeWeights,
        FLOAT*                pVertexWeights,
        DWORD                 MinValue,
        DWORD                 Options,
        LPD3DXMESH*           ppMesh )

FUNCTION: HRESULT
    D3DXComputeBoundingSphere (
        D3DXVECTOR3* pFirstPosition,
        DWORD        NumVertices,
        DWORD        dwStride,
        D3DXVECTOR3* pCenter,
        FLOAT*       pRadius )

FUNCTION: HRESULT
    D3DXComputeBoundingBox (
        D3DXVECTOR3* pFirstPosition,
        DWORD        NumVertices,
        DWORD        dwStride,
        D3DXVECTOR3* pMin,
        D3DXVECTOR3* pMax )

FUNCTION: HRESULT
    D3DXComputeNormals (
        LPD3DXBASEMESH pMesh,
        DWORD*         pAdjacency )

FUNCTION: HRESULT
    D3DXCreateBuffer (
        DWORD         NumBytes,
        LPD3DXBUFFER* ppBuffer )

FUNCTION: HRESULT
    D3DXLoadMeshFromXA (
        LPCSTR            pFilename,
        DWORD             Options,
        LPDIRECT3DDEVICE9 pD3DDevice,
        LPD3DXBUFFER*     ppAdjacency,
        LPD3DXBUFFER*     ppMaterials,
        LPD3DXBUFFER*     ppEffectInstances,
        DWORD*            pNumMaterials,
        LPD3DXMESH*       ppMesh )

FUNCTION: HRESULT
    D3DXLoadMeshFromXW (
        LPCWSTR           pFilename,
        DWORD             Options,
        LPDIRECT3DDEVICE9 pD3DDevice,
        LPD3DXBUFFER*     ppAdjacency,
        LPD3DXBUFFER*     ppMaterials,
        LPD3DXBUFFER*     ppEffectInstances,
        DWORD*            pNumMaterials,
        LPD3DXMESH*       ppMesh )

ALIAS: D3DXLoadMeshFromX D3DXLoadMeshFromXW

FUNCTION: HRESULT
    D3DXLoadMeshFromXInMemory (
        LPCVOID           Memory,
        DWORD             SizeOfMemory,
        DWORD             Options,
        LPDIRECT3DDEVICE9 pD3DDevice,
        LPD3DXBUFFER*     ppAdjacency,
        LPD3DXBUFFER*     ppMaterials,
        LPD3DXBUFFER*     ppEffectInstances,
        DWORD*            pNumMaterials,
        LPD3DXMESH*       ppMesh )

FUNCTION: HRESULT
    D3DXLoadMeshFromXResource (
        HMODULE           Module,
        LPCSTR            Name,
        LPCSTR            Type,
        DWORD             Options,
        LPDIRECT3DDEVICE9 pD3DDevice,
        LPD3DXBUFFER*     ppAdjacency,
        LPD3DXBUFFER*     ppMaterials,
        LPD3DXBUFFER*     ppEffectInstances,
        DWORD*            pNumMaterials,
        LPD3DXMESH*       ppMesh )

FUNCTION: HRESULT
    D3DXSaveMeshToXA (
        LPCSTR              pFilename,
        LPD3DXMESH          pMesh,
        DWORD*              pAdjacency,
        D3DXMATERIAL*       pMaterials,
        D3DXEFFECTINSTANCE* pEffectInstances,
        DWORD               NumMaterials,
        DWORD               Format )

FUNCTION: HRESULT
    D3DXSaveMeshToXW (
        LPCWSTR             pFilename,
        LPD3DXMESH          pMesh,
        DWORD*              pAdjacency,
        D3DXMATERIAL*       pMaterials,
        D3DXEFFECTINSTANCE* pEffectInstances,
        DWORD               NumMaterials,
        DWORD               Format )

ALIAS: D3DXSaveMeshToX D3DXSaveMeshToXW

FUNCTION: HRESULT
    D3DXCreatePMeshFromStream (
        IStream*          pStream,
        DWORD             Options,
        LPDIRECT3DDEVICE9 pD3DDevice,
        LPD3DXBUFFER*     ppMaterials,
        LPD3DXBUFFER*     ppEffectInstances,
        DWORD*            pNumMaterials,
        LPD3DXPMESH*      ppPMesh )

FUNCTION: HRESULT
    D3DXCreateSkinInfo (
        DWORD              NumVertices,
        D3DVERTEXELEMENT9* pDeclaration,
        DWORD              NumBones,
        LPD3DXSKININFO*    ppSkinInfo )

FUNCTION: HRESULT
    D3DXCreateSkinInfoFVF (
        DWORD           NumVertices,
        DWORD           FVF,
        DWORD           NumBones,
        LPD3DXSKININFO* ppSkinInfo )

FUNCTION: HRESULT
    D3DXLoadMeshFromXof (
        LPD3DXFILEDATA    pxofMesh,
        DWORD             Options,
        LPDIRECT3DDEVICE9 pD3DDevice,
        LPD3DXBUFFER*     ppAdjacency,
        LPD3DXBUFFER*     ppMaterials,
        LPD3DXBUFFER*     ppEffectInstances,
        DWORD*            pNumMaterials,
        LPD3DXMESH*       ppMesh )

FUNCTION: HRESULT
    D3DXLoadSkinMeshFromXof (
        LPD3DXFILEDATA    pxofMesh,
        DWORD             Options,
        LPDIRECT3DDEVICE9 pD3DDevice,
        LPD3DXBUFFER*     ppAdjacency,
        LPD3DXBUFFER*     ppMaterials,
        LPD3DXBUFFER*     ppEffectInstances,
        DWORD*            pMatOut,
        LPD3DXSKININFO*   ppSkinInfo,
        LPD3DXMESH*       ppMesh )

FUNCTION: HRESULT
    D3DXCreateSkinInfoFromBlendedMesh (
        LPD3DXBASEMESH       pMesh,
        DWORD                NumBones,
        D3DXBONECOMBINATION* pBoneCombinationTable,
        LPD3DXSKININFO*      ppSkinInfo )

FUNCTION: HRESULT
    D3DXTessellateNPatches (
        LPD3DXMESH    pMeshIn,
        DWORD*        pAdjacencyIn,
        FLOAT         NumSegs,
        BOOL          QuadraticInterpNormals,
        LPD3DXMESH*   ppMeshOut,
        LPD3DXBUFFER* ppAdjacencyOut )

FUNCTION: HRESULT
    D3DXGenerateOutputDecl (
        D3DVERTEXELEMENT9* pOutput,
        D3DVERTEXELEMENT9* pInput )

FUNCTION: HRESULT
    D3DXLoadPatchMeshFromXof (
        LPD3DXFILEDATA    pXofObjMesh,
        DWORD             Options,
        LPDIRECT3DDEVICE9 pD3DDevice,
        LPD3DXBUFFER*     ppMaterials,
        LPD3DXBUFFER*     ppEffectInstances,
        PDWORD            pNumMaterials,
        LPD3DXPATCHMESH*  ppMesh )

FUNCTION: HRESULT
    D3DXRectPatchSize (
        FLOAT* pfNumSegs,
        DWORD* pdwTriangles,
        DWORD* pdwVertices )

FUNCTION: HRESULT
    D3DXTriPatchSize (
        FLOAT* pfNumSegs,
        DWORD* pdwTriangles,
        DWORD* pdwVertices )

FUNCTION: HRESULT
    D3DXTessellateRectPatch (
        LPDIRECT3DVERTEXBUFFER9 pVB,
        FLOAT*                  pNumSegs,
        D3DVERTEXELEMENT9*      pdwInDecl,
        D3DRECTPATCH_INFO*      pRectPatchInfo,
        LPD3DXMESH              pMesh )

FUNCTION: HRESULT
    D3DXTessellateTriPatch (
      LPDIRECT3DVERTEXBUFFER9 pVB,
      FLOAT*                  pNumSegs,
      D3DVERTEXELEMENT9*      pInDecl,
      D3DTRIPATCH_INFO*       pTriPatchInfo,
      LPD3DXMESH              pMesh )

FUNCTION: HRESULT
    D3DXCreateNPatchMesh (
        LPD3DXMESH       pMeshSysMem,
        LPD3DXPATCHMESH* pPatchMesh )

FUNCTION: HRESULT
    D3DXCreatePatchMesh (
        D3DXPATCHINFO*     pInfo,
        DWORD              dwNumPatches,
        DWORD              dwNumVertices,
        DWORD              dwOptions,
        D3DVERTEXELEMENT9* pDecl,
        LPDIRECT3DDEVICE9  pD3DDevice,
        LPD3DXPATCHMESH*   pPatchMesh )

FUNCTION: HRESULT
    D3DXValidPatchMesh (
        LPD3DXPATCHMESH pMesh,
        DWORD*          dwcDegenerateVertices,
        DWORD*          dwcDegeneratePatches,
        LPD3DXBUFFER*   ppErrorsAndWarnings )

FUNCTION: UINT
    D3DXGetFVFVertexSize ( DWORD FVF )

FUNCTION: UINT
    D3DXGetDeclVertexSize ( D3DVERTEXELEMENT9* pDecl, DWORD Stream )

FUNCTION: UINT
    D3DXGetDeclLength ( D3DVERTEXELEMENT9* pDecl )

FUNCTION: HRESULT
    D3DXDeclaratorFromFVF (
        DWORD              FVF,
        D3DVERTEXELEMENT9* pDeclarator )

FUNCTION: HRESULT
    D3DXFVFFromDeclarator (
        D3DVERTEXELEMENT9* pDeclarator,
        DWORD*             pFVF )

FUNCTION: HRESULT
    D3DXWeldVertices (
        LPD3DXMESH        pMesh,
        DWORD             Flags,
        D3DXWELDEPSILONS* pEpsilons,
        DWORD*            pAdjacencyIn,
        DWORD*            pAdjacencyOut,
        DWORD*            pFaceRemap,
        LPD3DXBUFFER*     ppVertexRemap )

STRUCT: D3DXINTERSECTINFO
    { FaceIndex DWORD }
    { U         FLOAT }
    { V         FLOAT }
    { Dist      FLOAT } ;
TYPEDEF: D3DXINTERSECTINFO* LPD3DXINTERSECTINFO

FUNCTION: HRESULT
    D3DXIntersect (
        LPD3DXBASEMESH pMesh,
        D3DXVECTOR3*   pRayPos,
        D3DXVECTOR3*   pRayDir,
        BOOL*          pHit,
        DWORD*         pFaceIndex,
        FLOAT*         pU,
        FLOAT*         pV,
        FLOAT*         pDist,
        LPD3DXBUFFER*  ppAllHits,
        DWORD*         pCountOfHits )

FUNCTION: HRESULT
    D3DXIntersectSubset (
        LPD3DXBASEMESH pMesh,
        DWORD          AttribId,
        D3DXVECTOR3*   pRayPos,
        D3DXVECTOR3*   pRayDir,
        BOOL*          pHit,
        DWORD*         pFaceIndex,
        FLOAT*         pU,
        FLOAT*         pV,
        FLOAT*         pDist,
        LPD3DXBUFFER*  ppAllHits,
        DWORD*         pCountOfHits )

FUNCTION: HRESULT D3DXSplitMesh (
    LPD3DXMESH    pMeshIn,
    DWORD*        pAdjacencyIn,
    DWORD         MaxSize,
    DWORD         Options,
    DWORD*        pMeshesOut,
    LPD3DXBUFFER* ppMeshArrayOut,
    LPD3DXBUFFER* ppAdjacencyArrayOut,
    LPD3DXBUFFER* ppFaceRemapArrayOut,
    LPD3DXBUFFER* ppVertRemapArrayOut )

FUNCTION: BOOL D3DXIntersectTri (
    D3DXVECTOR3* p0,
    D3DXVECTOR3* p1,
    D3DXVECTOR3* p2,
    D3DXVECTOR3* pRayPos,
    D3DXVECTOR3* pRayDir,
    FLOAT*       pU,
    FLOAT*       pV,
    FLOAT*       pDist )

FUNCTION: BOOL
    D3DXSphereBoundProbe (
        D3DXVECTOR3* pCenter,
        FLOAT        Radius,
        D3DXVECTOR3* pRayPosition,
        D3DXVECTOR3* pRayDirection )

FUNCTION: BOOL
    D3DXBoxBoundProbe (
        D3DXVECTOR3* pMin,
        D3DXVECTOR3* pMax,
        D3DXVECTOR3* pRayPosition,
        D3DXVECTOR3* pRayDirection )

FUNCTION: HRESULT D3DXComputeTangentFrame (
    ID3DXMesh* pMesh,
    DWORD      dwOptions )

FUNCTION: HRESULT D3DXComputeTangentFrameEx (
    ID3DXMesh*    pMesh,
    DWORD         dwTextureInSemantic,
    DWORD         dwTextureInIndex,
    DWORD         dwUPartialOutSemantic,
    DWORD         dwUPartialOutIndex,
    DWORD         dwVPartialOutSemantic,
    DWORD         dwVPartialOutIndex,
    DWORD         dwNormalOutSemantic,
    DWORD         dwNormalOutIndex,
    DWORD         dwOptions,
    DWORD*        pdwAdjacency,
    FLOAT         fPartialEdgeThreshold,
    FLOAT         fSingularPointThreshold,
    FLOAT         fNormalEdgeThreshold,
    ID3DXMesh**   ppMeshOut,
    ID3DXBuffer** ppVertexMapping )

FUNCTION: HRESULT D3DXComputeTangent (
    LPD3DXMESH Mesh,
    DWORD      TexStage,
    DWORD      TangentIndex,
    DWORD      BinormIndex,
    DWORD      Wrap,
    DWORD*     pAdjacency )

C-TYPE: D3DXUVATLASCB
TYPEDEF: D3DXUVATLASCB* LPD3DXUVATLASCB

FUNCTION: HRESULT D3DXUVAtlasCreate (
    LPD3DXMESH      pMesh,
    UINT            uMaxChartNumber,
    FLOAT           fMaxStretch,
    UINT            uWidth,
    UINT            uHeight,
    FLOAT           fGutter,
    DWORD           dwTextureIndex,
    DWORD*          pdwAdjacency,
    DWORD*          pdwFalseEdgeAdjacency,
    FLOAT*          pfIMTArray,
    LPD3DXUVATLASCB pStatusCallback,
    FLOAT           fCallbackFrequency,
    LPVOID          pUserContext,
    DWORD           dwOptions,
    LPD3DXMESH*     ppMeshOut,
    LPD3DXBUFFER*   ppFacePartitioning,
    LPD3DXBUFFER*   ppVertexRemapArray,
    FLOAT*          pfMaxStretchOut,
    UINT*           puNumChartsOut )

FUNCTION: HRESULT D3DXUVAtlasPartition (
    LPD3DXMESH      pMesh,
    UINT            uMaxChartNumber,
    FLOAT           fMaxStretch,
    DWORD           dwTextureIndex,
    DWORD*          pdwAdjacency,
    DWORD*          pdwFalseEdgeAdjacency,
    FLOAT*          pfIMTArray,
    LPD3DXUVATLASCB pStatusCallback,
    FLOAT           fCallbackFrequency,
    LPVOID          pUserContext,
    DWORD           dwOptions,
    LPD3DXMESH*     ppMeshOut,
    LPD3DXBUFFER*   ppFacePartitioning,
    LPD3DXBUFFER*   ppVertexRemapArray,
    LPD3DXBUFFER*   ppPartitionResultAdjacency,
    FLOAT*          pfMaxStretchOut,
    UINT*           puNumChartsOut )

FUNCTION: HRESULT D3DXUVAtlasPack (
    ID3DXMesh*      pMesh,
    UINT            uWidth,
    UINT            uHeight,
    FLOAT           fGutter,
    DWORD           dwTextureIndex,
    DWORD*          pdwPartitionResultAdjacency,
    LPD3DXUVATLASCB pStatusCallback,
    FLOAT           fCallbackFrequency,
    LPVOID          pUserContext,
    DWORD           dwOptions,
    LPD3DXBUFFER    pFacePartitioning )

TYPEDEF: void* LPD3DXIMTSIGNALCALLBACK

FUNCTION: HRESULT D3DXComputeIMTFromPerVertexSignal (
    LPD3DXMESH      pMesh,
    FLOAT*          pfVertexSignal,
    UINT            uSignalDimension,
    UINT            uSignalStride,
    DWORD           dwOptions,
    LPD3DXUVATLASCB pStatusCallback,
    LPVOID          pUserContext,
    LPD3DXBUFFER*   ppIMTData )

FUNCTION: HRESULT D3DXComputeIMTFromSignal (
    LPD3DXMESH              pMesh,
    DWORD                   dwTextureIndex,
    UINT                    uSignalDimension,
    FLOAT                   fMaxUVDistance,
    DWORD                   dwOptions,
    LPD3DXIMTSIGNALCALLBACK pSignalCallback,
    VOID*                   pUserData,
    LPD3DXUVATLASCB         pStatusCallback,
    LPVOID                  pUserContext,
    LPD3DXBUFFER*           ppIMTData )

FUNCTION: HRESULT D3DXComputeIMTFromTexture (
    LPD3DXMESH         pMesh,
    LPDIRECT3DTEXTURE9 pTexture,
    DWORD              dwTextureIndex,
    DWORD              dwOptions,
    LPD3DXUVATLASCB    pStatusCallback,
    LPVOID             pUserContext,
    LPD3DXBUFFER*      ppIMTData )

FUNCTION: HRESULT D3DXComputeIMTFromPerTexelSignal (
    LPD3DXMESH      pMesh,
    DWORD           dwTextureIndex,
    FLOAT*          pfTexelSignal,
    UINT            uWidth,
    UINT            uHeight,
    UINT            uSignalDimension,
    UINT            uComponents,
    DWORD           dwOptions,
    LPD3DXUVATLASCB pStatusCallback,
    LPVOID          pUserContext,
    LPD3DXBUFFER*   ppIMTData )

FUNCTION: HRESULT
    D3DXConvertMeshSubsetToSingleStrip (
        LPD3DXBASEMESH          MeshIn,
        DWORD                   AttribId,
        DWORD                   IBOptions,
        LPDIRECT3DINDEXBUFFER9* ppIndexBuffer,
        DWORD*                  pNumIndices )

FUNCTION: HRESULT
    D3DXConvertMeshSubsetToStrips (
        LPD3DXBASEMESH          MeshIn,
        DWORD                   AttribId,
        DWORD                   IBOptions,
        LPDIRECT3DINDEXBUFFER9* ppIndexBuffer,
        DWORD*                  pNumIndices,
        LPD3DXBUFFER*           ppStripLengths,
        DWORD*                  pNumStrips )

FUNCTION: HRESULT
    D3DXOptimizeFaces (
        LPCVOID pbIndices,
        UINT    cFaces,
        UINT    cVertices,
        BOOL    b32BitIndices,
        DWORD*  pFaceRemap )

FUNCTION: HRESULT
    D3DXOptimizeVertices (
        LPCVOID pbIndices,
        UINT    cFaces,
        UINT    cVertices,
        BOOL    b32BitIndices,
        DWORD*  pVertexRemap )

TYPEDEF: int D3DXSHCOMPRESSQUALITYTYPE
CONSTANT: D3DXSHCQUAL_FASTLOWQUALITY  1
CONSTANT: D3DXSHCQUAL_SLOWHIGHQUALITY 2
CONSTANT: D3DXSHCQUAL_FORCE_DWORD     0x7fffffff

TYPEDEF: int D3DXSHGPUSIMOPT
CONSTANT: D3DXSHGPUSIMOPT_SHADOWRES256  1
CONSTANT: D3DXSHGPUSIMOPT_SHADOWRES512  0
CONSTANT: D3DXSHGPUSIMOPT_SHADOWRES1024 2
CONSTANT: D3DXSHGPUSIMOPT_SHADOWRES2048 3
CONSTANT: D3DXSHGPUSIMOPT_HIGHQUALITY   4
CONSTANT: D3DXSHGPUSIMOPT_FORCE_DWORD   0x7fffffff

STRUCT: D3DXSHMATERIAL
    { Diffuse                           D3DCOLORVALUE }
    { bMirror                           BOOL          }
    { bSubSurf                          BOOL          }
    { RelativeIndexOfRefraction         FLOAT         }
    { Absorption                        D3DCOLORVALUE }
    { ReducedScattering                 D3DCOLORVALUE } ;

STRUCT: D3DXSHPRTSPLITMESHVERTDATA
    { uVertRemap   UINT  }
    { uSubCluster  UINT  }
    { ucVertStatus UCHAR } ;

STRUCT: D3DXSHPRTSPLITMESHCLUSTERDATA
    { uVertStart     UINT }
    { uVertLength    UINT }
    { uFaceStart     UINT }
    { uFaceLength    UINT }
    { uClusterStart  UINT }
    { uClusterLength UINT } ;

TYPEDEF: void* LPD3DXSHPRTSIMCB

C-TYPE: ID3DXTextureGutterHelper
C-TYPE: ID3DXPRTBuffer

COM-INTERFACE: ID3DXPRTBuffer IUnknown {F1827E47-00A8-49cd-908C-9D11955F8728}
    UINT GetNumSamples ( )
    UINT GetNumCoeffs ( )
    UINT GetNumChannels ( )
    BOOL IsTexture ( )
    UINT GetWidth ( )
    UINT GetHeight ( )
    HRESULT Resize ( UINT NewSize )
    HRESULT LockBuffer ( UINT Start, UINT NumSamples, FLOAT** ppData )
    HRESULT UnlockBuffer ( )
    HRESULT ScaleBuffer ( FLOAT Scale )
    HRESULT AddBuffer ( LPD3DXPRTBUFFER pBuffer )
    HRESULT AttachGH ( LPD3DXTEXTUREGUTTERHELPER f )
    HRESULT ReleaseGH ( )
    HRESULT EvalGH ( )
    HRESULT ExtractTexture ( UINT Channel, UINT StartCoefficient,
                             UINT NumCoefficients, LPDIRECT3DTEXTURE9 pTexture )
    HRESULT ExtractToMesh ( UINT NumCoefficients, D3DDECLUSAGE Usage, UINT UsageIndexStart,
                            LPD3DXMESH pScene ) ;

C-TYPE: ID3DXPRTCompBuffer
TYPEDEF: ID3DXPRTCompBuffer* LPD3DXPRTCOMPBUFFER

COM-INTERFACE: ID3DXPRTCompBuffer IUnknown {A758D465-FE8D-45ad-9CF0-D01E56266A07}
    UINT GetNumSamples ( )
    UINT GetNumCoeffs ( )
    UINT GetNumChannels ( )
    BOOL IsTexture ( )
    UINT GetWidth ( )
    UINT GetHeight ( )
    UINT GetNumClusters ( )
    UINT GetNumPCA ( )
    HRESULT NormalizeData ( )
    HRESULT ExtractBasis ( UINT Cluster, FLOAT* pClusterBasis )
    HRESULT ExtractClusterIDs ( UINT* pClusterIDs )
    HRESULT ExtractPCA ( UINT StartPCA, UINT NumExtract, FLOAT* pPCACoefficients )
    HRESULT ExtractTexture ( UINT StartPCA, UINT NumpPCA,
                             LPDIRECT3DTEXTURE9 pTexture )
    HRESULT ExtractToMesh ( UINT NumPCA, D3DDECLUSAGE Usage, UINT UsageIndexStart,
                            LPD3DXMESH pScene ) ;

COM-INTERFACE: ID3DXTextureGutterHelper IUnknown {838F01EC-9729-4527-AADB-DF70ADE7FEA9}
    UINT GetWidth ( )
    UINT GetHeight ( )
    HRESULT ApplyGuttersFLOAT ( FLOAT* pDataIn, UINT NumCoeffs, UINT Width, UINT Height )
    HRESULT ApplyGuttersTex ( LPDIRECT3DTEXTURE9 pTexture )
    HRESULT ApplyGuttersPRT ( LPD3DXPRTBUFFER pBuffer )
    HRESULT ResampleTex (
        LPDIRECT3DTEXTURE9 pTextureIn,
        LPD3DXMESH         pMeshIn,
        D3DDECLUSAGE       Usage,
        UINT               UsageIndex,
        LPDIRECT3DTEXTURE9 pTextureOut )
    HRESULT GetFaceMap ( UINT* pFaceData )
    HRESULT GetBaryMap ( D3DXVECTOR2* pBaryData )
    HRESULT GetTexelMap ( D3DXVECTOR2* pTexelData )
    HRESULT GetGutterMap ( BYTE* pGutterData )
    HRESULT SetFaceMap ( UINT* pFaceData )
    HRESULT SetBaryMap ( D3DXVECTOR2* pBaryData )
    HRESULT SetTexelMap ( D3DXVECTOR2* pTexelData )
    HRESULT SetGutterMap ( BYTE* pGutterData ) ;

C-TYPE: ID3DXPRTEngine
TYPEDEF: ID3DXPRTEngine* LPD3DXPRTENGINE

COM-INTERFACE: ID3DXPRTEngine IUnknown {683A4278-CD5F-4d24-90AD-C4E1B6855D53}
    HRESULT SetMeshMaterials ( D3DXSHMATERIAL** ppMaterials, UINT NumMeshes,
                               UINT NumChannels, BOOL bSetAlbedo, FLOAT fLengthScale )
    HRESULT SetPerVertexAlbedo ( VOID* pDataIn, UINT NumChannels, UINT Stride )
    HRESULT SetPerTexelAlbedo ( LPDIRECT3DTEXTURE9 pAlbedoTexture,
                                UINT NumChannels,
                                LPD3DXTEXTUREGUTTERHELPER pGH )
    HRESULT GetVertexAlbedo ( D3DXCOLOR* pVertColors, UINT NumVerts )
    HRESULT SetPerTexelNormal ( LPDIRECT3DTEXTURE9 pNormalTexture )
    HRESULT ExtractPerVertexAlbedo ( LPD3DXMESH pMesh,
                                     D3DDECLUSAGE Usage,
                                     UINT NumChannels )
    HRESULT ResampleBuffer ( LPD3DXPRTBUFFER pBufferIn, LPD3DXPRTBUFFER pBufferOut )
    HRESULT GetAdaptedMesh ( LPDIRECT3DDEVICE9 pD3DDevice, UINT* pFaceRemap, UINT* pVertRemap, FLOAT* pfVertWeights, LPD3DXMESH* ppMesh )
    UINT GetNumVerts ( )
    UINT GetNumFaces ( )
    HRESULT SetMinMaxIntersection ( FLOAT fMin, FLOAT fMax )
    HRESULT RobustMeshRefine ( FLOAT MinEdgeLength, UINT MaxSubdiv )
    HRESULT SetSamplingInfo ( UINT NumRays,
                              BOOL UseSphere,
                              BOOL UseCosine,
                              BOOL Adaptive,
                              FLOAT AdaptiveThresh )
    HRESULT ComputeDirectLightingSH ( UINT SHOrder,
                                      LPD3DXPRTBUFFER pDataOut )
    HRESULT ComputeDirectLightingSHAdaptive ( UINT SHOrder,
                                              FLOAT AdaptiveThresh,
                                              FLOAT MinEdgeLength,
                                              UINT MaxSubdiv,
                                              LPD3DXPRTBUFFER pDataOut )
    HRESULT ComputeDirectLightingSHGPU ( LPDIRECT3DDEVICE9 pD3DDevice,
                                         UINT Flags,
                                         UINT SHOrder,
                                         FLOAT ZBias,
                                         FLOAT ZAngleBias,
                                         LPD3DXPRTBUFFER pDataOut )
    HRESULT ComputeSS ( LPD3DXPRTBUFFER pDataIn,
                        LPD3DXPRTBUFFER pDataOut, LPD3DXPRTBUFFER pDataTotal )
    HRESULT ComputeSSAdaptive ( LPD3DXPRTBUFFER pDataIn,
                                FLOAT AdaptiveThresh,
                                FLOAT MinEdgeLength,
                                UINT MaxSubdiv,
                                LPD3DXPRTBUFFER pDataOut, LPD3DXPRTBUFFER pDataTotal )
    HRESULT ComputeBounce ( LPD3DXPRTBUFFER pDataIn,
                            LPD3DXPRTBUFFER pDataOut,
                            LPD3DXPRTBUFFER pDataTotal )
    HRESULT ComputeBounceAdaptive ( LPD3DXPRTBUFFER pDataIn,
                                    FLOAT AdaptiveThresh,
                                    FLOAT MinEdgeLength,
                                    UINT MaxSubdiv,
                                    LPD3DXPRTBUFFER pDataOut,
                                    LPD3DXPRTBUFFER pDataTotal )
    HRESULT ComputeVolumeSamplesDirectSH ( UINT SHOrderIn,
                                           UINT SHOrderOut,
                                           UINT NumVolSamples,
                                           D3DXVECTOR3* pSampleLocs,
                                           LPD3DXPRTBUFFER pDataOut )
    HRESULT ComputeVolumeSamples ( LPD3DXPRTBUFFER pSurfDataIn,
                                   UINT SHOrder,
                                    UINT NumVolSamples,
                                   D3DXVECTOR3* pSampleLocs,
                                   LPD3DXPRTBUFFER pDataOut )
    HRESULT ComputeSurfSamplesDirectSH ( UINT SHOrder,
                                         UINT NumSamples,
                                         D3DXVECTOR3* pSampleLocs,
                                         D3DXVECTOR3* pSampleNorms,
                                         LPD3DXPRTBUFFER pDataOut )
    HRESULT ComputeSurfSamplesBounce ( LPD3DXPRTBUFFER pSurfDataIn,
                                       UINT NumSamples,
                                       D3DXVECTOR3* pSampleLocs,
                                       D3DXVECTOR3* pSampleNorms,
                                       LPD3DXPRTBUFFER pDataOut,
                                       LPD3DXPRTBUFFER pDataTotal )
    HRESULT FreeSSData ( )
    HRESULT FreeBounceData ( )
    HRESULT ComputeLDPRTCoeffs ( LPD3DXPRTBUFFER pDataIn,
                                 UINT SHOrder,
                                 D3DXVECTOR3* pNormOut,
                                 LPD3DXPRTBUFFER pDataOut )
    HRESULT ScaleMeshChunk ( UINT uMeshChunk, FLOAT fScale, LPD3DXPRTBUFFER pDataOut )
    HRESULT MultiplyAlbedo ( LPD3DXPRTBUFFER pDataOut )
    HRESULT SetCallBack ( LPD3DXSHPRTSIMCB pCB, FLOAT Frequency,  LPVOID lpUserContext )
    BOOL ShadowRayIntersects ( D3DXVECTOR3* pRayPos, D3DXVECTOR3* pRayDir )
    BOOL ClosestRayIntersects ( D3DXVECTOR3* pRayPos, D3DXVECTOR3* pRayDir,
                                DWORD* pFaceIndex, FLOAT* pU, FLOAT* pV, FLOAT* pDist ) ;

FUNCTION: HRESULT
    D3DXCreatePRTBuffer (
        UINT             NumSamples,
        UINT             NumCoeffs,
        UINT             NumChannels,
        LPD3DXPRTBUFFER* ppBuffer )

FUNCTION: HRESULT
    D3DXCreatePRTBufferTex (
        UINT             Width,
        UINT             Height,
        UINT             NumCoeffs,
        UINT             NumChannels,
        LPD3DXPRTBUFFER* ppBuffer )

FUNCTION: HRESULT
    D3DXLoadPRTBufferFromFileA (
        LPCSTR                 pFilename,
        LPD3DXPRTBUFFER*       ppBuffer )

FUNCTION: HRESULT
    D3DXLoadPRTBufferFromFileW (
        LPCWSTR                pFilename,
        LPD3DXPRTBUFFER*       ppBuffer )

ALIAS: D3DXLoadPRTBufferFromFile D3DXLoadPRTBufferFromFileW

FUNCTION: HRESULT
    D3DXSavePRTBufferToFileA (
        LPCSTR          pFileName,
        LPD3DXPRTBUFFER pBuffer )

FUNCTION: HRESULT
    D3DXSavePRTBufferToFileW (
        LPCWSTR         pFileName,
        LPD3DXPRTBUFFER pBuffer )

ALIAS: D3DXSavePRTBufferToFile D3DXSavePRTBufferToFileW

C-TYPE: D3DXPRTCompBuffer
! TYPEDEF: D3DXPRTCOMPBUFFER* LPD3DXPRTCOMPBUFFER

FUNCTION: HRESULT
    D3DXLoadPRTCompBufferFromFileA (
        LPCSTR                     pFilename,
        LPD3DXPRTCOMPBUFFER*       ppBuffer )

FUNCTION: HRESULT
    D3DXLoadPRTCompBufferFromFileW (
        LPCWSTR                    pFilename,
        LPD3DXPRTCOMPBUFFER*       ppBuffer )

ALIAS: D3DXLoadPRTCompBufferFromFile D3DXLoadPRTCompBufferFromFileW

FUNCTION: HRESULT
    D3DXSavePRTCompBufferToFileA (
        LPCSTR              pFileName,
        LPD3DXPRTCOMPBUFFER pBuffer )

FUNCTION: HRESULT
    D3DXSavePRTCompBufferToFileW (
        LPCWSTR             pFileName,
        LPD3DXPRTCOMPBUFFER pBuffer )

ALIAS: D3DXSavePRTCompBufferToFile D3DXSavePRTCompBufferToFileW

FUNCTION: HRESULT
    D3DXCreatePRTCompBuffer (
        D3DXSHCOMPRESSQUALITYTYPE Quality,
        UINT                      NumClusters,
        UINT                      NumPCA,
        LPD3DXSHPRTSIMCB          pCB,
        LPVOID                    lpUserContext,
        LPD3DXPRTBUFFER           pBufferIn,
        LPD3DXPRTCOMPBUFFER*      ppBufferOut )

FUNCTION: HRESULT
    D3DXCreateTextureGutterHelper (
        UINT                       Width,
        UINT                       Height,
        LPD3DXMESH                 pMesh,
        FLOAT                      GutterSize,
        LPD3DXTEXTUREGUTTERHELPER* ppBuffer )

FUNCTION: HRESULT
    D3DXCreatePRTEngine (
        LPD3DXMESH       pMesh,
        DWORD*           pAdjacency,
        BOOL             ExtractUVs,
        LPD3DXMESH       pBlockerMesh,
        LPD3DXPRTENGINE* ppEngine )

FUNCTION: HRESULT
    D3DXConcatenateMeshes (
        LPD3DXMESH*        ppMeshes,
        UINT               NumMeshes,
        DWORD              Options,
        D3DXMATRIX*        pGeomXForms,
        D3DXMATRIX*        pTextureXForms,
        D3DVERTEXELEMENT9* pDecl,
        LPDIRECT3DDEVICE9  pD3DDevice,
        LPD3DXMESH*        ppMeshOut )

FUNCTION: HRESULT
    D3DXSHPRTCompSuperCluster (
        UINT*      pClusterIDs,
        LPD3DXMESH pScene,
        UINT       MaxNumClusters,
        UINT       NumClusters,
        UINT*      pSuperClusterIDs,
        UINT*      pNumSuperClusters )

FUNCTION: HRESULT
    D3DXSHPRTCompSplitMeshSC (
        UINT*                          pClusterIDs,
        UINT                           NumVertices,
        UINT                           NumClusters,
        UINT*                          pSuperClusterIDs,
        UINT                           NumSuperClusters,
        LPVOID                         pInputIB,
        BOOL                           InputIBIs32Bit,
        UINT                           NumFaces,
        LPD3DXBUFFER*                  ppIBData,
        UINT*                          pIBDataLength,
        BOOL                           OutputIBIs32Bit,
        LPD3DXBUFFER*                  ppFaceRemap,
        LPD3DXBUFFER*                  ppVertData,
        UINT*                          pVertDataLength,
        UINT*                          pSCClusterList,
        D3DXSHPRTSPLITMESHCLUSTERDATA* pSCData )
