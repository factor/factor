#include "../factor.h"

void primitive_stat(void)
{
	struct stat sb;
	F_STRING* path;

	maybe_gc(0);

	path = untag_string(dpop());
	if(stat(to_c_string(path,true),&sb) < 0)
		dpush(F);
	else
	{
		CELL dirp = tag_boolean(S_ISDIR(sb.st_mode));
		CELL mode = tag_fixnum(sb.st_mode & ~S_IFMT);
		CELL size = tag_bignum(s48_long_long_to_bignum(sb.st_size));
		CELL mtime = tag_integer(sb.st_mtime);
		dpush(cons(
			dirp,
			cons(
				mode,
				cons(
					size,
					cons(
						mtime,F)))));
	}
}

void primitive_read_dir(void)
{
	F_STRING* path;
	DIR* dir;
	CELL result = F;

	maybe_gc(0);

	path = untag_string(dpop());
	dir = opendir(to_c_string(path,true));
	if(dir != NULL)
	{
		struct dirent* file;

		while((file = readdir(dir)) != NULL)
		{
			CELL name = tag_object(from_c_string(
				file->d_name));
			result = cons(name,result);
		}

		closedir(dir);
	}

	dpush(result);
}

void primitive_cwd(void)
{
	char wd[MAXPATHLEN];
	maybe_gc(0);
	if(getcwd(wd,MAXPATHLEN) == NULL)
		io_error();
	box_c_string(wd);
}

void primitive_cd(void)
{
	maybe_gc(0);
	chdir(pop_c_string());
}

