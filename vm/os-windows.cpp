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

void *factor_vm::ffi_dlsym_raw(dll *dll, symbol_char *symbol)
{
	return ffi_dlsym(dll, symbol);
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

void code_heap::guard_safepoint()
{
	DWORD ignore;
	if (!VirtualProtect(safepoint_page, getpagesize(), PAGE_NOACCESS, &ignore))
		fatal_error("Cannot protect safepoint guard page", (cell)safepoint_page);
}

void code_heap::unguard_safepoint()
{
	DWORD ignore;
	if (!VirtualProtect(safepoint_page, getpagesize(), PAGE_READWRITE, &ignore))
		fatal_error("Cannot unprotect safepoint guard page", (cell)safepoint_page);
}

void factor_vm::move_file(const vm_char *path1, const vm_char *path2)
{
	if(MoveFileEx((path1),(path2),MOVEFILE_REPLACE_EXISTING) == false)
		general_error(ERROR_IO,tag_fixnum(GetLastError()),false_object);
}

void factor_vm::init_signals() {}

THREADHANDLE start_thread(void *(*start_routine)(void *), void *args)
{
	return (void *)CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)start_routine, args, 0, 0);
}

u64 nano_count()
{
	static double scale_factor;

	static u32 hi = 0;
	static u32 lo = 0;

	LARGE_INTEGER count;
	BOOL ret = QueryPerformanceCounter(&count);
	if(ret == 0)
		fatal_error("QueryPerformanceCounter", 0);

	if(scale_factor == 0.0)
	{
		LARGE_INTEGER frequency;
		BOOL ret = QueryPerformanceFrequency(&frequency);
		if(ret == 0)
			fatal_error("QueryPerformanceFrequency", 0);
		scale_factor = (1000000000.0 / frequency.QuadPart);
	}

#ifdef FACTOR_64
	hi = count.HighPart;
#else
	/* On VirtualBox, QueryPerformanceCounter does not increment
	the high part every time the low part overflows.  Workaround. */
	if(lo > count.LowPart)
		hi++;
#endif
	lo = count.LowPart;

	return (u64)((((u64)hi << 32) | (u64)lo) * scale_factor);
}

void sleep_nanos(u64 nsec)
{
	Sleep((DWORD)(nsec/1000000));
}

LONG factor_vm::exception_handler(PEXCEPTION_RECORD e, void *frame, PCONTEXT c, void *dispatch)
{
	c->ESP = (cell)fix_callstack_top((stack_frame *)c->ESP);
	ctx->callstack_top = (stack_frame *)c->ESP;

	switch (e->ExceptionCode)
	{
	case EXCEPTION_ACCESS_VIOLATION:
		signal_fault_addr = e->ExceptionInformation[1];
		c->EIP = (cell)factor::memory_signal_handler_impl;
		break;

	case STATUS_FLOAT_DENORMAL_OPERAND:
	case STATUS_FLOAT_DIVIDE_BY_ZERO:
	case STATUS_FLOAT_INEXACT_RESULT:
	case STATUS_FLOAT_INVALID_OPERATION:
	case STATUS_FLOAT_OVERFLOW:
	case STATUS_FLOAT_STACK_CHECK:
	case STATUS_FLOAT_UNDERFLOW:
	case STATUS_FLOAT_MULTIPLE_FAULTS:
	case STATUS_FLOAT_MULTIPLE_TRAPS:
#ifdef FACTOR_64
		signal_fpu_status = fpu_status(MXCSR(c));
#else
		signal_fpu_status = fpu_status(X87SW(c) | MXCSR(c));

		/* This seems to have no effect */
		X87SW(c) = 0;
#endif
		MXCSR(c) &= 0xffffffc0;
		c->EIP = (cell)factor::fp_signal_handler_impl;
		break;
	default:
		signal_number = e->ExceptionCode;
		c->EIP = (cell)factor::misc_signal_handler_impl;
		break;
	}

	return 0;
}

VM_C_API LONG exception_handler(PEXCEPTION_RECORD e, void *frame, PCONTEXT c, void *dispatch)
{
	return current_vm()->exception_handler(e,frame,c,dispatch);
}

void factor_vm::open_console() {}

}
