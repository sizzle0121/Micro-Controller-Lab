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
	// PA, password input = PA[6,5,3,2]
	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_IDR, 0x48000010

	.equ X, 5
	.equ Y, 99999
	.equ password, 0xC // 1100
main:
   	BL   GPIO_init
Loop:
	//detect if button pressed

   	ldr r1, =GPIOC_MODER
   	ldr r0, [r1]
   	ldr r5, =#0xF3FFFFFF
   	and r0, r5
   	str r0, [r1]
   	ldr r0, =GPIOC_IDR //
   	movs r5, #1
   	lsl r5, #13
   	mov r2, #0
	detect_button:
		ldr r1, [r0] // r1=input
		and r1, r1, r5
		cmp r1, #0
		beq tick
		b   reset_cnt
		tick:
			add r2, r2, #1
			b is_pressed
		reset_cnt:
			mov r2, #0
		is_pressed:
			cmp r2, #30
			beq press_yes
			b detect_button
	press_yes:
		BL check_password
blink:
	BL	DisplayLED
	BL Delay
	cmp r7, #0
	bgt blink

	B		Loop
check_password:

   	ldr r0, =GPIOA_IDR //
   	ldr r6, [r0] // r1=input, if input = 1100,PA[] = 0011 !!
   	lsr r6, r6, #5
   	eor r6, r6, #15

   	ldr r2, =password // r2 = password
   	mov r7, #1
   	cmp r2, r6
   	bne	check_fin
   	add r7, r7, #2
   check_fin:
   	lsl r7, r7, #1
   	BX LR
GPIO_init:
  //TODO: Initial LED GPIO pins as output
  movs r0, #0x7 // enable PC, PB, PA
  ldr r1, =RCC_AHB2ENR
  str r0, [r1]
  // set output mode
  movs r0, #0x1540
  ldr r1, =GPIOB_MODER
  ldr r2, [r1]
  and r2, #0xFFFFC03F
  orrs r2, r2, r0
  str r2, [r1]
  //set speed
  ldr r0, =0x2A80
  ldr r1, =GPIOB_OSPEEDR
  strh r0, [r1]
	ldr r0, =0xFFFF
	ldr r1, =GPIOB_ODR
	strh r0, [r1]
	// set PA as input mode
	ldr r1, =GPIOA_MODER
 	ldr r0, [r1]
   	ldr r2, =0xABFC03FF
   	and r0, r0, r2
   	str r0, [r1]  //set PA[15,14,13,12] as input mode
  BX LR

DisplayLED:
	// set_value
	ldr r1, =GPIOB_ODR
	and r0, r7, #1
	cmp r0, #1
	beq set_dark
	b set_shine

set_dark:
	ldr r0, =0xFFFF
	b show
set_shine:
	ldr r0, =0xFF87 // led ma ni
show:
	strh r0, [r1]
	sub r7, r7, #1
	BX LR

Delay:
   //TODO: Write a delay 1sec function
   ldr r3, =X
L1:   ldr r4, =Y
L2:
		subs r4, r4, #1
		bne L2
		subs r3, r3, #1
		bne L1
BX LR

	//shift right, left, or not

