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

package factor.compiler;

import factor.*;

public class CompilerState
{
	public FactorArray datastack;
	public FactorArray callstack;
	public StackEffect effect;
	public Cons inDtypes;
	public Cons inRtypes;

	//{{{ CompilerState constructor
	public CompilerState(FactorCompiler compiler)
	{
		datastack = (FactorArray)compiler.datastack.clone();
		callstack = (FactorArray)compiler.callstack.clone();
		effect = (StackEffect)compiler.getStackEffect();
		inDtypes = cloneTypespec(compiler,compiler.inDtypes);
		inRtypes = cloneTypespec(compiler,compiler.inRtypes);
	} //}}}

	//{{{ restore() method
	public void restore(FactorCompiler compiler)
	{
		compiler.datastack = (FactorArray)datastack.clone();
		compiler.callstack = (FactorArray)callstack.clone();
		compiler.effect = (StackEffect)effect.clone();
		compiler.inDtypes = cloneTypespec(compiler,inDtypes);
		compiler.inRtypes = cloneTypespec(compiler,inRtypes);
	} //}}}

	//{{{ findResult() method
	private static Result findResult(Result result,
		FactorArray stack)
	{
		for(int i = 0; i < stack.top; i++)
		{
			if(stack.stack[i] instanceof Result)
			{
				Result r = (Result)stack.stack[i];
				if(r.getLocal() == result.getLocal())
					return r;
			}
		}

		return null;
	} //}}}

	//{{{ cloneResult() method
	private static Result cloneResult(Result result,
		FactorArray datastack,
		FactorArray callstack)
	{
		Result r = findResult(result,datastack);
		if(r != null)
			return r;
		r = findResult(result,callstack);
		if(r != null)
			return r;
		return (Result)result.clone();
	} //}}}

	//{{{ cloneTypespec() method
	private static Cons cloneTypespec(FactorCompiler compiler, Cons spec)
	{
		Cons newSpec = null;
		while(spec != null)
		{
			newSpec = new Cons(cloneResult((Result)spec.car,
				compiler.datastack,compiler.callstack),
				newSpec);
			spec = spec.next();
		}
		return Cons.reverse(newSpec);
	} //}}}

	//{{{ commonAncestor() method
	private static Class commonAncestor(Class ca, Class cb)
	{
		if(ca.isAssignableFrom(cb))
			return ca;
		else if(cb.isAssignableFrom(ca))
			return cb;
		else if(ca.isInterface() || cb.isInterface())
			return Object.class;
		else
			return commonAncestor(ca.getSuperclass(),cb);
	} //}}}

	//{{{ unifyTypes() method
	private static Cons unifyTypes(FactorCompiler compiler,
		RecursiveState recursiveCheck,
		Cons a, Cons b)
	{
		Cons cons = null;

		for(;;)
		{
			if(a == null && b == null)
				return Cons.reverse(cons);

			int la, lb;
			Class ca, cb;

			if(a == null)
			{
				la = -1;
				ca = Object.class;
			}
			else
			{
				FlowObject fa = (FlowObject)a.car;
				la = fa.getLocal();
				ca = fa.getType();

				a = a.next();
			}

			if(b == null)
			{
				lb = -1;
				cb = Object.class;
			}
			else
			{
				FlowObject fb = (FlowObject)b.car;
				lb = fb.getLocal();
				//if(la != -1 && la != lb)
				//	System.err.println("? " + a + "," + b);
				cb = fb.getType();

				b = b.next();
			}

			//System.err.println("Common ancestor of " + ca + " and " + cb + " is " + commonAncestor(ca,cb));
			cons = new Cons(
				new Result(la,compiler,recursiveCheck.last(),
					commonAncestor(ca,cb)),cons);
		}
	} //}}}

	//{{{ mergeStacks() method
	private static void mergeStacks(FactorCompiler compiler,
		RecursiveState recursiveCheck,
		FactorArray s1, FactorArray s2,
		FactorArray into)
	{
		for(int i = Math.min(s1.top,s2.top) - 1; i >= 0; i--)
		{
			FlowObject fa = (FlowObject)s1.stack[s1.top - i - 1];
			FlowObject fb = (FlowObject)s2.stack[s2.top - i - 1];
			into.stack[into.top - i - 1]
				= new Result(i,compiler,recursiveCheck.last(),
				commonAncestor(fa.getType(),fb.getType()));
		}
	} //}}}

	//{{{ unifyStates() method
	public static void unifyStates(
		FactorCompiler compiler,
		RecursiveState recursiveCheck,
		FlowObject t, FlowObject f,
		CompilerState a, CompilerState b)
		throws Exception
	{
		StackEffect te = a.effect;
		StackEffect fe = b.effect;

		// we can only balance out a conditional if
		// both sides leave the same amount of elements
		// on the stack.
		// eg, 1/1 -vs- 2/2 is ok, 3/1 -vs- 4/2 is ok,
		// but 1/2 -vs- 2/1 is not.
		if(te.outD - te.inD != fe.outD - fe.inD
			|| te.outR - te.inR != fe.outR - fe.inR)
		{
			throw new FactorCompilerException(
				"Stack effect of " + t + " " + a.effect + " is inconsistent with " + f + " " + b.effect
				+ "\nRecursive state:\n"
				+ recursiveCheck);
		}

		compiler.ensure(compiler.datastack,Math.max(te.outD,fe.outD));
		compiler.ensure(compiler.callstack,Math.max(te.outR,fe.outR));

		// replace results from the f branch with
		// dummy values so that subsequent code
		// doesn't assume these values always
		// result from this

		mergeStacks(compiler,recursiveCheck,a.datastack,
			b.datastack,compiler.datastack);
		mergeStacks(compiler,recursiveCheck,a.callstack,
			b.callstack,compiler.callstack);

		compiler.inDtypes = unifyTypes(compiler,recursiveCheck,
			a.inDtypes,b.inDtypes);
		compiler.inRtypes = unifyTypes(compiler,recursiveCheck,
			a.inRtypes,b.inRtypes);
	} //}}}
}
