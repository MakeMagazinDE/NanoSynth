
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
