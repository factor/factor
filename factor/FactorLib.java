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

import factor.math.*;
import java.io.*;

/**
 * A few useful words.
 */
public class FactorLib
{
	//{{{ toNumber() method
	public static Number toNumber(Object arg)
	{
		if(arg instanceof Number)
			return (Number)arg;
		else if(arg instanceof Character)
			return new Integer((int)((Character)arg).charValue());
		else if(arg instanceof String)
		{
			Number num = NumberParser.parseNumber((String)arg,10);
			if(num != null)
				return num;
		}

		throw new NumberFormatException(String.valueOf(arg));
	} //}}}

	//{{{ equal() method
	public static boolean equal(Object o1, Object o2)
	{
		if(o1 == null)
			return o2 == null;
		else if((o1 instanceof Number && !(o1 instanceof FactorNumber))
			&&
			(o2 instanceof Number && !(o2 instanceof FactorNumber))
			&&
			o1.getClass() != o2.getClass())
		{
			// to compare different types of numbers, cast to a
			// double first
			return ((Number)o1).doubleValue()
				== ((Number)o2).doubleValue();
		}
		else if(o1 instanceof Number
			&& o2 instanceof String)
		{
			try
			{
				return Double.parseDouble((String)o2)
					== ((Number)o1).doubleValue();
			}
			catch(NumberFormatException nf)
			{
				return false;
			}
		}
		else if(o1 instanceof String
			&& o2 instanceof Number)
		{
			try
			{
				return Double.parseDouble((String)o1)
					== ((Number)o2).doubleValue();
			}
			catch(NumberFormatException nf)
			{
				return false;
			}
		}
		else if(o1 instanceof String
			&& o2 instanceof Character)
		{
			return o1.equals(o2.toString());
		}
		else if(o1 instanceof Character
			&& o2 instanceof String)
		{
			return o1.toString().equals(o2);
		}
		else if(o1 instanceof Cons
			&& o2 instanceof Cons)
		{
			Cons c1 = (Cons)o1;
			Cons c2 = (Cons)o2;
			return equal(c1.car,c2.car) && equal(c1.cdr,c2.cdr);
		}
		else
			return o1.equals(o2);
	} //}}}

	//{{{ objectsEqual() method
	/**
	 * Returns if two objects are equal. This correctly handles null
	 * pointers, as opposed to calling <code>o1.equals(o2)</code>.
	 */
	public static boolean objectsEqual(Object o1, Object o2)
	{
		return (o1 == null ? o2 == null : o1.equals(o2));
	} //}}}
}
