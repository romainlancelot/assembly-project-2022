; external functions from X11 library
extern XOpenDisplay
extern XDisplayName
extern XCloseDisplay
extern XCreateSimpleWindow
extern XMapWindow
extern XRootWindow
extern XSelectInput
extern XFlush
extern XCreateGC
extern XSetForeground
extern XDrawLine
extern XDrawPoint
extern XFillArc
extern XNextEvent
extern XFillPolygon

; external functions from stdio library (ld-linux-x86-64.so.2)    
extern printf
extern exit

%define	StructureNotifyMask	131072
%define KeyPressMask		1
%define ButtonPressMask		4
%define MapNotify		    19
%define KeyPress		    2
%define ButtonPress		    4
%define Expose			    12
%define ConfigureNotify		22
%define CreateNotify        16
%define QWORD	            8
%define DWORD	            4
%define WORD	            2
%define BYTE	            1
%define NB_TRIANGLE         1

global main

section .bss
display_name:	resq	1
screen:			resd	1
depth:         	resd	1
connection:    	resd	1
width:         	resd	1
height:        	resd	1
window:		    resq	1
gc:		        resq	1

section .data

event:		times	24 dq 0

x1:	dd	0
x2:	dd	0
x3:	dd	0
y1:	dd	0
y2:	dd	0
y3:	dd	0
determinant:    dd	0
print_d:        db "[ %d ]",0,10
pos:            db "Determinant = %d, triangle indirect !",10,0
neg:            db "Determinant = %d, triangle direct !",10,0

section .text
	
;##################################################
;########### PROGRAMME PRINCIPAL ##################
;##################################################

main:
xor     rdi,rdi
call    XOpenDisplay	; Création de display
mov     qword[display_name],rax	; rax=nom du display

; display_name structure
; screen = DefaultScreen(display_name);
mov     rax,qword[display_name]
mov     eax,dword[rax+0xe0]
mov     dword[screen],eax

mov rdi,qword[display_name]
mov esi,dword[screen]
call XRootWindow
mov rbx,rax

mov rdi,qword[display_name]
mov rsi,rbx
mov rdx,10
mov rcx,10
mov r8,400	; largeur
mov r9,400	; hauteur
push 0xFFFFFF	; background  0xRRGGBB
push 0x00FF00
push 1
call XCreateSimpleWindow
mov qword[window],rax

mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,131077 ;131072
call XSelectInput

mov rdi,qword[display_name]
mov rsi,qword[window]
call XMapWindow

mov rsi,qword[window]
mov rdx,0
mov rcx,0
call XCreateGC
mov qword[gc],rax

mov rdi,qword[display_name]
mov rsi,qword[gc]
mov rdx,0x000000	; Couleur du crayon
call XSetForeground

; coordonnées des points du triangle
call coordonnees
mov word[x1],dx
call coordonnees
mov word[y1],dx
call coordonnees
mov word[x2],dx
call coordonnees
mov word[y2],dx
call coordonnees
mov word[x3],dx
call coordonnees
mov word[y3],dx

; mov dx,14
; mov word[x1],dx
; mov dx,20
; mov word[y1],dx
; mov dx,25
; mov word[x2],dx
; mov dx,69
; mov word[y2],dx
; mov dx,10
; mov word[x3],dx
; mov dx,60
; mov word[y3],dx

mov rdi,print_d
mov rsi,[x1]
call printf
mov rdi,print_d
mov rsi,[y1]
call printf
mov rdi,print_d
mov rsi,[x2]
call printf
mov rdi,print_d
mov rsi,[y2]
call printf
mov rdi,print_d
mov rsi,[x3]
call printf
mov rdi,print_d
mov rsi,[y3]
call printf

; appel de la fonction calculDeterminant avec les arguments x1, y1, x2, y2, x3, y3
mov rdi,[x1]    ; x1
mov rsi,[y1]    ; y1
mov rdx,[x2]    ; x2
mov rcx,[y2]    ; y2
mov r8,[x3]     ; x3
mov r9,[y3]     ; y3
call calculDeterminant

mov [determinant],rax

cmp word[determinant],0
jl negatif

cmp word[determinant],1
jge positif

positif:
    mov rdi,pos
    movsx rsi,word[determinant]
    mov rax,0
    call printf
    jmp fin

negatif:
    mov rdi,neg
    movsx rsi,word[determinant]
    mov rax,0
    call printf
    jmp fin

fin:
    pop rbp
    mov rax,60
    mov rdi,0
    syscall

boucle: ; boucle de gestion des évènements
mov rdi,qword[display_name]
mov rsi,event
call XNextEvent

cmp dword[event],ConfigureNotify	; à l'apparition de la fenêtre
je dessin							; on saute au label 'dessin'

cmp dword[event],KeyPress			; Si on appuie sur une touche
je closeDisplay						; on saute au label 'closeDisplay' qui ferme la fenêtre
jmp boucle

;#########################################
;#		DEBUT DE LA ZONE DE DESSIN		 #
;#########################################
dessin:
; couleurs sous forme RRGGBB où RR esr le niveau de rouge, GG le niveua de vert et BB le niveau de bleu
; 0000000 (noir) à FFFFFF (blanc)

;couleur du triangle
mov rdi,qword[display_name]
mov rsi,qword[gc]
mov edx,0x000000	; Couleur du crayon ; noir
call XSetForeground

; dessin de la ligne 1
mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,qword[gc]
mov ecx,dword[x1]	; coordonnée source en x
mov r8d,dword[y1]	; coordonnée source en y
mov r9d,dword[x2]	; coordonnée destination en x
push qword[y2]		; coordonnée destination en y
call XDrawLine

; dessin de la ligne 2
; mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,qword[gc]
mov ecx,dword[x1]	; coordonnée source en x
mov r8d,dword[y1]	; coordonnée source en y
mov r9d,dword[x3]	; coordonnée destination en x
push qword[y3]		; coordonnée destination en y
call XDrawLine

; dessin de la ligne 2
mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,qword[gc]
mov ecx,dword[x3]	; coordonnée source en x
mov r8d,dword[y3]	; coordonnée source en y
mov r9d,dword[x2]	; coordonnée destination en x
push qword[y2]		; coordonnée destination en y
call XDrawLine



; ############################
; # FIN DE LA ZONE DE DESSIN #
; ############################m
jmp flush

flush:
mov rdi,qword[display_name]
call XFlush
jmp boucle
mov rax,34
syscall

closeDisplay:
    mov     rax,qword[display_name]
    mov     rdi,rax
    call    XCloseDisplay
    xor	    rdi,rdi
    call    exit


global coordonnees
coordonnees:
    ; tirer un nombre au hasard rdrand
    mov ax,0
    rdrand ax

    ; utiliser modulo pour le ramener entre 0 et 400
    mov bx, 400
    xor dx, dx ; initialiser DX à 0
    div bx
    ; le résultat se trouve dans dx

    ret

global calculDeterminant
calculDeterminant:
    push rbp
    mov rbp,rsp
    push rbx

    ; prendre des arguments
    mov rax,0
    add rax,rdi         ; x1 (ax)
    add rax,rsi         ; y1 (ay)
    add rax,rdx         ; x2 (bx)
    add rax,rcx         ; y2 (by)
    add rax,r8          ; x3 (cx)
    add rax,r9          ; y3 (cy)

    ; calcul du déterminant de trois points A(x1,y1), B(x2,y2) et C(x3,y3)
    ; bax = ax - bx;
    ; bay = ay - by;
    ; bcx = cx - bx;
    ; bcy = cy - by;
    ; determinant = (bax * bcy) - (bcx * bay);
    ; determinant = (ax - bx) * (cy - by) - (cx - bx) * (ay - by)
    ; determinant = (x1 - x2) * (y3 - y2) - (x3 - x2) * (y1 - y2)

    mov rbx, rdi        ; rbx = x1
    sub rbx, rdx        ; rbx = x1 - x2
    mov rdi, r9         ; rdi = y3
    sub rdi, rcx        ; rdi = y3 - y2
    imul rbx, rdi       ; rbx = (x1 - x2) * (y3 - y2)

    mov rdi, r8         ; rdi = x3
    sub rdi, rdx        ; rdi = x3 - x2
    mov rax, rsi        ; rax = y1
    sub rax, rcx        ; rax = y1 - y2
    imul rdi, rax       ; rdi = (x3 - x2) * (y1 - y2)

    sub rbx, rdi        ; rbx = (x1 - x2) * (y3 - y2) - (x3 - x2) * (y1 - y2)

    mov rax, rbx

    ; mov rdi,print_d
    ; mov rsi,rax
    ; mov rax,0
    ; call printf

    pop rbx
    pop rbp
    ret