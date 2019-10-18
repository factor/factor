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

import java.util.Iterator;
import java.util.Map;
import java.util.TreeMap;

public class FactorDictionary
{
	// these are defined here for use by the precompiler
	FactorWord jconstructor;
	FactorWord jnew;
	FactorWord jfield;
	FactorWord jvarGet;
	FactorWord jvarSet;
	FactorWord jvarGetStatic;
	FactorWord jvarSetStatic;
	FactorWord jmethod;
	FactorWord jinvoke;
	FactorWord jinvokeStatic;

	private Map intern;

	//{{{ init() method
	public void init()
	{
		intern = new TreeMap();

		// data stack primitives
		intern("datastack$").def = new FactorPrimitive.P_datastackGet();
		intern("datastack@").def = new FactorPrimitive.P_datastackSet();
		intern("clear").def = new FactorPrimitive.P_clear();

		// call stack primitives
		intern("callstack$").def = new FactorPrimitive.P_callstackGet();
		intern("callstack@").def = new FactorPrimitive.P_callstackSet();
		intern("restack").def = new FactorPrimitive.P_restack();
		intern("unstack").def = new FactorPrimitive.P_unstack();
		intern("unwind").def = new FactorPrimitive.P_unwind();

		// reflection primitives
		jconstructor = intern("jconstructor");
		jconstructor.def = new FactorPrimitive.P_jconstructor();
		jfield = intern("jfield");
		jfield.def = new FactorPrimitive.P_jfield();
		jinvoke = intern("jinvoke");
		jinvoke.def = new FactorPrimitive.P_jinvoke();
		jinvokeStatic = intern("jinvokeStatic");
		jinvokeStatic.def = new FactorPrimitive.P_jinvokeStatic();
		jmethod = intern("jmethod");
		jmethod.def = new FactorPrimitive.P_jmethod();
		jnew = intern("jnew");
		jnew.def = new FactorPrimitive.P_jnew();
		jvarGet = intern("jvar$");
		jvarGet.def = new FactorPrimitive.P_jvarGet();
		jvarGetStatic = intern("jvarStatic$");
		jvarGetStatic.def = new FactorPrimitive.P_jvarGetStatic();
		jvarSet = intern("jvar@");
		jvarSet.def = new FactorPrimitive.P_jvarSet();
		jvarSetStatic = intern("jvarStatic@");
		jvarSetStatic.def = new FactorPrimitive.P_jvarSetStatic();

		// namespaces
		intern("$").def = new FactorPrimitive.P_get();
		intern("@").def = new FactorPrimitive.P_set();
		intern("s@").def = new FactorPrimitive.P_swap_set();

		// definition
		intern("define").def = new FactorPrimitive.P_define();

		// combinators
		intern("call").def = new FactorPrimitive.P_call();
		intern("bind").def = new FactorPrimitive.P_bind();
	} //}}}

	//{{{ intern() method
	public FactorWord intern(String name)
	{
		FactorWord w = (FactorWord)intern.get(name);
		if(w == null)
		{
			w = new FactorWord(name);
			intern.put(name,w);
		}
		return w;
	} //}}}

	//{{{ toWordList() method
	public FactorList toWordList()
	{
		FactorList first = null;
		FactorList last = null;
		Iterator iter = intern.values().iterator();
		while(iter.hasNext())
		{
			FactorWord word = (FactorWord)iter.next();
			if(word.def != FactorMissingDefinition.INSTANCE)
			{
				FactorList cons = new FactorList(word,null);
				if(first == null)
					first = cons;
				else
					last.cdr = cons;
				last = cons;
			}
		}
		return first;
	} //}}}
}
