.section .bss
.equ REQSIZE, 512
.equ READSIZE, 512

.intel_syntax noprefix
.globl _start
 
.section .text
 _start:

 #socket(AF_INET, SOCK_STREAM, IPPROTO_IP)
 mov rdi, 2
 mov rsi, 1
 mov rdx, 0
 mov rax, 0x29
 syscall

 #bind(3, [port 80, adress 0.0.0.0], 16)
 mov rdi, 3
 lea rsi, [rip+sockaddr]
 mov rdx, 16
 mov rax, 0x31
 syscall

 #listen(3, 0)
 mov rdi, 3
 mov rsi, 0
 mov rax, 0x32
 syscall

 accept:
 #accept(3, NULL, NULL)
 mov rdi, 3
 mov rsi, 0
 mov rdx, 0
 mov rax, 0x2B
 syscall

 #fork()
 mov rax, 0x39
 syscall

 #split child vs parent
 cmp rax, 0
 je Child
 jmp Parent
 Child:

 #close(3)
 mov rdi, 3
 mov rax, 0x3
 syscall

 #read(4, request, count)
 mov rdi, 4
 mov rsi, rsp
 mov rdx, REQSIZE
 mov rax, 0
 syscall

 #Check POST or GET
 mov r15, rax
 mov r8, rsp
 mov al, [r8]
 cmp al, 'P'
 je post
 jmp get

 get:
 mov r10, rsp
 loopg:
 mov al, [r10]
 cmp al, ' '
 je doneg
 add r10, 1
 jmp loopg

 doneg:
 add r10, 1
 mov r11, r10
 mov r12, 0

 loop2g:
 mov al, [r11]
 cmp al, ' '
 je done2g
 add r11, 1
 add r12, 1
 jmp loop2g

 done2g:
 mov byte ptr [r11], 0
 mov rdi, r10
 mov rsi, 0
 mov rdx, 0
 mov rax, 0x2    #SYS_open
 syscall

 #read(3, buf, count)
 mov rdi, 3
 mov rsi, rsp
 mov rdx, READSIZE
 mov rax, 0x0    #SYS_read
 syscall

 #close(3)
 mov r15, rax
 mov rdi, 3
 mov rax, 0x3    #SYS_close
 syscall

 #write(4, response, sizeof(response))
 mov rdi, 4
 lea rsi, [rip+okRequest]
 mov rdx, 19
 mov rax, 0x1    #SYS_write
 syscall

 #write(4, buf, count)
 mov rdi, 4
 mov rsi, rsp
 mov rdx, r15
 mov rax, 0x1    #SYS_write
 syscall

 #exit(60)
 mov rdi, 0
 mov rax, 60     #SYS_EXIT
 syscall

 post:
 firstSpaceLoop:
 mov al, [r8]
 cmp al, ' '
 je firstSpaceFound
 add r8, 1
 jmp firstSpaceLoop

 firstSpaceFound:
 add r8, 1
 mov r9, r8
 mov r10, 0

 secondSpaceLoop:
 mov al, [r9]
 cmp al, ' '
 je secondSpaceFound
 add r9, 1
 add r10, 1
 jmp secondSpaceLoop

 secondSpaceFound:
 mov byte ptr [r9], 0
 #open(path, writeonly)
 mov rdi, r8
 mov rsi, 01|02000|0100
 mov rdx, 0644
 mov rax, 0x2
 syscall

 mov r8, rsp
 mov r9, 0
 lookforfirst:
 mov al, [r8]
 cmp al, '\n'
 je lookforsecond
 add r8, 1
 add r9, 1
 jmp lookforfirst

 lookforsecond:
 add r8, 1
 add r9, 1
 mov al, [r8]
 cmp al, '\r'
 je lookforfinal
 add r8, 1
 add r9, 1
 jmp lookforfirst

 lookforfinal:
 add r8, 1
 add r9, 1
 mov al, [r8]
 cmp al, '\n'
 je done
 add r8, 1
 add r9, 1
 jmp lookforfirst

 done:
 add r8, 1
 add r9, 1
 #write(3, file, sizeof((requested text))
 mov rdi, 3
 mov rsi, r8
 sub r15, r9
 mov rdx, r15
 mov rax, 0x1
 syscall

 #close(3)
 mov rdi, 3
 mov rax, 0x3
 syscall

 #write(4, response, sizeof(response))
 mov rdi, 4
 lea rsi, [rip+okRequest]
 mov rdx, 19
 mov rax, 0x1
 syscall

 #exit(0)
 mov rdi, 0
 mov rax, 0x3C
 syscall

 Parent:
 #close(4)
 mov rdi, 4
 mov rax, 0x3
 syscall

 pop rax
 jmp accept

 #accept(3, NULL, NULL)
 mov rdi, 3
 mov rsi, 0
 mov rdx, 0
 mov rax, 0x2B
 syscall
 #Written by an0n9m
 Exit:
 .section .data
 sockaddr:
 .2byte 2
 .byte 0
 .byte 80
 .4byte 0
 .8byte 0
 okRequest:
 .8byte 0x302E312F50545448 # "HTTP/1.0"
 .8byte 0x0D4B4F2030303220 # " 200 OK\r
 .8byte 0x00000000000A0D0A # "\n\r\n"
