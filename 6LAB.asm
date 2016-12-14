multiplex_number = 0ffh
program_segment segment 'code'
assume cs:program_segment, ds:program_segment
    org     100h
main:
	   jmp     installation


;----------------//Резидентная часть//------------------------
	   old_int09h dd (?)  
	   old_int2fh dd (?)  

new_2fh proc         
                                 ; Мультиплексное прерывание 2Fh
	   cmp     ah, multiplex_number ; сверяет число мульт.плекс. процесса, 
	   jne     at_jump              ; если не находит число текущего процесса, то
	   jmp     resident_2fh         ; переходит на стандартное 
at_jump:	

unknown_function:
	   jmp cs:old_int2fh
resident_2fh:       ; проверяет число функции             
                    ; выбирает и переходит на верную
                    
 
    cmp     al, 00h           ; переходит на ф-ю загружен ли резидент
	   jne     at_jump2                 
	   jmp     resident_is_loaded            
at_jump2:	         

	    
    cmp     al, 01h           ; переходит на выгружаемую функцию
	   jne     at_jump3              
	   jmp     resident_unload        
at_jump3:	              



	   jmp     unknown_function        ; переходит на неизвестную функцию
                                    ; если номер функции не определен

                                    
                    
resident_is_loaded:                 ; если резидестная
                                    ; часть была уже загружена
                                   
	   mov     al, 0ffh                      
	   iret
                                
resident_unload:                    ; если рез. часть была выгружена
                    
	   push    ax dx ds es   
                    
	   mov     ax, 2509h      ; установка стандартного int09h
	   lds     dx, cs:old_int09h
	   int     21h
                    
	   mov     ax, 252fh      ; установка стандартного int2fh
	   lds     dx, cs:old_int2fh
	   int     21h
                    
	   mov     es, cs:2ch     ; очищение сегмена переменных
    mov     ah, 49h
    int     21h
                    
    push    cs         ;  очищение сегмента кода программы
    pop     es
    mov     ah, 49h
    int     21h
                    
	   pop es ds dx ax    
	   iret
new_2fh endp
                    
ungetc proc         ; помещаем символ из CX в буфер клавиатуры с помощью  
	   push ax         ; 5 функции int 16h прерывания BIOS
	   mov ah, 5
	   int 16h
	   pop ax
	   ret
ungetc endp
                                      ; E(12h)->F(21h)
	                                     ; Y(15h)->Z(2Ch)
                                      ; U(16h)->V(2Fh)
                                      ; I(17h)->J(24h)
                                      ; O(18h)->P(19h)
                                      ; A(1Eh)->B(30h)
                                      ; SHIFT LEFT(2A)
                                      ; SHIFT RIGHT(36)
                                      ; CAPS LOCK(3A)

new_09h proc        
    push ax cx         
; нажата следующая клавиша:

	                                    ;;in al, 60h                  
                                    ;;cmp al, 42
	                                    ;;je shift_jump
	                                    ;;jmp not_shift_left
                                   ;; shift_jump:
                                    ;cmp bl, 10
	                                    ;je shift_jump
	                                    ;jmp not_shift_left
                                    ;shift_jump:
                                    ;mov byte ptr ds:0417h, 10
                                    ; case 'shift left on':
                                     ;mov cx, 2Ah
                                    ;call ungetc
                                     ;;in al, 60h              
                                   ;; cmp al, 12h
	                                    ;;je e_jmp
	                                   ;; jmp not_e
                                    ;;e_jmp:
                                    ; case 'E':
                                     ;;mov cx, 'F'
                                     ;;call ungetc
                                     ;mov byte ptr ds:0417h,0
                                     ;;jmp new_09h_final
                                    ;;not_shift_left:

    in      al, 60h
    cmp     al, 12h
	   je      at_jump5
	   jmp     not_e
at_jump5:

; если 'e':
	   mov     cx, 'f'
	   call    ungetc
	   jmp     new_09h_final

not_e:
    cmp     al, 15h
	   je      at_jump6
	   jmp     not_y
at_jump6:
; если 'y':
	   mov     cx, 'z'
	   call    ungetc
	   jmp     new_09h_final

not_y:
    cmp     al, 16h
	   je      at_jump7
	   jmp     not_u
at_jump7:
; если 'u':
	   mov     cx, 'v'
	   call    ungetc
	   jmp     new_09h_final

not_u:
    cmp     al, 17h
	   je      at_jump8
	   jmp     not_i
at_jump8:
; если 'i':	
	   mov     cx, 'j'
	   call    ungetc
	   jmp     new_09h_final

not_i:
    cmp     al, 18h
	   je      at_jump9
	   jmp     not_o
at_jump9:
; если 'o':
	   mov     cx, 'p'
	   call    ungetc	
	   jmp     new_09h_final

not_o:
    cmp     al, 1eh
	   je      at_jump10
	   jmp     not_a
at_jump10:
; если 'a':
    mov     cx, 'b'
    call    ungetc
    jmp     new_09h_final

not_a:

; действия по умолчанию , если не нажаты нужные клавиши, то
; восстанавливаем регистры и вызываем стандартное int09h
	   pop     cx ax
	   jmp     cs:[old_int09h]
new_09h_final:

; заканчиваем прерывание
	   mov     al, 20h
    out     20h, al

	   pop cx ax  
	iret
new_09h endp

; ------------//Инсталляционная часть//---------------------
installation proc
	   mov     cl, es:80h                         
    
	   cmp     cl, 0           ; проверка на аргументы коммнадной строки 
	   jne     at_jump4
	   jmp     no_command_line_arguments
at_jump4:	            
                     
	   xor     ch, ch          ; запуск , если есть аргументы командной строки
   
	   mov     di, 81h         ; пропуск пробелов
	   mov     al, ' '
repe scasb          
                    
	   dec     di              ; проверка коммнадной строки
	   mov     cx, 3
	   lea     si, close_parameter
repe cmpsb                  ; перейти ,если верные аргументы
                     

	   je      resident_unload_argument    ; если некорректные аргументы
                              

;-----                              
	   push    ax dx                    
	   mov     ah, 09h                 
	   lea     dx, mes_incorr_args
	   int     21h
	   pop     dx ax   
;-----  


shut_down_prog:                 
	   mov     ax, 4c00h
	int 21h

resident_unload_argument:       ; если корректные аргументы
                                ; был ли уже загружен резидент?
	   mov     ah, multiplex_number
	   mov     al, 00h
	int 2fh                        
                                
    cmp     al, 0ffh            ; попытка выгрузить резидента 
	   je      at_jump11            ; который не был еще загружен
	   jmp     resident_unload_error
at_jump11:

	   mov     ah, multiplex_number       ; выгрузка резидента, очистка памяти 
	   mov     al, 01h                    ; и установка стандартных int09h и int2fh
	   int 2fh
  ;-----                              
	   push    ax dx                   ; вывод сообщения  
	   mov     ah, 09h                  
	   lea     dx, mes_res_first_unload
	   int     21h
	   pop     dx ax   
  ;-----                                
	   jmp     shut_down_prog

resident_unload_error:  ; если совершена попытка выгрузить резидента, который 
                        ; не был еще загружен
                      
  ;-----                              
	   push    ax dx                   
	   mov     ah, 09h                 
	   lea     dx, mes_res_unload_error
	   int     21h
	   pop     dx ax   
  ;-----              

	   jmp     shut_down_prog

no_command_line_arguments:  
                            ; проверка был ли уже загружен резидент
	   mov     ah, multiplex_number
	   mov     al, 00h
	   int     2fh
                           
    cmp     al, 0ffh        ; первая загрузка резидента
	   je      at_jump12            
	   jmp     first_load
at_jump12:
                            ; иначе , резидент уже загружен
                            

 ;-----                              
	   push    ax dx                   ; write information message 
	   mov     ah, 09h                 ; to console and close program
	   lea     dx, mes_res_load
	   int     21h
	   pop     dx ax   
 ;-----         


	   jmp     shut_down_prog
                            
                            
first_load:                 ; первая загрузка резидента
                            ; получить и сохранить данные стандартного int 2fh
	   mov     ax, 352fh
	   int     21h
	   mov     word ptr cs:old_int2fh, bx
	   mov     word ptr cs:old_int2fh+2, es
                            ; установить новое int 2fh
	   mov     ax, 252fh
	   lea     dx, new_2fh
	   int     21h
                            ; получить и сохранить данные стандартного int 09h                        
	   mov     ax, 3509h
	   int     21h
	   mov     word ptr cs:old_int09h, bx
    mov     word ptr cs:old_int09h+2, es
                            ; установка своего int 09h
	   mov     ax, 2509h
    lea     dx, new_09h
    int     21h
                            
	
;-----                              
	   push    ax dx                   ; вывод сообщения и закрытие программы, но
	   mov     ah, 09h                 
	   lea     dx, mes_res_firs_load
	   int     21h
	   pop     dx ax   
  ;-----     

                           
    lea     dx, installation        ; остаемся резидентом
	   int     27h

;-----------//Объявление данных//---------------------------
	close_parameter        db '-d', 13
	mes_res_firs_load      db 'Resident loaded.', 10, 13, '$'
	mes_res_first_unload   db 'Resident has been unloaded.', 10, 13, '$'
	mes_res_load           db 'Resident had been loaded!', 10, 13, '$'
	mes_incorr_args        db 'Error! Incorrect command line arguments!', 10, 13, '$'
	mes_res_unload_error   db "Error! Resident hasn't been loaded!", 10, 13, "$"
program_segment ends
installation endp
end main