;������ ��������� ���������� ���193
;����������� ��������� ����������� ��������� ������������� ����� ������, �� ������������ ����� ����������� ��������� �����

format PE GUI                          ; 32-��������� ���������� ��������� WINDOWS EXE
entry start                                  ; ����� �����

include 'win32a.inc'

section '.idata' import data readable        ; ������ ������������� �������

library kernel,'kernel32.dll',\
        user,'user32.dll',\
        msvcrt,'msvcrt.dll'

import  kernel,\
        ExitProcess,'ExitProcess'

import  user,\
        MessageBox,'MessageBoxA',\
        wsprintf,'wsprintfA'

section '.data' data readable writeable      ; ������ ������
resmsg  db '����� ������',0
fmt1    db '%u',13,10,0
itog    db 13,10,'������������ �������� �����: '
itoglen=$-itog
result  db 256 dup(0)
buf     db 16 dup(0)
section '.code' code readable executable     ; ������ ����
start:                                       ; ����� ����� � ���������
        stdcall Vudal,result                    ;��������� ����� ������
        stdcall [MessageBox],0,result,resmsg,0  ;������� ��������� � �����������
ex:     stdcall [ExitProcess], 0;�����
;������� ���������� ����� ������ ���� ��� �� �������� ����� ������������ ��������� �����
;���������� ������ stdcall
;void Vudal(char *res);
Vudal:
        push ebp        ;������ �������
        mov ebp,esp
        push ebx        ;��������� �������� �� ���������� stdcall
        push esi
        push edi
        mov edi,[ebp+8] ;����� ����������
        mov ebx,1       ;n=1
;���������� 2^n
lp:     mov ecx,ebx     ;������� �����=n
        mov eax,1       ;1 
lp1:    shl eax,1       ;�������� �� 2, ������� 2^1, 2^2,... 2^n
        jc fin          ;���� ����������� ���� cf, �� ��������� ����� ������������ ������, �������
        loop lp1        ;���������� ���� ���������� 2^n
        mul ebx         ;n*2^n
        test edx,edx    ;���� edx �� ����� 0
        jnz fin         ;�� ��������� ����� ������������ ������, �������
        dec eax         ;n*2^n-1

        ccall [wsprintf],buf,fmt1,eax   ;������������� ��������� ����� ������ � ������
        mov esi,buf     ;����� ������ � ������
;�������� ����� � ����������
append: lodsb           ;����� ��������� ������ �����
        test al,al      ;���� ����� �����
        jz m1           ;�� ��������� �������
        stosb           ;�������� ������ � ���������
        jmp append      ;���������� �����������
m1:     inc ebx         ;n=n+1
        jmp lp          ;���������� ��� ���������� ����� ������
fin:    mov ecx,itoglen ;����� ��������� ����
        mov esi,itog    ;��� ������
        rep movsb       ;�������� ��������� � ����������
        dec ebx         ;n-1, ��������� ��� ���������� ����� ���������� �����
        ccall [wsprintf],edi,fmt1,ebx   ;�������� ����� ���������� �����
        pop edi         ;������������ ��������
        pop esi
        pop ebx
        pop ebp         ;������ �������
        ret 4           ;����� � �������� ����������� ���������

