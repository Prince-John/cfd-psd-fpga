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
int rsscanf(const char* str, const char* format, ...)
{
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
