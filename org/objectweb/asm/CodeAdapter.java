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

package org.objectweb.asm;

/**
 * An empty {@link CodeVisitor CodeVisitor} that delegates to another {@link
 * CodeVisitor CodeVisitor}. This class can be used as a super class to quickly
 * implement usefull code adapter classes, just by overriding the necessary
 * methods.
 */

public class CodeAdapter implements CodeVisitor {

  /**
   * The {@link CodeVisitor CodeVisitor} to which this adapter delegates calls.
   */

  protected CodeVisitor cv;

  /**
   * Constructs a new {@link CodeAdapter CodeAdapter} object.
   *
   * @param cv the code visitor to which this adapter must delegate calls.
   */

  public CodeAdapter (final CodeVisitor cv) {
    this.cv = cv;
  }

  public void visitInsn (final int opcode) {
    cv.visitInsn(opcode);
  }

  public void visitIntInsn (final int opcode, final int operand) {
    cv.visitIntInsn(opcode, operand);
  }

  public void visitVarInsn (final int opcode, final int var) {
    cv.visitVarInsn(opcode, var);
  }

  public void visitTypeInsn (final int opcode, final String desc) {
    cv.visitTypeInsn(opcode, desc);
  }

  public void visitFieldInsn (
    final int opcode,
    final String owner,
    final String name,
    final String desc)
  {
    cv.visitFieldInsn(opcode, owner, name, desc);
  }

  public void visitMethodInsn (
    final int opcode,
    final String owner,
    final String name,
    final String desc)
  {
    cv.visitMethodInsn(opcode, owner, name, desc);
  }

  public void visitJumpInsn (final int opcode, final Label label) {
    cv.visitJumpInsn(opcode, label);
  }

  public void visitLabel (final Label label) {
    cv.visitLabel(label);
  }

  public void visitLdcInsn (final Object cst) {
    cv.visitLdcInsn(cst);
  }

  public void visitIincInsn (final int var, final int increment) {
    cv.visitIincInsn(var, increment);
  }

  public void visitTableSwitchInsn (
    final int min,
    final int max,
    final Label dflt,
    final Label labels[])
  {
    cv.visitTableSwitchInsn(min, max, dflt, labels);
  }

  public void visitLookupSwitchInsn (
    final Label dflt,
    final int keys[],
    final Label labels[])
  {
    cv.visitLookupSwitchInsn(dflt, keys, labels);
  }

  public void visitMultiANewArrayInsn (final String desc, final int dims) {
    cv.visitMultiANewArrayInsn(desc, dims);
  }

  public void visitTryCatchBlock (
    final Label start,
    final Label end,
    final Label handler,
    final String type)
  {
    cv.visitTryCatchBlock(start, end, handler, type);
  }

  public void visitMaxs (final int maxStack, final int maxLocals) {
    cv.visitMaxs(maxStack, maxLocals);
  }

  public void visitLocalVariable (
    final String name,
    final String desc,
    final Label start,
    final Label end,
    final int index)
  {
    cv.visitLocalVariable(name, desc, start, end, index);
  }

  public void visitLineNumber (final int line, final Label start) {
    cv.visitLineNumber(line, start);
  }

  public void visitAttribute (final Attribute attr) {
    cv.visitAttribute(attr);
  }
}
