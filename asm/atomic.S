// no mem access after a ldar can move before it
.globl load
load:
    ldar x0, [x0]
    ret

// no mem access before a stlr can move after it
.globl store
store: 
    stlr x1, [x0]
    ret

/*
* ldaxr marks the address as "exclusively owned" by the current core
* stlxr attempts the store, and succeeds only if the local core monitor still holds
  exclusive reservation for the address and writes the status to w4 (here)
*/
.globl compare_and_swap
compare_and_swap:
    ldaxr x3, [x0]
    cmp x3, x1
    bne failure
    stlxr w4, x2, [x0]
    cmp w4, #0
    bne compare_and_swap
    mov x0, #1
    ret

failure:
    mov x0, #0
    ret
