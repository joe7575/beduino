--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Standard libs

]]--

local lib = beduino.lib

vm16.register_ro_file("beduino", "stdlib.asm", vm16.libc.stdlib_asm)
vm16.register_ro_file("beduino", "stdio.asm",  vm16.libc.stdio_asm)
vm16.register_ro_file("beduino", "mem.asm",    vm16.libc.mem_asm)
vm16.register_ro_file("beduino", "string.asm", vm16.libc.string_asm)
vm16.register_ro_file("beduino", "math.asm",   vm16.libc.math_asm)
