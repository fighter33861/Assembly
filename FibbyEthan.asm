;Ethan Dyer 10/14/2018 253
;Purpose: Create an program that prints all fibonacci upto and including n where n is set by the user    

org 100h
include emu8086.inc  
PRINTN  'How many fibonacci numbers do you want?'   ;promt the user
call SCAN_NUM  ;get the numbr from the user and put it into CX
MOV AX,0;  
MOV DX,1; set initial values of fibinochi 

Print:
PRINTN ''         ; Go to the next line
call PRINT_NUM_UNS ; print the number in AX  
call NEXTFIB       ;Change AX to the next FIb number
loop Print  ; Keep doing this the number of times specified by the user

PROC NEXTFIB   
    Mov BX,AX ;mov AX into BX in order to preserve it
    Add Ax,DX ;add the current number to the previous number  
    Mov DX,BX ; the current number becomes the previous number
    RET       
ENDP NEXTFIB

;Biggest signed fibbochi number =  28,657 (the next number is 46,368 which is greater than 32,767)
;Biggest unsigned fibbonachi number = 46,368 (The next number is 75,025 which is greater than 65,536)
;You know when you have hit the largest fibbinochi in both signed and unsigned when the next number is less than the previous number

DEFINE_PRINT_NUM_UNS
DEFINE_SCAN_NUM                     
END





