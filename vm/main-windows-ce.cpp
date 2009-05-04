#include "master.hpp"

/* 
	Windows CE argument parsing ported to work on
	int main(int argc, wchar_t **argv).

	This would not be necessary if Windows CE had CommandLineToArgvW.

	Based on MinGW's public domain char** version.

*/

int __argc;
wchar_t **__argv;

static int
parse_tokens(wchar_t* string, wchar_t*** tokens, int length)
{
	/* Extract whitespace- and quotes- delimited tokens from the given string
	   and put them into the tokens array. Returns number of tokens
	   extracted. Length specifies the current size of tokens[].
	   THIS METHOD MODIFIES string.  */

	const wchar_t* whitespace = L" \t\r\n";
	wchar_t* tokenEnd = 0;
	const wchar_t* quoteCharacters = L"\"\'";
	wchar_t *end = string + wcslen(string);

	if (string == NULL)
		return length;

	while (1)
	{
		const wchar_t* q;
		/* Skip over initial whitespace.  */
		string += wcsspn(string, whitespace);
		if (*string == '\0')
			break;

		for (q = quoteCharacters; *q; ++q)
		{
			if (*string == *q)
				break;
		}
		if (*q)
		{
			/* Token is quoted.  */
			wchar_t quote = *string++;
			tokenEnd = wcschr(string, quote);
			/* If there is no endquote, the token is the rest of the string.  */
			if (!tokenEnd)
				tokenEnd = end;
		}
		else
		{
			tokenEnd = string + wcscspn(string, whitespace);
		}

		*tokenEnd = '\0';

		{
			wchar_t** new_tokens;
			int newlen = length + 1;
			new_tokens = realloc (*tokens, sizeof (wchar_t**) * newlen);
			if (!new_tokens)
			{
				/* Out of memory.  */
				return -1;
			}

			*tokens = new_tokens;
			(*tokens)[length] = string;
			length = newlen;
		}
		if (tokenEnd == end)
			break;
		string = tokenEnd + 1;
	}
	return length;
}

static void
parse_args(int *argc, wchar_t ***argv, wchar_t *cmdlinePtrW)
{
	wchar_t cmdnameBufW[MAX_UNICODE_PATH];
	int cmdlineLen = 0;
	int modlen;

	/* argv[0] is the path of invoked program - get this from CE.  */
	cmdnameBufW[0] = 0;
	modlen = GetModuleFileNameW(NULL, cmdnameBufW, sizeof (cmdnameBufW)/sizeof (cmdnameBufW[0]));

	if (!cmdlinePtrW)
		cmdlineLen = 0;
	else
		cmdlineLen = wcslen(cmdlinePtrW);

	/* gets realloc()'d later */
	*argv = malloc (sizeof (wchar_t**) * 1);
	if (!*argv)
		ExitProcess(-1);

	(*argv)[0] = wcsdup(cmdnameBufW);
	if(!(*argv[0]))
		ExitProcess(-1);
	/* Add one to account for argv[0] */
	(*argc)++;

	if (cmdlineLen > 0)
	{
		wchar_t* argv1 = (*argv)[0] + wcslen((*argv)[0]) + 1;
		argv1 = wcsdup(cmdlinePtrW);
		if(!argv1)
			ExitProcess(-1);
		*argc = parse_tokens(argv1, argv, 1);
		if (*argc < 0)
			ExitProcess(-1);
	}
	(*argv)[*argc] = 0;
	return;
}

int WINAPI
WinMain(
	HINSTANCE hInstance,
	HINSTANCE hPrevInstance,
	LPWSTR lpCmdLine,
	int nCmdShow)
{
	parse_args(&__argc, &__argv, lpCmdLine);
	factor::start_standalone_factor(__argc,(LPWSTR*)__argv);
	// memory leak from malloc, wcsdup
	return 0;
}
