	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	user_stack:	.zero 128
	expr_result:	.word   0

.text
	.global main
	postfix_expr:   .asciz    "-100 10 20 + - 10 +"

main:
	LDR	R0, =postfix_expr
	ldr r2, =user_stack
	add r2, r2, #128
	msr msp, r2

	mov r2, #10
	mov r3, #-1

ScanString:
	movs r4, #0 				//negative judge
	mov r5, #0
    ldrb r1, [r0], #1

    cmp r1, #0x20				//space
    beq ScanString

    cmp r1, #0   				//end
    beq program_end

    bl atoi
	b ScanString

program_end:
	ldr r6, =expr_result
	pop {r7}
	str r7, [r6]
	B L


atoi:
    //TODO: implement a “convert string to integer” function
    cmp r1, #0x2D
    bne cond				//'+' or num
    //minus handling
    ldrb r1, [r0], #-1
    cmp r1, #0
    beq program_end
    cmp r1, #0x20
    beq precond//just minus  '-'
    //is negative
    movs r4, #1
    add r0, r0, #2
    b is_num

	cond:
		cmp r1, #0x2B		//'+'
		beq do_add

		cmp r1, #0x2D		//'-'
		beq do_sub

	is_num:
		//num
		subs r1, r1, #48
		muls r5, r5, r2
		adds r5, r5, r1

		ldrb r1, [r0], #1
		cmp r1, #0x20
		beq atoi_end

		b is_num

do_add:
	POP {r6, r7}
	adds r5, r6, r7
	b atoi_end
do_sub:
	POP {r6, r7}
	subs r5, r7, r6
	b atoi_end
atoi_end:
	cmp r4, #1
	bne	end
	muls r5, r5, r3

	end:
	PUSH {r5}
    BX LR

precond:
	ldrb r1, [r0]
	add r0, r0, #1
	b cond

L: B L
/*
r1 parse string
r4 judge negative
r5 count integer

*/
