/* :folding=explicit:collapseFolds=1: */

/*
* $Id$
*
* Copyright (C) 2003, 2004 Slava Pestov.
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

package factor.compiler;

import factor.*;
import java.util.*;

/**
 * Each word class has a class loader.
 *
 * When compiling a word; add each dependent word to new class loader's
 * delegates map.
 */
public class FactorClassLoader extends ClassLoader
{
	private long id;
	private FactorNamespace table = new FactorNamespace();
	private ClassLoader delegate;

	//{{{ FactorClassLoader constructor
	public FactorClassLoader(ClassLoader delegate)
	{
		this.delegate = delegate;
	} //}}}

	//{{{ addDependency() method
	public void addDependency(String name, FactorClassLoader loader)
	{
		try
		{
			table.setVariable(name,loader);
		}
		catch(Exception e)
		{
			throw new RuntimeException(e);
		}
	} //}}}

	//{{{ addClass() method
	public Class addClass(String name, byte[] code, int off, int len)
	{
		return defineClass(name,code,off,len);
	} //}}}

	//{{{ loadClass() method
	public synchronized Class loadClass(String name, boolean resolve)
		throws ClassNotFoundException
	{
		Class c = findLoadedClass(name);
		if(c != null)
		{
			if(resolve)
				resolveClass(c);
			return c;
		}

		// See if another known class loader has this
		try
		{
			Object obj = table.getVariable(name);
			if(obj instanceof FactorClassLoader)
			{
				return ((FactorClassLoader)obj)
					.loadClass(name,resolve);
			}
			else if(obj != null)
			{
				System.err.println("WARNING: unknown object in class loader table for " + this + ": " + obj);
			}

			if(delegate == null)
				return super.loadClass(name,resolve);
			else
			{
				c = delegate.loadClass(name);
				if(resolve)
					resolveClass(c);
				return c;
			}
		}
		catch(ClassNotFoundException e)
		{
			throw e;
		}
		catch(Exception e)
		{
			throw new RuntimeException(e);
		}
	} //}}}
}
