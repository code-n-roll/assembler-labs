;problems with big NxN and 
;output 32bit number in place of 10e-38...10e38
model small
.stack 100h
.data
handle			dw		0
filename_in		db		'input14.txt',0
filename_out	db		'myfile.txt',0
point_fname_in	dd		filename_in
point_fname_out dd		filename_out
string_out		db		'ITS NOT IMPOSSIBLE!'
string_read		db		1200 dup (" ")
len_string_read = $ - string_read
;point_str_out	dd		string_out
point_str_read	dd		string_read
a				dd		10000 dup (0)
b				dd		10
z				dd		0
n 				dw		?
d 				dw		2
ind				dw		1
ans				dd		1
x				dw		1
y				dw		1
i				dw		2
j				dw		1
i_y_minus_1_y	dd		0
y_y				dd		0
ind_first		dw		0
temp			dw		1 
cr_lf			dw		10,13,'$' 
minus			dw		0
nws				dw		0
ncrlf			dw		0
nws_crlf		dw		0
temp_si			dw		-1
first_num		dw		0
mul_n_n			dw		1
size_bytes		dw		4
i_y_minus_1_j	dd		0
y_j				dd		0
nxn				dw		0
nelem_nxn		dw		0
i_j				dd		?
k				dw		?
k_j				dd		?
ind_k_z			dw		?
ind_i_z			dw		?
b_z				dd		?
nrevers			dd		0
ind_i_j			dw		?
minus_1			dd		-1
two				dd		2
base16			dd		10h
HEX_MAP			dw		0h,1h,10h,11h,100h,101h,110h,111h,1000h,1001h,1010h,1011h,1100h,1101h,1110h,1111h
BIN_MAP			db		32 dup(0)
base16dw		dw		10h
exponent		dw		0
mantissa		dd		0
val_end			dw		?
val_begin		dw		?
minus1			dw		0
ndigits			db		?
bs_cr_bs		db		08h,20h,08h,'$'	;bs=08h,cr=20h
j_temp			dd		?
i_temp			dd		?
;mask1			dw		1111001111111111b
;mask2			dw		0000000000000000b
;tmp			dw		?
old_ind			dw		0
one				dd		1
ok				dw		0
ind_i_y_minus_1_i	dw		?
ind_y_i			dw		?
ind_i_y_minus_1 dw		?
ind_i_y_minus_1_y dw	?
ind_y_y			dw		?
length_out		db		0
.code

_proc_create_file PROC
	XOR		CX, CX
	LDS		DX, point_fname_out
	MOV		AH, 3Ch
	INT		21h		; create file and rewrite
	JC		exit

	MOV		handle,AX

	RET	
exit:
	MOV		AX,4C00h
	INT		21h		
_proc_create_file ENDP

_proc_write_file PROC
	LEA		SI,string_read ;- DATA FOR WRITING
	MOV		AL,length_out		   ;- LENGTH STRING_read
	PUSH	SI

	POP		DX

	MOV		BX, handle
	MOV		CX, AX
	MOV		AH, 40h
	INT		21h	

	RET
_proc_write_file ENDP

_proc_open_file PROC
	MOV		AL, 02h
	;LDS	DX, point_fname_in  
	MOV		AH, 3Dh
	INT		21h
	JC		exit_open

	MOV		handle, AX

	RET
exit_open:		
	MOV		AX,4C00h
	INT		21h
_proc_open_file ENDP

.386
_proc_get_size_file PROC
	MOV		BX, handle
	MOV		AL, 2
	XOR		CX, CX
	XOR		DX, DX
	MOV		AH, 42h
	INT		21h		;in DX:AX->length of file in bytes
	JC		exit2

	shl		EAX, 16
	shld	EDX, EAX, 16
	;MOV		size_f, EDX	; size of file - when end of file 

	RET
exit2:
	MOV		AX,4C00h
	INT		21h
_proc_get_size_file ENDP

_proc_read_file PROC

;	set_pointer_in_file
	MOV		BX, handle
	MOV		AL, 0
	XOR		CX,	CX
	XOR		DX, DX
	MOV		AH, 42h
	INT		21h		;current pointer at begin of file
	JC		exit3
;	set_pointer_in_file

	MOV		BX,	handle	; MOV BX, 0 - keyword, 1 - desktop
	MOV		CX, len_string_read
	LDS		DX, point_str_read
	MOV		AH,	3Fh
	INT		21h		;opening file
	JC		exit3

	RET		
exit3:
	MOV		AX,4C00h
	INT		21h
_proc_read_file ENDP

_proc_output_desktop_from_file  PROC; output like integer
	MOV		BX, 1
	MOV		CX, len_string_read
	LDS		DX, point_str_read
	MOV		AH, 40h
	INT		21h
	JC		exit4

	RET
exit4:
	MOV		AX,4C00h
	INT		21h
_proc_output_desktop_from_file ENDP



_proc_get_one_num PROC
	MOV		minus, 0
	MOV		ind, 0 
	MOV		ind_first, 0 
	MOV		nws, 0
	MOV		ncrlf, 0
	MOV		temp_si, -1
	MOV		old_ind, 0
	XOR		BX, BX

	JMP		pass

overflow1:
	DEC		ind
	DEC		ind_first
	MOV		AX,CX
	DIV		b
	MOV		CX,AX
	JMP		backoverflow1

overflow:
	DEC		ind
	DEC		ind_first
	JMP		stackzero

nextposition:
	POP		BX

	MOV		AX,10
	MUL		CX
	JC		overflow

	MOV		CX,AX
	MOV		temp,CX

	ADD		temp,BX
	JC		overflow1
	ADD		CX,BX
	JMP		ifnotoverflow

pass:
input:
after_other_alpha:     
backonepos:
ifnotoverflow:
	XOR		AX,	AX
	MOV		BL, string_read[SI]
	INC		lenGth_out
	;	MOV AH,01h
	;	INT 21h
	;	MOV BL,AL

	CMP		BL,' ' ; whitespace == 20H
	JZ		is_whitespace

	CMP		BL, 13
	JZ		is_cr_lf				

	CMP		BL, 45	; '-'
	JZ		is_minus

	CMP		BL,	48
	JC		smallerzero

	CMP		BL,	57
	JG		morenine

	SUB		BL,'0' 
		
	INC		ind
	INC		ind_first	
	INC		first_num
	PUSH	BX			

	INC		SI
	CMP		ind_first,1
			JZ oneposition
			JG nextposition 
	
	JMP		input

is_minus:
	MOV		minus, 1
	;INC		SI

smallerzero:
morenine:
stackzero:
backoverflow1:
	INC		SI
	JMP		after_other_alpha

isempty:
	INC		SI
	JMP		input

is_cr_lf:
	INC		SI
	MOV		DX,ind
	CMP		DX,old_ind
	JE		isempty
	JMP		labenter
	;INC		ncrlf

is_whitespace:
	;INC		nws
	;MOV		DX, nws
	;ADD		nws_crlf, DX
	;MOV		DX, ncrlf
	;ADD		nws_crlf, DX
	;ADD		temp_si, SI
	;MOV		DX, nws_crlf
	;CMP		DX, temp_si
	MOV		DX,ind
	CMP		DX,old_ind
	JE		isempty
	JMP		labenter

oneposition:
	XOR		CX,CX
	POP		BX			
	ADD		CX,BX
	MOV		nws_crlf, 0
	JMP		backonepos

do_neg:
	NEG		ECX
	MOV		minus, 0

labenter:
	CMP		minus, 1
	JE		do_neg
	MOV		EAX,ECX
	XOR		ECX,ECX
	;MOV		DX,ind
	;MOV		old_ind,DX

	RET
_proc_get_one_num ENDP
	

_proc_in_array_from_string PROC
	XOR		DI, DI
	LEA		DX, cr_lf
	MOV		AH,	09h
	INT		21h

	XOR		SI, SI
	MOV		nelem_nxn,0
	cycle:		
		CALL	_proc_get_one_num	; from string(array) return number in AX		

		CMP		n, 0	
		JE		jump	

		MOV		a[DI], EAX
		FINIT
		;it' set precision
		;FNSTCW	tmp			; for rounding
			;MOV		BX,tmp
			;AND		BX,mask1
			;OR		BX,mask2
			;MOV		tmp,BX
		;FLDCW	tmp

		FILD	a[DI]
		FSTP	a[DI]
		ADD		DI, 4		; STEP FOR 4 BYTES ARRAY	

		INC		SI
		INC		nelem_nxn
		MOV		BX,nelem_nxn
		CMP		BX,nxn		; NxN 
		JE		from_in
	LOOP	cycle
jump:
		MOV		n, AX
		XOR		DX,DX
		MUL		n
		MOV		nxn,AX

		JMP		cycle
from_in:
	RET
_proc_in_array_from_string ENDP


.8087
_proc_add_lines PROC
	XOR		SI, SI
	MOV		ind, 1
	MOV		x, 1

	MOV		y, 1
	cycle_y:
		MOV		BX,n
		CMP		y, BX
		JE		exit_cycle_y

		MOV		i, 2
		cycle_i:
		MOV		BX,n
		CMP		i, BX
		JG		exit_cycle_i

			MOV		j, 1
			cycle_j:
				;MOV		DI, 2
				MOV		BX, n
				CMP		j, BX
				JG		exit_cycle_j
				CMP		ind,1
				JE		ind_is_1
				JNE		ind_is_0
				from_ind_is_1:

				INC		j
			LOOP cycle_j
			cycle_y_pass:
			JMP	cycle_y

			exit_cycle_j:
			XOR		EBX,EBX
			CMP		ind,0
			JE		ind_is_0_second
				
			MOV		DI,ind_i_y_minus_1_y
			MOV		EBX,a[DI]
			CMP		EBX,0
			JE		ind_is_0_second

			MOV		DI,ind_y_y
			MOV		EBX,a[DI]
			CMP		BX,0
			JNE		ind_is_0_second

			CALL	_proc_swap_lines

			;y_y_is_not_0:
			;i_y_minus_1_y_is_0:
			ind_is_0_second:
			MOV		ind, 1

			INC		i
		LOOP	cycle_i
		exit_cycle_i:
		INC		y
	LOOP	cycle_y_pass

ind_is_1:
	MOV		AX, i
	ADD		AX, y
	DEC		AX
		
	DEC		AX
	XOR		DX,DX
	MUL		n
	ADD		AX,y
	DEC		AX
	MUL		size_bytes
	MOV		DI, AX
	MOV		ind_i_y_minus_1_y,DI
	MOV		ECX, a[DI]
	MOV		i_y_minus_1_y, ECX

	MOV		AX, y
	DEC		AX
	XOR		DX, DX
	MUL		n
	ADD		AX, y
	DEC		AX
	MUL		size_bytes
	MOV		DI, AX
	MOV		ind_y_y,DI
	MOV		ECX, a[DI]
	MOV		y_y, ECX

;REWRITE!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		;CWD
		;MOV		EAX, i_y_minus_1_y
		;IDIV		y_y
		;MOV		z,	EAX	
		
	;FINIT
	FLD		i_y_minus_1_y 
	FLD		y_y

	FDIV	
	FSTP	z

	MOV		EAX, i_y_minus_1_y
	CMP		EAX, 0
	JE		from_ind_is_1
	MOV		EAX, y_y
	CMP		EAX, 0
	JE		from_ind_is_1
	MOV		ind, 0

ind_is_0:
	CALL	_proc_adding
	FLD		z
	FLD		y_j
	FMUL
	FSTP	y_j
	FLD		i_y_minus_1_j
	FLD		y_j
	FSUB		
	FSTP	i_y_minus_1_j
	MOV		ECX, i_y_minus_1_j
	MOV		a[SI], ECX
	JMP		from_ind_is_1
exit_cycle_y:

	RET
_proc_add_lines ENDP


_proc_adding PROC
	MOV		AX, i
	ADD		AX, y
	DEC		AX
		
	DEC		AX
	XOR		DX,DX
	MUL		n
	ADD		AX,j
	DEC		AX
	MUL		size_bytes
	MOV		DI, AX
	MOV		SI, DI
	MOV		ECX, a[DI]
	MOV		i_y_minus_1_j, ECX

	MOV		AX, y
	DEC		AX
	XOR		DX, DX
	MUL		n
	ADD		AX, j
	DEC		AX
	MUL		size_bytes
	MOV		DI, AX
	MOV		ECX, a[DI]
	MOV		y_j, ECX

	RET
_proc_adding ENDP
;REWRITE!!!!!!!!!!!!!!!!!!!!!!!!!!!

_proc_comp_i_j	PROC
	MOV		AX, i
	DEC		AX
	XOR		DX, DX
	MUL		n
	ADD		AX, j
	DEC		AX
	MUL		size_bytes
	MOV		DI, AX
	MOV		ECX, a[DI]
	MOV		i_j, ECX
	MOV		ind_i_j, AX

	RET
_proc_comp_i_j	ENDP

_proc_i_y_minus_1 PROC
	MOV		AX, i
	ADD		AX, y
	DEC		AX
		
	;DEC		AX
	;XOR		DX,DX
	;MUL		n
	;MUL		size_bytes
	MOV		ind_i_y_minus_1, AX

	RET
_proc_i_y_minus_1 ENDP


_proc_i_y_minus_1_i PROC
	MOV		AX, ind_i_y_minus_1
	DEC		AX
	XOR		DX, DX
	MUL		n
	ADD		AX, i
	DEC		AX
	MUL		size_bytes
	MOV		ind_i_y_minus_1_i, AX

	RET
_proc_i_y_minus_1_i ENDP


_proc_y_i PROC
	MOV		AX, y
	DEC		AX
	XOR		DX, DX
	MUL		n
	ADD		AX, i
	DEC		AX
	MUL		size_bytes
	MOV		ind_y_i, AX

	RET	
_proc_y_i ENDP

_proc_revers PROC
	MOV		DI,ind_i_y_minus_1_i
	MOV		EBX,a[DI]
	MOV		b_z,EBX
	MOV		DI,ind_y_i
	MOV		EBX,a[DI]
	MOV		DI,ind_i_y_minus_1_i
	MOV		a[DI],EBX
	MOV		EBX,b_z
	MOV		DI,ind_y_i
	MOV		a[DI],EBX
	RET
_proc_revers ENDP

_proc_swap_lines PROC
	XOR		ECX,ECX
	XOR		EBX,EBX
	MOV		BX,y
	MOV		i,BX
	CALL	_proc_i_y_minus_1
	cycle_i_swls:
		MOV		BX,n
		CMP		i,BX
		JG		exit_cycle_i_swls

		CALL	_proc_i_y_minus_1_i
		CALL	_proc_y_i
		CALL	_proc_revers
		INC		i
	LOOP	cycle_i_swls
	exit_cycle_i_swls:
	INC		nrevers
	RET
_proc_swap_lines ENDP


_proc_det PROC
	FILD	ans
	FSTP	ans
	MOV		i,1
	cycle_i_det:
		MOV		BX,n
		CMP		i,BX
		JG		exit_cycle_i_det

		MOV		j,1
		cycle_j_det:
			MOV		BX,n
			CMP		j,BX
			JG		exit_cycle_j_det

			MOV		AX,i
			CMP		AX,j
			JE		mul_det
			from_mul_det:
			CMP		ans,0
			JE		break_det
			INC		j
		LOOP	cycle_j_det
		break_det:
		exit_cycle_j_det:
		INC		i
	LOOP	cycle_i_det

mul_det:
	CALL	_proc_comp_i_j
	MOV		DI, ind_i_j
		
	FLD		ans
	FLD		a[DI]
	FMUL
	FSTP	ans
	JMP		from_mul_det
				
exit_cycle_i_det:
	CWD		

	FILD	two
	FILD	nrevers
	FPREM1			;division st(0) at st(1)and mod in st(0),
					;rounding to near integer
	FSTP	nrevers
	CMP		nrevers,0
	JE		exit_det
	FLD		ans
	FILD	minus_1
	FMUL
	FSTP	ans
exit_det:

	FLD		ans		;ROUNDING
	FRNDINT
	FSTP	ans

	RET
_proc_det ENDP

_proc_ieee754_to_dec PROC
	MOV		i,0
	MOV		EBX,8
	MOV		EAX,ans
	;XOR		EBX,EBX
	XOR		ECX,ECX
	;XOR		EDX,EDX
	;XOR		SI,SI
	XOR		DI,DI
cycle_to_bin:
	CMP		i,BX
	JG		exit_cycle_to_bin
	XOR		SI,SI
	XOR		EDX,EDX
	MUL		base16
	
	ADD		SI,DX
	XOR		DX,DX
	PUSH	EAX
	XOR		EAX,EAX
	MOV		AX,SI
	MUL		two
	MOV		SI,AX
	MOV		CX,HEX_MAP[SI]
	XOR		EAX,EAX
	XOR		EDX,EDX
.286
	MOV		AX,CX
	MOV		j,0
	XOR		CX,CX
cycle_by_bytes:
	;CMP		DI,4
	MOV		DX,4
	CMP		j,DX
	JE		exit_cycle_by_bytes

	XOR		DX,DX
	MUL		base16dw

	MOV		BIN_MAP[DI],DL
	INC		DI
	INC		j
LOOP	cycle_by_bytes
.386
.8087
exit_cycle_by_bytes:
	POP		EAX
	;ADD		DI,2
	INC		i
LOOP	cycle_to_bin
exit_cycle_to_bin:
	MOV		val_begin,8
	MOV		val_end,0

	CALL	_proc_bin_to_dec_a_b

	MOV		EBX,j_temp
	MOV		j,BX
	CMP		BX,127
	JL		pass_sub_127
	SUB		j,127

	MOV		BX,j
	MOV		exponent,BX
	
	XOR		BX,BX
	MOV		BL,BIN_MAP[8]
	PUSH	BX
	MOV		BIN_MAP[8],1
	MOV		val_begin,8
	MOV		BX,exponent
	ADD		val_begin,BX
	MOV		val_end,7		

	CALL	_proc_bin_to_dec_a_b

	MOV		EBX,j_temp
	MOV		mantissa,EBX
	XOR		BX,BX
	POP		BX
	MOV		BIN_MAP[8],BL

	CMP		BIN_MAP[0],0
	JE		num_unsigned	
	;NEG		mantissa
	MOV		minus1,1
num_unsigned:
pass_sub_127:
	XOR		EAX,EAX
	MOV		EAX,mantissa
	RET
_proc_ieee754_to_dec ENDP

_proc_bin_to_dec_a_b PROC
	MOV		i_temp,2
	MOV		j_temp,0
	XOR		EBX,EBX
	MOV		SI,val_begin	;8 val_begin=begin
	CMP		BIN_MAP[SI],0
	JE		cycle_exp
	ADD		j_temp,1				;exponent - j

cycle_exp:	
	DEC		SI
	CMP		SI,val_end		;0 val_end=end
	JE		exit_cycle_exp
	CMP		BIN_MAP[SI],0
	JE		cycle_exp_2

	MOV		EBX,i_temp
	ADD		j_temp,EBX
cycle_exp_2:
	MOV		EBX,i_temp
	ADD		i_temp,EBX
	LOOP	cycle_exp

exit_cycle_exp:
	
	RET
_proc_bin_to_dec_a_b ENDP


_proc_out PROC
	PUSH	EAX
	CMP		minus1,1
	JE		writeminus
after_writeminus:
	POP		EAX

	MOV		ind,0
next:
	CMP		EAX,0
	JZ	val_ax_is0

	XOR		DX,DX
	DIV		b
	MOV		BX,DX   ; DX = 5, AX = 6553
				; BX = DX = 5
	ADD		BL,'0'
	PUSH	BX
	INC		ind
	INC		ndigits

JMP next

val_ax_is0:
output: 

	CMP		ind,0
	JZ		iszero

	DEC		ind
	POP		CX
	MOV		DL,CL
	MOV		AH,02h
	INT		21h

JMP output

;deleteminus:
	;LEA		BX,bs_cr_bs  
	;MOV		AH,09h		
	;INT		21h			
;JMP after_deleteminus		

writeminus:
	
	;POP		EAX
	;NEG		AX
	;PUSH	EAX
	MOV		DL,45		
	MOV		AH,02h		
	INT		21h			 
JMP after_writeminus

iszero:
	CMP		ndigits,1   ;  check number of digits , if ndigits == 1 then 
	JZ		isone		;  check value of variable , if ndigits == 0 then 
						;  output 0 else RET
isone:
	CMP		AX,0
	JZ		iszero3

	JMP final
iszero3:
	;CMP		minus1,0    
	;JE		deleteminus	

after_deleteminus: 
	
	MOV		DL,48
	MOV		AH,02h
	INT		21h
final:

	RET
_proc_out ENDP


start:
	MOV		AX, @data
	MOV		DS, AX
	XOR		AX, AX

	;CALL	_proc_create_file
	;CALL	_proc_write_file

	LDS		DX, point_fname_in	;  for _proc_open_file
	CALL	_proc_open_file
	;CALL	_proc_get_size_file
	CALL	_proc_read_file	

	CALL	_proc_output_desktop_from_file
	CALL	_proc_in_array_from_string

	CALL	_proc_add_lines
	CALL	_proc_det

	CALL	_proc_ieee754_to_dec	;return to AX
	CALL	_proc_out

	;MOV		BL,ndigits
	;MOV		length_out,BL		
	;MOV		string_out,EBX
	;CALL	_proc_write_file

	MOV		AX,4C00h
	INT		21h
end start