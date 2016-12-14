ümodel small
.stack 100h
.data
comprom1 db "Enter dividente: $"
comprom2 db "Enter divisor: $"
comprom3 db "Division by zero!",10,13,'$'
comprom4 db "Enter data!",10,13,'$'
int_answer db "Quotient: $"
rem_answer db "Remainder: $"
cr_lf db 0Ah,0Dh,'$'
bs db 08h,'$'
cr db 20h,'$'
bs_cr_bs db 08h,20h,08h,'$'	;bs=08h,cr=20h
bs_cr_bs_bs_cr_bs db 08h,20h,08h,08h,20h,08h,'$'
cr_bs db 20h,08h,'$'
b dw 10
temp dw 1 ; 10
ind dw 0
ind_alpha dw 0
ind_first dw 0
input_zero dw 0
ncipher dw 0
i dw ?
j dw ?
.code

_proc_out PROC
	MOV ind,0
	next:
		CMP AX,0
		JZ val_ax_is0

		XOR DX,DX
		DIV b
		MOV BX,DX   ; DX = 5, AX = 6553
					; BX = DX = 5
		ADD BL,'0'
		PUSH BX
		INC ind
		INC ncipher

	JMP next

	val_ax_is0:
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
		CMP ncipher,1   ;  check number of ciphers , if ncipher == 1 then 
		JZ isone		;  check value of variable , if ncipher == 0 then 
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

	MOV ind_first,0 
	MOV input_zero,0
	MOV ncipher, 0

	JMP pass

	escmore0:
		isesc_next:
		XOR DX,DX

		CMP ind,0
		JZ escis0

		LEA DX,bs_cr_bs  ;!!
		MOV AH,09h
		INT 21h

		DEC ind
			
		CMP ind,0
		JG escmore0
		escis0:
		MOV ind_first,0
	JMP endesc

	isesc:
		LEA DX,bs_cr_bs
		MOV AH,09h
		INT 21h

	JMP isesc_next

	overflow1:
		DEC ind
		DEC ind_first
		MOV AX,CX
		DIV b
		MOV CX,AX
	JMP backoverflow1

	overflow:
		DEC ind
		DEC ind_first
	JMP stackzero

	checkBXiszero:
		CMP BX,0
		JZ checkright
		JG checkunright

	checkunright:
		LEA DX,bs_cr_bs_bs_cr_bs   ;!!!
		MOV AH,09h
		INT 21h

		ADD BL,'0'
		MOV DL,BL
		MOV AH,02h
		INT 21h
		MOV input_zero,0
		SUB BL,'0'
	JMP aftercheckunright

	nextposition:
		POP BX

		MOV AX,10
		MUL CX
		JC overflow

		MOV CX,AX
		MOV temp,CX

		ADD temp,BX
		JC overflow1
		ADD CX,BX
	JMP ifnotoverflow

	checkright:
		LEA DX,bs_cr_bs   ;!!!
		MOV AH,09h
		INT 21h
	JMP aftersecondzero

	pass:
	back3:
	endesc:
		MOV input_zero,0
	input:
		after_other_alpha:     
					backonepos:
						ifnotoverflow:
							aftersecondzero:
		XOR AX,AX
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

		CMP input_zero,1
		JZ checkBXiszero
		
		INC ind
		INC ind_first	
		aftercheckunright:  ;;;;;	
			PUSH BX			

		CMP ind_first,1
			JZ oneposition
			JG nextposition 

		back2:
	JMP input

	smallerzero:
		morenine:
			stackzero:
				backoverflow1:
			LEA DX,bs_cr_bs   ;!!!
			MOV AH,09h
			INT 21h

	JMP after_other_alpha

	isind0:
		MOV ind_first,0
		XOR DX,DX
		MOV DL,cr_bs
		MOV AH,02h
		INT 21h
	JMP back3
	
	isbackspace:
		CMP ind,0
		JZ isind0

		LEA DX,cr_bs
		MOV AH,09h
		INT 21h

		XOR DX,DX
		MOV AX,CX
		DIV b
		MOV CX,AX

		DEC ind
		DEC ind_first

		MOV input_zero,0
		inputzeroisone:
		waitdata:
	JMP back2

	isenter:
		CMP ind,0 
		JZ isenterindzero

		JMP labenter

		oneposition:
			XOR CX,CX
			POP BX
			CMP BX,0
			JZ BXis0			
			ADD CX,BX
		JMP backonepos

		isenterindzero:
			LEA DX,comprom4
			MOV AH,09h
			INT 21h
		JMP waitdata

		BXis0:
			MOV input_zero,1
		JMP inputzeroisone

		labenter:
			MOV AX,CX
			XOR CX,CX
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

	JMP pass_bs_cr_bs

	once_again:
		LEA DX,comprom3
		MOV AH,09h
		INT 21h
	
	pass_bs_cr_bs:
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

