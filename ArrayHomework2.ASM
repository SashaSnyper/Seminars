format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strVecSize   db 'Size of vector A: ', 0
        strNumberX   db 'Input the number X: ', 0
        strIncorSize db 'Incorrect size of vector = %d', 10, 0
        strVecElemI  db '[%d] = ', 0
        strScanInt   db '%d', 0
        strVecOutB   db 'B:', 10, 0
        strVecElemOut  db '[%d] = %d', 10, 0
        strVecOutA   db 'A:', 10, 0

        curNumber    dd 0
        A_size       dd 0
        B_size       dd 0
        size         dd 0
        sum          dd 0
        i            dd ?
        tmp          dd ?
        tmpStack     dd ?
        vecA         rd 100
        vecB         rd 100

;--------------------------------------------------------------------------
section '.code' code readable executable
start:

; 1) vector input
        call VectorInput

; 2) get vector B
        call VectorWithoutX

; 3) B vector out
        push strVecOutB
        call [printf]

        call VectorOut
finish:
        call [getch]

        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------
VectorInput:
        push strVecSize
        call [printf]
        add esp, 4

        push A_size
        push strScanInt
        call [scanf]
        add esp, 8

        push strVecOutA
        call [printf]
        add esp, 4


        mov eax, [A_size]
        cmp eax, 0
        jg  getVector
; fail size
        push A_size
        push strIncorSize
        call [printf]
        push 0
        call [ExitProcess]
; else continue...
getVector:
        xor ecx, ecx            ; ecx = 0
        mov ebx, vecA           ; ebx = &vec
getVecLoop:
        mov [tmp], ebx
        cmp ecx, [A_size]
        jge endInputVector       ; to end of loop

        ; input element
        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getVecLoop
endInputVector:
        ret
;--------------------------------------------------------------------------
VectorWithoutX:
        xor ecx, ecx            ; ecx = 0
        mov ebx, vecA           ; ebx = &vec
        mov edx, vecB
VecLoop:
        ;mov [tmp], ebx
        cmp ecx, [A_size]
        je endSumVector      ; to end of loop
        mov eax, [ebx]
        test eax, 1
        jz ToNextElem

        mov eax, [ebx]
        mov [edx], eax
        add edx, 4
        inc [B_size]

ToNextElem:
        inc ecx
        add ebx, 4
        jmp VecLoop
endSumVector:
        ret
;--------------------------------------------------------------------------
VectorOut:
        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov ebx, vecB           ; ebx = &vec
putVecLoop:
        mov [tmp], ebx
        cmp ecx, [B_size]
        je endOutputVector      ; to end of loop
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecLoop
endOutputVector:
        mov esp, [tmpStack]
        ret
;-------------------------------third act - including HeapApi--------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'