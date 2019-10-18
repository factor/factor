#include "master.hpp"

namespace factor
{

HMODULE hFactorDll;

void factor_vm::init_ffi()
{
	hFactorDll = GetModuleHandle(FACTOR_DLL);
	if(!hFactorDll)
		fatal_error("GetModuleHandle() failed", 0);
}

void factor_vm::ffi_dlopen(dll *dll)
{
	dll->handle = LoadLibraryEx((WCHAR *)alien_offset(dll->path), NULL, 0);
}

void *factor_vm::ffi_dlsym(dll *dll, symbol_char *symbol)
{
	return (void *)GetProcAddress(dll ? (HMODULE)dll->handle : hFactorDll, symbol);
}

void factor_vm::ffi_dlclose(dll *dll)
{
	FreeLibrary((HMODULE)dll->handle);
	dll->handle = NULL;
}

BOOL factor_vm::windows_stat(vm_char *path)
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
	BOOL ret = GetFileInformationByHandle(h, &bhfi);
	CloseHandle(h);
	return ret;
}

void factor_vm::windows_image_path(vm_char *full_path, vm_char *temp_path, unsigned int length)
{
	wcsncpy(temp_path, full_path, length - 1);
	size_t full_path_len = wcslen(full_path);
	if (full_path_len < length - 1)
		wcsncat(temp_path, L".image", length - full_path_len - 1);
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

	wcsncpy(temp_path, full_path, MAX_UNICODE_PATH - 1);
	size_t full_path_len = wcslen(full_path);
	if (full_path_len < MAX_UNICODE_PATH - 1)
		wcsncat(temp_path, L".image", MAX_UNICODE_PATH - full_path_len - 1);
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
	vm_char *path = untag_check<byte_array>(ctx->pop())->data<vm_char>();
	ctx->push(tag_boolean(windows_stat(path)));
}

segment::segment(cell size_, bool executable_p)
{
	size = size_;

	char *mem;
	DWORD ignore;

	if((mem = (char *)VirtualAlloc(NULL, getpagesize() * 2 + size,
		MEM_COMMIT, executable_p ? PAGE_EXECUTE_READWRITE : PAGE_READWRITE)) == 0)
		out_of_memory();

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

long getpagesize()
{
	static long g_pagesize = 0;
	if(!g_pagesize)
	{
		SYSTEM_INFO system_info;
		GetSystemInfo (&system_info);
		g_pagesize = system_info.dwPageSize;
	}
	return g_pagesize;
}

void factor_vm::move_file(const vm_char *path1, const vm_char *path2)
{
	if(MoveFileEx((path1),(path2),MOVEFILE_REPLACE_EXISTING) == false)
		general_error(ERROR_IO,tag_fixnum(GetLastError()),false_object);
}

void factor_vm::init_signals() {}

}
