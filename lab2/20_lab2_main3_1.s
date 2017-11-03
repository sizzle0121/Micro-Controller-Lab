.syntax unified
	.cpu cortex-m4
	.thumb
.data
    result: .byte 0
	
.text
    .global main
.equ X, 0x55AA
.equ Y, 0xAA55

hamm:
    //TODO
    EORS R3 ,R0 ,R1
    LDR R5 ,[R2]
	loop:
		AND R4 ,R3 ,#1

		cmp R4 ,#1
		bne flag
		add R5 ,R5 ,#1
	flag:
		LSRS R3 ,R3, #1
	bne loop

	str R5, [R2]
	bx lr
main:
   //movs R0, #X //This code will cause assemble error. Why? And how to fix.
   // movs R1, #Y
    LDR R0, =X
    LDR R1, =Y
    LDR R2, =result
    bl hamm
L: b L
