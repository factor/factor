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

import org.objectweb.asm.Label;
import org.objectweb.asm.Attribute;
import org.objectweb.asm.attrs.Dumpable;

import java.util.HashMap;

/**
 * A {@link PrintCodeVisitor PrintCodeVisitor} that prints the ASM code that
 * generates the code it visits.
 */

public class DumpCodeVisitor extends PrintCodeVisitor {

  /**
   * The label names. This map associate String values to Label keys.
   */

  private final HashMap labelNames;

  /**
   * Constructs a new {@link DumpCodeVisitor DumpCodeVisitor} object.
   */

  public DumpCodeVisitor () {
    this.labelNames = new HashMap();
  }

  public void printInsn (final int opcode) {
    buf.append("cv.visitInsn(").
      append(OPCODES[opcode]).
      append(");\n");
  }

  public void printIntInsn (final int opcode, final int operand) {
    buf.append("cv.visitIntInsn(").
      append(OPCODES[opcode]).
      append(", ").
      append(operand).
      append(");\n");
  }

  public void printVarInsn (final int opcode, final int var) {
    buf.append("cv.visitVarInsn(").
      append(OPCODES[opcode]).
      append(", ").
      append(var).
      append(");\n");
  }

  public void printTypeInsn (final int opcode, final String desc) {
    buf.append("cv.visitTypeInsn(").
      append(OPCODES[opcode]).
      append(", ");
    DumpClassVisitor.appendConstant(buf, desc);
    buf.append(");\n");
  }

  public void printFieldInsn (
    final int opcode,
    final String owner,
    final String name,
    final String desc)
  {
    buf.append("cv.visitFieldInsn(")
      .append(OPCODES[opcode])
      .append(", ");
    DumpClassVisitor.appendConstant(buf, owner);
    buf.append(", ");
    DumpClassVisitor.appendConstant(buf, name);
    buf.append(", ");
    DumpClassVisitor.appendConstant(buf, desc);
    buf.append(");\n");
  }

  public void printMethodInsn (
    final int opcode,
    final String owner,
    final String name,
    final String desc)
  {
    buf.append("cv.visitMethodInsn(")
      .append(OPCODES[opcode])
      .append(", ");
    DumpClassVisitor.appendConstant(buf, owner);
    buf.append(", ");
    DumpClassVisitor.appendConstant(buf, name);
    buf.append(", ");
    DumpClassVisitor.appendConstant(buf, desc);
    buf.append(");\n");
  }

  public void printJumpInsn (final int opcode, final Label label) {
    declareLabel(label);
    buf.append("cv.visitJumpInsn(")
      .append(OPCODES[opcode])
      .append(", ");
    appendLabel(label);
    buf.append(");\n");
  }

  public void printLabel (final Label label) {
    declareLabel(label);
    buf.append("cv.visitLabel(");
    appendLabel(label);
    buf.append(");\n");
  }

  public void printLdcInsn (final Object cst) {
    buf.append("cv.visitLdcInsn(");
    DumpClassVisitor.appendConstant(buf, cst);
    buf.append(");\n");
  }

  public void printIincInsn (final int var, final int increment) {
    buf.append("cv.visitIincInsn(")
      .append(var)
      .append(", ")
      .append(increment)
      .append(");\n");
  }

  public void printTableSwitchInsn (
    final int min,
    final int max,
    final Label dflt,
    final Label labels[])
  {
    for (int i = 0; i < labels.length; ++i) {
      declareLabel(labels[i]);
    }
    declareLabel(dflt);

    buf.append("cv.visitTableSwitchInsn(")
      .append(min)
      .append(", ")
      .append(max)
      .append(", ");
    appendLabel(dflt);
    buf.append(", new Label[] {");
    for (int i = 0; i < labels.length; ++i) {
      buf.append(i == 0 ? " " : ", ");
      appendLabel(labels[i]);
    }
    buf.append(" });\n");
  }

  public void printLookupSwitchInsn (
    final Label dflt,
    final int keys[],
    final Label labels[])
  {
    for (int i = 0; i < labels.length; ++i) {
      declareLabel(labels[i]);
    }
    declareLabel(dflt);

    buf.append("cv.visitLookupSwitchInsn(");
    appendLabel(dflt);
    buf.append(", new int[] {");
    for (int i = 0; i < keys.length; ++i) {
      buf.append(i == 0 ? " " : ", ").append(keys[i]);
    }
    buf.append(" }, new Label[] {");
    for (int i = 0; i < labels.length; ++i) {
      buf.append(i == 0 ? " " : ", ");
      appendLabel(labels[i]);
    }
    buf.append(" });\n");
  }

  public void printMultiANewArrayInsn (final String desc, final int dims) {
    buf.append("cv.visitMultiANewArrayInsn(");
    DumpClassVisitor.appendConstant(buf, desc);
    buf.append(", ")
      .append(dims)
      .append(");\n");
  }

  public void printTryCatchBlock (
    final Label start,
    final Label end,
    final Label handler,
    final String type)
  {
    buf.append("cv.visitTryCatchBlock(");
    appendLabel(start);
    buf.append(", ");
    appendLabel(end);
    buf.append(", ");
    appendLabel(handler);
    buf.append(", ");
    DumpClassVisitor.appendConstant(buf, type);
    buf.append(");\n");
  }

  public void printMaxs (final int maxStack, final int maxLocals) {
    buf.append("cv.visitMaxs(")
      .append(maxStack)
      .append(", ")
      .append(maxLocals)
      .append(");\n");
  }

  public void printLocalVariable (
    final String name,
    final String desc,
    final Label start,
    final Label end,
    final int index)
  {
    buf.append("cv.visitLocalVariable(");
    DumpClassVisitor.appendConstant(buf, name);
    buf.append(", ");
    DumpClassVisitor.appendConstant(buf, desc);
    buf.append(", ");
    appendLabel(start);
    buf.append(", ");
    appendLabel(end);
    buf.append(", ").append(index).append(");\n");
  }

  public void printLineNumber (final int line, final Label start) {
    buf.append("cv.visitLineNumber(")
      .append(line)
      .append(", ");
    appendLabel(start);
    buf.append(");\n");
  }

  public void printAttribute (final Attribute attr) {
    if (attr instanceof Dumpable) {
      buf.append("// CODE ATTRIBUTE\n");
      ((Dumpable)attr).dump(buf, "cv", labelNames);
    } else {
      buf.append("// WARNING! skipped a non standard code attribute of type \"");
      buf.append(attr.type).append("\"\n");
    }
  }

  /**
   * Appends a declaration of the given label to {@link #buf buf}. This
   * declaration is of the form "Label lXXX = new Label();". Does nothing
   * if the given label has already been declared.
   *
   * @param l a label.
   */

  private void declareLabel (final Label l) {
    String name = (String)labelNames.get(l);
    if (name == null) {
      name = "l" + labelNames.size();
      labelNames.put(l, name);
      buf.append("Label ")
        .append(name)
        .append(" = new Label();\n");
    }
  }

  /**
   * Appends the name of the given label to {@link #buf buf}. The given label
   * <i>must</i> already have a name. One way to ensure this is to always call
   * {@link #declareLabel declared} before calling this method.
   *
   * @param l a label.
   */

  private void appendLabel (final Label l) {
    buf.append((String)labelNames.get(l));
  }
}
