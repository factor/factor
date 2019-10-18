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

import java.io.*;
import java.math.BigInteger;

/**
 * Splits an input stream into words.
 */
public class FactorScanner
{
	/**
	 * Special object returned on EOF.
	 */
	public static final Object EOF = new Object();

	private FactorInterpreter interp;
	private String filename;
	private PushbackReader in;
	private StringBuffer buf;
	private ReadTable readtable;
	private int lineNo = 1;
	private boolean lastCR;

	//{{{ FactorScanner constructor
	public FactorScanner(FactorInterpreter interp, String filename,
		Reader in, ReadTable readtable)
	{
		this.interp = interp;
		this.filename = filename;
		this.in = new PushbackReader(in,1);
		this.readtable = readtable;
		buf = new StringBuffer();
	} //}}}

	//{{{ next() method
	/**
	 * @param readNumbers If true, will return either a Number or a
	 * FactorWord. Otherwise, only FactorWords are returned.
	 * @param start If true, dispatches will be handled by their parsing
	 * word, otherwise dispatches are ignored.
	 */
	public Object next(boolean readNumbers, boolean start)
		throws IOException, FactorParseException
	{
		for(;;)
		{
			int ch = in.read();
			if(ch == -1)
			{
				if(buf.length() == 0)
					return EOF;
				else
					return word(readNumbers);
			}
			else if(ch == '\n')
			{
				if(!lastCR)
					lineNo++;
				if(buf.length() != 0)
					return word(readNumbers);
				else
					continue;
			}
			else if(ch == '\r')
			{
				lineNo++;
				lastCR = true;
				if(buf.length() != 0)
					return word(readNumbers);
				else
					continue;
			}
			else
				lastCR = false;

			int type = readtable.getCharacterType((char)ch);

			switch(type)
			{
			case ReadTable.INVALID:
				error("Invalid character in input: " + (int)ch);
				break;
			case ReadTable.WHITESPACE:
				if(buf.length() != 0)
					return word(readNumbers);
				break;
			case ReadTable.DISPATCH:
				// note that s" is read as the word s", no
				// dispatch on "
				if(buf.length() == 0 && start)
				{
					buf.append((char)ch);
					return word(readNumbers);
				}
			case ReadTable.CONSTITUENT:
				buf.append((char)ch);
				break;
			case ReadTable.SINGLE_ESCAPE:
				buf.append(escape(readNonEOF()));
				break;
			}
		}
	} //}}}

	//{{{ readUntil() method
	public String readUntil(char start, char end,
		boolean lineBreaksAllowed,
		boolean escapesAllowed)
		throws IOException, FactorParseException
	{
		buf.setLength(0);

		for(;;)
		{
			int ch = in.read();
			if(ch == -1)
				error("Expected " + end + " before EOF");
			else if((ch == '\r' || ch == '\n')
				&& !lineBreaksAllowed)
			{
				error("Expected " + end + " before EOL");
			}
			else if(ch == '\n')
			{
				if(!lastCR)
					buf.append('\n');
				continue;
			}
			else if(ch == '\r')
			{
				buf.append('\n');
				lastCR = true;
				continue;
			}
			else if(ch == end)
				break;
			else
				lastCR = false;

			int type = readtable.getCharacterType((char)ch);

			if(type == ReadTable.SINGLE_ESCAPE)
				buf.append(escape(readNonEOF()));
			else
				buf.append((char)ch);
		}

		String returnValue = buf.toString();
		buf.setLength(0);
		return returnValue;
	} //}}}

	//{{{ readUntilEOL() method
	public String readUntilEOL() throws IOException
	{
		buf.setLength(0);

		for(;;)
		{
			int ch = in.read();
			if(ch == -1)
				break;
			else if(ch == '\n')
			{
				if(!lastCR)
					lineNo++;
				break;
			}
			else if(ch == '\r')
			{
				lineNo++;
				lastCR = true;
				break;
			}
			else
				buf.append((char)ch);
		}

		String returnValue = buf.toString();
		buf.setLength(0);
		return returnValue;
	} //}}}

	//{{{ readNonEOF() method
	public char readNonEOF() throws FactorParseException, IOException
	{
		int next = in.read();
		if(next == -1)
		{
			error("Unexpected EOF");
			// can't happen
			return '\0';
		}
		else
			return (char)next;
	} //}}}

	//{{{ readNonEOFEscaped() method
	public char readNonEOFEscaped() throws FactorParseException, IOException
	{
		int next = in.read();
		if(next == -1)
		{
			error("Unexpected EOF");
			// can't happen
			return '\0';
		}
		else if(readtable.getCharacterType((char)next)
			== ReadTable.SINGLE_ESCAPE)
		{
			return escape(readNonEOF());
		}
		else
			return (char)next;
	} //}}}

	//{{{ atEndOfWord() method
	public boolean atEndOfWord() throws IOException
	{
		int next = in.read();
		if(next == -1)
			return true;
		else
		{
			in.unread(next);
			int type = readtable.getCharacterType((char)next);
			return type == ReadTable.WHITESPACE;
		}
	} //}}}

	//{{{ escape() method
	private char escape(char ch) throws FactorParseException
	{
		switch(ch)
		{
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
		case ' ':
			return ' ';
		case '0':
			return '\0';
		default:
			error("Unknown escape: " + ch);
			// can't happen
			return '\0';
		}
	} //}}}

	//{{{ word() method
	private Object word(boolean readNumbers)
	{
		String name = buf.toString();
		buf.setLength(0);
		if(readNumbers)
		{
			Number n = parseNumber(name);
			if(n != null)
				return n;
		}

		return interp.intern(name);
	} //}}}

	//{{{ parseNumber() method
	/**
	 * If the given string is a number, convert it to a Number instance,
	 * otherwise return null.
	 */
	public static Number parseNumber(String word)
	{
		if(word == null)
			return null;

		boolean number = true;
		boolean floating = false;
		boolean exponent = false;

		for(int i = 0; i < word.length(); i++)
		{
			char ch = word.charAt(i);
			if(ch == '-')
			{
				if((i != 0 && Character.toLowerCase(
					word.charAt(i - 1))
					!= 'e') || word.length() == 1)
				{
					number = false;
					break;
				}
			}
			else if((ch == 'e' || ch == 'E')
				&& word.length() != 1)
			{
				if(exponent)
				{
					number = false;
					break;
				}
				else
					exponent = true;
			}
			else if(ch == '.' && word.length() != 1)
			{
				if(floating)
				{
					number = false;
					break;
				}
				else
					floating = true;
			}
			else if(!Character.isDigit(ch))
			{
				number = false;
				break;
			}
		}

		if(number)
		{
			if(floating || exponent)
				return new Float(word);
			else
			{
				try
				{
					return new Integer(word);
				}
				catch(NumberFormatException e)
				{
					return new BigInteger(word);
				}
			}
		}

		return null;
	} //}}}

	//{{{ error() method
	public void error(String msg) throws FactorParseException
	{
		throw new FactorParseException(filename,lineNo,msg);
	} //}}}
}
