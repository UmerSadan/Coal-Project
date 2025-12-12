;=================  5 lives + Green Shirt = BONUS  =========================


INCLUDE Irvine32.inc
INCLUDELIB winmm.lib           

PlaySound PROTO,
    pszSound:PTR BYTE, 
    hmod:DWORD, 
    fdwSound:DWORD
    
; SOUND KY LIYE
SND_SYNC      EQU 0000h 
SND_ASYNC     EQU 0001h  
SND_NODEFAULT EQU 0002h  
SND_LOOP      EQU 0008h  
SND_FILENAME  EQU 20000h 

GetAsyncKeyState PROTO, vKey:DWORD

; Key Codes = (ASCII)
VK_A        EQU 41h
VK_W        EQU 57h
VK_D        EQU 44h
VK_S        EQU 53h

VK_X        EQU 58h 
VK_P        EQU 50h
VK_RETURN   EQU 0Dh 

 ;=======================================================================================
 ;=======================================================================================
 ;=======================================================================================
 ;                                     DATA SEGMENT
 ;=======================================================================================
 ;=======================================================================================
 ;=======================================================================================

.data

; ---------------------------------- FILE HANDLING ---------------------------


promptName   db "Enter Player Name: ", 0
playerName   db 20 DUP(?)   
filename     db "scores.txt", 0
fileHandle   DWORD ?

highScoreTitle db "SCORE CARD TILL NOW ",0Dh, 0Ah, 0
fileBuffer     db 5000 dup(?) 
newEntry       db 1000 dup(?)  
bytesRead       DWORD ?
strScoreLabel  db " - Score: ", 0
strLevelLabel  db " - Level: ", 0
strNewLine     db 0Dh, 0Ah, 0 
buffer         db 5000  dup(?)
gap            db "                                        ", 0

; ---------------------------------- MENU-DISPLAYED ---------------------------------
ground db "------------------------------------------------------------------------------------------------------------------------",0

strScore db "Score: ",0
strLivesText db " Lives: ",0 
strLevelText db " Level: ",0
score dd 0
playerLives db 5 
currentLevel db 1  
askNameMsg  db "Enter Your Name : ", 0

; --------------------------------- POSIOTIN OF PLAYER ---------------------------------
startX BYTE 5
startY BYTE 21 
xPos db 5
yPos db 21
prevYPos db 21 
isJumping db 0

; ----------------------------------------------- ENEMY DATA --------------------------------------

enemyCount EQU 20
activeEnemy db 3  

enemyX db enemyCount dup(0)
enemyY db enemyCount dup(0)
enemyDir db enemyCount dup(0) ; 2 = moving left, 1 = moving right, 0 = not moving, 3 = very fast move
enemyState db enemyCount dup(0) ;; 1 = alive, 0 = dead, 2= sheel, 3 = slide
enemyType db enemycount dup(0)

enemyTile db "G", 0 


xCoinPos db ?
yCoinPos db ?
my_player db 178,178,178,0
inputChar db ?

;----------------------------------- BASIC SETUP -----------------------------------------

marioscreen db "WELCOME TO SUPER MARIO BROS -- 24i-0591", 0
gameOver db "CHICKEN DINNER ", 0
winScreen db "CONGRATULATIONS! YOU WON!", 0
returnMenu db "Press ENTER to return to menu", 0

;----------------------------------- BASIC SETUP -----------------------------------------

;----------------------------------- GAME MENU -----------------------------------------
start db "Start Game", 0
scorecard db "High Scores", 0
instruction db "Instructions ", 0
nofile db "No Scores Available ", 0
wapsi db "Press any key to Retrun to Menu", 0
exits db "Exit ",0

in1 db "Move Right (D)", 0
in2 db "Move Left (A)", 0
in3 db "Pause (P)", 0
in4 db "Exit (X)", 0
in5 db "Jump (W)", 0
in6 db "Freeze the enemies (F)", 0
in7 db "Increase score by 1000 ($)", 0
in8 db "Gain Life (+)", 0

selectedIndex DWORD 0           ; for menu
;----------------------------------- Game Menu -----------------------------------------

;----------------------------------- PAUSE MENU -----------------------------------------
resume db "Resume Game", 0
selectedIndex2 DWORD 0           ; for menu

;--------------------------------------- TILES -----------------------------------------
.data
tileAir      db " ",0      
tileGround   db 219,0      
tileBrick    db 178,0      
tileQuestion db 176,0      
tilePipe     db 63,0            
tileCoin     db "o", 0      
tileCloud    BYTE 177, 0
heart      db "+", 0                ; power-uo
star       db "$", 0                ; power-uo
tile10     db 63, 0
tile11     db 63, 0

Levelmap  db  1800 dup(0)  

maprows equ 20 
mapcols equ 90
mapStartY equ 3 



; ---------------------------------- TIMER SETT ---------------------------

startTime       DWORD ?
timerMsg     BYTE " Time: ", 0
timerlabel   db " Time: ", 0
; ---------------------------------- WELCOME TO2ND SCREEN ---------------------------
map2welcome   db 13,10,13,10
            db "                                           ********************************", 13, 10, 13, 10
            db "                                           *                              *", 13, 10, 13 , 10
            db "                                           *   *   WELCOME TO MAP 2   *   *", 13, 10, 13 , 10
            db "                                           *                              *", 13, 10, 13 , 10
            db "                                           ********************************", 0

.data


; ---------------------------------- sound system ---------------------------
soundBGM      db "bgm.wav", 0
soundJump     db "jump.wav", 0
soundCoin     db "coin.wav", 0
soundWin      db "win.wav", 0
soundkick     db "kick.wav", 0
;------------------------------ UNDERGORUNF --------------------------------

isUnderground db 0      
savMarioX     db ?     
savMarioY     db ?

; ---------------------------------- FREEXE TIEM ---------------------------

freeze    db "F", 0      
strFreeze    db " FREEZE: ", 0
isInvincible    BYTE 0          ; 0 = Normal, 1 = God Mode
invincibleTimer DWORD 0         ; How long it lasts

isTimeFrozen    BYTE 0          ; 0 = Normal, 1 = Frozen
freezeTimer     DWORD 0         ; How long freeze last

 ;=======================================================================================
 ;=======================================================================================
 ;=======================================================================================
 ;                                      CODE SEGMENT
 ;=======================================================================================
 ;=======================================================================================
 ;=======================================================================================

.code
main PROC
    call Randomize
    call AskName

MainMenuLoop: 
    ;----------------------------------- TITLE SCREEN -----------------------------------------
    call BackgroundMusic
    call TitleScreen
    mov eax, 2000
    call delay
    call clrscr
    
    ;----------------------------------- MENU SHOW -----------------------------------------
    call MenuControl             
    call clrscr 
    
    mov dl, maprows
    mov dh, mapcols
    call gotoxy
    mov eax, white + (BLUE*16)
    call SetTextColor
    call clrscr
    
    mov currentLevel, 1          
    
    call InitializeLevel  
    call DrawLevel        

    mov al, startX
    mov [xPos], al
    mov al, startY
    mov [yPos], al
    mov [prevYPos], al 
    
    mov score, 0
    mov playerLives, 5

    call InitializeEnemies 

    call GetMseconds             
    mov startTime, eax

    call DrawPlayer
    

;----------------------------------- GAME LOOP -----------------------------------------

gameLoop:
    
    mov al, yPos
    mov prevYPos, al

    call CheckItemPick           
    call secretpipe              ; <--- MATCHES YOUR NAME

    mov eax, yellow + (black * 16)
    call SetTextColor
    
    mov dl, 0
    mov dh, 0
    call Gotoxy
    mov edx, OFFSET strScore
    call WriteString
    mov eax, [score]
    call WriteDec
    
    mov edx, OFFSET strLivesText 
    call WriteString
    movzx eax, playerLives
    call WriteDec
    
    mov edx, OFFSET strLevelText
    call WriteString
    movzx eax, currentLevel
    call WriteDec
    mov al, ' ' 
    call WriteChar 

    call DrawTimer

    ; --- INPUTS ---
    INVOKE GetAsyncKeyState, VK_X
    test eax, 8000h              
    jz skipExit
    jmp exitGame
skipExit:

    INVOKE GetAsyncKeyState, VK_P
    test eax, 8000h              
    jz skipPause                        
    jmp ifPause
skipPause:

    ; --- MOVEMENT ---
    cmp isJumping, 1             
    je skipJump
    call LeftRightMovement

skipJump:
    
    call UpdateEnemies
    call PlayerCollisionEnemy
    
    cmp playerLives, 0
    jle DoGameOver

    call DrawEnemies
    
  

    ; ------------------------------------ Timer---------------------- ---
    cmp isInvincible, 1          
    jne CheckFreezeTimer         
    
    dec invincibleTimer          
    cmp invincibleTimer, 0       
    jg CheckFreezeTimer          
    
    mov isInvincible, 0          ; Reset

CheckFreezeTimer:
    cmp isTimeFrozen, 1          
    jne EndTimerLogic            
    
    dec freezeTimer              
    cmp freezeTimer, 0           
    jg EndTimerLogic             
    
    mov isTimeFrozen, 0          ; Reset

EndTimerLogic:
    ; ========================================================

    mov eax, 30 
    call Delay

    jmp gameLoop 

;----------------------------------- GAME LOOP END -----------------------------------

DoGameOver:
    call SaveScoreIrvine
    call ShowHighScores
    call GameOverScreen
    jmp MainMenuLoop
    
ifPause:
    call PauseControl   
    call clrscr
    mov eax, white + (BLUE*16)
    call SetTextColor
    call clrscr                  
    call DrawLevel    
    call DrawPlayer    
    jmp gameLoop

exitGame:
    call StopSound
    call clrscr
    exit
main ENDP

; =================================================================================
; =================================================================================
; =================================================================================
; =================================================================================
;                                    ENEMIES
; =================================================================================
; =================================================================================
; =================================================================================
; =================================================================================



;-------------------------------- INITLIZE ENEMY  -------------------------------------

InitializeEnemies PROC USES ecx esi edi
    mov al, currentLevel
            ; diffeentt levels m differny enemies 
    cmp al, 1
    je Level1
    cmp al, 2
    je Level2
    cmp al, 3
    je Level3
    cmp al, 4
    je Level4
    cmp al, 5
    je Level5
    cmp al, 6
    je Level6
    jmp ResetStates

Level1: 
    mov activeEnemy, 2
    mov enemyX[0], 22
    mov enemyY[0], 11
    mov enemyDir[0], 1
    mov enemyType[0], 0
    
    mov enemyX[1], 60
    mov enemyY[1], 15
    mov enemyDir[1], 0
    mov enemyType[1], 0
    jmp ResetStates

Level2: 
    mov activeEnemy, 3
    mov enemyX[0], 30
    mov enemyY[0], 18
    mov enemyDir[0], 1
    mov enemyType[0], 0
    
    mov enemyX[1], 50
    mov enemyY[1], 11
    mov enemyDir[1], 0
    mov enemyType[1], 0

    mov enemyX[2], 70
    mov enemyY[2], 18
    mov enemyDir[2], 0
    mov enemyType[2], 0
    jmp ResetStates

Level3: 
    mov activeEnemy, 5
    mov enemyX[0], 25
    mov enemyY[0], 15
    mov enemyDir[0], 1
    mov enemyType[0], 0
    
    mov enemyX[1], 45
    mov enemyY[1], 10
    mov enemyDir[1], 1
    mov enemyType[1], 0

    mov enemyX[2], 65
    mov enemyY[2], 18
    mov enemyDir[2], 0
    mov enemyType[2], 0
    
    mov enemyX[3], 35
    mov enemyY[3], 14
    mov enemyDir[3], 1
    mov enemyType[3], 0
    
    mov enemyX[4], 80
    mov enemyY[4], 16
    mov enemyDir[4], 0
    mov enemyType[4], 0
    jmp ResetStates

Level4: 
    mov activeEnemy, 3
    mov enemyX[0], 20
    mov enemyY[0], 13
    mov enemyDir[0], 0
    mov enemyType[0], 0

    mov enemyX[1], 45
    mov enemyY[1], 9
    mov enemyDir[1], 1
    mov enemyType[1], 1

    mov enemyX[2], 50
    mov enemyY[2], 18
    mov enemyDir[2], 0
    mov enemyType[2], 1
    jmp ResetStates

Level5: 
    mov activeEnemy, 4
    mov enemyX[0], 70
    mov enemyY[0], 5
    mov enemyDir[0], 0
    mov enemyType[0], 1
    
    mov enemyX[1], 45
    mov enemyY[1], 9
    mov enemyDir[1], 1
    mov enemyType[1], 1

    mov enemyX[2], 20
    mov enemyY[2], 13
    mov enemyDir[2], 0
    mov enemyType[2], 0

    mov enemyX[3], 30
    mov enemyY[3], 18
    mov enemyDir[3], 1
    mov enemyType[3], 0
    jmp ResetStates

Level6: 

    mov activeEnemy, 8
    mov enemyX[0], 20
    mov enemyY[0], 13
    mov enemyDir[0], 0
    mov enemyType[0], 1

    mov enemyX[1], 45
    mov enemyY[1], 9
    mov enemyDir[1], 1
    mov enemyType[1], 1

    mov enemyX[2], 70
    mov enemyY[2], 5
    mov enemyDir[2], 0
    mov enemyType[2], 1

    mov enemyX[3], 10
    mov enemyY[3], 18
    mov enemyDir[3], 1
    mov enemyType[3], 0

    mov enemyX[4], 50
    mov enemyY[4], 18
    mov enemyDir[4], 0
    mov enemyType[4], 0

    mov enemyX[5], 80
    mov enemyY[5], 18
    mov enemyDir[5], 0
    mov enemyType[5], 0

    mov enemyX[5], 89
    mov enemyY[5], 6
    mov enemyDir[5], 0
    mov enemyType[5], 1

    mov enemyX[5], 10
    mov enemyY[5], 8
    mov enemyDir[5], 0
    mov enemyType[5], 0

    jmp ResetStates

ResetStates:
    movzx ecx, activeEnemy
    mov esi, 0
resetLoop:
    mov enemyState[esi], 1
    inc esi
    loop resetLoop
    
    movzx esi, activeEnemy
    cmp esi, enemyCount
    jge doneReset
clearLoop:
    mov enemyState[esi], 0
    inc esi
    cmp esi, enemyCount
    jl clearLoop
doneReset:
    ret
InitializeEnemies ENDP

;=----------------------------------------- UPDATE ENEMISE -----------------------------------------

UpdateEnemies PROC USES eax ebx ecx edx esi
    
    cmp isTimeFrozen, 1
    je enemiesDone

    movzx ecx, activeEnemy                   ; active kitny hn bhai
    mov esi, 0

    cmp ecx, 0
    je enemiesDone

enemyUpdate1:
    
    cmp enemyState[esi], 0 
    je skipEnemy
                                ; change ky uopdate bhi t krna h, jhan sy move kia whan pr air aa gi
                                ; and dosri jaga p mario chala gya 
    mov eax, white + (blue*16)
    call SetTextColor
    mov dl, enemyX[esi]
    mov dh, enemyY[esi]
    call Gotoxy
    mov al, ' '
    call WriteChar

    cmp enemyState[esi], 2              ; 2= sheell
    je Nomovement

    push ecx                   
    
    mov ecx, 1                
    cmp enemyState[esi], 3              ; after sheel 3rd state
    jne StartMove
    mov ecx, 2                  

StartMove:
    push ecx                   
    
    cmp enemyDir[esi], 0                ; enemy direction ko dekha agr right p h t takra ky 
                                        ; wpasi and dosri dirction p jae gi, rigth p solid h t 
                                        ; right move nhi kr pae ga
                                        ; same with left scene
    je tryMoveLeft

tryMoveRight:
    mov dl, enemyX[esi]
    inc dl
    mov dh, enemyY[esi]
    call CheckCollision
    cmp eax, 1 
    je hitRightWall
    
    inc enemyX[esi]
    jmp EndMove

hitRightWall:
    mov enemyDir[esi], 0       
    jmp EndMove

tryMoveLeft:
    mov dl, enemyX[esi]
    dec dl
    mov dh, enemyY[esi]
    call CheckCollision
    cmp eax, 1
    je hitLeftWall
    
    dec enemyX[esi]                 ; positoion kia h
    jmp EndMove

hitLeftWall:
    mov enemyDir[esi], 1            ; direction changes

EndMove:
    pop ecx                 
    loop StartMove       

    pop ecx            

Nomovement:
    
    mov dl, enemyX[esi]
    mov dh, enemyY[esi]
    ;dec xpos 
    inc dh 
    call CheckCollision
    cmp eax, 1
    je enemyGrounded
    
    inc enemyY[esi] 
enemyGrounded:

skipEnemy:
    inc esi
    dec ecx
    cmp ecx, 0
    jne enemyUpdate1     

enemiesDone:
    ret
UpdateEnemies ENDP

;------------------------------------------- DRAW ENENIMES ----------------------------

DrawEnemies PROC USES eax ecx edx esi
    movzx ecx, activeEnemy                ; kitny active h usko dekhna h
    mov esi, 0
    
    mov eax, lightRed + (blue*16)
    call SetTextColor

drawEnemyLoop:
    
    cmp enemyState[esi], 0
    je noDrawEnemy

    mov dl, enemyX[esi]
    mov dh, enemyY[esi]
    call Gotoxy

    
    cmp enemyState[esi], 2
    je DrawShell
    cmp enemyState[esi], 3
    je DrawShell

    
    cmp enemyType[esi], 1     
    je DrawKoopa

    mov al, 'G'
    call WriteChar
    jmp noDrawEnemy

DrawKoopa:
    mov al, 'K'
    call WriteChar
    jmp noDrawEnemy

DrawShell:
    mov eax, magenta + (blue*16)
    call settextcolor
    mov al, 'S'               
    call WriteChar

noDrawEnemy:
    inc esi
    loop drawEnemyLoop
    ret
DrawEnemies ENDP

;------------------------------------- enemy - COLLOSION - player -----------------------------

PlayerCollisionEnemy PROC USES eax ecx edx esi
    movzx ecx, activeEnemy 
    mov esi, 0

collisionLoop:
    
    cmp enemyState[esi], 0 
    je nextColCheck

   
    mov al, xPos                    ; collide
    cmp al, enemyX[esi]
    jne nextColCheck

    mov al, yPos                    ; x and y ko check kia ky pata chaly khan sy collide kia
                                    ; if uper sy aya yneechy sy

    cmp al, enemyY[esi]
    jne nextColCheck

    mov al, prevYPos
    cmp al, enemyY[esi]
    jl HandleStomp

        
    cmp enemyState[esi], 2              ; seied collide
    je KickTheShell                     ; koopa ky liye different, enemy not dies, bs still hoyay

    
    jmp PlayerHurt

HandleStomp:
    call JumpSound              
    
    cmp enemyType[esi], 0
    je KillGoomba


    cmp enemyState[esi], 1
    je MakeShell
    
    
    cmp enemyState[esi], 2
    je KickTheShell


    cmp enemyState[esi], 3
    je MakeShell

KillGoomba:
    mov enemyState[esi], 0      
    add score, 100
    jmp finishColLoop

MakeShell:
    mov enemyState[esi], 2     
    add score, 100
    

    dec yPos                ; mario uper aa gya thora sa taky collisoin again n ho jae, means not 2 coollision ikathyi
    call DrawPlayer
    jmp finishColLoop

KickTheShell:
    call kicksound

    mov al, xPos
    cmp al, enemyX[esi]
    jl KickRight              
    

    mov enemyDir[esi], 0
    jmp ActivateSlide

KickRight:
    mov enemyDir[esi], 1

ActivateSlide:
    add score, 100
    mov enemyState[esi], 3      
    cmp enemyDir[esi], 1
    je pushR
    dec enemyX[esi]             
    jmp finishColLoop
pushR:
    inc enemyX[esi]             
    jmp finishColLoop

PlayerHurt:
    dec playerLives
    ;call StopSound              
    
    mov eax, 500
    call Delay 
    
    call UpdatePlayer 
    mov al, startX
    mov [xPos], al
    mov al, startY
    mov [yPos], al
    mov isJumping, 0 
    call DrawPlayer
    jmp finishColLoop 

nextColCheck:
    inc esi
    dec ecx
    cmp ecx, 0
    je collisionsDone
    jmp collisionLoop

collisionsDone:
finishColLoop:
    ret

PlayerCollisionEnemy ENDP

; =================================================================================
; =================================================================================
; =================================================================================
; =================================================================================
;                                    GAME OVER
; =================================================================================
; =================================================================================
; =================================================================================
; =================================================================================

GameOverScreen PROC
    call clrscr
    mov eax, lightRed + (black*16)
    call SetTextColor

    
    mov dl, 40                          ; screen dispkay 
    mov dh, 10
    call Gotoxy
    mov edx, OFFSET gameOver
    call WriteString

    mov dl, 35
    mov dh, 14
    call Gotoxy
    mov eax, white + (black*16)
    call SetTextColor
    mov edx, OFFSET returnMenu
    call WriteString

    mov dl, 40
    mov dh, 12
    call gotoxy
    mov edx, offset strscore
    call writestring
    mov eax, [score]
    call writedec

    call ReadKey 
    ;call menucontrol

wait1:
    call ReadKey
    cmp ax, 1C0Dh 
    jne wait1
    
    ret
GameOverScreen ENDP

; =================================================================================
; =================================================================================
; =================================================================================
; =================================================================================
;                                   WIN
; =================================================================================
; =================================================================================
; =================================================================================
; =================================================================================

WinScreendis PROC
    call clrscr                 ;Menu screeen aa gi
    mov eax, lightGreen + (black*16)
    call SetTextColor

    mov dl, 35
    mov dh, 10
    call Gotoxy
    mov edx, OFFSET winScreen
    call WriteString

    mov dl, 40
    mov dh, 12
    call Gotoxy
    mov eax, yellow + (black*16)
    call SetTextColor
    mov edx, OFFSET strScore
    call WriteString
    mov eax, [score]
    call WriteDec

    mov dl, 35
    mov dh, 14
    call Gotoxy
    mov eax, white + (black*16)
    call SetTextColor
    mov edx, OFFSET returnMenu
    call WriteString

    call ReadKey 

wait2:

    call ReadKey
    cmp ax, 1C0Dh 
    jne wait2
    
    ret
WinScreendis ENDP

;----------------------------------- NEXT SCREEN -------------------------------------------
nextMap PROC USES eax edx
    mov eax, yellow + (black*16)
    call settextcolor    

    call clrscr
    
    mov dl, 40
    mov dh, 8
    call gotoxy
    mov edx, offset map2welcome
    call writestring

    mov eax, 3000
    call delay

    call clrscr
    ret
nextMap ENDP 

; =================================================================================
; =================================================================================
; =================================================================================
; =================================================================================
;                                   COLLIION
; =================================================================================
; =================================================================================
; =================================================================================
; =================================================================================
;;------------------------------- CHECK COLLOIOSN -----------------------------------------

CheckCollision PROC USES ebx edx esi
    cmp dl, 0                           ; edges collison check
    jle collision_found 
    cmp dl, mapcols
    jge collision_found 
    cmp dh, mapStartY
    jl collision_found 
    cmp dh, mapStartY + maprows - 1
    jg collision_found 

                                         ;Array Index finding, eax = (solid or nt)
    xor eax, eax    
    mov al, dh     
    sub al, mapStartY  
    mov bl, mapcols
    mul bl         

    xor ebx, ebx                        ; tile ttype
    mov bl, dl     
    dec bl          
    add eax, ebx    

    mov esi, OFFSET Levelmap
    add esi, eax            
    mov al, [esi]           

    
    cmp al, 0                           ; al pass though hoo,,  air 
    je no_collision
    cmp al, 5
    je no_collision 
    cmp al, 6          
    je no_collision
    cmp al, 7                        ; Heart
    je no_collision
    cmp al, 8                        ; Star
    je no_collision
    cmp al, 60
    je no_collision                     ; neechy
    cmp al, 61
    je no_collision                     ; wapsi uper
    cmp al, 9
    je no_collision


collision_found:
    mov eax, 1     
    jmp done_check

no_collision:
    mov eax, 0      
done_check:
    ret
CheckCollision ENDP

; ---------------------------- LeftRightMovement -------------------------  

LeftRightMovement PROC
    
CheckLeft:
    
    INVOKE GetAsyncKeyState, VK_A
    test eax, 8000h     
    jz CheckRight

    
    mov dl, xPos
    dec dl             
    mov dh, yPos       
    call CheckCollision
    cmp eax, 1         
    je CheckRight       

    
    call UpdatePlayer                   ; Erase old position
    dec xPos
    call DrawPlayer
    jmp DoneHorizontal  

CheckRight:
    
    INVOKE GetAsyncKeyState, VK_D
    test eax, 8000h
    jz DoneHorizontal

    mov al, xPos
    cmp al, mapcols - 3  
    jge hiddenroom
    

    mov dl, xPos
    inc dl              
    mov dh, yPos        
    call CheckCollision
    cmp eax, 1
    je DoneHorizontal

    call UpdatePlayer
    inc xPos
    call DrawPlayer
    jmp DoneHorizontal

TriggerNextScreen:
    call LoadNextScreen
    jmp DoneHorizontal

hiddenroom:
    cmp isunderground, 1
    je donehorizontal
    call loadnextscreen
    jmp donehorizontal

DoneHorizontal:

    INVOKE GetAsyncKeyState, VK_W
    test eax, 8000h
    jz CheckGravity

    mov dl, xPos
    mov dh, yPos
    inc dh                          ; increment kr ky pata chal gya, air p h y solid p
    call CheckCollision
    cmp eax, 1         
    jne CheckGravity   

    
    mov isJumping, 1    
    call Jumping
    mov isJumping, 0   
    jmp Done    

    
CheckGravity:
    
    mov dl, xPos
    mov dh, yPos
    inc dh              
    call CheckCollision
    cmp eax, 1         
    je Landed           ; Yes, stop falling

    call UpdatePlayer
    inc yPos
    call DrawPlayer
    jmp Done

Landed:

Done:
    ret

LeftRightMovement ENDP

;---------------------------------- NEXT SCREEN -----------------------------------

LoadNextScreen PROC                 ; agly level, ky liye, check kia ky agr right wall touched
                                    ; tb move to agla level 
    mov al, currentLevel
    inc al
    mov currentLevel, al
    
    cmp al, 7
    jge PlayerWins
    
    mov bl, startX
    mov xPos, bl
    mov al, startY
    mov yPos, al
    mov prevYPos, al
    
    call InitializeLevel
    
    mov eax, white + (BLUE*16)
    call SetTextColor
    call clrscr
    
    call DrawLevel
    call DrawPlayer
    call InitializeEnemies
    
    mov eax, 500
    call Delay
    ret

PlayerWins:
    call SaveScoreIrvine
    call ShowHighScores

    call WinScreendis
    call MenuControl
    mov currentLevel, 1
    ;exit
LoadNextScreen ENDP

;---------------------------------------- JUMPing --------------------------------------------

Jumping PROC
    call JumpSound
    mov ecx, 6          
jumpLoop:
    push ecx           

    mov dl, xPos
    mov dh, yPos
    dec dh                          ; hit head top , cEiling
    call CheckCollision
    cmp eax, 1
    je bonkHead         

    call UpdatePlayer
    dec yPos
    call DrawPlayer

    call SideJump

    mov eax, 40                 ;=========== speed h bhai ============
    call Delay
    
    pop ecx             
    loop jumpLoop
    jmp jumpDone

bonkHead:
    pop ecx             

jumpDone:
    ret
Jumping ENDP

;-----------------------------------  MOVEMENT ON JUMP -------------------------------

SideJump PROC                               ; yhan win api ki madad sy chekc kia ky
                                            ; jump + left/right movvement bhi possible ho jae
    
    INVOKE GetAsyncKeyState, VK_A
    test eax, 8000h
    jz jmpCheckRight

    mov dl, xPos
    dec dl
    mov dh, yPos
    call CheckCollision
    cmp eax, 1
    je jmpCheckRight
    call UpdatePlayer
    dec xPos
    call DrawPlayer
    jmp jmpDoneSide

jmpCheckRight:                          ; roght bhi checked
    
    INVOKE GetAsyncKeyState, VK_D
    test eax, 8000h
    jz jmpDoneSide

    mov al, xPos
    cmp al, mapcols - 2
    jge triggerScreenAir

    mov dl, xPos
    inc dl
    mov dh, yPos
    call CheckCollision
    cmp eax, 1
    je jmpDoneSide
    call UpdatePlayer
    inc xPos
    call DrawPlayer
    jmp jmpDoneSide

triggerScreenAir:
    call LoadNextScreen
    
jmpDoneSide:
    ret
SideJump ENDP

;--------------------------------------- COIN PICK -----------------------------------------

CheckItemPick PROC USES eax ebx esi
 
    xor eax, eax
    mov al, yPos
    sub al, mapStartY
    mov bl, mapcols
    mul bl        
    

    xor ebx, ebx
    mov bl, xPos
    add eax, ebx   
    
    mov esi, OFFSET Levelmap
    add esi, eax   
    

    mov bl, [esi]
    call AnalyzeTile
    cmp eax, 1     
    je ItemFound
    

    mov bl, [esi-1] 
    call AnalyzeTile
    cmp eax, 1
    je ItemFound
    
    jmp NotAnItem

ItemFound:
    mov bl, [esi]  
    cmp bl, 5
    je EraseCenter
    cmp bl, 7
    je EraseCenter
    cmp bl, 8
    je EraseCenter
    cmp bl, 9
    je EraseCenter
    

    dec esi
    
EraseCenter:
    mov BYTE PTR [esi], 0  
    jmp NotAnItem

NotAnItem:
    ret
CheckItemPick ENDP


AnalyzeTile PROC
    cmp bl, 5       
    je DoCoin
    cmp bl, 7
    je DoHeart
    cmp bl, 8
    je DoStar
    cmp bl, 9
    je DoFreeze
    
    mov eax, 0      ; Not an item
    ret

DoCoin:
    inc score
    call CoinSound
    mov eax, 1
    ret

DoHeart:
    inc playerLives        
    call CoinSound        
    mov eax, 1
    ret

DoStar:
    add score, 1000       
    call CoinSound
    mov isInvincible, 1
    mov invincibleTimer, 50
    mov eax, 1
    ret

DoFreeze:
    call CoinSound
    mov isTimeFrozen, 1    
    mov freezeTimer, 50   
    mov eax, 1
    ret
AnalyzeTile ENDP

;------------------------------- DRAW PLAYER -----------------------------------------
DrawPlayer PROC
    
    mov eax, green  + (blue*16)              ; green kr diya, requiremt
    call SetTextColor
    mov dl,xPos
    mov dh,yPos
    call Gotoxy
    mov al, 'M'
    call Writechar
    ret
DrawPlayer ENDP

;------------------------------- UPDATE PLAYER -----------------------------------------

UpdatePlayer PROC USES eax ebx ecx edx esi
    mov dl, xPos
    mov dh, yPos                            ; plauer ki poston bhi t chenhae krni h n
    call Gotoxy

    xor eax, eax
    mov al, yPos
    sub al, mapStartY
    mov bl, mapcols
    mul bl
    
    xor ebx, ebx
    mov bl, xPos
    dec bl
    add eax, ebx

    mov esi, OFFSET Levelmap
    add esi, eax
    mov al, [esi]

    cmp al, 6
    je Cloudpwapsi

    mov eax, white + (blue*16)
    call SetTextColor
    mov al, ' '
    call WriteChar
    jmp DoneUpdate

Cloudpwapsi:
    mov eax, white + (blue*16)
    call SetTextColor
    mov edx, OFFSET tileCloud
    call WriteString

DoneUpdate:
    ret
UpdatePlayer ENDP

;----------------------------------- DRAW TILE ----------------------------------------

DrawTile PROC USES edx eax              ; check kr ky drae kia, 1,2,3,4,5,6 taky different jaga
                                        ; different print krwa skn
    cmp al,0
    je air
    cmp al,1
    je ground1
    cmp al,2
    je brick
    cmp al,3
    je quest
    cmp al,4
    je pipeTile
    cmp al,5
    je coinTile
    cmp al, 6
    je cloudTile
    cmp al, 7
    je hearttile
    cmp al, 8
    je startile
    cmp al, 9               ; its freeze tiem
    je startfreeze
    cmp al, 60
    je underpipe
    cmp al, 61
    je underpipe

air:
    mov eax, white + (blue*16)
    call SetTextColor
    mov edx, OFFSET tileAir
    call writestring
    jmp done

ground1:
    mov eax, brown+ (blue*16)
    call SetTextColor
    mov edx, OFFSET tileGround
    call writestring
    jmp done

brick:
    mov eax, lightred + (blue*16)
    call SetTextColor
    mov edx, OFFSET tileBrick
    call writestring
    jmp done

quest:
    mov eax, yellow + (BLue*16)
    call SetTextColor
    mov edx, OFFSET tileQuestion
    call writestring
    jmp done

pipeTile:
    mov eax, green + (blue*16)
    call SetTextColor
    mov edx, OFFSET tilePipe
    call writestring
    jmp done

coinTile:
    mov eax, yellow + (blue*16)
    call SetTextColor
    mov edx, OFFSET tileCoin
    call writestring
    jmp done

cloudTile:
    mov eax, white + (blue*16)   
    call SetTextColor
    mov edx, OFFSET tileCloud    
    call writestring
    jmp done

startile:
    mov eax, cyan + (blue*16)
    call settextcolor
    mov edx, offset star
    call writestring
    jmp done

heartTile:
    mov eax, red + (blue*16)   
    call SetTextColor
    mov edx, OFFSET heart   
    call writestring
    jmp done

startfreeze:
    mov eax, cyan + (blue * 16)    
    call SetTextColor
    mov edx, OFFSET freeze
    call WriteString
    jmp done

underpipe:
    mov eax, green + (magenta * 16)  
    call SetTextColor
    mov edx, OFFSET tilePipe
    call WriteString
    jmp done

done:
    
    ret

DrawTile ENDP

;------------------------------------- DRAW ENTIRE LEVEL -----------------------------------

DrawLevel PROC
    mov esi, OFFSET Levelmap
    mov dh, mapStartY             
    mov ecx, maprows            

rowLoop:
    push ecx
    mov dl, 1                   
    mov ecx, mapcols             

colLoop:
    push ecx
    push edx
      
    call Gotoxy                  
    mov al, [esi]                 
    call DrawTile                 
      
    pop edx
    inc dl                       
    inc esi                      
      
    pop ecx
    loop colLoop
      
    inc dh                        
    pop ecx
    loop rowLoop
      
    ret
DrawLevel ENDP

; ------------------------------------ TITEL SCREN -------------------------------

TitleScreen Proc
    call clrscr
    mov eax, yellow + (black*16)
    call SetTextColor
    
    mov dl,30
    mov dh,12
    call Gotoxy
    mov edx,OFFSET marioscreen
    call WriteString
    ret
TitleScreen ENDP




; =================================================================================
; =================================================================================
; =================================================================================
; =================================================================================
;                                    MENU
; =================================================================================
; =================================================================================
; =================================================================================
; =================================================================================


;------------------------------------- MENU DRAW ----------------------------------

DrawMenu PROC
    
    mov dl,40
    mov dh,10
    call Gotoxy
    cmp selectedIndex,0
    jne normal1
    mov eax, black + (yellow*16)
    call SetTextColor
    jmp print1

normal1:                                 ; color = opiton ka              
    mov eax, yellow + (black*16)
    call SetTextColor

print1:                                 
    mov edx,offset start
    call WriteString    

    mov dl,40
    mov dh,12
    call Gotoxy
    cmp selectedIndex,1
    jne normal2
    mov eax, black + (yellow*16)         ; option HIGHTLIGHTING KA 
    call SetTextColor
    jmp print2

normal2:
    mov eax, yellow + (black*16)
    call SetTextColor

print2:                                 
    mov edx,offset scorecard
    call WriteString

    mov dl,40
    mov dh,14
    call Gotoxy
    cmp selectedIndex,2
    jne normal3
    mov eax, black + (yellow*16)
    call SetTextColor
    jmp print3
normal3:
    mov eax, yellow + (black*16)
    call SetTextColor
print3:                                 
    mov edx, offset instruction
    call writestring

    mov dl, 40
    mov dh, 16
    call gotoxy
    cmp selectedINdex, 3
    jne normal4
    mov eax, black + (yellow*16)
    call setTextcolor
    jmp print4

normal4:
    mov eax, yellow + (black*16)
    call setTextcolor
    
print4:
    mov edx,offset exits
    call WriteString

    ret
DrawMenu ENDP

; ---------------------------------------- MENU CONTROL --------------------------------
MenuControl PROC
    call clrscr
    mov eax, yellow + (black*16)
    call SetTextColor
    call DrawMenu

menuLoop:
    call ReadKey    
    cmp ax,4800h                                    ; Up 
    je moveUpMenu
    cmp ax,5000h                                    ; Down 
    je moveDownMenu
    cmp ax,1C0Dh                                    ; ENTER 
    je selectDone
    jmp menuLoop

moveUpMenu:
    cmp selectedIndex,0
    je menuLoop
    dec selectedIndex
    call DrawMenu
    jmp menuLoop

moveDownMenu:
    cmp selectedIndex,3
    je menuLoop
    inc selectedIndex
    call DrawMenu
    jmp menuLoop

selectDone:
    
    ; ( 0 = start)   , (1 = HIGH SCORE ), (2 = instructions) , ( 3 = exit )

    cmp selectedIndex,0
    je endMenu       ; start game

    cmp selectedIndex, 1
    je HighScoreTable

    cmp selectedindex, 2
    je ShowInstructions

    exit

ShowInstructions:
    call clrscr
    mov eax, white + (black*16)
    call SetTextColor
    
    mov dl,25
    mov dh,8
    call Gotoxy
    mov edx,OFFSET instruction
    call WriteString
    
    mov dl,20
    mov dh,10
    call Gotoxy
    mov edx, OFFSET marioscreen
    call WriteString
    
    mov dl,25
    mov dh,11
    call Gotoxy
    mov edx, OFFSET in5
    call WriteString
    
    mov dl,25
    mov dh,12
    call Gotoxy
    mov edx, offset in2
    call WriteString
    
    mov dl,25
    mov dh,13
    call Gotoxy
    mov edx, offset in1
    call WriteString
    
    mov dl,25
    mov dh,14
    call Gotoxy
    mov edx, OFFSET in3
    call WriteString
    
    mov dl,25
    mov dh,15
    call Gotoxy
    mov edx, OFFSET in4
    call WriteString

    mov dl,25
    mov dh,16
    call Gotoxy
    mov edx, OFFSET in5
    call WriteString

    mov dl,25
    mov dh,17
    call Gotoxy
    mov edx, OFFSET in6
    call WriteString

    mov dl,25
    mov dh,18
    call Gotoxy
    mov edx, OFFSET in7
    call WriteString

    mov dl,25
    mov dh,19
    call Gotoxy
    mov edx, OFFSET in8
    call WriteString

    mov eax,5000
    call Delay
    
    jmp MenuControl   

HighScoreTable:
    call clrscr
    mov eax, white + (black*16)
    call SetTextColor
    
    mov dl, 40
    mov dh, 6
    call gotoxy
    mov edx, offset highScoreTitle
    call writestring

    mov edx, offset FileName
    call OpenInputFile

    cmp eax, INVALID_HANDLE_VALUE                           ; FILE H KY NHI
    je nofileFound

    mov fileHandle, eax
    
    mov edx, OFFSET fileBuffer              ; read, file buffer sy edx m
    mov ecx, SIZEOF fileBuffer - 1
    call readfromFile           

    mov fileBuffer[eax], 0
    
    mov dl, 40
    mov dh, 10
    call gotoxy
    mov edx, OFFSET fileBuffer              ; write
    call WriteString

    mov eax, fileHandle
    call CloseFile
    jmp return
 
nofilefound:
    mov dl, 10
    mov dh, 8
    mov edx, offset nofile
    call writestring
    
return:
    mov dl, 80
    mov dh, 8
    mov edx, offset wapsi
    call writestring

    call readchar
    call closefile
    jmp menucontrol

endMenu:
    ret
MenuControl ENDP

;---------------------------------- PAUSE GAME - MENU --------------------------------

PauseGameMenu PROC
    mov dl,40
    mov dh,10
    call Gotoxy
    cmp selectedIndex2, 0
    jne normal1
    mov eax, black + (yellow*16)
    call SetTextColor
    jmp print1

normal1:                              
    mov eax, yellow + (black*16)
    call SetTextColor
print1:                                 
    mov edx,offset resume
    call WriteString

    mov dl,40
    mov dh,12
    call Gotoxy
    cmp selectedIndex2 ,1
    jne normal2
    mov eax, black + (yellow*16)
    call SetTextColor
    jmp print2
    
normal2:                              
    mov eax, yellow + (black*16)
    call SetTextColor

print2:                                 
    mov edx,offset exits
    call WriteString

    ret

PauseGameMenu ENDP

;---------------------------------- PAUSE GAME - MENU CONTROL --------------------------------

PauseControl PROC
    call clrscr
    mov eax, yellow + (black*16)
    call SetTextColor
    call PauseGameMenu

menuLoopP:
    call ReadKey    
    cmp ax,4800h                                    ; Up 
    je moveUpMenuP
    cmp ax,5000h                                    ; Down 
    je moveDownMenuP
    cmp ax,1C0Dh                                    ; ENTER 
    je selectDoneP
    jmp menuLoopP

moveUpMenuP:
    cmp selectedIndex2,0
    je menuLoopP
    dec selectedIndex2
    call PauseGameMenu
    jmp menuLoopP

moveDownMenuP:
    cmp selectedIndex2,1
    je menuLoopP
    inc selectedIndex2
    call PauseGameMenu
    jmp menuLoopP

selectDoneP:
    
    ; ( 0 = resume)   , ( 1 = exit ) 

    cmp selectedIndex2,0
    je endMenuP                                                 ; resume game

    cmp selectedIndex2,1
    exit

EndMenuP:
    ret

PauseControl ENDP

; =================================================================================
; =================================================================================
; =================================================================================
; =================================================================================
;                                    LEVEL MAP
; =================================================================================
; =================================================================================
; =================================================================================
; =================================================================================

InitializeLevel PROC
    
    push edi
    push ecx
    mov edi, OFFSET Levelmap
    mov ecx, 1800
    mov al, 0
    rep stosb
    pop ecx
    pop edi

    mov al, currentLevel
    
    cmp al, 1
    je InitLevel1
    cmp al, 2
    je InitLevel2     
    cmp al, 3
    je InitLevel3      
    
   
    cmp al, 4
    je LevelMap2
    cmp al, 5
    je LevelMap2
    cmp al, 6
    je LevelMap2
    
    ret

LevelMap2:
    call InitializeLevel2 
    ret

InitLevel1:
    
    
    mov edi, OFFSET Levelmap
    add edi, 1710             
    mov ecx, 90
    mov al, 1                     ; Ground tile
    fillGround:
        mov [edi], al
        inc edi
    loop fillGround

    mov edi, offset levelmap
    mov ecx, 90
    mov al, 1
    fillabove:
        mov [edi], al
        inc edi
        loop fillabove

    mov edi, offset levelmap
    add edi, 0
    mov ecx, 20
    mov al, 1
    fillleft:
        mov [edi], al
        add edi, 90
        loop fillleft

    mov edi, offset levelmap
    add edi, 1
    mov ecx, 20
    mov al, 1
    fillleft1:
        mov [edi], al
        add edi, 90
        loop fillleft1

    mov edi, offset levelmap
    add edi, 2
    mov ecx, 20
    mov al, 1
    fillleft2:
        mov [edi], al
        add edi, 90
        loop fillleft2

    
    mov edi, offset levelmap
    add edi, 87
    mov ecx, 20
    mov al, 1
    fillright:
        mov [edi], al
        add edi, 90
        loop fillright

    mov edi, offset levelmap
    add edi, 88
    mov ecx, 20
    mov al, 1
    fillright1:
        mov [edi], al
        add edi, 90
        loop fillright1

    mov edi, OFFSET Levelmap
    add edi, 89
    mov ecx, 20
    mov al, 1
    fillright2:
        mov [edi], al
        add edi, 90
        loop fillright2
     
    ; ------------------------------------- COINS -------------------------------
    mov edi, OFFSET Levelmap
    add edi, 1430                
    mov ecx, 4
    mov al, 5
    tiloop1:
        mov [edi], al
        inc edi
        loop tiloop1

    mov edi, OFFSET Levelmap
    add edi, 1230
    mov ecx, 4
    mov al, 5
    tiloop11:
        mov [edi], al
        inc edi
        loop tiloop11
    
    ; ------------------------------------ QUESTION -------------------------------
    mov edi, OFFSET Levelmap
    add edi, 1378
    mov ecx, 5
    mov al, 3
    tiloop2:
        mov [edi], al
        inc edi
        loop tiloop2
     
    mov edi, OFFSET Levelmap
    add edi, 1277                  
    mov ecx, 4
    mov al, 3
    tiloop6:
        mov [edi], al
        inc edi
        loop tiloop6
    ; ------------------------------------ BRICKS --------------------------------------
    mov edi, OFFSET Levelmap
    add edi, 1540                 
    mov ecx, 4
    mov al, 2
    tiloop3:
        mov [edi], al
        inc edi
        loop tiloop3
     
    mov edi, OFFSET Levelmap
    add edi, 1090
    mov ecx, 4
    mov al, 2
    tiloop4:
        mov [edi], al
        inc edi
        loop tiloop4

    mov edi, OFFSET Levelmap
    add edi, 999                 
    mov ecx, 5
    mov al, 2
    tiloop5:
        mov [edi], al
        inc edi
        loop tiloop5

     
    ; ------------------------------------ PIPES -----------------------------------
    mov edi, OFFSET Levelmap
    add edi, 1387             
    mov ecx, 4
    mov al, 4
    tiloop7:
        mov [edi], al
        inc edi
        loop tiloop7
     
    
    mov edi, OFFSET Levelmap
    add edi, 765                    
    mov ecx, 6
    mov al, 2
    tiloop10:
        mov [edi], al
        inc edi
        loop tiloop10

    add edi, 85                    
    mov ecx, 4
    mov al, 2
    tiloop12:
        mov [edi], al
        inc edi
        loop tiloop12
    
    
    add edi, 50                    
    mov ecx, 4
    mov al, 2
    tiloop13:
        mov [edi], al
        inc edi
        loop tiloop13
    
    mov edi, offset levelmap
    add edi, (18*90) + 65
    mov al, 3
    mov ecx, 5
    l1:
        mov [edi], al
        inc edi
        loop l1

    mov edi, offset levelmap
    add edi, (17*90) + 66
    mov al, 3
    mov ecx, 3
    l2:
        mov [edi], al
        inc edi
        loop l2

    mov edi, offset levelmap
    add edi, (16*90) + 67
    mov al, 3
    mov ecx, 1
    l3:
        mov [edi], al
        inc edi
        loop l3


    mov edi, offset levelmap
    add edi, (18*90) + 45
    mov al, 3
    mov ecx, 5
    l5:
        mov [edi], al
        inc edi
        loop l5


    mov edi, offset levelmap
    add edi, (17*90) + 46
    mov al, 3
    mov ecx, 3
    l6:
        mov [edi], al
        inc edi
        loop l6

    mov edi, offset levelmap
    add edi, (16*90) + 47
    mov al, 3
    mov ecx, 1
    l7:
        mov [edi], al
        inc edi
        loop l7

    
    mov edi, offset levelmap
    add edi, (18*90) + 25
    mov al, 3
    mov ecx, 5
    l8:
        mov [edi], al
        inc edi
        loop l8


    mov edi, offset levelmap
    add edi, (17*90) + 26
    mov al, 3
    mov ecx, 3
    l9:
        mov [edi], al
        inc edi
        loop l9

    mov edi, offset levelmap
    add edi, (16*90) + 27
    mov al, 3
    mov ecx, 1
    l10:
        mov [edi], al
        inc edi
        loop l10

    mov edi, offset levelmap
    add edi, (13*90) + 77   
    mov BYTE PTR [edi], 5  

    mov edi, offset levelmap
    add edi, (13*90) + 78
    mov al, 2               
    mov ecx, 4
sMoved1:
    mov [edi], al
    inc edi
    loop sMoved1

    mov edi, offset levelmap
    add edi, (14*90) + 78
    mov al, 2
    mov ecx, 1
sMoved2:
    mov [edi], al
    inc edi
    loop sMoved2

    mov edi, offset levelmap
    add edi, (15*90) + 78
    mov al, 2
    mov ecx, 4
sMoved3:
    mov [edi], al
    inc edi
    loop sMoved3

    mov edi, offset levelmap
    add edi, (16*90) + 81
    mov al, 2
    mov ecx, 1
sMoved4:
    mov [edi], al
    inc edi
    loop sMoved4
    
    mov edi, offset levelmap
    add edi, (17*90) + 78
    mov al, 2
    mov ecx, 4
sMoved5:
    mov [edi], al
    inc edi
    loop sMoved5

    mov edi, offset levelmap
    add edi, (17*90) + 82   
    mov BYTE PTR [edi], 5   

    mov edi, offset levelmap
    add edi, (8*90) + 39    
    mov BYTE PTR [edi], 2   
    inc edi
    mov BYTE PTR [edi], 5   
    inc edi
    mov BYTE PTR [edi], 2   

    mov edi, offset levelmap
    add edi, (9*90) + 38    
    mov BYTE PTR [edi], 2   
    inc edi
    mov ecx, 3             
    mov al, 5
diamC1:
    mov [edi], al
    inc edi
    loop diamC1
    mov BYTE PTR [edi], 2   

    mov edi, offset levelmap
    add edi, (10*90) + 37   
    mov BYTE PTR [edi], 2   
    inc edi
    mov ecx, 5              
    mov al, 5
diamC2:
    mov [edi], al
    inc edi
    loop diamC2
    mov BYTE PTR [edi], 2   

    mov edi, offset levelmap
    add edi, (11*90) + 38   
    mov BYTE PTR [edi], 2   
    inc edi
    mov ecx, 3              
    mov al, 5
diamC3:
    mov [edi], al
    inc edi
    loop diamC3
    mov BYTE PTR [edi], 2   
 
    mov edi, offset levelmap
    add edi, (12*90) + 39   
    mov BYTE PTR [edi], 2   
    inc edi
    mov BYTE PTR [edi], 5   
    inc edi
    mov BYTE PTR [edi], 2   

    mov edi, offset levelmap
    add edi, (7*90) + 8
    mov al, 2               
    mov ecx, 4
zTop:
    mov [edi], al
    inc edi
    loop zTop

    mov edi, offset levelmap
    add edi, (6*90) + 8
    mov al, 5               
    mov ecx, 4
zCoins:
    mov [edi], al
    inc edi
    loop zCoins

    mov edi, offset levelmap
    add edi, (8*90) + 11
    mov BYTE PTR [edi], 2   

    mov edi, offset levelmap
    add edi, (9*90) + 11
    mov al, 2
    mov ecx, 4
zBot:
    mov [edi], al
    inc edi
    loop zBot

    mov edi, offset levelmap
    add edi, (5*90) + 60
    mov BYTE PTR [edi], 3   
    
    mov edi, offset levelmap
    add edi, (6*90) + 60
    mov BYTE PTR [edi], 3
  
    mov edi, offset levelmap
    add edi, (5*90) + 64
    mov BYTE PTR [edi], 3
   
    mov edi, offset levelmap
    add edi, (6*90) + 64
    mov BYTE PTR [edi], 3

    mov edi, offset levelmap
    add edi, (7*90) + 60
    mov al, 3
    mov ecx, 5
uBase:
    mov [edi], al
    inc edi
    loop uBase
  
    mov edi, offset levelmap
    add edi, (6*90) + 61
    mov al, 5               
    mov ecx, 3
    uCoins:
    mov [edi], al
    inc edi
        loop uCoins

    mov edi, offset levelmap
    add edi, (16*90) + 35
    mov BYTE PTR [edi], 2  
    
    mov edi, offset levelmap
    add edi, (15*90) + 35
    mov BYTE PTR [edi], 2  

    mov edi, offset levelmap
    add edi, (14*90) + 35
    mov BYTE PTR [edi], 5   

    mov edi, offset levelmap
    add edi, (16*90) + 54
    mov BYTE PTR [edi], 2   

    mov edi, offset levelmap
    add edi, (15*90) + 54
    mov BYTE PTR [edi], 2   

    mov edi, offset levelmap
    add edi, (14*90) + 54
    mov BYTE PTR [edi], 5 
    
        ; ------------------------   ------------ CLOUDSs  ------------------ --------------------
    
    
    mov edi, OFFSET Levelmap
    add edi, (5*90) + 15        
    mov BYTE PTR [edi], 6     
    inc edi
    mov BYTE PTR [edi], 6

    mov edi, OFFSET Levelmap
    add edi, (6*90) + 14        
    mov ecx, 4
    drawC3:
        mov BYTE PTR [edi], 6
        inc edi
        loop drawC3

   
    mov edi, OFFSET Levelmap
    add edi, (3*90) + 68
    mov BYTE PTR [edi], 6
    inc edi
    mov BYTE PTR [edi], 6

   
    mov edi, OFFSET Levelmap
    add edi, (4*90) + 67
    mov ecx, 4  
    drawC4:
        mov BYTE PTR [edi], 6
        inc edi
        loop drawC4


    ret

InitLevel2:
    
    mov edi, OFFSET Levelmap
    add edi, 1710
    mov ecx, 90
    mov al, 1
    fillGround2:
        mov [edi], al
        inc edi
    loop fillGround2

    
    mov edi, offset levelmap
    mov ecx, 90
    mov al, 1
    fillabove2:
        mov [edi], al
        inc edi
    loop fillabove2

    mov edi, offset levelmap
    mov ecx, 20
    mov al, 1
    fillleft2a:
        mov [edi], al
        add edi, 90
    loop fillleft2a

    mov edi, offset levelmap
    add edi, 1
    mov ecx, 20
    mov al, 1
    fillleft2b:
        mov [edi], al
        add edi, 90
    loop fillleft2b

    mov edi, offset levelmap
    add edi, 2
    mov ecx, 20
    mov al, 1
    fillleft2c:
        mov [edi], al
        add edi, 90
    loop fillleft2c

    mov edi, offset levelmap
    add edi, 87
    mov ecx, 20
    mov al, 1
    fillright2a:
        mov [edi], al
        add edi, 90
    loop fillright2a

    mov edi, offset levelmap
    add edi, 88
    mov ecx, 20
    mov al, 1
    fillright2b:
        mov [edi], al
        add edi, 90
    loop fillright2b

    mov edi, OFFSET Levelmap
    add edi, 89
    mov ecx, 20
    mov al, 1
    fillright2c:
        mov [edi], al
        add edi, 90
    loop fillright2c

        ; ------------------------   ------------ CLOUDSs  ------------------ --------------------
    
    
    mov edi, OFFSET Levelmap
    add edi, (5*90) + 15        
    mov BYTE PTR [edi], 6     
    inc edi
    mov BYTE PTR [edi], 6

    mov edi, OFFSET Levelmap
    add edi, (6*90) + 14        
    mov ecx, 4
    drawC1:
        mov BYTE PTR [edi], 6
        inc edi
        loop drawC1

   
    
   
    mov edi, OFFSET Levelmap
    add edi, (3*90) + 66
    mov BYTE PTR [edi], 6
    inc edi
    mov BYTE PTR [edi], 6

   
    mov edi, OFFSET Levelmap
    add edi, (4*90) + 65
    mov ecx, 4  
    drawC2:
        mov BYTE PTR [edi], 6
        inc edi
        loop drawC2

    ; ------------------------   ------------ bricks  ------------------ --------------------
    mov edi, OFFSET Levelmap
    add edi, (15*90) + 10
    mov al, 2
    mov ecx, 8
    platform2_1:
        mov [edi], al
        inc edi
    loop platform2_1

    mov edi, OFFSET Levelmap
    add edi, (12*90) + 22
    mov al, 2
    mov ecx, 6
    platform2_2:
        mov [edi], al
        inc edi
    loop platform2_2

    mov edi, OFFSET Levelmap
    add edi, (10*90) + 35
    mov al, 2
    mov ecx, 10
    platform2_3:
        mov [edi], al
        inc edi
    loop platform2_3

    mov edi, OFFSET Levelmap
    add edi, (13*90) + 50
    mov al, 2
    mov ecx, 8
    platform2_4:
        mov [edi], al
        inc edi
    loop platform2_4

    mov edi, OFFSET Levelmap
    add edi, (16*90) + 62
    mov al, 2
    mov ecx, 6
    platform2_5:
        mov [edi], al
        inc edi
    loop platform2_5

    ; ------------------------   ------------ COINS  ------------------ --------------------
    mov edi, OFFSET Levelmap
    add edi, (14*90) + 13
    mov al, 5
    mov ecx, 3
    coins2_1:
        mov [edi], al
        inc edi
    loop coins2_1

    mov edi, OFFSET Levelmap
    add edi, (11*90) + 24
    mov al, 5
    mov ecx, 4
    coins2_2:
        mov [edi], al
        inc edi
    loop coins2_2

    mov edi, OFFSET Levelmap
    add edi, (9*90) + 38
    mov al, 5
    mov ecx, 6
    coins2_3:
        mov [edi], al
        inc edi
    loop coins2_3

    mov edi, OFFSET Levelmap
    add edi, (12*90) + 53
    mov al, 5
    mov ecx, 4
    coins2_4:
        mov [edi], al
        inc edi
    loop coins2_4

   ; ------------------------   ------------ QUESTION  ------------------ --------------------
    mov edi, OFFSET Levelmap
    add edi, (14*90) + 30
    mov BYTE PTR [edi], 3
    add edi, 3
    mov BYTE PTR [edi], 3
    add edi, 3
    mov BYTE PTR [edi], 3

    ; ------------------------   ------------ PIPES  ------------------ --------------------
    mov edi, OFFSET Levelmap
    add edi, (17*90) + 45
    mov BYTE PTR [edi], 4
    mov edi, OFFSET Levelmap
    add edi, (18*90) + 45
    mov BYTE PTR [edi], 4

    mov edi, OFFSET Levelmap
    add edi, (17*90) + 70
    mov BYTE PTR [edi], 4
    mov edi, OFFSET Levelmap
    add edi, (18*90) + 70
    mov BYTE PTR [edi], 4

    
    mov edi, OFFSET Levelmap
    add edi, (18*90) + 75
    mov BYTE PTR [edi], 2
    
    mov edi, OFFSET Levelmap
    add edi, (17*90) + 76
    mov al, 2
    mov ecx, 2
    stair2_1:
        mov [edi], al
        inc edi
    loop stair2_1

    mov edi, OFFSET Levelmap
    add edi, (16*90) + 78
    mov al, 2
    mov ecx, 3
    stair2_2:
        mov [edi], al
        inc edi
    loop stair2_2

    ret

InitLevel3:
    
    mov edi, OFFSET Levelmap
    add edi, (14*90) + 40   
    mov BYTE PTR [edi], 9    

    mov edi, OFFSET Levelmap
    add edi, 1710
    mov ecx, 90
    mov al, 1
    fillGround3:
        mov [edi], al
        inc edi
    loop fillGround3

    
    mov edi, offset levelmap
    mov ecx, 90
    mov al, 1
    fillabove3:
        mov [edi], al
        inc edi
    loop fillabove3

    mov edi, offset levelmap
    mov ecx, 20
    mov al, 1
    fillleft3a:
        mov [edi], al
        add edi, 90
    loop fillleft3a

    mov edi, offset levelmap
    add edi, 1
    mov ecx, 20
    mov al, 1
    fillleft3b:
        mov [edi], al
        add edi, 90
    loop fillleft3b

    mov edi, offset levelmap
    add edi, 2
    mov ecx, 20
    mov al, 1
    fillleft3c:
        mov [edi], al
        add edi, 90
    loop fillleft3c

    mov edi, offset levelmap
    add edi, 87
    mov ecx, 20
    mov al, 1
    fillright3a:
        mov [edi], al
        add edi, 90
    loop fillright3a

    mov edi, offset levelmap
    add edi, 88
    mov ecx, 20
    mov al, 1
    fillright3b:
        mov [edi], al
        add edi, 90
    loop fillright3b

    mov edi, OFFSET Levelmap
    add edi, 89
    mov ecx, 20
    mov al, 1
    fillright3c:
        mov [edi], al
        add edi, 90
    loop fillright3c

    
    mov edi, OFFSET Levelmap
    add edi, (16*90) + 8
    mov al, 2
    mov ecx, 5
    platform3_1:
        mov [edi], al
        inc edi
    loop platform3_1

    mov edi, OFFSET Levelmap
    add edi, (13*90) + 15
    mov al, 2
    mov ecx, 4
    platform3_2:
        mov [edi], al
        inc edi
    loop platform3_2

    mov edi, OFFSET Levelmap
    add edi, (10*90) + 23
    mov al, 2
    mov ecx, 7
    platform3_3:
        mov [edi], al
        inc edi
    loop platform3_3

    mov edi, OFFSET Levelmap
    add edi, (14*90) + 33
    mov al, 2
    mov ecx, 5
    platform3_4:
        mov [edi], al
        inc edi
    loop platform3_4

    mov edi, OFFSET Levelmap
    add edi, (11*90) + 42
    mov al, 2
    mov ecx, 6
    platform3_5:
        mov [edi], al
        inc edi
    loop platform3_5

    mov edi, OFFSET Levelmap
    add edi, (15*90) + 52
    mov al, 2
    mov ecx, 8
    platform3_6:
        mov [edi], al
        inc edi
    loop platform3_6

    mov edi, OFFSET Levelmap
    add edi, (12*90) + 63
    mov al, 2
    mov ecx, 5
    platform3_7:
        mov [edi], al
        inc edi
    loop platform3_7

    mov edi, OFFSET Levelmap
    add edi, (17*90) + 73
    mov al, 2
    mov ecx, 10
    platform3_8:
        mov [edi], al
        inc edi
    loop platform3_8

   ; ------------------------   ------------ COINS  ------------------ --------------------
    mov edi, OFFSET Levelmap
    add edi, (15*90) + 10
    mov al, 5
    mov ecx, 3
    coins3_1:
        mov [edi], al
        inc edi
    loop coins3_1

    mov edi, OFFSET Levelmap
    add edi, (12*90) + 17
    mov al, 5
    mov ecx, 2
    coins3_2:
        mov [edi], al
        inc edi
    loop coins3_2

    mov edi, OFFSET Levelmap
    add edi, (9*90) + 25
    mov al, 5
    mov ecx, 5
    coins3_3:
        mov [edi], al
        inc edi
    loop coins3_3

    mov edi, OFFSET Levelmap
    add edi, (13*90) + 35
    mov al, 5
    mov ecx, 3
    coins3_4:
        mov [edi], al
        inc edi
    loop coins3_4

    mov edi, OFFSET Levelmap
    add edi, (10*90) + 45
    mov al, 5
    mov ecx, 4
    coins3_5:
        mov [edi], al
        inc edi
    loop coins3_5

    mov edi, OFFSET Levelmap
    add edi, (14*90) + 55
    mov al, 5
    mov ecx, 5
    coins3_6:
        mov [edi], al
        inc edi
    loop coins3_6

    mov edi, OFFSET Levelmap
    add edi, (11*90) + 65
    mov al, 5
    mov ecx, 3
    coins3_7:
        mov [edi], al
        inc edi
    loop coins3_7

    mov edi, OFFSET Levelmap
    add edi, (16*90) + 76
    mov al, 5
    mov ecx, 6
    coins3_8:
        mov [edi], al
        inc edi
    loop coins3_8

    ; ------------------------   ------------ QUESTION  ------------------ --------------------
    mov edi, OFFSET Levelmap
    add edi, (14*90) + 20
    mov BYTE PTR [edi], 3

    mov edi, OFFSET Levelmap
    add edi, (11*90) + 38
    mov BYTE PTR [edi], 3

    mov edi, OFFSET Levelmap
    add edi, (13*90) + 48
    mov BYTE PTR [edi], 3

    mov edi, OFFSET Levelmap
    add edi, (10*90) + 58
    mov BYTE PTR [edi], 3

    ; ------------------------   ----------- PIPES  ------------------ --------------------
    mov edi, OFFSET Levelmap
    add edi, (17*90) + 30
    mov BYTE PTR [edi], 4
    mov edi, OFFSET Levelmap
    add edi, (18*90) + 30
    mov BYTE PTR [edi], 4

    mov edi, OFFSET Levelmap
    add edi, (17*90) + 55
    mov BYTE PTR [edi], 4
    mov edi, OFFSET Levelmap
    add edi, (18*90) + 55
    mov BYTE PTR [edi], 4

        ; ------------------------   ------------ CLOUDSs  ------------------ --------------------
    
    
    mov edi, OFFSET Levelmap
    add edi, (5*90) + 15        
    mov BYTE PTR [edi], 6     
    inc edi
    mov BYTE PTR [edi], 6

    mov edi, OFFSET Levelmap
    add edi, (6*90) + 14        
    mov ecx, 4
    drawC5:
        mov BYTE PTR [edi], 6
        inc edi
        loop drawC5

   
    
   
    mov edi, OFFSET Levelmap
    add edi, (3*90) + 61
    mov BYTE PTR [edi], 6
    inc edi
    mov BYTE PTR [edi], 6

   
    mov edi, OFFSET Levelmap
    add edi, (4*90) + 60
    mov ecx, 4  
    drawC6:
        mov BYTE PTR [edi], 6
        inc edi
        loop drawC6


    ret

InitializeLevel ENDP

;-------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------
;-----------------------------         LEVLE MAP-2             -----------------------
;-------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------


InitializeLevel2 PROC
    
    push edi
    push ecx
    mov edi, OFFSET Levelmap
    mov ecx, 1800
    mov al, 0
    rep stosb
    pop ecx
    pop edi

    mov al, currentLevel
    call nextmap
    
    cmp al, 1
    je Level1
    cmp al, 2
    je Level2
    cmp al, 3
    je Level3
    
    cmp al, 4
    je Level1    
    
    cmp al, 5
    je Level2 
    
    cmp al, 6
    je Level3  
    
    ret

clearMap1:
    mov [edi], al
    inc edi
    loop clearMap1
    pop ecx
    pop edi

    mov al, currentLevel
    cmp al, 4
    je Level1
    cmp al, 5
    je Level2
    cmp al, 6
    je Level3
    ret

Level1:
   
    mov edi, OFFSET Levelmap
    add edi, (12*90) + 50
    mov BYTE PTR [edi], 9
    
    mov edi, OFFSET Levelmap
    add edi, (17*90) + 85   
    mov BYTE PTR [edi], 8

    mov edi, OFFSET Levelmap
    add edi, 1710             
    mov ecx, 90
    mov al, 1                     ; Ground tile
    fillGround1:
        mov [edi], al
        inc edi
    loop fillGround1

    mov edi, offset levelmap
    mov ecx, 90
    mov al, 1
    fillabove1:
        mov [edi], al
        inc edi
        loop fillabove1

    mov edi, offset levelmap
    add edi, 0
    mov ecx, 20
    mov al, 1
    l1:
        mov [edi], al
        add edi, 90
        loop l1

    mov edi, offset levelmap
    add edi, 1
    mov ecx, 20
    mov al, 1
    l2:
        mov [edi], al
        add edi, 90
        loop l2

    mov edi, offset levelmap
    add edi, 2
    mov ecx, 20
    mov al, 1
    l3:
        mov [edi], al
        add edi, 90
        loop l3

    
    mov edi, offset levelmap
    add edi, 87
    mov ecx, 20
    mov al, 1
    l4:
        mov [edi], al
        add edi, 90
        loop l4

    mov edi, offset levelmap
    add edi, 88
    mov ecx, 20
    mov al, 1
    l5:
        mov [edi], al
        add edi, 90
        loop l5

    mov edi, OFFSET Levelmap
    add edi, 89
    mov ecx, 20
    mov al, 1
    l6:
        mov [edi], al
        add edi, 90
        loop l6
     
    ; ------------------------------------- COINS -------------------------------
    mov edi, OFFSET Levelmap
    add edi, 1430                
    mov ecx, 4
    mov al, 5
    l7:
        mov [edi], al
        inc edi
        loop l7

    mov edi, OFFSET Levelmap
    add edi, 1230
    mov ecx, 4
    mov al, 5
    l8:
        mov [edi], al
        inc edi
        loop l8
    
    ; ------------------------------------ QUESTION -------------------------------
    mov edi, OFFSET Levelmap
    add edi, 1378
    mov ecx, 5
    mov al, 3
    l9:
        mov [edi], al
        inc edi
        loop l9
     
    mov edi, OFFSET Levelmap
    add edi, 1277                  
    mov ecx, 4
    mov al, 3
    l10:
        mov [edi], al
        inc edi
        loop l10
    ; ------------------------------------ BRICKS --------------------------------------
    mov edi, OFFSET Levelmap
    add edi, 1540                 
    mov ecx, 4
    mov al, 2
    l11:
        mov [edi], al
        inc edi
        loop l11
     
    mov edi, OFFSET Levelmap
    add edi, 1090
    mov ecx, 4
    mov al, 2
    l12:
        mov [edi], al
        inc edi
        loop l12

    mov edi, OFFSET Levelmap
    add edi, 999                 
    mov ecx, 5
    mov al, 2
    l13:
        mov [edi], al
        inc edi
        loop l13

     
    ; ------------------------------------ PIPES -----------------------------------
    mov edi, OFFSET Levelmap
    add edi, 1387             
    mov ecx, 4
    mov al, 4
    l14:
        mov [edi], al
        inc edi
        loop l14
     
    
    mov edi, OFFSET Levelmap
    add edi, 765                    
    mov ecx, 6
    mov al, 2
    l15:
        mov [edi], al
        inc edi
        loop l15

    add edi, 85                    
    mov ecx, 4
    mov al, 2
    l29:
        mov [edi], al
        inc edi
        loop l29
    
    
    add edi, 50                    
    mov ecx, 4
    mov al, 2
    l16:
        mov [edi], al
        inc edi
        loop l16
    
    mov edi, offset levelmap
    add edi, (18*90) + 65
    mov al, 3
    mov ecx, 5
    l17:
        mov [edi], al
        inc edi
        loop l17

    mov edi, offset levelmap
    add edi, (17*90) + 66
    mov al, 3
    mov ecx, 3
    l18:
        mov [edi], al
        inc edi
        loop l18

    mov edi, offset levelmap
    add edi, (16*90) + 67
    mov al, 3
    mov ecx, 1
    l19:
        mov [edi], al
        inc edi
        loop l19


    mov edi, offset levelmap
    add edi, (18*90) + 45
    mov al, 3
    mov ecx, 5
    l20:
        mov [edi], al
        inc edi
        loop l20


    mov edi, offset levelmap
    add edi, (17*90) + 46
    mov al, 3
    mov ecx, 3
    l21:
        mov [edi], al
        inc edi
        loop l21

    mov edi, offset levelmap
    add edi, (16*90) + 47
    mov al, 3
    mov ecx, 1
    l22:
        mov [edi], al
        inc edi
        loop l22

    
    mov edi, offset levelmap
    add edi, (18*90) + 25
    mov al, 3
    mov ecx, 5
    l23:
        mov [edi], al
        inc edi
        loop l23


    mov edi, offset levelmap
    add edi, (17*90) + 26
    mov al, 3
    mov ecx, 3
    l24:
        mov [edi], al
        inc edi
        loop l24

    mov edi, offset levelmap
    add edi, (16*90) + 27
    mov al, 3
    mov ecx, 1
    l25:
        mov [edi], al
        inc edi
        loop l25

    mov edi, offset levelmap
    add edi, (13*90) + 77   
    mov BYTE PTR [edi], 5  

    mov edi, offset levelmap
    add edi, (13*90) + 78
    mov al, 2               
    mov ecx, 4
sMoved11:
    mov [edi], al
    inc edi
    loop sMoved11

    mov edi, offset levelmap
    add edi, (14*90) + 78
    mov al, 2
    mov ecx, 1
sMoved22:
    mov [edi], al
    inc edi
    loop sMoved22

    mov edi, offset levelmap
    add edi, (15*90) + 78
    mov al, 2
    mov ecx, 4
sMoved33:
    mov [edi], al
    inc edi
    loop sMoved33

    mov edi, offset levelmap
    add edi, (16*90) + 81
    mov al, 2
    mov ecx, 1
sMoved43:
    mov [edi], al
    inc edi
    loop sMoved43
    
    mov edi, offset levelmap
    add edi, (17*90) + 78
    mov al, 2
    mov ecx, 4
sMoved53:
    mov [edi], al
    inc edi
    loop sMoved53

    mov edi, offset levelmap
    add edi, (17*90) + 82   
    mov BYTE PTR [edi], 5   

    mov edi, offset levelmap
    add edi, (8*90) + 39    
    mov BYTE PTR [edi], 2   
    inc edi
    mov BYTE PTR [edi], 5   
    inc edi
    mov BYTE PTR [edi], 2   

    mov edi, offset levelmap
    add edi, (9*90) + 38    
    mov BYTE PTR [edi], 2   
    inc edi
    mov ecx, 3             
    mov al, 5
diamC13:
    mov [edi], al
    inc edi
    loop diamC13
    mov BYTE PTR [edi], 2   

    mov edi, offset levelmap
    add edi, (10*90) + 37   
    mov BYTE PTR [edi], 2   
    inc edi
    mov ecx, 5              
    mov al, 5
diamC23:
    mov [edi], al
    inc edi
    loop diamC23
    mov BYTE PTR [edi], 2   

    mov edi, offset levelmap
    add edi, (11*90) + 38   
    mov BYTE PTR [edi], 2   
    inc edi
    mov ecx, 3              
    mov al, 5
diamC33:
    mov [edi], al
    inc edi
    loop diamC33
    mov BYTE PTR [edi], 2   
 
    mov edi, offset levelmap
    add edi, (12*90) + 39   
    mov BYTE PTR [edi], 2   
    inc edi
    mov BYTE PTR [edi], 5   
    inc edi
    mov BYTE PTR [edi], 2   

    mov edi, offset levelmap
    add edi, (7*90) + 8
    mov al, 2               
    mov ecx, 4
zTop1:
    mov [edi], al
    inc edi
    loop zTop1

    mov edi, offset levelmap
    add edi, (6*90) + 8
    mov al, 5               
    mov ecx, 4
zCoins1:
    mov [edi], al
    inc edi
    loop zCoins1

    mov edi, offset levelmap
    add edi, (8*90) + 11
    mov BYTE PTR [edi], 2   

    mov edi, offset levelmap
    add edi, (9*90) + 11
    mov al, 2
    mov ecx, 4
zBot1:
    mov [edi], al
    inc edi
    loop zBot1

    mov edi, offset levelmap
    add edi, (5*90) + 60
    mov BYTE PTR [edi], 3   
    
    mov edi, offset levelmap
    add edi, (6*90) + 60
    mov BYTE PTR [edi], 3
  
    mov edi, offset levelmap
    add edi, (5*90) + 64
    mov BYTE PTR [edi], 3
   
    mov edi, offset levelmap
    add edi, (6*90) + 64
    mov BYTE PTR [edi], 3

    mov edi, offset levelmap
    add edi, (7*90) + 60
    mov al, 3
    mov ecx, 5
uBase1:
    mov [edi], al
    inc edi
    loop uBase1
  
    mov edi, offset levelmap
    add edi, (6*90) + 61
    mov al, 5               
    mov ecx, 3
    uCoins1:
    mov [edi], al
    inc edi
        loop uCoins1

    mov edi, offset levelmap
    add edi, (16*90) + 35
    mov BYTE PTR [edi], 2  
    
    mov edi, offset levelmap
    add edi, (15*90) + 35
    mov BYTE PTR [edi], 2  

    mov edi, offset levelmap
    add edi, (14*90) + 35
    mov BYTE PTR [edi], 5   

    mov edi, offset levelmap
    add edi, (16*90) + 54
    mov BYTE PTR [edi], 2   

    mov edi, offset levelmap
    add edi, (15*90) + 54
    mov BYTE PTR [edi], 2   

    mov edi, offset levelmap
    add edi, (14*90) + 54
    mov BYTE PTR [edi], 5 
    
        ; ------------------------   ------------ CLOUDSs  ------------------ --------------------
    
    
    mov edi, OFFSET Levelmap
    add edi, (5*90) + 15        
    mov BYTE PTR [edi], 6     
    inc edi
    mov BYTE PTR [edi], 6

    mov edi, OFFSET Levelmap
    add edi, (6*90) + 14        
    mov ecx, 4
    drawC31:
        mov BYTE PTR [edi], 6
        inc edi
        loop drawC31

   
    mov edi, OFFSET Levelmap
    add edi, (3*90) + 68
    mov BYTE PTR [edi], 6
    inc edi
    mov BYTE PTR [edi], 6

   
    mov edi, OFFSET Levelmap
    add edi, (4*90) + 67
    mov ecx, 4  
    drawC41:
        mov BYTE PTR [edi], 6
        inc edi
        loop drawC41


    ret

Level2:
    
    mov edi, OFFSET Levelmap
    add edi, (10*90) + 20
    mov BYTE PTR [edi], 9
    
    mov edi, OFFSET Levelmap
    add edi, 1710
    mov ecx, 90
    mov al, 1
    fillGround21:
        mov [edi], al
        inc edi
    loop fillGround21

    
    mov edi, offset levelmap
    mov ecx, 90
    mov al, 1
    fillabove21:
        mov [edi], al
        inc edi
    loop fillabove21

    mov edi, offset levelmap
    mov ecx, 20
    mov al, 1
    fillleft2a1:
        mov [edi], al
        add edi, 90
    loop fillleft2a1

    mov edi, offset levelmap
    add edi, 1
    mov ecx, 20
    mov al, 1
    fillleft2b1:
        mov [edi], al
        add edi, 90
    loop fillleft2b1

    mov edi, offset levelmap
    add edi, 2
    mov ecx, 20
    mov al, 1
    fillleft2c1:
        mov [edi], al
        add edi, 90
    loop fillleft2c1

    mov edi, offset levelmap
    add edi, 87
    mov ecx, 20
    mov al, 1
    fillright2a1:
        mov [edi], al
        add edi, 90
    loop fillright2a1

    mov edi, offset levelmap
    add edi, 88
    mov ecx, 20
    mov al, 1
    fillright2b1:
        mov [edi], al
        add edi, 90
    loop fillright2b1

    mov edi, OFFSET Levelmap
    add edi, 89
    mov ecx, 20
    mov al, 1
    fillright2c1:
        mov [edi], al
        add edi, 90
    loop fillright2c1

        ; ------------------------   ------------ CLOUDSs  ------------------ --------------------
    
    
    mov edi, OFFSET Levelmap
    add edi, (5*90) + 15        
    mov BYTE PTR [edi], 6     
    inc edi
    mov BYTE PTR [edi], 6

    mov edi, OFFSET Levelmap
    add edi, (6*90) + 14        
    mov ecx, 4
    drawC11:
        mov BYTE PTR [edi], 6
        inc edi
        loop drawC11

   
    
   
    mov edi, OFFSET Levelmap
    add edi, (3*90) + 66
    mov BYTE PTR [edi], 6
    inc edi
    mov BYTE PTR [edi], 6

   
    mov edi, OFFSET Levelmap
    add edi, (4*90) + 65
    mov ecx, 4  
    drawC21:
        mov BYTE PTR [edi], 6
        inc edi
        loop drawC21

    ; ------------------------   ------------ bricks  ------------------ --------------------
    mov edi, OFFSET Levelmap
    add edi, (15*90) + 10
    mov al, 2
    mov ecx, 8
    platform2_11 :
        mov [edi], al
        inc edi
    loop platform2_11

    mov edi, OFFSET Levelmap
    add edi, (12*90) + 22
    mov al, 2
    mov ecx, 6
    platform2_21:
        mov [edi], al
        inc edi
    loop platform2_21

    mov edi, OFFSET Levelmap
    add edi, (10*90) + 35
    mov al, 2
    mov ecx, 10
    platform2_31:
        mov [edi], al
        inc edi
    loop platform2_31

    mov edi, OFFSET Levelmap
    add edi, (13*90) + 50
    mov al, 2
    mov ecx, 8
    platform2_41:
        mov [edi], al
        inc edi
    loop platform2_41

    mov edi, OFFSET Levelmap
    add edi, (16*90) + 62
    mov al, 2
    mov ecx, 6
    platform2_51:
        mov [edi], al
        inc edi
    loop platform2_51

    ; ------------------------   ------------ COINS  ------------------ --------------------
    mov edi, OFFSET Levelmap
    add edi, (14*90) + 13
    mov al, 5
    mov ecx, 3
    coins2_11:
        mov [edi], al
        inc edi
    loop coins2_11

    mov edi, OFFSET Levelmap
    add edi, (11*90) + 24
    mov al, 5
    mov ecx, 4
    coins2_21:
        mov [edi], al
        inc edi
    loop coins2_21

    mov edi, OFFSET Levelmap
    add edi, (9*90) + 38
    mov al, 5
    mov ecx, 6
    coins2_31:
        mov [edi], al
        inc edi
    loop coins2_31

    mov edi, OFFSET Levelmap
    add edi, (12*90) + 53
    mov al, 5
    mov ecx, 4
    coins2_41:
        mov [edi], al
        inc edi
    loop coins2_41

   ; ------------------------   ------------ QUESTION  ------------------ --------------------
    mov edi, OFFSET Levelmap
    add edi, (14*90) + 30
    mov BYTE PTR [edi], 3
    add edi, 3
    mov BYTE PTR [edi], 3
    add edi, 3
    mov BYTE PTR [edi], 3

    ; ------------------------   ------------ PIPES  ------------------ --------------------
    mov edi, OFFSET Levelmap
    add edi, (17*90) + 45
    mov BYTE PTR [edi], 4
    mov edi, OFFSET Levelmap
    add edi, (18*90) + 45
    mov BYTE PTR [edi], 4

    mov edi, OFFSET Levelmap
    add edi, (17*90) + 70
    mov BYTE PTR [edi], 4
    mov edi, OFFSET Levelmap
    add edi, (18*90) + 70
    mov BYTE PTR [edi], 4

    
    mov edi, OFFSET Levelmap
    add edi, (18*90) + 75
    mov BYTE PTR [edi], 2
    
    mov edi, OFFSET Levelmap
    add edi, (17*90) + 76
    mov al, 2
    mov ecx, 2
    stair2_11:
        mov [edi], al
        inc edi
    loop stair2_11

    mov edi, OFFSET Levelmap
    add edi, (16*90) + 78
    mov al, 2
    mov ecx, 3
    stair2_21:
        mov [edi], al
        inc edi
    loop stair2_21

    mov edi, OFFSET Levelmap
    add edi, (16*90) + 47   
    mov BYTE PTR [edi], 7
    
    mov edi, OFFSET Levelmap
    add edi, (13*90) + 80   
    mov BYTE PTR [edi], 8


    ret

Level3:
    
    mov edi, OFFSET Levelmap
    add edi, (8*90) + 60  
    mov BYTE PTR [edi], 9

    mov edi, OFFSET Levelmap
    add edi, 1710
    mov ecx, 90
    mov al, 1
    fillGround31:
        mov [edi], al
        inc edi
    loop fillGround31

    
    mov edi, offset levelmap
    mov ecx, 90
    mov al, 1
    fillabove31:
        mov [edi], al
        inc edi
    loop fillabove31

    mov edi, offset levelmap
    mov ecx, 20
    mov al, 1
    fillleft3a1:
        mov [edi], al
        add edi, 90
    loop fillleft3a1

    mov edi, offset levelmap
    add edi, 1
    mov ecx, 20
    mov al, 1
    fillleft3b1:
        mov [edi], al
        add edi, 90
    loop fillleft3b1

    mov edi, offset levelmap
    add edi, 2
    mov ecx, 20
    mov al, 1
    fillleft3c1:
        mov [edi], al
        add edi, 90
    loop fillleft3c1

    mov edi, offset levelmap
    add edi, 87
    mov ecx, 20
    mov al, 1
    fillright3a1:
        mov [edi], al
        add edi, 90
    loop fillright3a1

    mov edi, offset levelmap
    add edi, 88
    mov ecx, 20
    mov al, 1
    fillright3b1:
        mov [edi], al
        add edi, 90
    loop fillright3b1

    mov edi, OFFSET Levelmap
    add edi, 89
    mov ecx, 20
    mov al, 1
    fillright3c1:
        mov [edi], al
        add edi, 90
    loop fillright3c1

    
    mov edi, OFFSET Levelmap
    add edi, (16*90) + 8
    mov al, 2
    mov ecx, 5
    platform3_11:
        mov [edi], al
        inc edi
    loop platform3_11

    mov edi, OFFSET Levelmap
    add edi, (13*90) + 15
    mov al, 2
    mov ecx, 4
    platform3_21:
        mov [edi], al
        inc edi
    loop platform3_21

    mov edi, OFFSET Levelmap
    add edi, (10*90) + 23
    mov al, 2
    mov ecx, 7
    platform3_31:
        mov [edi], al
        inc edi
    loop platform3_31

    mov edi, OFFSET Levelmap
    add edi, (14*90) + 33
    mov al, 2
    mov ecx, 5
    platform3_41:
        mov [edi], al
        inc edi
    loop platform3_41

    mov edi, OFFSET Levelmap
    add edi, (11*90) + 42
    mov al, 2
    mov ecx, 6
    platform3_51:
        mov [edi], al
        inc edi
    loop platform3_51

    mov edi, OFFSET Levelmap
    add edi, (15*90) + 52
    mov al, 2
    mov ecx, 8
    platform3_16:
        mov [edi], al
        inc edi
    loop platform3_16

    mov edi, OFFSET Levelmap
    add edi, (12*90) + 63
    mov al, 2
    mov ecx, 5
    platform3_71:
        mov [edi], al
        inc edi
    loop platform3_71

    mov edi, OFFSET Levelmap
    add edi, (17*90) + 73
    mov al, 2
    mov ecx, 10
    platform3_81:
        mov [edi], al
        inc edi
    loop platform3_81

   ; ------------------------   ------------ COINS  ------------------ --------------------
    mov edi, OFFSET Levelmap
    add edi, (15*90) + 10
    mov al, 5
    mov ecx, 3
    coins3_11:
        mov [edi], al
        inc edi
    loop coins3_11

    mov edi, OFFSET Levelmap
    add edi, (12*90) + 17
    mov al, 5
    mov ecx, 2
    coins3_211:
        mov [edi], al
        inc edi
    loop coins3_211

    mov edi, OFFSET Levelmap
    add edi, (9*90) + 25
    mov al, 5
    mov ecx, 5
    coins3_13:
        mov [edi], al
        inc edi
    loop coins3_13

    mov edi, OFFSET Levelmap
    add edi, (13*90) + 35
    mov al, 5
    mov ecx, 3
    coins3_41:
        mov [edi], al
        inc edi
    loop coins3_41

    mov edi, OFFSET Levelmap
    add edi, (10*90) + 45
    mov al, 5
    mov ecx, 4
    coins3_51:
        mov [edi], al
        inc edi
    loop coins3_51

    mov edi, OFFSET Levelmap
    add edi, (14*90) + 55
    mov al, 5
    mov ecx, 5
    coins3_61:
        mov [edi], al
        inc edi
    loop coins3_61

    mov edi, OFFSET Levelmap
    add edi, (11*90) + 65
    mov al, 5
    mov ecx, 3
    coins3_71:
        mov [edi], al
        inc edi
    loop coins3_71

    mov edi, OFFSET Levelmap
    add edi, (16*90) + 76
    mov al, 5
    mov ecx, 6
    coins31_8:
        mov [edi], al
        inc edi
    loop coins31_8

    ; ------------------------   ------------ QUESTION  ------------------ --------------------
    mov edi, OFFSET Levelmap
    add edi, (14*90) + 20
    mov BYTE PTR [edi], 3

    mov edi, OFFSET Levelmap
    add edi, (11*90) + 38
    mov BYTE PTR [edi], 3

    mov edi, OFFSET Levelmap
    add edi, (13*90) + 48
    mov BYTE PTR [edi], 3

    mov edi, OFFSET Levelmap
    add edi, (10*90) + 58
    mov BYTE PTR [edi], 3

    ; ------------------------   ----------- PIPES  ------------------ --------------------
    mov edi, OFFSET Levelmap
    add edi, (17*90) + 30
    mov BYTE PTR [edi], 4
    mov edi, OFFSET Levelmap
    add edi, (18*90) + 30
    mov BYTE PTR [edi], 4

    mov edi, OFFSET Levelmap
    add edi, (17*90) + 55
    mov BYTE PTR [edi], 4
    mov edi, OFFSET Levelmap
    add edi, (18*90) + 55
    mov BYTE PTR [edi], 4

        ; ------------------------   ------------ CLOUDSs  ------------------ --------------------
    
    
    mov edi, OFFSET Levelmap
    add edi, (5*90) + 15        
    mov BYTE PTR [edi], 6     
    inc edi
    mov BYTE PTR [edi], 6

    mov edi, OFFSET Levelmap
    add edi, (6*90) + 14        
    mov ecx, 4
    drawC51:
        mov BYTE PTR [edi], 6
        inc edi
        loop drawC51

   
    
   
    mov edi, OFFSET Levelmap
    add edi, (3*90) + 61
    mov BYTE PTR [edi], 6
    inc edi
    mov BYTE PTR [edi], 6

   
    mov edi, OFFSET Levelmap
    add edi, (4*90) + 60
    mov ecx, 4  
    drawC61:
        mov BYTE PTR [edi], 6
        inc edi
        loop drawC61

    mov edi, offset Levelmap
    mov ecx, 90
    mov al, 1
    m1:
        mov [edi], al
        inc edi
    loop m1

    mov edi, OFFSET Levelmap
    add edi, 1710
    mov ecx, 90
    mov al, 1
    m2:
        mov [edi], al
        inc edi
    loop m2

    mov edi, offset Levelmap
    mov ecx, 20
    mov al, 1
    m3:
        mov [edi], al
        add edi, 90
    loop m3

    mov edi, offset Levelmap
    add edi, 89
    mov ecx, 20
    mov al, 1
    m4:
        mov [edi], al
        add edi, 90
    loop m4
    
    mov edi, OFFSET Levelmap
    add edi, (17*90) + 4
    mov al, 2
    mov ecx, 4
    m5:
        mov [edi], al
        inc edi
    loop m5

    mov edi, OFFSET Levelmap
    add edi, (16*90) + 10
    mov al, 2
    mov ecx, 4
    m6:
        mov [edi], al
        inc edi
    loop m6

    mov edi, OFFSET Levelmap
    add edi, (15*90) + 16
    mov al, 2
    mov ecx, 4
    m7:
        mov [edi], al
        inc edi
    loop m7

    mov edi, OFFSET Levelmap
    add edi, (14*90) + 22
    mov al, 2
    mov ecx, 4
    m8:
        mov [edi], al
        inc edi
    loop m8

    mov edi, OFFSET Levelmap
    add edi, (13*90) + 28
    mov al, 2
    mov ecx, 4
    m9:
        mov [edi], al
        inc edi
    loop m9

    mov edi, OFFSET Levelmap
    add edi, (12*90) + 34
    mov al, 2
    mov ecx, 4
    m10:
        mov [edi], al
        inc edi
    loop m10

    mov edi, OFFSET Levelmap
    add edi, (11*90) + 40
    mov al, 2
    mov ecx, 4
    m11:
        mov [edi], al
        inc edi
    loop m11

    mov edi, OFFSET Levelmap
    add edi, (10*90) + 46
    mov al, 2
    mov ecx, 4
    m12:
        mov [edi], al
        inc edi
    loop m12

    mov edi, OFFSET Levelmap
    add edi, (9*90) + 52
    mov al, 2
    mov ecx, 4
    m13:
        mov [edi], al
        inc edi
    loop m13

    mov edi, OFFSET Levelmap
    add edi, (8*90) + 58
    mov al, 2
    mov ecx, 4
    m14:
        mov [edi], al
        inc edi
    loop m14

    mov edi, OFFSET Levelmap
    add edi, (7*90) + 64
    mov al, 2
    mov ecx, 4
    m15:
        mov [edi], al
        inc edi
    loop m15

    mov edi, OFFSET Levelmap
    add edi, (6*90) + 70
    mov al, 2
    mov ecx, 4
    m16:
        mov [edi], al
        inc edi
    loop m16

    mov edi, OFFSET Levelmap
    add edi, (5*90) + 76
    mov al, 2
    mov ecx, 4
    m17:
        mov [edi], al
        inc edi
    loop m17

    mov edi, OFFSET Levelmap
    add edi, (4*90) + 77
    mov al, 2
    mov ecx, 7
    m18:
        mov [edi], al
        inc edi
    loop m18


    mov edi, OFFSET Levelmap
    add edi, (10*90) + 30
    mov al, 1
    mov ecx, 2
    m19:
        mov [edi], al
        inc edi
    loop m19

    mov edi, OFFSET Levelmap
    add edi, (7*90) + 48
    mov al, 1
    mov ecx, 2
    m20:
        mov [edi], al
        inc edi
    loop m20


    mov edi, OFFSET Levelmap
    add edi, (16*90) + 15
    mov al, 5
    mov [edi], al

    mov edi, OFFSET Levelmap
    add edi, (14*90) + 23
    mov al, 5
    mov [edi], al

    mov edi, OFFSET Levelmap
    add edi, (12*90) + 35
    mov al, 5
    mov [edi], al

    mov edi, OFFSET Levelmap
    add edi, (10*90) + 47
    mov al, 5
    mov [edi], al

    mov edi, OFFSET Levelmap
    add edi, (8*90) + 59
    mov al, 5
    mov [edi], al

    mov edi, OFFSET Levelmap
    add edi, (6*90) + 71
    mov al, 5
    mov [edi], al

    ;--------------------------- straingt line
    mov edi , offset levelmap
    add edi, (15*90) + 77
    mov al, 2
    mov [edi], al
      
    mov edi , offset levelmap
    add edi, (14*90) + 77
    mov al, 2
    mov [edi], al

    mov edi , offset levelmap
    add edi, (13*90) + 77
    mov al, 2
    mov [edi], al

    mov edi , offset levelmap
    add edi, (12*90) + 77
    mov al, 2
    mov [edi], al

    mov edi , offset levelmap
    add edi, (11*90) + 77
    mov al, 2
    mov [edi], al

    mov edi , offset levelmap
    add edi, (10*90) + 77
    mov al, 2
    mov [edi], al

    mov edi , offset levelmap
    add edi, (9*90) + 77
    mov al, 2
    mov [edi], al

    mov edi , offset levelmap
    add edi, (8*90) + 77
    mov al, 2
    mov [edi], al

    mov edi , offset levelmap
    add edi, (7*90) + 77
    mov al, 2
    mov [edi], al

    mov edi , offset levelmap
    add edi, (16*90) + 77
    mov al, 2
    mov [edi], al

    mov edi , offset levelmap
    add edi, (17*90) + 77
    mov al, 2
    mov [edi], al

    ; powerups designee bu me
    mov edi, OFFSET Levelmap
    add edi, (16*90) + 47   
    mov BYTE PTR [edi], 7
    
    mov edi, OFFSET Levelmap
    add edi, (3*90) + 85   
    mov BYTE PTR [edi], 8

    mov edi, OFFSET Levelmap
    add edi, (17*90) + 15   
    mov BYTE PTR [edi], 60              ;its the sceret thinfs, 

    ret  


InitializeLevel2 ENDP


; =================================================================================
; =================================================================================
;                                  UNDERGROUND
; =================================================================================
; =================================================================================
; =================================================================================

; ----------------------------- UNDERGORUNG map-----------------------------

Underground PROC uses eax ecx edi
    
    mov edi, OFFSET Levelmap
    mov ecx, 1800
    mov al, 0
    ug1:
        mov [edi], al
        inc edi
    loop ug1

    mov edi, OFFSET Levelmap
    add edi, 1710       
    mov ecx, 90
    mov al, 2                 
    ug2:
        mov [edi], al
        inc edi
    loop ug2
    
    mov edi, OFFSET Levelmap 
    mov ecx, 90
    mov al, 2
    ug3:
        mov [edi], al
        inc edi
    loop ug3

    mov edi, OFFSET Levelmap
    mov ecx, 20
    mov al, 2
    ug4:
        mov [edi], al
        add edi, 90
    loop ug4

    mov edi, OFFSET Levelmap
    add edi, 89
    mov ecx, 20
    mov al, 2
    ug5:
        mov [edi], al
        add edi, 90
    loop ug5

    mov edi, OFFSET Levelmap
    add edi, (4*90) + 10    
    mov ecx, 70              
    mov al, 5                
    ug6: 
        mov [edi], al
        inc edi
    loop ug6

    mov edi, OFFSET Levelmap
    add edi, (6*90) + 10    
    mov ecx, 70              
    mov al, 5                
    ug7: 
        mov [edi], al
        inc edi
    loop ug7

    mov edi, OFFSET Levelmap
    add edi, (8*90) + 10    
    mov ecx, 70              
    mov al, 5                
    ug8: 
        mov [edi], al
        inc edi
    loop ug8

    mov edi, OFFSET Levelmap
    add edi, (10*90) + 10    
    mov ecx, 70              
    mov al, 5                
    ug9: 
        mov [edi], al
        inc edi
    loop ug9

    mov edi, OFFSET Levelmap
    add edi, (12*90) + 10    
    mov ecx, 70              
    mov al, 5                
    ug10: 
        mov [edi], al
        inc edi
    loop ug10

    mov edi, OFFSET Levelmap
    add edi, (14*90) + 10    
    mov ecx, 70              
    mov al, 5                
    ug11: 
        mov [edi], al
        inc edi
    loop ug11

    mov edi, OFFSET Levelmap
    add edi, (16*90) + 10    
    mov ecx, 70              
    mov al, 5                
    ug12: 
        mov [edi], al
        inc edi
    loop ug12

    mov edi, OFFSET Levelmap
    add edi, (17*90) + 20
    mov ecx, 50
    mov al, 2
    ug13:  
        mov [edi], al
        inc edi
    loop ug13

    mov edi, OFFSET Levelmap
    add edi, (13*90) + 10
    mov ecx, 20
    mov al, 2
    ug14: 
        mov [edi], al
        inc edi
    loop ug14
    
    mov edi, OFFSET Levelmap
    add edi, (13*90) + 60
    mov ecx, 20
    mov al, 2
    ug15: 
        mov [edi], al
        inc edi
    loop ug15

    mov edi, OFFSET Levelmap
    add edi, (9*90) + 30
    mov ecx, 30
    mov al, 2
    ug16:  
        mov [edi], al
        inc edi
    loop ug16

    mov edi, OFFSET Levelmap
    add edi, (5*90) + 40
    mov ecx, 10
    mov al, 2
    ug17:  
        mov [edi], al
        inc edi
    loop ug17

    mov edi, OFFSET Levelmap
    add edi, (17*90) + 80    
    mov BYTE PTR [edi], 61   

    sub edi, 90
    mov BYTE PTR [edi], 4    

    ret
Underground ENDP

;---------------------------------- MOVING TO SCRETE -----------------------------

secretPipe PROC
    
    cmp isUnderground, 1     
    je ProceedCheck          
    
    cmp currentLevel, 6      
    jne NoWarp               
   

ProceedCheck:
    movzx eax, yPos
    movzx ebx, xPos
    
    mov esi, OFFSET Levelmap
    mov ecx, 90
    mul ecx
    add eax, ebx
    add esi, eax
    
    mov al, [esi]
    
    cmp al, 60                           ; check entery p h to undergorund jae ga
    je GoDown
    
    cmp al, 61                           ; exit entery p h t wpasi
    je GoUp
    
NoWarp:
    ret 

GoDown:
    call StopSound        
    
    mov al, xPos
    mov savMarioX, al
    mov al, yPos
    mov savMarioY, al
    
    mov isUnderground, 1
    
    call Underground
    
    mov xPos, 5
    mov yPos, 17
    
    call Clrscr
    call DrawLevel
    call DrawPlayer
    ret

GoUp:
    call StopSound
    
    mov isUnderground, 0
    
    call InitializeLevel2                ; idhr curretnlevel varible knows hte lvl, kidhr jana h 
    
    mov al, savMarioX
    add al, 2              
    mov xPos, al
    mov al, savMarioY
    sub al, 2              
    mov yPos, al
    
    call Clrscr
    call DrawLevel
    call DrawPlayer
    ret

secretPipe ENDP

; =================================================================================
; =================================================================================
; =================================================================================
;                                   FILE HANDLING
; =================================================================================
; =================================================================================
; =================================================================================

;-------------------------------------- ASK NAME ------------------------------------
AskName PROC

    call Clrscr
    mov dh, 10
    mov dl, 20
    call Gotoxy
    
    mov edx, OFFSET askNameMsg
    call WriteString
    
    mov edx, OFFSET playerName
    mov ecx, 19                             ; Max length
    call ReadString
    ret

AskName ENDP

;-------------------------------------- SAVE SCROES ------------------------------------

SaveScoreIrvine PROC USES eax ebx ecx edx esi edi
    
    mov ecx, SIZEOF newEntry
    mov edi, OFFSET newEntry
    mov al, 0
    rep stosb

    mov esi, OFFSET playerName
    mov edi, OFFSET newEntry
    call StringCopyConcat

    mov esi, OFFSET strScoreLabel
    call StringCopyConcat

    mov eax, [score]                        ; COPYING DATA
    call IntToStringappend

    mov esi, OFFSET strLevelLabel
    call StringCopyConcat
    
    movzx eax, currentLevel
    call IntToStringappend

    mov esi, OFFSET strNewLine
    call StringCopyConcat
    
    mov esi, OFFSET gap
    call StringCopyConcat

    mov edx, OFFSET filename
    call OpenInputFile
    cmp eax, INVALID_HANDLE_VALUE
    je CreateNewFile         

    mov fileHandle, eax
    mov edx, OFFSET fileBuffer
    mov ecx, SIZEOF fileBuffer
    call ReadFromFile
    mov bytesRead, eax         
    mov eax, fileHandle
    call CloseFile
    jmp AppendData

CreateNewFile:
    mov bytesRead, 0           

AppendData:
    
    mov edi, OFFSET fileBuffer
    add edi, bytesRead
    
   
    mov esi, OFFSET newEntry

CopyLoop:
    mov al, [esi]
    cmp al, 0
    je DoneCopying
    mov [edi], al
    inc esi
    inc edi
    inc bytesRead             
    jmp CopyLoop
;                       W R I T N G

DoneCopying:
    
    mov edx, OFFSET filename
    call CreateOutputFile      
    mov fileHandle, eax
    
    mov edx, OFFSET fileBuffer
    mov ecx, bytesRead         
    call WriteToFile
    
    mov eax, fileHandle
    call CloseFile
    ret

SaveScoreIrvine ENDP

;-------------------------------------- SHOW HIGH SCROES ------------------------------------

ShowHighScores PROC
    call Clrscr
    mov eax, white + (black * 16)
    call SetTextColor
    
    mov edx, OFFSET highScoreTitle
    call WriteString

    ;                                        Open File 

    mov edx, OFFSET filename
    call OpenInputFile
    cmp eax, INVALID_HANDLE_VALUE
    je NoFileFound

    mov fileHandle, eax

    ;                                        Read File
    mov edx, OFFSET buffer
    mov ecx, 4999
    call ReadFromFile
    mov buffer[eax], 0 

    ;                                        Display
    mov edx, OFFSET buffer
    call WriteString
    call crlf

    call CloseFile
    jmp WaitKey

NoFileFound:
    mov edx, OFFSET filename
    call WriteString
    mov al, ' '
    call WriteChar
    mov edx, OFFSET tileAir 
    
WaitKey:
    call Crlf
    call Crlf
    mov edx, OFFSET returnMenu
    call WriteString
    call crlf
    call ReadChar
    ret
ShowHighScores ENDP



;-------------------------------------- STRING COPY ------------------------------------

StringCopyConcat PROC
    
    push edi
FindEnd:
    cmp BYTE PTR [edi], 0
    je StartCopy
    inc edi
    jmp FindEnd
StartCopy:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    cmp al, 0
    jne StartCopy
    dec edi        
    pop edi
    ret

StringCopyConcat ENDP

;-------------------------------------- INT TO STRING - APPEND ----------------------------------

IntToStringAppend PROC USES ebx ecx edx
   ;                            useing the puch adn pop sytem, last in first out
FindEndInt:
    cmp BYTE PTR [edi], 0      
    je StartInt                
    inc edi                    
    jmp FindEndInt

StartInt:
    mov ecx, 10
    mov ebx, 0                

    
    cmp eax, 0      
    jne DivLoop
    mov BYTE PTR [edi], '0'    
    inc edi
    jmp FinishInt

DivLoop:
    xor edx, edx               
    div ecx                    
    add dl, 48              
    push dx                 
    inc ebx                   
    cmp eax, 0                 
    jne DivLoop

PopLoop:
    pop dx                     
    mov [edi], dl              
    inc edi                 
    dec ebx                  
    cmp ebx, 0
    jne PopLoop

FinishInt:
    mov BYTE PTR [edi], 0      ; Null terminator add kro
    ret
IntToStringAppend ENDP

; =================================================================================
; =================================================================================
; =================================================================================
;                                   TIMER
; =================================================================================
; =================================================================================
; =================================================================================

;-------------------------------------- DRAW TIEMR ----------------------------------
UpdateAndDrawTimer PROC
    
    call GetMseconds
    sub eax, startTime
    mov edx, 0
    mov ecx, 1000
    div ecx             ; EAX now holds seconds
    
    push eax

    mov eax, yellow + (black * 16)
    call SetTextColor
    
    mov dl, 40       
    mov dh, 0
    call Gotoxy
    
    mov edx, OFFSET timerMsg
    call WriteString
    
    pop eax             
    call WriteDec       

   ;------------------------------------- tiem frrreeze --------------------------
    cmp isTimeFrozen, 1
    jne Freezeend   
    
    mov eax, lightCyan + (black * 16) 
    call SetTextColor
    
    mov dh, 0
    mov dl, 65               
    call Gotoxy
    
    mov edx, OFFSET strFreeze
    call WriteString
    
    mov eax, freezeTimer
    call WriteDec
    mov al, ' '             
    call WriteChar
    ret

Freezeend:
    
    mov dh, 0
    mov dl, 65
    call Gotoxy
    mov eax, black + (black * 16)
    call SetTextColor
    mov edx, OFFSET gap      
    call WriteString

    ret

UpdateAndDrawTimer ENDP

;-------------------------------------- DRAW TIEMR ----------------------------------
DrawTimer PROC
    
    call GetMseconds
    sub eax, startTime        
    mov edx, 0
    mov ecx, 1000
    div ecx                    
    
    push eax                  
    mov eax, yellow + (black * 16)
    call SetTextColor
    
    mov dh, 0
    mov dl, 45              
    call Gotoxy
    mov edx, OFFSET timerLabel
    call WriteString
    pop eax                   
    call WriteDec             

    cmp isTimeFrozen, 1
    jne ClearFreezeDisplay  
    
    mov eax, lightCyan + (black * 16) 
    call SetTextColor
    
    mov dh, 0
    mov dl, 60                
    call Gotoxy
    
    mov edx, OFFSET strFreeze
    call WriteString
    
    mov eax, freezeTimer
    call WriteDec
    
    mov al, ' '               
    call WriteChar
    call WriteChar
    ret

ClearFreezeDisplay:
    
    mov dh, 0
    mov dl, 60
    call Gotoxy
    mov eax, black + (black * 16)
    call SetTextColor
    
    mov ecx, 15
    WipeLoop:
        mov al, ' '
        call WriteChar
    loop WipeLoop
    ret

DrawTimer ENDP

; =================================================================================
; =================================================================================
; =================================================================================
;                                   SOUNDS
; =================================================================================
; =================================================================================
; =================================================================================

;-------------------------------------- BGM SOUND ----------------------------------

BackgroundMusic PROC
    
    INVOKE PlaySound, ADDR soundBGM, NULL, SND_ASYNC OR SND_LOOP OR SND_FILENAME
    ret

BackgroundMusic ENDP

;-------------------------------------- JUMP SOUND ----------------------------------

JumpSound PROC
    INVOKE PlaySound, ADDR soundJump, NULL, SND_ASYNC OR SND_FILENAME
    ;call Backgroundmusic
    ret
JumpSound ENDP

;-------------------------------------- COIN SOUND ----------------------------------

CoinSound PROC
    INVOKE PlaySound, ADDR soundCoin, NULL, SND_ASYNC OR SND_FILENAME
    ;call Backgroundmusic
    ret
CoinSound ENDP


;-------------------------------------- SHELL KICJ SOUND ----------------------------------

kickSound PROC
    INVOKE PlaySound, ADDR soundkick, NULL, SND_ASYNC OR SND_FILENAME
    ;call Backgroundmusic
    ret
kickSound ENDP

;-------------------------------------- STOP SOUND  ----------------------------------

StopSound PROC
    INVOKE PlaySound, NULL, NULL, 0
    call Backgroundmusic
    ret
StopSound ENDP

END main


    
