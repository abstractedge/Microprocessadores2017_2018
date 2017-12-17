; multi-segment executable file template.

data segment
    ; add your data here!
    spreadsheet_cell db "     "
    white_line db "                                                   "
    menu1 db "- Import Spreadsheet"
    menu2 db "-  Show  Spreadsheet"
    menu3 db "-  Edit  Spreadsheet"
    menu4 db "- Export Spreadsheet"
    menu5 db "- About"
    menu6 db "- Exit"
    column_identifier db "A"
    row_identifier db "1"
    formula db "Formula"
    formula_space db "                 "
    result db "Result"
    result_space db "          "
    menu db "Menu"
    filename dw "C:\contents.bin"
    error db "Error reading file"
    handle dw ?
    buffer dw ?
    copyrights db "Copyrights reserved to:"
    dude db "Joao Camacho       Numero: 50905"
    key_press db "Press any key to continue! "
    exit_info db "You are now exiting the program. Please, 'hold the line!'"
    exit_error db "There was at least 1 error when exiting the program!"
    database db 20 dup(0)
    
    
    
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax

    ; add your code here
    pusha                                     ; Push all general registers not to screw previous kept values in those registers     
    
    call menu_print                           ; Prints menu and its options
    call menu_option_select                   ; Handles the select of option using mouse                          
    
    popa                                      ; Pop all to general registers not to screw previous kept values in those registers
        
    jmp  end_program                          ; "Exit" to Operating System
    
    menu_print proc
        
        mov ah, 00h
        mov al, 03h
        int 10h
        
        mov bl, 0000_1111b                    ; (Black Background)_(White String)b
        mov dl, 25                            ; It points to column 25 
        
        mov cx, (offset menu2 - offset menu1) ; Calculates message size
        mov dh, 05                            ; It points to row 05
        mov bp, offset menu1
        call string_print                     ; Prints string "Import Spreadsheet"
                                                    
        mov cx, (offset menu3 - offset menu2) ; Calculates message size
        mov dh, 07                            ; It points to row 07
        mov bp, offset menu2
        call string_print                     ; Prints string "Show Spreadsheet"
        
        mov cx, (offset menu4 - offset menu3) ; Calculates message size
        mov dh, 09                            ; It points to row 09
        mov bp, offset menu3
        call string_print                     ; Prints string "Edit Spreadsheet"
        
        mov cx, (offset menu5 - offset menu4) ; Calculates message size
        mov dh, 13                            ; It points to row 13
        mov bp, offset menu4
        call string_print                     ; Prints string "Export Spreadsheet"
        
        mov cx, (offset menu6 - offset menu5) ; Calculates message size 
        mov dh, 17                            ; It points to row 17
        mov bp, offset menu5
        call string_print                     ; Prints string "About"
        
        mov cx, (offset column_identifier - offset menu6) ; Calculates message size --- Print string "Exit"  
        mov dh, 19                            ; It points to row 19
        mov bp, offset menu6
        call string_print    
        
        ret    
    menu_print endp
    
    menu_option_select proc
        again_menu_option_select:
            call mouse_position
            cmp bx, 01
            jne again_menu_option_select
        
        cmp cx, 201                           ; CX = C9h
        jb again_menu_option_select
        cmp cx, 359
        ja again_menu_option_select
           
        cmp dx, 38                            ; DX = 26h
        jb again_menu_option_select
        cmp dx, 48                            ; DX = 30h
        jb menu_option1                       ; Option - Import Spreadsheet          
        
        cmp dx, 54                            ; DX = 36h
        jb again_menu_option_select
        cmp dx, 64                            ; DX = 40h
        jb menu_option2                       ; Option - Show Spreadsheet
        
        cmp dx, 72                            ; DX = 48h
        jb again_menu_option_select
        cmp dx, 82                            ; DX = 52h
        jb menu_option3                       ; Option - Edit Spreadsheet
        
        cmp dx, 104                           ; DX = 68h
        jb again_menu_option_select
        cmp dx, 114                           ; DX = 72h
        jb menu_option4                       ; Option - Export Spreadsheet 
        
        cmp dx, 134                           ; DX = 86h
        jb again_menu_option_select
        cmp dx, 144                           ; DX = 90h
        jb menu_option5                       ; Option - About
        
        cmp dx, 150                           ; DX = 96h
        jb again_menu_option_select
        cmp dx, 160                           ; DX = A0h
        jb menu_option6                       ; Option - Exit 
        ja again_menu_option_select
        
        menu_option1:
            call menu_erase
            call import_spreadsheet
            jmp menu_option_select_end     
            
        menu_option2:
            call menu_erase
            call show_spreadsheet
            jmp menu_option_select_end    
                     
        menu_option3:
            call menu_erase
            call edit_spreadsheet
            jmp menu_option_select_end        
            
        menu_option4:
            call menu_erase
            call export_spreadsheet
            jmp menu_option_select_end        
        
        menu_option5:
            call menu_erase
            call about
            jmp menu_option_select_end     
            
        menu_option6:
            call menu_erase
            call exit 
            jmp menu_option_select_end        
        
        menu_option_select_end:         
            ret
    menu_option_select endp
    
    
    import_spreadsheet proc
                           
        ret                       
    import_spreadsheet endp   
    
    
    show_spreadsheet proc
        jj:    
        mov bh, 1111_0000b                    ; Set page color to white
        call page_print
        
        mov dh, 3                             ; Points to row 3
         
        new_row_print:
            mov dl, 25                        ; Points to column 25
                                                   
            add dh, 1                         ; Starts printing in row 04        
            
            cmp dh, 7
            jb  print_even_row_cell
            cmp dh, 10
            jb  odd_row
            cmp dh, 13
            jb  print_even_row_cell
            cmp dh, 16
            jb  odd_row            
            cmp dh, 19                        ; Jump to cell position printing 
            jb print_even_row_cell
            je cell_position_print
            
            print_even_row_cell:             
                mov bl, 0111_0000b            ; Sets cell color to (Light Gray background)_(Black string)b
                mov cx, (offset white_line - offset spreadsheet_cell)
                mov bp, offset spreadsheet_cell
                call string_print             ; Prints space to handle spreadsheet cell
                cmp dl, 35
                je new_row_print 
                add dl, 10
                jne print_even_row_cell
                    
            
            odd_row: 
                mov dl, 20 
                
                print_odd_row_cell: 
                    mov bl, 0111_0000b        ; Sets cell color to (Light Gray background)_(Black string)b
                    mov cx, (offset white_line - offset spreadsheet_cell)
                    mov bp, offset spreadsheet_cell
                    call string_print         ; Prints space to handle spreadsheet cell
                    cmp dl, 40   
                    je new_row_print 
                    add dl, 10
                    jne print_odd_row_cell
                    
              
        
            cell_position_print: 
                mov si, offset column_identifier
                mov dl, 27
                mov dh, 5
                                          
                again_column_identifier_print:
                    mov bl, 0111_0000b        ; Sets cell color to (Light Gray background)_(Black string)b
                    mov cx, (offset row_identifier - offset column_identifier)
                    mov bp, offset column_identifier
                    call string_print         ; Prints column_identifier letter 
                    
                    add byte ptr [si], 1      ; Changes column_identifier letter
                    add dl, 5
                    cmp byte ptr [si], "E"
                    jne again_column_identifier_print 
                    
                mov byte ptr[si], "A"         ; Resets column identifier
                
                mov si, offset row_identifier
                mov dl, 22
                mov dh, 8    
                    
                again_row_identifier_print:  
                    mov bl, 0111_0000b        ; Sets cell color to (Light Gray background)_(Black string)b
                    mov cx, (offset formula - offset row_identifier)
                    mov bp, offset row_identifier
                    call string_print         ; Prints row_identifier letter
                    
                    add byte ptr [si], 1      ; Changes row_identifier letter
                    add dh, 3
                    cmp byte ptr [si], "5"
                    jne again_row_identifier_print
                    
                mov byte ptr[si], "1"         ; Resets row_identifier  
        
        mov dh, 22                            
        mov dl, 20      
        mov bl, 1111_0000b                    ; Sets cell color to (White background)_(Black string)b
        mov cx, (offset formula_space - offset formula)
        mov bp, offset formula
        call string_print                     ; Prints "Formula"
        
        mov dh, 20
        mov dl, 28
        formula_space_print:
            add dh, 1                         ; Starts printing in row 21
            mov bl, 0111_0000b                ; Sets cell color to (Light Gray background)_(Black string)b
            mov cx, (offset result - offset formula_space)
            mov bp, offset formula_space
            call string_print                 ; Prints space to handle formula
            cmp dh, 23
            jne formula_space_print
             
        mov dh, 21                            ; Prints "Result" and Result space
        mov dl, 50 
        mov bl, 1111_0000b                    ; Sets cell color to (White background)_(Black string)b
        mov cx, (offset result_space - offset result)
        mov bp, offset result
        call string_print                     ; Prints space to handle result
        
        mov dh, 21
        mov dl, 48
        result_space_print:
            add dh, 1                         ; Starts printing in row 21 
            mov bl, 0111_0000b                ; Sets cell color to (Light Gray background)_(Black string)b
            mov cx, (offset menu - offset result_space)
            mov bp, offset result_space
            call string_print                 ; Prints space to handle result
            cmp dh, 23                        
            jne result_space_print
        
        mov dh, 22                            
        mov dl, 10
        mov bl, 0111_0000b                    ; Sets cell color to (Light Gray background)_(Black string)b
        mov cx, (offset filename - offset menu)
        mov bp, offset menu                   
        call string_print                     ; Prints "Menu"
                                              
        again_mouse_position:                 ; Handles mouse click in "Menu"
            call mouse_position
            cmp bx, 01
            jne again_mouse_position
            
        cmp cx, 80                            ; CX = 50h
        jb again_mouse_position
        cmp cx, 112                           ; CX = 70h
        ja again_mouse_position
        cmp dx, 176                           ; DX = B0h
        jb again_mouse_position
        cmp dx, 184                           ; DX = B8h  
        ja again_mouse_position   
                            
        ret                       
    show_spreadsheet endp
    
    edit_spreadsheet proc
                           
        ret                       
    edit_spreadsheet endp
    
    export_spreadsheet proc
                           
        ret                       
    export_spreadsheet endp
    
    about proc
        mov dh, 04                            ; Points to row 04
        mov dl, 15                            ; Points to column 15
        mov bl, 0000_1111b                    ; Sets cell color to (Black background)_(White string)b
        mov cx, (offset dude - offset copyrights)
        mov bp, offset copyrights              
        call string_print                     ; Prints "Copyrights reserved to:"
        
        add dh, 02                            ; Points to row 06
        add dl, 04                            ; Points to column 19
        mov cx, (offset key_press - offset dude)
        mov bp, offset dude
        call string_print                     ; Prints "Joao Camacho       Numero: 50905"
        
        add dh, 05                            ; Points to row 11
        sub dl, 04                            ; Points back to column 15
        mov cx, (offset exit_info - offset key_press)
        mov bp, offset key_press
        call string_print                     ; Prints "Press any key to continue!"
        
        mov ah, 07                            ; Gets keyboad press from 'Press any key to continue!'
        int 21h                       
        ret                       
    about endp
    
    exit proc 
        jmp exit_end                          ; TODO - ELIMINAR ESTA LINHA QUANDO FUNCOES FILE ESTIVEREM A FUNCIONAR
        
        mov bl, 0000_1111b                    ; Sets cell color to (Black background)_(White string)b  
        mov dl, 20                            ; Points to column 20
        mov dh, 07                            ; Points to row 07
        mov cx, (offset exit_error - offset exit_info)
        mov bp, offset exit_info        
        call string_print
        
                                              ; Creating the file contents.bin
        mov dx, offset filename               ; DS:DX - ASCIZ filename
        mov cx, 0                             ; Normal - No attributes                         
        call fcreate
        jc error_exit
        mov handle, ax
    
                                              ; Writing to the file contents.bin                       
        mov bh, 0 
        mov bx, handle                        ; BX - File handle
        mov cx, 20                            ; CX - Number of bytes to write                                            
        mov dx, offset database               ; DS:DX - Data to write.
        call fwrite
        jc error_exit
        
                                              ; Closing contents.bin
        mov bx, handle
        call fclose
        jc error_exit
        
        jmp exit_end
                                              
        error_exit:
            mov dh, 10
            mov dl, 20
            mov cx, (offset database - offset exit_error)
            mov bp, exit_error
            call string print
            
            add dh, 4
            mov cx, (offset exit_info - offset key_press)
            mov bp, key_press
            call string_print
            
            mov ah, 07                        ; Gets keyboad press from 'Press any key to continue!'
            int 21h 
            
        exit_end:
            ret 
    exit endp
    
    
    ;Auxiliar procedures (necessary for program integrity!)
    
       
    ;*****************************************************************
    ; PAGE_PRINT - Procedure necessary to "paint" page
    ; Input parameters:
    ;   ah - Scroll up window (06h)
    ;   al - Entire windows (00h)
    ;   cl - 00h (Top)
    ;   ch - 00h (Left)
    ;   dl - 25 (Bottom)
    ;   dh - 80 (Right)
    page_print proc
        mov ah, 06h
        mov al, 00h
        mov cl, 0
        mov ch, 0
        mov dl, 80
        mov dh, 25 
        int 10h 
        
        ret
    page_print endp
    
    ;*****************************************************************
    ; MENU_ERASE - Procedure necessary for "erase" menu options
    ; Input parameters:
    ;   cx - Size of white_line
    ;   dl - Column number
    ;   dh - Row number of option to be overwrited
    ;   bp - Offset  white_line
    ;***************************************************************** 
    menu_erase proc
        mov dl, 25
        mov cx, (offset menu1 - offset white_line) 
        mov bp, offset white_line 
        
        mov dh, 05
        call string_print  
        
        mov dh, 07
        call string_print
        
        mov dh, 09
        call string_print
        
        mov dh, 13
        call string_print
        
        mov dh, 17
        call string_print
        
        mov dh, 19
        call string_print             
        
        ret
    menu_erase endp   
    
    ;*****************************************************************
    ; STRING_PRINT - Procedure that allows strings to be printed
    ; Input parameters: 
    ;   bl - (Background color)_(String color)b
    ;   cx - Size of message to be printed
    ;   dl - Column number
    ;    
    ;   bp - Offset  of message to be printed 
    ;*****************************************************************
    string_print proc 
	    mov al, 1 
	    mov ah, 13h   ;Interrupt 10h - AH:13h 
	    mov bh, 0
	    int 10h
	    
	    ret 
	string_print endp 
    
    mouse_position proc
        mov ax, 3
        int 33h
        
        ret
    mouse_position endp
    
    ;*****************************************************************
    ;FCREATE - File create
    ;Input parameters: 
    ;           CX - file attributes:   cx=0-normal-no attributes.  cx=1-read-only. 2- hidden. 4-system
    ;           DS:DX - ASCIZ filename.
    ;       
    ; Output parameters:
    ;   CF clear if successful, AX - file handle.
    ;   CF set on error AX - error code.
    ;*****************************************************************
    
    fcreate proc
        mov ah, 3ch
    	int 21h
    	ret 
    fcreate endp
    
    
    ;*****************************************************************
    ;FOPEN - open file     
    ;Input parameters:
    ;           DS:DX -> ASCIZ filename
    ;           AL = access and sharing modes: 0-read  1-write   2-read/write      
    ;Notes:              
    ;           note 1: file pointer is set to start of file.
    ;           note 2: file must exist
    ;          
    ;Return:   if successful;
    ;           CF is clear, AX = file handle. 
    ;
    ;           Erro:
    ;           CF set on error AX = error code. 
    ;*****************************************************************
    fopen proc
        mov ah, 3dh
        int 21h
        ret
    fopen endp
    
    
    
    ;*****************************************************************
    ; fread - read from file  
    ; Input parameters:
    ;           BX = file handle.
    ;           CX = number of bytes to read.
    ;           DS:DX -> buffer for data.
    ; Note:
    ;           Data is read beginning at current file position, 
    ;           and the file position is updated after a successful 
    ;           read the returned AX may be smaller than the request 
    ;           in CX if a partial read occurred. 
    ;       
    ; Return:   if successful;
    ;           CF is clear, AX = number of bytes actually read; 0 if at EOF (end of file) before call.
    ;
    ;           Erro:
    ;           CF is set on error AX = error code.
    ;*****************************************************************
    fread proc
        mov ah,3Fh
        int 21h 
        ret 
    fread endp
    

     
    ;*****************************************************************
    ; fwrite - write to file    
    ; Input parameters:
    ;           BX = file handle.
    ;           CX = number of bytes to write.
    ;           DS:DX -> data to write.  
    ; Note:
    ;           -if CX is zero, no data is written, and the file is truncated 
    ;           or extended to the current position 
    ;           -data is written beginning 
    ;           at the current file position, and the file position is updated 
    ;           after a successful write the usual cause for AX < CX on return is a full disk.
    ; 
    ; Return:   if successful;
    ;           CF clear; AX = number of bytes actually written. 
    ;
    ;           Erro:
    ;           CF set on error; AX = error code.
    ;           note: if CX is zero, no data is written, and the file is truncated or extended to the current position data is written beginning at the current file position, and the file position is updated after a successful write the usual cause for AX < CX on return is a full disk. 
    ;*****************************************************************
    fwrite proc
        mov ah,40h
        int 21h
        ret
    fwrite endp
    
    
    ;*****************************************************************
    ; fclose - close file   
    ; Input parameters:
    ;           BX = file handle.  
    ;
    ; Return:   if successful;
    ;           CF clear, AX destroyed. 
    ;
    ;           Erro:
    ;           CF set on error, AX = error code (06h). 
    ;            
    ;*****************************************************************
    fclose proc
        mov ah, 3Eh
        int 21h
        ret
    fclose endp

    
end_program:      
ends

end start ; set entry point and stop the assembler.
