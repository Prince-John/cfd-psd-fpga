#include    "str_utils.h"

// **********************************************
// Convert a single ascii character to a nybble
// *********************************************

u8  asc2nybble(u8 ascChar) {
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

u8  buff2byte(u8 *buff) {
    u8  byte ;
    u8  ls, ms ;

    ms = asc2nybble(buff[0]) ;
    ls = asc2nybble(buff[1]) ;
    byte = ls + (ms << 4) ;
    return byte ;
}

// ***********************************************
// Routine to convert a string of hex numbers to
// a byte array.
// Routine returns number of bytes returned
// ***********************************************

int str2bytes(u8 *buff) {
    int     readPtr = 0 ;
    int     writePtr  = 0;
    int     numBytes = 0 ;

    while (buff[readPtr] != 0x00) {
        buff[writePtr] = buff2byte(&buff[readPtr]) ;
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
  
	  do 
	  { 
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






