.include "Match.s"

# LOCATE WORD BOUND
# =====================================================
# A register holds the address of last char decrease every
# time and checks two consecutive chars (a bigram) at that
# position. If a bigram wit "C_" pattern is found, then
# assign the address to EndReg, and if a bigram with "_C"
# found, then leave the subroutine, and the current char
# position (StartReg) along with the end position (EndReg)
# will be used in the next stage.

.macro LocateWordBound StartReg, EndReg 

    leaq InputBuffer(%rip), %rax 

    NextBigram:
        cmpq \StartReg, %rax 
        je   WordLocated

        cmpb $(0x20), (\StartReg)
        je   StartWithSpace
        jne  StartWithChar

        StartWithSpace:
            cmpb $(0x20), -1(\StartReg)
            je  MoveCurr 

            CharNext:
                movq \StartReg, \EndReg
                jmp MoveCurr 

        StartWithChar:
            cmpb $(0x20), -1(\StartReg) 
            jne MoveCurr 

            SpaceNext:

                jmp WordLocated

        MoveCurr:

            decq \StartReg
        
        jmp NextBigram 

    WordLocated:

.endm

.macro ParseDecimal StartReg, LenReg

    xorq  %rax, %rax
    xorq  %rbx, %rbx
    xorq  %rcx, %rcx

    ParseDecimalForEachDigit:
        imul $10, %rax
        
        movzbq (\StartReg, %rcx), %rbx
        subq $0x30, %rbx
        addq %rbx, %rax 
        
        incq %rcx
        cmpq %rcx, \LenReg

        jne ParseDecimalForEachDigit
CheckRax:

    PushDataStack %rax

.endm

.macro ParseHex StartReg, LenReg

    xorq  %rax, %rax
    xorq  %rbx, %rbx
    xorq  %rcx, %rcx

    ParseHexForEachDigit:
        imul $0x10, %rax
        
        movzbq (\StartReg, %rcx), %rbx
        cmpb $0x60,  %bl
        jg Hex
            subq $0x30, %rbx
            jmp ParseHexCheckDone
        Hex:
            subq $0x57, %rbx

        ParseHexCheckDone:
        
        addq %rbx, %rax 
        
        incq %rcx
        cmpq %rcx, \LenReg

        jne ParseHexForEachDigit

    PushDataStack %rax

.endm
