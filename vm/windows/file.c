#include "../factor.h"

void primitive_stat(void)
{
	F_STRING *path;
	WIN32_FILE_ATTRIBUTE_DATA st;

	maybe_gc(0);
	path = untag_string(dpop());

	if(!GetFileAttributesEx(to_c_string(path,true), GetFileExInfoStandard, &st)) 
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
			CELL name = tag_object(from_c_string(
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

	box_c_string(buf);
}

void primitive_cd(void)
{
	maybe_gc(0);
	SetCurrentDirectory(pop_c_string());
}