	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	user_stack: .zero 2048 
	result: .word  0
	max_size:  .word  0

.text
	.global main
	m: .word  0x5E//0x7D
	n: .word  0x60//0x271


fix_depth:
	mrs r1, msp
	cmp r1, r0
	bgt fix_depth_fin
	add r0, r1, #0
	fix_depth_fin:
	bx lr
GCD:
	//GCD(A,B)
    //TODO: Implement your GCD function
	push {r1-r3,lr}
	BL fix_depth

	ldr r2, [sp, #4] // r2 == A
	ldr r3, [sp, #8] // r3 == B
	cmp r2, #0
	beq return_B
	cmp r3, #0
	beq return_A

	and r4, r2, #1
	and r5, r3, #1

	cmp r4, #0
	beq A_is_even
	b   A_is_odd


return_A:
	str r2, [sp]
	b fin
return_B:
	str r3, [sp]
	b fin
A_is_even:
	cmp r5, #0
	beq even_even
	b even_odd
A_is_odd:
	cmp r5, #0
	beq odd_even
	b odd_odd
even_even:
	asr r2, r2, #1
	asr r3, r3, #1
	BL GCD
	lsl r1, r1, #1
	b fill_ans
even_odd:
	asr r2, r2, #1
	BL GCD
	b fill_ans
odd_even:
	asr r3, r3, #1
	BL GCD
	b fill_ans
odd_odd:
	cmp r2, r3
	blt A_small
	b B_small
	A_small:
		sub r3, r3, r2
		BL GCD
		b fill_ans
	B_small:
		sub r2, r2, r3
		BL GCD
		b fill_ans
fill_ans:
	str r1, [sp]
fin:
	pop {r1-r3,pc}
	BX LR

main:
	ldr r0, =user_stack
	add r0, r0, #2048
	add r7, r0, #0
	msr psp, r0
	msr msp, r0
	ldr r2, m
	ldr r3, n
//	ldr r3, [r4]

	bl GCD

	sub r0, r7, r0
	lsr r0, r0, #2
	ldr r2, =max_size
	str r0, [r2]
	ldr r2, =result
	str r1, [r2]

    //add r0, r0, #0
L: B L

