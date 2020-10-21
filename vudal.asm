;Козлов Александр Алексеевич БПИ193
;Разработать программу определения параметра максимального числа Вудала, не превышающего длины безнакового машинного слова

format PE GUI                          ; 32-разрядная консольная программа WINDOWS EXE
entry start                                  ; точка входа

include 'win32a.inc'

section '.idata' import data readable        ; секция импортируемых функций

library kernel,'kernel32.dll',\
        user,'user32.dll',\
        msvcrt,'msvcrt.dll'

import  kernel,\
        ExitProcess,'ExitProcess'

import  user,\
        MessageBox,'MessageBoxA',\
        wsprintf,'wsprintfA'

section '.data' data readable writeable      ; секция данных
resmsg  db 'Числа Вудала',0
fmt1    db '%u',13,10,0
itog    db 13,10,'Максимальный параметр числа: '
itoglen=$-itog
result  db 256 dup(0)
buf     db 16 dup(0)
section '.code' code readable executable     ; секция кода
start:                                       ; точка входа в программу
        stdcall Vudal,result                    ;Вычисляем сисла Вудала
        stdcall [MessageBox],0,result,resmsg,0  ;вывести сообщение с результатом
ex:     stdcall [ExitProcess], 0;выход
;функция вычисления чисел Вудала пока они не превысят длину беззнакового машинного слова
;соглашение вызова stdcall
;void Vudal(char *res);
Vudal:
        push ebp        ;Пролог функции
        mov ebp,esp
        push ebx        ;сохранить регистры по соглашению stdcall
        push esi
        push edi
        mov edi,[ebp+8] ;адрес результата
        mov ebx,1       ;n=1
;возведение 2^n
lp:     mov ecx,ebx     ;счетчик цикла=n
        mov eax,1       ;1 
lp1:    shl eax,1       ;умножаем на 2, полчаем 2^1, 2^2,... 2^n
        jc fin          ;если установился флаг cf, то превысили длину беззнакового целого, переход
        loop lp1        ;продолжить цикл возведения 2^n
        mul ebx         ;n*2^n
        test edx,edx    ;если edx не равен 0
        jnz fin         ;то превысили длину беззнакового целого, переход
        dec eax         ;n*2^n-1

        ccall [wsprintf],buf,fmt1,eax   ;преобразовать очередное число Вудала в строку
        mov esi,buf     ;адрес строки с числом
;добавить число к результату
append: lodsb           ;взять очередной символ числа
        test al,al      ;если конец числа
        jz m1           ;то закончить перенос
        stosb           ;записать символ в результат
        jmp append      ;продолжить копирование
m1:     inc ebx         ;n=n+1
        jmp lp          ;продолжить для следующего числа Вудала
fin:    mov ecx,itoglen ;длина сообщения итог
        mov esi,itog    ;его начало
        rep movsb       ;добавить сообщение к результату
        dec ebx         ;n-1, поскольну нас интересует номер последнего числа
        ccall [wsprintf],edi,fmt1,ebx   ;добавить номер последнего числа
        pop edi         ;восстановить регистры
        pop esi
        pop ebx
        pop ebp         ;Эпилог функции
        ret 4           ;выйти с очисткой переданного параметра

