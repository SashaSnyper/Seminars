
format PE Console 4.0
include 'win32a.inc'
 
entry start
 
section '.data' data readable writeable
        aszInstant      db      'Instant array:', 0Dh, 0Ah, 0
        aszResult       db      'Result array:', 0Dh, 0Ah, 0
        aszErrorMalloc  db      'Error malloc', 0Dh, 0Ah, 0
        aszGetSize      db      'Array size: ', 0
        aszGetElement   db      'A[%d]=', 0
        aszFormatInp    db      '%d', 0
        aszFormat       db      '%5d', 0
        aszCrLf         db      0Dh, 0Ah, 0
 
section '.bss' readable writeable
        lpArray         dd      ?
        nSize           dd      ?
 
section '.code' code readable executable
start:

        stdcall GetArray,       lpArray, nSize
        test    eax,    eax
        jnz     @f

                cinvoke printf,         aszErrorMalloc
                jmp     .exit
        @@:

        cinvoke printf,         aszInstant
        stdcall ShowArray,      [lpArray], [nSize]
        ;??????????
        stdcall HeapSort,       [lpArray], [nSize]

        cinvoke printf,         aszResult
        stdcall ShowArray,      [lpArray], [nSize]

        invoke  free,           [lpArray]
.exit:
        invoke  _getch
        invoke  ExitProcess, 0
 
 
proc    GetArray,       lpPtrArray:DWORD, lpSize:DWORD

        cinvoke printf,         aszGetSize
        mov     esi,    [lpSize]
        cinvoke scanf,          aszFormatInp, esi

        mov     esi,    [lpSize]
        mov     eax,    [esi]
        shl     eax,    2
        invoke  malloc, eax

        mov     esi,    [lpPtrArray]
        mov     [esi],  eax
        test    eax,    eax
        jz      .exit

        mov     esi,    [lpSize]
        mov     ecx,    [esi]
        xor     esi,    esi
        mov     edi,    [lpPtrArray]
        mov     edi,    [edi]
        .for:
                push    ecx
                push    edi
                push    esi
                lea     ebx,    [edi+4*esi]
                push    ebx
                cinvoke printf,         aszGetElement, esi
                pop     ebx
                cinvoke scanf,          aszFormatInp, ebx
                pop     esi
                pop     edi
                pop     ecx
                inc     esi
        loop    .for
        mov     eax,    [lpPtrArray]
        mov     eax,    [eax]
.exit:
        ret
endp
 
proc    ShowArray,      lpArray:DWORD, nSize:DWORD
        mov     ecx,    [nSize]
        mov     esi,    [lpArray]
        .for:
                lodsd
                push    ecx
                push    esi
                cinvoke printf, aszFormat, eax
                pop     esi
                pop     ecx
        loop    .for
        invoke  printf, aszCrLf
        ret
endp
 

proc    siftDown,       lpArray:DWORD, K:DWORD, N:DWORD         ;procedure siftDown(var A: TArray; K, N: integer);
                                                                ;  var
                                                                ;    temp: integer;
                                                                ;    childPos: integer;
        pushad                                                  ;  begin
        mov     ebx,    [N]
        mov     esi,    [lpArray]
        mov     ecx,    [K]
                                                                ;    {??? ????? ??? K=0 ? N=0 ?? ???????? ?????? ????????????}
        test    ebx,    ebx                                     ;    if 0 = N then
        jz      .exit                                           ;      exit;
        mov     edi,    [esi+ecx*4]                             ;    temp := A[K];
        .while:                                                 ;    while K * 2 + 1 <= N do
                                                                ;    begin
                mov     edx,    ecx                             ;      childPos := 2 * K + 1;  // ?????? ?????? ???????
                add     edx,    edx
                inc     edx
                cmp     edx,    ebx
                ja      .break
                                                                ;      // ???????? ? childPos ?????? ???????? ???????
                mov     eax,    edx                             ;      if (childPos + 1 <= N) and (A[childPos] < A[childPos + 1]) then
                inc     eax
                cmp     eax,    ebx
                ja      @f
                mov     eax,    [esi+eax*4]
                cmp     eax,    [esi+edx*4]
                jle     @f
                inc     edx                                     ;        Inc(childPos);
        @@:                                                     ;
                                                                ;      // ???? A[K] ?????? ????????????? ??????? - ??????????
                cmp     edi,    [esi+edx*4]                     ;      if (temp >= A[childPos]) then
                jge     .break                                  ;        break;
                                                                ;
                                                                ;      // ????? - ?????? ??? ? ?????????? ????????
                mov     eax,    [esi+edx*4]                     ;      A[K] := A[childPos];
                mov     [esi+ecx*4],    eax
                                                                ;
                mov     ecx,    edx                             ;      K := childPos;
        jmp     .while                                          ;    end;
.break:
        mov     [esi+ecx*4],    edi                             ;    A[K] := temp;
.exit:                                                          ;  end;
        popad
        ret
endp

proc    HeapSort,       \
                        lpArray:DWORD, uiAmount:DWORD



        pushad
        mov     esi,    [lpArray]
        mov     ebx,    [uiAmount]

        mov     ecx,    ebx
        shr     ecx,    1
        dec     ebx
        jmp     .next
        .for:
                stdcall siftDown,       esi, ecx, ebx
        .next:
                dec     ecx
        jns     .for



        mov     ecx,    ebx
        jmp     .test_while
        .while:

                push    dword [esi]
                push    dword [esi+4*ecx]
                pop     dword [esi]
                pop     dword [esi+4*ecx]

                dec     ecx
                stdcall siftDown,       esi, 0, ecx
        .test_while:
                test    ecx,    ecx
        jnz     .while
        popad
        ret
endp
 
 
section '.idata' import data readable writeable
    library kernel32,'KERNEL32.DLL',\
        user32,'USER32.DLL',\
        msvcrt, 'msvcrt.dll'
 
    include 'api\kernel32.inc'
    include 'api\user32.inc'
 
    import  msvcrt,\
        printf, 'printf',\
        scanf,  'scanf',\
        _getch, '_getch',\
        malloc, 'malloc',\
        free,   'free'