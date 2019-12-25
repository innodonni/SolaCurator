!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!  ICType.h                     A "port" of the ansi-C ctype library to
!                               Inform 6 by L. Ross Raszewski
!  version 1
!
! The following functions are defined in this file:
! (tolower and toupper return c if c is not a valid letter. is* functions
!  return false for any condition not listed)
!  Function:            returns:                         example:
!  tolower(c);          the lowercase of a letter        tolower('A')=='a'
!  toupper(c);          the uppercase of a letter        toupper('a')=='A'
!  isalpha(c);          true if c is a letter            isalpha('a')==TRUE
!  isdigit(c);          true if c is a digit             isdigit('1')==TRUE
!  isspace(c);          true if c is a space or newline  isspace(' ')==TRUE
!  ispunct(c);          true if c is a period,comma,etc  ispunct(';')==TRUE
!  isalnum(c);          true if c is a letter or digit   isalnum('a')==TRUE
!  isupper(c);          true if c is an uppercase letter isupper('a')==FALSE
!  islower(c);          true if c is a lowercase letter  islower('a')==TRUE
!
! Questions, comments, etc, e-mail rraszews@acm.org
system_file;
[ tolower i;
  if (i>='A' && i<='Z')
   return i+('a'-'A');
  else return i;
];
[ toupper i;
 if (i>='a' && i<='z')
  return i-('a'-'A');
 else return i;
];
[ isalpha i;
  if (toupper(i)>='A' && toupper(i)<='Z') rtrue;
  else rfalse;
];
[ isdigit i;
  if (i>='0' && i<='9') rtrue;
  else rfalse;
];
[ isspace i;
 if (i==' ' or 13) rtrue;
 else rfalse;
];
[ ispunct i;
 if (i>32 && i<127 && ~~isalnum(i)) rtrue;
 else rfalse;
];
[ isalnum i;
 if (isalpha(i) || isdigit(i)) rtrue;
 else rfalse;
];
[ isupper i;
  if (i==toupper(i) && isalpha(i)) rtrue;
  else rfalse;
];
[ islower i;
 if (i==tolower(i) && isalpha(i)) rtrue;
 else rfalse;
];
