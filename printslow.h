!
! File:         PrintSlow.h
!
! Description:  This is a library extension for Inform 6 that allows you to modify the speed at which text is printed to the
!               interpreter. This is not recommended for already slow devices like handhelds.
!
! Modification History
! Who           When            What
! D Cornelson   16-Mar-2003     Original
!
! 1. Include "PrintSlow"; into your program.
! 2. In the Initialise routine, set PrintSlowSettings.Override = false and PrintSlowSettings.Speed = 1 to 10;
!    1 is the fastest and 10 is the slowest.
!
! NOTE: Since so many things are printed in the library, if you really wanted everything effected, you'd have to do some serious
!       library modifications to make that happen. As it is, this will work for general printing.
!
! USAGE: printslow("text");
!
! NOTE: You cannot concatenate or use the comma in printslow....it requires one string less than 800 bytes long. If you need to
!       print variables or more than 800 bytes, you should break up your printing.
!
! NOTE: printslow(); does _not_ print a newline automatically so you have to add this on your own.
!
Object PrintSlowSettings with Speed 5, Override true;

Array print_slow_array -> 800;

#IfDef TARGET_GLULX;
Global has_unicode;
Global has_timer;
#Endif;

[ printslow d i w c cc;
#IfDef TARGET_GLULX;
	@setiosys 2 0; ! select Glk I/O system
	has_unicode = glk($0004, 15, 0); ! gestalt, Unicode
	has_timer = glk($0004, 5, 0); ! gestalt, Timer
#Endif;
		ClearSlowArray();
		w = 0->33; ! screen width
		c = 0;
#IfDef TARGET_ZCODE;
		d.print_to_array(print_slow_array);
		for (i=2 : i<=(print_slow_array-->0+1) : i++) {
#IfNot;
		d.print_to_array(print_slow_array, 800);
		for (i=WORDSIZE : i<=(print_slow_array-->0+3) : i++) {
#Endif;
			c++;
			for (cc=i : cc<=(print_slow_array-->0+1) && print_slow_array->cc ~= 32 : cc++);
			if (c + (cc-i) >= w) { ! chars since newline + chars to next space >= w
				print (char) 13;
				c = 1;
			}
			if (print_slow_array->i / (11-PrintSlowSettings.Speed)*(11-PrintSlowSettings.Speed) == print_slow_array->i && PrintSlowSettings.Speed ~= 0)
			{
#IfDef TARGET_ZCODE;
				@read_char 1 1 DoNothing d;
#IfNot;
				if (has_timer) {
					glk($00D6, 100); ! schedule event after milliseconds 
					while (true) {
						glk($00C0, gg_event); ! select
						if (gg_event-->0 == 1) { ! timer event
							break;
						}
					}
					glk($00D6, 0); ! back to normal
				}
#Endif;
			}
#IfDef TARGET_GLULX;
			if (print_slow_array->i <= 0)
				continue;
			else if (print_slow_array->i == $13)
			{	glk($0080, print_slow_array->i); c = 0;		}
			else if (print_slow_array->i == $126)
				glk($0080, $34);
			else if (print_slow_array->i >= $0 && print_slow_array->i < $100)
				glk($0080, print_slow_array->i); ! put_char
			else if (has_unicode)
				glk($0128, print_slow_array->i); ! put_char_uni
			else
				print (char) 64;
#IfNot;
			switch (print_slow_array->i) {
				13:		print (char) 13;
						c = 0; ! newline in source text
				126:		print (char) 34; ! ~ -> quot
				default:	print (char) print_slow_array->i;
			}
#Endif;
		}
];

#IfDef TARGET_ZCODE;
[ DoNothing; 	rtrue; ];
#Endif;

[ ClearSlowArray i;	for (i=1 : i<800 : i++) print_slow_array->i = 0; ];
