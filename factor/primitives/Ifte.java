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

package factor.primitives;

import factor.compiler.*;
import factor.db.*;
import factor.*;
import org.objectweb.asm.*;

public class Ifte extends FactorPrimitiveDefinition
{
	//{{{ Ifte constructor
	/**
	 * A new definition.
	 */
	public Ifte(FactorWord word, Workspace workspace)
		throws Exception
	{
		super(word,workspace);
	} //}}}

	//{{{ Ifte constructor
	/**
	 * A blank definition, about to be unpickled.
	 */
	public Ifte(Workspace workspace, long id)
		throws Exception
	{
		super(workspace,id);
	} //}}}

	//{{{ eval() method
	public void eval(FactorInterpreter interp)
		throws Exception
	{
		FactorArray datastack = interp.datastack;
		Cons f = (Cons)datastack.pop();
		Cons t = (Cons)datastack.pop();
		Object cond = datastack.pop();
		if(FactorJava.toBoolean(cond))
			interp.call(t);
		else
			interp.call(f);
	} //}}}

	//{{{ getStackEffect() method
	public void getStackEffect(RecursiveState recursiveCheck,
		FactorCompiler compiler) throws Exception
	{
		compiler.ensure(compiler.datastack,Cons.class);

		boolean fPossiblyRecursive = false;
		FlowObject f = (FlowObject)compiler.datastack.pop();
		compiler.ensure(compiler.datastack,Cons.class);

		boolean tPossiblyRecursive = false;
		FlowObject t = (FlowObject)compiler.datastack.pop();
		compiler.ensure(compiler.datastack,Object.class);
		FlowObject cond = (FlowObject)compiler.datastack.pop();

		CompilerState savedState = new CompilerState(compiler);

		try
		{
			t.compileCallTo(null,recursiveCheck);
		}
		catch(Exception e)
		{
			tPossiblyRecursive = true;
		}

		CompilerState tState = new CompilerState(compiler);

		savedState.restore(compiler);

		try
		{
			f.compileCallTo(null,recursiveCheck);
		}
		catch(Exception e)
		{
			fPossiblyRecursive = true;
		}

		CompilerState fState = new CompilerState(compiler);

		if(!fPossiblyRecursive && tPossiblyRecursive)
		{
			RecursiveForm rec = t.getWord();
			rec.baseCase = fState.effect;
			savedState.restore(compiler);
			t.compileCallTo(null,recursiveCheck);
			tState = new CompilerState(compiler);
		}
		else if(fPossiblyRecursive && !tPossiblyRecursive)
		{
			RecursiveForm rec = f.getWord();
			rec.baseCase = tState.effect;
			savedState.restore(compiler);
			f.compileCallTo(null,recursiveCheck);
			fState = new CompilerState(compiler);
		}
		else if(fPossiblyRecursive && tPossiblyRecursive)
			throw new FactorCompilerException("Indeterminate ifte effect\ntrue branch: " + t + "\nfalse branch: " + f);

		CompilerState.unifyStates(compiler,recursiveCheck,t,f,tState,fState);
	} //}}}

	//{{{ compileNonRecursiveImmediate() method
	/**
	 * Non-recursive immediate words are inlined.
	 */
	protected void compileNonRecursiveImmediate(CodeVisitor mw,
		FactorCompiler compiler,
		RecursiveState recursiveCheck,
		StackEffect immediateEffect) throws Exception
	{
		if(mw == null)
			compiler.ensure(compiler.datastack,Cons.class);
		FlowObject f = (FlowObject)compiler.datastack.pop();
		if(mw == null)
			compiler.ensure(compiler.datastack,Cons.class);
		FlowObject t = (FlowObject)compiler.datastack.pop();
		if(mw == null)
			compiler.ensure(compiler.datastack,Object.class);
		FlowObject cond = (FlowObject)compiler.datastack.pop();

		// if null jump to F
		// T
		// jump END
		// F: F
		// END: ...
		Label fl = new Label();
		Label endl = new Label();

		cond.pop(mw,Object.class);

		mw.visitJumpInsn(IFNULL,fl);

		FactorArray datastackCopy = (FactorArray)
			compiler.datastack.clone();
		FactorArray callstackCopy = (FactorArray)
			compiler.callstack.clone();

		t.compileCallTo(mw,recursiveCheck);

		compiler.normalizeStacks(mw);

		compiler.datastack = datastackCopy;
		compiler.callstack = callstackCopy;

		mw.visitJumpInsn(GOTO,endl);
		mw.visitLabel(fl);
		f.compileCallTo(mw,recursiveCheck);

		compiler.normalizeStacks(mw);

		mw.visitLabel(endl);
	} //}}}

	//{{{ compileRecursiveImmediate() method
	/**
	 * Recursive immediate words are compiled to an auxiliary method
	 * inside the compiled class definition.
	 *
	 * This must be done so that recursion has something to jump to.
	 */
	protected void compileRecursiveImmediate(CodeVisitor mw,
		FactorCompiler compiler,
		RecursiveState recursiveCheck,
		StackEffect immediateEffect) throws Exception
	{
		throw new FactorCompilerException("ifte is not recursive");
	} //}}}
}
