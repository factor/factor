USING: alien alien.c-types alien.destructors alien.libraries
alien.libraries.finder alien.syntax assocs classes.struct kernel sequences
system ;
IN: python.ffi

! << "python" { "3.0" "3" "2.7" "2.6" } ! Python 3 has a different api, enable someday
<< "python"
{ "python2.7" "python2.6" "python27" "python26" } find-library-from-list
cdecl add-library >>

! Functions that return borrowed references needs to be called like this:
! Py_Func dup Py_IncRef &Py_DecRef

LIBRARY: python

C-TYPE: PyObject

! Methods
CONSTANT: METH_OLDARGS  0x0000
CONSTANT: METH_VARARGS  0x0001
CONSTANT: METH_KEYWORDS 0x0002
CONSTANT: METH_NOARGS   0x0004
CONSTANT: METH_O        0x0008
CONSTANT: METH_CLASS    0x0010
CONSTANT: METH_STATIC   0x0020
CONSTANT: METH_COEXIST  0x0040

C-TYPE: PyCFunction

STRUCT: PyMethodDef
    { ml_name c-string }
    { ml_meth PyCFunction* }
    { ml_flags int }
    { ml_doc c-string } ;

FUNCTION: PyObject* PyCFunction_NewEx ( PyMethodDef* ml,
                                        PyObject* self,
                                        PyObject* module )
FUNCTION: int PyCFunction_GetFlags ( PyObject* op )

CALLBACK: PyObject* PyCallback ( PyObject* self,
                                 PyObject* args,
                                 PyObject* kw )

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
! Borrowed reference
FUNCTION: PyObject* PySys_GetObject ( c-string name )

! Dicts
! Borrowed reference
FUNCTION: PyObject* PyDict_GetItemString ( PyObject* d, c-string key )
FUNCTION: PyObject* PyDict_New ( )
FUNCTION: int PyDict_Size ( PyObject* d )
FUNCTION: int PyDict_SetItemString ( PyObject* d,
                                     c-string key,
                                     PyObject* val )
FUNCTION: int PyDict_SetItem ( PyObject* d, PyObject* k, PyObject* o )
FUNCTION: PyObject* PyDict_Items ( PyObject *d )

! Tuples
! Borrowed reference
FUNCTION: PyObject* PyTuple_GetItem ( PyObject* t, int pos )
FUNCTION: PyObject* PyTuple_New ( int len )
! Steals the reference
FUNCTION: int PyTuple_SetItem ( PyObject* t, int pos, PyObject* o )
FUNCTION: int PyTuple_Size ( PyObject* t )

! Lists
! Borrowed reference
FUNCTION: PyObject* PyList_GetItem ( PyObject* l, int pos )
! New reference
FUNCTION: PyObject* PyList_New ( int len )
FUNCTION: int PyList_Size ( PyObject* l )
! Steals the reference
FUNCTION: int PyList_SetItem ( PyObject* l, int pos, PyObject* o )

! Sequences
FUNCTION: int PySequence_Check ( PyObject* o )

! Modules
FUNCTION: c-string PyModule_GetName ( PyObject* module )
FUNCTION: PyObject* PyModule_GetDict ( PyObject* module )

! Callables
FUNCTION: int PyCallable_Check ( PyObject* obj )

! Objects
FUNCTION: PyObject* PyObject_CallObject ( PyObject* callable,
                                          PyObject* args )
FUNCTION: PyObject* PyObject_Call ( PyObject* callable,
                                    PyObject* args,
                                    PyObject* kw )
! New reference
FUNCTION: PyObject* PyObject_GetAttrString ( PyObject* o,
                                             c-string attr_name )
FUNCTION: int PyObject_SetAttrString ( PyObject* o,
                                       c-string attr_name,
                                       PyObject *v )

FUNCTION: PyObject* PyObject_Str ( PyObject* o )
FUNCTION: int PyObject_IsTrue ( PyObject* o )

! Strings
FUNCTION: c-string PyString_AsString ( PyObject* string )
FUNCTION: PyObject* PyString_FromString ( c-string v )

! Unicode
FUNCTION: PyObject* PyUnicode_DecodeUTF8 ( c-string s,
                                           int size,
                                           void* errors )
FUNCTION: PyObject* PyUnicodeUCS4_FromString ( c-string s )
FUNCTION: PyObject* PyUnicodeUCS2_FromString ( c-string s )
FUNCTION: PyObject* PyUnicodeUCS2_AsUTF8String ( PyObject* unicode )
FUNCTION: PyObject* PyUnicodeUCS4_AsUTF8String ( PyObject* unicode )

! Ints
FUNCTION: long PyInt_AsLong ( PyObject* io )

! Longs
FUNCTION: PyObject* PyLong_FromLong ( long v )
FUNCTION: long PyLong_AsLong ( PyObject* o )

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
FUNCTION: void PyErr_Fetch ( PyObject** ptype,
                             PyObject** pvalue,
                             PyObject** *ptraceback )
