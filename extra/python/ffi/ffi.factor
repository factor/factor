USING:
    alien
    alien.c-types
    alien.destructors
    alien.libraries alien.libraries.finder
    alien.syntax
    assocs
    kernel
    sequences
    system ;
IN: python.ffi

<< "python" {
    { unix { "3.0" "2.6" "2.7" } } { windows { "26" "27" "30" } }
} os of [
    "python" prepend find-library
] map-find drop cdecl add-library >>

LIBRARY: python

C-TYPE: PyObject

! Top-level
FUNCTION: c-string Py_GetVersion ( ) ;
FUNCTION: void Py_Initialize ( ) ;
FUNCTION: bool Py_IsInitialized ( ) ;
FUNCTION: void Py_Finalize ( ) ;

! Misc
FUNCTION: int PyRun_SimpleString ( c-string command ) ;

! Importing
FUNCTION: PyObject* PyImport_AddModule ( c-string name ) ;
FUNCTION: long PyImport_GetMagicNumber ( ) ;
FUNCTION: PyObject* PyImport_ImportModule ( c-string name ) ;

! Dicts
FUNCTION: PyObject* PyDict_GetItemString ( PyObject* d, c-string key ) ;
FUNCTION: PyObject* PyDict_New ( ) ;
FUNCTION: int PyDict_Size ( PyObject* d ) ;
FUNCTION: int PyDict_SetItemString ( PyObject* d,
                                     c-string key,
                                     PyObject* val ) ;
FUNCTION: int PyDict_SetItem ( PyObject* d, PyObject* k, PyObject* o ) ;
FUNCTION: PyObject* PyDict_Items ( PyObject *d ) ;

! Tuples
FUNCTION: PyObject* PyTuple_GetItem ( PyObject* t, int pos ) ;
FUNCTION: PyObject* PyTuple_New ( int len ) ;
FUNCTION: int PyTuple_SetItem ( PyObject* t, int pos, PyObject* o ) ;
FUNCTION: int PyTuple_Size ( PyObject* t ) ;

! Lists (sequences)
FUNCTION: PyObject* PyList_GetItem ( PyObject* l, int pos ) ;
FUNCTION: int PyList_Size ( PyObject* t ) ;


! Modules
FUNCTION: c-string PyModule_GetName ( PyObject* module ) ;
FUNCTION: PyObject* PyModule_GetDict ( PyObject* module ) ;

! Objects
FUNCTION: PyObject* PyObject_CallObject ( PyObject* callable,
                                          PyObject* args ) ;
FUNCTION: PyObject* PyObject_Call ( PyObject* callable,
                                    PyObject* args,
                                    PyObject* kw ) ;
FUNCTION: PyObject* PyObject_GetAttrString ( PyObject* callable,
                                             c-string attr_name ) ;
FUNCTION: PyObject* PyObject_Str ( PyObject* o ) ;

! Strings
FUNCTION: void* PyString_AsString ( PyObject* string ) ;
FUNCTION: PyObject* PyString_FromString ( c-string v ) ;

! Unicode
FUNCTION: PyObject* PyUnicode_DecodeUTF8 ( c-string s,
                                           int size,
                                           void* errors ) ;
FUNCTION: PyObject* PyUnicodeUCS4_FromString ( c-string s ) ;
FUNCTION: PyObject* PyUnicodeUCS2_FromString ( c-string s ) ;
FUNCTION: PyObject* PyUnicodeUCS2_AsUTF8String ( PyObject* unicode ) ;
FUNCTION: PyObject* PyUnicodeUCS4_AsUTF8String ( PyObject* unicode ) ;

! Ints
FUNCTION: long PyInt_AsLong ( PyObject* io ) ;

! Longs
FUNCTION: PyObject* PyLong_FromLong ( long v ) ;
FUNCTION: long PyLong_AsLong ( PyObject* o ) ;

! Floats
FUNCTION: PyObject* PyFloat_FromDouble ( double d ) ;

! Reference counting
FUNCTION: void Py_IncRef ( PyObject* o ) ;
FUNCTION: void Py_DecRef ( PyObject* o ) ;
DESTRUCTOR: Py_DecRef

! Reflection
FUNCTION: c-string PyEval_GetFuncName ( PyObject* func ) ;

! Errors
FUNCTION: void PyErr_Print ( ) ;
FUNCTION: void PyErr_Fetch ( PyObject** ptype,
                             PyObject** pvalue,
                             PyObject** *ptraceback ) ;
