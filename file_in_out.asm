%ifndef NOWZARI_FILE_IN_OUT
%define NOWZARI_FILE_IN_OUT
%include "./in_out.asm"
;----------------------------------------------------
section     .fileIOMessages
    error_create        db      "error in creating file             ", NL, 0
    error_close         db      "error in closing file              ", NL, 0
    error_write         db      "error in writing file              ", NL, 0
    error_open          db      "error in opening file              ", NL, 0
    error_open_dir      db      "error in opening dir               ", NL, 0
    error_append        db      "error in appending file            ", NL, 0
    error_delete        db      "error in deleting file             ", NL, 0
    error_read          db      "error in reading file              ", NL, 0
    error_print         db      "error in printing file             ", NL, 0
    error_seek          db      "error in seeking file              ", NL, 0
    error_create_dir    db      "error in creating directory        ", NL, 0
    suces_create        db      "file created and opened for R/W    ", NL, 0
    suces_create_dir    db      "dir created and opened for R/W     ", NL, 0
    suces_close         db      "desc file closed                   ", NL, 0
    suces_write         db      "written to file                    ", NL, 0
    suces_open          db      "file opened for R/W                ", NL, 0
    suces_open_dir      db      "dir opened for R/W                 ", NL, 0
    suces_append        db      "file opened for appending          ", NL, 0
    suces_delete        db      "file deleted                       ", NL, 0
    suces_read          db      "The file was read:                 ", NL, 0
    suces_seek          db      "seeking file                       ", NL, 0
    NSFMsg              db      "No such file                       ", NL, 0
    PDMsg               db      "Permission denied                  ", NL, 0
    BFDMsg              db      "Bad file address                   ", NL, 0
    FSMsg               db      "File exists                        ", NL, 0
    IADMsg              db      "Is a directory                     ", NL, 0

section .text


;----------------------------------------------------
; rdi : file name; rsi : file permission
createFile:
    mov     rax, sys_create
    mov     rsi, sys_IRUSR | sys_IWUSR 
    syscall
    cmp     rax, -1   ; file descriptor in rax
    jle     createerror
    mov     rsi, suces_create           
    call    printString
    ret
createerror:
    mov     rsi, error_create
    call    printString
    ret

;----------------------------------------------------
; rdi : file name; rsi : file access mode 
; rdx: file permission, do not need
openFile:
    mov     rax, sys_open
    mov     rsi, O_RDWR     
    syscall
    cmp     rax, -1   ; file descriptor in rax
    jle     openerror
    mov     rsi, suces_open
    call    printString
    ret
openerror:
    cmp     rax, -2
    jne     notNSF
    mov     rsi, NSFMsg
    jmp     notAllM
notNSF:
    cmp     rax, -13
    jne     notPD
    mov     rsi, PDMsg
    jmp     notAllM
notPD:
    cmp     rax, -14
    jne     notBFD
    mov     rsi, BFDMsg
    jmp     notAllM
notBFD:
    cmp     rax, -17
    jne     notFS
    mov     rsi, FSMsg
    jmp     notAllM
notFS:
    cmp     rax, -21
    jne     notIAD
    mov     rsi, IADMsg
    jmp     notAllM
notIAD:
    mov     rsi, error_open
notAllM: 
    call    printString
    ret

openFileT:
    mov rax, sys_open
    mov rdx, sys_IRUSR | sys_IWUSR
    mov rsi, O_RDWR | O_CREAT | O_TRUNC
    cmp rbx, 0
    je trunc
    xor rsi, O_TRUNC
    or rsi, O_EXCL
trunc:
    syscall
    cmp     rax, -1   ; file descriptor in rax
    jle     openerror
    mov     rsi, suces_open
    call    printString
    ret
;----------------------------------------------------
; rdi point to file name
appendFile:
    mov     rax, sys_open
    mov     rsi, O_RDWR | O_APPEND
    syscall
    cmp     rax, -1     ; file descriptor in rax
    jle     appenderror
    mov     rsi, suces_append
    call    printString
    ret
appenderror:
    mov     rsi, error_append
    call    printString
    ret
;----------------------------------------------------
; rdi : file descriptor ; rsi : buffer ; rdx : length
writeFile:
    mov     rax, sys_write
    syscall
    cmp     rax, -1         ; number of written byte
    jle     writeerror
    mov     rsi, suces_write
    call    printString
    ret
writeerror:
    mov     rsi, error_write
    call    printString
    ret
;----------------------------------------------------
; rdi : file descriptor ; rsi : buffer ; rdx : length
readFile:
    mov     rax, sys_read
    syscall
    cmp     rax, -1           ; number of read byte
    jle     readerror
    ; mov     byte [rsi+rax], 0 ; add a  zero ??????????????
    mov     rsi, suces_read
    call    printString
    ret
readerror:
    mov     rsi, error_read
    call    printString
    ret
;----------------------------------------------------
; rdi : file descriptor
closeFile:
    mov     rax, sys_close
    syscall
    cmp     rax, -1      ; 0 successful
    jle     closeerror
    mov     rsi, suces_close
    call    printString
    ret
closeerror:
    mov     rsi, error_close
    call    printString
    ret

;----------------------------------------------------
; rdi : file name
deleteFile:
    mov     rax, sys_unlink
    syscall
    cmp     rax, -1      ; 0 successful
    jle     deleterror
    mov     rsi, suces_delete
    call    printString
    ret
deleterror:
    mov     rsi, error_delete
    call    printString
    ret
;----------------------------------------------------
; rdi : file descriptor ; rsi: offset ; rdx : whence
seekFile:
    mov     rax, sys_lseek
    syscall
    cmp     rax, -1
    jle     seekerror
    mov     rsi, suces_seek
    call    printString
    ret
seekerror:
    mov     rsi, error_seek
    call    printString
    ret

;----------------------------------------------------

%endif
