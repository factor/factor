/* :folding=explicit:collapseFolds=1: */

/*
 * $Id$
 *
 * Copyright (C) 2003 Slava Pestov.
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

/**
 * Specifies how an input stream is to be split into words.
 */
public class ReadTable
{
	public static final ReadTable DEFAULT_READTABLE;

	//{{{ Class initializer
	static
	{
		DEFAULT_READTABLE = new ReadTable();

		DEFAULT_READTABLE.setCharacterType('\t',ReadTable.WHITESPACE);
		DEFAULT_READTABLE.setCharacterType('\n',ReadTable.WHITESPACE);
		DEFAULT_READTABLE.setCharacterType('\r',ReadTable.WHITESPACE);
		DEFAULT_READTABLE.setCharacterType(' ',ReadTable.WHITESPACE);

		DEFAULT_READTABLE.setCharacterType('!',ReadTable.CONSTITUENT);
		DEFAULT_READTABLE.setCharacterType('"',ReadTable.DISPATCH);
		DEFAULT_READTABLE.setCharacterRange('#','[',ReadTable.CONSTITUENT);
		DEFAULT_READTABLE.setCharacterType('\\',ReadTable.SINGLE_ESCAPE);
		DEFAULT_READTABLE.setCharacterRange(']','~',ReadTable.CONSTITUENT);
		DEFAULT_READTABLE.setCharacterType('(',ReadTable.CONSTITUENT);
	} //}}}

	/**
	 * Invalid character.
	 */
	public static final int INVALID = 0;

	/**
	 * Word break character.
	 */
	public static final int WHITESPACE = 1;

	/**
	 * Word character. Entire words are read at once.
	 */
	public static final int CONSTITUENT = 2;

	/**
	 * A single character to dispatch on.
	 */
	public static final int DISPATCH = 3;

	/**
	 * Escape the next character.
	 */
	public static final int SINGLE_ESCAPE = 4;

	private int[] chars = new int[256];

	//{{{ getCharacterType() method
	public int getCharacterType(char ch)
	{
		if(ch >= 256)
			return INVALID;
		else
			return chars[ch];
	} //}}}

	//{{{ setCharacterType() method
	public void setCharacterType(char ch, int type)
	{
		chars[ch] = type;
	} //}}}

	//{{{ setCharacterRange() method
	public void setCharacterRange(char ch1, char ch2, int type)
	{
		for(int i = ch1; i <= ch2; i++)
			chars[i] = type;
	} //}}}
}
