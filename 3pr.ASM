format PE console
entry start

include 'win32a.inc'

proc Addition stdcall uses ecx edx, a:DWORD
     mov ecx, [a]
     mov edx, [sum]
     add ecx, edx
     mov [sum],ecx


     ret
endp

section '.data' data readable writeable

        RequestInput   db      "Write number: ", 0
        Result         db      "Sum: %d", 0
        input          dd      "%s", 0
        sum            dd      "%d", 0

        number        dd      ?

section '.text' code readable executable

        start:
                mov [sum],0 ;;set sum to 0 at start
        inputCall:
                      push RequestInput
                      call [printf]

                      push number     ;; push variable
                      push input      ;; get input
                      call [scanf]     ;; do scanf
                      ;; atoi
                      cinvoke atoi, number
                      mov [number],eax
        checkIfZero:
                      mov ecx, [number]    ;; get inserted number
                      cmp ecx,0             ;; check if 0
                      je  results  ;go to results if 0

                      push [number]  ;; not 0, we can sum, push number into stack
                      call Addition   ;; get addition
                      jmp inputCall   ;; loop


        results:

                push [sum]
                push Result
                call [printf]

                call [getchar]

                push 0

                call [ExitProcess]

section '.idata' import data readable

        library msvcrt, 'MSVCRT.DLL', \
                kernel, 'KERNEL32.DLL'

        import msvcrt, \
                       printf, 'printf', \
                       scanf, 'scanf', \
                       getchar, 'getchar',\
                       atoi, 'atoi'

        import kernel, \
                       ExitProcess, 'ExitProcess'