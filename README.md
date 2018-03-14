
![GitHub Logo](http://www.heise.de/make/icons/make_logo.png)

Maker Media GmbH und c't, Heise Zeitschriften Verlag

***

# NanoSynth

### Mini-GM-Synthesizer mit Karaoke-IC

![Picture](https://github.com/heise/NanoSynth/blob/master/aufm_breit.JPG)

Schier unglaublich, was hochintegrierte ICs heute können: Der SAM2695 von **[DREAM](http://www.dream.fr)** ist ein mehrstimmiger Wavetable-Synthesizer mit Effekteingang und MIDI-Steuerung auf 5 x 5 Quadratmillimetern. Unser NanoSynth-Board macht den Winzling Breadboard-tauglich.

Einen einfachen, aber sehr praktischen MIDI-Editor für Windows (andere Plattformen nach Neukompilierung der Delphi-Sourcen) finden Sie im Verzeichnis "GM-Editor" (ausführbare Datei in "Win32/Release"). Zum Einstellen des SAM2695 die vorbereitete CC-Tabelle "sam2695_ccvals.csv" laden. Mit Hilfe der Excel-Tabelle "GM-CCs.xlsx" können Sie CC-Tabellen für den Editor selbst erstellen. Ein preiswerter MIDI-USB-Adapter zum Betrieb am PC ist der [LOGILINK UA0037 von Reichelt](https://www.reichelt.de/USB-Konverter/LOGILINK-UA0037/3/index.html?ACTION=3&LA=446&ARTICLE=132373&GROUPID=6105&artnr=LOGILINK+UA0037).

Zur Neukompilierung des MIDI-Editors benötigen Sie die kostenlose **[Delphi 10 Starter Edition von Embarcadero](https://www.embarcadero.com/de/products/delphi/starter/free-download)**.

Der NanoSynth kann auf sehr einfache Weise über den Hardware-UART oder einen Software-UART (z.B. NewSoftSerial) vom Arduino gesteuert werden. 

Einen komplexeren Beispiel-Sketch (MIDI-File-Player) zum Betrieb am Arduino finden sie im Verzeichnis "paula.ino". Der Sketch benötigt die Libraries [FluxamaSynth](http://wiki.moderndevice.com/uploads/MD/Fluxamasynth.zip), [NewSoftSerial](http://arduiniana.org/libraries/newsoftserial/), [FlexiTimer2](http://www.pjrc.com/teensy/td_libs_MsTimer2.html) und [Flash](http://arduiniana.org/libraries/flash/).

Diese Libraries sind im Original nur auf älteren Arduino-IDEs lauffähig; für die aktuelle Version 1.8.5 haben wir einige recht umfangreiche Änderungen ausführen müssen. Die geänderten Libraries finden Sie in den hier zur Verfügung gestellten ZIPs, die Sie direkt mit dem Arduino-Library-Manager importieren können.

Die ersten vier FluxamaSynth-Beispiele funktionieren dann über /Datei/Beispiele/Fluxama-Shields-Synthmaster. Bitte beachten: Pin D4 ist MIDI-Tx, wie im Schaltbild in Ausgabe 1/2018 angegeben.

Um eigene MIDI-Files in unser Beispiel einzubinden, ist eine zusätzliche Konvertierung notwendig. Kostenlose MIDI-Dateien gibt es zum Beispiel [bei MIDIworld](http://www.midiworld.com/files/). Die .MID-Dateien müssen mit einem Perl-Skript konvertiert werden, das es unter https://sourceforge.net/projects/midi2fluxama/ gibt. Zum Start benötigt Perl aber das MIDI-Modul
''libmidi-perl'', das man unter Ubuntu mit ''sudo apt-get insall libmidi-perl'' nachinstalliert.

Konvertiert wird dann mit ''./midifluxama.pl beispiel.mid > data.h'', anschließend ''data.h'' über Reiter in der Arduino-IDE einfügen (neuen Reiter anlegen) und im Sketch ''SoftFluxSynthSMF.pde'' die Datei ''data.h'' inkludieren (#include data.h).
