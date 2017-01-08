! Copyright (C) 2017 Benjamin Pollack.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax windows.types ;
IN: windows.shcore

LIBRARY: shcore

ENUM: MONITOR_DPI_TYPE
    MDT_EFFECTIVE_DPI
    MDT_ANGULAR_DPI
    MDT_RAW_DPI
    { MDT_DEFAULT 0 } ;

FUNCTION: HRESULT GetDpiForMonitor ( HMONITOR hMonitor, MONITOR_DPI_TYPE dpiType, UINT* dpiX, UINT *dpiY )
