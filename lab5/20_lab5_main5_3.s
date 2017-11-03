	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	fibA: .word 0x1
	fibB: .word 0x1
.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OTYPER, 0x48000004
	.equ GPIOA_OSPEEDR, 0x48000008
	.equ GPIOA_PUPDR, 0x4800000C
	.equ GPIOA_ODR, 0x48000014
	.equ DECODE_MODE, 0x09
	.equ INTENSITY, 0x0A
	.equ SCAN_LIMIT, 0x0B
	.equ SHUTDOWN, 0x0C
	.equ DISPLAY_TEST, 0x0F
	.equ DIN, 0x20
	.equ CS, 0x40
	.equ CLOCK, 0x80
	.equ GPIO_BSRR_OFFSET, 0x18
	.equ GPIO_BRR_OFFSET, 0x28
	//user-buttom
	.equ GPIOC_MODER, 0x48000800
	.equ GPIOC_IDR, 0x48000810
	//delay
	.equ X, 40
	.equ Y, 6900

main:
    BL   GPIO_init
    BL   max7219_init
    //TODO: display your student id on 7-Seg LED

reset_fib:
    ldr r0, =#0x01
    ldr r1, =#0x0
    bl 	MAX7219Send
    ldr r0, =#0x01
    ldr r1, =#0x0
    bl 	MAX7219Send
    ldr r0, =#0x02
    ldr r1, =#15
    bl 	MAX7219Send
    ldr r0, =#0x03
    ldr r1, =#15
    bl 	MAX7219Send
    ldr r0, =#0x04
    ldr r1, =#15
    bl 	MAX7219Send
    ldr r0, =#0x05
    ldr r1, =#15
    bl 	MAX7219Send
    ldr r0, =#0x06
    ldr r1, =#15
    bl 	MAX7219Send
    ldr r0, =#0x07
    ldr r1, =#15
    bl 	MAX7219Send
    ldr r0, =#0x08
    ldr r1, =#15
    bl 	MAX7219Send
    movs r7, #0
    movs r8, #0

    mov r5, #1
    ldr r9, =fibA
    str r5, [r9]
    ldr r4, =fibB
    str r5, [r4]

//r0 position of each bit
//r1 data
//r3 buttom input
//r4 mask for judging the condtion of the buttom
//r5 counter for debouncing
//r7 index of fib
//r8 1:on, 0:off
loop:
	mov r5, #0
	bl event
	cmp r8, #2
	beq reset_fib
	cmp r8, #1
	bne loop


	ldr r9, =fibA
	ldr r4, =fibB
    ldr r0, =#1
	bl update

	b loop


update:
	push {lr}
	calculate:
		cmp r7, #0
		beq no_claculate1
		cmp r7, #1
		beq no_calculate2
		cmp r7, #3
		beq display_minus

		ldr r5, [r9]
		ldr r6, [r4]
		adds r5, r5, r6
		str r5, [r4]
		str r6, [r9]

		ldr r2, =#100000000
		cmp r5, r2
		bge display_minus
		b display

		no_claculate1:
			ldr r5, [r9]
			adds r7, r7, #1
			b display
		no_calculate2:
			ldr r5, [r4]
			adds r7, r7, #1
			b display

	//right now, answer is in r5
	display:

		mov r2, #10
		cmp r5, #0
		beq set_blank

		udiv r1, r5, r2
		mul r1, r1, r2
		subs r1, r5, r1
		udiv r5, r5, r2
		b max_send

		set_blank:
			mov r1, #15

		max_send:
			bl MAX7219Send
			add r0, r0, #1  		//position of each bit
			cmp r0, #9
			bne display
	mov r0, #1
	movs r8, #0
pop {lr}
bx lr
	display_minus:
		mov r7, #3
		ldr r0, =#1
		ldr r1, =#1
		bl 	MAX7219Send
		ldr r0, =#2
		ldr r1, =#0x0A
		bl 	MAX7219Send
	    ldr r0, =#0x03
	    ldr r1, =#15
	    bl 	MAX7219Send
	    ldr r0, =#0x04
	    ldr r1, =#15
	    bl 	MAX7219Send
	    ldr r0, =#0x05
	    ldr r1, =#15
	    bl 	MAX7219Send
	    ldr r0, =#0x06
	    ldr r1, =#15
	    bl 	MAX7219Send
	    ldr r0, =#0x07
	    ldr r1, =#15
	    bl 	MAX7219Send
	    ldr r0, =#0x08
	    ldr r1, =#15
	    bl 	MAX7219Send
	movs r8, #0
pop {lr}
bx lr


GPIO_init:
	//TODO: Initialize three GPIO pins as output for max7219 DIN, CS and CLK
	//enable port A
	movs r0, #0x5
	ldr r1, =RCC_AHB2ENR
	str r0, [r1]
	//set output mode
	movs r0, #0x5400
	ldr r1, =GPIOA_MODER
	ldr r2, [r1]
	and r2, r2, #0xFFFF03FF
	orrs r2, r2, r0
	str r2, [r1]
	//set speed
	ldr r0, =0xA800
	ldr r1, =GPIOA_OSPEEDR
	strh r0, [r1]

	//set port C to input mode
	ldr r0, =GPIOC_MODER
    ldr r1, [r0]
    ldr r2, =#0xF3FFFFFF
    and r1, r2
    str r1, [r0]
	BX LR

MAX7219Send:
	//input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	push {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, lr}
	lsl r0, r0, #8
	add r0, r0, r1	//16 bits for DIN to eat
	ldr r1, =#GPIOA_MODER
	ldr r2, =#CS
	ldr r3, =#DIN
	ldr r4, =#CLOCK
	ldr r5, =#GPIO_BSRR_OFFSET
	ldr r6, =#GPIO_BRR_OFFSET
	mov r7, #16

	//str r2, [r1, r6]
	max7219send_loop:
		mov r8, #1
		sub r9, r7, #1
		lsl r8, r8, r9
		str r4, [r1, r6]
		//tst r0, r8					//wtf
		ands r8, r0, r8
		lsr r8, r8, r9
		cmp r8, #0
		beq is_zero
		str r3, [r1, r5]
		b finish
	is_zero:
		str r3, [r1, r6]
	finish:
		str r4, [r1, r5]
		subs r7, r7, #1
		bgt max7219send_loop
		str r2, [r1, r6]			//reset
		str r2, [r1, r5]

	pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, lr}
	BX LR

max7219_init:
	//TODO: Initial max7219 registers.
	//r0:address, r1:data
	push {r0, r1, r2, LR}
	ldr r0, =#DECODE_MODE
	ldr r1, =#0xFF
	bl MAX7219Send
	ldr r0, =#DISPLAY_TEST
	ldr r1, =#0x0
	bl MAX7219Send
	ldr r0, =#SCAN_LIMIT
	ldr r1, =#0x07
	bl MAX7219Send
	ldr r0, =#INTENSITY
	ldr r1, =#0x0
	bl MAX7219Send
	ldr r0, =#SHUTDOWN
	ldr r1, =#0x1
	bl MAX7219Send
	pop {r0, r1, r2, LR}
	BX LR

event:
push {r0, r1, r2, r3, r4, r5, r6, r7, r9, lr}
	ldr r2, =#16000
	ldr r1, =#100000
	debounce:
	ldr r3, =GPIOC_IDR	//initialize buttom off
	movs r4, #1
	lsl r4, #13
	ldr r0, [r3]		//load input content
	and r0, r0, r4
	lsr r0, r0, #13
	cmp r0, #0
	bne no_press_now
	add r5, r5, #1
	b debounce
	no_press_now:
	cmp r5, r1
	bge one_second
	cmp r5, r2
	bge press

	mov r8, #0
pop {r0, r1, r2, r3, r4, r5, r6, r7, r9, lr}
bx lr

press:
	mov r8, #1
pop {r0, r1, r2, r3, r4, r5, r6, r7, r9, lr}
bx lr

one_second:
	mov r8, #2
pop {r0, r1, r2, r3, r4, r5, r6, r7, r9, lr}
bx lr