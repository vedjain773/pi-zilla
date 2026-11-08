# PiZilla

A bare metal OS kernel for the Raspberry Pi 3B, written in Zig.

![Demo](./assets/demo2.png)

## Requirements

- [Zig](https://ziglang.org/) 0.16+
- [QEMU](https://www.qemu.org/) with `qemu-system-aarch64` for emulation

## Usage
Clone the repository
```bash
git clone https://github.com/vedjain773/pi-zilla.git
cd pi-zilla
```

Build the project
```bash
# Build and emulate the pong game on QEMU
zig build qemu-d

# Open the help menu
zig build --help
```

## Features

At its core, PiZilla runs a preemptive round-robin scheduler with full context switching, driven by an interrupt-based timer and IRQ handling, so multiple tasks actually share the CPU rather than running cooperatively.

For I/O, it talks to the VideoCore GPU through the mailbox interface and drives a framebuffer capable of pixel, line, and bitmap font rendering. Serial input and output are handled by both the Mini UART and PL011 UART drivers, including keyboard input.

The kernel uses samples as entry points, each one showcasing a specific set of features. You can select which sample to run at build time using the -Dsample flag.

| Sample | Description |
|--------|-------------|
| `context_switch` | Runs a simple context switch demonstration |
| `pong_clock` | Runs a playable Pong game and a live tick counter as two concurrent preemptive tasks |
| `spinlock` | Two tasks increment a shared counter using a spinlock to demonstrate mutual exclusion |
| `wait_queue` | Two tasks block on a wait queue and are woken up by a third task after a set number of ticks, demonstrating inter-task synchronization |

## Acknowledgements

- [raspberry-pi-os](https://github.com/s-matyukevich/raspberry-pi-os)
- [NovaPi](https://github.com/moxybaba/NovaPi)
