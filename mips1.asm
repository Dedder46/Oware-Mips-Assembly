.data
boardhouses:  .space 48  # 48 bytes for 12 integers
pointhouses: .space 8
choosehouses: .asciiz "press 1 to play houses (1-6) or 2 to play houses (7-12): "
prompt: .asciiz " Choose pit number (1-6) or 86 if unending cicle: "
prompt2: .asciiz " Choose pit number (7-12) or 86 if unending cicle: "
prompt3: .asciiz "invalid pit choose again: "
prompt4: .asciiz "player 1 points-"
prompt5: .asciiz "player 2 points-"
prompt6: .asciiz "player 1 wins"
prompt7: .asciiz "player 2 wins"
prompt8: .asciiz "draw"
prompt9: .asciiz " press 1 if you agree in ending game or 2 to continue: "
prompt10: .asciiz "choose biggest capture seed:"
prompt11: .asciiz "choose lowest capture seed:"
result: .asciiz "Player "
newline:.asciiz "\n"
newline2:.asciiz " "

.text
main:

        jal initialize_board # Player input of capturing interval
 
        jal  choose_houses # Fill array with seeds and palyer input das casas para controlar
        
        jal  game_loop# Print array and player input da casa para semear
         
        # Win and tie conditions
        bgt $a1,24,exitwin1
        bgt $a2,24,exitwin2
        beq $a1,24,exitdraw
        beq $a2,24,exitdraw
        
notdraw:
              
    # Display the player turn
        li $v0,4
        la $a0, newline #Print a new line
        syscall
        li $v0, 4           # System call for print_str
        la $a0, result      # Load the address of the result string
        syscall
        move $a0, $t7       # Player number
        li $v0, 1           # System call for print_int
        syscall
               
checkhouses1_6:

        bne $t7,1,checkhouses7_12 # verify player
Notaccepted_end:
    # Get player input
        li $v0, 4           # System call for print_str
        la $a0, prompt      # Load the address of the prompt string
        syscall

        li $v0, 5           # System call for read_int
        syscall
        move $t3, $v0       # Store player input in $t3
        
    # Validate input
        beq $t3,86,capture_end
        blt $t3, 1, checkhouses1_6
        bgt $t3, 6, checkhouses1_6
        
checkhouses7_12:
        bne $t7,2,assignpit
    # Get player input
        li $v0, 4           # System call for print_str
        la $a0, prompt2      # Load the address of the prompt string
        syscall

        li $v0, 5           # System call for read_int
        syscall
        move $t3, $v0       # Store player input in $t3
        
        
        # Validate input
        beq $t3,86,capture_end
        blt $t3, 7, checkhouses7_12
        bgt $t3, 12, checkhouses7_12

assignpit:
    # Distribute seeds
        mul $t3,$t3,4 # Multiply house by bits
        andi $t3, $t3, -4
        addi $t3, $t3, -4 # Align house chosen to array
        move $s1,$t3
        lw $t4, boardhouses($t3)   # Load seeds from the selected pit
        bne $t4,0,validpit
invalidpit:
    # Player check
        beq $t7,1,invalid1
        beq $t7,2,invalid2
invalid1:
    # invalid house choice player 1
        li $v0, 4           # System call for print_str
        la $a0, prompt3      # Load the address of the prompt string
        syscall
        beq $t4,0 checkhouses1_6
invalid2:
     # invalid house choice player 2
        li $v0, 4           # System call for print_str
        la $a0, prompt3      # Load the address of the prompt string
        syscall
        beq $t4,0 checkhouses7_12
validpit:              
        sw $zero, boardhouses($t3) # Empty the selected pit

distribute_seeds:
        addi $t3, $t3, 4    # Move to the next pit
        blt $t3, 48, check_next_pit  # Check if the next pit is valid
        li $t3, 0           # Reset to index 0 if at the end of the board
check_next_pit:
        beq $s1,$t3,distribute_seeds # condition to not sow starting house
        addi $t4, $t4, -1   # Decrement seeds
        lw $t5, boardhouses($t3)  # Load seeds from the next pit
        addi $t5, $t5, 1    # Increment seeds
        sw $t5, boardhouses($t3)  # Store seeds in the next pit
        bnez $t4, distribute_seeds
        
playercapture:
     # Player check
        beq $t7,1,capture1
        beq $t7,2,capture2     
capture1:
     # Check if there is house\s to capture player1
        ble $t3,24,capture_end # Condition to not capture from own house
        lw $t5, boardhouses($t3) # Load seeds from the pit
        bgt $t5,$t9,capture_end # Check capture interval
        blt $t5,$t8,capture_end # Check capture interval
        add $a1,$a1,$t5 # Capture seeds
        sw $zero,boardhouses($t3) # Empty captured house
        addi $t3,$t3,-4 # Chech next house em contra-relogio  
        j capture1
        
capture2: 
     # Check if there is house\s to capture player2
        bgt $t3,24,capture_end # Condition to not capture from own house
        lw $t5, boardhouses($t3)  # Load seeds from the pit
        bgt $t5,$t9,capture_end # Check capture interval
        blt $t5,$t8,capture_end # Check capture interval
        add $a2,$a2,$t5 # Capture seeds
        sw $zero,boardhouses($t3) # Empty captured house
        addi $t3,$t3,-4 # Chech next house em contra-relogio     
        j capture2
        
capture_end:  
         # Switch player turn                                                                                                     
        blt  $t7,2,changeplayer1     
        
changeplayer2:
# Switch player turn  
        addi $t7,$zero,1
        beq $t3,86,unendingcycle
        j game_loop
        
changeplayer1:
# Switch player turn  
        addi $t7,$zero,2
        beq $t3,86,unendingcycle
        j game_loop
        
        jal exitwin1 # check win condition for player 1
              
        jal exitwin2     # check win condition for player 2
                      
        jal exitdraw # Check draw
                
unendingcycle:

        li $v0, 4           # System call for print_str
        la $a0, result      # Load the address of the result string
        syscall
        move $a0, $t7       # Player number
        li $v0, 1           # System call for print_int
        syscall
        li $v0, 4           # System call for print_str
        la $a0, prompt9      # Load the address of the prompt string
        syscall
        li $v0, 5           # System call for read_int
        syscall
        move $t3, $v0       # Store player input in $t3
        bne $t3,1,capture_end
        addi $t3,$zero,0
collectpoints1:
        lw $t5, boardhouses($t3)  # Load seeds from the next pit
        add $a1,$a1,$t5
        sw $zero, boardhouses($t3)  # Store seeds in the next pit
        addi $t3, $t3,4
        bne $t3,24,collectpoints1
collectpoints2:
        lw $t5, boardhouses($t3)  # Load seeds from the next pit
        add $a2,$a2,$t5
        sw $zero, boardhouses($t3)  # Store seeds in the next pit
        addi $t3, $t3,4
        bne $t3,48,collectpoints2
        j game_loop
        
        
        
initialize_board:

        li $v0, 4           # System call for print_str
        la $a0, prompt10      # Load the address of the result string
        syscall
        li $v0, 5           # System call for read_int
        syscall
        move $t9, $v0
        li $v0, 4           # System call for print_str
        la $a0, prompt11     # Load the address of the result string
        syscall
         li $v0, 5           # System call for read_int
        syscall
        move $t8, $v0
        li $t0,4         # Initial seeds in each pit
        li $t1, 0         # Initialize index for board
        li $a1,0
        li,$a2,0
        jr $ra
    
choose_houses:    
         sw $t0, boardhouses($t1)  # Set seeds in each pit
        addi $t1, $t1, 4    # Move to the next pit
        bne $t1, 48, choose_houses    # Repeat until all pits are initialized   
        li $v0, 4           # System call for print_str
        la $a0, choosehouses      # Load the address of the result string
        syscall
        li $v0, 5           # System call for read_int
        syscall
        move $t7, $v0
        jr $ra
        
game_loop:
    # Display the current board state
        addi $t1, $t1, -4
        lw $t6, boardhouses($t1)        
        li $v0, 1
        addi $a0, $t6, 0 #Print the no 
        syscall
        li $v0,4
        la $a0, newline2 #Print a new line
        syscall
        ble $t1,24,divideboard
        bne $t1, 0, game_loop        
divideboard:      
        li $v0,4
        la $a0, newline #Print a new line
        syscall
        addi $t1, $zero, 0
              
print_board:          
        lw $t6, boardhouses($t1)
        li $v0, 1
        addi $a0, $t6, 0 #Print the no 
        syscall
        li $v0,4
        la $a0, newline2 #Print a new line
        syscall
        addi $t1, $t1, 4      
        bne $t1, 24, print_board
        addi $t1, $zero, 48
        
        li $v0,4
        la $a0, newline #Print a new line
        syscall
        li $v0, 4           # System call for print_str
        la $a0, prompt4      # Load the address of the prompt string
        syscall
        move $a0, $a1       # Player number
        li $v0, 1           # System call for print_int
        syscall
        li $v0, 4           # System call for print_str
        la $a0, newline      # Load the address of the prompt string
        syscall
        li $v0, 4           # System call for print_str
        la $a0, prompt5      # Load the address of the prompt string
        syscall
        move $a0, $a2       # Player number
        li $v0, 1           # System call for print_int
        syscall
        
        jr $ra
        
exitwin1: 
        li $v0, 4           # System call for print_str
        la $a0, newline      # Load the address of the prompt string
        syscall       
        li $v0, 4           # System call for print_str
        la $a0, prompt6      # Load the address of the prompt string
        syscall
        li $v0, 10              # terminate program run and
        syscall  
        jr $ra
        
exitwin2:     
        li $v0, 4           # System call for print_str
        la $a0, newline      # Load the address of the prompt string
        syscall
        li $v0, 4           # System call for print_str
        la $a0, prompt7      # Load the address of the prompt string
        syscall   
        li $v0, 10              # terminate program run and
        syscall
        jr $ra
        
exitdraw:
        bne $a2,24,notdraw
        bne $a1,24,notdraw
        li $v0, 4           # System call for print_str
        la $a0, newline      # Load the address of the prompt string
        syscall
        li $v0, 4           # System call for print_str
        la $a0, prompt8      # Load the address of the prompt string
        syscall
        li $v0, 10              # terminate program run and
        syscall
        jr $ra


