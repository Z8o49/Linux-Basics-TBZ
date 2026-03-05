# Linux Übungen - Lösungen

## Übung 1 – Navigieren in Verzeichnissen

```bash
# Ins Heimverzeichnis
cd

# Absoluter Pfad zu /var/log
cd /var/log

# Absoluter Pfad zu /etc/udev
cd /etc/udev

# Relativer Pfad zu /etc (angenommen man ist in /etc/udev)
cd ..

# Relativer Pfad zu /etc/network
cd network

# Relativer Pfad zu /dev (angenommen man ist in /etc/network)
cd ../../dev
```

---

## Übung 2 – Wildcards

```bash
# Docs-Verzeichnis im Home erstellen
mkdir ~/Docs

# Dateien file1 bis file10 erstellen
touch ~/Docs/file{1..10}

# Dateien mit '1' im Namen löschen
rm ~/Docs/*1*

# Dateien file2, file4, file7 löschen
rm ~/Docs/file{2,4,7}

# Alle restlichen Dateien löschen
rm ~/Docs/*

# Ordner-Verzeichnis erstellen
mkdir ~/Ordner

# Dateien file1 bis file10 erstellen
touch ~/Ordner/file{1..10}

# Ordner kopieren nach Ordner2
cp -r ~/Ordner ~/Ordner2

# Ordner kopieren nach Ordner2/Ordner3
mkdir -p ~/Ordner2/Ordner3
cp -r ~/Ordner ~/Ordner2/Ordner3

# Ordner in Ordner1 umbenennen
mv ~/Ordner ~/Ordner1

# Alle erstellten Verzeichnisse und Dateien löschen
rm -r ~/Docs ~/Ordner1 ~/Ordner2
```

---

## Übung 3 – Tilde Expansions

```bash
# Eigenes Home-Verzeichnis
cd ~

# Unterordner im Home
cd ~/Docs

# Home eines anderen Benutzers (z.B. 'user2')
cd ~user2
```

---

## Übung 4 – grep, cut, awk

### a) grep

Erstelle die Testdatei:

```bash
cat << EOF > test.txt
alpha1:1alpha1:alp1ha
beta2:2beta:be2ta
gamma3:3gamma:gam3ma
obelix:belixo:xobeli
asterix:sterixa:xasteri
idefix:defixi:ixidef
EOF
```

grep-Befehle:

```bash
# Zeilen mit "obelix"
grep --color=auto 'obelix' test.txt

# Zeilen mit "2"
grep --color=auto '2' test.txt

# Zeilen mit "e"
grep --color=auto 'e' test.txt

# Zeilen ohne "gamma"
grep -v 'gamma' test.txt

# Zeilen mit 1, 2 oder 3 (Regex)
grep -E '1|2|3' test.txt
```

### b) cut

```bash
# Vor dem ersten ":"
cut -d ":" -f1 test.txt

# Zwischen den beiden ":"
cut -d ":" -f2 test.txt

# Nach dem letzten ":"
cut -d ":" -f3 test.txt
```

### c) awk (dynamisch, Knobbler)

```bash
awk -F ":" '{print $(NF-1)}' test.txt
```

**Erklärung:** Gibt das vorletzte Feld aus, egal wie viele Doppelpunkte in der Zeile sind.

---

## Übung 5 – Für Fortgeschrittene

```bash
# 1. dmesg: sucht nach Mustern wie "1234:12:ab.1"
dmesg | egrep '[0-9]{4}:[0-9]{2}:[0-9a-f]{2}.[0-9]'
# Erklärung: 4 Zahlen, 2 Zahlen, 2 Hex-Zeichen, Punkt, 1 Zahl

# 2. ifconfig: sucht nach IPv4-Adressen
ifconfig | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])'
# Erklärung: extrahiert nur gültige IPv4-Adressen
```

---

## Übung 6 – stdout, stdin, stderr

### a) Datei mit << erstellen

```bash
cat << END > letters.txt
a
b
c
d
e
END
```

### b) Fehler umleiten

```bash
ls -z 2> /root/errorsLs.log
```

### c) Umleitung testen

```bash
# Datei erstellen
echo -e "Zeile1\nZeile2" > file1.txt

# Ausgabe > überschreibt
cat file1.txt > file2.txt

# Ausgabe >> hängt an
cat file1.txt >> file2.txt
```

**Wichtige Unterschiede:**

- `>` überschreibt die Datei
- `>>` hängt Inhalte an
- Bei mehrfacher Verwendung von `>` wird der Inhalt überschrieben

### d) whoami in info.txt

```bash
whoami > info.txt
```

### e) id an info.txt anhängen

```bash
id >> info.txt
```

### f) wc zur Zählung von Wörtern

```bash
wc -w < info.txt
```
