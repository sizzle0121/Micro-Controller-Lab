	.syntax unified
	.cpu cortex-m4
	.thumb
.data
leds: .byte 0

.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOB_MODER, 0x48000400
	.equ GPIOB_OTYPER, 0x48000404
	.equ GPIOB_OSPEEDR, 0x48000408
	.equ GPIOB_PUPDR, 0x4800040C
	.equ GPIOB_ODR, 0x48000414
	// PC
	.equ GPIOC_MODER, 0x48000800
	.equ GPIOC_IDR, 0x48000810
	.equ X, 40
	.equ Y, 6900
main:
   	BL   GPIO_init
	MOVS	R1, #1
	LDR	R0, =leds
	STRB	R1, [R0]

Loop:
	//TODO: Write the display pattern into leds variable

	BL	DisplayLED
   	BL   Delay
	B		Loop

GPIO_init:
  //TODO: Initial LED GPIO pins as output
  movs r0, #0x6 // enable PC, PB
  ldr r1, =RCC_AHB2ENR
  str r0, [r1]
  // set output mode
  movs r0, #0x1540
  ldr r1, =GPIOB_MODER
  ldr r2, [r1]
  and r2, 0xFFFFC03F
  orrs r2, r2, r0
  str r2, [r1]
  //set speed
  ldr r0, =0x2A80
  ldr r1, =GPIOB_OSPEEDR
  strh r0, [r1]
  ldr r1, =GPIOB_ODR
  movs r7, #0
  movs r2, #0xC //    00001100
  BL Loop
  BX LR

DisplayLED:
	// set_value

	eor r3, r2, #0xff
	ldr r1, =GPIOB_ODR
	strh r3, [r1]
	LDR	R0, =leds
	lsr r3, r2, #3
	str r3, [r0] // write in LED
	//shift right, left, or not
	cmp r7, #2
	bge change_fin
again:
	cmp r7, #0
	beq shift_left
	cmp r7, #1
	beq shift_right
shift_left:
	lsl r2, r2, #1
	cmp r2, #0x180
	blt change_fin
	lsr r2, r2, #1
	eor r7, r7, #1
	b again
shift_right:
	lsr r2, r2, #1
	cmp r2, #0x6
	bgt change_fin
	lsl r2, r2, #1
	eor r7, r7, #1
	b again
change_fin:
	BX LR

Delay:
   //TODO: Write a delay 1sec function
   // r2, r7 cannot be used ,
   ldr r1, =GPIOC_MODER
   ldr r0, [r1]
   ldr r5, =#0xF3FFFFFF
   and r0, r5
   str r0, [r1]
   ldr r0, =GPIOC_IDR //
   movs r5, #1
   lsl r5, #13
   ldr r3, =X

L1:   ldr r4, =Y
L2:
		ldr r1, [r0] // r1=input
		and r1, r1, r5
		cmp r1, #0
		beq tick
		b   reset_cnt
	tick:
		add r6, r6, #1
		b is_pressed
	reset_cnt:
		mov r6, #0
	is_pressed:
		cmp r6, #100
		bne nothing_happen
		eor r7,r7, #2

		//mov r6, #0
	nothing_happen:
		subs r4, r4, #1
		bne L2
		subs r3, r3, #1
		bne L1
BX LR
