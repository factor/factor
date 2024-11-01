USING: alien alien.c-types alien.destructors alien.libraries
alien.libraries.finder alien.syntax classes.struct ;
IN: python.ffi

<< "python"
{ "python3.13" "python3.12" "python3.11" "python3.10" "python3.9" "python3.8" "python3.7" } find-library-from-list
cdecl add-library >>

! Functions that return borrowed references needs to be called like this:
! Py_Func dup Py_IncRef &Py_DecRef

LIBRARY: python

C-TYPE: PyObject

! Methods
CONSTANT: METH_OLDARGS   0x0000
CONSTANT: METH_VARARGS   0x0001
CONSTANT: METH_KEYWORDS  0x0002
CONSTANT: METH_NOARGS    0x0004
CONSTANT: METH_O         0x0008
CONSTANT: METH_CLASS     0x0010
CONSTANT: METH_STATIC    0x0020
CONSTANT: METH_COEXIST   0x0040
CONSTANT: METH_FASTCALL  0x0080
CONSTANT: METH_STACKLESS 0x0100
CONSTANT: METH_METHOD    0x0200

C-TYPE: PyCFunction

TYPEDEF: long Py_ssize_t

STRUCT: PyMethodDef
    { ml_name c-string }
    { ml_meth PyCFunction* }
    { ml_flags int }
    { ml_doc c-string } ;

CALLBACK: PyObject* PyCallback ( PyObject* self, PyObject* args, PyObject* kw )

! Functions
FUNCTION: PyObject* PyCFunction_NewEx ( PyMethodDef* ml, PyObject* self, PyObject* module )
FUNCTION: int PyCFunction_GetFlags ( PyObject* op )

! Top-level
FUNCTION: c-string Py_GetVersion ( )
FUNCTION: void Py_Initialize ( )
FUNCTION: bool Py_IsInitialized ( )
FUNCTION: void Py_Finalize ( )
FUNCTION: void PySys_SetArgvEx ( int argc, c-string* argv, int updatepath )

! Misc
FUNCTION: int PyRun_SimpleString ( c-string command )

! Importing
FUNCTION: PyObject* PyImport_AddModule ( c-string name )
FUNCTION: long PyImport_GetMagicNumber ( )
FUNCTION: PyObject* PyImport_ImportModule ( c-string name )

! Sys module
FUNCTION: PyObject* PySys_GetObject ( c-string name )

! Dicts
FUNCTION: PyObject* PyDict_New ( )
FUNCTION: PyObject* PyDict_GetItem ( PyObject* d, PyObject* key )
FUNCTION: PyObject* PyDict_GetItemString ( PyObject* d, c-string key )
FUNCTION: PyObject* PyDict_GetItemWithError ( PyObject* d, PyObject* key )
FUNCTION: int PyDict_SetItem ( PyObject* d, PyObject* key, PyObject* value )
FUNCTION: int PyDict_SetItemString ( PyObject* d, c-string key, PyObject* val )
FUNCTION: int PyDict_DelItem ( PyObject* d, PyObject* key )
FUNCTION: int PyDict_DelItemString ( PyObject* d, c-string key )
FUNCTION: void PyDict_Clear ( PyObject* d )
FUNCTION: PyObject* PyDict_Keys ( PyObject* d )
FUNCTION: PyObject* PyDict_Values ( PyObject* d )
FUNCTION: PyObject* PyDict_Items ( PyObject* d )
FUNCTION: int PyDict_Size ( PyObject* d )
FUNCTION: int PyDict_Contains ( PyObject* d, PyObject* key )

! Tuples
FUNCTION: PyObject* PyTuple_New ( int len )
FUNCTION: int PyTuple_Size ( PyObject* t )
FUNCTION: PyObject* PyTuple_GetItem ( PyObject* t, Py_ssize_t pos )
FUNCTION: int PyTuple_SetItem ( PyObject* t, Py_ssize_t pos, PyObject* o )
FUNCTION: PyObject* PyTuple_GetSlice ( PyObject* t, Py_ssize_t i1, Py_ssize_t i2 )

! Lists
FUNCTION: PyObject* PyList_New ( int len )
FUNCTION: int PyList_Size ( PyObject* l )
FUNCTION: PyObject* PyList_GetItem ( PyObject* l, Py_ssize_t pos )
FUNCTION: int PyList_SetItem ( PyObject* l, Py_ssize_t pos, PyObject* o )
FUNCTION: int PyList_Insert ( PyObject* l, Py_ssize_t pos, PyObject* o )
FUNCTION: int PyList_Append ( PyObject* l, PyObject* o )
FUNCTION: PyObject* PyList_GetSlice ( PyObject* l, Py_ssize_t i1, Py_ssize_t i2 )
FUNCTION: PyObject* PyList_SetSlice ( PyObject* l, Py_ssize_t i1, Py_ssize_t i2, PyObject* v )
FUNCTION: int PyList_Sort ( PyObject* l )
FUNCTION: int PyList_Reverse ( PyObject* l )

! Sequences
FUNCTION: int PySequence_Check ( PyObject* o )
FUNCTION: Py_ssize_t PySequence_Size ( PyObject* o )
FUNCTION: PyObject* PySequence_Concat ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PySequence_Repeat ( PyObject* o, Py_ssize_t count )
FUNCTION: PyObject* PySequence_GetItem ( PyObject* o, Py_ssize_t i )
FUNCTION: PyObject* PySequence_GetSlice ( PyObject* o, Py_ssize_t i1, Py_ssize_t i2 )
FUNCTION: PyObject* PySequence_SetItem ( PyObject* o, Py_ssize_t i, PyObject* v )
FUNCTION: PyObject* PySequence_DelItem ( PyObject* o, Py_ssize_t i )
FUNCTION: PyObject* PySequence_SetSlice ( PyObject* o, Py_ssize_t i1, Py_ssize_t i2, PyObject* v )
FUNCTION: PyObject* PySequence_DelSlice ( PyObject* o, Py_ssize_t i1, Py_ssize_t i2 )
FUNCTION: PyObject* PySequence_Tuple ( PyObject* o )
FUNCTION: PyObject* PySequence_List ( PyObject* o )
FUNCTION: Py_ssize_t PySequence_Count ( PyObject* o )
FUNCTION: int PySequence_Contains ( PyObject* o, PyObject* v )
FUNCTION: Py_ssize_t PySequence_Index ( PyObject* o, PyObject* v )
FUNCTION: PyObject* PySequence_InPlaceConcat ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PySequence_InPlaceRepeat ( PyObject* o, Py_ssize_t count )

! Mapping
FUNCTION: int PyMapping_Check ( PyObject* o )
FUNCTION: Py_ssize_t PyMapping_Size ( PyObject* o )
FUNCTION: int PyMapping_HasKey ( PyObject* o, PyObject* key )
FUNCTION: PyObject* PyMapping_Keys ( PyObject* o )
FUNCTION: PyObject* PyMapping_Values ( PyObject* o )
FUNCTION: PyObject* PyMapping_Items ( PyObject* o )
FUNCTION: PyObject* PyMapping_GetItemString ( PyObject* o, c-string key )
FUNCTION: int PyMapping_SetItemString ( PyObject* o, c-string key, PyObject* value )

! Modules
FUNCTION: c-string PyModule_GetName ( PyObject* module )
FUNCTION: PyObject* PyModule_GetDict ( PyObject* module )

! Callables
FUNCTION: int PyCallable_Check ( PyObject* obj )

! Objects
FUNCTION: PyObject* PyObject_CallNoArgs ( PyObject* callable )
FUNCTION: PyObject* PyObject_Call ( PyObject* callable, PyObject* args, PyObject* kw )
FUNCTION: PyObject* PyObject_CallObject ( PyObject* callable, PyObject* args )
FUNCTION: int PyObject_HasAttr ( PyObject* o, c-string attr_name )
FUNCTION: PyObject* PyObject_GetAttr ( PyObject* o, c-string attr_name )
FUNCTION: PyObject* PyObject_GetAttrString ( PyObject* o, c-string attr_name )
FUNCTION: int PyObject_SetAttr ( PyObject* o, c-string attr_name, PyObject *v )
FUNCTION: int PyObject_SetAttrString ( PyObject* o, c-string attr_name, PyObject *v )
FUNCTION: int PyObject_DelAttr ( PyObject* o, c-string attr_name )
FUNCTION: int PyObject_DelAttrString ( PyObject* o, c-string attr_name )
FUNCTION: PyObject* PyObject_Repr ( PyObject* o )
FUNCTION: PyObject* PyObject_Str ( PyObject* o )
FUNCTION: PyObject* PyObject_Type ( PyObject* o )
FUNCTION: PyObject* PyObject_GetItem ( PyObject* o, PyObject* key )
FUNCTION: int PyObject_SetItem ( PyObject* o, PyObject* key, PyObject* v )
FUNCTION: int PyObject_DelItem ( PyObject* o, PyObject* key )
FUNCTION: PyObject* PyObject_Iter ( PyObject* o )
FUNCTION: int PyObject_IsTrue ( PyObject* o )
FUNCTION: int PyObject_IsInstance ( PyObject* o, PyObject* typeorclass )
FUNCTION: int PyObject_IsSubclass ( PyObject* o, PyObject* typeorclass )

! Iter
FUNCTION: int PyIter_Check ( PyObject* o )
FUNCTION: PyObject* PyIter_Next ( PyObject* o )

! Number
FUNCTION: int PyNumber_Check ( PyObject* o )
FUNCTION: PyObject* PyNumber_Add ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PyNumber_Subtract ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PyNumber_Multiply ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PyNumber_FloorDivide ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PyNumber_TrueDivide ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PyNumber_Remainder ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PyNumber_Divmod ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PyNumber_Power ( PyObject* o1, PyObject* o2, PyObject* o3 )
FUNCTION: PyObject* PyNumber_Negative ( PyObject* o )
FUNCTION: PyObject* PyNumber_Positive ( PyObject* o )
FUNCTION: PyObject* PyNumber_Absolute ( PyObject* o )
FUNCTION: PyObject* PyNumber_Invert ( PyObject* o )
FUNCTION: PyObject* PyNumber_Lshift ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PyNumber_Rshift ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PyNumber_And ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PyNumber_Xor ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PyNumber_Or ( PyObject* o1, PyObject* o2 )
FUNCTION: int PyIndex_Check ( PyObject* o )
FUNCTION: PyObject* PyNumber_Index ( PyObject* o )
FUNCTION: PyObject* PyNumber_Long ( PyObject* o )
FUNCTION: PyObject* PyNumber_Float ( PyObject* o )
FUNCTION: PyObject* PyNumber_InPlaceAdd ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PyNumber_InPlaceSubtract ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PyNumber_InPlaceMultiply ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PyNumber_InPlaceFloorDivide ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PyNumber_InPlaceTrueDivide ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PyNumber_InPlaceRemainder ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PyNumber_InPlaceDivmod ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PyNumber_InPlacePower ( PyObject* o1, PyObject* o2, PyObject* o3 )
FUNCTION: PyObject* PyNumber_InPlaceLshift ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PyNumber_InPlaceRshift ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PyNumber_InPlaceAnd ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PyNumber_InPlaceXor ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PyNumber_InPlaceOr ( PyObject* o1, PyObject* o2 )
FUNCTION: PyObject* PyNumber_ToBase ( PyObject* o1, int base )

! Bytes
FUNCTION: c-string PyBytes_AsString ( PyObject* string )
FUNCTION: PyObject* PyBytes_FromStringAndSize ( c-string v, Py_ssize_t size )

! Strings
FUNCTION: c-string PyUnicode_AsUTF8 ( PyObject* unicode )
FUNCTION: PyObject* PyUnicode_FromStringAndSize ( c-string v, Py_ssize_t size )
FUNCTION: PyObject* PyUnicode_FromString ( c-string v )

! Ints
FUNCTION: long PyLong_AsLong ( PyObject* io )
FUNCTION: PyObject* PyLong_FromLong ( long v )
FUNCTION: PyObject* PyLong_FromString ( c-string str, char** pend, int base )

! Floats
FUNCTION: PyObject* PyFloat_FromDouble ( double d )

! Types
FUNCTION: int PyType_Check ( PyObject* obj )

! Reference counting
FUNCTION: void Py_IncRef ( PyObject* o )
FUNCTION: void Py_DecRef ( PyObject* o )
DESTRUCTOR: Py_DecRef

! Reflection
FUNCTION: c-string PyEval_GetFuncName ( PyObject* func )

! Errors
FUNCTION: void PyErr_Clear ( )
FUNCTION: void PyErr_Print ( )
FUNCTION: void PyErr_Fetch ( PyObject** ptype, PyObject** pvalue, PyObject** *ptraceback )
