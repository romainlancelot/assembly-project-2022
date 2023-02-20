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
; extern XFillPolygon

; external functions from stdio library (ld-linux-x86-64.so.2)    
extern printf
extern exit

%define MaxColor        16777215
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
%define NB_TRIANGLE         2

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
color:          resw    1

section .data

event:		times	24 dq 0

x1:	            dw	0
x2:	            dw	0
x3:	            dw	0
y1:	            dw	0
y2:	            dw	0
y3:     	    dw	0
i:              dd  0
genok:          dd  0
determinant:    dd	0
isDirect:       dd	0
coord_x:        dw  0
coord_y:        dw  0
result1:        dw  0
result2:        dw  0
result3:        dw  0

print_d:        db "[ %d ]",10,0
print_i:        db "i : [ %d ] /",10,0
; inTriangle:     db "Point dans le triangle !",10,0
; notInTriangle:  db "Point pas dans le triangle #sad",10,0
; pointx: db "x = %d",10,0
; pointy: db "y = %d",10,0

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

rdrand eax
mov ebx,MaxColor
xor edx,edx
div ebx
mov dword[color],edx

mov bl, NB_TRIANGLE
mov byte[i],bl

jmp genTriangle

boucle: ; boucle de gestion des évènements
    mov rdi,qword[display_name]
    mov rsi,event
    call XNextEvent

    ; mov rdi,print_i
    ; mov rsi,[i]
    ; mov rax,0
    ; call printf
    cmp byte[i],0
    je skip
    
    cmp byte[genok],0
    je genTriangle
    mov byte[genok],0

    cmp dword[event],ConfigureNotify	; à l'apparition de la fenêtre
    je dessin 						    ; on saute au label 'dessin'
    
    skip:
    cmp dword[event],KeyPress			; Si on appuie sur une touche
    je closeDisplay						; on saute au label 'closeDisplay' qui ferme la fenêtre
    jmp boucle


genTriangle:
    ; coordonnées des points du triangle
    mov dx,0
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

    ; mov dx,14
    ; mov word[x1],dx
    ; mov dx,20
    ; mov word[y1],dx
    ; mov dx,10
    ; mov word[x2],dx
    ; mov dx,60
    ; mov word[y2],dx
    ; mov dx,25
    ; mov word[x3],dx
    ; mov dx,69
    ; mov word[y3],dx

    mov rdi,print_d
    movzx rsi,word[x1]
    mov rax,0
    call printf

    mov rdi,print_d
    movzx rsi,word[y1]
    mov rax,0
    call printf
    
    mov rdi,print_d
    movzx rsi,word[x2]
    mov rax,0
    call printf
    
    mov rdi,print_d
    movzx rsi,word[y2]
    mov rax,0
    call printf
    
    mov rdi,print_d
    movzx rsi,word[x3]
    mov rax,0
    call printf
    
    mov rdi,print_d
    movzx rsi,word[y3]
    mov rax,0
    call printf

    mov byte[genok],1
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
    mov cx,word[x1]	; coordonnée source en x
    mov r8w,word[y1]	; coordonnée source en y
    mov r9w,word[x2]	; coordonnée destination en x
    push qword[y2]		; coordonnée destination en y
    call XDrawLine

    ; dessin de la ligne 2
    mov rdi,qword[display_name]
    mov rsi,qword[window]
    mov rdx,qword[gc]
    mov cx,word[x1]	; coordonnée source en x
    mov r8w,word[y1]	; coordonnée source en y
    mov r9w,word[x3]	; coordonnée destination en x
    push qword[y3]		; coordonnée destination en y
    call XDrawLine

    ; dessin de la ligne 3
    mov rdi,qword[display_name]
    mov rsi,qword[window]
    mov rdx,qword[gc]
    mov cx,word[x3]	; coordonnée source en x
    mov r8w,word[y3]	; coordonnée source en y
    mov r9w,word[x2]	; coordonnée destination en x
    push qword[y2]		; coordonnée destination en y
    call XDrawLine

    ; ; appel de la fonction calculDeterminant avec les arguments x1, y1, x2, y2, x3, y3
    ; mov rdi,[x1]    ; x1
    ; mov rsi,[y1]    ; y1
    ; mov rdx,[x2]    ; x2
    ; mov rcx,[y2]    ; y2
    ; mov r8,[x3]     ; x3
    ; mov r9,[y3]     ; y3
    ; call calculDeterminant

    mov rbx,[x1]        ; rbx = x1
    sub rbx,[x2]        ; rbx = x1 - x2
    mov rcx,[y3]        ; rdi = y3
    sub rcx,[y2]        ; rdi = y3 - y2
    imul rbx,rcx        ; rbx = (x1 - x2) * (y3 - y2)

    mov rcx,[x3]        ; rdi = x3
    sub rcx,[x2]        ; rdi = x3 - x2
    mov rax,[y1]        ; rax = y1
    sub rax,[y2]        ; rax = y1 - y2
    imul rcx,rax        ; rdi = (x3 - x2) * (y1 - y2)

    sub rbx,rcx         ; rbx = (x1 - x2) * (y3 - y2) - (x3 - x2) * (y1 - y2)

    mov [determinant],rbx
    ; mov rdi,print_d
    ; mov rsi,[determinant]
    ; mov rax,0
    ; call printf

    cmp word[determinant],0
    mov dword[isDirect],0
    jl initIsDirect
    jg skipIsDirect
    initIsDirect:
        mov byte[isDirect],1
    skipIsDirect:

    dessin_x:
        dessin_y:

        ; mov rdi,pointx
        ; movzx rsi,word[]
        ; mov rax,0
        ; call printf

        ; mov rdi,pointy
        ; movzx rsi,word[coord_y]
        ; mov rax,0
        ; call printf

        ;###################################
        ;#  Code de dessin pour point ici  #
        ;###################################

        ; result 1 = abp
        ; rbx = (x2 - x1) * (coord_y - y1) - (coord_x - x1) * (y2 - y1)
        mov rbx,[x2]        ; rbx = x2
        sub rbx,[x1]        ; rbx = x2 - x1
        mov rcx,[coord_y]   ; rdi = coord_y
        sub rcx,[y1]        ; rdi = coord_y - y1
        imul rbx,rcx        ; rbx = (x2 - x1) * (coord_y - y1)

        mov rcx,[coord_x]   ; rdi = coord_x
        sub rcx,[x1]        ; rdi = coord_x - x1
        mov rax,[y2]        ; rax = y2
        sub rax,[y1]        ; rax = y2 - y1
        imul rcx,rax        ; rdi = (coord_x - x1) * (y2 - y1)

        sub rbx,rcx         ; rbx = (x2 - x1) * (coord_y - y1) - (coord_x - x1) * (y2 - y1)
        mov [result1],rbx

        ; result 2 = bcp
        ; rbx = (x3 - x2) * (coord_y - y2) - (coord_x - x2) * (y3 - y2)
        mov rbx,[x3]        ; rbx = x3
        sub rbx,[x2]        ; rbx = x3 - x2
        mov rcx,[coord_y]   ; rdi = coord_y
        sub rcx,[y2]        ; rdi = coord_y - y2
        imul rbx,rcx        ; rbx = (x3 - x2) * (coord_y - y2)

        mov rcx,[coord_x]   ; rdi = coord_x
        sub rcx,[x2]        ; rdi = coord_x - x2
        mov rax,[y3]        ; rax = y3
        sub rax,[y2]        ; rax = y3 - y2
        imul rcx,rax        ; rdi = (coord_x - x2) * (y3 - y2)

        sub rbx,rcx         ; rbx = (x3 - x2) * (coord_y - y2) - (coord_x - x2) * (y3 - y2)
        mov [result2],rbx

        ; result 3 cap
        ; rbx = (x1 - x3) * (coord_y - y3) - (coord_x - x3) * (y1 - y3)
        mov rbx,[x1]        ; rbx = x1
        sub rbx,[x3]        ; rbx = x1 - x3
        mov rcx,[coord_y]   ; rdi = coord_y
        sub rcx,[y3]        ; rdi = coord_y - y3
        imul rbx,rcx        ; rbx = (x1 - x3) * (coord_y - y3)

        mov rcx,[coord_x]   ; rdi = coord_x
        sub rcx,[x3]        ; rdi = coord_x - x3
        mov rax,[y1]        ; rax = y1
        sub rax,[y3]        ; rax = y1 - x3
        imul rcx,rax        ; rdi = (coord_x - x3) * (y1 - x3)

        sub rbx,rcx         ; rbx = (x1 - x3) * (coord_y - y3) - (coord_x - x3) * (y1 - x3)
        mov [result3],rbx
        
        ; mov rdi,print_d
        ; mov rsi,[isDirect]
        ; mov rax,0
        ; call printf
        
        cmp byte[isDirect],1
        je direct
        jmp indirect

        indirect:
            cmp word[result1],0
            jg point_pasdessin

            cmp word[result2],0
            jg point_pasdessin

            cmp word[result3],0
            jg point_pasdessin
            
            jmp point_dessin

        direct:
            cmp word[result1],0
            jl point_pasdessin

            cmp word[result2],0
            jl point_pasdessin

            cmp word[result3],0
            jl point_pasdessin

            jmp point_dessin

        point_dessin:
            ; mov rdi,inTriangle
            ; mov rax,0
            ; call printf
            
            ;couleur du point 1
            mov rdi,qword[display_name]
            mov rsi,qword[gc]
            mov edx,dword[color]	; Couleur du crayon ; rouge
            call XSetForeground

            ; Dessin d'un point rouge : coordonnées (100,200)
            mov rdi,qword[display_name]
            mov rsi,qword[window]
            mov rdx,qword[gc]
            mov cx,word[coord_x]	; coordonnée source en x
            mov r8w,word[coord_y]	; coordonnée source en y
            call XDrawPoint

            jmp fin

        point_pasdessin:
            ; mov rdi,notInTriangle
            ; mov rax,0
            ; call printf
            jmp fin

        fin:
        inc word[coord_y]       ; y++
        cmp word[coord_y],400
        jle dessin_y
        mov word[coord_y],0     ; reset de y
        inc word[coord_x]       ; x++
        cmp word[coord_x],400
        jle dessin_x


    ; mov rdi,print_d
    ; mov rsi,[i]
    ; mov rax,0
    ; call printf
    
    dec byte[i]
    ; cmp byte[i],0
    ; jne boucle

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
    mov bx,100
    xor dx,dx ; initialiser DX à 0
    div bx
    ; le résultat se trouve dans dx

    ret

; global calculDeterminant
; calculDeterminant:
;     push rbp
;     mov rbp,rsp
;     push rbx

;     ; prendre des arguments
;     mov rax,0
;     add rax,rdi         ; x1 (ax)
;     add rax,rsi         ; y1 (ay)
;     add rax,rdx         ; x2 (bx)
;     add rax,rcx         ; y2 (by)
;     add rax,r8          ; x3 (cx)
;     add rax,r9          ; y3 (cy)

;     ; calcul du déterminant de trois points A(x1,y1), B(x2,y2) et C(x3,y3)
;     ; bax = ax - bx;
;     ; bay = ay - by;
;     ; bcx = cx - bx;
;     ; bcy = cy - by;
;     ; determinant = (bax * bcy) - (bcx * bay);
;     ; determinant = (ax - bx) * (cy - by) - (cx - bx) * (ay - by)
;     ; determinant = (x1 - x2) * (y3 - y2) - (x3 - x2) * (y1 - y2)

;     mov rbx, rdi        ; rbx = x1
;     sub rbx, rdx        ; rbx = x1 - x2
;     mov rdi, r9         ; rdi = y3
;     sub rdi, rcx        ; rdi = y3 - y2
;     imul rbx, rdi       ; rbx = (x1 - x2) * (y3 - y2)

;     mov rdi, r8         ; rdi = x3
;     sub rdi, rdx        ; rdi = x3 - x2
;     mov rax, rsi        ; rax = y1
;     sub rax, rcx        ; rax = y1 - y2
;     imul rdi, rax       ; rdi = (x3 - x2) * (y1 - y2)

;     sub rbx, rdi        ; rbx = (x1 - x2) * (y3 - y2) - (x3 - x2) * (y1 - y2)

;     ; mov rax, rbx

;     ; mov rdi,print_d
;     ; mov rsi,rax
;     ; mov rax,0
;     ; call printf

;     pop rbx
;     mov rsp,rbp
;     pop rbp
;     ret