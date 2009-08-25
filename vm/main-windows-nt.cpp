#include "master.hpp"

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

  #ifdef FACTOR_MULTITHREADED
	factor::THREADHANDLE thread = factor::start_standalone_factor_in_new_thread(nArgs,szArglist);
	WaitForSingleObject(thread, INFINITE);
  #else
	factor::start_standalone_factor(nArgs,szArglist);
  #endif

	LocalFree(szArglist);

	return 0;
}
