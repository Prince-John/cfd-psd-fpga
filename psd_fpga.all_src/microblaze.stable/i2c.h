#ifndef SRC_I2C_H_
#define SRC_I2C_H_

#include    <xparameters.h>
#include    <xiic.h>
#include    <xiic_l.h>
#include    <xil_printf.h>
#include    <xil_types.h>
#include    <sleep.h>
#include    <stdbool.h>

extern  bool   useLCD  ;

// I2C related

#define     I2C_BASE_ADDR       XPAR_AXI_IIC_0_BASEADDR

// PCS9534 related

#define     PCA9534_I2C_ADDR    0x27
#define     PCA9534_IP_REG      0x00
#define     PCA9534_OP_REG      0x01
#define     PCA9534_INV_REG     0x02
#define     PCA9534_CONF_REG    0x03
#define     INPUT_INVERTED      0x04 

// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

// SparkFun 3 Volt SerLCD display

#define LCD_I2C_ADDR      0x72
#define DISPLAY_ADDRESS1  0x72 

//OpenLCD command characters

#define SPECIAL_COMMAND 254  //Magic number for sending a special command
#define SETTING_COMMAND 0x7C //124, |, the pipe character: The command to change settings: baud, lines, width, backlight, splash, etc

//OpenLCD commands

#define CLEAR_COMMAND                   0x2D		//45, -, the dash character: command to clear and home the display
#define CONTRAST_COMMAND                0x18		//Command to change the contrast setting
#define ADDRESS_COMMAND                 0x19		//Command to change the i2c address
#define SET_RGB_COMMAND                 0x2B		//43, +, the plus character: command to set backlight RGB value
#define ENABLE_SYSTEM_MESSAGE_DISPLAY   0x2E        //46, ., command to enable system messages being displayed
#define DISABLE_SYSTEM_MESSAGE_DISPLAY  0x2F        //47, /, command to disable system messages being displayed
#define ENABLE_SPLASH_DISPLAY           0x30		/48, 0, command to enable splash screen at power on
#define DISABLE_SPLASH_DISPLAY          0x31		//49, 1, command to disable splash screen at power on
#define SAVE_CURRENT_DISPLAY_AS_SPLASH  0x0A        //10, Ctrl+j, command to save current text on display as splash

// special commands

#define LCD_RETURNHOME      0x02
#define LCD_ENTRYMODESET    0x04
#define LCD_DISPLAYCONTROL  0x08
#define LCD_CURSORSHIFT     0x10
#define LCD_SETDDRAMADDR    0x80

// flags for display on/off control

#define LCD_DISPLAYON     0x04
#define LCD_DISPLAYOFF    0x00
#define LCD_CURSORON      0x02
#define LCD_CURSOROFF     0x00
#define LCD_BLINKON       0x01
#define LCD_BLINKOFF      0x00

// flags for display entry mode

#define LCD_ENTRYRIGHT 0x00
#define LCD_ENTRYLEFT 0x02
#define LCD_ENTRYSHIFTINCREMENT 0x01
#define LCD_ENTRYSHIFTDECREMENT 0x00

// Global variable defined in main

extern  char LCDstr[80] ; 

// Public functions supported

void lcd_init(void) ;
void lcd_clear(void);
void lcd_set_cursor(u8 row, u8 col);
void lcd_print_str(char *str);
void lcd_write_buff(u8 *buffer, unsigned int buff_size) ;
void pca9534_write_buff(u8 *buffer, unsigned int buff_size) ;

#endif /* SRC_I2C_H */
