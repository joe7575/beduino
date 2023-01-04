--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Standard libs

]]--

local lib = beduino.lib

vm16.register_ro_file("beduino", "sys/stdlib.asm", vm16.libc.stdlib_asm)
vm16.register_ro_file("beduino", "sys/stdio.asm",  vm16.libc.stdio_asm)
vm16.register_ro_file("beduino", "sys/mem.asm",    vm16.libc.mem_asm)
vm16.register_ro_file("beduino", "sys/string.asm", vm16.libc.string_asm)
vm16.register_ro_file("beduino", "sys/math.asm",   vm16.libc.math_asm)
