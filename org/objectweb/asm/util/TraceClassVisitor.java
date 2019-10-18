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

import java.io.FileInputStream;
import java.io.PrintWriter;

import org.objectweb.asm.Attribute;
import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassVisitor;
import org.objectweb.asm.CodeVisitor;
import org.objectweb.asm.Constants;

/**
 * A {@link PrintClassVisitor PrintClassVisitor} that prints a disassembled
 * view of the classes it visits. This class visitor can be used alone (see the
 * {@link #main main} method) to disassemble a class. It can also be used in
 * the middle of class visitor chain to trace the class that is visited at a
 * given point in this chain. This may be uselful for debugging purposes.
 * <p>
 * The trace printed when visiting the <tt>Hello</tt> class is the following:
 * <p>
 * <blockquote>
 * <pre>
 * // compiled from Hello.java
 * public class Hello {
 *
 *   public static main ([Ljava/lang/String;)V
 *     GETSTATIC java/lang/System out Ljava/io/PrintStream;
 *     LDC "hello"
 *     INVOKEVIRTUAL java/io/PrintStream println (Ljava/lang/String;)V
 *     RETURN
 *     MAXSTACK = 2
 *     MAXLOCALS = 1
 *
 *   public &lt;init&gt; ()V
 *     ALOAD 0
 *     INVOKESPECIAL java/lang/Object &lt;init&gt; ()V
 *     RETURN
 *     MAXSTACK = 1
 *     MAXLOCALS = 1
 *
 * }
 * </pre>
 * </blockquote>
 * where <tt>Hello</tt> is defined by:
 * <p>
 * <blockquote>
 * <pre>
 * public class Hello {
 *
 *   public static void main (String[] args) {
 *     System.out.println("hello");
 *   }
 * }
 * </pre>
 * </blockquote>
 */

public class TraceClassVisitor extends PrintClassVisitor {

  /**
   * The {@link ClassVisitor ClassVisitor} to which this visitor delegates
   * calls. May be <tt>null</tt>.
   */

  protected final ClassVisitor cv;

  /**
   * Prints a disassembled view of the given class to the standard output.
   * <p>
   * Usage: TraceClassVisitor
   * &lt;fully qualified class name or class file name &gt;
   *
   * @param args the command line arguments.
   *
   * @throws Exception if the class cannot be found, or if an IO exception
   *      occurs.
   */

  public static void main (final String[] args) throws Exception {
    if (args.length == 0) {
      System.err.println("Prints a disassembled view of the given class.");
      System.err.println("Usage: TraceClassVisitor " +
                         "<fully qualified class name or class file name>");
      System.exit(-1);
    }
    ClassReader cr;
    if (args[0].endsWith(".class")) {
      cr = new ClassReader(new FileInputStream(args[0]));
    } else {
      cr = new ClassReader(args[0]);
    }
    cr.accept(new TraceClassVisitor(null, new PrintWriter(System.out)),
              PrintClassVisitor.DEFAULT_ATTRIBUTES, true);
  }

  /**
   * Constructs a new {@link TraceClassVisitor TraceClassVisitor} object.
   *
   * @param cv the class visitor to which this adapter must delegate calls. May
   *      be <tt>null</tt>.
   * @param pw the print writer to be used to print the class.
   */

  public TraceClassVisitor (final ClassVisitor cv, final PrintWriter pw) {
    super(pw);
    this.cv = cv;
  }

  public void visit (
    final int access,
    final String name,
    final String superName,
    final String[] interfaces,
    final String sourceFile)
  {
    buf.setLength(0);
    if ((access & Constants.ACC_DEPRECATED) != 0) {
      buf.append("// DEPRECATED\n");
    }
    if (sourceFile != null) {
      buf.append("// compiled from ").append(sourceFile).append("\n");
    }
    buf.append("// access flags ").append(access).append("\n");
    appendAccess(access & ~Constants.ACC_SUPER);
    if ((access & Constants.ACC_INTERFACE) != 0) {
      buf.append("interface ");
    } else if ((access & Constants.ACC_ENUM) != 0) {
      buf.append("enum ");
    } else {
      buf.append("class ");
    }
    buf.append(name).append(" ");
    if (superName != null && !superName.equals("java/lang/Object")) {
      buf.append("extends ").append(superName).append(" ");
    }
    if (interfaces != null && interfaces.length > 0) {
      buf.append("implements ");
      for (int i = 0; i < interfaces.length; ++i) {
        buf.append(interfaces[i]).append(" ");
      }
    }
    buf.append("{\n\n");
    text.add(buf.toString());

    if (cv != null) {
      cv.visit(access, name, superName, interfaces, sourceFile);
    }
  }

  public void visitInnerClass (
    final String name,
    final String outerName,
    final String innerName,
    final int access)
  {
    buf.setLength(0);
    buf.append("  INNERCLASS ")
      .append(name)
      .append(" ")
      .append(outerName)
      .append(" ")
      .append(innerName)
      .append(" ")
      .append(access)
      .append("\n");
    text.add(buf.toString());

    if (cv != null) {
      cv.visitInnerClass(name, outerName, innerName, access);
    }
  }

  public void visitField (
    final int access,
    final String name,
    final String desc,
    final Object value,
    final Attribute attrs)
  {
    buf.setLength(0);
    if ((access & Constants.ACC_DEPRECATED) != 0) {
      buf.append("  // DEPRECATED\n");
    }
    buf.append("  // access flags ").append(access).append("\n");
    buf.append("  ");
    appendAccess(access);
    if ((access & Constants.ACC_ENUM) != 0) {
      buf.append("enum ");
    }
    buf.append(desc)
      .append(" ")
      .append(name);
    if (value != null) {
      buf.append(" = ");
      if (value instanceof String) {
        buf.append("\"").append(value).append("\"");
      } else {
        buf.append(value);
      }
    }
    Attribute attr = attrs;
    while (attr != null) {
      buf.append("  FIELD ATTRIBUTE ").append(attr.type).append(" : ")
        .append(attr.toString()).append("\n");
      attr = attr.next;
    }
    buf.append("\n");
    text.add(buf.toString());

    if (cv != null) {
      cv.visitField(access, name, desc, value, attrs);
    }
  }

  public CodeVisitor visitMethod (
    final int access,
    final String name,
    final String desc,
    final String[] exceptions,
    final Attribute attrs)
  {
    buf.setLength(0);
    if ((access & Constants.ACC_DEPRECATED) != 0) {
      buf.append("  // DEPRECATED\n");
    }
    buf.append("  // access flags ").append(access).append("\n");
    buf.append("  ");
    appendAccess(access);
    if ((access & Constants.ACC_NATIVE) != 0) {
      buf.append("native ");
    }
    if ((access & Constants.ACC_VARARGS) != 0) {
      buf.append("varargs ");
    }
    if ((access & Constants.ACC_BRIDGE) != 0) {
      buf.append("bridge ");
    }
    buf.append(name).
      append(" ").
      append(desc);
    if (exceptions != null && exceptions.length > 0) {
      buf.append(" throws ");
      for (int i = 0; i < exceptions.length; ++i) {
        buf.append(exceptions[i]).append(" ");
      }
    }
    buf.append("\n");
    text.add(buf.toString());
    Attribute attr = attrs;
    while (attr != null) {
      buf.setLength(0);
      buf.append("    METHOD ATTRIBUTE ").append(attr.type).append(" : ")
        .append(attr.toString()).append("\n");
      text.add(buf.toString());
      attr = attr.next;
    }

    CodeVisitor cv;
    if (this.cv != null) {
      cv = this.cv.visitMethod(access, name, desc, exceptions, attrs);
    } else {
      cv = null;
    }
    PrintCodeVisitor pcv = new TraceCodeVisitor(cv);
    text.add(pcv.getText());
    return pcv;
  }

  public void visitAttribute (final Attribute attr) {
    buf.setLength(0);
    buf.append("  CLASS ATTRIBUTE ").append(attr.type).append(" : ")
      .append(attr.toString()).append("\n");
    text.add(buf.toString());

    if (cv != null) {
      cv.visitAttribute(attr);
    }
  }

  public void visitEnd () {
    text.add("}\n");

    if (cv != null) {
      cv.visitEnd();
    }

    super.visitEnd();
  }

  /**
   * Appends a string representation of the given access modifiers to {@link
   * #buf buf}.
   *
   * @param access some access modifiers.
   */

  private void appendAccess (final int access) {
    if ((access & Constants.ACC_PUBLIC) != 0) {
      buf.append("public ");
    }
    if ((access & Constants.ACC_PRIVATE) != 0) {
      buf.append("private ");
    }
    if ((access & Constants.ACC_PROTECTED) != 0) {
      buf.append("protected ");
    }
    if ((access & Constants.ACC_FINAL) != 0) {
      buf.append("final ");
    }
    if ((access & Constants.ACC_STATIC) != 0) {
      buf.append("static ");
    }
    if ((access & Constants.ACC_SYNCHRONIZED) != 0) {
      buf.append("synchronized ");
    }
    if ((access & Constants.ACC_VOLATILE) != 0) {
      buf.append("volatile ");
    }
    if ((access & Constants.ACC_TRANSIENT) != 0) {
      buf.append("transient ");
    }
    // if ((access & Constants.ACC_NATIVE) != 0) {
    //   buf.append("native ");
    // }
    if ((access & Constants.ACC_ABSTRACT) != 0) {
      buf.append("abstract ");
    }
    if ((access & Constants.ACC_STRICT) != 0) {
      buf.append("strictfp ");
    }
  }
}
