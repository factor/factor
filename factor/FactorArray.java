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
 * A growable array.
 * @author Slava Pestov
 */
public class FactorArray implements FactorExternalizable
{
	public Object[] array;
	public int top;

	//{{{ FactorArray constructor
	public FactorArray()
	{
		array = new Object[64];
	} //}}}

	//{{{ FactorArray constructor
	public FactorArray(int size)
	{
		array = new Object[size];
	} //}}}
	
	//{{{ FactorArray constructor
	public FactorArray(Cons list)
	{
		this(list == null ? 0 : list.length());

		int i = 0;
		while(list != null)
		{
			array[i++] = list.car;
			list = list.next();
		}
	} //}}}

	//{{{ FactorArray constructor
	public FactorArray(Object[] array, int top)
	{
		this.array = array;
		this.top = top;
	} //}}}

	//{{{ toString() method
	/**
	 * Returns elementsToString() enclosed with [ and ].
	 */
	public String toString()
	{
		StringBuffer buf = new StringBuffer("{ ");
		for(int i = 0; i < top; i++)
		{
			buf.append(FactorReader.unparseObject(array[i]));
			buf.append(' ');
		}

		return buf.append("}").toString();
	} //}}}

	//{{{ clone() method
	public Object clone()
	{
		if(array == null)
			return new FactorArray();
		else
		{
			Object[] newArray = new Object[array.length];
			System.arraycopy(array,0,newArray,0,top);
			return new FactorArray(newArray,top);
		}
	} //}}}

	//{{{ hashCode() method
	public int hashCode()
	{
		int hashCode = 0;
		for(int i = 0; i < Math.min(top,4); i++)
		{
			Object obj = array[i];
			if(obj != null)
				hashCode ^= obj.hashCode();
		}

		return hashCode;
	} //}}}

	//{{{ equals() method
	public boolean equals(Object obj)
	{
		if(obj instanceof FactorArray)
		{
			FactorArray a = (FactorArray)obj;
			if(a.top != top)
				return false;
			for(int i = 0; i < top; i++)
			{
				if(!FactorLib.equal(array[i],a.array[i]))
					return false;
			}
			
			return true;
		}
		else
			return false;
	} //}}}
}
