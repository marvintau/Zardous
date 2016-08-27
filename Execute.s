
# EXECUTE
# ====================
# The term "Execute" can be understood as modifying the
# order of reading and performing the instructions. But
# differing to control flow, the instructions that being
# executed is subsidiary to some other instructions.

# In order to control the execution, we only need two
# registers. One holds the address to be jumped and the
# other the address to be jumped out to.

# Since we have the words that refer to other words, rather
# than merely containing code, we need to use indirected
# addressing. Instead of jumping to the address stored
# in register, the program jumps to the address, that
# stored in some other certain address, which stored in
# that register. Like second-order jump.

# This second-order jump means that the content in the
# register, must POINT to some address which is the start
# of executable instructions. This basically formed the
# structure of the entries.

EntryHeader BacktracingPrint
    jmp BacktracingPrintStart

Arrow:
    .ascii " ==> "

BacktracingPrintStart:

    pushq   %rax
    pushq   %rbx
    pushq   %rcx
    pushq   %rdi
    pushq   %rsi
    pushq   %rdx
    pushq   %r11

    movq    EvaluationLevel(%rip), %rax
    cmpq     $(0), %rax
    je      BacktracingPrintContinue

    # %r12 currently points to the address where actual
    # code or the code of enterword begins. The following
    # two steps makes %rax points to the entry header.
    movq    %r12, %rax              
    subq    -8(%rax), %rax          
                                   
    movq    (%rax), %rdx           
    leaq    8(%rax), %rsi

    movq    $SyscallDisplay, %rax
    movq    $(1), %rdi
    movq    $(1), %rbx
    syscall

    movq   $SyscallDisplay, %rax
    movq   $(1), %rdi
    movq   $(1), %rbx
    leaq   Arrow(%rip), %rsi
    movq   $(5), %rdx
    syscall

    
BacktracingPrintContinue:
 
    popq    %r11
    popq    %rdx
    popq    %rsi
    popq    %rdi
    popq    %rcx
    popq    %rbx
    popq    %rax
    ret
EntryEnd BacktracingPrint 

EntryHeader ExecuteNextWord
    call BacktracingPrint
    movq  (%r13), %r12
    leaq 8(%r13), %r13
    jmpq *(%r12)
EntryEnd ExecuteNextWord

# ENTERWORD
# =====================
# EnterWord is a subroutine that essentially does two things
# First it stores the original Return Address Register (RAR),
# which similar to the frame register that stores the caller
# address in function call. Secondly it leads the instruction
# pointer points to the referred entry by changing the Entry
# Register (ER).


EntryHeader EnterWord
    PushStack %r13
    leaq 8(%r12),  %r12
    movq   %r12,   %r13
    jmp ExecuteNextWord
EntryEnd EnterWord

EntryHeader SystemEntrance
ExitAddress:
    .quad SystemExit

ExecuteSystemWord:
    leaq ExitAddress(%rip), %r13
    
    movq %r11, %r12
    jmp  *(%r12)
EntryEnd SystemEntrance

# ======================================================
# EVAL
# ======================================================
# Save the current runtime context and go to the routine
# defined by user words. No registers are preserved, but
# guaranteed to lead the instruction pointer back.

Code Eval
    
    # For debugging
    incq EvaluationLevel(%rip)

    # Save context and prepare to jump to the new
    # session
    movq %r11, %r12
    GoToDefinition %r12
    PushStack %r13
    leaq ReturnAddress(%rip), %r13
    
    jmp *(%r12)

    # -------------LEFT CURRENT SESSION-----------------

    EvaluateDone:
        decq EvaluationLevel(%rip)
        PopStack %r13

    # 4 for the distance between Cond and DefineLiteral 
    movq $(4), %rax
    # leave this to Cond
    push %rax


CodeEnd Eval

# ======================================================
# RETURN
# ======================================================
# A word that merely referred by Eval, that guide the
# instruction pointer back to the code starting from
# EvaluateDone in Eval.
Code Return 
    jmp EvaluateDone 
ReturnAddress:
    .quad Return
CodeEnd Return
