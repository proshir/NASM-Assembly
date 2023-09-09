%include "file_in_out.asm"

Menu:
    mov rsi, MenuMsg
    call getNumAfterS
    mov [Order], al

checkOrder:
    cmp byte [Order], 0
    je  endMenu
    cmp byte [Order], 1
    je openAddressFile 
    cmp byte [Order], 2   
    je sayFileDescription
    cmp byte [Order], 3
    je saySearchPhrase
    cmp byte [Order], 4
    je sayReplacePhrase
    cmp byte [Order], 5
    je sayAppendPhrase
    cmp byte [Order], 6
    je sayDeleteMany
    cmp byte [Order], 7
    je sayCloseWOSave
    cmp byte [Order], 8
    je saySave
    cmp byte [Order], 9
    je sayCloseWSave
    cmp byte [Order], 10
    je sayCloseSaveAS
    cmp byte [Order], 11
    jmp notInputCor
endMenu:
    call closeFileds
    mov rsi, GoodbyeMsg
    call printString 
    ret

;----------------------------

openAddressFile:
    cmp r12, 0
    je do_oAFile
    mov rsi, alreadyOpenMsg
    call printString
    jmp Menu
    do_oAFile:
        call getFileAddr
        mov rdi, file_addr
        call openFile
        cmp rax, -2
        jne fileExistGet
        mov rsi, NotExistMsg
        call printString
        call getc
        mov bl, al
        call getc
        cmp bl, 'y'
        jne Menu
        mov rbx, 1
        call openFileT
fileExistGet:
        cmp rax, 0
        jl  Menu
        inc r12
        mov rdi, rax
        mov rsi, file_cont
        mov rdx, 2000
        call readFile
        mov rsi, file_cont
        add rax, rsi
        mov [endFileds], rax
        call printString
        call newLine
        call closeFile
        jmp Menu

;---------------------------

sayFirstOpenFile:
    mov rsi, firstOpenMsg
    call printString
    jmp Menu

;--------------------------
sayFileDescription:
    cmp r12, 0
    je sayFirstOpenFile
    mov rdi, file_cont
    xor r10, r10
    xor rcx, rcx
    xor rdx, rdx
    xor r8, r8
    xor r9, r9
caclLetter:
    mov bl, [rdi]
    cmp bl, 0
    je endCalcDesck
    cmp rcx, 0
    jne moveon
    inc rcx
moveon:
    cmp bl, NL
    jne notNL
    inc rcx
    jmp checkWord
notNL:
    cmp bl, ' '
    jne notAll
    inc r9
checkWord:
    cmp r8, 0
    je nextLetter
    xor r8, r8
    inc rdx
    jmp nextLetter
notAll:
    inc r10
    inc r8
nextLetter:
    inc rdi
    jmp caclLetter
endCalcDesck:
    cmp r8, 0
    je endOfCalDesck
    xor r8, r8
    inc rdx
endOfCalDesck:
    mov rax, r10
    mov rsi, numberLetterMsg
    call writeNumAfterS

    mov rax, rdx
    mov rsi, numberWordMsg
    call writeNumAfterS

    mov rax, rcx
    mov rsi, numberLineMsg
    call writeNumAfterS

    mov rax, r9
    mov rsi, numberSpaceMsg
    call writeNumAfterS
    jmp Menu
;------------------------

;----------------------
saySearchPhrase:
    mov r10, 1
searchPhrase:
    cmp r12, 0
    je sayFirstOpenFile
    mov rsi, phraseMsg
    call printString
    mov rdi, phrase
    call readStr
    sub rdi, phrase
    mov rdx, rdi
    cmp rdx, 0
    je  notInputCor
    mov [sizePhrase], dx
    mov r13, [endFileds]
    mov r8, file_cont

    call findWord
    mov rsi, findHowPhraseMsg
    mov rax, r14
    call writeNumAfterS
    cmp rax, 0
    je notFound
    mov rsi, locationPhrasesMsg
    call printString
    xor rcx, rcx
printLoc:
    lea rax, [rcx+1]
    call writeNum
    mov rsi, separatorMsg
    call printString
    mov ax, word [location+rcx*2]
    call writeNum
    call newLine
    inc rcx
    cmp rcx, r14
    je  endPrintLoc
    jmp printLoc
notFound:
    mov rsi, notFoundMsg
    call printString
endPrintLoc:
    call newLine
    cmp r10, 1
    je  Menu
    ret

findWord:
   mov   rdi, phrase
   sub r13, rdx
   inc r13 ;; r13 end of position we have to check
   xor rbx, rbx
   xor r14, r14 ;; answer 
againFind:
   mov   rcx, rdx ;; length we have to check
   mov   rsi, r8 ;; r8 = current position in file
   mov   rdi, phrase
   repe  cmpsb
   jne notFoundAnymore
   mov rax, r8
   sub rax, file_cont
   mov word [location+r14*2], ax
   inc r14
notFoundAnymore:
   inc r8
   cmp r8, r13 ;; check end check
   jne againFind
   ret
;----------------------

sayReplacePhrase:
    xor r10, r10
    call searchPhrase
    cmp r14, 0
    je Menu
    mov rsi, whichChangeMsg
    call getNumAfterS
    cmp rax, 0
    jle notInputCor
    cmp rax, r14
    jg  notInputCor
    mov rbx, rax
    mov rsi, whatChangeMsg
    mov rdi, rphrase
    call getStrAfterS

    dec rbx
    mov bx, word [location+rbx*2]
    mov rsi, rbx
    add rsi, file_cont
    mov rbx, rsi
    add si, word [sizePhrase]
    mov rcx, qword [endFileds]
    sub rcx, rsi
    mov r9, rcx
    mov rdi, tcont
    rep movsb

    mov rdi, rphrase
    call GetStrlen
    mov rcx, rdx
    mov rdi, rbx
    rep movsb

    mov rdi, rbx
    call zeroUntilEnd

    mov rdi, rbx
    mov rcx, rdx
    mov rsi, rphrase
    rep movsb

    mov rsi, tcont
    mov rcx, r9
    rep movsb

    mov rdi, tcont
    call zeroUntilEnd

    call sayResult
    jmp Menu

sayResult:
    mov rsi, resultMsg
    call printString
    mov rsi, file_cont
    call printString
    call newLine
    mov rdi, rsi
    call GetStrlen
    add rdx, rsi
    mov qword [endFileds], rdx
    ret
    
notInputCor:
    mov rsi, didNotInputCor
    call printString
    jmp Menu
;----------------------

sayAppendPhrase:
    cmp r12, 0
    je sayFirstOpenFile
    mov rsi, whatAppend
    mov rdi, phrase
    mov rbx, rdi
    call getStrAfterS
    mov rcx, rdi
    sub rcx, rbx
    cmp rcx, 0
    je  notInputCor
    mov rsi, phrase
    mov rdi, qword [endFileds]
    rep movsb
    call sayResult
    jmp Menu

;----------------------

sayDeleteMany:
    cmp r12, 0
    je sayFirstOpenFile
    mov rsi, howManyDelete
    call getNumAfterS
    cmp rax, 0
    jle notInputCor
    mov rcx, rax
    mov rdi, qword [endFileds]
    sub rdi, rcx
    cmp rdi, file_cont
    jl notInputCor
    call zeroUntilEnd
    call sayResult
    jmp Menu

;----------------------

zeroUntilEnd:
    cmp byte [rdi], 0
    je endZeroUntil
    mov byte [rdi], 0
    inc rdi
    jmp zeroUntilEnd
endZeroUntil:
    ret

;----------------------

sayCloseWOSave:
    cmp r12, 0
    je sayFirstOpenFile
    call closeFileds
    jmp Menu

;----------------------
SaveFile:
    cmp r12, 0
    je notOpenCF
    call openFileT
    cmp rax, 0
    jl notOpenCF
    mov rdi, rax
    mov rsi, file_cont
    mov rdx, qword [endFileds] 
    sub rdx, rsi
    call writeFile
    call closeFile
    ret

saySave:
    cmp r12, 0
    je sayFirstOpenFile
    mov rdi, file_addr
    xor rbx, rbx
    call SaveFile
    jmp Menu

sayCloseWSave:
    cmp r12, 0
    je sayFirstOpenFile
    mov rdi, file_addr
    xor rbx, rbx
    call SaveFile
    cmp rax, -1
    jle Menu
    call closeFileds
    jmp Menu
    
sayCloseSaveAS:
    cmp r12, 0
    je sayFirstOpenFile
    call getFileAddr
    mov rdi, file_addr
    mov rbx, 1
saveFileAgain:
    call SaveFile
    cmp rax, -17
    jne notFileExist
    mov rsi, TruncMsg
    call printString
    call getc
    mov bl, al
    call getc
    cmp bl, 'y'
    jne Menu
    xor rbx, rbx
    jmp saveFileAgain
notFileExist:
    cmp rax, -1
    jle Menu
    call closeFileds
    jmp Menu

getFileAddr:
    mov rsi, pathMsg
    call printString
    mov rdi, file_addr
    call readStr
    ret
;----------------------

getStrAfterS:
    call printString
    call readStr
    ret

getNumAfterS:
    call printString
    call readNum
    ret

writeNumAfterS:
    call printString
    call writeNum
    call newLine
    ret

closeFileds:
    cmp r12, 0
    je notOpenCF
    xor r12, r12
    mov qword [endFileds], 0
    mov rdi, file_addr
    call zeroUntilEnd

    mov rdi, file_cont
    call zeroUntilEnd

    mov rdi, phrase
    call zeroUntilEnd
    mov word [sizePhrase], 0

    mov rdi, rphrase
    call zeroUntilEnd
    
    mov rdi, location
    call zeroUntilEnd

    mov byte [Order], 0

    mov rsi, resetMsg
    call printString

    notOpenCF:
        ret

section .data
    Order   db  0
    endFileds   dq  0
    MenuMsg db  "-------------", NL, "0. Exit", NL, "1. Open file", NL, "2. File description", NL, "3. Find phrase", NL, "4. Replace phrace", NL, "5. Append", NL, "6. Delete from the end", NL, "7. Close without saving", NL, "8. Save", NL, "9. Close with save", NL, "10. Close with save as", NL, "Your order: ", 0
    pathMsg    db  "Please enter the file address: ", 0
    alreadyOpenMsg db "A file has already been opened. Please close it first.", NL, 0
    firstOpenMsg   db "Please open a file first.", NL, 0
    numberLetterMsg db  "Number of letters (Without calculating space and NL): ", 0
    numberWordMsg   db  "Number of words: ", 0
    numberLineMsg   db  "Number of lines: ", 0
    numberSpaceMsg  db  "Number of spaces: ", 0
    phraseMsg   db  "Please enter the phrase: ", 0
    findHowPhraseMsg   db  "Number of words found: ", 0
    locationPhrasesMsg  db  "Their location: ", NL, 0
    notFoundMsg db  "Nothing found!", 0
    whichChangeMsg db  "Which one do you want to change (1, 2, ...)‌ (Enter a missing value to exit (0))? ", 0
    whatChangeMsg db   "What do you want to replace it with? ", 0
    didNotInputCor db "You did not enter correctly!", NL, 0
    resultMsg   db  "Result:", NL, 0
    separatorMsg    db  ". ", 0
    whatAppend  db  "What do you want to append? ", 0
    howManyDelete  db  "How many do you want to delete from the end? ", 0
    resetMsg    db  "Everything has been reset! ", NL, 0
    TruncMsg    db  "If you want to write on the desired file, press 'y', otherwise, enter 'n': ", 0
    NotExistMsg db  "If you want to create the file press 'y' otherwise 'n': ", 0
    GoodbyeMsg db  "Goodbye!", 0
    sizePhrase  dw  0

section .bss
    file_addr   resb   200
    file_cont   resb   2000
    phrase      resb   150
    rphrase     resb   150
    location    resw   2000
    tcont       resb   2000   
section .text
    global _start

_start:
    xor r12, r12
    call Menu
Exit:
    call newLine
    mov rax, sys_exit
    xor rdi, rdi
    syscall