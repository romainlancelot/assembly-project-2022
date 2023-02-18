extern printf

global main

section .data
x1:     dw  0
print:  db  "%d",10,0

section .text
main:

push rbp

; tirer un nombre au hasard rdrand
mov ax,0
rdrand ax

; utiliser modulo pour le ramener entre 0 et 400
mov bx, 400
xor dx, dx ; initialiser DX à 0
div bx
mov word[x1], dx ; stocker le reste dans x1

; afficher le nombre
mov rdi,print
movzx rsi,word[x1]
mov rax,0
call printf

pop rbp

mov rax,60
mov rdi,0
syscall
ret