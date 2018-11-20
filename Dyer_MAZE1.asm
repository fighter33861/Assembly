;Ethan Dyer
;11/2/2018
;Purpose: draw a maze and be able to move in to reach a goal. 

org 100h 
include emu8086.inc                 
jmp code
  maze db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1;1 is wall, 0 is DIace, 2 is person, 3 is goal
       db 1,2,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1 
       db 1,0,1,0,1,1,1,0,1,1,1,1,1,1,1,1,1,0,1
       db 1,0,1,0,1,0,0,0,1,1,0,0,0,0,1,0,1,0,1
       db 1,0,0,0,1,0,1,1,0,0,0,1,1,0,1,0,1,0,1
       db 1,0,1,0,1,0,0,0,0,0,0,0,1,0,1,0,0,0,1
       db 1,0,1,0,1,1,1,1,0,1,0,0,1,0,1,1,1,0,1
       db 1,0,1,0,1,0,0,0,1,0,1,0,1,0,0,0,0,0,1
       db 1,0,1,0,1,0,1,0,1,0,1,0,1,1,1,1,1,1,1
       db 1,0,1,1,1,0,1,0,0,0,1,0,0,0,0,1,0,1,1
       db 1,0,0,0,0,0,1,0,0,0,1,0,0,1,0,0,0,3,1
       db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1  
 rsize=19; row size 
 csize=12; column size  
 
code:        ;main program
   call DRAW
   call INSTR
   call NAV
   jmp stop

;DRAW draws the maze
PROC DRAW  
   push BX
   push SI
   push CX; push all the registers that will be used
   cursoroff  
   mov BH,0
   mov BL,0 
   lea SI,maze
   mov CX,csize ; set up initial conditions
nextrow:
     gotoxy BH,BL; set cursor to this location
     push CX; save CX for the loop
     mov CX,rsize
     call ROW; print row
     pop CX
     add SI,rsize; point to the next row
     add BL,1; move location down by 1
     loop nextrow  
   pop CX; pop all the registers to put them back to their original values
   pop SI
   pop BX 
   ret
ENDP DRAW



;ROW prints a row
PROC ROW
  push AX
  push SI; push all the registers that will be used 
  top:
  call ATOM  
    add SI,1 
    loop top
  pop SI; pop all the registers to put them back to their original values
  pop AX
  ret
ENDP ROW  

;procedure to print a single cell, depending on what SI is pointing to.
Proc ATOM
    cmp [SI],0; is it a DIace?
    jne wall; if not test wall
    mov AL, 20h
    jmp done
wall:    
    cmp [SI],1; is it a wall?
    jne man; if not test man
    mov AL, 0DBh
    jmp done 
man:
    cmp [SI],2; is it a man?
    jne goal; if not test goal
    mov AL, 1h
    jmp done
goal:
    cmp [SI],3;is it the goal
    jne done
    mov AL, 78h
done:
    putc AL; output character 
    ret     
ENDP ATOM 
 
; nav stands for navigation, it controls the second part of the maze- moving through it till you hit the goal
PROC NAV
    lea SI,maze
    add SI, 20
tillEnd: 
	xor AX,AX  
    mov AH, 00h    
    int 16h
    cmp AH,11h
    jne LeftA ; do we go up?
    Call Up
    jmp Found  
LeftA:; do we go left?
    cmp AH,1Eh
    jne DownS
    Call Left
    jmp Found 
DownS:;do we go down?
    cmp AH,1Fh 
    jne RightD
    Call Down
    jmp Found
RightD:; do we go right
    cmp AH,20h
    jne Found 
    Call Right
Found:
    cmp [SI],3
    jne tillEnd
    Call CLEAR_SCREEN
    gotoxy 25,12
    PrintN "You did it M8"
    ret 
ENDP NAV  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; up, down, left, and right control set parameters and call move with those set. 
PROC Up 
      lea DI,[SI]
      sub DI,rsize
      call MOVE
    ret
ENDP Up

PROC Left
      lea DI,[SI]
      sub DI,1 
      call MOVE
    ret
ENDP Left

PROC Down
      lea DI,[SI]
      add DI,rsize 
      call MOVE
    ret
ENDP Down

PROC Right
      lea DI,[SI]
      add DI,1
      call MOVE
    ret
ENDP Right

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;move focuses on figuring out what is in the cell we are thinking about moving to, and calls other function that draws it
PROC MOVE 
    cmp [DI],3; are we at the goal
    jne iswall
    mov [SI],3
    jmp NoDraw   
isWall:; are we trying to move to a wall?    
    cmp [DI],1
    jne isSpace
    putc 07
    jmp NoDraw
isSpace:;are we trying to move to a space? 
    cmp [DI],0 
    je drawing
    jmp NoDraw
drawing:; draw, if applicable
     mov [SI],0
     call DrawUnit 
     mov SI,DI
     mov [SI],2
     call DrawUnit
NoDraw:
    ret
ENDP MOVE  

;Uses SI to determine the x(BL) and y(BH)
PROC Location
    push SI
    push AX 
    xor BX,BX
    xor AX,AX
    lea AX,maze
    sub SI,AX
    xor AX,AX; this whole section is to make SI start at maze, I had to do some weird things because of 8 bit vs 16 bit registers 
CountROW: ;by subtracting SI until it is less than rsize and counting the number of times and putting it in BH, you effectively get whole integer division  
    cmp SI,rsize
    jl Column
    sub SI, rsize
    inc BH
    jmp CountROW    
Column:
    mov AX, SI; again 16 bit to 8 bit conversion 
    mov BL,AL; puting the rest into BL is effectively modulo SI and the correct x location
    pop AX
    pop SI
    ret
ENDP Location

;Handles calling necissary functions to print a cell 
PROC DrawUnit
    push BX
    call Location
    gotoxy BL,BH
    pop BX  
    Call ATOM
    ret
ENDP DrawUnit  

;outputs basic instructions
PROC INSTR
    gotoxy 40,4
    PRINT  "Move UP: w"
    gotoxy 40,5
    PRINT  "Move DOWN: s"
    gotoxy 40,6
    PRINT   "Move LEFT: a"
    gotoxy 40,7
    PRINT  "Move RIGHT: d"
    gotoxy 40,8
    PRINT   "MAN: " 
    putc 1
    gotoxy 40,9 
    PRINT  "Goal: "  
    putc 78h
    ret
ENDP INSTR

DEFINE_CLEAR_SCREEN
stop:     
END 
