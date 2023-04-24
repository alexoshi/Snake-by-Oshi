Snake by Oshi   1.0

Deutsche Readme unten!

Snake with DirectX Engine
This is a Beta Version: Try out everything
and send me your comments
www.schonberg.de

If you want to use it as an advertisement
game, contact me and we can work it out.

This program is free for copy. However,
it is not allowed to change it in any way
or distribute it for payment.


Installation
The program extracts all files into the
folder specified, the only requirement is
that DirectX 6.0 or higher runs on
the machine with sound abilities and that
the graphics card supports a resolution
of 800*600 pixels in 16bit
double buffered mode (this should not
be a problem with graphics cards newer
than five years of age)

The rules
The player controls the snake by the
arrow keys. It is neither allowed to crash
the snake obstacles nor in the own body.
There is a very short delay before the crash
to give the player a chance to correct mistakes.
The player has to "eat" the points in
order to score. The amount of score is based
on the speed of the snake, everytime the
player scores the snake is becoming longer.

The Scores are:
Speed      Points            Time     Maximum possible
1           1                500ms    227
2           2                250ms    454
3           3                150ms    681
4           4                100ms    908
5           5                 75ms    1135
6           6                 50ms    1362
7           8                 30ms    1816
8          10                 20ms    2270
9          15                 10ms    3405
x          20                ASAP     4540

The time is the delay if the computer computes
fast enough, a slow computer will have a
limited update time, the snake is not becoming
faster. The maximum number of points possible
is the effect of the 234 fields in the
snake grid (the snake starts with a length of 7)

The Screens
The first screen you see is the loading screen,
it appears depending on the speed of the machine.
Fast computers change the resolution very fast
and the main screen becomes active before the
monitor performs the internal switch.

The main screen shows the options:
N        New      starts a new game with the currently
                  active or standard grid
1-0      Load I.  loads a saved game
G        Game O.  leads to the Options Screen
E        Exit     exits the game, saves most settings

The Option screen gives the options:
M        Main     goes back to the main screen
JKL      Points   changes the layout of the points
F        Sound FX turns sound on/off
S        Music    turns music on/off
q-p      Lab.     loads other Grids
c        custom   edits the current grid
1-9,x    Speed    changes the speed of the snake

The snake moves in the current speed, sound and
music change according to the setting.

The Edit Menu is controlled by
M        Main    goes back to the main screen
B        Back    goes back to the options screen
1-0      Grid    switches the editable pieces
arrows           moves the position of the editor
Space            Sets the current piece / removes a piece
S        Save    saves the current Grid in the
                 box q-p, ESC quits saving

The play screen has the following key bindings:
M, ESC   Main   quits the game and goes back
                to the main screen
P, SPACE        pause the game and give the ability
                to save in slot 1-0, according to the
                loading in the main screen
arrows          control the snake, unpause the game



-Two Player Multiplayer Mode on one PC

The new commands for player two are:
                 w   up
                 s   down
                 a   left
                 d   right

When button for multiplayer is pressed, the editor
comes up to set up the field. This is the initial
grid for all upcoming rounds. You can change it
between the rounds by pressing Space in IDLE Mode.

By pressing Enter the background changes and the
MP game is in IDLE Mode. The game starts as soon as
both players hit one of their movement keys
simultaneously.

The grid sometimes looses points at the end of the
round. This happens because the setup of the snakes
overwrites current data in the grid. Just open the
editor and paste a new point.



-Customizing Snake by Oshi

Since version 0-99-1 you can put an 800*600 24bit TGA-
Image in the folder the exe is installed. The program
tries load it and defaults to the standard images
in case an error occured. However due to loading
problems you have to mirror the image horizontally
to get it right.

play.tga     Playing background
main.tga     Menu background
editor.tga   Editor background
options.tga  Options background

Since version 1.0 you can put an 800*600 JPG-
Image in the folder the exe is installed. The program
tries load it and defaults to the TGA images
in case an error occured. However due to loading
problems you have to mirror the image horizontally
and vertically to get it right.

play.jpg     Playing background
main.jpg     Menu background
editor.jpg   Editor background
options.jpg  Options background


You can also use 44*44 24bit TGA images to replace the
snake, the points and the labyrinth. The naming-
convention is like this:

snake_hr.tga  snake head looking to the right
snake_hl.tga  snake head looking to the left
snake_hu.tga  snake head looking up
snake_hd.tga  snake head looking down
snake_tr.tga  snake tail looking to the right
snake_tl.tga  snake tail looking to the left
snake_tu.tga  snake tail looking up
snake_td.tga  snake tail looking down
snake_lr.tga  snake body left to right
snake_lu.tga  snake body left to up
snake_ld.tga  snake body left to down
snake_ru.tga  snake body right to up
snake_rd.tga  snake body right to down
snake_ud.tga  snake body up to down

point1.tga
point2.tga
point3.tga

lab1.tga
lab2.tga
lab3.tga
lab4.tga
lab5.tga
lab6.tga
lab7.tga
lab8.tga
lab9.tga

Don't forget to mirror the TGA!






Snake by Oshi   v.0-99-1

Snake mit DirectX Engine
Es läuft bis auf Kleinigkeiten richtig, und man kann
schon eine ganze Menge ausprobieren. Senden sie ruhig
Feedback.

Wer das Spiel als an die eigene
Firma angepasstes Werbespiel anbieten
möchte, setzt sich mit mir bitte in Verbindung
www.schonberg.de

Dieses Programm darf frei kopiert werden.
Es darf jedoch ohne meine Genehmigung
nicht verändert werden, oder gegen
Bezahlung angeboten werden.


Installation
Das Program extrahiert alle Dateien in das angegebene
Verzeichnis, einzige Vorraussetzung ist mindestens
DirectX 6.0 mit Soundkarte und einer Grafikkarte,
die 800*600 Pixel im 16bit Farben Modus mit Double
Buffering darstellen kann, dies sollte in einem PC,
der nicht älter als 5 Jahre ist, kein Problem sein.

Die Regeln
Der Spieler steuert die Schlange mit den Pfeiltasten.
Es ist weder erlaubt, das Labyrinth zu berühren, noch
den eigenen Schlangenkörper. Es gibt eine sehr kurze
Verzögerung vor dem Crash, um Fehler zu korrigieren.
Ziel ist es, die Punkte zu "fressen", basierend auf
eingestellten Geschwindigkeit der Schlange kriegt man
Punkte gutgeschrieben. Jedesmal, wenn die Schlange
frisst, wird sie ein Stück länger.

Die Punkteverteilung ist wie folgt:
Geschw.     Punkte           Zeit     Maximal
1           1                500ms    227
2           2                250ms    454
3           3                150ms    681
4           4                100ms    908
5           5                 75ms    1135
6           6                 50ms    1362
7           8                 30ms    1816
8          10                 20ms    2270
9          15                 10ms    3405
x          20               sofort    4540

Die Zeit ist die Verzögerung, die der Computer
einrechnet, wenn er die Szene schnell genug
berechnen kann. ein langsamer Computer wird nur eine
begrenzte Update Zeit haben, die Schlange wird trotz
höherer Einstellung nicht schneller. Die Maximal-
Punktzahl ergibt sich aus der Tatsache, dass nur ein
Spielfeld von 234 vorhanden ist (und die Schlange mit
der Länge 7 beginnt)

Die Bildschirme
Der erste Bildschirm, den sie sehen werden ist der
Ladeschirm, auf schnellen Computern werden sie ihn nie
zu Gesicht bekommen, da der Computer schneller mit
dem Laden fertig ist, als der Monitor sich selber
umschalten kann.

Der Hauptschirm hat folgende Optionen:
N        New      startet ein neues Spiel mit den zur
                  Zeit aktivierten Optionen
1-0      Load I.  lädt ein vorher gespeichertes Spiel
G        Game O.  öffnet die Optionen
E        Exit     schließt das Spiel und speichert
                  die meisten Einstellungen

Die Optionen:
M        Main     geht zurück ins Hauptmenü
JKL      Points   ändert den Punkt-Typ
F        Sound FX stellt den Sound ein/aus
S        Music    stellt die Musik ein/aus
q-p      Lab.     lädt ein definiertes Labyrinth
c        custom   öffnet den Editor
1-9,x    Speed    ändert die Geschwindigkeit der Schlange

Die Schlange bewegt sich im aktuellen Tempo, der Sound
und die Musik verhalten sich gemäß den Einstellungen

Der Editor wird wie folgt gesteuert:
M        Main     geht zurück ins Hauptmenü
B        Back     geht zurück in die Optionen
1-0      Grid     ändert das aktuelle Stück
Pfeiltasten       positionieren die Arbeitsstelle
Space             setzen ein Stück oder entfernen das
                  zur Zeit positionierte
S        Save     öffnet die Speicherabfrage, q-p speichert
                  das aktuelle Labyrinth ab, ESC beendet die
                  Abfrage ohne zu speichern

Der Spielschirm hat folgende Kommandos:
M, ESC   Main     Beendet das aktuelle Spiel und geht in den
                  Hauptbildschirm
P, SPACE          pausiert das Spiel und gibt die Möglichkeit,
                  in 1-0 zu speichern
Pfeiltasten       kontrollieren die Schlange und beenden
                  die Pause

-Two Player Multiplayer Mode auf einem PC

Tasten für Spieler 2 sind:
                 w   hoch
                 s   runter
                 a   links
                 d   rechts

Zum Start einer Multiplayer-Runde erscheint der Editor
Er zeigt das Labyrinth und die beiden Schlangen an,
wie sie zum Start der nächsten Runden auch auf dem
Feld erscheinen.

Wenn Return gedrückt wird wechselt das Spiel in den
IDLE-Modus. Das Spiel startet, wenn beide Spieler
gleichzeitig eine Bewegungstaste drücken

Das Feld verliert am Ende von Runden manchmal Punkte. Mit
der Leertaste können sie im IDLE-Modus in den Editor
wechseln und das Labyrinth dementsprechend verändern.


-Eigene Bilder verwenden
Seit der Version 0-99-1 kann man eigene Bilder als Hintergrund
benutzen. Diese müssen 800*600 groß sein 24bit haben und
als TGA in dem Pfad der Exe gespeichert sein. Außerdem müssen
sie horizontal gespiegelt sein.

play.tga     Spielfläche
main.tga     Haupt-Menü
editor.tga   Editor
options.tga  Optionen

Seit der Version 1.0 kann man JPG-Bilder als Hintergrund
benutzen. Diese müssen 800*600 groß und im Pfad der Exe
gespeichert sein. Außerdem muss man sie horizontal und
vertikal spiegeln. Bei Ladefehlern wird wenn vorhanden
auf die TGA Datei zurückgegriffen.

play.jpg     Spielfläche
main.jpg     Haupt-Menü
editor.jpg   Editor
options.jpg  Optionen


Außerdem kann man 44*44 24bit TGA Bilder für die Schlange,
das Labyrinth und die Punkte verwenden:

snake_hr.tga  Kopf nach rechts
snake_hl.tga  Kopf nach links
snake_hu.tga  Kopf nach oben
snake_hd.tga  Kopf nach unten
snake_tr.tga  Schwanz nach rechts
snake_tl.tga  Schwanz nach links
snake_tu.tga  Schwanz nach oben
snake_td.tga  Schwanz nach unten
snake_lr.tga  Körper links nach rechts
snake_lu.tga  Körper links nach oben
snake_ld.tga  Körper links nach unten
snake_ru.tga  Körper rechts nach oben
snake_rd.tga  Körper rechts nach unten
snake_ud.tga  Körper oben nach unten

point1.tga
point2.tga
point3.tga

lab1.tga
lab2.tga
lab3.tga
lab4.tga
lab5.tga
lab6.tga
lab7.tga
lab8.tga
lab9.tga

Nicht vergessen zu spiegeln!












Known Bugs:
The screen gets messed up with points, the program doesn't respond
           happened only twice on my computer, no clue what's happening!

The program is not entering main menu
           don't play with the files in data and data1!
           this way you might be able to fix it: open installation
           file with Rar-Packer and copy first the data
           folder, try out if it works and if it doesn't, use the
           data1 folder(this overwrites all your settings)

           You can as well reinstall the package(all settings get lost)

The program crashes when using the Pause button very often
           This is no intention, however I think it is not too bad so
           this will not be changed any time soon, play fair!
           Either way it is very difficult to trigger this!

The Snake crashes when performing very fast turns
           If you change the direction during delay time twice, the error
           correction is not triggered because it works faster than the
           actual game. To fix this problem the way more importent point
           of error correction would greatly decrease, this is why this
           is not fixed yet, the timing is very crucial, because each
           waitstate lasts several Milliseconds which is to much for
           smooth operation.

Playing the game off a CD, the program doesn't save any of the settings
           The game will start from CD, saving in hidden or temporary
           folders will be supported by the advertised versions.

The personal images look strange
           Check wether you mirrored the images or not. I know it is not
           that user friendly, however changing that code is a real pain,
           and I am not willing to solve this problem when there is such
           an easy workaround.
           If the pictures look really strange with distortions or row
           flips check wether you have the right size. The program
           just checks for the correct amount of pixels in the tga and
           the right depth. If you have a 600 times 800 TGA it will load,
           however the buffer is treated raw and you will have heavy
           distortions.



DISCLAIMER:
The program is carefully coded and there is no use of any system
functions, however: I WILL NOT TAKE ANY RESPONSIBILITY BY USING THIS SOFTWARE
I coded this game for fun and learning, I am not experienced and so I
don't know how to code bugfree. Either way the program is running on my Computer
for quite some time now and I tested every stupid thing you can think of,
enjoy the game.
