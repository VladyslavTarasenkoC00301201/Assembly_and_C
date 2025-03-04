        ORG $1000


CR          EQU $0D 
LF          EQU $0A
        
EXIT        EQU 0           ; USED TO EXIT ASSEMBLY PROGRAM
MIN_POTIONS EQU 1           ; MIN NUMBER OF SMALL POTIONS
MAX_POTIONS EQU 9           ; MAX NUMBER OF SMALL POTIONS

        * START OF GAME
START:
        ;BSR     WELCOME         ; BRANCH TO THE WELCOME SUBROUTINE
        ;BSR     INPUT           ; BRANCH TO THE INPUT SUBROUTINE
        BSR     GAME            ; BRANCH TO THE GAME SUBROUTINE

        * GAME LOOP
        ORG     $3000           ; THE REST OF THE PROGRAM IS TO BE LOCATED FROM 3000 ONWARDS

        * ------------------- GAME SUBROUTINE ---------------------
GAME:
        BSR     CHAPTER_1
        BSR     CHAPTER_2
        BSR     END

END:
        SIMHALT



GAMELOOP:
        
   

CHAPTER_1:
        BSR     ENDL
        LEA     CHAPTER_1_INTRO_P1, A1
        MOVE.B  #1, D0                      ; trap 15 n number of characters specified in d1 without CR LF
        BSR     PRINT
        
            
        LEA     READ_NEXT, A1
        MOVE.B  #18, D0
        TRAP    #15
        
        BSR     CLEAR_SCREEN
        LEA     CHAPTER_1_INTRO_P2, A1
        MOVE.B  #1, D0
        BSR     PRINT
        
        
CHAPTER_1p1:   
     
        LEA     PLAYER_ACTION_PROMPT, A1
        MOVE.B  #14, D0
        TRAP    #15
        MOVE.B  #2, D0                      ; this system call takes user input into A1 and writes the length to D1 (max 80)
        TRAP    #15
        
        BSR     CLEAR_D_REGISTERS
        MOVE.L  A1, A5                      ; save copy of input
        LEA     PLAYER_ACTIONS, A6          ; loading the address of array with available commands to use in comparison loop with input
        ADDQ    #1, A6
        BSR     CHECK_COMMANDS
        
        
CHAPTER_2:
                       

PRINT: 
        MOVE.B  #1, D1         
        MOVE.L  #10, D6       ; 10 for faster debugging otherwise 20000
        BSR     DELAY
        TRAP    #15           ; Call Easy68K system trap for output
        ADDQ    #1, A1
        MOVE.B  (A1), D6
        BNE     PRINT
        BSR     ENDL
        RTS


DONE    TRAP    #15           ; Exit program



DELAY:
        SUBQ.L  #1, D6
        BNE     DELAY
        RTS 
        

             
ENDL:
        MOVEM.L D0/A1,-(A7)     ; SAVE D0 AND A1
        MOVE    #14,D0          ; MOVE LITERAL 14 TO DO
        LEA     CRLF,A1         ; ASSIGN CRLF TO ADDRESS REGISTER A1
        TRAP    #15             ; TRAP AND INTERPRET VALUE IN D0
        MOVEM.L (A7)+,D0/A1     ; RESTORE D0 AND A1
        RTS                     ; RETURN FROM ENDL: SUBROUTINE


STRCMP:   
        MOVE.B  (A0)+, D2       ; Load byte from expected string
        MOVE.B  (A1)+, D3       ; Load byte from input command
        CMP.L   #0, D2          ; Check if end of string
        BEQ     RETURN_LABEL
        CMP.B   D2, D3          ; Compare characters
        BEQ     STRCMP     
        RTS                     ; Strings are equal


RETURN_LABEL:
        RTS
        
        
INVALID_INPUT:
        BSR      CLEAR_SCREEN
        LEA      INVALID_INP, A1
        MOVE.B   #14, D0
        TRAP     #15
        BRA      END


CHECK_COMMANDS:
        MOVE.L  A5, A1
        CMP.L   #0, (A6)
        BEQ     INVALID_INPUT     ; If null, invalid command
        MOVE.L  (A6)+, A0         ; Load command pointer
        ADDQ    #1, D6
        BSR     STRCMP            ; Compare user input with command
VALID:  BEQ     EXECUTE_COMMAND   ; If match, execute command
        BRA     CHECK_COMMANDS
       

EXECUTE_COMMAND:
        CMP.L    #1, D6
        BEQ      GO
        
        CMP.L    #2, D6
        BEQ      TALK
        
        CMP.L    #3, D6
        BEQ      INSPECT
        
        CMP.L    #4, D6
        BEQ      QUIT


GO:


TALK:
       MOVE.L    A5, A1
       CMP.L     #0,(A6)
       BEQ       INVALID_INPUT
       ADDQ.L    #8, A1           ; skipping the "talk to" command itself
       LEA       INTERACTIVE_PEOPLE, A6
       ADDQ      #1, A6
       MOVE.L    (A6)+, A0
       BSR       STRCMP       
       BEQ       DIALOGUE_MANAGER
       BRA       TALK
       
       
INSPECT:


QUIT:


DIALOGUE_MANAGER:
        LEA     DEBUGGING_MESSAGE, A1
        BSR     CLEAR_SCREEN
        BSR     CLEAR_D_REGISTERS
        MOVE.B  #14, D0
        TRAP    #15


CLEAR_D_REGISTERS:
        MOVE.L  #0, D6
        MOVE.L  #0, D5
        MOVE.L  #0, D4
        MOVE.L  #0, D3
        MOVE.L  #0, D2
        MOVE.L  #0, D1
        MOVE.L  #0, D0
        RTS       

CLEAR_SCREEN: 
        MOVE.B  #11, D0         ; CLEAR SCREEN
        MOVE.W  #$FF00, D1      ; SET COLOUR
        TRAP    #15             ; TRAP AND INTERPRET VALUE IN D0
        MOVE.W  #0, D1          ; restore 0 value of D1 for safety
        RTS                     ; RETURN FROM CLEAR_SCREEN: SUBROUTINE   
        
            
        * ------------------- DATA DECLARATIONS --------------------
CRLF:           DC.B    $0D,$0A,0
NEWSPAPER_MSG:  DC.B    '************************************************************'
                DC.B    $0D,$0A
                DC.B    'THE LONDON TIMES - February 25, 2007'
                DC.B    $0D,$0A

INVALID_INP:    DC.B    'You can not perform this action at the moment, try something else...',CR,LF,0
UPDATE_MSG:     DC.B    'UPDATING QUEST STATUS...',0
BORDER:         DC.B    '----------------------------------------------------',10,0
OPTION1:        DC.B    '[1] The Mystery of the Missing Artifact',10,0
OPTION2:        DC.B    '[2] Exit',10,10,0
PROMPT:         DC.B    'Enter your choice: ',0

DEBUGGING_MESSAGE:
                DC.B    'Hooooray I got here it works!',0
CHAPTER_1_INTRO_P1: 
                DC.B '| Footsteps were heard from the landing. The distinct syncopation ',CR,LF
                DC.B '| and distinctive ringing of one of the strokes in relation to the',CR,LF
                DC.B '| next betrayed the limp and the presence of a wooden cane. ',CR,LF
                DC.B '| The step was weighty, confident and proud. Despite the limp, the walker ',CR,LF 
                DC.B '| kept his step evenly, without faltering or slowing down.',CR,LF
                DC.B '| The clock struck a quarter past seven. ',CR,LF
                DC.B '| The once spacious, now haphazardly furnished and strewn with all',CR,LF
                DC.B '| sorts of notes and objects ',CR,LF
                DC.B '| (having no other purpose than to exist in this cozy chaos) living',CR,LF
                DC.B '| room was filled with warm light coming',CR,LF
                DC.B '| from the crackling fireplace and giving a special',CR,LF
                DC.B '| vintage shade to the dusty bookshelves... ',CR,LF,0
CHAPTER_1_INTRO_P2:
                DC.B '| Rocking in my chair and puffing on tobacco from an oak pipe,',CR,LF
                DC.B '| the aroma of which merged into a dual duet with the delicate',CR,LF
                DC.B '| smell of almost charred walnut firewood,',CR,LF
                DC.B '| I wandered in the chambers of my mind,',CR,LF
                DC.B '| again and again passing by the same nooks and corners, ',CR,LF
                DC.B '| trying to spot any previously unnoticed detail.',CR,LF
                DC.B '| "What a bore," I cried out, disappointed and unexpectedly loud. ',CR,LF
                DC.B '| In the kitchen, a spoon hit a glass.',CR,LF
                DC.B '| Mrs Hudson must have been here all this time. At that very moment, ',CR,LF
                DC.B '| the door opened slightly and John entered the room...',CR,LF,0
                

ACTION_TALKTJ:  DC.B 'talk to John',0
ACTION_TALKH:   DC.B 'talk to Mrs Hudson',0
ACTION_TALKL:   DC.B 'talk to Lestrade',0
ACTION_TAKE:    DC.B 'take',0
READ_NEXT:      
                DC.B '|/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/|',CR,LF
                DC.B '|/\/\ PRESS ENTER TO CONTINUE \/\/|',CR,LF
                DC.B '|/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/|',CR,LF,0
                
PLAYER_ACTION_PROMPT:  
                DC.B '***********************************',CR,LF
                DC.B 'WHAT SHOULD I DO -> ',0




INTERACTIVE_PEOPLE:
    DC.L JOHN       ; Pointer to first string
    DC.L HUDSON     ; Pointer to second string
    DC.L LESTRADE   ; Pointer to third string
    DC.L 0          ; Null terminator (optional)

JOHN:
    DC.B 'John',0
HUDSON:
    DC.B 'Mrs Hudson',0
LESTRADE:
    DC.B 'Lestrade',0
    
    
PLAYER_ACTIONS:
    DC.L CMD_GO
    DC.L CMD_TALK
    DC.L CMD_INSPECT
    DC.L CMD_QUIT
    DC.L 0

CMD_GO:      DC.B 'go',0          ; command 0
CMD_TALK:    DC.B 'talk to',0     ; command 1
CMD_INSPECT: DC.B 'inspect',0
CMD_QUIT:    DC.B 'quit',0



INTEREACTIVE_ITEMS:
    DC.L ITEM_NEWSPAPER
    DC.L SMOKING_PIPE
    DC.L 0
    
ITEM_NEWSPAPER: DC.B 'newspaper',0
SMOKING_PIPE: DC.B 'pipe',0



        END START





*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~0~
