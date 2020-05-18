; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

imprimir_msg MACRO class
    push ax
    mov ah, 09h
    lea dx, class
    int 21h
    pop ax

ENDM 

;Macro criada para pular linha 
pularlinha MACRO
        push ax
        mov     al, 0Dh
        mov     ah, 0Eh
        int     10h
        mov     AL, 0Ah
        mov     AH, 0Eh
        int     10h     
        pop     AX
endm 
     

org 100h

; Mensgem
imprimir_msg msg
pularlinha

lea bx, numeros 	;Passamos para bx o endereco da primeira posicao do array 
mov si, 0			;Si sera para acessar os endereços

;Entrando com valores

valores:
; Scan numero
call scan_num
pularlinha
mov w.[bx + si], cx ;Movemos para a posicao bx + si o valor dado pelo usario 
add si,2			;Como estamos trabalhando com word eh necessario incrementar dois 
cmp si,20			;Comparcao feita para ver se ja foi adiconado os 10 valores
jne valores    
 

mov di, 20          ;Di sera utilizado para finalizar o o loop

                   
                    ;Ordem externa fara a parte mais externa do bubble sort, que eh pegar as
ordem_ex:			;primeiras posicoes para iniciar as comparacoes.  
mov si, 0           ;Si sempre retorna para 0, para comecar dnv
sub di, 2           ;Eh preciso decrementar o di para ver se jah foi feita todas as comparacoes 
cmp di, 0           ;Se di chegou a zero, foram feitas todas as compamaracoes 
je array_ordenado
    ordem_in:
    mov ax, w.[bx + si]      ;Passamos o valor das posicoes que serao comparadas para ax e cx. 
    mov cx, w.[bx + si + 2]   
    cmp ax, cx               ;Comparamos ax com cx, caso ax seja maior entraremos na regiao de
    jg troca                 ;troca. Se nao pularemos para a proxima posicao.
    
    contin:
    
    add si,2                 ;Aqui incrementamos dois a SI para pegar a proxima posicao
    cmp si, di               ;Compararemos si, com di para ver se ja chegamos no ultimo elemento 
    je ordem_ex              ;do array, ainda nao testado, caso ja tenha chegado voltaremos para 
    jmp ordem_in             ;o loop mais externo, se nao continuaremos testando.

troca:
mov w.[bx + si],cx           ;Trocamos as posicoes, colocando ax na frente e cx atras.
mov w.[bx + si + 2], ax
jmp contin                   ;Voltamos para o loop interno.

array_ordenado:

pularlinha
imprimir_msg msg_dois
pularlinha         

mov si, 0

imprimindo:                  ;Aqui imprimiremos os elementos do array ja ordenados 

mov ax, w.[bx + si]          ;Movemos pra ax o elemento presente na posicao si do array, para
call print_num               ;ser impressa pelo procedimento print_num
pularlinha
add si,2
cmp si,20
jne imprimindo



fim: 
ret

;Declaracao de variaveis
msg db "Entre com os valores: $"
msg_dois db "Array ordenado: $"
numeros dw 10 DUP(0)


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
