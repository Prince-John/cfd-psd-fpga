#include	<stdbool.h>
#include    "str_utils.h"

// ************************************************
// get_str_len() (includes the \0
// ************************************************

int	get_str_len(u8 *str) {
	int i = 0 ;

	do {
		if (str[i++] == 0x00) return i ;
	} while (true) ;
}

// **********************************************
// Convert a single ascii character to a nybble
// *********************************************

u8  asc_to_nybble(u8 ascChar) {
    u8   nybble ;

    if ((ascChar >= 0x30) && (ascChar <= 0x39)) {
        nybble = ascChar - 0x30 ;
    } else {
        nybble = ascChar - 0x37 ;
    }  
    return nybble ; 
}

// *******************************************
// Routine to convert 2 ASCII nybbles to a byte
// Pass int pointer to u8 buffer containing
// hex digits ... Grab two digits and convert
// to a byte.
// *******************************************

u8  buff_to_byte(u8 *buff) {
    u8  byte ;
    u8  ls, ms ;

    ms = asc_to_nybble(buff[0]) ;
    ls = asc_to_nybble(buff[1]) ;
    byte = ls + (ms << 4) ;
    return byte ;
}

// ***********************************************
// Routine to convert a string of hex numbers to
// a byte array.
//
// Routine returns number of bytes returned
// ***********************************************

int str_to_bytes(u8 *buff) {
    int     readPtr = 0 ;
    int     writePtr  = 0;
    int     numBytes = 0 ;

    while (buff[readPtr] != 0x00) {
        buff[writePtr] = buff_to_byte(&buff[readPtr]) ;
        readPtr += 2 ;
        writePtr++ ;
        numBytes++ ;
    }
    return numBytes ;
}

// *********************************************
// Support routine for the sprintf routine
// ********************************************

char *convert(unsigned int num, int base) { 

	  static char Representation[]= "0123456789ABCDEF";
	  static char buffer[50]; 
	  char *ptr; 
  
	  ptr = &buffer[49]; 
	  *ptr = '\0'; 
  
	  do {
		*--ptr = Representation[num%base]; 
		num /= base; 
	  }while(num != 0); 
  
  	  return(ptr); 
}

// **********************************************
// Light weight sprintf routine
// **********************************************

void lite_sprintf(char *buf, char  *fmt, ...) {

  	char *traverse; 
  	int i; 
	char *s;
   
//Module 1: Initializing Myprintf's arguments 

	  va_list arg; 
	  va_start(arg, fmt);
 
 	 for(traverse = fmt; *traverse != '\0'; traverse++) {

  		  while( *traverse != '%' ) 
  		  { 
  			    *buf = *traverse;				//putchar(*traverse);
			    if(*traverse == '\0'){break;}
			    buf++;
  			    traverse++; 
  		  } 
    		  //buf++;

  		  if(*traverse == '\0'){break;} 
    		  traverse++;

  		  //Module 2: Fetching and executing arguments
		switch(*traverse) 
    		{ 
    			  case 'c' : i = va_arg(arg,int);    //Fetch char argument
        			    *buf = i;			     //putchar(i);  if writing printf
        			    break; 
            
    			  case 'd' : i = va_arg(arg,int);     //Fetch Decimal/Integer argument
        			    if(i<0) 
        			    { 
        			      i = -i;
        			      *buf = '-';	      //putchar('-'); if writing printf
				      buf++;
        			    } 
        			    s = convert(i,10);	      //puts(convert(i,10));if writing printf
				    while(*s != '\0')
				    { 
					*buf = *s; s++; buf++; 
				    }
				    //*buf = '\0';
        			    break; 
            
      			case 'o': i = va_arg(arg,unsigned int); //Fetch Octal representation
     				  s = convert(i,8);		//puts(convert(i,8));if writing printf
				  while(*s != '\0')
				  { 
					*buf = *s; s++; buf++; 
				  }
				    //*buf = '\0';
        			    break; 
            
			case 's': s = va_arg(arg,char *);     //Fetch string
        			    			      //puts(s); if writing printf
				  while(*s != '\0')
				  { 
					*buf = *s; s++;buf++; 
				  }
				    //*buf = '\0';
        			    break; 
            
		        case 'x': i = va_arg(arg,unsigned int); //Fetch Hexadecimal representation
        			  s = convert(i,16);		//  puts(convert(i,16));if writing printf
				  while(*s != '\0')
				  { 
					*buf = *s; s++; buf++; 
				  }
				    //*buf = '\0';
            			  break;

			default: break; 
    		}  
  	} 
  *buf = '\0';

  //Module 3: Closing argument list to necessary clean-up
	
	  va_end(arg); 
}

/******************************************************************************\
*
* Replacement for sscanf from https://groups.google.com/forum/hl=en#!topic/comp.arch.fpga/ImYAZ6X_Wm4
* This replacement is needed because the standard sscanf provided by Xilinx is too large to be used
* with a MicroBlaze running from BRAM.
*
\******************************************************************************/
//
// Reduced version of scanf (%d, %x, %c, %n are supported)
// %d dec integer (E.g.: 12)
// %x hex integer (E.g.: 0xa0)
// %b bin integer (E.g.: b1010100010)
// %n hex, dec or bin integer (e.g: 12, 0xa0, b1010100010)
// %c any character
// %s string
//

int lite_sscanf(const char* str, const char* format, ...) {
  va_list ap;
  int value, tmp;
  int count;
  int pos;
  char neg, fmt_code;
//  const char* pf;
  char sval[30];    // Must be the same size or larger than irqLine in the main program.
 
  va_start(ap, format);
 
//  for (pf = format, count = 0; *format != 0 && *str != 0; format++, str++)
  for (count = 0; *format != 0 && *str != 0; format++, str++)
  {
    while (*format == ' ' && *format != 0)
      format++;
    if (*format == 0)
      break;
 
    while (*str == ' ' && *str != 0)
      str++;
    if (*str == 0)
      break;
 
    if (*format == '%')
    {
      format++;
      if (*format == 'n')
      {
        if (str[0] == '0' && (str[1] == 'x' || str[1] == 'X'))
        {
          fmt_code = 'x';
          str += 2;
        }
        else
          if (str[0] == 'b')
          {
            fmt_code = 'b';
            str++;
          }
          else
            fmt_code = 'd';
      }
      else
        fmt_code = *format;
 
      switch (fmt_code)
      {
        case 'x':
        case 'X':
          for (value = 0, pos = 0; *str != 0; str++, pos++)
          {
            if ('0' <= *str && *str <= '9')
              tmp = *str - '0';
            else
              if ('a' <= *str && *str <= 'f')
                tmp = *str - 'a' + 10;
              else
                if ('A' <= *str && *str <= 'F')
                  tmp = *str - 'A' + 10;
                else
                  break;
 
            value *= 16;
            value += tmp;
          }
          if (pos == 0)
            return count;
          *(va_arg(ap, int*)) = value;
          count++;
          break;
 
        case 'b':
          for (value = 0, pos = 0; *str != 0; str++, pos++)
          {
            if (*str != '0' && *str != '1')
              break;
            value *= 2;
            value += *str - '0';
          }
          if (pos == 0)
            return count;
          *(va_arg(ap, int*)) = value;
          count++;
          break;
 
        case 'd':
          if (*str == '-')
          {
            neg = 1;
            str++;
          }
          else
            neg = 0;
          for (value = 0, pos = 0; *str != 0; str++, pos++)
          {
            if ('0' <= *str && *str <= '9')
              value = value*10 + (int)(*str - '0');
            else
              break;
          }
          if (pos == 0)
            return count;
          *(va_arg(ap, int*)) = neg ? -value : value;
          count++;
          break;
 
        case 'c':
          *(va_arg(ap, char*)) = *str;
          count++;
          break;
        
        case 's':
          for (pos = 0; *str != 0 && *str != '\x20' && *str != '\xd' ; str++, pos++)
          {
            sval[pos] = *str;
          }
          sval[pos] = '\0';
          strncpy((va_arg(ap, char*)), sval,8);
          count++;
          break;
 
        default:
          return count;
      }
    }
    else
    {
      if (*format != *str)
        break;
    }
  }
 
  va_end(ap);
 
  return count;
}




