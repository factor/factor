#include "factor.h"

/* frees memory allocated by win32 api calls */
char *buffer_to_char_string(char *buffer)
{
	int capacity = strlen(buffer);
	F_STRING *_c_str = allot_string(capacity / CHARS + 1);
	u8 *c_str = (u8*)(_c_str + 1);
	strcpy(c_str, buffer);
	LocalFree(buffer);
	return (char*)c_str;
}

F_STRING *get_error_message()
{
	DWORD id = GetLastError();
	return from_char_string(error_message(id));
}

char *error_message(DWORD id)
{
	char *buffer;
	int index;
	
	FormatMessage(
		FORMAT_MESSAGE_ALLOCATE_BUFFER |
		FORMAT_MESSAGE_FROM_SYSTEM,
		NULL,
		id,
		MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
		(LPTSTR) &buffer,
		0, NULL);

	/* strip whitespace from end */
	index = strlen(buffer) - 1;
	while(index >= 0 && isspace(buffer[index]))
		buffer[index--] = 0;
	
	return buffer_to_char_string(buffer);
}

s64 current_millis(void)
{
	FILETIME t;
	GetSystemTimeAsFileTime(&t);
	return (((s64)t.dwLowDateTime | (s64)t.dwHighDateTime<<32) - EPOCH_OFFSET) 
		/ 10000;
}

void ffi_dlopen (DLL *dll, bool error)
{
	HMODULE module;
	char *path = to_char_string(untag_string(dll->path),true);

	module = LoadLibrary(path);

	if (!module)
	{
		dll->dll = NULL;
		if(error)
			general_error(ERROR_FFI, tag_object(get_error_message()),F,true);
		else
			return;
	}

	dll->dll = module;
}

void *ffi_dlsym (DLL *dll, F_STRING *symbol, bool error)
{
	void *sym = GetProcAddress(dll ? (HMODULE)dll->dll : GetModuleHandle(NULL),
		to_char_string(symbol,true));

	if (!sym)
	{
		if(error)
			general_error(ERROR_FFI, tag_object(get_error_message()),F,true);
		else
			return NULL;
	}

	return sym;
}

void ffi_dlclose (DLL *dll)
{
	FreeLibrary((HMODULE)dll->dll);
	dll->dll = NULL;
}

void primitive_stat(void)
{
	F_STRING *path;
	WIN32_FILE_ATTRIBUTE_DATA st;

	maybe_gc(0);
	path = untag_string(dpop());

	if(!GetFileAttributesEx(to_char_string(path,true), GetFileExInfoStandard, &st)) 
	{
		dpush(F);
	} 
	else 
	{
		CELL dirp = tag_boolean(st.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY);
		CELL size = tag_bignum(s48_long_long_to_bignum(
			(s64)st.nFileSizeLow | (s64)st.nFileSizeHigh << 32));
		CELL mtime = tag_integer((int)
			((*(s64*)&st.ftLastWriteTime - EPOCH_OFFSET) / 10000000));
		dpush(make_array_4(dirp,tag_fixnum(0),size,mtime));
	}
}

void primitive_read_dir(void)
{
	F_STRING *path;
	HANDLE dir;
	WIN32_FIND_DATA find_data;
	F_ARRAY *result;
	CELL result_count = 0;

	maybe_gc(0);

	result = array(ARRAY_TYPE,100,F);

	path = untag_string(dpop());
	if (INVALID_HANDLE_VALUE != (dir = FindFirstFile(".\\*", &find_data)))
	{
		do
		{
			CELL name = tag_object(from_char_string(
				find_data.cFileName));

			if(result_count == array_capacity(result))
			{
				result = resize_array(result,
					result_count * 2,F);
			}
			
			put(AREF(result,result_count),name);
			result_count++;
		} 
		while (FindNextFile(dir, &find_data));
		CloseHandle(dir);
	}

	result = resize_array(result,result_count,F);

	dpush(tag_object(result));
}

void primitive_cwd(void)
{
	char buf[MAX_PATH];

	maybe_gc(0);
	if(!GetCurrentDirectory(MAX_PATH, buf))
		io_error();

	box_char_string(buf);
}

void primitive_cd(void)
{
	maybe_gc(0);
	SetCurrentDirectory(pop_char_string());
}

BOUNDED_BLOCK *alloc_bounded_block(CELL size)
{
    SYSTEM_INFO si;
    char *mem;
    DWORD ignore;

    GetSystemInfo(&si);
    if((mem = (char *)VirtualAlloc(NULL, si.dwPageSize*2 + size, MEM_COMMIT, PAGE_EXECUTE_READWRITE)) == 0)
        fatal_error("VirtualAlloc() failed in alloc_bounded_block()",0);

    if (!VirtualProtect(mem, si.dwPageSize, PAGE_NOACCESS, &ignore))
        fatal_error("Cannot allocate low guard page", (CELL)mem);

    if (!VirtualProtect(mem+size+si.dwPageSize, si.dwPageSize, PAGE_NOACCESS, &ignore))
        fatal_error("Cannot allocate high guard page", (CELL)mem);

    BOUNDED_BLOCK *block = safe_malloc(sizeof(BOUNDED_BLOCK));

    block->start = (int)mem + si.dwPageSize;
    block->size = size;

    return block;
}

void dealloc_bounded_block(BOUNDED_BLOCK *block)
{
    SYSTEM_INFO si;
    GetSystemInfo(&si);
    if(!VirtualFree((void*)(block->start - si.dwPageSize), 0, MEM_RELEASE))
        fatal_error("VirtualFree() failed",0);
    free(block);
}

/* SEH support. Proceed with caution. */
typedef long exception_handler_t(
	void *rec, void *frame, void *context, void *dispatch);

typedef struct exception_record {
	struct exception_record *next_handler;
	void *handler_func;
} exception_record_t;

void seh_call(void (*func)(), exception_handler_t *handler)
{
	exception_record_t record;
	asm("mov %%fs:0, %0" : "=r" (record.next_handler));
	asm("mov %0, %%fs:0" : : "r" (&record));
	record.handler_func = handler;
	func();
	asm("mov %0, %%fs:0" : "=r" (record.next_handler));
}

static long exception_handler(void *rec, void *frame, void *ctx, void *dispatch)
{
	signal_error(SIGSEGV);
}

void platform_run(void)
{
	seh_call(run_toplevel, exception_handler);
}

const char *default_image_path(void)
{
	return "factor.image";
}
