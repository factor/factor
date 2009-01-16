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
	if(NULL == szArglist)
	{
		puts("CommandLineToArgvW failed");
		return 1;
	}

	start_standalone_factor(nArgs,szArglist);

	LocalFree(szArglist);

	return 0;
}
