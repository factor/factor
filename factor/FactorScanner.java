/* :folding=explicit:collapseFolds=1: */

/*
 * $Id$
 *
 * Copyright (C) 2004 Slava Pestov.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package factor;

import factor.math.NumberParser;
import java.io.*;

/**
 * Splits an input stream into words.
 */
public class FactorScanner
{
	/**
	 * Special object returned on EOF.
	 */
	public static final Object EOF = new Object();

	/**
	 * Special object returned on EOL.
	 */
	public static final Object EOL = new Object();

	private String filename;
	private BufferedReader in;

	/**
	 * Line number being parsed, for error reporting.
	 */
	private int lineNo = 0;

	/**
	 * The line currently being parsed.
	 */
	private String line;

	/**
	 * Position within line being parsed.
	 */
	private int position = 0;

	private ReadTable readtable;

	/**
	 * The current word.
	 */
	private StringBuffer buf;

	//{{{ FactorScanner constructor
	public FactorScanner(String filename, BufferedReader in)
	{
		this.filename = filename;
		this.in = in;
		buf = new StringBuffer();
		setReadTable(ReadTable.DEFAULT_READTABLE);
	} //}}}

	//{{{ getReadTable() method
	public ReadTable getReadTable()
	{
		return readtable;
	} //}}}

	//{{{ setReadTable() method
	public void setReadTable(ReadTable readtable)
	{
		this.readtable = readtable;
	} //}}}

	//{{{ getLineNumber() method
	public int getLineNumber()
	{
		return lineNo;
	} //}}}

	//{{{ getColumnNumber() method
	public int getColumnNumber()
	{
		return position;
	} //}}}

	//{{{ getFileName() method
	public String getFileName()
	{
		return filename;
	} //}}}

	//{{{ nextLine() method
	public void nextLine() throws IOException
	{
		lineNo++;
		line = in.readLine();
		position = 0;
		if(line != null && line.length() == 0)
			nextLine();
	} //}}}

	//{{{ next() method
	/**
	 * @param readNumbers If true, will return either a Number or a
	 * String. Otherwise, only Strings are returned.
	 * @param start If true, dispatches will be handled by their parsing
	 * word, otherwise dispatches are ignored.
	 * @param base The number base -- not that if this is not equal to
	 * 10, floats cannot be read
	 */
	public Object next(
		boolean readNumbers,
		boolean start,
		int base)
		throws IOException, FactorParseException
	{
		if(line == null)
			return EOF;
		if(position == line.length())
			return EOL;

		for(;;)
		{
			if(position == line.length())
			{
				// EOL
				if(buf.length() != 0)
					return word(readNumbers,base);
				else
					return EOL;
			}

			char ch = line.charAt(position++);

			int type = readtable.getCharacterType(ch);

			switch(type)
			{
			case ReadTable.INVALID:
				error("Invalid character in input: " + ch);
				break;
			case ReadTable.WHITESPACE:
				if(buf.length() != 0)
					return word(readNumbers,base);
				break;
			case ReadTable.DISPATCH:
				// note that s" is read as the word s", no
				// dispatch on "
				if(buf.length() == 0 && start)
				{
					buf.append(ch);
					return word(readNumbers,base);
				}
			case ReadTable.CONSTITUENT:
				buf.append(ch);
				break;
			case ReadTable.SINGLE_ESCAPE:
				buf.append(escape());
				break;
			}
		}
	} //}}}

	//{{{ nextNonEOL() method
	public Object nextNonEOL(
		boolean readNumbers,
		boolean start,
		int base)
		throws IOException, FactorParseException
	{
		Object next = next(readNumbers,start,base);
		if(next == EOL)
			error("Unexpected EOL");
		if(next == EOF)
			error("Unexpected EOF");
		return next;
	} //}}}

	//{{{ readUntil() method
	public String readUntil(char start, char end, boolean escapesAllowed)
		throws IOException, FactorParseException
	{
		buf.setLength(0);

		for(;;)
		{
			if(position == line.length())
			{
				error("Expected " + end + " before EOL");
				break;
			}

			if(line == null)
			{
				error("Expected " + end + " before EOF");
				break;
			}

			char ch = line.charAt(position++);

			if(ch == end)
				break;

			int type = readtable.getCharacterType(ch);

			if(escapesAllowed && type == ReadTable.SINGLE_ESCAPE)
				buf.append(escape());
			else
				buf.append(ch);
		}

		String returnValue = buf.toString();
		buf.setLength(0);
		return returnValue;
	} //}}}

	//{{{ readUntilEOL() method
	public String readUntilEOL() throws IOException
	{
		buf.setLength(0);

		while(position < line.length())
			buf.append(line.charAt(position++));

		String returnValue = buf.toString();
		buf.setLength(0);
		return returnValue;
	} //}}}

	//{{{ readNonEOF() method
	public char readNonEOF() throws FactorParseException, IOException
	{
		if(position == line.length())
		{
			error("Unexpected EOL");
			return '\0';
		}
		if(line == null)
		{
			error("Unexpected EOF");
			return '\0';
		}

		return line.charAt(position++);
	} //}}}

	//{{{ readNonEOFEscaped() method
	public char readNonEOFEscaped() throws FactorParseException, IOException
	{
		char next = readNonEOF();
		if(readtable.getCharacterType(next) == ReadTable.SINGLE_ESCAPE)
			return escape();
		else
			return next;
	} //}}}

	//{{{ atEndOfWord() method
	public boolean atEndOfWord() throws IOException
	{
		if(position == line.length())
			return true;
		if(line == null)
			return true;
		char next = line.charAt(position);
		int type = readtable.getCharacterType(next);
		return type == ReadTable.WHITESPACE;
	} //}}}

	//{{{ escape() method
	private char escape() throws FactorParseException
	{
		char ch = line.charAt(position++);

		switch(ch)
		{
		case 'e':
			// ASCII ESC
			return (char)27;
		case 'n':
			return '\n';
		case 'r':
			return '\r';
		case 't':
			return '\t';
		case '\\':
			return '\\';
		case '"':
			return '"';
		case 's':
		case ' ':
			return ' ';
		case '0':
			return '\0';
		case 'u':
			if(line.length() - position < 4)
			{
				error("Unexpected EOL");
				return '\0';
			}

			String hex = line.substring(position,position + 4);

			position += 4;

			try
			{
				return (char)Integer.parseInt(hex,16);
			}
			catch(NumberFormatException e)
			{
				error("Invalid \\u escape: " + hex);
			}
			return '\0';
		default:
			error("Unknown escape: " + ch);
			return '\0';
		}
	} //}}}

	//{{{ word() method
	private Object word(boolean readNumbers, int base)
	{
		String name = buf.toString();
		buf.setLength(0);
		if(readNumbers)
		{
			Number n = NumberParser.parseNumber(name, base);
			if(n != null)
				return n;
		}

		return name;
	} //}}}

	//{{{ error() method
	public void error(String msg) throws FactorParseException
	{
		throw new FactorParseException(
			filename,lineNo,line,position - 1,msg);
	} //}}}
}
