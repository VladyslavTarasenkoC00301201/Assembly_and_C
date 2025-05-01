;Title		: Parameter Passing Example x86_64
;Written by	: Vladyslav Tarasenko
;Date Created	: March-25-2025
;Description	: 



section .data
	PROMPT1			db "Enter a nubmer: ",
	PROMPT1_LEN		equ $ - PROMPT1 ; current address minux starting address
        RESULT_PROMPT  		db "The current sum is: ",
	RESULT_PROMPT_LEN	equ $ - RESULT_PROMPT
	FINAL_RESULT_PROMPT	db "The final sum is: ",
	FINAL_RESULT_LEN	equ $ - FINAL_RESULT_PROMPT
	OVERFLOW_PROMPT		db "The risk of overflow was encountered, program exits...",0,10
	OVERFLOW_PROMPT_LEN	equ $ - OVERFLOW_PROMPT
	INVALID_INPUT_PR	db "You have entered invalid data, exiting...", 0, 10
	INVALID_INPUT_PR_LEN	equ $ - INVALID_INPUT_PR
	NEWLINE			db 10			

section .bss
	input_buffer resb 21  ; reserve 20 bytes to store user number 
	sum_buffer   resb 20  ; reserve 20 bytes to store some of numbers
	input_len    resq 1   ; reserve 1 byte to store the length of user input
	sum    	     resq 1   ; sum for output
section .text
	global _start

_start:
	mov	qword [sum], 0 ; initialize sum to 0
	
	mov	r14, 6 ; loop counter set to 3


.game_loop:
	; promt to enter a number
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, PROMPT1
	mov	rdx, PROMPT1_LEN
	syscall 


	mov	rax, 0 ; syscall for read
	mov	rdi, 0 ; stdin
	mov	rsi, input_buffer
	mov 	rdx, 21 ; set how much to read (20 bytes)
	syscall


	; getting rid of '/n' in the end of the input
	mov	rcx, rax
	cmp	rcx, 0
	je	.input_invalid

	dec	rcx
	xor	rax, rax
	mov	al, [input_buffer+rcx] ; copy input_buffer at index rcx to al
	cmp	al, 10
	jne	.store_original ; if not equal then there is no new line

	mov	byte[input_buffer+rcx],0 ; replace new line '10'  with 0
	dec 	rcx ; first time for new line char second decrement to get to number
	mov	[input_len], rcx	; store new length
	mov	rcx, [input_len] ; was added for debbugging 
	jmp	.after_strip


.store_original:
	mov	[input_len], rcx


.after_strip:
	
	xor	rax, rax ; sets to 0s without impacting flags
	xor	rbx, rbx
	xor	rcx, rcx
	xor     r10, r10 ; will hold the current sum


.validate_input_loop:
	
	mov	cl, [input_buffer+rbx] ; move first digit to cl
	cmp	cl, '0'
	jb	.input_invalid ; if below '0' in ASCII jump to invalid
	cmp	cl, '9'
	ja	.input_invalid ; if above '9' in ASCII jump to invalid

	sub	cl, '0' ; converts the char into numeric equivalent
	movzx	r9, cl	; digit is stored in r9 zx - zero extend, fills all extra with 0s
	
	; calculate maximum possible number
	
	mov	rax, -1	; UINT64_MAX
	sub	rax, r9	
	xor	rdx, rdx ; clear rdx before devision because remainder is stored there
	mov	r8, 10
	div	r8
	
	; current number*10 + new_digit 
	; < maximum possible    => current number < (maximum possible-new_digit)/10
	;compare current sum with limmit
	cmp	r10, rax
	ja	.overflow_prevention	;

	mov	rax, r10	
	mul 	r8
	mov	r10, rax
	add	r10, r9
	
	inc	rbx
	mov	r12, [input_len]
	cmp	rbx, r12
	jg	.done
	
	jmp	.validate_input_loop
	
.input_invalid:
	
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, INVALID_INPUT_PR
	mov	rdx, INVALID_INPUT_PR_LEN
	syscall
	; Exit with code 1 on error
	mov	rax, 60
	mov	rdi, 1
	syscall

.overflow_prevention:
 	mov	rax, 1
	mov	rdi, 1
	mov	rsi, OVERFLOW_PROMPT
	mov	rdx, OVERFLOW_PROMPT_LEN
	syscall	
	
	mov	rax, 60
	mov	rdi, 1
	syscall
.done:
	; sum + new number < max possible   => new < max possible - sum
	mov     rax, -1
	sub	rax, [sum]
	cmp     r10, rax
	ja      .overflow_prevention
	add	[sum], r10
	
	dec	r14
	jz	.print_final_sum
	
	test	r14, 1
	jz	.print_intermediate_sum ; check if even => 2 number are entered print sum
	
	; clear input buffer and prompt for next number
.clear_input:
	
	mov	rcx, 21		; coutner for 20 times (20 bytes)
	mov	rdi, input_buffer ; point to input_buffer
	xor	rax, rax

.clear_input_loop:
	mov	[rdi], al	; puts 0 at memory address pointed by rdi
	inc	rdi
	loop	.clear_input_loop	; decreases rcx by one and returns to clear_loop if !=0

	jmp 	.game_loop


.print_intermediate_sum:
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, RESULT_PROMPT
	mov	rdx, RESULT_PROMPT_LEN
	syscall
	
	call	.print_number
	
	call	.print_newline
	
	mov	qword [sum], 0 ; reinitilize the sum to 0

.clear_sum_buffer:
	mov	rcx, 20
	mov	rdi, sum_buffer
	xor	rax, rax

.clear_sum_loop:
	mov	[rdi], al
	inc	rdi
	loop	.clear_sum_loop
	jmp	.clear_input

	
.print_final_sum:
	mov 	rax, 1
	mov 	rdi, 1
	mov 	rsi, FINAL_RESULT_PROMPT
	mov	rdx, FINAL_RESULT_LEN
	syscall
	
	call	.print_number

	call	.print_newline
	
	mov	rax, 60
	mov	rdi, 0
	syscall

.print_number:
	mov	rax, [sum]
	mov	rbx, 10
	mov	rdi, sum_buffer+20 ; the end of the buffer
	xor	rcx, rcx

.convert_to_ASCII_loop:
	xor	rdx, rdx
	div	rbx	; remainder goes to rdx
	dec	rdi
	add	dl, '0' ; transform to ascii
	mov	[rdi], dl
	inc	rcx	; track the length
	test	rax, rax ; check if quotitient = 0
	jnz	.convert_to_ASCII_loop

	mov	rax, 1
	mov	rsi, rdi
	mov	rdi, 1
	mov	rdx, rcx
	syscall
	ret

	
.print_newline:
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, NEWLINE
	mov	rdx, 1
	syscall
	ret
