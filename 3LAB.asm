model small
.stack 100h
.data
comprom1 db "Enter dividente: $"
comprom2 db "Enter divisor: $"
comprom3 db "Division by zero! Enter once again:",10,13,'$'
comprom4 db "Enter data!",10,13,'$'
comprom5 db "Range of values: -32768...+32767",10,13,'$'
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
;temp_dd dd 0
ind dw 0
ind_alpha dw 0
ind_first dw 0
input_zero dw 0
ndigits dw 0
minus dw 0
minus1 dw 0
minus2 dw 0
max_negative dd 32768;32768
max_positive dd 32767;32767
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
		INC ndigits

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

		deleteminus:
			LEA DX,bs_cr_bs  ; TEMP
			MOV AH,09h		 ; TEMP
			INT 21h			 ; TEMP
		JMP after_deleteminus; TEMP

	iszero:
		CMP ndigits,1   ;  check number of digits , if ndigits == 1 then 
		JZ isone		;  check value of variable , if ndigits == 0 then 
						;  output 0 else RET
		isone:
			CMP AX,0
			JZ iszero3

		JMP final
			iszero3:
				CMP minus1,1    ; TEMP
				JE deleteminus	; TEMP			!!!SEEEE TO HERE!!!!

				after_deleteminus: ; TEMP

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
	MOV ndigits, 0
	MOV minus,0

	JMP pass

	escisminus:
		LEA DX,bs_cr_bs  ;!!
		MOV AH,09h
		INT 21h

		MOV minus,0

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
		CMP minus,1
		JZ escisminus

		MOV ind_first,0
	JMP endesc

	isesc:
		LEA DX,bs_cr_bs
		MOV AH,09h
		INT 21h

	JMP isesc_next

	overflow:
		DEC ind
		DEC ind_first
	JMP stackzero

	overflow1:
		SUB CX,BX  ;new!
		DEC ind
		DEC ind_first
		MOV AX,CX
		DIV b
		MOV CX,AX
	JMP backoverflow1

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

	isesc_middle:
		JMP isesc

	minusoverflow:
		CMP AX,32768
		JA overflow  
		JMP notoverflow

	minusoverflow1:
		CMP AX,32768
		JA overflow1
		JMP tonotoverflow
	nextposition:
		POP BX

		MOV AX,10
		MUL CX

		JO overflow			; new!
		;JNO notoverflow		;

		CMP minus,1
		JZ minusoverflow

		CMP AX,32767
		JG overflow 

		notoverflow:

		MOV CX,AX
		;MOV temp,CX

		;ADD temp,BX
		;MOV AX,temp
		ADD CX,BX
		MOV AX,CX
							;JC overflow1	
		
		CMP minus,1
		JZ minusoverflow1
		
		CMP AX,32767
		JA overflow1

		tonotoverflow:
		;ADD CX,BX
	JMP ifnotoverflow

	checkBXiszero_middle:
	JMP checkBXiszero

	checkright:
		LEA DX,bs_cr_bs   ;!!!
		MOV AH,09h
		INT 21h
	JMP aftersecondzero

	nextposition_middle:
		JMP nextposition

	pass:
	back3:
	endesc:
		MOV input_zero,0
	input:
	fromisminus:
		after_other_alpha:     
					backonepos:
						ifnotoverflow:
							aftersecondzero:
		XOR AX,AX
		MOV AH,01h
		INT 21h

		MOV BL,AL

		CMP BL,45
		JE isminus

		CMP BL,27
		JE isesc_middle

		CMP BL,8
		JE isbackspace

		CMP BL,13
		JZ isenter_middle

		CMP BL,48
		JC smallerzero

		CMP BL,57
		JG morenine

		SUB BL,'0' 

		CMP input_zero,1
		JZ checkBXiszero_middle
		
		INC ind
		INC ind_first	
		aftercheckunright:  ;;;;;	
			PUSH BX			

		CMP ind_first,1
			JZ oneposition
			JG nextposition_middle 

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

	isminus:
	CMP ind,0
	JNZ manyminus
	JMP isminus_middle

	isind0:
		CMP minus,1
		JZ firstminus

		MOV ind_first,0
		XOR DX,DX
		MOV DL,cr_bs
		MOV AH,02h
		INT 21h
	JMP back3
	
	isenter_middle:
		JMP isenter				

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
		fromfirstminus:
	JMP back2

	oneposition:
	JMP oneposition_middle

	isminus_middle:
		CMP minus,0
		JZ fromonminus

		manyminus:

		LEA DX,bs_cr_bs
		MOV AH,09h
		INT 21h

		JMP fromisminus

		fromonminus:
		MOV minus,1
		JMP fromisminus

	firstminus:
		MOV minus,0

		LEA DX,cr_bs
		MOV AH,09h
		INT 21h

		JMP fromfirstminus

	isenter:
		CMP ind,0 
		JZ isenterindzero

		JMP labenter

		oneposition_middle:
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

		input_deleteminus:				; TEMP
			LEA DX,bs_cr_bs_bs_cr_bs	; TEMP
			MOV AH,09h					; TEMP
			INT 21h						; TEMP

			MOV minus,0					; TEMP

			MOV DL,48					; TEMP
			MOV AH,02h					; TEMP
			INT 21h						; TEMP
		JMP after_input_deleteminus		; TEMP

		BXis0:
			MOV input_zero,1
			CMP minus,1					; TEMP
			JE input_deleteminus		; TEMP

			after_input_deleteminus:	; TEMP
		JMP inputzeroisone			

		labenter:
			MOV AX,CX
			XOR CX,CX
	RET
_proc_in ENDP



_proc_idiv PROC
;///////////////////////////////
	MOV minus1,0
	MOV minus2,0 

	JMP pass_idiv

	changesign:
		NEG AX	
		MOV minus1,1
	JMP afterchange

	changesign2:
		NEG AX
		MOV minus2,1
	JMP afterchange2

	pass_idiv:
	LEA DX,comprom1
	MOV AH,09h
	INT 21h

	CALL _proc_in
	CMP minus,1
	JZ changesign

	afterchange:
	MOV i,AX

	LEA DX,comprom2
	MOV AH,09h
	INT 21h

	XOR DX,DX

	JMP pass_bs_cr_bs_idiv

	inv_first_nums:
		NEG i
	JMP after_first_minus

	inv_second_nums:
	CMP minus2,1
	JE after_out_minus
	inverse_second_num:
		NEG j
	JMP after_out_minus

	outputminus:
		MOV DL,'-'
		MOV AH,02h
		INT 21h

	;CMP minus1,1
	;JE inv_first_nums
	JMP inv_first_nums

	after_first_minus:

	CMP minus1,1
	JE inv_second_nums

	JMP after_out_minus

	out_neg_remainder:
		MOV DL,'-'
		MOV AH,02h
		INT 21h
	JMP to_out_remainder

	checkminus2:
	CMP minus2,0
	JGE out_neg_remainder

	once_again_idiv:
		LEA DX,comprom3
		MOV AH,09h
		INT 21h
	
	pass_bs_cr_bs_idiv:
		CALL _proc_in
		CMP AX,0
	JZ once_again_idiv

	CMP minus,1
	JZ changesign2

	afterchange2:
	MOV j,AX

	MOV AX,i
	CWD
	IDIV j
	MOV j,DX
	MOV i,AX
	
	LEA DX,int_answer
	MOV AH,09h
	INT 21h

	XOR AX,AX
	XOR DX,DX
	MOV AX,minus1
	MOV DX,minus2
	CMP AX,DX
	JNE outputminus

	CMP minus1,1
	JE inverse_second_num 

	after_out_minus:
	;//////////////////////////
	XOR DX,DX
	MOV AX,i

	CALL _proc_out
	
	MOV DL,cr_lf
	MOV AH,02h
	INT 21h
	
	LEA DX,rem_answer
	MOV AH,09h
	INT 21h
	;;;;;;;;;;;;;;;;;;;;;;;;;

	CMP minus1,1
	JZ checkminus2

	to_out_remainder:

	XOR DX,DX
	MOV AX,j
	CALL _proc_out

	RET
_proc_idiv ENDP


start:
	MOV AX,@data
	MOV DS,AX			; data of alpha doesn't push in stack then
						; by backspace symbols alpha is there, but
						; need to backspace and alpha!
	LEA DX,comprom5
		MOV AH,09h
		INT 21h

	CALL _proc_idiv ; division signed/unsigned numbers

	MOV AH,4Ch
	INT 21h
end start
