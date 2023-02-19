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

coord_x:    dd  0
coord_y:    dd  0
result1:    dw  0
result2:    dw  0
result3:    dw  0
pointx: db "x = %d",10,0
pointy: db "y = %d",10,0

x1:	dd	0
x2:	dd	0
x3:	dd	0
y1:	dd	0
y2:	dd	0
y3:	dd	0
i:  db  0
determinant:    dd	0
isDirect:       dd	0
print_d:        db "[ %d ]",0,10
inTriangle: db "Point dans le triangle !",10,0
notInTriangle: db "Point pas dans le triangle #sad",10,0

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

mov al, NB_TRIANGLE
mov [i], al

genTriangle:
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
    mov rax,0
    call printf

    mov rdi,print_d
    mov rsi,[y1]
    mov rax,0
    call printf
    
    mov rdi,print_d
    mov rsi,[x2]
    mov rax,0
    call printf
    
    mov rdi,print_d
    mov rsi,[y2]
    mov rax,0
    call printf
    
    mov rdi,print_d
    mov rsi,[x3]
    mov rax,0
    call printf
    
    mov rdi,print_d
    mov rsi,[y3]
    mov rax,0
    call printf

    ; jmp dessin

boucle: ; boucle de gestion des évènements
    mov rdi,qword[display_name]
    mov rsi,event
    call XNextEvent

    cmp dword[event],ConfigureNotify	; à l'apparition de la fenêtre
    je dessin						    ; on saute au label 'dessin'

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
    mov rdi,qword[display_name]
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


    ; appel de la fonction calculDeterminant avec les arguments x1, y1, x2, y2, x3, y3
    mov rdi,[x1]    ; x1
    mov rsi,[y1]    ; y1
    mov rdx,[x2]    ; x2
    mov rcx,[y2]    ; y2
    mov r8,[x3]     ; x3
    mov r9,[y3]     ; y3
    call calculDeterminant

    mov [determinant],rax

    ; mov rdi,print_d
    ; mov rsi,[x1]
    ; mov rax,0
    ; call printf

    ; mov rdi,print_d
    ; mov rsi,[determinant]
    ; mov rax,0
    ; call printf

    cmp word[determinant],0
    jl negatif
    mov ah,1
    mov [isDirect],ah
    ; cmp word[determinant],1

    dessin_x:
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
        ; appel de la fonction calculDeterminant avec les arguments x1, y1, x2, y2, x3, y3
        mov rdi,[x1]        ; x1
        mov rsi,[y1]        ; y1
        mov rdx,[x2]        ; x2
        mov rcx,[y2]        ; y2
        mov r8,[coord_x]    ; coord_x
        mov r9,[coord_y]    ; coord_y
        call calculDeterminant
        mov [result1],rax

        ; appel de la fonction calculDeterminant avec les arguments x1, y1, x2, y2, x3, y3
        mov rdi,[x2]        ; x2
        mov rsi,[y2]        ; y2
        mov rdx,[coord_x]   ; coord_x
        mov rcx,[coord_y]   ; coord_y
        mov r8,[x3]         ; x3
        mov r9,[y3]         ; y3
        call calculDeterminant
        mov [result2],rax

        ; appel de la fonction calculDeterminant avec les arguments x1, y1, x2, y2, x3, y3
        mov rdi,[x3]        ; x3
        mov rsi,[y3]        ; y3
        mov rdx,[coord_x]   ; coord_x
        mov rcx,[coord_y]   ; coord_y
        mov r8,[x1]         ; x1
        mov r9,[y1]         ; y1
        call calculDeterminant
        mov [result3],rax
        
        cmp isDirect,0
        je positif
        jmp negatif

        positif:
            cmp word[result1],0
            jl point_pasdessin

            cmp word[result1],1
            jge pos_valide2

            pos_valide2:
                cmp word[result2],0
                jl point_pasdessin
                cmp word[result2],1
                jge pos_valide3

            pos_valide3:
                cmp word[result3],0
                jl point_pasdessin
                cmp word[result3],1
                jge point_dessin

        negatif:
            cmp word[result1],0
            jl point_pasdessin

            cmp word[result1],1
            jge neg_valide2

            neg_valide2:
                cmp word[result2],0
                jl point_pasdessin
                cmp word[result2],1
                jge neg_valide3

            neg_valide3:
                cmp word[result3],0
                jl point_pasdessin
                cmp word[result3],1
                jge point_dessin

        point_dessin:
            mov rdi,inTriangle
            mov rax,0
            call printf
            jmp fin

        point_pasdessin:
            mov rdi,notInTriangle
            mov rax,0
            call printf
            jmp fin

        add word[coord_y],1 ; y++
        cmp word[coord_y],10
        jle dessin_y
        mov word[coord_y],0 ; reset de y
        add word[coord_x],1 ; x++
        cmp word[coord_x],10
        jle dessin_x

    fin:

    ; dec byte[i]
    ; cmp byte[i], 0
    ; jg genTriangle
    ; jmp boucle


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

    ; mov rax, rbx

    ; mov rdi,print_d
    ; mov rsi,rax
    ; mov rax,0
    ; call printf

    pop rbx
    mov rsp,rbp
    pop rbp
    ret