@  This is the init for an AT91SAM7
@ This code is entered with interrupts disabled
@ This code should work as start code from flash or RAM.
@ It does not have to be placed at address 0 since it will copy the vectors
@ there if needed.
@
	.text
	.code 32
	.align 	0
	
	.global interrupts_get_and_disable
    .type interrupts_get_and_disable, %function

	.global interrupts_enable
    .type interrupts_enable, %function

	.global fiq_get_and_disable
    .type fiq_get_and_disable, %function

	.global fiq_enable
    .type fiq_enable, %function


@ int interrupts_get_and_disable
@  Disables interrupts. 
@ Returns zero if interupts were previously off

.func interrupts_get_and_disable
interrupts_get_and_disable:
		mrs	r0, cpsr
		ands    r0, r0, #0x80
		movne   r0, #0
		bxne    lr
		mrs	r0, cpsr
		orr	r0,r0,#0x80
		msr	cpsr_c,r0
		mov     r0,#1
		bx	lr
.endfunc

@ void interrupts_enable
.func interrupts_enable
interrupts_enable:
		mrs	r0, cpsr
		bic	r0,r0,#0x80
		msr	cpsr_c,r0
		bx	lr
.endfunc

@ int fiq_get_and_disable
@  Disables interrupts. 
@ Returns zero if interupts were previously off
.func fiq_get_and_disable
fiq_get_and_disable:
		mrs	r0, cpsr
		ands    r0, r0, #0x40
		movne   r0, #0
		bxne    lr
		mrs	r0, cpsr
		orr	r0,r0,#0x80
		msr	cpsr_c,r0
		mov     r0,#1
		bx	lr
.endfunc

@ void fiq_enable
.func fiq_enable
fiq_enable:
		mrs	r0, cpsr
		bic	r0,r0,#0x40
		msr	cpsr_c,r0
		bx	lr
.endfunc
