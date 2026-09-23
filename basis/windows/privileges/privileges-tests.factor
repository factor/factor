USING: accessors alien.c-types alien.data classes.struct kernel sequences
tools.test windows.advapi32 windows.kernel32 windows.privileges windows.types ;
IN: windows.privileges.tests

! Privileges is embedded storage, not a pointer to a separately allocated LUID.
{ 1 2 t } [
    "SeChangeNotifyPrivilege" t make-token-privileges
    [ PrivilegeCount>> ]
    [ Privileges>> first Attributes>> ]
    [ Privileges>> first Luid>>
      "SeChangeNotifyPrivilege" lookup-privilege = ] tri
] unit-test
