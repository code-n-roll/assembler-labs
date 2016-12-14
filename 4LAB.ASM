MODEL SMALL
.STACK 100h
.DATA
mas				db		100 dup (?)
cur_len			dw		0
temp_cur_len	dw		0
min_len			dw		65535
expr_len		dw		0
temp_expr_len	dw		0
in_word			dw		0
str2			db		" Enter string:  $"
str1			db		"/Output string: $"
.CODE
main:
		MOV		AX,@data
		MOV		DS,AX
		XOR		AX,AX

		MOV		SI,0
		LEA		DX,str2
		MOV		AH,09h
		INT		21h
go:
		MOV		AH,01h
		INT		21h

		CMP		AL,13
		JE		isSPACE_TAB
		CMP		AL,32
		JE		isSPACE_TAB
		CMP		AL,9
		JE		isSPACE_TAB
		INC		cur_len
		MOV		in_word,1		;;;;;;
after_SPACE_TAB:
		CMP		AL,13
		JE		ANALISE_pass
		MOV		mas[SI],AL
		INC		SI
		INC		expr_len

		LOOP	go

cur_is_min_len:
		MOV		min_len,BX
		MOV		in_word,0		;;;;;;;;
		JMP		after_SPACE_TAB

isSPACE_TAB:
		CMP		in_word,1
		JNE		go
		XOR		BX,BX
		MOV		BX,cur_len
		MOV		cur_len,0
		CMP		min_len,BX
		JA		cur_is_min_len
		MOV		in_word,0		;;;;;;;				
		JMP		after_SPACE_TAB

ANALISE_pass:
		JMP ANALISE

go_pass:
		JMP		go

isnt_sym:
		DEC		SI
		CMP		in_word,0
		JE		go2
		XOR		BX,BX
		MOV		BX,cur_len
		CMP		BX,min_len
		JG		go2_plus
		XOR		BX,BX
		MOV		BX,cur_len
		MOV		temp_cur_len,BX
in_mas:
		MOV		mas[SI],-1
		DEC		SI
		DEC		cur_len
		CMP		cur_len,0
		JE		to_go2
		LOOP	in_mas

go2_plus:
		INC		SI
		MOV		cur_len,0
		JMP		go2

isnt_sym_pass:
		JMP		isnt_sym

to_go2:
		INC		temp_cur_len
		ADD		SI,temp_cur_len
		MOV		in_word,0
		JMP		go2

ANALISE:
		MOV		mas[SI],AL
		CMP		min_len,65535
		JE		go_pass
		MOV		cur_len,0
		MOV		SI,-1
go2:
		INC		SI
		
		CMP		mas[SI],32
		JE		isnt_sym_pass
		CMP		mas[SI],9
		JE		isnt_sym_pass
		CMP		mas[SI],13
		JE		isnt_sym_pass

		XOR		BX,BX
		MOV		BX,expr_len
		CMP		temp_expr_len,BX
		JE		isINPUT

		MOV		in_word,1
		INC		cur_len
		INC		temp_expr_len
		
		LOOP	go2
isINPUT:
		MOV		SI,-1
		LEA		DX,str1
		MOV		AH,09h
		INT		21h
OUTPUT:
		
		INC		SI
		CMP		mas[SI],-1
		JE		OUTPUT
		MOV		DL,mas[SI]
		MOV		AH,02h
		INT		21h
		CMP		SI,expr_len
		JLE		OUTPUT

		MOV		AX,4C00h
		INT		21h
end main