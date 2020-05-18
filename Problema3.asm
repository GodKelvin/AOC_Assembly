
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

;Entrando  com o valor da base B
imprimir_msg base
call scan_num
mov B, cx                             ;Passamos cx para B para guardar o valor
mov res, cx                       	  ;Movemos tambem cx para res

;AX sera a base que irei trabalhar
mov ax, cx
pularLinha


;Entando com o valor de N
imprimir_msg numero
call scan_num
mov N, cx                              ;Guardando na variavel N o valor desejado
mov bx, cx

;pularLinha
pularLinha

;Segunda parte da tarefa------
mov expo, 0                           ;Fizemos antes para o caso de elevado a 0 ser o menor antes
call potencia                         ;do valor desejado. Ja ira pro final quando entrar no
                                      ;loopVerExpo.
loopVerExpo:
    ;para fins de comparacao
    mov cx, res
    cmp cx, N                        ;Comparamos se o resultado da potencia eh menor ou igual
    ;pularlinha                      ;o valor, caso seja entraremos dentro de chamarPotencia 
    jle chamarPotencia               ;que fara com o proximo exponte, ate que o valor seja maior.
    jmp fimLoop                      ;Quando o resultado ficar maior que o valor, sairemos do
                                     ;loop e vamos para o final do codigo, onde imprimiremos o 
    chamarPotencia:                  ;resultado.
        
        mov si, 1                    ;Reiniciar as variaveis
        mov ax, B                    ;para entrar novamente no procedimento potencia
        mov di, expo
        ;incremento em +1 o expoente
        inc di
        mov expo, di  
        ;Reinicio o valor de Res
        mov dx, B
        mov res, dx
        ;chamo a potenciacao
        call potencia
        cmp expo, -1                 ;Aqui comparamos com -1, caso seja sim significa que 
        je fimLoopOverFlow           ;aconteceu um overflow, vamos para o setor de overflow. 
        jmp loopVerExpo              ;(Veja no procedimento o teste de overflow). 
                                     ;Volteremos para testar o expoente.
               
fimLoop:                      
dec expo                             ;Como fazemos ate um menor ou igual eh preciso decrementar 
imprimir_msg msg_f1                  ;expo para ter o expoente final.
mov ax, N                            ;Apartir daqui eh o print final com o resultado. 
call print_num
imprimir_msg msg_f2
mov ax, B
call print_num
imprimir_msg msg_f3
mov ax, expo
call print_num


jmp fimCod    

fimLoopOverFlow:                     ;Imprimiremos a mesagem de overflow.
    imprimir_msg overflow
    jmp fimCod
    
fimCod:
    ret 
;---------------------------------------------------
    
;declarando variaveis
N dw 0
B dw 0
res dw 0
expo dw 0
base dw "Entre com a base: $"
numero dw "Entre com o numero: $"
msg_f1 dw "Log de $"
msg_f2 dw " na base $"
msg_f3 dw " eh igual $"
overflow dw "OverFlow $"



;FUNCAO POTENCIA ---------------------------------
;Variaveis usadas: si = 1, ax = B, res = B, 
potencia proc
    ;se for igual a 0, retorna 1
    cmp expo, 0
    je  tratExpoZero
    
    ;se for igual a 1, retorna o proprio res
    cmp expo, 1
    je tratExpoUm
    
    ;se nao
    mul res            ;Multiplicamos res por ax e testamos se houve overflow, caso aconteca
    jo over            ;vamos para o setor over.
    mov res, ax
    mov ax, B
    inc si             ;Incrementamos o valor de si e comparamos com expo, para ver se ja foi 
    cmp si, expo       ;alcancado o expoente pedido. Se sim voltamos com ret, caso nao,
    jne potencia       ;voltamos para potencia
    ret                             
    
    tratExpoZero:
        mov res, 1
        ret
        
    tratExpoUm:
        ret 
    
    over:         
        mov expo, -1    ;Caso tenha acontecido um overflow, entramos aqui e passamos para expo
        ret             ;-1, que sera comparado mais acima.   
potencia endp
;---------------------- ------------------------


imprimir_msg macro class
    push ax
    mov ah, 09h
    lea dx, class
    int 21h
    pop ax
endm


pularLinha MACRO
        PUSH    AX
        MOV     AL, 0Dh
        MOV     AH, 0Eh
        INT     10h
        MOV     AL, 0Ah
        MOV     AH, 0Eh
        INT     10h     
        POP     AX
ENDM 



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
