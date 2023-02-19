extern printf

global main

section .data
pointx: db "x = %d",10,0
pointy: db "y = %d",10,0

coord_x: dw 0
coord_y: dw 0

section .text
main:
push rbp

; for(i=0;i<400;i++)

dessin:

dessin_y:

mov rdi,pointx
movzx rsi,word[coord_x]
mov rax,0
call printf

mov rdi,pointy
movzx rsi,word[coord_y]
mov rax,0
call printf

;###################################
;#  Code de dessin pour point ici  #
;###################################

add word[coord_y],1 ; y++

cmp word[coord_y],10
jle dessin_y

mov word[coord_y],0 ; reset de y

add word[coord_x],1 ; x++

cmp word[coord_x],10
jle dessin

fin:
pop rbp
mov rax,60
mov rdi,0
syscall
ret
