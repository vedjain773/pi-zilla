#define THREAD_CPU_CONTEXT  0

/*
* Since the cpu_switch_to function acts like a simple call from the pov of the current task,
* it expects its callee-saved registers to be restored once the task is woken again.
* It therefore makes sense to only store these registers to the task's cpu context.
*/

.globl cpu_switch_to
cpu_switch_to:
	mov	x10, #THREAD_CPU_CONTEXT
	add	x8, x0, x10 // load the cpu context of the current task
	mov	x9, sp
	stp	x19, x20, [x8], #16	// store callee-saved registers to the current task's cpu context
	stp	x21, x22, [x8], #16
	stp	x23, x24, [x8], #16
	stp	x25, x26, [x8], #16
	stp	x27, x28, [x8], #16
	stp	x29, x9, [x8], #16
	str	x30, [x8]
	add	x8, x1, x10 // Load the cpu context of the next task
	ldp	x19, x20, [x8], #16	// load callee-saved registers from the next task's cpu context
	ldp	x21, x22, [x8], #16
	ldp	x23, x24, [x8], #16
	ldp	x25, x26, [x8], #16
	ldp	x27, x28, [x8], #16
	ldp	x29, x9, [x8], #16
	ldr	x30, [x8]
	mov	sp, x9
	ret
