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
	//{{{ branch3() method
	public static Object branch3(float x, float y,
		Object o1, Object o2, Object o3)
	{
		if(x > y)
			return o1;
		else if(x == y)
			return o2;
		else
			return o3;
	} //}}}

	//{{{ error() method
	public static void error(Object obj) throws Throwable
	{
		if(obj instanceof Throwable)
			throw (Throwable)obj;
		else
			throw new FactorRuntimeException(String.valueOf(obj));
	} //}}}

	//{{{ eq() method
	public static boolean eq(Object o1, Object o2)
	{
		return o1 == o2;
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

	//{{{ exec() method
	public static int exec(String[] args) throws Exception
	{
		int exitCode = -1;

		try
		{
			Process process = Runtime.getRuntime().exec(args);
			process.getInputStream().close();
			process.getOutputStream().close();
			process.getErrorStream().close();
			exitCode = process.waitFor();
		}
		catch(Exception e)
		{
			e.printStackTrace();
			// this needs to be handled better
			/* stack.push(MiscUtilities.throwableToString(e));
			Console.print(stack,namespace); */
		}

		return exitCode;
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

	//{{{ copy() method
	/**
	 * Copies the contents of an input stream to an output stream.
	 */
	public static void copy(InputStream in, OutputStream out)
		throws IOException
	{
		byte[] buf = new byte[4096];

		int count;

		for(;;)
		{
			count = in.read(buf,0,buf.length);
			if(count == -1 || count == 0)
				break;

			out.write(buf,0,count);
		}

		in.close();
		out.close();
	} //}}}

	//{{{ readLine() method
	/**
	 * Reads a line of text from the given input stream.
	 */
	public static String readLine(InputStream in) throws IOException
	{
		StringBuffer buf = new StringBuffer();
		int b;
		while((b = in.read()) != -1)
		{
			if(b == '\r')
			{
				if(in.markSupported()/*  && in.available() >= 1 */)
				{
					in.mark(1);
					b = in.read();
					if(b != '\n')
						in.reset();
				}
				break;
			}
			else if(b == '\n')
				break;
			buf.append((char)b);
		}
		return buf.toString();
	} //}}}

	//{{{ readCount() method
	public static String readCount(int count, InputStream in)
		throws IOException
	{
		byte[] bytes = new byte[count];
		int offset = 0;
		int read = 0;
		while((read = in.read(bytes,offset,count - offset)) > 0)
			offset += read;
		return new String(bytes,"ASCII");
	} //}}}

	//{{{ readCount() method
	public static String readCount(int count, Reader in)
		throws IOException
	{
		char[] chars = new char[count];
		int offset = 0;
		int read = 0;
		while((read = in.read(chars,offset,count - offset)) > 0)
			offset += read;
		return new String(chars);
	} //}}}
}
