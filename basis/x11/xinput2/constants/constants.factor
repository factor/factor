! Copyright (C) 2010 Niklas Waern.
! See https://factorcode.org/license.txt for BSD license.
USING: math ;
IN: x11.xinput2.constants

! From XI2.h

CONSTANT: XInput_2_0               7

CONSTANT: XI_2_Major               2
CONSTANT: XI_2_Minor               0

! Property event flags
CONSTANT: XIPropertyDeleted        0
CONSTANT: XIPropertyCreated        1
CONSTANT: XIPropertyModified       2

! Enter/Leave and Focus In/Out modes
CONSTANT: XINotifyNormal           0
CONSTANT: XINotifyGrab             1
CONSTANT: XINotifyUngrab           2
CONSTANT: XINotifyWhileGrabbed     3
CONSTANT: XINotifyPassiveGrab      4
CONSTANT: XINotifyPassiveUngrab    5

! Enter/Leave and Focus In/Out detail
CONSTANT: XINotifyAncestor         0
CONSTANT: XINotifyVirtual          1
CONSTANT: XINotifyInferior         2
CONSTANT: XINotifyNonlinear        3
CONSTANT: XINotifyNonlinearVirtual 4
CONSTANT: XINotifyPointer          5
CONSTANT: XINotifyPointerRoot      6
CONSTANT: XINotifyDetailNone       7

! Passive grab types
CONSTANT: XIGrabtypeButton         0
CONSTANT: XIGrabtypeKeycode        1
CONSTANT: XIGrabtypeEnter          2
CONSTANT: XIGrabtypeFocusIn        3

! Passive grab modifier
: XIAnyModifier ( -- n )           31 2^ ; inline
: XIAnyButton   ( -- n )           0     ; inline
: XIAnyKeycode  ( -- n )           0     ; inline

! XIAllowEvents event-modes
CONSTANT: XIAsyncDevice            0
CONSTANT: XISyncDevice             1
CONSTANT: XIReplayDevice           2
CONSTANT: XIAsyncPairedDevice      3
CONSTANT: XIAsyncPair              4
CONSTANT: XISyncPair               5

! DeviceChangedEvent change reasons
CONSTANT: XISlaveSwitch            1
CONSTANT: XIDeviceChange           2

! Hierarchy flags
: XIMasterAdded    ( -- n )        0 2^ ; inline
: XIMasterRemoved  ( -- n )        1 2^ ; inline
: XISlaveAdded     ( -- n )        2 2^ ; inline
: XISlaveRemoved   ( -- n )        3 2^ ; inline
: XISlaveAttached  ( -- n )        4 2^ ; inline
: XISlaveDetached  ( -- n )        5 2^ ; inline
: XIDeviceEnabled  ( -- n )        6 2^ ; inline
: XIDeviceDisabled ( -- n )        7 2^ ; inline

! ChangeHierarchy constants
CONSTANT: XIAddMaster              1
CONSTANT: XIRemoveMaster           2
CONSTANT: XIAttachSlave            3
CONSTANT: XIDetachSlave            4

CONSTANT: XIAttachToMaster         1
CONSTANT: XIFloating               2

! Valuator modes
CONSTANT: XIModeRelative           0
CONSTANT: XIModeAbsolute           1

! Device types
CONSTANT: XIMasterPointer          1
CONSTANT: XIMasterKeyboard         2
CONSTANT: XISlavePointer           3
CONSTANT: XISlaveKeyboard          4
CONSTANT: XIFloatingSlave          5

! Device classes
CONSTANT: XIKeyClass               0
CONSTANT: XIButtonClass            1
CONSTANT: XIValuatorClass          2

! Device event flags (common)
! Device event flags (key events only)
: XIKeyRepeat ( -- n )             16 2^ ; inline
! Device event flags (pointer events only)

! Fake device ID's for event selection
CONSTANT: XIAllDevices             0
CONSTANT: XIAllMasterDevices       1

! Event types
CONSTANT: XI_DeviceChanged         1
CONSTANT: XI_KeyPress              2
CONSTANT: XI_KeyRelease            3
CONSTANT: XI_ButtonPress           4
CONSTANT: XI_ButtonRelease         5
CONSTANT: XI_Motion                6
CONSTANT: XI_Enter                 7
CONSTANT: XI_Leave                 8
CONSTANT: XI_FocusIn               9
CONSTANT: XI_FocusOut              10
CONSTANT: XI_HierarchyChanged      11
CONSTANT: XI_PropertyEvent         12
CONSTANT: XI_RawKeyPress           13
CONSTANT: XI_RawKeyRelease         14
CONSTANT: XI_RawButtonPress        15
CONSTANT: XI_RawButtonRelease      16
CONSTANT: XI_RawMotion             17
: XI_LASTEVENT ( -- n )            XI_RawMotion ; inline

! Event masks
: XI_DeviceChangedMask    ( -- n ) XI_DeviceChanged    2^ ; inline
: XI_KeyPressMask         ( -- n ) XI_KeyPress         2^ ; inline
: XI_KeyReleaseMask       ( -- n ) XI_KeyRelease       2^ ; inline
: XI_ButtonPressMask      ( -- n ) XI_ButtonPress      2^ ; inline
: XI_ButtonReleaseMask    ( -- n ) XI_ButtonRelease    2^ ; inline
: XI_MotionMask           ( -- n ) XI_Motion           2^ ; inline
: XI_EnterMask            ( -- n ) XI_Enter            2^ ; inline
: XI_LeaveMask            ( -- n ) XI_Leave            2^ ; inline
: XI_FocusInMask          ( -- n ) XI_FocusIn          2^ ; inline
: XI_FocusOutMask         ( -- n ) XI_FocusOut         2^ ; inline
: XI_HierarchyChangedMask ( -- n ) XI_HierarchyChanged 2^ ; inline
: XI_PropertyEventMask    ( -- n ) XI_PropertyEvent    2^ ; inline
: XI_RawKeyPressMask      ( -- n ) XI_RawKeyPress      2^ ; inline
: XI_RawKeyReleaseMask    ( -- n ) XI_RawKeyRelease    2^ ; inline
: XI_RawButtonPressMask   ( -- n ) XI_RawButtonPress   2^ ; inline
: XI_RawButtonReleaseMask ( -- n ) XI_RawButtonRelease 2^ ; inline
: XI_RawMotionMask        ( -- n ) XI_RawMotion        2^ ; inline
