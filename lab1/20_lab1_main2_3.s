	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	X:	.word 5
	Y:	.word 10
	Z:	.word 0

.text
	.global main

main:
	ldr r1, =X
	ldr r0, [r1]

	ldr r3, =Y
	ldr r2, [r3]

	muls r0, r0, r2
	adds r0, r0, r2
	str	 r0, [r1]

	ldr r5, =Z
	ldr r4, [r5]
	subs r4, r2, r0
	str r4, [r5]
L: B L
