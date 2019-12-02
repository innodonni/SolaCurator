!============================================================================
! DIRS.H                                                     Release 1.980729
!----------------------------------------------------------------------------
! This library provides an easy way of adding a 'dirs' or 'exits' verb to
! your game. Just include it somewhere after parser and verblib.
!
! >EXITS
! You can go north, south or in.
!
! In the dark, you will only know about exits in a dark room when you have
! been in that room before. You'll just have to try otherwise.
! Define Constant ShowRooms; somewhere before the inclusion of the library
! to get a display like:
!
! >EXITS
! You can go north (to the Kitchen), south (to the Living Room) or in (to the
! Closet).
!
! Bugs, comments and feedback to:
! Gunther Schmidl <sothoth@usa.net>
!
!============================================================================

[ DirTo dir room j;
 j = dir.door_dir;
 return room.j;
];

[ DirsSub i j loc;
 if (location == thedark)
 {
  if (real_location has visited) loc = real_location;
  else "You can't see any exits as it is totally dark.";
 }
 else loc = location;
 j = 0;
 objectloop(i in Compass)
  if(loc provides (i.door_dir) && metaclass(loc.(i.door_dir))~=nothing)
   j++;
 if (j == 0) "There are no obvious exits.";
 print "You can go ";
 objectloop(i in Compass)
 {
  if(loc provides (i.door_dir) && metaclass(loc.(i.door_dir))~=nothing)
  {
   LanguageDirection(i.door_dir);
   #ifdef ShowRooms;
   if (ZRegion(DirTo(i, loc))~=3) ! don't print strings!
    print " (to ", (the) DirTo(i, loc), ")";
   #endif;
   j--;
   if (j == 1) print " or ";
   else if (j == 0) ".";
   else print ", ";
  }
 }
];

Verb meta 'dirs' 'directions'
     *                                   -> Dirs;
Verb meta 'list'
     * 'exits'/'dirs'/'directions'       -> Dirs;
Verb meta 'exits'
      *                                  -> Dirs;
