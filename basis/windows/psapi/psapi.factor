! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.syntax windows.types ;
IN: windows.psapi

LIBRARY: psapi

FUNCTION: BOOL EnumDeviceDrivers ( LPVOID* lpImageBase, DWORD cb, LPDWORD lpcbNeeded )

FUNCTION: DWORD GetDeviceDriverBaseNameW ( LPVOID ImageBase, LPTSTR lpBaseName, DWORD nSize )

ALIAS: GetDeviceDriverBaseName GetDeviceDriverBaseNameW

FUNCTION: DWORD GetModuleFileNameExW ( HANDLE hProcess,
  HMODULE hModule,
  LPWSTR  lpFilename,
  DWORD   nSize
)

FUNCTION: DWORD GetProcessImageFileNameA (
  HANDLE hProcess,
  LPSTR  lpImageFileName,
  DWORD  nSize
)
