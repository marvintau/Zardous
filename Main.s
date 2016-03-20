/**
 *  Exor experiment program
 *  =======================
 *  Containing learning notes and resources
 */

.section __TEXT, __text
.include "Dictionary.s"
.include "Lexer.s"
.include "IO.s"

.globl _main

PrintWord:
	Print %r15, %r14
	ret

Find:
	FindEntry %r15, %r14, %r13, %r12, %r11
	ret

_main:

	ScanInputBuffer	
	ApplyToUserInputWith Find, WithOffsetOf, %r15, AndLengthof, %r14

	// call Find

	movq $SyscallExit, %rax
	syscall

.section __DATA, __data
.include "DataSegment.s"
