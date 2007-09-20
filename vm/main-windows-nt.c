#include <windows.h>
#include <stdio.h>
#include <shellapi.h>
#include "master.h"

int WINAPI WinMain(
	HINSTANCE hInstance,
	HINSTANCE hPrevInstance,
	LPSTR lpCmdLine,
	int nCmdShow)
{
	LPWSTR *szArglist;
	int nArgs;

	szArglist = CommandLineToArgvW(GetCommandLineW(), &nArgs);
	if( NULL == szArglist )
	{
		wprintf(L"CommandLineToArgvW failed\n");
		return 1;
	}

	init_factor_from_args(NULL,nArgs,szArglist,false);

	LocalFree(szArglist);

	return 0;
}
