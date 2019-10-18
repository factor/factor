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

package factor;

import factor.primitives.*;
import java.util.Iterator;
import java.util.Map;
import java.util.TreeMap;

public class FactorDictionary
{
	public FactorWord last;

	FactorWord datastackGet;
	FactorWord datastackSet;
	FactorWord clear;
	FactorWord callstackGet;
	FactorWord callstackSet;
	FactorWord restack;
	FactorWord unstack;
	FactorWord unwind;
	FactorWord jnew;
	FactorWord jvarGet;
	FactorWord jvarSet;
	FactorWord jvarGetStatic;
	FactorWord jvarSetStatic;
	FactorWord jinvoke;
	FactorWord jinvokeStatic;
	FactorWord get;
	FactorWord set;
	FactorWord define;
	FactorWord call;
	FactorWord bind;
	FactorWord choice;

	private Map intern;

	//{{{ init() method
	public void init()
	{
		intern = new TreeMap();

		// data stack primitives
		datastackGet = intern("datastack$");
		datastackGet.def = new DatastackGet(
			datastackGet);
		datastackSet = intern("datastack@");
		datastackSet.def = new DatastackSet(
			datastackSet);
		clear = intern("clear");
		clear.def = new Clear(clear);

		// call stack primitives
		callstackGet = intern("callstack$");
		callstackGet.def = new CallstackGet(
			callstackGet);
		callstackSet = intern("callstack@");
		callstackSet.def = new CallstackSet(
			callstackSet);
		restack = intern("restack");
		restack.def = new Restack(restack);
		unstack = intern("unstack");
		unstack.def = new Unstack(unstack);
		unwind = intern("unwind");
		unwind.def = new Unwind(unwind);

		// reflection primitives
		jinvoke = intern("jinvoke");
		jinvoke.def = new JInvoke(jinvoke);
		jinvokeStatic = intern("jinvoke-static");
		jinvokeStatic.def = new JInvokeStatic(
			jinvokeStatic);
		jnew = intern("jnew");
		jnew.def = new JNew(jnew);
		jvarGet = intern("jvar$");
		jvarGet.def = new JVarGet(jvarGet);
		jvarGetStatic = intern("jvar-static$");
		jvarGetStatic.def = new JVarGetStatic(
			jvarGetStatic);
		jvarSet = intern("jvar@");
		jvarSet.def = new JVarSet(jvarSet);
		jvarSetStatic = intern("jvar-static@");
		jvarSetStatic.def = new JVarSetStatic(
			jvarSetStatic);

		// namespaces
		get = intern("$");
		get.def = new Get(get);
		set = intern("@");
		set.def = new Set(set);

		// definition
		define = intern("define");
		define.def = new Define(define);

		// combinators
		call = intern("call");
		call.def = new Call(call);
		bind = intern("bind");
		bind.def = new Bind(bind);
		choice = intern("?");
		choice.def = new Choice(choice);
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
	public Cons toWordList()
	{
		Cons first = null;
		Cons last = null;
		Iterator iter = intern.values().iterator();
		while(iter.hasNext())
		{
			FactorWord word = (FactorWord)iter.next();
			if(!(word.def instanceof FactorMissingDefinition))
			{
				Cons cons = new Cons(word,null);
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
