.altmacro
.macro SAVE_SN n
    sd s\n, (\n+2)*8(a0)
.endm
.macro LOAD_SN n
    ld s\n, (\n+2)*8(a1)
.endm
    .section .text
    .globl __switch
__switch:
    # __switch(
    #     current_task_cx_ptr: *mut TaskContext,
    #     next_task_cx_ptr: *const TaskContext
    # )
    # save kernel stack of current task
    sd sp, 8(a0)
    # save ra & s0~s11 of current execution
    sd ra, 0(a0)
    .set n, 0
    .rept 12
        SAVE_SN %n
        .set n, n + 1
    .endr
    # restore ra & s0~s11 of next execution
    ld ra, 0(a1)
    .set n, 0
    .rept 12
        LOAD_SN %n
        .set n, n + 1
    .endr
    # restore kernel stack of next task
    ld sp, 8(a1)
    ret

.altmacro
.macro SAVE_SN2 n
    sd s\n, (\n+1)*8(a0)
.endm
.macro LOAD_SN2 n
    ld s\n, (\n+1)*8(a1)
.endm
    .section .text
    .globl __switch2

__switch2:
    # __switch2(
    #     current_task_cx_ptr2: &*const TaskContext,
    #     next_task_cx_ptr2: &*const TaskContext
    # )
    # push TaskContext to current sp and save its address to where a0 points to
    # fill TaskContext with ra & s0-s11
    sd sp, 20*8(a0)
    sd ra, 0(a0)
    .set n, 0
    .rept 12
        SAVE_SN2 %n
        .set n, n + 1
    .endr
    csrr s0, uie
    csrr s1, uip
    csrr s2, uepc
    csrr s3, utvec
    csrr s4, utval
    csrr s5, ucause
    sd s0, 13*8(a0)
    sd s1, 14*8(a0)
    sd s2, 15*8(a0)
    sd s3, 16*8(a0)
    sd s4, 17*8(a0)
    sd s5, 18*8(a0)

    # ready for loading TaskContext a1 points to
    # load registers in the TaskContext
    ld sp, 20*8(a1)
    ld ra, 0(a1)
    ld s0, 13*8(a1)
    ld s1, 14*8(a1)
    ld s2, 15*8(a1)
    ld s3, 16*8(a1)
    ld s4, 17*8(a1)
    ld s5, 18*8(a1)
    csrw uie, s0
    csrw uip, s1
    csrw uepc, s2
    csrw utvec, s3
    csrw utval, s4
    csrw ucause, s5
    .set n, 0
    .rept 12
        LOAD_SN2 %n
        .set n, n + 1
    .endr
    ret
