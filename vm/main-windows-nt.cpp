#include "master.hpp"

VM_C_API int wmain(int argc, wchar_t **argv)
{
	factor::init_globals();
#ifdef FACTOR_MULTITHREADED
	factor::THREADHANDLE thread = factor::start_standalone_factor_in_new_thread(argv,argc);
	WaitForSingleObject(thread, INFINITE);
#else
	factor::start_standalone_factor(argc,argv);
#endif
	return 0;
}

int WINAPI WinMain(
	HINSTANCE hInstance,
	HINSTANCE hPrevInstance,
	LPSTR lpCmdLine,
	int nCmdShow)
{
	int argc;
	wchar_t **argv;

	argv = CommandLineToArgvW(GetCommandLine(),&argc);
	wmain(argc,argv);

	// memory leak from malloc, wcsdup
	return 0;
}
