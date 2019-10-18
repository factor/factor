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
	public String method;

	private int base;
	private int max;
	private int allotD;
	private int allotR;

	public FactorDataStack datastack;
	public FactorCallStack callstack;

	private int literalCount;

	private Map literals;

	public StackEffect effect;

	private Cons aux;
	private int auxCount;

	//{{{ FactorCompiler constructor
	/**
	 * For balancing.
	 */
	public FactorCompiler()
	{
		this(null,null,null);
		init(0,0,0,null);
	} //}}}

	//{{{ FactorCompiler constructor
	/**
	 * For compiling.
	 */
	public FactorCompiler(FactorInterpreter interp,
		FactorWord word, String className)
	{
		this.interp = interp;

		this.word = word;
		this.className = className;

		literals = new HashMap();

		datastack = new FactorDataStack();
		callstack = new FactorCallStack();
	} //}}}

	//{{{ getInterpreter() method
	public FactorInterpreter getInterpreter()
	{
		return interp;
	} //}}}

	//{{{ init() method
	public void init(int base, int allotD, int allotR, String method)
	{
		effect = new StackEffect();

		this.base = base;

		datastack.top = 0;
		callstack.top = 0;

		for(int i = 0; i < allotD; i++)
			datastack.push(new Result(base + i,this,null));

		for(int i = 0; i < allotR; i++)
			datastack.push(new Result(base + allotD + i,this,null));

		max = base + allotD + allotR;

		this.allotD = allotD;
		this.allotR = allotR;
		effect.inD = allotD;
		effect.inR = allotR;

		this.method = method;
	} //}}}

	//{{{ getAllotedEffect() method
	public StackEffect getAllotedEffect()
	{
		return new StackEffect(allotD,allotR,0,0);
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
				int local = allocate();
				stack.stack[i] = new Result(
					local,this,null);
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
		{
			int local = allocate();
			stack.push(new Result(local,this,null));
		}
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
				getStackEffectOfWord((FactorWord)obj,recursiveCheck);
			else
				pushLiteral(obj,recursiveCheck);

			definition = definition.next();
		}
	} //}}}

	//{{{ getStackEffectOfWord() method
	private void getStackEffectOfWord(FactorWord word,
		RecursiveState recursiveCheck)
		throws Exception
	{
		RecursiveForm rec = recursiveCheck.get(word);
		if(rec == null)
		{
			recursiveCheck.add(word,getStackEffect(),null,null);
		}
		else
			rec.active = true;

		word.def.getStackEffect(recursiveCheck,this);

		if(rec == null)
		{
			recursiveCheck.remove(word);
		}
		else
			rec.active = false;
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

	//{{{ compileCore() method
	public String compileCore(Cons definition, ClassWriter cw,
		StackEffect effect, RecursiveState recursiveCheck)
		throws Exception
	{
		RecursiveForm last = recursiveCheck.last();
		last.method = "core";
		last.className = className;

		String asm = compile(definition,cw,"core",
			effect,recursiveCheck);

		return asm;
	} //}}}

	//{{{ compile() method
	/**
	 * Compiles a method and returns the disassembly.
	 */
	public String compile(Cons definition, ClassWriter cw,
		String methodName, StackEffect effect,
		RecursiveState recursiveCheck)
		throws Exception
	{
		String signature = effect.getCorePrototype();

		CodeVisitor _mw = cw.visitMethod(ACC_PUBLIC | ACC_STATIC,
			methodName,signature,null,null);

		TraceCodeVisitor mw = new TraceCodeVisitor(_mw);

		Label start = recursiveCheck.last().label;

		mw.visitLabel(start);

		int maxJVMStack = compile(definition,mw,
			recursiveCheck);

		Label end = new Label();

		// special case where return value is passed on
		// JVM operand stack

		// note: in each branch, must visit end label before RETURN!
		if(effect.outD == 0 && effect.outR == 0)
		{
			mw.visitLabel(end);
			mw.visitInsn(RETURN);
		}
		else if(effect.outD == 1 && effect.outR == 0)
		{
			pop(mw);
			mw.visitLabel(end);
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

			// store callstack in a local
			mw.visitVarInsn(ALOAD,0);
			mw.visitFieldInsn(GETFIELD,
				"factor/FactorInterpreter",
				"callstack",
				"Lfactor/FactorCallStack;");
			int callstackLocal = allocate();
			mw.visitVarInsn(ASTORE,callstackLocal);

			for(int i = 0; i < callstack.top; i++)
			{
				mw.visitVarInsn(ALOAD,callstackLocal);
				((FlowObject)callstack.stack[i])
					.generate(mw);
				mw.visitMethodInsn(INVOKEVIRTUAL,
					"factor/FactorCallStack",
					"push",
					"(Ljava/lang/Object;)V");
			}

			callstack.top = 0;

			mw.visitLabel(end);
			mw.visitInsn(RETURN);

			maxJVMStack = Math.max(2,maxJVMStack);
		}

		// Now compile exception handler.

		Label target = new Label();
		mw.visitLabel(target);

		mw.visitVarInsn(ASTORE,1);
		mw.visitVarInsn(ALOAD,0);
		mw.visitFieldInsn(GETSTATIC,className,literal(
			recursiveCheck.last().word),
			"Ljava/lang/Object;");
		mw.visitTypeInsn(CHECKCAST,"factor/FactorWord");
		mw.visitVarInsn(ALOAD,1);

		mw.visitMethodInsn(INVOKEVIRTUAL,"factor/FactorInterpreter",
			"compiledException",
			"(Lfactor/FactorWord;Ljava/lang/Throwable;)V");

		mw.visitVarInsn(ALOAD,1);
		mw.visitInsn(ATHROW);

		maxJVMStack = Math.max(maxJVMStack,3);
		mw.visitMaxs(maxJVMStack,max);

		mw.visitTryCatchBlock(start,end,target,"java/lang/Throwable");
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
				FactorWord w = (FactorWord)obj;

				RecursiveForm rec = recursiveCheck.get(w);

				try
				{
					boolean recursiveCall;
					if(rec == null)
					{
						recursiveCall = false;
						recursiveCheck.add(w,
							new StackEffect()/* getStackEffect() */,
							className,"core");
						recursiveCheck.last().tail = false;
					}
					else
					{
						recursiveCall = true;
						rec.active = true;
						rec.tail = (definition.cdr == null);
					}

					maxJVMStack = Math.max(maxJVMStack,
						compileWord((FactorWord)obj,mw,
						recursiveCheck,recursiveCall));
				}
				finally
				{
					if(rec == null)
						recursiveCheck.remove(w);
					else
					{
						rec.active = false;
						rec.tail = false;
					}
				}
			}
			else
				pushLiteral(obj,recursiveCheck);

			definition = definition.next();
		}

		return maxJVMStack;
	} //}}}

	//{{{ compileWord() method
	private int compileWord(FactorWord w, CodeVisitor mw,
		RecursiveState recursiveCheck,
		boolean recursiveCall) throws Exception
	{
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

	//{{{ auxiliary() method
	public String auxiliary(String word, Cons code, StackEffect effect,
		RecursiveState recursiveCheck) throws Exception
	{
		FactorDataStack savedDatastack = (FactorDataStack)
			datastack.clone();
		FactorCallStack savedCallstack = (FactorCallStack)
			callstack.clone();

		String method = "aux_" + FactorJava.getSanitizedName(word) + "_"
			+ (auxCount++);

		recursiveCheck.last().method = method;
		aux = new Cons(new AuxiliaryQuotation(
			method,savedDatastack,savedCallstack,
			code,effect,this,recursiveCheck),aux);

		return method;
	} //}}}

	//{{{ generateAuxiliary() method
	public String generateAuxiliary(ClassWriter cw)
		throws Exception
	{
		StringBuffer asm = new StringBuffer();
		while(aux != null)
		{
			AuxiliaryQuotation q = (AuxiliaryQuotation)aux.car;
			aux = aux.next();
			asm.append(q);
			asm.append('\n');
			asm.append(q.compile(this,cw,word));
		}
		return asm.toString();
	} //}}}

	//{{{ normalizeStacks() method
	public int normalizeStacks(CodeVisitor mw)
	{
		int datastackTop = datastack.top;
		datastack.top = 0;
		int callstackTop = callstack.top;
		callstack.top = 0;

		localsToStack(callstack,callstackTop,mw);
		localsToStack(datastack,datastackTop,mw);
		stackToLocals(datastack,datastackTop,mw);
		stackToLocals(callstack,callstackTop,mw);

		return datastackTop + callstackTop;
	} //}}}

	//{{{ localsToStack() method
	private void localsToStack(FactorArrayStack stack, int top,
		CodeVisitor mw)
	{
		for(int i = top - 1; i >= 0; i--)
		{
			FlowObject obj = (FlowObject)stack.stack[i];
			obj.generate(mw);
		}
	} //}}}

	//{{{ stackToLocals() method
	private void stackToLocals(FactorArrayStack stack, int top,
		CodeVisitor mw)
	{
		for(int i = 0; i < top; i++)
		{
			int local = allocate();
			stack.push(new Result(local,this,null));
			mw.visitVarInsn(ASTORE,local);
		}
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
			int local = allocate();
			stack.push(new Result(local,this,null));
			mw.visitVarInsn(ASTORE,local);
		}
	} //}}}

	//{{{ generateArgs() method
	/**
	 * Generate instructions for copying arguments from the allocated
	 * local variables to the JVM stack, doing type conversion in the
	 * process.
	 */
	public void generateArgs(CodeVisitor mw, int inD, int inR, Class[] args)
		throws Exception
	{
		for(int i = 0; i < inD; i++)
		{
			FlowObject obj = (FlowObject)datastack.stack[
				datastack.top - inD + i];
			obj.generate(mw);
			if(args != null)
				FactorJava.generateFromConversion(mw,args[i]);
		}

		datastack.top -= inD;

		for(int i = 0; i < inR; i++)
		{
			FlowObject obj = (FlowObject)callstack.stack[
				callstack.top - inR + i];
			obj.generate(mw);
			if(args != null)
				FactorJava.generateFromConversion(mw,args[i]);
		}

		callstack.top -= inR;
	} //}}}

	//{{{ generateReturn() method
	public void generateReturn(CodeVisitor mw, int outD, int outR)
	{
		if(outD == 0 && outR == 0)
		{
			// do nothing
		}
		else if(outD == 1 && outR == 0)
		{
			push(mw);
		}
		else
		{
			// transfer from data stack to JVM locals

			// allocate the appropriate number of locals

			if(outD != 0)
			{
				produce(datastack,outD);

				// store the datastack instance somewhere
				mw.visitVarInsn(ALOAD,0);
				mw.visitFieldInsn(GETFIELD,
					"factor/FactorInterpreter",
					"datastack",
					"Lfactor/FactorDataStack;");
				int datastackLocal = allocate();
				mw.visitVarInsn(ASTORE,datastackLocal);
	
				// put all elements from the real datastack
				// into locals
				for(int i = 0; i < outD; i++)
				{
					mw.visitVarInsn(ALOAD,datastackLocal);
					mw.visitMethodInsn(INVOKEVIRTUAL,
						"factor/FactorDataStack",
						"pop",
						"()Ljava/lang/Object;");
	
					Result destination = (Result)
						datastack.stack[
						datastack.top - i - 1];
	
					mw.visitVarInsn(ASTORE,destination.getLocal());
				}
			}

			if(outR != 0)
			{
				produce(callstack,outR);

				mw.visitVarInsn(ALOAD,0);
				mw.visitFieldInsn(GETFIELD,
					"factor/FactorInterpreter",
					"callstack",
					"Lfactor/FactorCallStack;");
				int callstackLocal = allocate();
				mw.visitVarInsn(ASTORE,callstackLocal);

				// put all elements from the real callstack
				// into locals
				for(int i = 0; i < outR; i++)
				{
					mw.visitVarInsn(ALOAD,callstackLocal);
					mw.visitMethodInsn(INVOKEVIRTUAL,
						"factor/FactorCallStack",
						"pop",
						"()Ljava/lang/Object;");
	
					Result destination = (Result)
						callstack.stack[
						callstack.top - i - 1];
	
					mw.visitVarInsn(ASTORE,destination.getLocal());
				}
			}
		}
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

		CodeVisitor mw = cw.visitMethod(ACC_PUBLIC | ACC_STATIC,
			"setFields","(Lfactor/FactorInterpreter;)V",null,null);

		Iterator entries = literals.entrySet().iterator();
		while(entries.hasNext())
		{
			Map.Entry entry = (Map.Entry)entries.next();
			Object literal = entry.getKey();
			int index = ((Integer)entry.getValue()).intValue();

			generateParse(mw,literal,0);
			mw.visitFieldInsn(PUTSTATIC,
				className,
				"literal_" + index,
				"Ljava/lang/Object;");
		}

		mw.visitInsn(RETURN);

		mw.visitMaxs(2,1);
	} //}}}

	//{{{ generateParse() method
	public void generateParse(CodeVisitor mw, Object obj, int interpLocal)
	{
		mw.visitLdcInsn(FactorReader.unparseObject(obj));
		mw.visitVarInsn(ALOAD,interpLocal);
		mw.visitMethodInsn(INVOKESTATIC,
			"factor/FactorReader",
			"parseObject",
			"(Ljava/lang/String;Lfactor/FactorInterpreter;)"
			+ "Ljava/lang/Object;");
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
