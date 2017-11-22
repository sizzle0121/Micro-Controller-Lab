.syntax unified
	.cpu cortex-m4
	.thumb
.data
	arr: .byte 0x7E, 0x30, 0x6D, 0x79, 0x33, 0x5B, 0x5F, 0x70, 0x7F, 0x7B, 0x77, 0x1F, 0x4E, 0x3D, 0x4F, 0x47 //TODO: put 0 to F 7-Seg LED pattern here

.text
	.global GPIO_init
	.global max7219_send
	.global max7219_init
	.global MAX7219re
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
	.equ X, 160
	.equ Y, 9999


GPIO_init:
	//TODO: Initialize three GPIO pins as output for max7219 DIN, CS and CLK
	//enable port A
	//push{r4-r11,LR}
	movs r0, #0x3
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
	//pop{r4-r11,PC}
	BX LR

max7219_send:
    //input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	push {r0-r11,LR}
	lsl r0, r0, #8
	add r0, r0, r1	//16 bits for DIN to eat
	ldr r1, =#GPIOA_MODER
	ldr r2, =#CS
	ldr r3, =#DIN
	ldr r4, =#CLOCK
	ldr r5, =#GPIO_BSRR_OFFSET
	ldr r6, =#GPIO_BRR_OFFSET
	mov r7, #16

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


	pop {r0-r11,PC}
	BX LR
max7219_init:
	//TODO: Initialize max7219 registers
	//r0:address, r1:data
	push {r0-r2,LR}
	ldr r0, =#DECODE_MODE
	ldr r1, =#0xff
	bl max7219_send
	ldr r0, =#DISPLAY_TEST
	ldr r1, =#0x0
	bl max7219_send
	ldr r0, =#SCAN_LIMIT
	ldr r1, =#0x7
	bl max7219_send
	ldr r0, =#INTENSITY
	ldr r1, =#0x8
	bl max7219_send
	ldr r0, =#SHUTDOWN
	ldr r1, =#0x1
	bl max7219_send
	bl MAX7219re


	pop {r0-r2,PC}
	BX LR

MAX7219re:
	push {lr}


	ldr r0, =#0x01
resetLoop:
	ldrb r1, =#0x0F
	BL max7219_send

	add r0, #1
	cmp r0, #9
	bne resetLoop

	ldr r0, =#0x01		// "0"
	ldr r1, =#15
	BL max7219_send


	pop {lr}
	bx lr
