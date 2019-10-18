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

import java.util.LinkedList;
import java.util.List;
/**
 * Used to build up linked lists.
 */
public class FactorList implements PublicCloneable, FactorExternalizable
{
	public static int COUNT;

	public Object car;
	public Object cdr;

	//{{{ FactorList constructor
	public FactorList(Object car, Object cdr)
	{
		this.car = car;
		this.cdr = cdr;

		COUNT++;
	} //}}}

	//{{{ car() method
	public Object car(Class clas) throws Exception
	{
		return FactorJava.convertToJavaType(car,clas);
	} //}}}

	//{{{ cdr() method
	public Object cdr(Class clas) throws Exception
	{
		return FactorJava.convertToJavaType(cdr,clas);
	} //}}}

	//{{{ next() method
	public FactorList next()
	{
		return (FactorList)cdr;
	} //}}}

	//{{{ get() method
	public Object get(int index)
	{
		return _get(index).car;
	} //}}}

	//{{{ _get() method
	public FactorList _get(int index)
	{
		FactorList iter = this;
		while(index != 0)
		{
			iter = (FactorList)iter.cdr;
			index--;
		}
		return iter;
	} //}}}

	//{{{ contains() method
	public boolean contains(Object obj)
	{
		FactorList iter = this;
		while(iter != null)
		{
			if(FactorLib.objectsEqual(obj,iter.car))
				return true;
			iter = iter.next();
		}
		return false;
	} //}}}

	//{{{ set() method
	/**
	 * Returns a new list where the item at the given index is changed.
	 */
	public FactorList set(int index, Object car, Object cdr)
	{
		if(index == 0)
			return new FactorList(car,cdr);
		else
		{
			return new FactorList(this.car,
				this.next().set(index - 1,car,cdr));
		}
	} //}}}

	//{{{ set() method
	/**
	 * Returns a new list containing the first n elements of this list.
	 */
	public FactorList head(int n)
	{
		if(n == 0)
			return null;
		else if(cdr == null && n == 1)
			return this;
		else
		{
			FactorList head = next().head(n - 1);
			if(head == cdr)
				return this;
			else
				return new FactorList(car,head);
		}
	} //}}}

	//{{{ length() method
	public int length()
	{
		int size = 0;
		FactorList iter = this;
		while(iter != null)
		{
			iter = (FactorList)iter.cdr;
			size++;
		}
		return size;
	} //}}}

	//{{{ append() method
	public FactorList append(FactorList list)
	{
		if(list == null)
			return this;

		FactorList returnValue = null;
		FactorList end = null;
		FactorList iter = this;
		for(;;)
		{
			FactorList cons = new FactorList(iter.car,null);
			if(end != null)
				end.cdr = cons;
			end = cons;
			if(returnValue == null)
				returnValue = cons;
			if(iter.cdr == null)
			{
				end.cdr = list;
				break;
			}
			else
				iter = iter.next();
		}
		return returnValue;
	} //}}}

	//{{{ reverse() method
	public FactorList reverse()
	{
		FactorList returnValue = null;
		FactorList iter = this;
		while(iter != null)
		{
			returnValue = new FactorList(iter.car,returnValue);
			iter = iter.next();
		}
		return returnValue;
	} //}}}

	//{{{ isProperList() method
	public boolean isProperList()
	{
		return cdr == null || (cdr instanceof FactorList
			&& ((FactorList)cdr).isProperList());
	} //}}}

	//{{{ elementsToString() method
	/**
	 * Returns a whitespace separated string of the toString() of each
	 * item.
	 */
	public String elementsToString()
	{
		StringBuffer buf = new StringBuffer();
		FactorList iter = this;
		while(iter != null)
		{
			if(iter.car == this)
				buf.append("<circular reference>");
			else
				buf.append(FactorJava.factorTypeToString(iter.car));
			if(iter.cdr instanceof FactorList)
			{
				buf.append(' ');
				iter = (FactorList)iter.cdr;
				continue;
			}
			else if(iter.cdr == null)
				break;
			else
			{
				buf.append(" , ");
				buf.append(FactorJava.factorTypeToString(iter.cdr));
				iter = null;
			}
		}

		return buf.toString();
	} //}}}

	//{{{ toString() method
	/**
	 * Returns elementsToString() enclosed with [ and ].
	 */
	public String toString()
	{
		return "[ " + elementsToString() + " ]";
	} //}}}

	//{{{ toJavaList() method
	public List toJavaList()
	{
		LinkedList returnValue = new LinkedList();
		FactorList iter = this;
		while(iter != null)
		{
			returnValue.add(iter.car);
			iter = (FactorList)iter.cdr;
		}
		return returnValue;
	} //}}}

	//{{{ toArray() method
	/**
	 * Note that unlike Java list toArray(), the given array must already
	 * be the right size.
	 */
	public Object[] toArray(Object[] returnValue)
	{
		int i = 0;
		FactorList iter = this;
		while(iter != null)
		{
			returnValue[i++] = iter.car;
			iter = iter.next();
		}
		return returnValue;
	} //}}}

	//{{{ fromArray() method
	public static FactorList fromArray(Object[] array)
	{
		if(array == null || array.length == 0)
			return null;
		else
		{
			FactorList first = new FactorList(array[0],null);
			FactorList last = first;
			for(int i = 1; i < array.length; i++)
			{
				FactorList cons = new FactorList(array[i],null);
				last.cdr = cons;
				last = cons;
			}
			return first;
		}
	} //}}}

	//{{{ equals() method
	public boolean equals(Object o)
	{
		if(o instanceof FactorList)
		{
			FactorList l = (FactorList)o;
			return FactorLib.objectsEqual(car,l.car)
				&& FactorLib.objectsEqual(cdr,l.cdr);
		}
		else
			return false;
	} //}}}

	//{{{ hashCode() method
	public int hashCode()
	{
		if(car == null)
			return 0;
		else
			return car.hashCode();
	} //}}}

	//{{{ clone() method
	public Object clone()
	{
		if(cdr instanceof FactorList)
			return new FactorList(car,((FactorList)cdr).clone());
		else
			return new FactorList(car,cdr);
	} //}}}

	//{{{ deepClone() method
	public Object deepClone()
	{
		Object ccar;
		if(car instanceof PublicCloneable)
			ccar = ((PublicCloneable)car).clone();
		else
			ccar = car;
		if(cdr instanceof FactorList)
		{
			return new FactorList(ccar,next().deepClone());
		}
		else if(cdr == null)
		{
			return new FactorList(ccar,null);
		}
		else
		{
			Object ccdr;
			if(cdr instanceof PublicCloneable)
				ccdr = ((PublicCloneable)cdr).clone();
			else
				ccdr = cdr;
			return new FactorList(ccar,ccdr);
		}
	} //}}}
}
