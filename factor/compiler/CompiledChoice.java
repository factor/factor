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
import java.lang.reflect.*;
import java.util.*;
import org.objectweb.asm.*;

public class CompiledChoice extends FlowObject implements Constants
{
	FlowObject cond, t, f;

	//{{{ CompiledChoice constructor
	CompiledChoice(FlowObject cond, FlowObject t, FlowObject f,
		FactorCompiler compiler, RecursiveState recursiveCheck)
	{
		super(compiler,recursiveCheck);
		this.cond = cond;
		this.t = t;
		this.f = f;
	} //}}}

	//{{{ generate() method
	public void generate(CodeVisitor mw)
	{
		// if null jump to F
		// T
		// jump END
		// F: F
		// END: ...
		Label fl = new Label();
		Label endl = new Label();

		cond.generate(mw);
		mw.visitJumpInsn(IFNULL,fl);

		t.generate(mw);

		mw.visitJumpInsn(GOTO,endl);
		mw.visitLabel(fl);
		f.generate(mw);
		mw.visitLabel(endl);
	} //}}}

	//{{{ usingLocal() method
	boolean usingLocal(int local)
	{
		return cond.usingLocal(local)
			|| t.usingLocal(local)
			|| f.usingLocal(local);
	} //}}}

	//{{{ getStackEffect() method
	/**
	 * Stack effect of executing this -- only used for lists
	 * and conditionals!
	 */
	public void getStackEffect(RecursiveState recursiveCheck)
		throws Exception
	{
		StackEffect onEntry = recursiveCheck.last().effect;

		FactorDataStack datastackCopy = (FactorDataStack)
			compiler.datastack.clone();
		FactorCallStack callstackCopy = (FactorCallStack)
			compiler.callstack.clone();
		StackEffect effectCopy = (StackEffect)
			compiler.getStackEffect();

		StackEffect te = compiler.getStackEffectOrNull(
			t,recursiveCheck,false);
		//System.err.println("te=" + te);

		/** Other branch. */
		FactorDataStack obDatastack = compiler.datastack;
		FactorCallStack obCallstack = compiler.callstack;
		StackEffect obEffect = compiler.getStackEffect();

		compiler.datastack = (FactorDataStack)
			datastackCopy.clone();
		compiler.callstack = (FactorCallStack)
			callstackCopy.clone();
		compiler.effect = (StackEffect)effectCopy.clone();

		StackEffect fe = compiler.getStackEffectOrNull(
			f,recursiveCheck,false);
		//System.err.println("fe=" + fe);

		//System.err.println("rec=" + rec);
		if(fe != null && te == null)
		{
			RecursiveForm rec = t.getWord();
			if(rec == null)
				throw new FactorCompilerException("Unscoped quotation: " + t);
			rec.baseCase = fe;
			//System.err.println("base=" + fe);
			compiler.datastack = (FactorDataStack)
				datastackCopy.clone();
			compiler.callstack = (FactorCallStack)
				callstackCopy.clone();
			compiler.effect = (StackEffect)
				effectCopy.clone();
			t.getStackEffect(recursiveCheck);
			te = compiler.getStackEffect();
			//te = StackEffect.decompose(onEntry,te);
			//System.err.println("te=" + te);
		}
		else if(fe == null && te != null)
		{
			RecursiveForm rec = f.getWord();
			if(rec == null)
				throw new FactorCompilerException("Unscoped quotation: " + t);
			//System.err.println("base=" + te);
			rec.baseCase = te;
			compiler.datastack = (FactorDataStack)
				datastackCopy.clone();
			compiler.callstack = (FactorCallStack)
				callstackCopy.clone();
			compiler.effect = (StackEffect)
				effectCopy.clone();
			f.getStackEffect(recursiveCheck);
			fe = compiler.getStackEffect();
			//fe = StackEffect.decompose(onEntry,te);
			//System.err.println("fe=" + fe);
		}

		if(te == null || fe == null)
			throw new FactorCompilerException("Indeterminate recursive choice");

		// we can only balance out a conditional if
		// both sides leave the same amount of elements
		// on the stack.
		// eg, 1/1 -vs- 2/2 is ok, 3/1 -vs- 4/2 is ok,
		// but 1/2 -vs- 2/1 is not.
		int balanceTD = te.outD - te.inD;
		int balanceTR = te.outR - te.inR;
		int balanceFD = fe.outD - fe.inD;
		int balanceFR = fe.outR - fe.inR;
		if(balanceTD != balanceFD || balanceTR != balanceFR)
		{
			throw new FactorCompilerException("Stack effect of " + t + " " + te + " is inconsistent with " + f + " " + fe + ", head is " + effectCopy);
		}

		// find how many elements of the t branch match with the f
		// branch and don't discard those.
		int highestEqual = 0;

		for(highestEqual = 0; highestEqual < fe.outD; highestEqual++)
		{
			Object o1 = obDatastack.stack[
				obDatastack.top - highestEqual - 1];
			Object o2 = compiler.datastack.stack[
				obDatastack.top - highestEqual - 1];
			if(!o1.equals(o2))
				break;
		}

		// replace results from the f branch with
		// dummy values so that subsequent code
		// doesn't assume these values always
		// result from this
		compiler.datastack.top -= fe.outD;
		compiler.produce(compiler.datastack,fe.outD - highestEqual);
		compiler.datastack.top += highestEqual;
		compiler.callstack.top -= fe.outR;
		compiler.produce(compiler.callstack,fe.outR);

		compiler.effect = new StackEffect(
			Math.max(te.inD,fe.inD),
			Math.max(te.outD,fe.outD),
			Math.max(te.inR,fe.inR),
			Math.max(te.outR,fe.outR)
		);
	} //}}}

	//{{{ compileCallTo() method
	/**
	 * Write code for evaluating this. Returns maximum JVM stack
	 * usage.
	 */
	public int compileCallTo(CodeVisitor mw, RecursiveState recursiveCheck)
		throws Exception
	{
		// if null jump to F
		// T
		// jump END
		// F: F
		// END: ...
		Label fl = new Label();
		Label endl = new Label();

		cond.generate(mw);

		int maxJVMStack = 1;

		/* if(t instanceof Null && f instanceof Null)
		{
			// nothing to do!
			mw.visitInsn(POP);
		}
		else if(t instanceof Null)
		{
			mw.visitJumpInsn(IFNONNULL,endl);
			maxJVMStack = Math.max(maxJVMStack,
				f.compileCallTo(mw,recursiveCheck));
			mw.visitLabel(endl);
		}
		else if(f instanceof Null)
		{
			mw.visitJumpInsn(IFNULL,endl);
			maxJVMStack = Math.max(maxJVMStack,
				t.compileCallTo(mw,recursiveCheck));
			mw.visitLabel(endl);
		}
		else */
		{
			mw.visitJumpInsn(IFNULL,fl);

			FactorDataStack datastackCopy
				= (FactorDataStack)
				compiler.datastack.clone();
			FactorCallStack callstackCopy
				= (FactorCallStack)
				compiler.callstack.clone();

			maxJVMStack = Math.max(maxJVMStack,
				t.compileCallTo(mw,recursiveCheck));

			maxJVMStack = Math.max(maxJVMStack,
				normalizeStacks(mw));

			compiler.datastack = datastackCopy;
			compiler.callstack = callstackCopy;

			mw.visitJumpInsn(GOTO,endl);
			mw.visitLabel(fl);
			maxJVMStack = Math.max(maxJVMStack,
				f.compileCallTo(mw,recursiveCheck));

			maxJVMStack = Math.max(maxJVMStack,
				normalizeStacks(mw));

			mw.visitLabel(endl);
		}

		return maxJVMStack;
	} //}}}

	//{{{ normalizeStacks() method
	private int normalizeStacks(CodeVisitor mw)
	{
		int datastackTop = compiler.datastack.top;
		compiler.datastack.top = 0;
		int callstackTop = compiler.callstack.top;
		compiler.callstack.top = 0;

		normalizeStack(compiler.datastack,datastackTop,mw);
		normalizeStack(compiler.callstack,callstackTop,mw);
		return Math.max(datastackTop,callstackTop);
	} //}}}

	//{{{ normalizeStack() method
	private void normalizeStack(FactorArrayStack stack, int top,
		CodeVisitor mw)
	{
		for(int i = top - 1; i >= 0; i--)
		{
			FlowObject obj = (FlowObject)stack.stack[i];
			obj.generate(mw);
		}

		for(int i = 0; i < top; i++)
		{
			int local = compiler.allocate();
			stack.push(new Result(local,compiler,null));
			mw.visitVarInsn(ASTORE,local);
		}
	} //}}}

	//{{{ toString() method
	public String toString()
	{
		return FactorParser.unparse(f)
			+ " "
			+ FactorParser.unparse(t)
			+ " ? call";
	} //}}}
}
