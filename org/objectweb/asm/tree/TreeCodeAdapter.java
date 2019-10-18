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

package org.objectweb.asm.tree;

import org.objectweb.asm.CodeAdapter;
import org.objectweb.asm.Label;
import org.objectweb.asm.Attribute;

/**
 * A {@link CodeAdapter CodeAdapter} that constructs a tree representation of
 * the methods it vists. Each <tt>visit</tt><i>XXX</i> method of this class
 * constructs an <i>XXX</i><tt>Node</tt> and adds it to the {@link #methodNode
 * methodNode} node.
 */

public class TreeCodeAdapter extends CodeAdapter {

  /**
   * A tree representation of the method that is being visited by this visitor.
   */

  public MethodNode methodNode;

  /**
   * Constructs a new {@link TreeCodeAdapter TreeCodeAdapter} object.
   *
   * @param methodNode the method node to be used to store the tree
   *      representation constructed by this code visitor.
   */

  public TreeCodeAdapter (final MethodNode methodNode) {
    super(null);
    this.methodNode = methodNode;
  }

  public void visitInsn (final int opcode) {
    AbstractInsnNode n = new InsnNode(opcode);
    methodNode.instructions.add(n);
  }

  public void visitIntInsn (final int opcode, final int operand) {
    AbstractInsnNode n = new IntInsnNode(opcode, operand);
    methodNode.instructions.add(n);
  }

  public void visitVarInsn (final int opcode, final int var) {
    AbstractInsnNode n = new VarInsnNode(opcode, var);
    methodNode.instructions.add(n);
  }

  public void visitTypeInsn (final int opcode, final String desc) {
    AbstractInsnNode n = new TypeInsnNode(opcode, desc);
    methodNode.instructions.add(n);
  }

  public void visitFieldInsn (
    final int opcode,
    final String owner,
    final String name,
    final String desc)
  {
    AbstractInsnNode n = new FieldInsnNode(opcode, owner, name, desc);
    methodNode.instructions.add(n);
  }

  public void visitMethodInsn (
    final int opcode,
    final String owner,
    final String name,
    final String desc)
  {
    AbstractInsnNode n = new MethodInsnNode(opcode, owner, name, desc);
    methodNode.instructions.add(n);
  }

  public void visitJumpInsn (final int opcode, final Label label) {
    AbstractInsnNode n = new JumpInsnNode(opcode, label);
    methodNode.instructions.add(n);
  }

  public void visitLabel (final Label label) {
    methodNode.instructions.add(label);
  }

  public void visitLdcInsn (final Object cst) {
    AbstractInsnNode n = new LdcInsnNode(cst);
    methodNode.instructions.add(n);
  }

  public void visitIincInsn (final int var, final int increment) {
    AbstractInsnNode n = new IincInsnNode(var, increment);
    methodNode.instructions.add(n);
  }

  public void visitTableSwitchInsn (
    final int min,
    final int max,
    final Label dflt,
    final Label labels[])
  {
    AbstractInsnNode n = new TableSwitchInsnNode(min, max, dflt, labels);
    methodNode.instructions.add(n);
  }

  public void visitLookupSwitchInsn (
    final Label dflt,
    final int keys[],
    final Label labels[])
  {
    AbstractInsnNode n = new LookupSwitchInsnNode(dflt, keys, labels);
    methodNode.instructions.add(n);
  }

  public void visitMultiANewArrayInsn (final String desc, final int dims) {
    AbstractInsnNode n = new MultiANewArrayInsnNode(desc, dims);
    methodNode.instructions.add(n);
  }

  public void visitTryCatchBlock (
    final Label start,
    final Label end,
    final Label handler,
    final String type)
  {
    TryCatchBlockNode n = new TryCatchBlockNode(start, end, handler, type);
    methodNode.tryCatchBlocks.add(n);
  }

  public void visitMaxs (final int maxStack, final int maxLocals) {
    methodNode.maxStack = maxStack;
    methodNode.maxLocals = maxLocals;
  }

  public void visitLocalVariable (
    final String name,
    final String desc,
    final Label start,
    final Label end,
    final int index)
  {
    LocalVariableNode n = new LocalVariableNode(name, desc, start, end, index);
    methodNode.localVariables.add(n);
  }

  public void visitLineNumber (final int line, final Label start) {
    LineNumberNode n = new LineNumberNode(line, start);
    methodNode.lineNumbers.add(n);
  }

  public void visitAttribute (final Attribute attr) {
    attr.next = methodNode.attrs;
    methodNode.attrs = attr;
  }
}
