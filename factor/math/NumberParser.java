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

package factor.math;

import java.io.*;
import java.math.BigInteger;

/**
 * A class for turning strings into numbers.
 */
public class NumberParser
{
	//{{{ parseInteger() method
	private static Number parseInteger(String word, int base)
	{
		try
		{
			return Integer.valueOf(word,base);
		}
		catch(NumberFormatException e)
		{
			return new BigInteger(word,base);
		}
	} //}}}

	//{{{ parseNumber() method
	/**
	 * If the given string is a number, convert it to a Number instance,
	 * otherwise return null.
	 */
	public static Number parseNumber(String word, int base)
	{
		if(word == null)
			return null;

		boolean number = false;
		boolean floating = false;
		boolean exponent = false;
		int ratio = -1;

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
			else if(Character.isDigit(ch))
				number = true;
			else if(base == 16
				&& ((ch >= 'a' && ch <= 'f')
				||  (ch >= 'A' && ch <= 'F')))
			{
				number = true;
			}
			else if((ch == 'e' || ch == 'E')
				&& word.length() != 1)
			{
				if(exponent || ratio != -1)
				{
					number = false;
					break;
				}
				else
					exponent = true;
			}
			else if(ch == '.' && word.length() != 1)
			{
				if(floating || ratio != -1)
				{
					number = false;
					break;
				}
				else
					floating = true;
			}
			else if(ch == '/')
			{
				if(floating || ratio != -1)
				{
					number = false;
					break;
				}
				else
					ratio = i;
			}
			else
			{
				number = false;
				break;
			}
		}

		if(number)
		{
			if(ratio == 0 || ratio == word.length() - 1)
				return null;
			else if(floating || exponent)
			{
				if(ratio != -1)
					return null;
				else
				{
					if(base != 10)
						return null;
					else
						return new Double(word);
				}
			}
			else if(ratio != -1)
			{
				String numerator = word.substring(0,ratio);
				String denominator = word.substring(ratio + 1);
				return Ratio.valueOf(
					parseInteger(numerator,base),
					parseInteger(denominator,base));
			}
			else
				return parseInteger(word,base);
		}

		return null;
	} //}}}
}
