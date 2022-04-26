--[[

	Beduino
	=======

	Copyright (C) 2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Standard libs

]]--

local lib = beduino.lib

local stdlib_asm = [[
;===================================
; stdlib v1.0
; - itoa(c, str)
; - itoha(c, str)
; - halt()
;===================================

global itoa
global itoha
global halt

  .code

;===================================
; [01] itoa(val, str)
; val: [SP+2]
; str: [SP+1]
;===================================
itoa:
  move A, [SP+2]
  move X, [SP+1]  
  move D, X      ; return val
  push #0        ; end-of-string

loop01:
  move B, A
  div  B, #10    ; rest in B
  move C, A
  mod  C, #10    ; digit in C
  add  C, #48
  push C         ; store on stack
  move A, B
  bnze A, loop01 ; next digit

output01:
  pop  B
  move [X]+, B
  bnze B, output01

exit01:
  move A, D
  ret

;===================================
; [02] itoha(val, str)
; val: [SP+2]
; str: [SP+1]
;===================================
itoha:
  move A, [SP+2]
  move X, [SP+1]  
  move D, X      ; return val
  push #0        ; end-of-string
  move C, #4     ; num digits

loop02:
  move B, A
  div  B, #$10   ; rest in B
  mod  A, #$10   ; digit in C
  sklt A, #10    ; C < 10 => jmp +2
  add  A, #7     ; A-F offset
  add  A, #48    ; 0-9 offset
  push A         ; store on stack
  move A, B
  dbnz C, loop02 ; next digit

output02:
  pop  B
  move [X]+, B
  bnze B, output02

exit02:
  move A, D
  ret

;===================================
; [03] halt()
;===================================
halt:
  halt
  
]]

vm16.register_ro_file("beduino", "stdlib.asm", stdlib_asm)
vm16.register_ro_file("beduino", "stdio.asm",  vm16.libc.stdio_asm)
vm16.register_ro_file("beduino", "mem.asm",    vm16.libc.mem_asm)
vm16.register_ro_file("beduino", "string.asm", vm16.libc.string_asm)
vm16.register_ro_file("beduino", "math.asm",   vm16.libc.math_asm)
