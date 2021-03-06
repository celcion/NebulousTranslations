Star Cruiser 2 PC-98 Translation

Contents:

1. Foreword.
2. Game description
3. Translation/hacking notes
4. Items and weapons - proper naming
5. Disclaimer
6. Staff and special thanks
7. Contact

IMPORTANT NOTE: this game has a severe graphical bug that makes the game unplayable whenever it happens. Most likely it's caused by a race condition somewhere in the code. Most of the time it triggers when you use certain weapon types (Metaparticle Gun, for example) while being hit by the enemy at the same time. Most likely you won't encounter it, but if you do - hit Enter, open Spacemap (Use -> Info -> Spacemap) and then close it. It should clear the glitch. If not, save the game with the in-game save feature (you can save anywhere), restart the emulator and load from that save.
===========================

1. Foreword

Hey everyone!
We're proud to present to you a new translation patch, this time for Star Cruiser 2: The Odysseus Project. This game is a PC-98/FM Towns only sequel to Star Cruiser, which came out on numerous systems (SMD, PC-88, PC-98, x68000). There are a few changes in game mechanics, it is more story-heavy and perhaps a bit more fast-paced than the first game. The single most prominent change is being able to use the mouse and the keyboard to play. This is also possibly the best way to play the game, since it has shops and adventure-like sections where you need to investigate certain areas. Overall, we feel that this game is quite advanced for 1992/1993, back when it  came out. We worked on SC SMD, and we thought that it would be good to translate the sequel as well. So, without further ado, have fun! 

2. Game description

Star Cruiser 2 is rather hard to describe. Of course, it is by and large the same in terms of gameplay as the first part, but there are certain differences. This time around you can use a mouse + keyboard combo. This was pretty novel at the time. It has many uses, as a matter of fact, since this game also has a turn-based mode (game calls it the "command mode") and adventure-like segments, where you have to find/operate some items in order to proceed, and sometimes solve an occasional puzzle. 

The abovementioned turned-based combat system can be used during most of the game (unless the game explicitly states that it can't be done for some reason). Sometimes it is even mandatory, usually when you're controlling more than one unit. 

The adventure mode works as it would in most adventure games - you need to find something/operate something to move forward. Some puzzles can only be solved by 'calling' someone, so as to advance the plot.

Still, the game is mostly an FPS/action game at its core. You will have to mow down tons of enemies, find your way out of multiple enemy bases, and defeat bosses in order to get further. The game has some customization, quite a few different weapon/sub-weapon types, and also basic crafting. 

The game also has some side quests you can do for money/items, and some challenges, such as racing. Nonetheless, it is mostly a linear experience - in some parts you have to do a set number of quests before advancing first, but you get to choose which ones you want to do. This grants the game some replayability, as you won't be able to do all the available quests in one go. 

This is a rather unusual game for its time. It has a fairly interesting plot, multiple genres, and quite a few memorable moments/characters. 

3. Translation notes

There are a few references to Japanese culture in this game, such as the o-mikuji fortunetelling machines, the (very popular) folktale Jugemu, and some Japanese songs/artists being mentioned at times. In addition, some item names had to be changed, because of space restriction (in particular Pressure/Super-pressure shield -> Voltaic Shield and Atom Shield). Apart from that, the script was fairly straightforward, as it is almost entirely event-based. Still, this game happens to have twice as much text as SC SMD (more or less 8000 lines compared to 4000 lines in the first game). That is a fairly substantial number, but a good chunk of it were item/interior descriptions, and also some repeated strings. 

4. Hacking notes

For some strange reason, Star Cruiser 2 uses the same dictionary-based text compression method as Star Cruiser SMD port (which I believe suggests that the SMD port was in development at more or less the same time as Star Cruiser 2, and thus it has a similar FPS-like style of gameplay). Text is separated into 12 files, one of which is constantly resident, whereas the others get switched depending on a star system you're in. Another thing is that the game was unable to use half-width characters, so its text engine had to be hacked to change that. One more problem was that the game had the same string-concatenation as the first game did, so by parsing the dialogue files you could only get the strings array, but no idea on when and how they are used. The best way would be hacking the event-engine and collecting all the strings utilized in it, but I did it the lazy way, since at the beginning of the game concatenation wasn't all that common. So, the strings array was translated. And, boy, did it backfire... 
The majority of the translation time was wasted on manual line fixing and optimization as a result. Another issue that took a while to deal with was image decompression and recompression to make that fancy "5 years have passed since VOID's downfall..." screen, as it was in Japanese, obviously. The compression algorithm while not being too hard in itself, required quite some time to reproduce and optimize. Still, it was a fun game to work on. Very challenging and rewarding as well.

5. Disclaimer

This translation is a non-commercial and unofficial project which is in no way affiliated with the game creators or distributors. We don't own anything here and have no copyrights.
We release this translation in the form of a patch, not the actual patched disks. Please, don't ask us to send you the ROM, or where you can find it - we can't help you with that.

You can redistribute this translation freely as long as you don't ask money for it and include this readme.txt file with it. We don't condone any form of commercial redistribution. Please, keep that in mind.


6. Staff and special thanks

Celcion - hacking 
Cccmar - main translation/testing 
TheMajinZenki - translation support/manual translation
Miralita - graphics hacking 

Beta-testing: * Spolan (Dendy Forever) 
              * Blomman (main betatester)

Special thanks to: 
* Great guys from PC-9800 Series Central (Discord channel and forum). 
* Great guys from Dendy Forever community.

7. Contact

Celcion
email:	celcion@gmail.com

cccmar
email:	cccmar111@gmail.com