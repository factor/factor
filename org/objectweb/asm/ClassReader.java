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

import java.io.InputStream;
import java.io.IOException;

/**
 * A Java class parser to make a {@link ClassVisitor ClassVisitor} visit an
 * existing class. This class parses a byte array conforming to the Java class
 * file format and calls the appropriate visit methods of a given class visitor
 * for each field, method and bytecode instruction encountered.
 */

public class ClassReader {

  /**
   * The class to be parsed. <i>The content of this array must not be
   * modified. This field is intended for {@link Attribute} sub classes, and is
   * normally not needed by class generators or adapters.</i>
   */

  public final byte[] b;

  /**
   * The start index of each constant pool item in {@link #b b}, plus one. The
   * one byte offset skips the constant pool item tag that indicates its type.
   */

  private int[] items;

  /**
   * The String objects corresponding to the CONSTANT_Utf8 items. This cache
   * avoids multiple parsing of a given CONSTANT_Utf8 constant pool item, which
   * GREATLY improves performances (by a factor 2 to 3). This caching strategy
   * could be extended to all constant pool items, but its benefit would not be
   * so great for these items (because they are much less expensive to parse
   * than CONSTANT_Utf8 items).
   */

  private String[] strings;

  /**
   * Maximum length of the strings contained in the constant pool of the class.
   */

  private int maxStringLength;

  /**
   * Start index of the class header information (access, name...) in {@link #b
   * b}.
   */

  private int header;

  // --------------------------------------------------------------------------
  // Constructors
  // --------------------------------------------------------------------------

  /**
   * Constructs a new {@link ClassReader ClassReader} object.
   *
   * @param b the bytecode of the class to be read.
   */

  public ClassReader (final byte[] b) {
    this(b, 0, b.length);
  }

  /**
   * Constructs a new {@link ClassReader ClassReader} object.
   *
   * @param b the bytecode of the class to be read.
   * @param off the start offset of the class data.
   * @param len the length of the class data.
   */

  public ClassReader (final byte[] b, final int off, final int len) {
    this.b = b;
    // parses the constant pool
    items = new int[readUnsignedShort(off + 8)];
    strings = new String[items.length];
    int max = 0;
    int index = off + 10;
    for (int i = 1; i < items.length; ++i) {
      items[i] = index + 1;
      int tag = b[index];
      int size;
      switch (tag) {
        case ClassWriter.FIELD:
        case ClassWriter.METH:
        case ClassWriter.IMETH:
        case ClassWriter.INT:
        case ClassWriter.FLOAT:
        case ClassWriter.NAME_TYPE:
          size = 5;
          break;
        case ClassWriter.LONG:
        case ClassWriter.DOUBLE:
          size = 9;
          ++i;
          break;
        case ClassWriter.UTF8:
          size = 3 + readUnsignedShort(index + 1);
          max = (size > max ? size : max);
          break;
        //case ClassWriter.CLASS:
        //case ClassWriter.STR:
        default:
          size = 3;
          break;
      }
      index += size;
    }
    maxStringLength = max;
    // the class header information starts just after the constant pool
    header = index;
  }

  /**
   * Constructs a new {@link ClassReader ClassReader} object.
   *
   * @param is an input stream from which to read the class.
   * @throws IOException if a problem occurs during reading.
   */

  public ClassReader (final InputStream is) throws IOException {
    this(readClass(is));
  }

  /**
   * Constructs a new {@link ClassReader ClassReader} object.
   *
   * @param name the fully qualified name of the class to be read.
   * @throws IOException if an exception occurs during reading.
   */

  public ClassReader (final String name) throws IOException {
    this((ClassReader.class.getClassLoader() == null
            ? ClassLoader.getSystemClassLoader()
            : ClassReader.class.getClassLoader())
            .getSystemResourceAsStream(name.replace('.','/') + ".class"));
  }

  /**
   * Reads the bytecode of a class.
   *
   * @param is an input stream from which to read the class.
   * @return the bytecode read from the given input stream.
   * @throws IOException if a problem occurs during reading.
   */

  private static byte[] readClass (final InputStream is) throws IOException {
    if (is == null) {
      throw new IOException("Class not found");
    }
    byte[] b = new byte[is.available()];
    int len = 0;
    while (true) {
      int n = is.read(b, len, b.length - len);
      if (n == -1) {
        if (len < b.length) {
          byte[] c = new byte[len];
          System.arraycopy(b, 0, c, 0, len);
          b = c;
        }
        return b;
      } else {
        len += n;
        if (len == b.length) {
          byte[] c = new byte[b.length + 1000];
          System.arraycopy(b, 0, c, 0, len);
          b = c;
        }
      }
    }
  }

  // --------------------------------------------------------------------------
  // Public methods
  // --------------------------------------------------------------------------

  /**
   * Returns the major and minor version numbers of this class.
   *
   * @return the <tt>int</tt> array { major version, minor version }  
   */

  public int[] getVersion () {
    return new int[] { readShort(6), readShort(4) };
  }

  /**
   * Makes the given visitor visit the Java class of this {@link ClassReader
   * ClassReader}. This class is the one specified in the constructor (see
   * {@link #ClassReader ClassReader}).
   *
   * @param classVisitor the visitor that must visit this class.
   * @param skipDebug <tt>true</tt> if the debug information of the class must
   *      not be visited. In this case the {@link CodeVisitor#visitLocalVariable
   *      visitLocalVariable} and {@link CodeVisitor#visitLineNumber
   *      visitLineNumber} methods will not be called.
   */

  public void accept (
    final ClassVisitor classVisitor,
    final boolean skipDebug)
  {
    accept(classVisitor, new Attribute[0], skipDebug);
  }

  /**
   * Makes the given visitor visit the Java class of this {@link ClassReader
   * ClassReader}. This class is the one specified in the constructor (see
   * {@link #ClassReader ClassReader}).
   *
   * @param classVisitor the visitor that must visit this class.
   * @param attrs prototypes of the attributes that must be parsed during the
   *      visit of the class. Any attribute whose type is not equal to the type
   *      of one the prototypes will be ignored.
   * @param skipDebug <tt>true</tt> if the debug information of the class must
   *      not be visited. In this case the {@link CodeVisitor#visitLocalVariable
   *      visitLocalVariable} and {@link CodeVisitor#visitLineNumber
   *      visitLineNumber} methods will not be called.
   */

  public void accept (
    final ClassVisitor classVisitor,
    final Attribute[] attrs,
    final boolean skipDebug)
  {
    byte[] b = this.b;                     // the bytecode array
    char[] c = new char[maxStringLength];  // buffer used to read strings
    int i, j, k;                           // loop variables
    int u, v, w;                           // indexes in b
    Attribute attr;

    // visits the header
    u = header;
    int access = readUnsignedShort(u);
    String className = readClass(u + 2, c);
    v = items[readUnsignedShort(u + 4)];
    String superClassName = v == 0 ? null : readUTF8(v, c);
    String[] implementedItfs = new String[readUnsignedShort(u + 6)];
    String sourceFile = null;
    Attribute clattrs = null;
    w = 0;
    u += 8;
    for (i = 0; i < implementedItfs.length; ++i) {
      implementedItfs[i] = readClass(u, c); u += 2;
    }
    // skips fields and methods
    v = u;
    i = readUnsignedShort(v); v += 2;
    for ( ; i > 0; --i) {
      j = readUnsignedShort(v + 6);
      v += 8;
      for ( ; j > 0; --j) {
        v += 6 + readInt(v + 2);
      }
    }
    i = readUnsignedShort(v); v += 2;
    for ( ; i > 0; --i) {
      j = readUnsignedShort(v + 6);
      v += 8;
      for ( ; j > 0; --j) {
        v += 6 + readInt(v + 2);
      }
    }
    // reads the class's attributes
    i = readUnsignedShort(v); v += 2;
    for ( ; i > 0; --i) {
      String attrName = readUTF8(v, c);
      if (attrName.equals("SourceFile")) {
        sourceFile = readUTF8(v + 6, c);
      } else if (attrName.equals("Deprecated")) {
        access |= Constants.ACC_DEPRECATED;
      } else if (attrName.equals("InnerClasses")) {
        w = v + 6;
      } else {
        attr = readAttribute(
          attrs, attrName, v + 6, readInt(v + 2), c, -1, null);
        if (attr != null) {
          attr.next = clattrs;
          clattrs = attr;
        }
      }
      v += 6 + readInt(v + 2);
    }
    // calls the visit method
    classVisitor.visit(
      access, className, superClassName, implementedItfs, sourceFile);

    // visits the inner classes info
    if (w != 0) {
      i = readUnsignedShort(w); w += 2;
      for ( ; i > 0; --i) {
        classVisitor.visitInnerClass(
          readUnsignedShort(w) == 0 ? null : readClass(w, c),
          readUnsignedShort(w + 2) == 0 ? null : readClass(w + 2, c),
          readUnsignedShort(w + 4) == 0 ? null : readUTF8(w + 4, c),
          readUnsignedShort(w + 6));
        w += 8;
      }
    }

    // visits the fields
    i = readUnsignedShort(u); u += 2;
    for ( ; i > 0; --i) {
      access = readUnsignedShort(u);
      String fieldName = readUTF8(u + 2, c);
      String fieldDesc = readUTF8(u + 4, c);
      Attribute fattrs = null;
      // visits the field's attributes and looks for a ConstantValue attribute
      int fieldValueItem = 0;
      j = readUnsignedShort(u + 6);
      u += 8;
      for ( ; j > 0; --j) {
        String attrName = readUTF8(u, c);
        if (attrName.equals("ConstantValue")) {
          fieldValueItem = readUnsignedShort(u + 6);
        } else if (attrName.equals("Synthetic")) {
          access |= Constants.ACC_SYNTHETIC;
        } else if (attrName.equals("Deprecated")) {
          access |= Constants.ACC_DEPRECATED;
        } else {
          attr = readAttribute(
            attrs, attrName, u + 6, readInt(u + 2), c, -1, null);
          if (attr != null) {
            attr.next = fattrs;
            fattrs = attr;
          }
        }
        u += 6 + readInt(u + 2);
      }
      // reads the field's value, if any
      Object value = (fieldValueItem == 0 ? null : readConst(fieldValueItem, c));
      // visits the field
      classVisitor.visitField(access, fieldName, fieldDesc, value, fattrs);
    }

    // visits the methods
    i = readUnsignedShort(u); u += 2;
    for ( ; i > 0; --i) {
      access = readUnsignedShort(u);
      String methName = readUTF8(u + 2, c);
      String methDesc = readUTF8(u + 4, c);
      Attribute mattrs = null;
      Attribute cattrs = null;
      v = 0;
      w = 0;
      // looks for Code and Exceptions attributes
      j = readUnsignedShort(u + 6);
      u += 8;
      for ( ; j > 0; --j) {
        String attrName = readUTF8(u, c); u += 2;
        int attrSize = readInt(u); u += 4;
        if (attrName.equals("Code")) {
          v = u;
        } else if (attrName.equals("Exceptions")) {
          w = u;
        } else if (attrName.equals("Synthetic")) {
          access |= Constants.ACC_SYNTHETIC;
        } else if (attrName.equals("Deprecated")) {
          access |= Constants.ACC_DEPRECATED;
        } else {
          attr = readAttribute(attrs, attrName, u, attrSize, c, -1, null);
          if (attr != null) {
            attr.next = mattrs;
            mattrs = attr;
          }
        }
        u += attrSize;
      }
      // reads declared exceptions
      String[] exceptions;
      if (w == 0) {
        exceptions = null;
      } else {
        exceptions = new String[readUnsignedShort(w)]; w += 2;
        for (j = 0; j < exceptions.length; ++j) {
          exceptions[j] = readClass(w, c); w += 2;
        }
      }

      // visits the method's code, if any
      CodeVisitor cv;
      cv = classVisitor.visitMethod(
        access, methName, methDesc, exceptions, mattrs);
      if (cv != null && v != 0) {
        int maxStack = readUnsignedShort(v);
        int maxLocals = readUnsignedShort(v + 2);
        int codeLength = readInt(v + 4);
        v += 8;

        int codeStart = v;
        int codeEnd = v + codeLength;

        // 1st phase: finds the labels
        int label;
        Label[] labels = new Label[codeLength + 1];
        while (v < codeEnd) {
          int opcode = b[v] & 0xFF;
          switch (ClassWriter.TYPE[opcode]) {
            case ClassWriter.NOARG_INSN:
            case ClassWriter.IMPLVAR_INSN:
              v += 1;
              break;
            case ClassWriter.LABEL_INSN:
              label = v - codeStart + readShort(v + 1);
              if (labels[label] == null) {
                labels[label] = new Label();
              }
              v += 3;
              break;
            case ClassWriter.LABELW_INSN:
              label = v - codeStart + readInt(v + 1);
              if (labels[label] == null) {
                labels[label] = new Label();
              }
              v += 5;
              break;
            case ClassWriter.WIDE_INSN:
              opcode = b[v + 1] & 0xFF;
              if (opcode == Constants.IINC) {
                v += 6;
              } else {
                v += 4;
              }
              break;
            case ClassWriter.TABL_INSN:
              // skips 0 to 3 padding bytes
              w = v - codeStart;
              v = v + 4 - (w & 3);
              // reads instruction
              label = w + readInt(v); v += 4;
              if (labels[label] == null) {
                labels[label] = new Label();
              }
              j = readInt(v); v += 4;
              j = readInt(v) - j + 1; v += 4;
              for ( ; j > 0; --j) {
                label = w + readInt(v); v += 4;
                if (labels[label] == null) {
                  labels[label] = new Label();
                }
              }
              break;
            case ClassWriter.LOOK_INSN:
              // skips 0 to 3 padding bytes
              w = v - codeStart;
              v = v + 4 - (w & 3);
              // reads instruction
              label = w + readInt(v); v += 4;
              if (labels[label] == null) {
                labels[label] = new Label();
              }
              j = readInt(v); v += 4;
              for ( ; j > 0; --j) {
                v += 4; // skips key
                label = w + readInt(v); v += 4;
                if (labels[label] == null) {
                  labels[label] = new Label();
                }
              }
              break;
            case ClassWriter.VAR_INSN:
            case ClassWriter.SBYTE_INSN:
            case ClassWriter.LDC_INSN:
              v += 2;
              break;
            case ClassWriter.SHORT_INSN:
            case ClassWriter.LDCW_INSN:
            case ClassWriter.FIELDORMETH_INSN:
            case ClassWriter.TYPE_INSN:
            case ClassWriter.IINC_INSN:
              v += 3;
              break;
            case ClassWriter.ITFMETH_INSN:
              v += 5;
              break;
            // case MANA_INSN:
            default:
              v += 4;
              break;
          }
        }
        // parses the try catch entries
        j = readUnsignedShort(v); v += 2;
        for ( ; j > 0; --j) {
          label = readUnsignedShort(v);
          if (labels[label] == null) {
            labels[label] = new Label();
          }
          label = readUnsignedShort(v + 2);
          if (labels[label] == null) {
            labels[label] = new Label();
          }
          label = readUnsignedShort(v + 4);
          if (labels[label] == null) {
            labels[label] = new Label();
          }
          v += 8;
        }
        // parses the local variable, line number tables, and code attributes
        j = readUnsignedShort(v); v += 2;
        for ( ; j > 0; --j) {
          String attrName = readUTF8(v, c);
          if (attrName.equals("LocalVariableTable")) {
            if (!skipDebug) {
              k = readUnsignedShort(v + 6);
              w = v + 8;
              for ( ; k > 0; --k) {
                label = readUnsignedShort(w);
                if (labels[label] == null) {
                  labels[label] = new Label();
                }
                label += readUnsignedShort(w + 2);
                if (labels[label] == null) {
                  labels[label] = new Label();
                }
                w += 10;
              }
            }
          } else if (attrName.equals("LineNumberTable")) {
            if (!skipDebug) {
              k = readUnsignedShort(v + 6);
              w = v + 8;
              for ( ; k > 0; --k) {
                label = readUnsignedShort(w);
                if (labels[label] == null) {
                  labels[label] = new Label();
                }
                w += 4;
              }
            }
          } else {
            for (k = 0; k < attrs.length; ++k) {
              if (attrs[k].type.equals(attrName)) {
                attr = attrs[k].read(
                  this, v + 6, readInt(v + 2), c, codeStart - 8, labels);
                if (attr != null) {
                  attr.next = cattrs;
                  cattrs = attr;
                }
              }
            }
          }
          v += 6 + readInt(v + 2);
        }

        // 2nd phase: visits each instruction
        v = codeStart;
        Label l;
        while (v < codeEnd) {
          w = v - codeStart;
          l = labels[w];
          if (l != null) {
            cv.visitLabel(l);
          }
          int opcode = b[v] & 0xFF;
          switch (ClassWriter.TYPE[opcode]) {
            case ClassWriter.NOARG_INSN:
              cv.visitInsn(opcode);
              v += 1;
              break;
            case ClassWriter.IMPLVAR_INSN:
              if (opcode > Constants.ISTORE) {
                opcode -= 59; //ISTORE_0
                cv.visitVarInsn(Constants.ISTORE + (opcode >> 2), opcode & 0x3);
              } else {
                opcode -= 26; //ILOAD_0
                cv.visitVarInsn(Constants.ILOAD + (opcode >> 2), opcode & 0x3);
              }
              v += 1;
              break;
            case ClassWriter.LABEL_INSN:
              cv.visitJumpInsn(opcode, labels[w + readShort(v + 1)]);
              v += 3;
              break;
            case ClassWriter.LABELW_INSN:
              cv.visitJumpInsn(opcode, labels[w + readInt(v + 1)]);
              v += 5;
              break;
            case ClassWriter.WIDE_INSN:
              opcode = b[v + 1] & 0xFF;
              if (opcode == Constants.IINC) {
                cv.visitIincInsn(readUnsignedShort(v + 2), readShort(v + 4));
                v += 6;
              } else {
                cv.visitVarInsn(opcode, readUnsignedShort(v + 2));
                v += 4;
              }
              break;
            case ClassWriter.TABL_INSN:
              // skips 0 to 3 padding bytes
              v = v + 4 - (w & 3);
              // reads instruction
              label = w + readInt(v); v += 4;
              int min = readInt(v); v += 4;
              int max = readInt(v); v += 4;
              Label[] table = new Label[max - min + 1];
              for (j = 0; j < table.length; ++j) {
                table[j] = labels[w + readInt(v)];
                v += 4;
              }
              cv.visitTableSwitchInsn(min, max, labels[label], table);
              break;
            case ClassWriter.LOOK_INSN:
              // skips 0 to 3 padding bytes
              v = v + 4 - (w & 3);
              // reads instruction
              label = w + readInt(v); v += 4;
              j = readInt(v); v += 4;
              int[] keys = new int[j];
              Label[] values = new Label[j];
              for (j = 0; j < keys.length; ++j) {
                keys[j] = readInt(v); v += 4;
                values[j] = labels[w + readInt(v)]; v += 4;
              }
              cv.visitLookupSwitchInsn(labels[label], keys, values);
              break;
            case ClassWriter.VAR_INSN:
              cv.visitVarInsn(opcode, b[v + 1] & 0xFF);
              v += 2;
              break;
            case ClassWriter.SBYTE_INSN:
              cv.visitIntInsn(opcode, b[v + 1]);
              v += 2;
              break;
            case ClassWriter.SHORT_INSN:
              cv.visitIntInsn(opcode, readShort(v + 1));
              v += 3;
              break;
            case ClassWriter.LDC_INSN:
              cv.visitLdcInsn(readConst(b[v + 1] & 0xFF, c));
              v += 2;
              break;
            case ClassWriter.LDCW_INSN:
              cv.visitLdcInsn(readConst(readUnsignedShort(v + 1), c));
              v += 3;
              break;
            case ClassWriter.FIELDORMETH_INSN:
            case ClassWriter.ITFMETH_INSN:
              int cpIndex = items[readUnsignedShort(v + 1)];
              String iowner = readClass(cpIndex, c);
              cpIndex = items[readUnsignedShort(cpIndex + 2)];
              String iname = readUTF8(cpIndex, c);
              String idesc = readUTF8(cpIndex + 2, c);
              if (opcode < Constants.INVOKEVIRTUAL) {
                cv.visitFieldInsn(opcode, iowner, iname, idesc);
              } else {
                cv.visitMethodInsn(opcode, iowner, iname, idesc);
              }
              if (opcode == Constants.INVOKEINTERFACE) {
                v += 5;
              } else {
                v += 3;
              }
              break;
            case ClassWriter.TYPE_INSN:
              cv.visitTypeInsn(opcode, readClass(v + 1, c));
              v += 3;
              break;
            case ClassWriter.IINC_INSN:
              cv.visitIincInsn(b[v + 1] & 0xFF, b[v + 2]);
              v += 3;
              break;
            // case MANA_INSN:
            default:
              cv.visitMultiANewArrayInsn(readClass(v + 1, c), b[v + 3] & 0xFF);
              v += 4;
              break;
          }
        }
        l = labels[codeEnd - codeStart];
        if (l != null) {
          cv.visitLabel(l);
        }
        // visits the try catch entries
        j = readUnsignedShort(v); v += 2;
        for ( ; j > 0; --j) {
          Label start = labels[readUnsignedShort(v)];
          Label end = labels[readUnsignedShort(v + 2)];
          Label handler = labels[readUnsignedShort(v + 4)];
          int type = readUnsignedShort(v + 6);
          if (type == 0) {
            cv.visitTryCatchBlock(start, end, handler, null);
          } else {
            cv.visitTryCatchBlock(start, end, handler, readUTF8(items[type], c));
          }
          v += 8;
        }
        // visits the local variable and line number tables
        j = readUnsignedShort(v); v += 2;
        if (!skipDebug) {
          for ( ; j > 0; --j) {
            String attrName = readUTF8(v, c);
            if (attrName.equals("LocalVariableTable")) {
              k = readUnsignedShort(v + 6);
              w = v + 8;
              for ( ; k > 0; --k) {
                label = readUnsignedShort(w);
                Label start = labels[label];
                label += readUnsignedShort(w + 2);
                Label end = labels[label];
                cv.visitLocalVariable(
                  readUTF8(w + 4, c),
                  readUTF8(w + 6, c),
                  start,
                  end,
                  readUnsignedShort(w + 8));
                w += 10;
              }
            } else if (attrName.equals("LineNumberTable")) {
              k = readUnsignedShort(v + 6);
              w = v + 8;
              for ( ; k > 0; --k) {
                cv.visitLineNumber(
                  readUnsignedShort(w + 2),
                  labels[readUnsignedShort(w)]);
                w += 4;
              }
            }
            v += 6 + readInt(v + 2);
          }
        }
        // visits the other attributes
        while (cattrs != null) {
          attr = cattrs.next;
          cattrs.next = null;
          cv.visitAttribute(cattrs);
          cattrs = attr;
        }
        // visits the max stack and max locals values
        cv.visitMaxs(maxStack, maxLocals);
      }
    }
    // visits the class attributes
    while (clattrs != null) {
      classVisitor.visitAttribute(clattrs);
      clattrs = clattrs.next;
    }
    // visits the end of the class
    classVisitor.visitEnd();
  }

  // --------------------------------------------------------------------------
  // Utility methods: low level parsing
  // --------------------------------------------------------------------------

  /**
   * Reads a byte value in {@link #b b}. <i>This method is intended
   * for {@link Attribute} sub classes, and is normally not needed by class
   * generators or adapters.</i>
   *
   * @param index the start index of the value to be read in {@link #b b}.
   * @return the read value.
   */

  public int readByte (final int index) {
    return b[index] & 0xFF;
  }

  /**
   * Reads an unsigned short value in {@link #b b}. <i>This method is intended
   * for {@link Attribute} sub classes, and is normally not needed by class
   * generators or adapters.</i>
   *
   * @param index the start index of the value to be read in {@link #b b}.
   * @return the read value.
   */

  public int readUnsignedShort (final int index) {
    byte[] b = this.b;
    return ((b[index] & 0xFF) << 8) | (b[index + 1] & 0xFF);
  }

  /**
   * Reads a signed short value in {@link #b b}. <i>This method is intended
   * for {@link Attribute} sub classes, and is normally not needed by class
   * generators or adapters.</i>
   *
   * @param index the start index of the value to be read in {@link #b b}.
   * @return the read value.
   */

  public short readShort (final int index) {
    byte[] b = this.b;
    return (short)(((b[index] & 0xFF) << 8) | (b[index + 1] & 0xFF));
  }

  /**
   * Reads a signed int value in {@link #b b}. <i>This method is intended
   * for {@link Attribute} sub classes, and is normally not needed by class
   * generators or adapters.</i>
   *
   * @param index the start index of the value to be read in {@link #b b}.
   * @return the read value.
   */

  public int readInt (final int index) {
    byte[] b = this.b;
    return ((b[index] & 0xFF) << 24) |
           ((b[index + 1] & 0xFF) << 16) |
           ((b[index + 2] & 0xFF) << 8) |
           (b[index + 3] & 0xFF);
  }

  /**
   * Reads a signed long value in {@link #b b}. <i>This method is intended
   * for {@link Attribute} sub classes, and is normally not needed by class
   * generators or adapters.</i>
   *
   * @param index the start index of the value to be read in {@link #b b}.
   * @return the read value.
   */

  public long readLong (final int index) {
    long l1 = readInt(index);
    long l0 = readInt(index + 4) & 0xFFFFFFFFL;
    return (l1 << 32) | l0;
  }

  /**
   * Reads an UTF8 string constant pool item in {@link #b b}. <i>This method is
   * intended for {@link Attribute} sub classes, and is normally not needed by
   * class generators or adapters.</i>
   *
   * @param index the start index of an unsigned short value in {@link #b b},
   *      whose value is the index of an UTF8 constant pool item.
   * @param buf buffer to be used to read the item. This buffer must be
   *      sufficiently large. It is not automatically resized.
   * @return the String corresponding to the specified UTF8 item.
   */

  public String readUTF8 (int index, final char[] buf) {
    // consults cache
    int item = readUnsignedShort(index);
    String s = strings[item];
    if (s != null) {
      return s;
    }
    // computes the start index of the CONSTANT_Utf8 item in b
    index = items[item];
    // reads the length of the string (in bytes, not characters)
    int utfLen = readUnsignedShort(index);
    index += 2;
    // parses the string bytes
    int endIndex = index + utfLen;
    byte[] b = this.b;
    int strLen = 0;
    int c, d, e;
    while (index < endIndex) {
      c = b[index++] & 0xFF;
      switch (c >> 4) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
          // 0xxxxxxx
          buf[strLen++] = (char)c;
          break;
        case 12:
        case 13:
          // 110x xxxx   10xx xxxx
          d = b[index++];
          buf[strLen++] = (char)(((c & 0x1F) << 6) | (d & 0x3F));
          break;
        default:
          // 1110 xxxx  10xx xxxx  10xx xxxx
          d = b[index++];
          e = b[index++];
          buf[strLen++] =
            (char)(((c & 0x0F) << 12) | ((d & 0x3F) << 6) | (e & 0x3F));
          break;
      }
    }
    s = new String(buf, 0, strLen);
    strings[item] = s;
    return s;
  }

  /**
   * Reads a class constant pool item in {@link #b b}. <i>This method is
   * intended for {@link Attribute} sub classes, and is normally not needed by
   * class generators or adapters.</i>
   *
   * @param index the start index of an unsigned short value in {@link #b b},
   *      whose value is the index of a class constant pool item.
   * @param buf buffer to be used to read the item. This buffer must be
   *      sufficiently large. It is not automatically resized.
   * @return the String corresponding to the specified class item.
   */

  public String readClass (final int index, final char[] buf) {
    // computes the start index of the CONSTANT_Class item in b
    // and reads the CONSTANT_Utf8 item designated by
    // the first two bytes of this CONSTANT_Class item
    return readUTF8(items[readUnsignedShort(index)], buf);
  }

  /**
   * Reads a numeric or string constant pool item in {@link #b b}. <i>This
   * method is intended for {@link Attribute} sub classes, and is normally not
   * needed by class generators or adapters.</i>
   *
   * @param item the index of a constant pool item.
   * @param buf buffer to be used to read the item. This buffer must be
   *      sufficiently large. It is not automatically resized.
   * @return the {@link java.lang.Integer Integer}, {@link java.lang.Float
   *      Float}, {@link java.lang.Long Long}, {@link java.lang.Double Double}
   *      or {@link String String} corresponding to the given constant pool
   *      item.
   */

  public Object readConst (final int item, final char[] buf) {
    int index = items[item];
    switch (b[index - 1]) {
      case ClassWriter.INT:
        return new Integer(readInt(index));
      case ClassWriter.FLOAT:
        return new Float(Float.intBitsToFloat(readInt(index)));
      case ClassWriter.LONG:
        return new Long(readLong(index));
      case ClassWriter.DOUBLE:
        return new Double(Double.longBitsToDouble(readLong(index)));
      //case ClassWriter.STR:
      default:
        return readUTF8(index, buf);
    }
  }

  /**
   * Reads an attribute in {@link #b b}. The default implementation of this
   * method returns <tt>null</tt> for all attributes.
   *
   * @param attrs prototypes of the attributes that must be parsed during the
   *      visit of the class. Any attribute whose type is not equal to the type
   *      of one the prototypes will be ignored.
   * @param type the type of the attribute.
   * @param off index of the first byte of the attribute's content in {@link #b
   *      b}. The 6 attribute header bytes, containing the type and the length
   *      of the attribute, are not taken into account here (they have already
   *      been read).
   * @param len the length of the attribute's content.
   * @param buf buffer to be used to call {@link #readUTF8 readUTF8}, {@link
   *      #readClass readClass} or {@link #readConst readConst}.
   * @param codeOff index of the first byte of code's attribute content in
   *      {@link #b b}, or -1 if the attribute to be read is not a code
   *      attribute. The 6 attribute header bytes, containing the type and the
   *      length of the attribute, are not taken into account here.
   * @param labels the labels of the method's code, or <tt>null</tt> if the
   *      attribute to be read is not a code attribute.
   * @return the attribute that has been read, or <tt>null</tt> to skip this
   *      attribute.
   */

  protected Attribute readAttribute (
    final Attribute[] attrs,
    final String type,
    final int off,
    final int len,
    final char[] buf,
    final int codeOff,
    final Label[] labels)
  {
    for (int i = 0; i < attrs.length; ++i) {
      if (attrs[i].type.equals(type)) {
        return attrs[i].read(this, off, len, buf, codeOff, labels);
      }
    }
    return null;
  }
}
