#include "master.hpp"

namespace factor
{

HMODULE hFactorDll;

void factor_vm::init_ffi()
{
	hFactorDll = GetModuleHandle(FACTOR_DLL);
	if(!hFactorDll)
		fatal_error("GetModuleHandle(\"" FACTOR_DLL_NAME "\") failed", 0);
}

void factor_vm::ffi_dlopen(dll *dll)
{
	dll->dll = LoadLibraryEx((WCHAR *)alien_offset(dll->path), NULL, 0);
}

void *factor_vm::ffi_dlsym(dll *dll, symbol_char *symbol)
{
	return (void *)GetProcAddress(dll ? (HMODULE)dll->dll : hFactorDll, symbol);
}

void factor_vm::ffi_dlclose(dll *dll)
{
	FreeLibrary((HMODULE)dll->dll);
	dll->dll = NULL;
}

bool factor_vm::windows_stat(vm_char *path)
{
	BY_HANDLE_FILE_INFORMATION bhfi;
	HANDLE h = CreateFileW(path,
			GENERIC_READ,
			FILE_SHARE_READ,
			NULL,
			OPEN_EXISTING,
			FILE_FLAG_BACKUP_SEMANTICS,
			NULL);

	if(h == INVALID_HANDLE_VALUE)
	{
		// FindFirstFile is the only call that can stat c:\pagefile.sys
		WIN32_FIND_DATA st;
		HANDLE h;

		if(INVALID_HANDLE_VALUE == (h = FindFirstFile(path, &st)))
			return false;
		FindClose(h);
		return true;
	}
	bool ret;
	ret = GetFileInformationByHandle(h, &bhfi);
	CloseHandle(h);
	return ret;
}

void factor_vm::windows_image_path(vm_char *full_path, vm_char *temp_path, unsigned int length)
{
	snwprintf(temp_path, length-1, L"%s.image", full_path); 
	temp_path[length - 1] = 0;
}

/* You must free() this yourself. */
const vm_char *factor_vm::default_image_path()
{
	vm_char full_path[MAX_UNICODE_PATH];
	vm_char *ptr;
	vm_char temp_path[MAX_UNICODE_PATH];

	if(!GetModuleFileName(NULL, full_path, MAX_UNICODE_PATH))
		fatal_error("GetModuleFileName() failed", 0);

	if((ptr = wcsrchr(full_path, '.')))
		*ptr = 0;

	snwprintf(temp_path, MAX_UNICODE_PATH-1, L"%s.image", full_path); 
	temp_path[MAX_UNICODE_PATH - 1] = 0;

	return safe_strdup(temp_path);
}

/* You must free() this yourself. */
const vm_char *factor_vm::vm_executable_path()
{
	vm_char full_path[MAX_UNICODE_PATH];
	if(!GetModuleFileName(NULL, full_path, MAX_UNICODE_PATH))
		fatal_error("GetModuleFileName() failed", 0);
	return safe_strdup(full_path);
}

void factor_vm::primitive_existsp()
{
	vm_char *path = untag_check<byte_array>(dpop())->data<vm_char>();
	box_boolean(windows_stat(path));
}

segment::segment(factor_vm *myvm_, cell size_)
{
	myvm = myvm_;
	size = size_;

	char *mem;
	DWORD ignore;

	if((mem = (char *)VirtualAlloc(NULL, getpagesize() * 2 + size,
		MEM_COMMIT, PAGE_EXECUTE_READWRITE)) == 0)
		myvm->out_of_memory();

	if (!VirtualProtect(mem, getpagesize(), PAGE_NOACCESS, &ignore))
		fatal_error("Cannot allocate low guard page", (cell)mem);

	if (!VirtualProtect(mem + size + getpagesize(),
		getpagesize(), PAGE_NOACCESS, &ignore))
		fatal_error("Cannot allocate high guard page", (cell)mem);

	start = (cell)mem + getpagesize();
	end = start + size;
}

segment::~segment()
{
	SYSTEM_INFO si;
	GetSystemInfo(&si);
	if(!VirtualFree((void*)(start - si.dwPageSize), 0, MEM_RELEASE))
		fatal_error("Segment deallocation failed",0);
}

void factor_vm::sleep_micros(u64 usec)
{
	Sleep((DWORD)(usec / 1000));
}

long getpagesize()
{
	static long g_pagesize = 0;
	if (! g_pagesize)
	{
		SYSTEM_INFO system_info;
		GetSystemInfo (&system_info);
		g_pagesize = system_info.dwPageSize;
	}
	return g_pagesize;
}

}
