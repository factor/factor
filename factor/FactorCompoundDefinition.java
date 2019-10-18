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

import factor.compiler.*;
import java.lang.reflect.*;
import java.io.FileOutputStream;
import java.util.*;
import org.objectweb.asm.*;

/**
 * : name ... ;
 */
public class FactorCompoundDefinition extends FactorWordDefinition
{
	private static int compileCount;

	public Cons definition;
	private Cons endOfDocs;

	//{{{ FactorCompoundDefinition constructor
	/**
	 * A new definition.
	 */
	public FactorCompoundDefinition(FactorWord word, Cons definition,
		FactorInterpreter interp)
	{
		super(word);
		fromList(definition,interp);
	} //}}}

	//{{{ eval() method
	public void eval(FactorInterpreter interp)
		throws Exception
	{
		interp.call(endOfDocs);
	} //}}}

	//{{{ getStackEffect() method
	public void getStackEffect(RecursiveState recursiveCheck,
		FactorCompiler compiler) throws Exception
	{
		RecursiveForm rec = recursiveCheck.get(word);
		if(rec.active)
		{
			if(rec.baseCase == null)
				throw new FactorCompilerException("Indeterminate recursive call");

			compiler.apply(StackEffect.decompose(rec.effect,rec.baseCase));
		}
		else
		{
			compiler.compile(endOfDocs,null,recursiveCheck);
		}
	} //}}}

	//{{{ getClassName() method
	private static String getClassName(String name)
	{
		return FactorJava.getSanitizedName(name)
			+ "_" + (compileCount++);
	} //}}}

	//{{{ compile() method
	/**
	 * Compile the given word, returning a new word definition.
	 */
	FactorWordDefinition compile(FactorInterpreter interp,
		RecursiveState recursiveCheck) throws Exception
	{
		// Each word has its own class loader
		FactorClassLoader loader = new FactorClassLoader(
			getClass().getClassLoader());

		StackEffect effect = getStackEffect(interp);

		if(effect.inR != 0 || effect.outR != 0)
			throw new FactorCompilerException("Compiled code cannot manipulate call stack frames");

		String className = getClassName(word.name);

		ClassWriter cw = new ClassWriter(true);
		cw.visit(ACC_PUBLIC, className,
			"factor/compiler/CompiledDefinition",
			null, null);

		compileConstructor(cw,className);

		FactorCompiler compiler = compileEval(interp,cw,loader,
			className,effect,recursiveCheck);

		// Generate auxiliary methods
		compiler.generateAuxiliary(cw);

		// Generate fields for storing literals and
		// word references
		compiler.generateFields(cw);

		compileToList(interp,compiler,cw);

		compileGetStackEffect(cw,effect);

		// gets the bytecode of the class, and loads it
		// dynamically
		byte[] code = cw.toByteArray();

		if(interp.dump)
		{
			FileOutputStream fos = new FileOutputStream(
				className + ".class");
			try
			{
				fos.write(code);
			}
			finally
			{
				fos.close();
			}
		}

		String javaClassName = className.replace('/','.');
		word.setCompiledInfo(compiler.loader,javaClassName);

		Class compiledWordClass = loader.addClass(
			javaClassName,code,0,code.length);

		return CompiledDefinition.create(interp,word,compiledWordClass);
	} //}}}

	//{{{ compileConstructor() method
	private void compileConstructor(ClassVisitor cw, String className)
	{
		// creates a MethodWriter for the constructor
		CodeVisitor mw = cw.visitMethod(ACC_PUBLIC,
			"<init>",
			"(Lfactor/FactorWord;)V",
			null, null);
		// pushes the 'this' variable
		mw.visitVarInsn(ALOAD, 0);
		// pushes the word parameter
		mw.visitVarInsn(ALOAD, 1);
		// invokes the super class constructor
		mw.visitMethodInsn(INVOKESPECIAL,
			"factor/compiler/CompiledDefinition", "<init>",
			"(Lfactor/FactorWord;)V");
		mw.visitInsn(RETURN);
		mw.visitMaxs(0,0);
	} //}}}

	//{{{ compileToList() method
	private void compileToList(FactorInterpreter interp,
		FactorCompiler compiler, ClassVisitor cw)
	{
		// creates a MethodWriter for the toList() method
		CodeVisitor mw = cw.visitMethod(ACC_PUBLIC,
			"toList",
			"(Lfactor/FactorInterpreter;)Lfactor/Cons;",
			null, null);
		// push unparsed string representation of this word and parse it
		compiler.generateParse(mw,toList(interp),1);
		mw.visitTypeInsn(CHECKCAST,"factor/Cons");
		mw.visitInsn(ARETURN);
		mw.visitMaxs(0,0);
	} //}}}

	//{{{ compileGetStackEffect() method
	private void compileGetStackEffect(ClassVisitor cw, StackEffect effect)
	{
		// creates a MethodWriter for the getStackEffect() method
		CodeVisitor mw = cw.visitMethod(ACC_PUBLIC,
			"getStackEffect",
			"(Lfactor/compiler/RecursiveState;"
			+ "Lfactor/compiler/FactorCompiler;)V",
			null, null);

		mw.visitVarInsn(ALOAD,2);
		mw.visitTypeInsn(NEW,"factor/compiler/StackEffect");
		mw.visitInsn(DUP);
		mw.visitLdcInsn(new Integer(effect.inD));
		mw.visitLdcInsn(new Integer(effect.outD));
		mw.visitLdcInsn(new Integer(effect.inR));
		mw.visitLdcInsn(new Integer(effect.outR));
		mw.visitMethodInsn(INVOKESPECIAL,"factor/compiler/StackEffect",
			"<init>","(IIII)V");
		mw.visitMethodInsn(INVOKEVIRTUAL,"factor/compiler/FactorCompiler",
			"apply","(Lfactor/compiler/StackEffect;)V");
		mw.visitInsn(RETURN);
		mw.visitMaxs(0,0);
	} //}}}

	//{{{ compileEval() method
	/**
	 * Write the definition of the eval() method in the compiled word.
	 * Local 0 -- this
	 * Local 1 -- interpreter
	 */
	protected FactorCompiler compileEval(FactorInterpreter interp,
		ClassWriter cw, FactorClassLoader loader,
		String className, StackEffect effect,
		RecursiveState recursiveCheck)
		throws Exception
	{
		cw.visitField(ACC_PRIVATE | ACC_STATIC, "initialized", "Z",
			null, null);

		// creates a MethodWriter for the 'eval' method
		CodeVisitor mw = cw.visitMethod(ACC_PUBLIC,
			"eval", "(Lfactor/FactorInterpreter;)V",
			null, null);

		// eval() method calls core
		mw.visitVarInsn(ALOAD,1);

		compileDataStackToJVMStack(effect,mw);

		mw.visitMethodInsn(INVOKESTATIC,className,"core",
			effect.getCorePrototype());

		compileJVMStackToDataStack(effect,mw);

		mw.visitInsn(RETURN);
		mw.visitMaxs(0,0);

		// generate core
		FactorCompiler compiler = new FactorCompiler(interp,word,
			className,loader);
		compiler.init(1,effect.inD,effect.inR,"core");
		compiler.compileCore(endOfDocs,cw,effect,recursiveCheck);

		return compiler;
	} //}}}

	//{{{ compileDataStackToJVMStack() method
	private void compileDataStackToJVMStack(StackEffect effect,
		CodeVisitor mw)
	{
		if(effect.inD != 0)
		{
			mw.visitVarInsn(ALOAD,1);
			mw.visitFieldInsn(GETFIELD,
				"factor/FactorInterpreter", "datastack",
				"Lfactor/FactorArray;");

			// ensure the stack has enough elements
			mw.visitInsn(DUP);
			mw.visitIntInsn(BIPUSH,effect.inD);
			mw.visitMethodInsn(INVOKEVIRTUAL,
				"factor/FactorArray", "ensurePop",
				"(I)V");

			// datastack.stack -> 2
			mw.visitInsn(DUP);
			mw.visitFieldInsn(GETFIELD,
				"factor/FactorArray", "stack",
				"[Ljava/lang/Object;");
			mw.visitVarInsn(ASTORE,2);
			// datastack.top-args.length -> 3
			mw.visitInsn(DUP);
			mw.visitFieldInsn(GETFIELD,
				"factor/FactorArray", "top",
				"I");
			mw.visitIntInsn(BIPUSH,effect.inD);
			mw.visitInsn(ISUB);

			// datastack.top -= args.length
			mw.visitInsn(DUP_X1);
			mw.visitFieldInsn(PUTFIELD,
				"factor/FactorArray", "top",
				"I");

			mw.visitVarInsn(ISTORE,3);

			for(int i = 0; i < effect.inD; i++)
			{
				mw.visitVarInsn(ALOAD,2);
				mw.visitVarInsn(ILOAD,3);
				mw.visitInsn(AALOAD);
				if(i != effect.inD - 1)
					mw.visitIincInsn(3,1);
			}
		}
	} //}}}

	//{{{ compileJVMStackToDataStack() method
	private void compileJVMStackToDataStack(StackEffect effect,
		CodeVisitor mw)
	{
		if(effect.outD == 1)
		{
			// ( datastack )
			mw.visitVarInsn(ALOAD,1);
			mw.visitFieldInsn(GETFIELD,
				"factor/FactorInterpreter", "datastack",
				"Lfactor/FactorArray;");

			mw.visitInsn(SWAP);
			mw.visitMethodInsn(INVOKEVIRTUAL,
				"factor/FactorArray", "push",
				"(Ljava/lang/Object;)V");
		}
	} //}}}

	//{{{ fromList() method
	public void fromList(Cons definition, FactorInterpreter interp)
	{
		this.definition = definition;
		if(definition == null)
			endOfDocs = null;
		else
		{
			endOfDocs = definition;
			while(endOfDocs != null
				&& endOfDocs.car instanceof FactorDocComment)
				endOfDocs = endOfDocs.next();
		}
	} //}}}

	//{{{ toList() method
	public Cons toList(FactorInterpreter interp)
	{
		return definition;
	} //}}}
}
