/***
 * ASM: a very small and fast Java bytecode manipulation framework
 * Copyright (c) 2000,2002,2003 INRIA, France Telecom
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holders nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Contact: Eric.Bruneton@rd.francetelecom.com
 *
 * Author: Eric Bruneton
 */

package org.objectweb.asm.util;

import org.objectweb.asm.CodeVisitor;
import org.objectweb.asm.Label;
import org.objectweb.asm.Attribute;

import java.util.ArrayList;
import java.util.List;

/**
 * An abstract code visitor that prints the code it visits. Each
 * <tt>visit</tt><i>XXX</i> method clears the {@link #buf buf} buffer, calls the
 * corresponding <tt>print</tt><i>XXX</i> method, and then adds the buffer's
 * content to the {@link #text text} list. In order to provide a concrete
 * print code visitor, one must implement the <tt>print</tt><i>XXX</i> methods
 * in a sub class of this class. Each method should print the instructions it
 * visits in {@link #buf buf}.
 */

public abstract class PrintCodeVisitor implements CodeVisitor {

  /**
   * The text to be printed. See {@link PrintClassVisitor#text text}.
   */

  protected final List text;

  /**
   * A buffer used to convert instructions to strings.
   */

  protected final StringBuffer buf;

  /**
   * The names of the Java Virtual Machine opcodes.
   */

  public final static String[] OPCODES = {
    "NOP",
    "ACONST_NULL",
    "ICONST_M1",
    "ICONST_0",
    "ICONST_1",
    "ICONST_2",
    "ICONST_3",
    "ICONST_4",
    "ICONST_5",
    "LCONST_0",
    "LCONST_1",
    "FCONST_0",
    "FCONST_1",
    "FCONST_2",
    "DCONST_0",
    "DCONST_1",
    "BIPUSH",
    "SIPUSH",
    "LDC",
    null,
    null,
    "ILOAD",
    "LLOAD",
    "FLOAD",
    "DLOAD",
    "ALOAD",
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    "IALOAD",
    "LALOAD",
    "FALOAD",
    "DALOAD",
    "AALOAD",
    "BALOAD",
    "CALOAD",
    "SALOAD",
    "ISTORE",
    "LSTORE",
    "FSTORE",
    "DSTORE",
    "ASTORE",
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    "IASTORE",
    "LASTORE",
    "FASTORE",
    "DASTORE",
    "AASTORE",
    "BASTORE",
    "CASTORE",
    "SASTORE",
    "POP",
    "POP2",
    "DUP",
    "DUP_X1",
    "DUP_X2",
    "DUP2",
    "DUP2_X1",
    "DUP2_X2",
    "SWAP",
    "IADD",
    "LADD",
    "FADD",
    "DADD",
    "ISUB",
    "LSUB",
    "FSUB",
    "DSUB",
    "IMUL",
    "LMUL",
    "FMUL",
    "DMUL",
    "IDIV",
    "LDIV",
    "FDIV",
    "DDIV",
    "IREM",
    "LREM",
    "FREM",
    "DREM",
    "INEG",
    "LNEG",
    "FNEG",
    "DNEG",
    "ISHL",
    "LSHL",
    "ISHR",
    "LSHR",
    "IUSHR",
    "LUSHR",
    "IAND",
    "LAND",
    "IOR",
    "LOR",
    "IXOR",
    "LXOR",
    "IINC",
    "I2L",
    "I2F",
    "I2D",
    "L2I",
    "L2F",
    "L2D",
    "F2I",
    "F2L",
    "F2D",
    "D2I",
    "D2L",
    "D2F",
    "I2B",
    "I2C",
    "I2S",
    "LCMP",
    "FCMPL",
    "FCMPG",
    "DCMPL",
    "DCMPG",
    "IFEQ",
    "IFNE",
    "IFLT",
    "IFGE",
    "IFGT",
    "IFLE",
    "IF_ICMPEQ",
    "IF_ICMPNE",
    "IF_ICMPLT",
    "IF_ICMPGE",
    "IF_ICMPGT",
    "IF_ICMPLE",
    "IF_ACMPEQ",
    "IF_ACMPNE",
    "GOTO",
    "JSR",
    "RET",
    "TABLESWITCH",
    "LOOKUPSWITCH",
    "IRETURN",
    "LRETURN",
    "FRETURN",
    "DRETURN",
    "ARETURN",
    "RETURN",
    "GETSTATIC",
    "PUTSTATIC",
    "GETFIELD",
    "PUTFIELD",
    "INVOKEVIRTUAL",
    "INVOKESPECIAL",
    "INVOKESTATIC",
    "INVOKEINTERFACE",
    null,
    "NEW",
    "NEWARRAY",
    "ANEWARRAY",
    "ARRAYLENGTH",
    "ATHROW",
    "CHECKCAST",
    "INSTANCEOF",
    "MONITORENTER",
    "MONITOREXIT",
    null,
    "MULTIANEWARRAY",
    "IFNULL",
    "IFNONNULL",
    null,
    null
  };

  /**
   * Constructs a new {@link PrintCodeVisitor PrintCodeVisitor} object.
   */

  public PrintCodeVisitor () {
    this.buf = new StringBuffer();
    this.text = new ArrayList();
  }

  public void visitInsn (final int opcode) {
    buf.setLength(0);
    printInsn(opcode);
    text.add(buf.toString());
  }

  public void visitIntInsn (final int opcode, final int operand) {
    buf.setLength(0);
    printIntInsn(opcode, operand);
    text.add(buf.toString());
  }

  public void visitVarInsn (final int opcode, final int var) {
    buf.setLength(0);
    printVarInsn(opcode, var);
    text.add(buf.toString());
  }

  public void visitTypeInsn (final int opcode, final String desc) {
    buf.setLength(0);
    printTypeInsn(opcode, desc);
    text.add(buf.toString());
  }

  public void visitFieldInsn (
    final int opcode,
    final String owner,
    final String name,
    final String desc)
  {
    buf.setLength(0);
    printFieldInsn(opcode, owner, name, desc);
    text.add(buf.toString());
  }

  public void visitMethodInsn (
    final int opcode,
    final String owner,
    final String name,
    final String desc)
  {
    buf.setLength(0);
    printMethodInsn(opcode, owner, name, desc);
    text.add(buf.toString());
  }

  public void visitJumpInsn (final int opcode, final Label label) {
    buf.setLength(0);
    printJumpInsn(opcode, label);
    text.add(buf.toString());
  }

  public void visitLabel (final Label label) {
    buf.setLength(0);
    printLabel(label);
    text.add(buf.toString());
  }

  public void visitLdcInsn (final Object cst) {
    buf.setLength(0);
    printLdcInsn(cst);
    text.add(buf.toString());
  }

  public void visitIincInsn (final int var, final int increment) {
    buf.setLength(0);
    printIincInsn(var, increment);
    text.add(buf.toString());
  }

  public void visitTableSwitchInsn (
    final int min,
    final int max,
    final Label dflt,
    final Label labels[])
  {
    buf.setLength(0);
    printTableSwitchInsn(min, max, dflt, labels);
    text.add(buf.toString());
  }

  public void visitLookupSwitchInsn (
    final Label dflt,
    final int keys[],
    final Label labels[])
  {
    buf.setLength(0);
    printLookupSwitchInsn(dflt, keys, labels);
    text.add(buf.toString());
  }

  public void visitMultiANewArrayInsn (final String desc, final int dims) {
    buf.setLength(0);
    printMultiANewArrayInsn(desc, dims);
    text.add(buf.toString());
  }

  public void visitTryCatchBlock (
    final Label start,
    final Label end,
    final Label handler,
    final String type)
  {
    buf.setLength(0);
    printTryCatchBlock(start, end, handler, type);
    text.add(buf.toString());
  }

  public void visitMaxs (final int maxStack, final int maxLocals) {
    buf.setLength(0);
    printMaxs(maxStack, maxLocals);
    text.add(buf.toString());
  }

  public void visitLocalVariable (
    final String name,
    final String desc,
    final Label start,
    final Label end,
    final int index)
  {
    buf.setLength(0);
    printLocalVariable(name, desc, start, end, index);
    text.add(buf.toString());
  }

  public void visitLineNumber (final int line, final Label start) {
    buf.setLength(0);
    printLineNumber(line, start);
    text.add(buf.toString());
  }

  public void visitAttribute (final Attribute attr) {
    buf.setLength(0);
    printAttribute(attr);
    text.add(buf.toString());
  }

  /**
   * Returns the code printed by this code visitor.
   *
   * @return the code printed by this code visitor. See {@link
   *      PrintClassVisitor#text text}.
   */

  public List getText () {
    return text;
  }

  /**
   * Prints a zero operand instruction.
   *
   * @param opcode the opcode of the instruction to be printed. This opcode is
   *      either NOP, ACONST_NULL, ICONST_M1, ICONST_0, ICONST_1, ICONST_2,
   *      ICONST_3, ICONST_4, ICONST_5, LCONST_0, LCONST_1, FCONST_0, FCONST_1,
   *      FCONST_2, DCONST_0, DCONST_1,
   *
   *      IALOAD, LALOAD, FALOAD, DALOAD, AALOAD, BALOAD, CALOAD, SALOAD,
   *      IASTORE, LASTORE, FASTORE, DASTORE, AASTORE, BASTORE, CASTORE,
   *      SASTORE,
   *
   *      POP, POP2, DUP, DUP_X1, DUP_X2, DUP2, DUP2_X1, DUP2_X2, SWAP,
   *
   *      IADD, LADD, FADD, DADD, ISUB, LSUB, FSUB, DSUB, IMUL, LMUL, FMUL,
   *      DMUL, IDIV, LDIV, FDIV, DDIV, IREM, LREM, FREM, DREM, INEG, LNEG,
   *      FNEG, DNEG, ISHL, LSHL, ISHR, LSHR, IUSHR, LUSHR, IAND, LAND, IOR,
   *      LOR, IXOR, LXOR,
   *
   *      I2L, I2F, I2D, L2I, L2F, L2D, F2I, F2L, F2D, D2I, D2L, D2F, I2B, I2C,
   *      I2S,
   *
   *      LCMP, FCMPL, FCMPG, DCMPL, DCMPG,
   *
   *      IRETURN, LRETURN, FRETURN, DRETURN, ARETURN, RETURN,
   *
   *      ARRAYLENGTH,
   *
   *      ATHROW,
   *
   *      MONITORENTER, or MONITOREXIT.
   */

  public abstract void printInsn (final int opcode);

  /**
   * Prints an instruction with a single int operand.
   *
   * @param opcode the opcode of the instruction to be printed. This opcode is
   *      either BIPUSH, SIPUSH or NEWARRAY.
   * @param operand the operand of the instruction to be printed.
   */

  public abstract void printIntInsn (final int opcode, final int operand);

  /**
   * Prints a local variable instruction. A local variable instruction is an
   * instruction that loads or stores the value of a local variable.
   *
   * @param opcode the opcode of the local variable instruction to be printed.
   *      This opcode is either ILOAD, LLOAD, FLOAD, DLOAD, ALOAD, ISTORE,
   *      LSTORE, FSTORE, DSTORE, ASTORE or RET.
   * @param var the operand of the instruction to be printed. This operand is
   *      the index of a local variable.
   */

  public abstract void printVarInsn (final int opcode, final int var);

  /**
   * Prints a type instruction. A type instruction is an instruction that
   * takes a type descriptor as parameter.
   *
   * @param opcode the opcode of the type instruction to be printed. This opcode
   *      is either NEW, ANEWARRAY, CHECKCAST or INSTANCEOF.
   * @param desc the operand of the instruction to be printed. This operand is
   *      must be a fully qualified class name in internal form, or a the type
   *      descriptor of an array type (see {@link org.objectweb.asm.Type Type}).
   */

  public abstract void printTypeInsn (final int opcode, final String desc);

  /**
   * Prints a field instruction. A field instruction is an instruction that
   * loads or stores the value of a field of an object.
   *
   * @param opcode the opcode of the type instruction to be printed. This opcode
   *      is either GETSTATIC, PUTSTATIC, GETFIELD or PUTFIELD.
   * @param owner the internal name of the field's owner class (see {@link
   *      org.objectweb.asm.Type#getInternalName getInternalName}).
   * @param name the field's name.
   * @param desc the field's descriptor (see {@link org.objectweb.asm.Type
   *      Type}).
   */

  public abstract void printFieldInsn (
    final int opcode,
    final String owner,
    final String name,
    final String desc);

  /**
   * Prints a method instruction. A method instruction is an instruction that
   * invokes a method.
   *
   * @param opcode the opcode of the type instruction to be printed. This opcode
   *      is either INVOKEVIRTUAL, INVOKESPECIAL, INVOKESTATIC or
   *      INVOKEINTERFACE.
   * @param owner the internal name of the method's owner class (see {@link
   *      org.objectweb.asm.Type#getInternalName getInternalName}).
   * @param name the method's name.
   * @param desc the method's descriptor (see {@link org.objectweb.asm.Type
   *      Type}).
   */

  public abstract void printMethodInsn (
    final int opcode,
    final String owner,
    final String name,
    final String desc);

  /**
   * Prints a jump instruction. A jump instruction is an instruction that may
   * jump to another instruction.
   *
   * @param opcode the opcode of the type instruction to be printed. This opcode
   *      is either IFEQ, IFNE, IFLT, IFGE, IFGT, IFLE, IF_ICMPEQ, IF_ICMPNE,
   *      IF_ICMPLT, IF_ICMPGE, IF_ICMPGT, IF_ICMPLE, IF_ACMPEQ, IF_ACMPNE,
   *      GOTO, JSR, IFNULL or IFNONNULL.
   * @param label the operand of the instruction to be printed. This operand is
   *      a label that designates the instruction to which the jump instruction
   *      may jump.
   */

  public abstract void printJumpInsn (final int opcode, final Label label);

  /**
   * Prints a label. A label designates the instruction that will be visited
   * just after it.
   *
   * @param label a {@link Label Label} object.
   */

  public abstract void printLabel (final Label label);

  /**
   * Prints a LDC instruction.
   *
   * @param cst the constant to be loaded on the stack. This parameter must be
   *      a non null {@link java.lang.Integer Integer}, a {@link java.lang.Float
   *      Float}, a {@link java.lang.Long Long}, a {@link java.lang.Double
   *      Double} or a {@link String String}.
   */

  public abstract void printLdcInsn (final Object cst);

  /**
   * Prints an IINC instruction.
   *
   * @param var index of the local variable to be incremented.
   * @param increment amount to increment the local variable by.
   */

  public abstract void printIincInsn (final int var, final int increment);

  /**
   * Prints a TABLESWITCH instruction.
   *
   * @param min the minimum key value.
   * @param max the maximum key value.
   * @param dflt beginning of the default handler block.
   * @param labels beginnings of the handler blocks. <tt>labels[i]</tt> is the
   *      beginning of the handler block for the <tt>min + i</tt> key.
   */

  public abstract void printTableSwitchInsn (
    final int min,
    final int max,
    final Label dflt,
    final Label labels[]);

  /**
   * Prints a LOOKUPSWITCH instruction.
   *
   * @param dflt beginning of the default handler block.
   * @param keys the values of the keys.
   * @param labels beginnings of the handler blocks. <tt>labels[i]</tt> is the
   *      beginning of the handler block for the <tt>keys[i]</tt> key.
   */

  public abstract void printLookupSwitchInsn (
    final Label dflt,
    final int keys[],
    final Label labels[]);

  /**
   * Prints a MULTIANEWARRAY instruction.
   *
   * @param desc an array type descriptor (see {@link org.objectweb.asm.Type
   *      Type}).
   * @param dims number of dimensions of the array to allocate.
   */

  public abstract void printMultiANewArrayInsn (
    final String desc,
    final int dims);

  /**
   * Prints a try catch block.
   *
   * @param start beginning of the exception handler's scope (inclusive).
   * @param end end of the exception handler's scope (exclusive).
   * @param handler beginning of the exception handler's code.
   * @param type internal name of the type of exceptions handled by the handler,
   *      or <tt>null</tt> to catch any exceptions (for "finally" blocks).
   */

  public abstract void printTryCatchBlock (
    final Label start,
    final Label end,
    final Label handler,
    final String type);

  /**
   * Prints the maximum stack size and the maximum number of local variables of
   * the method.
   *
   * @param maxStack maximum stack size of the method.
   * @param maxLocals maximum number of local variables for the method.
   */

  public abstract void printMaxs (final int maxStack, final int maxLocals);

  /**
   * Prints a local variable declaration.
   *
   * @param name the name of a local variable.
   * @param desc the type descriptor of this local variable.
   * @param start the first instruction corresponding to the scope of this
   *      local variable (inclusive).
   * @param end the last instruction corresponding to the scope of this
   *      local variable (exclusive).
   * @param index the local variable's index.
   */

  public abstract void printLocalVariable (
    final String name,
    final String desc,
    final Label start,
    final Label end,
    final int index);

  /**
   * Prints a line number declaration.
   *
   * @param line a line number. This number refers to the source file
   *      from which the class was compiled.
   * @param start the first instruction corresponding to this line number.
   */

  public abstract void printLineNumber (final int line, final Label start);

  /**
   * Prints a non standard code attribute.
   *
   * @param attr a non standard code attribute.
   */

  public abstract void printAttribute (final Attribute attr);
}