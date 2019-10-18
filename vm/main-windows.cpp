#include "master.hpp"

VM_C_API int wmain(int argc, wchar_t **argv)
{
	factor::init_globals();
	factor::start_standalone_factor(argc,argv);
	return 0;
}

int WINAPI WinMain(
	HINSTANCE hInstance,
	HINSTANCE hPrevInstance,
	LPSTR lpCmdLine,
	int nCmdShow)
{
	int argc;
	wchar_t **argv = CommandLineToArgvW(GetCommandLine(),&argc);
	wmain(argc,argv);

	return 0;
}
