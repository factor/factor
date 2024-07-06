! Copyright (C) 2010 Erik Charlebois
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.libraries
alien.syntax classes.struct combinators combinators.short-circuit
kernel math math.order sequences typed specialized-arrays system ;
SPECIALIZED-ARRAY: void*
IN: chipmunk.ffi

<<
"chipmunk" {
    { [ os windows? ] [ "chipmunk.dll" ] }
    { [ os macos? ] [ "libchipmunk.dylib"  ] }
    { [ os unix?  ] [ "libchipmunk.so" ] }
} cond cdecl add-library

"chipmunk" deploy-library
>>
LIBRARY: chipmunk

! chipmunk_types.h
TYPEDEF: double cpFloat
STRUCT: cpVect
    { x cpFloat }
    { y cpFloat } ;
SPECIALIZED-ARRAY: cpVect

TYPEDEF: uint cpHashValue
TYPEDEF: void* cpDataPointer
TYPEDEF: uint cpCollisionType
TYPEDEF: uint cpLayers
TYPEDEF: uint cpGroup

CONSTANT: CP_NO_GROUP 0
CONSTANT: CP_ALL_LAYERS 0xffffffff

! cpVect.h
TYPED: cpv ( x y -- v: cpVect )
    cpVect boa ; inline

TYPED: cpvzero ( -- v: cpVect )
    0.0 0.0 cpv ; inline

FUNCTION: cpFloat cpvlength ( cpVect v )
FUNCTION: cpVect cpvslerp ( cpVect v1, cpVect v2, cpFloat t )
FUNCTION: cpVect cpvslerpconst ( cpVect v1, cpVect v2, cpFloat a )
FUNCTION: cpVect cpvforangle ( cpFloat a )
FUNCTION: cpFloat cpvtoangle ( cpVect v )
FUNCTION: c-string cpvstr ( cpVect v )

TYPED: cpvadd ( v1: cpVect v2: cpVect -- v3: cpVect )
    [ [ x>> ] bi@ + ]
    [ [ y>> ] bi@ + ] 2bi cpv ; inline

TYPED: cpvneg ( v1: cpVect -- v2: cpVect )
    [ x>> ] [ y>> ] bi [ neg ] bi@ cpv ; inline

TYPED: cpvsub ( v1: cpVect v2: cpVect -- v3: cpVect )
    [ [ x>> ] bi@ - ]
    [ [ y>> ] bi@ - ] 2bi cpv ; inline

TYPED: cpvmult ( v1: cpVect s -- v2: cpVect )
    [ swap x>> * ]
    [ swap y>> * ] 2bi cpv ; inline

TYPED: cpvdot ( v1: cpVect v2: cpVect -- s )
    [ [ x>> ] bi@ * ]
    [ [ y>> ] bi@ * ] 2bi + ; inline

TYPED: cpvcross ( v1: cpVect v2: cpVect -- s )
    [ [ x>> ] [ y>> ] bi* * ]
    [ [ y>> ] [ x>> ] bi* * ] 2bi - ; inline

TYPED: cpvperp ( v1: cpVect -- v2: cpVect )
    [ y>> neg ] [ x>> ] bi cpv ; inline

TYPED: cpvrperp ( v1: cpVect -- v2: cpVect )
    [ y>> ] [ x>> neg ] bi cpv ; inline

TYPED: cpvproject ( v1: cpVect v2: cpVect -- v3: cpVect )
    [ nip ]
    [ cpvdot ]
    [ nip dup cpvdot ]
    2tri / cpvmult ; inline

TYPED: cpvrotate ( v1: cpVect v2: cpVect -- v3: cpVect )
    [
        [ [ x>> ] bi@ * ]
        [ [ y>> ] bi@ * ] 2bi -
    ]
    [
        [ [ x>> ] [ y>> ] bi* * ]
        [ [ y>> ] [ x>> ] bi* * ] 2bi +
    ] 2bi cpv ; inline

TYPED: cpvunrotate ( v1: cpVect v2: cpVect -- v3: cpVect )
    [
        [ [ x>> ] bi@ * ]
        [ [ y>> ] bi@ * ] 2bi +
    ]
    [
        [ [ y>> ] [ x>> ] bi* * ]
        [ [ x>> ] [ y>> ] bi* * ] 2bi -
    ] 2bi cpv ; inline

TYPED: cpvlengthsq ( v: cpVect -- s )
    dup cpvdot ; inline

TYPED: cpvlerp ( v1: cpVect v2: cpVect s -- v3: cpVect )
    [ nip 1.0 swap - cpvmult ]
    [ cpvmult nip ] 3bi cpvadd ; inline

TYPED: cpvnormalize ( v1: cpVect -- v2: cpVect )
    dup cpvlength recip cpvmult ; inline

TYPED: cpvnormalize_safe ( v1: cpVect -- v2: cpVect )
    dup [ x>> 0.0 = ] [ y>> 0.0 = ] bi and
    [ drop cpvzero ]
    [ cpvnormalize ] if ; inline

TYPED: cpvclamp ( v1: cpVect len -- v2: cpVect )
    2dup
    [ dup cpvdot ]
    [ sq ] 2bi* >
    [ [ cpvnormalize ] dip cpvmult ]
    [ drop ] if ; inline

TYPED: cpvlerpconst ( v1: cpVect v2: cpVect d -- v3: cpVect )
    [ 2drop ]
    [ [ swap cpvsub ] dip cpvclamp ] 3bi cpvadd ; inline

TYPED: cpvdist ( v1: cpVect v2: cpVect -- dist )
    cpvsub cpvlength ; inline

TYPED: cpvdistsq ( v1: cpVect v2: cpVect -- distsq )
    cpvsub cpvlengthsq ; inline

TYPED: cpvnear ( v1: cpVect v2: cpVect dist -- ? )
    [ cpvdistsq ] dip sq < ; inline

! cpBB.h
STRUCT: cpBB
    { l cpFloat }
    { b cpFloat }
    { r cpFloat }
    { t cpFloat } ;

TYPED: cpBBNew ( l b r t -- cpbb: cpBB )
    cpBB boa ; inline

TYPED: cpBBintersects ( a: cpBB b: cpBB -- ? )
    {
        [ [ l>> ] [ r>> ] bi* <= ]
        [ [ r>> ] [ l>> ] bi*  > ]
        [ [ b>> ] [ t>> ] bi* <= ]
        [ [ t>> ] [ b>> ] bi*  > ]
    } 2&& ; inline

TYPED: cpBBcontainsBB ( bb: cpBB other: cpBB -- ? )
    {
        [ [ l>> ] bi@ < ]
        [ [ r>> ] bi@ > ]
        [ [ b>> ] bi@ < ]
        [ [ t>> ] bi@ > ]
    } 2&& ; inline

TYPED: cpBBcontainsVect ( bb: cpBB v: cpVect -- ? )
    {
        [ [ l>> ] [ x>> ] bi* < ]
        [ [ r>> ] [ x>> ] bi* > ]
        [ [ b>> ] [ y>> ] bi* < ]
        [ [ t>> ] [ y>> ] bi* > ]
    } 2&& ; inline

TYPED: cpBBmerge ( a: cpBB b: cpBB -- c: cpBB )
    {
        [ [ l>> ] bi@ min ]
        [ [ b>> ] bi@ min ]
        [ [ r>> ] bi@ max ]
        [ [ t>> ] bi@ max ]
    } 2cleave cpBBNew ; inline

TYPED: cpBBexpand ( bb: cpBB v: cpVect -- b: cpBB )
    {
        [ [ l>> ] [ x>> ] bi* min ]
        [ [ b>> ] [ y>> ] bi* min ]
        [ [ r>> ] [ x>> ] bi* max ]
        [ [ t>> ] [ y>> ] bi* max ]
    } 2cleave cpBBNew ; inline

FUNCTION: cpVect cpBBClampVect ( cpBB bb, cpVect v )
FUNCTION: cpVect cpBBWrapVect ( cpBB bb, cpVect v )

! cpBody.h
C-TYPE: cpBody
CALLBACK: void cpBodyVelocityFunc ( cpBody* body, cpVect gravity, cpFloat damping, cpFloat dt )
CALLBACK: void cpBodyPositionFunc ( cpBody* body, cpFloat dt )

STRUCT: cpBody
    { velocity_func cpBodyVelocityFunc }
    { position_func cpBodyPositionFunc }
    { m             cpFloat            }
    { m_inv         cpFloat            }
    { i             cpFloat            }
    { i_inv         cpFloat            }
    { p             cpVect             }
    { v             cpVect             }
    { f             cpVect             }
    { a             cpFloat            }
    { w             cpFloat            }
    { t             cpFloat            }
    { rot           cpVect             }
    { data          cpDataPointer      }
    { v_limit       cpFloat            }
    { w_limit       cpFloat            }
    { v_bias        cpVect             }
    { w_bias        cpFloat            } ;

FUNCTION: cpBody* cpBodyAlloc ( )
FUNCTION: cpBody* cpBodyInit ( cpBody* body, cpFloat m, cpFloat i )
FUNCTION: cpBody* cpBodyNew ( cpFloat m, cpFloat i )
FUNCTION: void cpBodyDestroy ( cpBody* body )
FUNCTION: void cpBodyFree ( cpBody* body )
FUNCTION: void cpBodySetMass ( cpBody* body, cpFloat m )
FUNCTION: void cpBodySetMoment ( cpBody* body, cpFloat i )
FUNCTION: void cpBodySetAngle ( cpBody* body, cpFloat a )
FUNCTION: void cpBodySlew ( cpBody* body, cpVect pos, cpFloat dt )
FUNCTION: void cpBodyUpdateVelocity ( cpBody* body, cpVect gravity, cpFloat damping, cpFloat dt )
FUNCTION: void cpBodyUpdatePosition ( cpBody* body, cpFloat dt )

TYPED: cpBodyLocal2World ( body: cpBody v: cpVect -- v2: cpVect )
    [ drop p>> ]
    [ swap rot>> cpvrotate ] 2bi cpvadd ; inline

TYPED: cpBodyWorld2Local ( body: cpBody v: cpVect -- v2: cpVect )
    [ swap p>> cpvsub ]
    [ drop rot>> ] 2bi cpvunrotate ; inline

TYPED: cpBodyApplyImpulse ( body: cpBody j: cpVect r: cpVect -- )
    [
        drop
        [ drop dup v>> ]
        [ swap m_inv>> cpvmult ] 2bi cpvadd >>v drop
    ]
    [
        [ 2drop dup w_bias>> ]
        [ swap cpvcross [ i_inv>> ] dip * ] 3bi + >>w_bias drop
    ] 3bi ; inline

FUNCTION: void cpBodyResetForces ( cpBody* body )
FUNCTION: void cpBodyApplyForce ( cpBody* body, cpVect f, cpVect r )
FUNCTION: void cpApplyDampedSpring ( cpBody* a, cpBody* b, cpVect anchr1, cpVect anchr2, cpFloat rlen, cpFloat k, cpFloat dmp, cpFloat dt )

! cpArray.h
STRUCT: cpArray
    { num int    }
    { max int    }
    { arr void** } ;

CALLBACK: void cpArrayIter ( void* ptr, void* data )

FUNCTION: cpArray* cpArrayAlloc ( )
FUNCTION: cpArray* cpArrayInit ( cpArray* arr, int size )
FUNCTION: cpArray* cpArrayNew ( int size )
FUNCTION: void cpArrayDestroy ( cpArray* arr )
FUNCTION: void cpArrayFree ( cpArray* arr )
FUNCTION: void cpArrayPush ( cpArray* arr, void* object )
FUNCTION: void cpArrayDeleteIndex ( cpArray* arr, int idx )
FUNCTION: void cpArrayDeleteObj ( cpArray* arr, void* obj )
FUNCTION: void cpArrayEach ( cpArray* arr, cpArrayIter iterFunc, void* data )
FUNCTION: int cpArrayContains ( cpArray* arr, void* ptr )

! cpHashSet.h
STRUCT: cpHashSetBin
    { elt  void*         }
    { hash cpHashValue   }
    { next cpHashSetBin* } ;

CALLBACK: int cpHashSetEqlFunc ( void* ptr, void* elt )
CALLBACK: void* cpHashSetTransFunc ( void* ptr, void* data )
CALLBACK: void cpHashSetIterFunc ( void* elt, void* data )
CALLBACK: int cpHashSetFilterFunc ( void* elt, void* data )

STRUCT: cpHashSet
    { entries       int                }
    { size          int                }
    { eql           cpHashSetEqlFunc   }
    { trans         cpHashSetTransFunc }
    { default_value void*              }
    { table         cpHashSetBin**     } ;

FUNCTION: void cpHashSetDestroy ( cpHashSet* set )
FUNCTION: void cpHashSetFree ( cpHashSet* set )
FUNCTION: cpHashSet* cpHashSetAlloc ( )
FUNCTION: cpHashSet* cpHashSetInit ( cpHashSet* set, int size, cpHashSetEqlFunc eqlFunc, cpHashSetTransFunc trans )
FUNCTION: cpHashSet* cpHashSetNew ( int size, cpHashSetEqlFunc eqlFunc, cpHashSetTransFunc trans )
FUNCTION: void* cpHashSetInsert ( cpHashSet* set, cpHashValue hash, void* ptr, void* data )
FUNCTION: void* cpHashSetRemove ( cpHashSet* set, cpHashValue hash, void* ptr )
FUNCTION: void* cpHashSetFind ( cpHashSet* set, cpHashValue hash, void* ptr )
FUNCTION: void cpHashSetEach ( cpHashSet* set, cpHashSetIterFunc func, void* data )
FUNCTION: void cpHashSetFilter ( cpHashSet* set, cpHashSetFilterFunc func, void* data )

! cpSpaceHash.h
STRUCT: cpHandle
    { obj    void* }
    { retain int   }
    { stamp  int   } ;

STRUCT: cpSpaceHashBin
    { handle cpHandle*       }
    { next   cpSpaceHashBin* } ;

CALLBACK: cpBB cpSpaceHashBBFunc ( void* obj )

STRUCT: cpSpaceHash
    { numcells  int               }
    { celldim   cpFloat           }
    { bbfunc    cpSpaceHashBBFunc }
    { handleSet cpHashSet*        }
    { table     cpSpaceHashBin**  }
    { bins      cpSpaceHashBin*   }
    { stamp     int               } ;

FUNCTION: cpSpaceHash* cpSpaceHashAlloc ( )
FUNCTION: cpSpaceHash* cpSpaceHashInit ( cpSpaceHash* hash, cpFloat celldim, int cells, cpSpaceHashBBFunc bbfunc )
FUNCTION: cpSpaceHash* cpSpaceHashNew ( cpFloat celldim, int cells, cpSpaceHashBBFunc bbfunc )
FUNCTION: void cpSpaceHashDestroy ( cpSpaceHash* hash )
FUNCTION: void cpSpaceHashFree ( cpSpaceHash* hash )
FUNCTION: void cpSpaceHashResize ( cpSpaceHash* hash, cpFloat celldim, int numcells )
FUNCTION: void cpSpaceHashInsert ( cpSpaceHash* hash, void* obj, cpHashValue id, cpBB bb )
FUNCTION: void cpSpaceHashRemove ( cpSpaceHash* hash, void* obj, cpHashValue id )
CALLBACK: void cpSpaceHashIterator ( void* obj, void* data )
FUNCTION: void cpSpaceHashEach ( cpSpaceHash* hash, cpSpaceHashIterator func, void* data )
FUNCTION: void cpSpaceHashRehash ( cpSpaceHash* hash )
FUNCTION: void cpSpaceHashRehashObject ( cpSpaceHash* hash, void* obj, cpHashValue id )
CALLBACK: void cpSpaceHashQueryFunc ( void* obj1, void* obj2, void* data )
FUNCTION: void cpSpaceHashPointQuery ( cpSpaceHash* hash, cpVect point, cpSpaceHashQueryFunc func, void* data )
FUNCTION: void cpSpaceHashQuery ( cpSpaceHash* hash, void* obj, cpBB bb, cpSpaceHashQueryFunc func, void* data )
FUNCTION: void cpSpaceHashQueryRehash ( cpSpaceHash* hash, cpSpaceHashQueryFunc func, void* data )
CALLBACK: cpFloat cpSpaceHashSegmentQueryFunc ( void* obj1, void* obj2, void* data )
FUNCTION: void cpSpaceHashSegmentQuery ( cpSpaceHash* hash, void* obj, cpVect a, cpVect b, cpFloat t_exit, cpSpaceHashSegmentQueryFunc func, void* data )

! cpShape.h
C-TYPE: cpShape
C-TYPE: cpShapeClass

STRUCT: cpSegmentQueryInfo
    { shape cpShape* }
    { t     cpFloat  }
    { n     cpVect   } ;

ENUM: cpShapeType
    CP_CIRCLE_SHAPE
    CP_SEGMENT_SHAPE
    CP_POLY_SHAPE
    CP_NUM_SHAPES ;

CALLBACK: cpBB cacheData_cb ( cpShape* shape, cpVect p, cpVect rot )
CALLBACK: void destroy_cb ( cpShape* shape )
CALLBACK: int pointQuery_cb ( cpShape* shape, cpVect p )
CALLBACK: void segmentQuery_cb ( cpShape* shape, cpVect a, cpVect b, cpSegmentQueryInfo* info )

STRUCT: cpShapeClass
    { type         cpShapeType     }
    { cacheData    cacheData_cb    }
    { destroy      destroy_cb      }
    { pointQuery   pointQuery_cb   }
    { segmentQuery segmentQuery_cb } ;

STRUCT: cpShape
    { klass          cpShapeClass*   }
    { body           cpBody*         }
    { bb             cpBB            }
    { sensor         int             }
    { e              cpFloat         }
    { u              cpFloat         }
    { surface_v      cpVect          }
    { data           cpDataPointer   }
    { collision_type cpCollisionType }
    { group          cpGroup         }
    { layers         cpLayers        }
    { hashid         cpHashValue     } ;

FUNCTION: cpShape* cpShapeInit ( cpShape* shape, cpShapeClass* klass, cpBody* body )
FUNCTION: void cpShapeDestroy ( cpShape* shape )
FUNCTION: void cpShapeFree ( cpShape* shape )
FUNCTION: cpBB cpShapeCacheBB ( cpShape* shape )
FUNCTION: int cpShapePointQuery ( cpShape* shape, cpVect p )

STRUCT: cpCircleShape
    { shape cpShape }
    { c     cpVect  }
    { r     cpFloat }
    { tc    cpVect  } ;

FUNCTION: cpCircleShape* cpCircleShapeAlloc ( )
FUNCTION: cpCircleShape* cpCircleShapeInit ( cpCircleShape* circle, cpBody* body, cpFloat radius, cpVect offset )
FUNCTION: cpShape* cpCircleShapeNew ( cpBody* body, cpFloat radius, cpVect offset )

STRUCT: cpSegmentShape
    { shape cpShape }
    { a     cpVect  }
    { b     cpVect  }
    { n     cpVect  }
    { r     cpFloat }
    { ta    cpVect  }
    { tb    cpVect  }
    { tn    cpVect  } ;

FUNCTION: cpSegmentShape* cpSegmentShapeAlloc ( )
FUNCTION: cpSegmentShape* cpSegmentShapeInit ( cpSegmentShape* seg, cpBody* body, cpVect a, cpVect b, cpFloat radius )
FUNCTION: cpShape* cpSegmentShapeNew ( cpBody* body, cpVect a, cpVect b, cpFloat radius )
FUNCTION: void cpResetShapeIdCounter ( )
FUNCTION: void cpSegmentQueryInfoPrint ( cpSegmentQueryInfo* info )
FUNCTION: int cpShapeSegmentQuery ( cpShape* shape, cpVect a, cpVect b, cpSegmentQueryInfo* info )

TYPED: cpSegmentQueryHitPoint ( start: cpVect end: cpVect info: cpSegmentQueryInfo -- hit-point: cpVect )
    t>> cpvlerp ; inline

TYPED: cpSegmentQueryHitDist ( start: cpVect end: cpVect info: cpSegmentQueryInfo -- hit-dist )
    t>> [ cpvdist ] dip * ; inline

! cpPolyShape.h
STRUCT: cpPolyShapeAxis
    { n cpVect  }
    { d cpFloat } ;
SPECIALIZED-ARRAY: cpPolyShapeAxis

STRUCT: cpPolyShape
    { shape    cpShape          }
    { numVerts int              }
    { verts    cpVect*          }
    { axes     cpPolyShapeAxis* }
    { tVerts   cpVect*          }
    { tAxes    cpPolyShapeAxis* } ;

FUNCTION: cpPolyShape* cpPolyShapeAlloc ( )
FUNCTION: cpPolyShape* cpPolyShapeInit ( cpPolyShape* poly, cpBody* body, int numVerts, cpVect* verts, cpVect offset )
FUNCTION: cpShape* cpPolyShapeNew ( cpBody* body, int numVerts, cpVect* verts, cpVect offset )
FUNCTION: int cpPolyValidate ( cpVect* verts, int numVerts )
FUNCTION: int cpPolyShapeGetNumVerts ( cpShape* shape )
FUNCTION: cpVect cpPolyShapeGetVert ( cpShape* shape, int idx )

TYPED: cpPolyShapeValueOnAxis ( poly: cpPolyShape n: cpVect d -- min-dist )
    spin [ numVerts>> ] [ tVerts>> swap cpVect <c-direct-array> ] bi swap
    [ cpvdot ] curry [ min ] reduce swap - ; inline

TYPED: cpPolyShapeContainsVert ( poly: cpPolyShape v: cpVect -- ? )
    swap [ numVerts>> ] [ tAxes>> swap cpPolyShapeAxis <c-direct-array> ] bi swap
    [
        [ [ n>> ] dip cpvdot ] [ drop d>> ] 2bi -
    ] curry [ max ] reduce 0.0 <= ; inline

TYPED: cpPolyShapeContainsVertPartial ( poly: cpPolyShape v: cpVect n: cpVect -- ? )
    rot [ numVerts>> ] [ tAxes>> swap cpPolyShapeAxis <c-direct-array> ] bi -rot
    [| axis v n |
        axis n>> n cpvdot 0.0 < 0
        [ 0.0 ]
        [ axis n>> v cpvdot axis d>> - ]
        if
    ] 2curry [ max ] reduce 0.0 <= ; inline

! cpArbiter.h
C-TYPE: cpArbiter
C-TYPE: cpSpace
C-TYPE: cpCollisionHandler

STRUCT: cpContact
    { p      cpVect      }
    { n      cpVect      }
    { dist   cpFloat     }
    { r1     cpVect      }
    { r2     cpVect      }
    { nMass  cpFloat     }
    { tMass  cpFloat     }
    { bounce cpFloat     }
    { jnAcc  cpFloat     }
    { jtAcc  cpFloat     }
    { jBias  cpFloat     }
    { bias   cpFloat     }
    { hash   cpHashValue } ;

FUNCTION: cpContact* cpContactInit ( cpContact* con, cpVect p, cpVect n, cpFloat dist, cpHashValue hash )

ENUM: cpArbiterState
    cpArbiterStateNormal
    cpArbiterStateFirstColl
    cpArbiterStateIgnore ;

STRUCT: cpArbiter
    { numContacts int                 }
    { contacts    cpContact*          }
    { a           cpShape*            }
    { b           cpShape*            }
    { e           cpFloat             }
    { u           cpFloat             }
    { surface_vr  cpVect              }
    { stamp       int                 }
    { handler     cpCollisionHandler* }
    { swappedColl char                }
    { state       char                } ;

FUNCTION: cpArbiter* cpArbiterAlloc ( )
FUNCTION: cpArbiter* cpArbiterInit ( cpArbiter* arb, cpShape* a, cpShape* b )
FUNCTION: cpArbiter* cpArbiterNew ( cpShape* a, cpShape* b )
FUNCTION: void cpArbiterDestroy ( cpArbiter* arb )
FUNCTION: void cpArbiterFree ( cpArbiter* arb )
FUNCTION: void cpArbiterUpdate ( cpArbiter* arb, cpContact* contacts, int numContacts, cpCollisionHandler* handler, cpShape* a, cpShape* b )
FUNCTION: void cpArbiterPreStep ( cpArbiter* arb, cpFloat dt_inv )
FUNCTION: void cpArbiterApplyCachedImpulse ( cpArbiter* arb )
FUNCTION: void cpArbiterApplyImpulse ( cpArbiter* arb, cpFloat eCoef )
FUNCTION: cpVect cpArbiterTotalImpulse ( cpArbiter* arb )
FUNCTION: cpVect cpArbiterTotalImpulseWithFriction ( cpArbiter* arb )
FUNCTION: void cpArbiterIgnore ( cpArbiter* arb )

TYPED: cpArbiterGetShapes ( arb: cpArbiter -- a: cpShape b: cpShape )
    dup swappedColl>> 0 = [
        [ a>> ] [ b>> ] bi
    ] [
        [ b>> ] [ a>> ] bi
    ] if ; inline

TYPED: cpArbiterIsFirstContact ( arb: cpArbiter -- ? )
    state>> cpArbiterStateFirstColl = ; inline

TYPED: cpArbiterGetNormal ( arb: cpArbiter i -- n: cpVect )
    [
        swap
        [ numContacts>> ]
        [ contacts>> swap void* <c-direct-array> ] bi nth cpContact memory>struct n>>
    ]
    [
        drop swappedColl>> 0 = [ cpvneg ] unless
    ] 2bi ; inline

TYPED: cpArbiterGetPoint ( arb: cpArbiter i -- p: cpVect )
    swap
    [ numContacts>> ]
    [ contacts>> swap void* <c-direct-array> ] bi
    nth cpContact memory>struct p>> ; inline

! cpCollision.h
FUNCTION: int cpCollideShapes ( cpShape* a, cpShape* b, cpContact** arr )

! cpConstraint.h

C-TYPE: cpConstraintClass
C-TYPE: cpConstraint

CALLBACK: void cpConstraintPreStepFunction ( cpConstraint* constraint, cpFloat dt, cpFloat dt_inv )
CALLBACK: void cpConstraintApplyImpulseFunction ( cpConstraint* constraint )
CALLBACK: cpFloat cpConstraintGetImpulseFunction ( cpConstraint* constraint )

STRUCT: cpConstraintClass
    { preStep      cpConstraintPreStepFunction      }
    { applyImpulse cpConstraintApplyImpulseFunction }
    { getImpulse   cpConstraintGetImpulseFunction   } ;

STRUCT: cpConstraint
    { klass    cpConstraintClass* }
    { a        cpBody*            }
    { b        cpBody*            }
    { maxForce cpFloat            }
    { biasCoef cpFloat            }
    { maxBias  cpFloat            }
    { data     cpDataPointer      } ;

FUNCTION: void cpConstraintDestroy ( cpConstraint* constraint )
FUNCTION: void cpConstraintFree ( cpConstraint* constraint )
FUNCTION: void cpConstraintCheckCast ( cpConstraint* constraint, cpConstraintClass* klass )

! cpPinJoint.h
FUNCTION: cpConstraintClass* cpPinJointGetClass ( )

STRUCT: cpPinJoint
    { constraint cpConstraint }
    { anchr1     cpVect       }
    { anchr2     cpVect       }
    { dist       cpFloat      }
    { r1         cpVect       }
    { r2         cpVect       }
    { n          cpVect       }
    { nMass      cpFloat      }
    { jnAcc      cpFloat      }
    { jnMax      cpFloat      }
    { bias       cpFloat      } ;

FUNCTION: cpPinJoint* cpPinJointAlloc ( )
FUNCTION: cpPinJoint* cpPinJointInit ( cpPinJoint* joint, cpBody* a, cpBody* b, cpVect anchr1, cpVect anchr2 )
FUNCTION: cpConstraint* cpPinJointNew ( cpBody* a, cpBody* b, cpVect anchr1, cpVect anchr2 )

! cpSlideJoint.h
FUNCTION: cpConstraintClass* cpSlideJointGetClass ( )

STRUCT: cpSlideJoint
    { constraint cpConstraint }
    { anchr1     cpVect       }
    { anchr2     cpVect       }
    { min        cpFloat      }
    { max        cpFloat      }
    { r1         cpVect       }
    { r2         cpVect       }
    { n          cpVect       }
    { nMass      cpFloat      }
    { jnAcc      cpFloat      }
    { jnMax      cpFloat      }
    { bias       cpFloat      } ;

FUNCTION: cpSlideJoint* cpSlideJointAlloc ( )
FUNCTION: cpSlideJoint* cpSlideJointInit ( cpSlideJoint* joint, cpBody* a, cpBody* b, cpVect anchr1, cpVect anchr2, cpFloat min, cpFloat max )
FUNCTION: cpConstraint* cpSlideJointNew ( cpBody* a, cpBody* b, cpVect anchr1, cpVect anchr2, cpFloat min, cpFloat max )

! cpPivotJoint.h
FUNCTION: cpConstraintClass* cpPivotJointGetClass ( )

STRUCT: cpPivotJoint
    { constraint cpConstraint }
    { anchr1     cpVect       }
    { anchr2     cpVect       }
    { r1         cpVect       }
    { r2         cpVect       }
    { k1         cpVect       }
    { k2         cpVect       }
    { jAcc       cpVect       }
    { jMaxLen    cpFloat      }
    { bias       cpVect       } ;

FUNCTION: cpPivotJoint* cpPivotJointAlloc ( )
FUNCTION: cpPivotJoint* cpPivotJointInit ( cpPivotJoint* joint, cpBody* a, cpBody* b, cpVect anchr1, cpVect anchr2 )
FUNCTION: cpConstraint* cpPivotJointNew ( cpBody* a, cpBody* b, cpVect pivot )
FUNCTION: cpConstraint* cpPivotJointNew2 ( cpBody* a, cpBody* b, cpVect anchr1, cpVect anchr2 )

! cpGrooveJoint.h
FUNCTION: cpConstraintClass* cpGrooveJointGetClass ( )

STRUCT: cpGrooveJoint
    { constraint   cpConstraint   }
    { grv_n        cpVect         }
    { grv_a        cpVect         }
    { grv_b        cpVect         }
    { anchr2       cpVect         }
    { grv_tn       cpVect         }
    { clamp        cpFloat        }
    { r1           cpVect         }
    { r2           cpVect         }
    { k1           cpVect         }
    { k2           cpVect         }
    { jAcc         cpVect         }
    { jMaxLen      cpFloat        }
    { bias         cpVect         } ;

FUNCTION: cpGrooveJoint* cpGrooveJointAlloc ( )
FUNCTION: cpGrooveJoint* cpGrooveJointInit ( cpGrooveJoint* joint, cpBody* a, cpBody* b, cpVect groove_a, cpVect groove_b, cpVect anchr2 )
FUNCTION: cpConstraint* cpGrooveJointNew ( cpBody* a, cpBody* b, cpVect groove_a, cpVect groove_b, cpVect anchr2 )

! cpDampedSpring.h
CALLBACK: cpFloat cpDampedSpringForceFunc ( cpConstraint* spring, cpFloat dist )
FUNCTION: cpConstraintClass* cpDampedSpringGetClass ( )

STRUCT: cpDampedSpring
    { constraint      cpConstraint            }
    { anchr1          cpVect                  }
    { anchr2          cpVect                  }
    { restLength      cpFloat                 }
    { stiffness       cpFloat                 }
    { damping         cpFloat                 }
    { springForceFunc cpDampedSpringForceFunc }
    { dt              cpFloat                 }
    { target_vrn      cpFloat                 }
    { r1              cpVect                  }
    { r2              cpVect                  }
    { nMass           cpFloat                 }
    { n               cpVect                  } ;

FUNCTION: cpDampedSpring* cpDampedSpringAlloc ( )
FUNCTION: cpDampedSpring* cpDampedSpringInit ( cpDampedSpring* joint, cpBody* a, cpBody* b, cpVect anchr1, cpVect anchr2, cpFloat restLength, cpFloat stiffness, cpFloat damping )
FUNCTION: cpConstraint* cpDampedSpringNew ( cpBody* a, cpBody* b, cpVect anchr1, cpVect anchr2, cpFloat restLength, cpFloat stiffness, cpFloat damping )

! cpDampedRotarySpring.h
CALLBACK: cpFloat cpDampedRotarySpringTorqueFunc ( cpConstraint* spring, cpFloat relativeAngle )
FUNCTION: cpConstraintClass* cpDampedRotarySpringGetClass ( )

STRUCT: cpDampedRotarySpring
    { constraint       cpConstraint                   }
    { restAngle        cpFloat                        }
    { stiffness        cpFloat                        }
    { damping          cpFloat                        }
    { springTorqueFunc cpDampedRotarySpringTorqueFunc }
    { dt               cpFloat                        }
    { target_wrn       cpFloat                        }
    { iSum             cpFloat                        } ;

FUNCTION: cpDampedRotarySpring* cpDampedRotarySpringAlloc ( )
FUNCTION: cpDampedRotarySpring* cpDampedRotarySpringInit ( cpDampedRotarySpring* joint, cpBody* a, cpBody* b, cpFloat restAngle, cpFloat stiffness, cpFloat damping )
FUNCTION: cpConstraint* cpDampedRotarySpringNew ( cpBody* a, cpBody* b, cpFloat restAngle, cpFloat stiffness, cpFloat damping )

! cpRotaryLimitJoint.h
FUNCTION: cpConstraintClass* cpRotaryLimitJointGetClass ( )

STRUCT: cpRotaryLimitJoint
    { constraint cpConstraint   }
    { min        cpFloat        }
    { max        cpFloat        }
    { iSum       cpFloat        }
    { bias       cpFloat        }
    { jAcc       cpFloat        }
    { jMax       cpFloat        } ;

FUNCTION: cpRotaryLimitJoint* cpRotaryLimitJointAlloc ( )
FUNCTION: cpRotaryLimitJoint* cpRotaryLimitJointInit ( cpRotaryLimitJoint* joint, cpBody* a, cpBody* b, cpFloat min, cpFloat max )
FUNCTION: cpConstraint* cpRotaryLimitJointNew ( cpBody* a, cpBody* b, cpFloat min, cpFloat max )

! cpRatchetJoint.h
FUNCTION: cpConstraintClass* cpRatchetJointGetClass ( )

STRUCT: cpRatchetJoint
    { constraint cpConstraint }
    { angle      cpFloat      }
    { phase      cpFloat      }
    { ratchet    cpFloat      }
    { iSum       cpFloat      }
    { bias       cpFloat      }
    { jAcc       cpFloat      }
    { jMax       cpFloat      } ;

FUNCTION: cpRatchetJoint* cpRatchetJointAlloc ( )
FUNCTION: cpRatchetJoint* cpRatchetJointInit ( cpRatchetJoint* joint, cpBody* a, cpBody* b, cpFloat phase, cpFloat ratchet )
FUNCTION: cpConstraint* cpRatchetJointNew ( cpBody* a, cpBody* b, cpFloat phase, cpFloat ratchet )

! cpGearJoint.h
FUNCTION: cpConstraintClass* cpGearJointGetClass ( )

STRUCT: cpGearJoint
    { constraint cpConstraint }
    { phase      cpFloat      }
    { ratio      cpFloat      }
    { ratio_inv  cpFloat      }
    { iSum       cpFloat      }
    { bias       cpFloat      }
    { jAcc       cpFloat      }
    { jMax       cpFloat      } ;

FUNCTION: cpGearJoint* cpGearJointAlloc ( )
FUNCTION: cpGearJoint* cpGearJointInit ( cpGearJoint* joint, cpBody* a, cpBody* b, cpFloat phase, cpFloat ratio )
FUNCTION: cpConstraint* cpGearJointNew ( cpBody* a, cpBody* b, cpFloat phase, cpFloat ratio )
FUNCTION: void cpGearJointSetRatio ( cpConstraint* constraint, cpFloat value )

! cpSimpleMotor.h
FUNCTION: cpConstraintClass* cpSimpleMotorGetClass ( )

STRUCT: cpSimpleMotor
    { constraint cpConstraint }
    { rate       cpFloat      }
    { iSum       cpFloat      }
    { jAcc       cpFloat      }
    { jMax       cpFloat      } ;

FUNCTION: cpSimpleMotor* cpSimpleMotorAlloc ( )
FUNCTION: cpSimpleMotor* cpSimpleMotorInit ( cpSimpleMotor* joint, cpBody* a, cpBody* b, cpFloat rate )
FUNCTION: cpConstraint* cpSimpleMotorNew ( cpBody* a, cpBody* b, cpFloat rate )

! cpSpace.h
C-TYPE: cpSpace

CALLBACK: int cpCollisionBeginFunc ( cpArbiter* arb, cpSpace* space, void* data )
CALLBACK: int cpCollisionPreSolveFunc ( cpArbiter* arb, cpSpace* space, void* data )
CALLBACK: void cpCollisionPostSolveFunc ( cpArbiter* arb, cpSpace* space, void* data )
CALLBACK: void cpCollisionSeparateFunc ( cpArbiter* arb, cpSpace* space, void* data )

STRUCT: cpCollisionHandler
    { a         cpCollisionType          }
    { b         cpCollisionType          }
    { begin     cpCollisionBeginFunc     }
    { preSolve  cpCollisionPreSolveFunc  }
    { postSolve cpCollisionPostSolveFunc }
    { separate  cpCollisionSeparateFunc  }
    { data      void*                    } ;

STRUCT: cpSpace
    { iterations        int                }
    { elasticIterations int                }
    { gravity           cpVect             }
    { damping           cpFloat            }
    { stamp             int                }
    { staticShapes      cpSpaceHash*       }
    { activeShapes      cpSpaceHash*       }
    { bodies            cpArray*           }
    { arbiters          cpArray*           }
    { contactSet        cpHashSet*         }
    { constraints       cpArray*           }
    { collFuncSet       cpHashSet*         }
    { defaultHandler    cpCollisionHandler }
    { postStepCallbacks cpHashSet*         } ;

FUNCTION: cpSpace* cpSpaceAlloc ( )
FUNCTION: cpSpace* cpSpaceInit ( cpSpace* space )
FUNCTION: cpSpace* cpSpaceNew ( )
FUNCTION: void cpSpaceDestroy ( cpSpace* space )
FUNCTION: void cpSpaceFree ( cpSpace* space )
FUNCTION: void cpSpaceFreeChildren ( cpSpace* space )
FUNCTION: void cpSpaceSetDefaultCollisionHandler (
    cpSpace*                 space,
    cpCollisionBeginFunc     begin,
    cpCollisionPreSolveFunc  preSolve,
    cpCollisionPostSolveFunc postSolve,
    cpCollisionSeparateFunc  separate,
    void*                    data )
FUNCTION: void cpSpaceAddCollisionHandler (
    cpSpace*                 space,
    cpCollisionType          a,
    cpCollisionType          b,
    cpCollisionBeginFunc     begin,
    cpCollisionPreSolveFunc  preSolve,
    cpCollisionPostSolveFunc postSolve,
    cpCollisionSeparateFunc  separate,
    void*                    data )
FUNCTION: void cpSpaceRemoveCollisionHandler ( cpSpace* space, cpCollisionType a, cpCollisionType b )
FUNCTION: cpShape* cpSpaceAddShape ( cpSpace* space, cpShape* shape )
FUNCTION: cpShape* cpSpaceAddStaticShape ( cpSpace* space, cpShape* shape )
FUNCTION: cpBody* cpSpaceAddBody ( cpSpace* space, cpBody* body )
FUNCTION: cpConstraint* cpSpaceAddConstraint ( cpSpace* space, cpConstraint* constraint )
FUNCTION: void cpSpaceRemoveShape ( cpSpace* space, cpShape* shape )
FUNCTION: void cpSpaceRemoveStaticShape ( cpSpace* space, cpShape* shape )
FUNCTION: void cpSpaceRemoveBody ( cpSpace* space, cpBody* body )
FUNCTION: void cpSpaceRemoveConstraint ( cpSpace* space, cpConstraint* constraint )
CALLBACK: void cpPostStepFunc ( cpSpace* space, void* obj, void* data )
FUNCTION: void cpSpaceAddPostStepCallback ( cpSpace* space, cpPostStepFunc func, void* obj, void* data )
CALLBACK: void cpSpacePointQueryFunc ( cpShape* shape, void* data )
FUNCTION: void cpSpacePointQuery ( cpSpace* space, cpVect point, cpLayers layers, cpGroup group, cpSpacePointQueryFunc func, void* data )
FUNCTION: cpShape* cpSpacePointQueryFirst ( cpSpace* space, cpVect point, cpLayers layers, cpGroup group )
CALLBACK: void cpSpaceSegmentQueryFunc ( cpShape* shape, cpFloat t, cpVect n, void* data )
FUNCTION: int cpSpaceSegmentQuery ( cpSpace* space, cpVect start, cpVect end, cpLayers layers, cpGroup group, cpSpaceSegmentQueryFunc func, void* data )
FUNCTION: cpShape* cpSpaceSegmentQueryFirst ( cpSpace* space, cpVect start, cpVect end, cpLayers layers, cpGroup group, cpSegmentQueryInfo* out )
CALLBACK: void cpSpaceBBQueryFunc ( cpShape* shape, void* data )
FUNCTION: void cpSpaceBBQuery ( cpSpace* space, cpBB bb, cpLayers layers, cpGroup group, cpSpaceBBQueryFunc func, void* data )
CALLBACK: void cpSpaceBodyIterator ( cpBody* body, void* data )
FUNCTION: void cpSpaceEachBody ( cpSpace* space, cpSpaceBodyIterator func, void* data )
FUNCTION: void cpSpaceResizeStaticHash ( cpSpace* space, cpFloat dim, int count )
FUNCTION: void cpSpaceResizeActiveHash ( cpSpace* space, cpFloat dim, int count )
FUNCTION: void cpSpaceRehashStatic ( cpSpace* space )
FUNCTION: void cpSpaceStep ( cpSpace* space, cpFloat dt )

! chipmunk.h
FUNCTION: void cpInitChipmunk ( )
FUNCTION: cpFloat cpMomentForCircle ( cpFloat m, cpFloat r1, cpFloat r2, cpVect offset )
FUNCTION: cpFloat cpMomentForSegment ( cpFloat m, cpVect a, cpVect b )
FUNCTION: cpFloat cpMomentForPoly ( cpFloat m, int numVerts, cpVect* verts, cpVect offset )
