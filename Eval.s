# EvaluateEntry will be playing the role as exec,
# eval or similar functions in most of the main-
# stream dynamic interpreting language. Evaluate-
# Entry should returns to the calling point after
# evaluate the new entry. Since EvaluateEntry will
# break the normal traversing of evaluation tree,
# A dedicated stack should be created for this
# code word. 

Word Eval
    .quad EvalCore
WordEnd Eval

# The real eval routine extracted from evalEntry.
# %r11 will be the destination entry.
Code EvalCore

    # receive entry entrance address from MatchName
    pop  %r11

    movq %r11, %r12
    GoToDefinition %r12

    PushStack %r13

    incq EvaluationLevel(%rip)
    
    leaq ReturnAddress(%rip), %r13

    jmp *(%r12)

    EvaluateDone:
        decq EvaluationLevel(%rip)
        PopStack %r13

    # Leave this to DefineLiteral 
    push %r11

    # 4 for the distance between Cond and DefineLiteral 
    movq $(4), %rax
    # leave this to Cond
    push %rax


CodeEnd EvalCore

# ReturnLexer will be automatically pushed into
# the return stack of the word being evaluated,
# coerced to return to the evaluating point.

Code Return 
    jmp EvaluateDone 
ReturnAddress:
    .quad Return
CodeEnd Return
