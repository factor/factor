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

public class LocalAllocator implements Constants
{
	private FactorInterpreter interp;

	private String className;
	private int base;
	private int max;

	public FactorDataStack datastack;
	public FactorCallStack callstack;

	private int literalCount;
	private int wordCount;

	private Map literals = new HashMap();
	private Map words = new HashMap();

	//{{{ LocalAllocator constructor
	/**
	 * For balancing.
	 */
	public LocalAllocator()
	{
		this(null,null,0,0);
	} //}}}

	//{{{ LocalAllocator constructor
	/**
	 * For compiling.
	 */
	public LocalAllocator(FactorInterpreter interp, String className,
		int base, int allot)
	{
		this.interp = interp;
		this.className = className;

		this.base = base;
		datastack = new FactorDataStack();
		callstack = new FactorCallStack();

		for(int i = 0; i < allot; i++)
		{
			datastack.push(new Result(base + i));
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
			stack.ensurePush(count - top);
			System.arraycopy(stack.stack,0,stack.stack,
				count - top,top);
			for(int i = 0; i < count - top; i++)
			{
				stack.stack[i] = new Result(allocate());
			}
			stack.top = count;
		}
	} //}}}

	//{{{ compile() method
	/**
	 * Compiles a quotation and returns the maximum JVM stack depth.
	 */
	public int compile(Cons definition, CodeVisitor mw,
		Set recursiveCheck) throws Exception
	{
		int maxJVMStack = 0;

		while(definition != null)
		{
			Object obj = definition.car;
			if(obj instanceof FactorWord)
			{
				FactorWord w = (FactorWord)obj;

				FactorWordDefinition d = w.def;
				if(d instanceof FactorCompoundDefinition
					&& d.getStackEffect(recursiveCheck,
					new LocalAllocator()) != null)
				{
					// compile first.
					w.compile(interp,recursiveCheck);
					if(w.def == d)
					{
						// didn't compile
						throw new FactorCompilerException(w + " cannot be compiled");
					}
				}

				maxJVMStack = Math.max(maxJVMStack,
					w.def.compileCallTo(mw,this,recursiveCheck));
			}
			else if(obj == null)
			{
				pushNull();
			}
			else if(obj instanceof String)
			{
				pushString((String)obj);
			}
			else
			{
				pushLiteral(obj);
			}

			definition = definition.next();
		}

		return maxJVMStack;
	} //}}}

	//{{{ push() method
	/**
	 * Generates code for pushing the top of the JVM stack onto the
	 * data stack.
	 */
	public void push(CodeVisitor mw)
	{
		int local = allocate();
		datastack.push(new Result(local));
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
		callstack.push(new Result(local));
		if(mw != null)
			mw.visitVarInsn(ASTORE,local);
	} //}}}

	//{{{ pushLiteral() method
	public void pushLiteral(Object literal)
	{
		datastack.push(new Literal(literal));
	} //}}}

	//{{{ pushString() method
	public void pushString(String literal)
	{
		datastack.push(new ConstantPoolString(literal));
	} //}}}

	//{{{ pushNull() method
	public void pushNull()
	{
		datastack.push(new Null());
	} //}}}

	//{{{ pushChoice() method
	public void pushChoice() throws FactorStackException
	{
		FlowObject f = (FlowObject)datastack.pop();
		FlowObject t = (FlowObject)datastack.pop();
		FlowObject cond = (FlowObject)datastack.pop();
		datastack.push(new Choice(cond,t,f));
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
	private int allocate()
	{
		// inefficient!
		int limit = base + datastack.top + callstack.top;
		for(int i = base; i <= limit; i++)
		{
			if(allocate(i,datastack) && allocate(i,callstack))
			{
				max = Math.max(max,i + 1);
				return i;
			}
		}
		// this is impossible
		throw new RuntimeException("allocator failed");
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

	//{{{ maxLocals() method
	public int maxLocals()
	{
		return max;
	} //}}}

	//{{{ literal() method
	private String literal(Object obj)
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

		Iterator entries = words.entrySet().iterator();
		while(entries.hasNext())
		{
			Map.Entry entry = (Map.Entry)entries.next();
			FactorWord word = (FactorWord)entry.getKey();
			int index = ((Integer)entry.getValue()).intValue();

			cw.visitField(ACC_PUBLIC | ACC_STATIC,"word_" + index,
				FactorJava.javaClassToVMClass(word.def.getClass()),
				null,null);
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

		entries = words.entrySet().iterator();
		while(entries.hasNext())
		{
			Map.Entry entry = (Map.Entry)entries.next();
			FactorWord word = (FactorWord)entry.getKey();
			int index = ((Integer)entry.getValue()).intValue();

			Field f = def.getField("word_" + index);
			System.err.println(word.def.getClass() + " ==> " + "word_" + index);
			f.set(null,word.def);
		}
	} //}}}

	//{{{ FlowObject
	public abstract class FlowObject
	{
		abstract void generate(CodeVisitor mw);

		boolean usingLocal(int local)
		{
			return false;
		}

		Object getLiteral()
			throws FactorCompilerException
		{
			throw new FactorCompilerException("Cannot compile unless literal on stack");
		}

		/**
		 * Stack effect of evaluating this -- only used for lists
		 * and conditionals!
		 */
		public StackEffect getStackEffect(Set recursiveCheck)
			throws Exception
		{

			return null;
		}

		/**
		 * Write code for evaluating this. Returns maximum JVM stack
		 * usage.
		 */
		public int compileCallTo(CodeVisitor mw, Set recursiveCheck)
			throws Exception
		{
			throw new FactorCompilerException("Cannot compile call to non-literal quotation");
		}
	} //}}}

	//{{{ Result
	class Result extends FlowObject
	{
		private int local;

		Result(int local)
		{
			this.local = local;
		}

		void generate(CodeVisitor mw)
		{
			mw.visitVarInsn(ALOAD,local);
		}

		boolean usingLocal(int local)
		{
			return (this.local == local);
		}
	} //}}}

	//{{{ Literal
	class Literal extends FlowObject
	{
		private Object literal;

		Literal(Object literal)
		{
			this.literal = literal;
		}

		void generate(CodeVisitor mw)
		{
			mw.visitFieldInsn(GETSTATIC,className,
				literal(literal),"Ljava/lang/Object;");
		}

		Object getLiteral()
		{
			return literal;
		}

		/**
		 * Stack effect of executing this -- only used for lists
		 * and conditionals!
		 */
		public StackEffect getStackEffect(Set recursiveCheck)
			throws Exception
		{
			if(literal instanceof Cons
				|| literal == null)
			{
				return StackEffect.getStackEffect(
					(Cons)literal,recursiveCheck,
					LocalAllocator.this);
			}
			else
				return null;
		}

		/**
		 * Write code for evaluating this. Returns maximum JVM stack
		 * usage.
		 */
		public int compileCallTo(CodeVisitor mw, Set recursiveCheck)
			throws Exception
		{
			if(literal instanceof Cons || literal == null)
				return compile((Cons)literal,mw,recursiveCheck);
			else
				throw new FactorCompilerException("Not a quotation: " + literal);
		}
	} //}}}

	//{{{ ConstantPoolString
	class ConstantPoolString extends FlowObject
	{
		private String str;

		ConstantPoolString(String str)
		{
			this.str = str;
		}

		void generate(CodeVisitor mw)
		{
			mw.visitLdcInsn(str);
		}

		Object getLiteral()
		{
			return str;
		}
	} //}}}

	//{{{ Null
	class Null extends FlowObject
	{
		void generate(CodeVisitor mw)
		{
			mw.visitInsn(ACONST_NULL);
		}

		Object getLiteral()
		{
			return null;
		}

		/**
		 * Stack effect of executing this -- only used for lists
		 * and conditionals!
		 */
		public StackEffect getStackEffect(Set recursiveCheck)
		{
			return new StackEffect(0,0,0,0);
		}

		/**
		 * Write code for evaluating this. Returns maximum JVM stack
		 * usage.
		 */
		public int compileCallTo(CodeVisitor mw, Set recursiveCheck)
			throws Exception
		{
			return 0;
		}
	} //}}}

	//{{{ Choice
	class Choice extends FlowObject
	{
		FlowObject cond, t, f;

		Choice(FlowObject cond, FlowObject t, FlowObject f)
		{
			this.cond = cond;
			this.t = t;
			this.f = f;
		}

		void generate(CodeVisitor mw)
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
		}

		boolean usingLocal(int local)
		{
			return cond.usingLocal(local)
				|| t.usingLocal(local)
				|| f.usingLocal(local);
		}

		/**
		 * Stack effect of executing this -- only used for lists
		 * and conditionals!
		 */
		public StackEffect getStackEffect(Set recursiveCheck)
			throws Exception
		{
			FactorDataStack datastackCopy = (FactorDataStack)
				datastack.clone();
			FactorCallStack callstackCopy = (FactorCallStack)
				callstack.clone();

			StackEffect te = t.getStackEffect(recursiveCheck);

			datastack = datastackCopy;
			callstack = callstackCopy;

			StackEffect fe = f.getStackEffect(recursiveCheck);

			if(te == null || fe == null)
				return null;

			// we can only balance out a conditional if
			// both sides leave the same amount of elements
			// on the stack.
			// eg, 1/1 -vs- 2/2 is ok, 3/1 -vs- 4/2 is ok,
			// but 1/2 -vs- 2/1 is not.
			int balanceTD = te.outD - te.inD;
			int balanceTR = te.outR - te.inR;
			int balanceFD = fe.outD - fe.inD;
			int balanceFR = fe.outR - fe.inR;
			if(balanceTD == balanceFD
				&& balanceTR == balanceFR)
			{
				// replace results from the f branch with
				// dummy values so that subsequent code
				// doesn't assume these values always
				// result from this
				datastack.top -= te.outD;
				for(int i = 0; i < te.outD; i++)
				{
					push(null);
				}
				callstack.top -= te.outR;
				for(int i = 0; i < te.outR; i++)
				{
					pushR(null);
				}
				return new StackEffect(
					Math.max(te.inD,fe.inD),
					Math.max(te.outD,fe.outD),
					Math.max(te.inR,fe.inR),
					Math.max(te.outR,fe.outR)
				);
			}
			else
				return null;
		}

		/**
		 * Write code for evaluating this. Returns maximum JVM stack
		 * usage.
		 */
		public int compileCallTo(CodeVisitor mw, Set recursiveCheck)
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
			mw.visitJumpInsn(IFNULL,fl);

			FactorDataStack datastackCopy = (FactorDataStack)
				datastack.clone();
			FactorCallStack callstackCopy = (FactorCallStack)
				callstack.clone();

			int maxJVMStack = t.compileCallTo(mw,recursiveCheck);
			mw.visitJumpInsn(GOTO,endl);
			mw.visitLabel(fl);

			datastack = datastackCopy;
			callstack = callstackCopy;

			maxJVMStack = Math.max(f.compileCallTo(
				mw,recursiveCheck),maxJVMStack);
			mw.visitLabel(endl);

			return Math.max(maxJVMStack,1);
		}
	} //}}}
}
