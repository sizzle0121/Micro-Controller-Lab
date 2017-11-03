	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	student_id: .byte 4, 7, 0, 6, 1, 4, 0, 15 //TODO: put your student id here

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

main:
    BL   GPIO_init
    BL   max7219_init
    //TODO: display your student id on 7-Seg LED
    ldr r9, =student_id
    ldr r0, =#1
    ldr r2, =#0
display:
	
	ldrb r1, [r9, r2]
	bl MAX7219Send
	add r0, r0, #1  		//position of each bit
	add r2, r2, #1
	cmp r2, #8
	bne display
	b Program_end


Program_end:
	B Program_end
	
GPIO_init:
	//TODO: Initialize three GPIO pins as output for max7219 DIN, CS and CLK
	//enable port A
	movs r0, #0x1
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
	BX LR

MAX7219Send:
	//input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	push {r0, r2, r9, LR}
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

	pop {r0, r2, r9, LR}
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
