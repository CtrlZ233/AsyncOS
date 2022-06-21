
#![no_std]
#![no_main]

#![allow(unused)]

use spin::Mutex;
use core::usize::MAX;

use crate::excutor::{Excutor};
use crate::task::{user_task::UserTask};


use crate::user_task::TaskId;
use crate::{thread::*, EXCUTOR};
use crate::println;

use crate::cbq::CBTID;
extern crate alloc;
use alloc::boxed::Box;


use core::{mem::MaybeUninit, ptr::NonNull};
const USER_HEAP_SIZE: usize = 0x20_0000;

static mut HEAP_SPACE: [u8; USER_HEAP_SIZE] = [0; USER_HEAP_SIZE];

const HEAP_SIZE: usize = 0x20_0000;
static HEAP_MEMORY: MaybeUninit<[u8; HEAP_SIZE]> = core::mem::MaybeUninit::uninit();

use buddy_system_allocator::LockedHeap;



#[global_allocator]
static HEAP: LockedHeap = LockedHeap::empty();

/// 在用户态程序中获取地址直接调用
#[no_mangle]
unsafe fn init_environment() {
    let heap_start = HEAP_MEMORY.as_ptr() as usize;
    HEAP.lock().init(heap_start, HEAP_SIZE);

    init_cpu_test();
}


#[no_mangle]
pub fn check_callback(t: usize) -> bool {
    CBTID.lock().contains_tid(t)
}


#[alloc_error_handler]
pub fn handle_alloc_error(layout: core::alloc::Layout) -> ! {
    panic!("Heap allocation error, layout = {:?}", layout);
}
