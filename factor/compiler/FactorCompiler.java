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
import org.objectweb.asm.util.*;

public class FactorCompiler implements Constants
{
	private FactorInterpreter interp;

	public final FactorWord word;
	public final String className;

	private int base;
	private int max;

	public FactorDataStack datastack;
	public FactorCallStack callstack;

	private int literalCount;

	private Map literals = new HashMap();

	public StackEffect effect = new StackEffect();

	//{{{ FactorCompiler constructor
	/**
	 * For balancing.
	 */
	public FactorCompiler()
	{
		this(null,null,null,0,0);
	} //}}}

	//{{{ FactorCompiler constructor
	/**
	 * For compiling.
	 */
	public FactorCompiler(FactorInterpreter interp,
		FactorWord word, String className,
		int base, int allot)
	{
		this.interp = interp;

		this.word = word;
		this.className = className;

		this.base = base;
		datastack = new FactorDataStack();
		callstack = new FactorCallStack();

		for(int i = 0; i < allot; i++)
		{
			datastack.push(new Result(base + i,this,null));
		}

		max = base + allot;
	} //}}}

	//{{{ ensure() method
	/**
	 * Ensure stack has at least 'count' elements.
	 * Eg, if count is 4 and stack is A B,
	 * stack will become RESULT RESULT A B.
	 * Used when deducing stack effects.
	 */
	public void ensure(FactorArrayStack stack, int count)
	{
		int top = stack.top;
		if(top < count)
		{
			if(stack == datastack)
				effect.inD += (count - top);
			else if(stack == callstack)
				effect.inR += (count - top);

			stack.ensurePush(count - top);
			System.arraycopy(stack.stack,0,stack.stack,
				count - top,top);
			for(int i = 0; i < count - top; i++)
			{
				stack.stack[i] = new Result(
					allocate(),this,null);
			}
			stack.top = count;
		}
	} //}}}

	//{{{ consume() method
	public void consume(FactorArrayStack stack, int count)
	{
		ensure(stack,count);
		stack.top -= count;
	} //}}}

	//{{{ produce() method
	public void produce(FactorArrayStack stack, int count)
	{
		for(int i = 0; i < count; i++)
			stack.push(new Result(allocate(),this,null));
	} //}}}

	//{{{ apply() method
	public void apply(StackEffect se)
	{
		consume(datastack,se.inD);
		produce(datastack,se.outD);
		consume(callstack,se.inR);
		produce(callstack,se.outR);
	} //}}}

	//{{{ getStackEffect() method
	public StackEffect getStackEffect()
	{
		effect.outD = datastack.top;
		effect.outR = callstack.top;
		return (StackEffect)effect.clone();
	} //}}}

	//{{{ getStackEffect() method
	public void getStackEffect(Cons definition,
		RecursiveState recursiveCheck)
		throws Exception
	{
		while(definition != null)
		{
			Object obj = definition.car;
			if(obj instanceof FactorWord)
			{
				FactorWord word = (FactorWord)obj;
				RecursiveForm rec = recursiveCheck.get(word);
				if(rec == null)
					recursiveCheck.add(word,getStackEffect());
				else
					rec.active = true;

				word.def.getStackEffect(recursiveCheck,this);

				if(rec == null)
					recursiveCheck.remove(word);
				else
					rec.active = false;
			}
			else
				pushLiteral(obj,recursiveCheck);

			definition = definition.next();
		}
	} //}}}

	//{{{ getDisassembly() method
	protected String getDisassembly(TraceCodeVisitor mw)
	{
		// Save the disassembly of the eval() method
		StringBuffer buf = new StringBuffer();
		Iterator bytecodes = mw.getText().iterator();
		while(bytecodes.hasNext())
		{
			buf.append(bytecodes.next());
		}
		return buf.toString();
	} //}}}

	//{{{ compile() method
	/**
	 * Compiles a method and returns the disassembly.
	 */
	public String compile(Cons definition, ClassWriter cw, String className,
		String methodName, StackEffect effect,
		RecursiveState recursiveCheck)
		throws Exception
	{
		String signature = effect.getCorePrototype();

		CodeVisitor _mw = cw.visitMethod(ACC_PUBLIC | ACC_STATIC,
			methodName,signature,null,null);

		TraceCodeVisitor mw = new TraceCodeVisitor(_mw);

		int maxJVMStack = compile(definition,mw,
			recursiveCheck);

		// special case where return value is passed on
		// JVM operand stack
		if(effect.outD == 0)
		{
			mw.visitInsn(RETURN);
		}
		else if(effect.outD == 1)
		{
			pop(mw);
			mw.visitInsn(ARETURN);
			maxJVMStack = Math.max(maxJVMStack,1);
		}
		else
		{
			// store datastack in a local
			mw.visitVarInsn(ALOAD,0);
			mw.visitFieldInsn(GETFIELD,
				"factor/FactorInterpreter",
				"datastack",
				"Lfactor/FactorDataStack;");
			int datastackLocal = allocate();
			mw.visitVarInsn(ASTORE,datastackLocal);

			for(int i = 0; i < datastack.top; i++)
			{
				mw.visitVarInsn(ALOAD,datastackLocal);
				((FlowObject)datastack.stack[i])
					.generate(mw);
				mw.visitMethodInsn(INVOKEVIRTUAL,
					"factor/FactorDataStack",
					"push",
					"(Ljava/lang/Object;)V");
			}

			datastack.top = 0;

			mw.visitInsn(RETURN);

			maxJVMStack = Math.max(2,maxJVMStack);
		}

		mw.visitMaxs(maxJVMStack,max);

		return getDisassembly(mw);
	} //}}}

	//{{{ compile() method
	/**
	 * Compiles a quotation and returns the maximum JVM stack depth.
	 */
	public int compile(Cons definition, CodeVisitor mw,
		RecursiveState recursiveCheck) throws Exception
	{
		int maxJVMStack = 0;

		while(definition != null)
		{
			Object obj = definition.car;
			if(obj instanceof FactorWord)
			{
				maxJVMStack = Math.max(maxJVMStack,
					compileWord((FactorWord)obj,mw,
					recursiveCheck));
			}
			else
				pushLiteral(obj,recursiveCheck);

			definition = definition.next();
		}

		return maxJVMStack;
	} //}}}

	//{{{ compileWord() method
	private int compileWord(FactorWord w, CodeVisitor mw,
		RecursiveState recursiveCheck) throws Exception
	{
		RecursiveForm rec = recursiveCheck.get(w);

		try
		{
			boolean recursiveCall;
			if(rec == null)
			{
				recursiveCall = false;
				recursiveCheck.add(w,null);
			}
			else
			{
				recursiveCall = true;
				rec.active = true;
			}

			FactorWordDefinition d = w.def;

			if(!recursiveCall)
			{
				StackEffect effect = getStackEffectOrNull(d);
				if(effect == null)
				{
					return d.compileImmediate(mw,this,
						recursiveCheck);
				}
				else if(d instanceof FactorCompoundDefinition)
				{
					w.compile(interp,recursiveCheck);
					if(d == w.def)
					{
						throw new FactorCompilerException(word + " depends on " + w + " which cannot be compiled");
					}
					d = w.def;
				}
			}

			w.compileRef = true;
			return d.compileCallTo(mw,this,recursiveCheck);
		}
		finally
		{
			if(rec == null)
				recursiveCheck.remove(w);
			else
				rec.active = false;
		}
	} //}}}

	//{{{ push() method
	/**
	 * Generates code for pushing the top of the JVM stack onto the
	 * data stack.
	 */
	public void push(CodeVisitor mw)
	{
		int local = allocate();
		datastack.push(new Result(local,this,null));
		if(mw != null)
			mw.visitVarInsn(ASTORE,local);
	} //}}}

	//{{{ pushR() method
	/**
	 * Generates code for pushing the top of the JVM stack onto the
	 * call stack.
	 */
	public void pushR(CodeVisitor mw)
	{
		int local = allocate();
		callstack.push(new Result(local,this,null));
		if(mw != null)
			mw.visitVarInsn(ASTORE,local);
	} //}}}

	//{{{ pushLiteral() method
	public void pushLiteral(Object literal, RecursiveState recursiveCheck)
	{
		if(literal == null)
			datastack.push(new Null(this,recursiveCheck));
		else if(literal instanceof Cons)
		{
			datastack.push(new CompiledList((Cons)literal,this,
				recursiveCheck));
		}
		else if(literal instanceof String)
		{
			datastack.push(new ConstantPoolString((String)literal,
				this,recursiveCheck));
		}
		else
		{
			datastack.push(new Literal(literal,this,
				recursiveCheck));
		}
	} //}}}

	//{{{ pushChoice() method
	public void pushChoice(RecursiveState recursiveCheck)
		throws FactorStackException
	{
		FlowObject f = (FlowObject)datastack.pop();
		FlowObject t = (FlowObject)datastack.pop();
		FlowObject cond = (FlowObject)datastack.pop();
		datastack.push(new CompiledChoice(
			cond,t,f,this,recursiveCheck));
	} //}}}

	//{{{ pop() method
	/**
	 * Generates code for popping the top of the data stack onto
	 * the JVM stack.
	 */
	public void pop(CodeVisitor mw) throws FactorStackException
	{
		FlowObject obj = (FlowObject)datastack.pop();
		if(mw != null)
			obj.generate(mw);
	} //}}}

	//{{{ popR() method
	/**
	 * Generates code for popping the top of the call stack onto
	 * the JVM stack.
	 */
	public void popR(CodeVisitor mw) throws FactorStackException
	{
		FlowObject obj = (FlowObject)callstack.pop();
		if(mw != null)
			obj.generate(mw);
	} //}}}

	//{{{ popLiteral() method
	/**
	 * Pops a literal off the datastack or throws an exception.
	 */
	public Object popLiteral() throws FactorException
	{
		FlowObject obj = (FlowObject)datastack.pop();
		return obj.getLiteral();
	} //}}}

	//{{{ allocate() method
	/**
	 * Allocate a local variable.
	 */
	public int allocate()
	{
		// inefficient!
		int i = base;
		for(;;)
		{
			if(allocate(i,datastack) && allocate(i,callstack))
			{
				max = Math.max(max,i + 1);
				return i;
			}
			else
				i++;
		}
	} //}}}

	//{{{ allocate() method
	/**
	 * Return true if not in use, false if in use.
	 */
	private boolean allocate(int local, FactorArrayStack stack)
	{
		for(int i = 0; i < stack.top; i++)
		{
			FlowObject obj = (FlowObject)stack.stack[i];
			if(obj.usingLocal(local))
				return false;
		}
		return true;
	} //}}}

	//{{{ literal() method
	public String literal(Object obj)
	{
		Integer i = (Integer)literals.get(obj);
		int literal;
		if(i == null)
		{
			literal = literalCount++;
			literals.put(obj,new Integer(literal));
		}
		else
			literal = i.intValue();

		return "literal_" + literal;
	} //}}}

	//{{{ generateArgs() method
	/**
	 * Generate instructions for copying arguments from the allocated
	 * local variables to the JVM stack, doing type conversion in the
	 * process.
	 */
	public void generateArgs(CodeVisitor mw, int num, Class[] args)
		throws Exception
	{
		for(int i = 0; i < num; i++)
		{
			FlowObject obj = (FlowObject)datastack.stack[
				datastack.top - num + i];
			obj.generate(mw);
			if(args != null)
				FactorJava.generateFromConversion(mw,args[i]);
		}

		datastack.top -= num;
	} //}}}

	//{{{ generateFields() method
	public void generateFields(ClassWriter cw)
		throws Exception
	{
		for(int i = 0; i < literalCount; i++)
		{
			cw.visitField(ACC_PUBLIC | ACC_STATIC,"literal_" + i,
				"Ljava/lang/Object;",null,null);
		}
	} //}}}

	//{{{ setFields() method
	public void setFields(Class def)
		throws Exception
	{
		Iterator entries = literals.entrySet().iterator();
		while(entries.hasNext())
		{
			Map.Entry entry = (Map.Entry)entries.next();
			Object literal = entry.getKey();
			int index = ((Integer)entry.getValue()).intValue();

			Field f = def.getField("literal_" + index);
			f.set(null,literal);
		}
	} //}}}

	//{{{ getStackEffectOrNull() method
	static StackEffect getStackEffectOrNull(FactorWordDefinition def)
	{
		try
		{
			return def.getStackEffect();
		}
		catch(Exception e)
		{
			//System.err.println("WARNING: " + e);
			//System.err.println(def);
			return null;
		}
	} //}}}

	//{{{ getStackEffectOrNull() method
	StackEffect getStackEffectOrNull(FlowObject obj,
		RecursiveState recursiveCheck,
		boolean decompose)
	{
		try
		{
			obj.getStackEffect(recursiveCheck);
			StackEffect effect = getStackEffect();
			if(decompose)
			{
				effect = StackEffect.decompose(
					recursiveCheck.last().effect,
					effect);
			}
			return effect;
		}
		catch(Exception e)
		{
			//System.err.println("WARNING: " + e);
			//System.err.println(obj);
			return null;
		}
	} //}}}
}
