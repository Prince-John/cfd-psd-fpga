// Xilinx data types

#include    <xil_types.h>

// Local defines

#include    "i2c.h"
#include    "str_utils.h"


// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// Some global variables
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

u8  displayControl = LCD_DISPLAYON | LCD_CURSOROFF | LCD_BLINKOFF;
u8  displayMode = LCD_ENTRYLEFT | LCD_ENTRYSHIFTDECREMENT;

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// Write a character buffer to the display.
// Required for print.
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

void lcd_write_buff(u8 *buffer, unsigned int buff_size) {
    u32                 CntlReg;
    volatile unsigned   AckByteCount ;

	do {
		AckByteCount = XIic_Send(I2C_BASE_ADDR, LCD_I2C_ADDR, buffer, buff_size, XIIC_STOP) ;
		if (AckByteCount != buff_size) {
			/* Send is aborted so reset Tx FIFO */
			CntlReg = XIic_ReadReg(I2C_BASE_ADDR, XIIC_CR_REG_OFFSET);
			XIic_WriteReg(I2C_BASE_ADDR, XIIC_CR_REG_OFFSET,CntlReg | XIIC_CR_TX_FIFO_RESET_MASK);
			XIic_WriteReg(I2C_BASE_ADDR, XIIC_CR_REG_OFFSET,XIIC_CR_ENABLE_DEVICE_MASK);
		}

	} while (AckByteCount != buff_size);
    
    return ;
} 

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^
// Initialize the display
// ^^^^^^^^^^^^^^^^^^^^^^^^
 
void lcd_init(void) {
    u8  tx_buff[6] ;

    tx_buff[0] = SPECIAL_COMMAND ;                      	
    tx_buff[1] = LCD_DISPLAYCONTROL | displayControl ; 	
    tx_buff[2] = SPECIAL_COMMAND ;                     
    tx_buff[3] = LCD_ENTRYMODESET | displayMode ;      
    tx_buff[4] = SETTING_COMMAND ;                    
    tx_buff[5] = CLEAR_COMMAND ;
  
    lcd_write_buff(tx_buff, 6) ;         
    return ;                             	
} 

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// Send a command to the display.
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

void lcd_command(u8 command) {
    u8  tx_buff[2] ;  

    tx_buff[0] = SETTING_COMMAND ; 
    tx_buff[1] = command ;         
    lcd_write_buff(tx_buff, 2) ;      
    return ;
}

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// Send a special command to the display.  Used by other functions.
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

void lcd_specialCommand(u8 command) {
    u8  tx_buff[2] ; 

    tx_buff[0] = SPECIAL_COMMAND ; 
    tx_buff[1] = command ;         
    lcd_write_buff(tx_buff, 2) ;        
    return ;
}

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// Send the clear command to the display.  This clears the
// display and forces the cursor to return to the beginning
// of the display.
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

void lcd_clear() {
    lcd_command(CLEAR_COMMAND) ;
    usleep(50000) ;
    return ;
}

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// Set the cursor position to a particular column and row.
//
// column - byte 0 to 19
// row - byte 0 to 3
//
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

void lcd_set_cursor(u8 row, u8 col) {
    int row_offsets[] = {0x00, 0x40, 0x14, 0x54} ;

    lcd_specialCommand(LCD_SETDDRAMADDR | (col + row_offsets[row])) ;
    return ;
} 

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// Write a string to the display.
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

void lcd_print_str(char *str) {
    unsigned int    i = 0 ;
    u8              buff[80] ;
    unsigned int    len_of_str ;

// Return if we have a NULL string

    if (str[0] == 0x00) return ;
    while (str[i] != 0x00) {
        i = i + 1 ;
    }
    len_of_str = i ;

// Convert character array to u8 array

    for (i=0; i < len_of_str; i++) {
        buff[i] = (u8) str[i]  ;
    }
    
    lcd_write_buff(buff, len_of_str) ;
    return ;
}
