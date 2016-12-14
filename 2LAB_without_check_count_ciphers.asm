model small
.stack 100h
.data
comprom1 db "Enter dividente: $"
comprom2 db "Enter divisor: $"
int_answer db "Quotient: $"
rem_answer db "Remainder: $"
cr_lf db 0Ah,0Dh,'$'
bs db 08h,'$'
cr db 20h,'$'
b dw 10
temp dw 1 ; 10
ind dw 0
ind_alpha dw 0
ncipher dw 0
i dw ?
j dw ?
.code

_proc_out PROC
	;MOV AX,a - input from keyboard in AX

	next:
		CMP AX,0
		JZ ravno

		XOR DX,DX
		DIV b
		MOV BX,DX ; DX = 5, AX = 6553
					; BX = DX = 5
		ADD BL,'0'
		PUSH BX
		INC ind
		INC ncipher

	JMP next

	ravno:
		output: 

			CMP ind,0
			JZ iszero

			DEC ind
			POP CX
			MOV DL,CL
			MOV AH,02h
			INT 21h

		JMP output

	iszero:
		CMP ncipher,1   ;  check number of ciphers , if == 1 then 
		JZ isone		;  check value of variable , if == 0 then 
						;  output 0 else RET
		isone:
			CMP AX,0
			JZ iszero3

		JMP final
			iszero3:
				MOV DL,48
				MOV AH,02h
				INT 21h
		final:
	RET
_proc_out ENDP


_proc_in PROC
	XOR BX,BX
	MOV ind,0 
	MOV ind_alpha,0 
	JMP pass

	isesc:
		MOV DL,bs
		MOV AH,02h
		INT 21h

		MOV DL,cr
		MOV AH,02h
		INT 21h

		MOV DL,bs
		MOV AH,02h
		INT 21h
	JMP isesc_next

	escmore0:
		isesc_next:
		XOR DX,DX

		after_dec_ind_alpha:
		CMP ind_alpha,0
		JG pass_check_ind

		CMP ind,0
		JZ escis0

		pass_check_ind:

		MOV DL,bs
		MOV AH,02h
		INT 21h

		MOV DL,cr
		MOV AH,02h
		INT 21h

		MOV DL,bs
		MOV AH,02h
		INT 21h

		CMP ind_alpha,0
		JG ismoreind_alpha
		POP BX
		DEC ind
			
		CMP ind,0
		JG escmore0
		escis0:
	JMP endesc

	ismoreind_alpha:
			DEC ind_alpha
	JMP after_dec_ind_alpha

	smallerzero:
		morenine:
			INC ind_alpha

			JMP after_inc_alpha

	pass:
	input:
		after_inc_alpha:     ;  smallerzero:
							 ;  morenine:
							 ;isind0:
				back3:
					endesc:
		MOV AH,01h
		INT 21h

		MOV BL,AL

		CMP BL,27
		JE isesc

		CMP BL,8
		JE isbackspace

		CMP BL,13
		JZ isenter

		CMP BL,48
		JC smallerzero

		CMP BL,57
		JG morenine

		SUB BL,'0'

		PUSH BX
		INC ind

		back:
		isalpha:
		back2:
	JMP input

	ismoreind_alpha2:
		DEC ind_alpha
	JMP after_dec_ind_alpha2

	ismore5535:  ; it's for check input value, if value more 65535 then 
	ismore6:	 ; doesn't input
		DEC ind
	JMP back

	isind0:
		MOV DL,cr
		MOV AH,02h
		INT 21h
	JMP back3
	
	isbackspace:
		CMP ind_alpha,0
		JG pass_check_ind2
		
		CMP ind,0
		JZ isind0

		pass_check_ind2:

		MOV DL,cr
		MOV AH,02h
		INT 21h

		MOV DL,bs
		MOV AH,02h
		INT 21h

		CMP ind_alpha,0
		JG ismoreind_alpha2
		POP BX
		DEC ind

		after_dec_ind_alpha2:
	JMP back2

	isenter:
		
		CMP ind,0
		JZ isalpha

		XOR CX,CX

		POP BX
		ADD CX,BX
		DEC ind
		
		MOV temp,1 ; it's very important! 

		next2:

			CMP ind,0
			JZ iszero2

			POP BX
			MOV AX,10
			MUL temp
			MOV temp,AX

			CMP AX,10000
			JZ is10000
			
			isorsmaller5535:

			MUL BX
			ADD CX,AX
			DEC ind

		JMP next2
		
		is10000:
			CMP BX,6
			JG ismore6

			CMP CX,5535
			JG ismore5535
			JLE isorsmaller5535

		iszero2:
			MOV AX,CX
	RET
_proc_in ENDP


_proc_div PROC

	LEA DX,comprom1
	MOV AH,09h
	INT 21h

	CALL _proc_in
	MOV i,AX

	LEA DX,comprom2
	MOV AH,09h
	INT 21h

	XOR DX,DX
	once_again:
	CALL _proc_in
	CMP AX,0
	JZ once_again
	MOV j,AX

	MOV AX,i
	XOR DX,DX
	DIV j
	MOV j,DX
	MOV i,AX

	LEA DX,int_answer
	MOV AH,09h
	INT 21h

	XOR DX,DX
	MOV AX,i
	CALL _proc_out

	MOV DL,cr_lf
	MOV AH,02h
	INT 21h

	LEA DX,rem_answer
	MOV AH,09h
	INT 21h

	XOR DX,DX
	MOV AX,j
	CALL _proc_out

	RET
_proc_div ENDP


start:
	MOV AX,@data
	MOV DS,AX			; data of alpha doesn't push in stack then
						; by backspace symbols alpha is there, but
						; need to backspace and alpha!
	CALL _proc_div 
	

	MOV AH,4Ch
	INT 21h
end start

