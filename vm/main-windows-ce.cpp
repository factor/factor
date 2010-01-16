#include "master.hpp"

int WINAPI WinMain(
	HINSTANCE hInstance,
	HINSTANCE hPrevInstance,
	LPWSTR lpCmdLine,
	int nCmdShow)
{
	int __argc;
	wchar_t **__argv;
	factor::parse_args(&__argc, &__argv, lpCmdLine);
	factor::init_globals();
	factor::start_standalone_factor(__argc,(LPWSTR*)__argv);

	// memory leak from malloc, wcsdup
	return 0;
}
