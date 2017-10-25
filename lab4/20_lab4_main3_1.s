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
	.equ X, 160
	.equ Y, 9999
main:
   	BL   GPIO_init
	MOVS	R1, #1

Loop:
	//TODO: Write the display pattern into leds variable

	BL	DisplayLED
   	BL   Delay

	B		Loop

GPIO_init:
  //TODO: Initial LED GPIO pins as output
  movs r0, #0x02 // PB
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
  movs r2, #0xC
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
   ldr r3, =X
L1:   ldr r4, =Y
L2:		subs r4, r4, #1
		bne L2
		subs r3, r3, #1
		bne L1
BX LR
