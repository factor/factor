#include "master.h"

F_STRING *get_error_message(void)
{
	DWORD id = GetLastError();
	F_CHAR *msg = error_message(id);
	F_STRING *string = from_u16_string(msg);
	LocalFree(msg);
	return string;
}

/* You must LocalFree() the return value! */
F_CHAR *error_message(DWORD id)
{
	F_CHAR *buffer;
	int index;

	DWORD ret = FormatMessage(
		FORMAT_MESSAGE_ALLOCATE_BUFFER |
		FORMAT_MESSAGE_FROM_SYSTEM,
		NULL,
		id,
		MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
		(LPTSTR)(void *) &buffer,
		0, NULL);
	if(ret == 0)
		return error_message(GetLastError());

	/* strip whitespace from end */
	index = wcslen(buffer) - 1;
	while(index >= 0 && isspace(buffer[index]))
		buffer[index--] = 0;

	return buffer;
}

HMODULE hFactorDll;

void init_ffi(void)
{
	hFactorDll = GetModuleHandle(FACTOR_DLL);
	if(!hFactorDll)
		fatal_error("GetModuleHandle(\"" FACTOR_DLL_NAME "\") failed", 0);
}

void ffi_dlopen (F_DLL *dll, bool error)
{
	HMODULE module = LoadLibraryEx(alien_offset(dll->path), NULL, 0);

	if (!module)
	{
		dll->dll = NULL;
		if(error)
			general_error(ERROR_FFI,F,F,
				(void*)tag_object(get_error_message()));
		else
			return;
	}

	dll->dll = module;
}

void *ffi_dlsym(F_DLL *dll, F_SYMBOL *symbol)
{
	return GetProcAddress(dll ? (HMODULE)dll->dll : hFactorDll, symbol);
}

void ffi_dlclose(F_DLL *dll)
{
	FreeLibrary((HMODULE)dll->dll);
	dll->dll = NULL;
}

/* You must free() this yourself. */
const F_CHAR *default_image_path(void)
{
	F_CHAR full_path[MAX_UNICODE_PATH];
	F_CHAR *ptr;
	F_CHAR path_temp[MAX_UNICODE_PATH];

	if(!GetModuleFileName(NULL, full_path, MAX_UNICODE_PATH))
		fatal_error("GetModuleFileName() failed", 0);

	if((ptr = wcsrchr(full_path, '.')))
		*ptr = 0;

	snwprintf(path_temp, sizeof(path_temp)-1, L"%s.image", full_path); 
	path_temp[sizeof(path_temp) - 1] = 0;

	return safe_strdup(path_temp);
}

/* You must free() this yourself. */
const F_CHAR *vm_executable_path(void)
{
	F_CHAR full_path[MAX_UNICODE_PATH];
	if(!GetModuleFileName(NULL, full_path, MAX_UNICODE_PATH))
		fatal_error("GetModuleFileName() failed", 0);
	return safe_strdup(full_path);
}

DEFINE_PRIMITIVE(stat)
{
	WIN32_FIND_DATA st;
	HANDLE h;

	F_CHAR *path = unbox_u16_string();
	if(INVALID_HANDLE_VALUE == (h = FindFirstFile(
		path,
		&st)))
	{
		dpush(F);
		dpush(F);
		dpush(F);
		dpush(F);
	}
	else
	{
		box_boolean(st.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY);
		dpush(tag_fixnum(0));
		box_unsigned_8(
			(u64)st.nFileSizeLow | (u64)st.nFileSizeHigh << 32);

		u64 lo = st.ftLastWriteTime.dwLowDateTime;
		u64 hi = st.ftLastWriteTime.dwHighDateTime;
		u64 modTime = (hi << 32) + lo;

		box_unsigned_8((modTime - EPOCH_OFFSET) / 10000000);
		FindClose(h);
	}
}

DEFINE_PRIMITIVE(read_dir)
{
	HANDLE dir;
	WIN32_FIND_DATA find_data;
	F_CHAR *path = unbox_u16_string();

	GROWABLE_ARRAY(result);

	if(INVALID_HANDLE_VALUE != (dir = FindFirstFile(path, &find_data)))
	{
		do
		{
			REGISTER_UNTAGGED(result);
			CELL name = tag_object(from_u16_string(find_data.cFileName));
			CELL dirp = tag_boolean(find_data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY);
			CELL pair = allot_array_2(name,dirp);
			UNREGISTER_UNTAGGED(result);
			GROWABLE_ADD(result,pair);
		}
		while (FindNextFile(dir, &find_data));
		CloseHandle(dir);
	}

	GROWABLE_TRIM(result);

	dpush(tag_object(result));
}

F_SEGMENT *alloc_segment(CELL size)
{
	char *mem;
	DWORD ignore;

	if((mem = (char *)VirtualAlloc(NULL, getpagesize() * 2 + size,
		MEM_COMMIT, PAGE_EXECUTE_READWRITE)) == 0)
		fatal_error("Out of memory in alloc_segment",0);

	if (!VirtualProtect(mem, getpagesize(), PAGE_NOACCESS, &ignore))
		fatal_error("Cannot allocate low guard page", (CELL)mem);

	if (!VirtualProtect(mem + size + getpagesize(),
		getpagesize(), PAGE_NOACCESS, &ignore))
		fatal_error("Cannot allocate high guard page", (CELL)mem);

	F_SEGMENT *block = safe_malloc(sizeof(F_SEGMENT));

	block->start = (CELL)mem + getpagesize();
	block->size = size;
	block->end = block->start + size;

	return block;
}

void dealloc_segment(F_SEGMENT *block)
{
	SYSTEM_INFO si;
	GetSystemInfo(&si);
	if(!VirtualFree((void*)(block->start - si.dwPageSize), 0, MEM_RELEASE))
		fatal_error("dealloc_segment failed",0);
	free(block);
}

long getpagesize(void)
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

void sleep_millis(DWORD msec)
{
    Sleep(msec);
}
