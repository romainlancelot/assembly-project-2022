extern printf

global main

section .data
inTriangle: db "Point dans le triangle !",10,0
notInTriangle: db "Point pas dans le triangle #sad",10,0
point: db "Point %d",10,0

result1: dw 72
result2: dw 69
result3: dw 80

section .text
main:
push rbp

mov rdi,point
movsx rsi,word[result1]
mov rax,0
call printf

mov rdi,point
movsx rsi,word[result2]
mov rax,0
call printf

mov rdi,point
movsx rsi,word[result3]
mov rax,0
call printf

cmp word[result1],0
jl pasdessin

cmp word[result1],1
jge valide2

valide2:
cmp word[result2],0
jl pasdessin

cmp word[result2],1
jge valide3

valide3:
cmp word[result3],0
jl pasdessin

cmp word[result3],1
jge dessin

dessin:
mov rdi,inTriangle
mov rax,0
call printf
jmp fin

pasdessin:
mov rdi,notInTriangle
mov rax,0
call printf
jmp fin

fin:
pop rbp
mov rax,60
mov rdi,0
syscall

ret
