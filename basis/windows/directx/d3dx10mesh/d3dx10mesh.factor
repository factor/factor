USING: alien.c-types alien.syntax classes.struct windows.com
windows.com.syntax windows.directx windows.directx.d3d10
windows.directx.d3d10misc windows.types windows.directx.d3dx10math ;
IN: windows.directx.d3dx10mesh

LIBRARY: d3dx10

CONSTANT: D3DX10_MESH_32_BIT       1
CONSTANT: D3DX10_MESH_GS_ADJACENCY 4

TYPEDEF: int D3DX10_MESH

STRUCT: D3DX10_ATTRIBUTE_RANGE
    { AttribId     UINT }
    { FaceStart    UINT }
    { FaceCount    UINT }
    { VertexStart  UINT }
    { VertexCount  UINT } ;

TYPEDEF: D3DX10_ATTRIBUTE_RANGE* LPD3DX10_ATTRIBUTE_RANGE

CONSTANT: D3DX10_MESH_DISCARD_ATTRIBUTE_BUFFER 0x01
CONSTANT: D3DX10_MESH_DISCARD_ATTRIBUTE_TABLE  0x02
CONSTANT: D3DX10_MESH_DISCARD_POINTREPS        0x04
CONSTANT: D3DX10_MESH_DISCARD_ADJACENCY        0x08
CONSTANT: D3DX10_MESH_DISCARD_DEVICE_BUFFERS   0x10
TYPEDEF: int D3DX10_MESH_DISCARD_FLAGS

STRUCT: D3DX10_WELD_EPSILONS
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

TYPEDEF: D3DX10_WELD_EPSILONS* LPD3DX10_WELD_EPSILONS

STRUCT: D3DX10_INTERSECT_INFO
    { FaceIndex  UINT  }
    { U          FLOAT }
    { V          FLOAT }
    { Dist       FLOAT } ;
TYPEDEF: D3DX10_INTERSECT_INFO* LPD3DX10_INTERSECT_INFO

COM-INTERFACE: ID3DX10MeshBuffer IUnknown {04B0D117-1041-46b1-AA8A-3952848BA22E}
    HRESULT Map ( void** ppData, SIZE_T* pSize )
    HRESULT Unmap ( )
    SIZE_T GetSize ( ) ;

COM-INTERFACE: ID3DX10Mesh IUnknown {4020E5C2-1403-4929-883F-E2E849FAC195}
    UINT GetFaceCount ( )
    UINT GetVertexCount ( )
    UINT GetVertexBufferCount ( )
    UINT GetFlags ( )
    HRESULT GetVertexDescription ( D3D10_INPUT_ELEMENT_DESC** ppDesc, UINT* pDeclCount )
    HRESULT SetVertexData ( UINT iBuffer, void* pData )
    HRESULT GetVertexBuffer ( UINT iBuffer, ID3DX10MeshBuffer** ppVertexBuffer )
    HRESULT SetIndexData ( void* pData, UINT cIndices )
    HRESULT GetIndexBuffer ( ID3DX10MeshBuffer** ppIndexBuffer )
    HRESULT SetAttributeData ( UINT* pData )
    HRESULT GetAttributeBuffer ( ID3DX10MeshBuffer** ppAttributeBuffer )
    HRESULT SetAttributeTable ( D3DX10_ATTRIBUTE_RANGE* pAttribTable, UINT cAttribTableSize )
    HRESULT GetAttributeTable ( D3DX10_ATTRIBUTE_RANGE* pAttribTable, UINT* pAttribTableSize )
    HRESULT GenerateAdjacencyAndPointReps ( FLOAT Epsilon )
    HRESULT GenerateGSAdjacency ( )
    HRESULT SetAdjacencyData ( UINT* pAdjacency )
    HRESULT GetAdjacencyBuffer ( ID3DX10MeshBuffer** ppAdjacency )
    HRESULT SetPointRepData ( UINT* pPointReps )
    HRESULT GetPointRepBuffer ( ID3DX10MeshBuffer** ppPointReps )
    HRESULT Discard ( D3DX10_MESH_DISCARD_FLAGS dwDiscard )
    HRESULT CloneMesh ( UINT Flags, LPCSTR pPosSemantic, D3D10_INPUT_ELEMENT_DESC* pDesc, UINT DeclCount, ID3DX10Mesh** ppCloneMesh )
    HRESULT Optimize ( UINT Flags, UINT* pFaceRemap, LPD3D10BLOB* ppVertexRemap )
    HRESULT GenerateAttributeBufferFromTable ( )
    HRESULT Intersect ( D3DXVECTOR3* pRayPos, D3DXVECTOR3* pRayDir,
                                        UINT* pHitCount, UINT* pFaceIndex, float* pU, float* pV, float* pDist, ID3D10Blob** ppAllHits )
    HRESULT IntersectSubset ( UINT AttribId, D3DXVECTOR3* pRayPos, D3DXVECTOR3* pRayDir,
                                        UINT* pHitCount, UINT* pFaceIndex, float* pU, float* pV, float* pDist, ID3D10Blob** ppAllHits )
    HRESULT CommitToDevice ( )
    HRESULT DrawSubset ( UINT AttribId )
    HRESULT DrawSubsetInstanced ( UINT AttribId, UINT InstanceCount, UINT StartInstanceLocation )
    HRESULT GetDeviceVertexBuffer ( UINT iBuffer, ID3D10Buffer** ppVertexBuffer )
    HRESULT GetDeviceIndexBuffer ( ID3D10Buffer** ppIndexBuffer ) ;

FUNCTION: HRESULT
    D3DX10CreateMesh (
        ID3D10Device*             pDevice,
        D3D10_INPUT_ELEMENT_DESC* pDeclaration,
        UINT                      DeclCount,
        LPCSTR                    pPositionSemantic,
        UINT                      VertexCount,
        UINT                      FaceCount,
        UINT                      Options,
        ID3DX10Mesh**             ppMesh )

CONSTANT: D3DX10_MESHOPT_COMPACT            0x01000000
CONSTANT: D3DX10_MESHOPT_ATTR_SORT          0x02000000
CONSTANT: D3DX10_MESHOPT_VERTEX_CACHE       0x04000000
CONSTANT: D3DX10_MESHOPT_STRIP_REORDER      0x08000000
CONSTANT: D3DX10_MESHOPT_IGNORE_VERTS       0x10000000
CONSTANT: D3DX10_MESHOPT_DO_NOT_SPLIT       0x20000000
CONSTANT: D3DX10_MESHOPT_DEVICE_INDEPENDENT 0x00400000

CONSTANT: D3DX10_SKININFO_NO_SCALING     0
CONSTANT: D3DX10_SKININFO_SCALE_TO_1     1
CONSTANT: D3DX10_SKININFO_SCALE_TO_TOTAL 2

STRUCT: D3DX10_SKINNING_CHANNEL
    { SrcOffset             UINT }
    { DestOffset            UINT }
    { IsNormal              BOOL } ;

COM-INTERFACE: ID3DX10SkinInfo IUnknown {420BD604-1C76-4a34-A466-E45D0658A32C}
    UINT GetNumVertices ( )
    UINT GetNumBones ( )
    UINT GetMaxBoneInfluences ( )
    HRESULT AddVertices ( UINT Count )
    HRESULT RemapVertices ( UINT NewVertexCount, UINT* pVertexRemap )
    HRESULT AddBones ( UINT Count )
    HRESULT RemoveBone ( UINT Index )
    HRESULT RemapBones ( UINT NewBoneCount, UINT* pBoneRemap )
    HRESULT AddBoneInfluences ( UINT BoneIndex, UINT InfluenceCount, UINT* pIndices, float* pWeights )
    HRESULT ClearBoneInfluences ( UINT BoneIndex )
    UINT GetBoneInfluenceCount ( UINT BoneIndex )
    HRESULT GetBoneInfluences ( UINT BoneIndex, UINT Offset, UINT Count, UINT* pDestIndices, float* pDestWeights )
    HRESULT FindBoneInfluenceIndex ( UINT BoneIndex, UINT VertexIndex, UINT* pInfluenceIndex )
    HRESULT SetBoneInfluence ( UINT BoneIndex, UINT InfluenceIndex, float Weight )
    HRESULT GetBoneInfluence ( UINT BoneIndex, UINT InfluenceIndex, float* pWeight )
    HRESULT Compact ( UINT MaxPerVertexInfluences, UINT ScaleMode, float MinWeight )
    HRESULT DoSoftwareSkinning ( UINT StartVertex, UINT VertexCount, void* pSrcVertices, UINT SrcStride, void* pDestVertices, UINT DestStride, D3DXMATRIX* pBoneMatrices, D3DXMATRIX* pInverseTransposeBoneMatrices, D3DX10_SKINNING_CHANNEL* pChannelDescs, UINT NumChannels ) ;

TYPEDEF: ID3DX10SkinInfo* LPD3DX10SKININFO

FUNCTION: HRESULT
    D3DX10CreateSkinInfo ( LPD3DX10SKININFO* ppSkinInfo )

STRUCT: D3DX10_ATTRIBUTE_WEIGHTS
    { Position FLOAT    }
    { Boundary FLOAT    }
    { Normal   FLOAT    }
    { Diffuse  FLOAT    }
    { Specular FLOAT    }
    { Texcoord FLOAT[8] }
    { Tangent  FLOAT    }
    { Binormal FLOAT    } ;
