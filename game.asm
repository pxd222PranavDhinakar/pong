
; game.asm
[bits 32]

global start

section .text
start:
    mov esp, 0x90000 ; update the stack
    call hide_cursor ; Hide the cursor at the start
    call init_game
    call game_loop


hide_cursor:
    ; Disable the cursor
    mov dx, 0x3D4
    mov al, 0x0A
    out dx, al
    
    inc dx
    mov al, 0x20
    out dx, al
    ret

init_game:
    call reset_ball
    mov word [left_paddle_y], 10
    mov word [right_paddle_y], 10
    mov byte [game_started], 0  ; Game not started
    mov dword [step_counter], 0
    mov dword [step_rate], 10   ; Adjust this to control game speed
    mov dword [left_score], 0   ; Initialize left player's score
    mov dword [right_score], 0  ; Initialize right player's score
    ret

reset_ball:
    mov word [ball_x], 40
    mov word [ball_y], 12
    mov word [ball_dx], 1
    mov word [ball_dy], 1
    ret

game_loop:
    call handle_input
    call render_frame
    cmp byte [game_started], 0
    je .continue    ; If game not started, skip update
    inc dword [step_counter]
    mov eax, [step_counter]
    cmp eax, [step_rate]
    jl .continue
    mov dword [step_counter], 0
    call update_game_state
.continue:
    call delay
    jmp game_loop

handle_input:
    in al, 0x64
    test al, 1
    jz .done
    in al, 0x60
    cmp al, 0x39    ; Space bar
    je .start_game
    cmp al, 0x11    ; 'w' key
    je .move_left_up
    cmp al, 0x1F    ; 's' key
    je .move_left_down
    cmp al, 0x48    ; up arrow
    je .move_right_up
    cmp al, 0x50    ; down arrow
    je .move_right_down
    jmp .done
.start_game:
    mov byte [game_started], 1
    jmp .done
.move_left_up:
    cmp word [left_paddle_y], 1
    jle .done
    dec word [left_paddle_y]
    jmp .done
.move_left_down:
    cmp word [left_paddle_y], 20
    jge .done
    inc word [left_paddle_y]
    jmp .done
.move_right_up:
    cmp word [right_paddle_y], 1
    jle .done
    dec word [right_paddle_y]
    jmp .done
.move_right_down:
    cmp word [right_paddle_y], 20
    jge .done
    inc word [right_paddle_y]
.done:
    ret

update_game_state:
    ; Update ball position
    mov ax, [ball_x]
    add ax, [ball_dx]
    mov [ball_x], ax
    mov ax, [ball_y]
    add ax, [ball_dy]
    mov [ball_y], ax

    ; Boundary checks
    cmp word [ball_y], 0
    jle .reverse_y
    cmp word [ball_y], 24
    jge .reverse_y
    jmp .check_paddles

.reverse_y:
    neg word [ball_dy]

.check_paddles:
    ; Left paddle
    cmp word [ball_x], 1
    jne .check_right_paddle
    mov ax, [ball_y]
    sub ax, [left_paddle_y]
    cmp ax, 0
    jl .right_scores
    cmp ax, 5
    jge .right_scores
    neg word [ball_dx]
    jmp .done

.check_right_paddle:
    ; Right paddle
    cmp word [ball_x], 78
    jne .done
    mov ax, [ball_y]
    sub ax, [right_paddle_y]
    cmp ax, 0
    jl .left_scores
    cmp ax, 5
    jge .left_scores
    neg word [ball_dx]
    jmp .done

.right_scores:
    inc dword [right_score]
    call reset_ball
    jmp .done

.left_scores:
    inc dword [left_score]
    call reset_ball

.done:
    ret

render_frame:
    ; Clear screen
    mov edi, 0xb8000
    mov ecx, 80*25
    mov ax, 0x0720 ; Space character with black background
    rep stosw

    ; Draw scores
    mov edi, 0xb8000
    mov esi, score_text
    call draw_string

    ; Draw left score
    add edi, 50
    mov eax, [left_score]
    call draw_number

    ; Draw right score
    add edi, 56
    mov eax, [right_score]
    call draw_number

    ; Draw game elements regardless of game_started state
    call draw_ball
    call draw_paddles

    ret

draw_ball:
    mov edi, 0xb8000
    movzx eax, word [ball_y]
    imul eax, 160
    movzx ebx, word [ball_x]
    add eax, ebx
    add eax, ebx ; Multiply by 2 because each cell is 2 bytes
    add edi, eax
    mov word [edi], 0x0F4F ; 'O' character with white foreground
    ret

draw_paddles:
    ; Draw left paddle
    mov edi, 0xb8000
    movzx eax, word [left_paddle_y]
    imul eax, 160
    add edi, eax
    mov ecx, 5
.draw_left_paddle:
    mov word [edi], 0x0F7C ; '|' character with white foreground
    add edi, 160
    loop .draw_left_paddle

    ; Draw right paddle
    mov edi, 0xb8000
    movzx eax, word [right_paddle_y]
    imul eax, 160
    add edi, eax
    add edi, 158 ; Move to right side
    mov ecx, 5
.draw_right_paddle:
    mov word [edi], 0x0F7C ; '|' character with white foreground
    add edi, 160
    loop .draw_right_paddle
    ret

draw_string:
    .loop:
        lodsb
        test al, al
        jz .done
        mov ah, 0x0F ; White on black
        stosw
        jmp .loop
    .done:
        ret

draw_number:
    push edi        ; Save the original position
    add edi, 6      ; Move to the rightmost position (assuming max 3 digits)
    mov ecx, 0      ; Digit counter
    mov ebx, 10
.loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    dec edi
    mov dh, 0x0F    ; White on black
    mov [edi], dx
    inc ecx
    test eax, eax
    jnz .loop
    
    pop eax         ; Get the original position
    sub edi, eax    ; Calculate how many characters we moved back
    shr edi, 1      ; Divide by 2 (because each character is 2 bytes)
    add eax, edi    ; Add this to the original position
    mov edi, eax    ; Set edi to the start of the number
    add edi, ecx
    add edi, ecx    ; Move edi past the number
    ret

delay:
    mov ecx, 5000000  ; Adjusted for faster gameplay
.delay_loop:
    loop .delay_loop
    ret

section .data
ball_x: dw 40
ball_y: dw 12
ball_dx: dw 1  ; Horizontal ball speed (can be negative)
ball_dy: dw 1  ; Vertical ball speed (can be negative)
left_paddle_y: dw 10
right_paddle_y: dw 10
game_started: db 0  ; Flag to indicate if the game has started
step_counter: dd 0  ; Counter for controlling game update rate
step_rate: dd 10    ; Number of frames between game updates
left_score: dd 0    ; Left player's score
right_score: dd 0   ; Right player's score
score_text: db 'Left Player:     Right Player:    ', 0
