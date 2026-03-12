# M122 – Grundlagen der Scriptsprache BASH (Linux / Unix)

## Git Teil 1 – Linux Befehle

### Checkpoint Übung 1 – Absolute und Relative Pfade

**Absolute Pfade beginnen immer mit `/` (Root).**

Beispiele:

```bash
cd /                # Wechsel ins Root-Verzeichnis
cd /home            # Wechsel ins Home-Verzeichnis
cat /home/user/data/file.txt
```

**Relative Pfade beginnen im aktuellen Verzeichnis**

Beispiele:

```bash
cd ~                # Wechsel ins Home-Verzeichnis
cd ../..            # Zwei Verzeichnisse nach oben
cd ..               # Ein Verzeichnis nach oben
cat data/file.txt   # Datei aus Unterverzeichnis anzeigen
cd ./data           # Wechsel in Unterordner
cd ../../etc        # Wechsel nach /etc
```

---

### Checkpoint Übung 2 – Wildcards und Brace Expansion

**Wildcards**

```bash
ls *.txt        # Alle txt Dateien anzeigen
rm f*.gif       # Alle gif Dateien die mit f beginnen löschen
ls *0.*         # Dateien mit einer 0 vor der Endung
rm *A*          # Dateien mit A im Namen löschen
```

**Einzelzeichen**

```bash
ls file?.txt
ls file_??.txt
```

**Brace Expansion**

```bash
touch File{1,2,3}.txt
```

Erstellt:

```bash
File1.txt
File2.txt
File3.txt
```

Bereich erstellen:

```bash
touch file{1..9}.txt
```

Verschachtelung:

```bash
touch file{original{.bak,.txt},kopie{.bak,.txt}}
```

Ergebnis:

```bash
fileoriginal.txt
fileoriginal.bak
filekopie.txt
filekopie.bak
```

---

### Checkpoint Übung 3 – Bash Expansions

Bash besitzt mehrere **Expansionen**, die vor der Ausführung eines Befehls stattfinden.

**Wichtige Expansionen:**

1. Brace Expansion  
2. Tilde Expansion  
3. Parameter Expansion  
4. Command Substitution  
5. Arithmetic Expansion  
6. Word Splitting  
7. Pathname Expansion

**Reihenfolge der Bash Expansion:**

1. Brace Expansion
2. Tilde Expansion
3. Parameter Expansion
4. Command Substitution
5. Arithmetic Expansion
6. Word Splitting
7. Pathname Expansion

Beispiele:

```bash
echo file{1..3}.txt
```

Output:

```
file1.txt file2.txt file3.txt
```

Command Substitution:

```bash
echo "Heute ist $(date)"
```

---

### Checkpoint Übung 4 – String Verarbeitung

Beispiele für Stringbearbeitung in Bash.

```bash
text="Hallo Welt"
echo ${#text}     # Länge des Strings
```

Teilstring:

```bash
echo ${text:0:5}
```

Output:

```
Hallo
```

---

### Checkpoint Übung 5 – Text Processing Tools

Wichtige Unix Tools zur Textverarbeitung.

**cut**

```bash
echo "name:alter:stadt" | cut -d ":" -f1
```

Output:

```
name
```

**tr**

```bash
echo "HALLO" | tr A-Z a-z
```

Output:

```
hallo
```

**sed**

```bash
echo "Hallo Welt" | sed 's/Welt/Linux/'
```

Output:

```
Hallo Linux
```

**awk**

```bash
echo "Max 20" | awk '{print $1}'
```

Output:

```
Max
```

---

### Checkpoint Übung 6 – Pipeline

Pipeline verbindet mehrere Befehle.

Beispiel:

```bash
cat meinFile.txt | grep hallo
```

Nur Zeilen mit "hallo".

Sortieren ohne Duplikate:

```bash
cat meinFile.txt | grep hallo | sort | uniq
```

Alle User aus `/etc/passwd` ohne irc:

```bash
cat /etc/passwd | grep -v irc | cut -d ':' -f 1
```

---

# Git Teil 2 – Shellprogrammierung

## Erstes Bash Script

Script erstellen:

```bash
touch meinscript.sh
```

Script bearbeiten:

```bash
nano meinscript.sh
```

Inhalt:

```bash
#!/bin/bash

echo "Das ist mein erstes Script"
```

Script ausführbar machen:

```bash
chmod +x meinscript.sh
```

Script starten:

```bash
./meinscript.sh
```

---

## Variablen

Variable erstellen:

```bash
name="Hans"
echo $name
```

Output:

```
Hans
```

Variable ändern:

```bash
name="Muster"
echo $name
```

---

## Datum in Variable speichern

```bash
datum=$(date +%Y_%m_%d)
echo $datum
```

Beispiel Output:

```
2026_03_12
```

Datei mit Datum erstellen:

```bash
touch file_$datum
```

---

## Arithmetische Berechnung

```bash
a=100
b=5
result=$((a / b))
echo $result
```

Output:

```
20
```

---

## If Entscheidung

```bash
#!/bin/bash

echo -n "Enter a number: "
read VAR

if [ $VAR -gt 10 ]; then
    echo "Die Zahl ist größer als 10"
elif [ $VAR -eq 10 ]; then
    echo "Die Zahl ist gleich 10"
else
    echo "Die Zahl ist kleiner als 10"
fi
```

---

## For Schleife mit Dateien

```bash
#!/bin/bash

for file in *.txt
do
    echo $file
done
```

---

## For Schleife mit Argumenten

```bash
#!/bin/bash

for datei in "$@"
do
    if [ -f $datei ]; then
        echo "$datei ist eine Datei"
    elif [ -d $datei ]; then
        echo "$datei ist ein Verzeichnis"
    else
        echo "$datei existiert nicht"
    fi
done
```

Aufruf:

```bash
./script.sh file.txt ordner test.txt
```

---

## Arrays

Array erstellen:

```bash
array=(1 2 3 4 5 6 7 8 9)
```

Array durchlaufen:

```bash
for value in ${array[*]}
do
    echo $value
done
```

Output:

```bash
1
2
3
4
5
6
7
8
9
```

---

## Ausgabe umleiten

Normale Ausgabe in Datei:

```bash
ls -la > liste.txt
```

Anhängen:

```bash
cat liste.txt >> output.txt
```

Fehlerausgabe umleiten:

```bash
./script.sh 2> errors.txt
```

Standard und Fehlerausgabe zusammen:

```bash
./script.sh > output.txt 2>&1
```

---

## Eingabe umleiten

```bash
cat < meinFile.txt
```

Kopie erstellen:

```bash
cat < meinFile.txt > kopie.txt
```

---

## Beispiel Pipeline

```bash
cat meinFile.txt | grep hallo | sort | uniq
```

---

## Script Debuggen

Script mit Debug Modus starten:

```bash
bash -x script.sh
```

Fehler anzeigen:

```bash
bash -n script.sh
```

---

## Script auf Server kopieren (SCP)

Script hochladen:

```bash
scp script.sh user@hostname:~
```

Script ausführbar machen:

```bash
chmod +x script.sh
```

Script starten:

```bash
./script.sh
```