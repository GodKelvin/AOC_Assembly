
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

;Macro criada para inprimir strings
imprimir_msg MACRO class
    push ax
    mov ah, 09h
    lea dx, class
    int 21h
    pop ax
endm

;Macro criada para pular linha.
;A sub-intereirfdjwo OEh armazenada em AH mudarar de pagina se necessario.

pularlinha MACRO
        push	ax       
        mov		al, 0Dh
        mov		ah, 0Eh         
        int		10h
        mov		al, 0Ah
        mov		ah, 0Eh
        int 	10h     
        pop		ax
ENDM 
     

org 100h

; Imprimindo a mensgem
imprimir_msg msg

; Scan_num eh um procedimento feito para entrada de dados atraves do 
; teclado, fornecida pelo professor para otimizar o nosso trabalho. 
call scan_num
mov numero, cx

; Pular linha
pularlinha

mov ax, numero     
cmp ax, 0               ; Testando se a variavel e igual a zero
je se_zero              ; se sim vamos pular pro setor do codigo se_zero
         
mov dx,0         
idiv dois               ; Fazemos a divisao por dois para descobrir se eh par ou impar
cmp dx, 0               ; Comparamos o registrador ah (aonde fica guardado o resto da divisao), se resto for igual a
je se_par               ; zero o valor eh par e pulamos pra regiao se_par


; Caso o resto nao seja zero o numero sera impar entao passaremos pra essa regiao
; onde printamos a mensagem de impar.   
imprimir_msg impar
mov ax, numero
cmp al, 1				;Comparamos com 1, porque caso o valor impar seja o 1 ele nao eh primo  
je nao_primo 			;pularemos para o setor de nao_primo
jmp testar_primo		;Caso seja diferente de 1, testaremos se eh primo ou nao  

;Se o valor for zero vamos printar na tela a mensagem gravada na
;variavel zero e ir para o fim do codigo.
se_zero: 
imprimir_msg zero	
jmp fim

se_par:
    cmp ax, 1           ;Aqui comparamos se o valor da divisao eh igual a 1, se sim  
    imprimir_msg par   	;sabemos que o valor testado eh o 2 e eh o unico par e primo.  															
    je primo			;pulamos para o setor primo.
    jmp nao_primo		;Caso nao seja 2 vamos direto para o nao_primo
           
testar_primo:
    mov bx, 1			;Comecamos o bl, que sera o nosso divisor, em dois. 

teste_primo:
    mov ax, numero		;Movemos para ax o numero testado.    
    mov dx,0            
    div bx  			;Dividimos por bl.   
    inc bx
    cmp dx,0			;Testamos se a divisao tem resto 0, caso seja 0 
    je divisor			;bl sera um divisor e pularemos para o setor de divisor.
    jmp teste_primo		;Se nao voltaremos para testar o proximo valor de bl 


divisor:
    cmp ax, 1    		;Eh preciso comparar se o resultado da divisao eh diferente de 1
    je primo			;porque se for quer dizer que o divisor foi o proprio valor
    jmp nao_primo	 	;entao o numero testado eh primo. Caso seja diferente saberemos que	
						;o divisor eh outro valor, entao o numero nao sera primo, pularemos para  
						;o setor nao_primo.  	

primo:
pularlinha			 	;Apenas imprimira a mensagem de dizendo que eh primo.
imprimir_msg var_primo	  
jmp fim					;Pulara para o final do programa. 

nao_primo:              ;Apenas imprimira a mensagem de dizendo que nao eh primo.
    pularlinha			
    imprimir_msg var_nao_primo      

fim: 
ret

;Declaracao de variaveis
msg DB "Entre com um valor: $"
impar DB "IMPAR!$"
par DB "PAR!$"
zero DB "ZERO!$"
var_primo DB "PRIMO!$"
var_nao_primo DB "NAO PRIMO!$"
numero DW 0
dois DW 2

; this macro prints a char in AL and advances
; the current cursor position:
PUTC    MACRO   char
        PUSH    AX
        MOV     AL, char
        MOV     AH, 0Eh
        INT     10h     
        POP     AX
ENDM

; gets the multi-digit SIGNED number from the keyboard,
; and stores the result in CX register:
SCAN_NUM        PROC    NEAR
        PUSH    DX
        PUSH    AX
        PUSH    SI
        
        MOV     CX, 0

        ; reset flag:
        MOV     CS:make_minus, 0

next_digit:

        ; get char from keyboard
        ; into AL:
        MOV     AH, 00h
        INT     16h
        ; and print it:
        MOV     AH, 0Eh
        INT     10h

        ; check for MINUS:
        CMP     AL, '-'
        JE      set_minus

        ; check for ENTER key:
        CMP     AL, 0Dh  ; carriage return?
        JNE     not_cr
        JMP     stop_input
not_cr:


        CMP     AL, 8                   ; 'BACKSPACE' pressed?
        JNE     backspace_checked
        MOV     DX, 0                   ; remove last digit by
        MOV     AX, CX                  ; division:
        DIV     CS:ten                  ; AX = DX:AX / 10 (DX-rem).
        MOV     CX, AX
        PUTC    ' '                     ; clear position.
        PUTC    8                       ; backspace again.
        JMP     next_digit
backspace_checked:


        ; allow only digits:
        CMP     AL, '0'
        JAE     ok_AE_0
        JMP     remove_not_digit
ok_AE_0:        
        CMP     AL, '9'
        JBE     ok_digit
remove_not_digit:       
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered not digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for next input.       
ok_digit:


        ; multiply CX by 10 (first time the result is zero)
        PUSH    AX
        MOV     AX, CX
        MUL     CS:ten                  ; DX:AX = AX*10
        MOV     CX, AX
        POP     AX

        ; check if the number is too big
        ; (result should be 16 bits)
        CMP     DX, 0
        JNE     too_big

        ; convert from ASCII code:
        SUB     AL, 30h

        ; add AL to CX:
        MOV     AH, 0
        MOV     DX, CX      ; backup, in case the result will be too big.
        ADD     CX, AX
        JC      too_big2    ; jump if the number is too big.

        JMP     next_digit

set_minus:
        MOV     CS:make_minus, 1
        JMP     next_digit

too_big2:
        MOV     CX, DX      ; restore the backuped value before add.
        MOV     DX, 0       ; DX was zero before backup!
too_big:
        MOV     AX, CX
        DIV     CS:ten  ; reverse last DX:AX = AX*10, make AX = DX:AX / 10
        MOV     CX, AX
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for Enter/Backspace.
        
        
stop_input:
        ; check flag:
        CMP     CS:make_minus, 0
        JE      not_minus
        NEG     CX
not_minus:

        POP     SI
        POP     AX
        POP     DX
        RET
make_minus      DB      ?       ; used as a flag.
SCAN_NUM        ENDP                             

; this procedure prints number in AX,
; used with PRINT_NUM_UNS to print signed numbers:
PRINT_NUM       PROC    NEAR
        PUSH    DX
        PUSH    AX

        CMP     AX, 0
        JNZ     not_zero

        PUTC    '0'
        JMP     printed

not_zero:
        ; the check SIGN of AX,
        ; make absolute if it's negative:
        CMP     AX, 0
        JNS     positive
        NEG     AX

        PUTC    '-'

positive:
        CALL    PRINT_NUM_UNS
printed:
        POP     AX
        POP     DX
        RET
PRINT_NUM       ENDP

; this procedure prints out an unsigned
; number in AX (not just a single digit)
; allowed values are from 0 to 65535 (FFFF)
PRINT_NUM_UNS   PROC    NEAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX

        ; flag to prevent printing zeros before number:
        MOV     CX, 1

        ; (result of "/ 10000" is always less or equal to 9).
        MOV     BX, 10000       ; 2710h - divider.

        ; AX is zero?
        CMP     AX, 0
        JZ      print_zero

begin_print:

        ; check divider (if zero go to end_print):
        CMP     BX,0
        JZ      end_print

        ; avoid printing zeros before number:
        CMP     CX, 0
        JE      calc
        ; if AX<BX then result of DIV will be zero:
        CMP     AX, BX
        JB      skip
calc:
        MOV     CX, 0   ; set flag.

        MOV     DX, 0
        DIV     BX      ; AX = DX:AX / BX   (DX=remainder).

        ; print last digit
        ; AH is always ZERO, so it's ignored
        ADD     AL, 30h    ; convert to ASCII code.
        PUTC    AL


        MOV     AX, DX  ; get remainder from last div.

skip:
        ; calculate BX=BX/10
        PUSH    AX
        MOV     DX, 0
        MOV     AX, BX
        DIV     CS:ten  ; AX = DX:AX / 10   (DX=remainder).
        MOV     BX, AX
        POP     AX

        JMP     begin_print
        
print_zero:
        PUTC    '0'
        
end_print:

        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET
PRINT_NUM_UNS   ENDP



ten             DW      10      ; used as multiplier/divider by SCAN_NUM & PRINT_NUM_UNS.