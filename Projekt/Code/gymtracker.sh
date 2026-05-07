#!/bin/bash
# =============================================================================
# GymTracker CLI - Workout Tracking Tool
# Modul: M122 - Grundlagen der Scriptsprache BASH
# Autor: Mattia Tuor
# Datum: 2026-05-07
# Version: 1.0
# =============================================================================

# ---- Konfiguration -----------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/gymtracker_data"
WORKOUTS_FILE="$DATA_DIR/workouts.csv"
LOG_FILE="$DATA_DIR/gymtracker.log"
RECORDS_FILE="$DATA_DIR/records.csv"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

EXERCISES=("Bankdruecken" "Kniebeugen" "Kreuzheben" "Schulterpress"
           "Klimmzuege" "Bizepscurls" "Trizepsdruecken" "Beinpress"
           "Lat-Pulldown" "Rudern" "Eigene Uebung")

# ---- Hilfsfunktionen ---------------------------------------------------------

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$1] $2" >> "$LOG_FILE"
}

print_header() {
    clear
    echo -e "${CYAN}================================================${NC}"
    echo -e "${BOLD}       🏋️  GymTracker CLI - Workout Journal${NC}"
    echo -e "${CYAN}================================================${NC}\n"
}

press_enter() {
    echo -e "\n${YELLOW}[Enter druecken...]${NC}"
    read -r
}

init_data() {
    [ ! -d "$DATA_DIR" ] && mkdir -p "$DATA_DIR"
    [ ! -f "$WORKOUTS_FILE" ] && echo "datum,uebung,gewicht_kg,saetze,wiederholungen,notiz" > "$WORKOUTS_FILE"
    [ ! -f "$RECORDS_FILE" ]  && echo "uebung,max_gewicht_kg,datum" > "$RECORDS_FILE"
    [ ! -f "$LOG_FILE" ]      && touch "$LOG_FILE"
}

validate_number() {
    [[ "$1" =~ ^[0-9]+(\.[0-9]+)?$ ]] && (( $(echo "$1 > 0" | bc -l) ))
}

update_record() {
    local exercise="$1" weight="$2" date="$3"
    local current
    current=$(grep "^${exercise}," "$RECORDS_FILE" 2>/dev/null | head -1 | cut -d',' -f2)

    if [ -z "$current" ]; then
        echo "${exercise},${weight},${date}" >> "$RECORDS_FILE"
        echo -e "${GREEN}🏆 Neue Uebung eingetragen: ${exercise} mit ${weight}kg!${NC}"
    elif (( $(echo "$weight > $current" | bc -l) )); then
        local tmp
        tmp=$(mktemp)
        grep -v "^${exercise}," "$RECORDS_FILE" > "$tmp"
        echo "${exercise},${weight},${date}" >> "$tmp"
        mv "$tmp" "$RECORDS_FILE"
        echo -e "${GREEN}🏆 NEUER REKORD fuer ${exercise}: ${weight}kg (vorher: ${current}kg)!${NC}"
    fi
}

# ---- Hauptfunktionen ---------------------------------------------------------

add_workout() {
    print_header
    echo -e "${BOLD}📝 Neues Workout eintragen${NC}\n"

    local date
    date=$(date "+%Y-%m-%d")
    echo -e "Datum: ${CYAN}$date${NC}\n"

    # Uebung auswaehlen
    local i=1
    for ex in "${EXERCISES[@]}"; do
        echo -e "  ${CYAN}[$i]${NC} $ex"
        ((i++))
    done

    local choice
    while true; do
        read -rp $'\nAuswahl (1-'"${#EXERCISES[@]}"'): ' choice
        [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#EXERCISES[@]}" ] && break
        echo -e "${RED}Ungueltige Eingabe.${NC}"
    done

    local exercise="${EXERCISES[$((choice-1))]}"
    if [ "$exercise" = "Eigene Uebung" ]; then
        read -rp "Name der Uebung: " exercise
        if [ -z "$exercise" ]; then
            echo -e "${RED}Kein Name eingegeben. Abbruch.${NC}"
            press_enter; return
        fi
    fi

    # Gewicht, Saetze, Wiederholungen einlesen
    local weight sets reps note
    while true; do
        read -rp "Gewicht in kg (z.B. 80.5): " weight
        validate_number "$weight" && break
        echo -e "${RED}Bitte eine positive Zahl eingeben.${NC}"
    done

    while true; do
        read -rp "Anzahl Saetze: " sets
        [[ "$sets" =~ ^[1-9][0-9]*$ ]] && break
        echo -e "${RED}Bitte eine ganze Zahl > 0 eingeben.${NC}"
    done

    while true; do
        read -rp "Wiederholungen pro Satz: " reps
        [[ "$reps" =~ ^[1-9][0-9]*$ ]] && break
        echo -e "${RED}Bitte eine ganze Zahl > 0 eingeben.${NC}"
    done

    read -rp "Notiz (optional): " note
    note="${note//,/;}"

    echo "${date},${exercise},${weight},${sets},${reps},${note}" >> "$WORKOUTS_FILE"
    log_message "INFO" "Workout: $exercise ${weight}kg ${sets}x${reps}"

    update_record "$exercise" "$weight" "$date"

    local volume
    volume=$(echo "$weight * $sets * $reps" | bc)
    echo -e "\n${GREEN}✅ Gespeichert! Volumen: ${volume}kg${NC}"
    press_enter
}

show_history() {
    print_header
    echo -e "${BOLD}📅 Workout-Historie (letzte 20 Eintraege)${NC}\n"

    local count
    count=$(tail -n +2 "$WORKOUTS_FILE" | wc -l)
    if [ "$count" -eq 0 ]; then
        echo -e "${YELLOW}Noch keine Workouts vorhanden.${NC}"
        press_enter; return
    fi

    printf "${BOLD}%-12s %-20s %-10s %-6s %-6s %s${NC}\n" "Datum" "Uebung" "Gewicht" "Saetze" "Wdh" "Notiz"
    echo "--------------------------------------------------------------------"
    tail -n +2 "$WORKOUTS_FILE" | tail -20 | while IFS=',' read -r d e w s r n; do
        printf "%-12s %-20s %-10s %-6s %-6s %s\n" "$d" "$e" "${w}kg" "$s" "$r" "$n"
    done
    echo -e "\nGesamt: ${CYAN}$count${NC} Eintraege"
    press_enter
}

show_records() {
    print_header
    echo -e "${BOLD}🏆 Persoenliche Bestleistungen${NC}\n"

    local count
    count=$(tail -n +2 "$RECORDS_FILE" | wc -l)
    if [ "$count" -eq 0 ]; then
        echo -e "${YELLOW}Noch keine Bestleistungen vorhanden.${NC}"
        press_enter; return
    fi

    printf "${BOLD}%-25s %-15s %s${NC}\n" "Uebung" "Bestgewicht" "Datum"
    echo "----------------------------------------------"
    tail -n +2 "$RECORDS_FILE" | sort -t',' -k2 -rn | while IFS=',' read -r e w d; do
        printf "%-25s ${GREEN}%-15s${NC} %s\n" "$e" "${w}kg" "$d"
    done
    press_enter
}

show_weekly_stats() {
    print_header
    echo -e "${BOLD}📊 Wochen-Statistik${NC}\n"

    local week_start
    week_start=$(date -d "last monday" "+%Y-%m-%d" 2>/dev/null || date "+%Y-%m-%d")
    local current_week
    current_week=$(date "+%Y-W%V")

    echo -e "Aktuelle Woche: ${CYAN}$current_week${NC}\n"

    local count volume
    count=$(tail -n +2 "$WORKOUTS_FILE" | awk -F',' -v s="$week_start" '$1 >= s' | wc -l)
    volume=$(tail -n +2 "$WORKOUTS_FILE" | awk -F',' -v s="$week_start" '$1 >= s { v += $3*$4*$5 } END { printf "%.1f", v }')

    echo -e "Trainingseinheiten: ${CYAN}$count${NC}"
    echo -e "Gesamtvolumen:      ${CYAN}${volume}kg${NC}\n"

    echo -e "${BOLD}Letzte 4 Wochen:${NC}"
    for i in 0 1 2 3; do
        local label wstart wend wcount bar=""
        label=$(date -d "$((i*7)) days ago" "+%Y-W%V" 2>/dev/null || date "+%Y-W%V")
        wstart=$(date -d "$((i*7)) days ago monday" "+%Y-%m-%d" 2>/dev/null || date "+%Y-%m-%d")
        wend=$(date -d "$((i*7-6)) days ago" "+%Y-%m-%d" 2>/dev/null || date "+%Y-%m-%d")
        wcount=$(tail -n +2 "$WORKOUTS_FILE" | awk -F',' -v s="$wstart" -v e="$wend" '$1>=s && $1<=e {c++} END{print c+0}')
        for ((j=0; j<wcount; j++)); do bar="${bar}█"; done

        if [ "$i" -eq 0 ]; then
            printf "  ${GREEN}%-10s${NC} | %-8s (%d)\n" "$label" "$bar" "$wcount"
        else
            printf "  %-10s | %-8s (%d)\n" "$label" "$bar" "$wcount"
        fi
    done
    press_enter
}

show_exercise_progress() {
    print_header
    echo -e "${BOLD}📈 Fortschritt einer Uebung${NC}\n"

    local -a list
    mapfile -t list < <(tail -n +2 "$WORKOUTS_FILE" | cut -d',' -f2 | sort -u)

    if [ ${#list[@]} -eq 0 ]; then
        echo -e "${YELLOW}Noch keine Workouts vorhanden.${NC}"
        press_enter; return
    fi

    local i=1
    for ex in "${list[@]}"; do
        echo -e "  ${CYAN}[$i]${NC} $ex"; ((i++))
    done

    local choice
    while true; do
        read -rp $'\nAuswahl (1-'"${#list[@]}"'): ' choice
        [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#list[@]}" ] && break
        echo -e "${RED}Ungueltige Eingabe.${NC}"
    done

    local selected="${list[$((choice-1))]}"
    echo -e "\nFortschritt: ${CYAN}${BOLD}$selected${NC}"
    echo "--------------------------------------------"
    printf "${BOLD}%-12s %-10s %-6s %-6s %s${NC}\n" "Datum" "Gewicht" "Saetze" "Wdh" "Volumen"
    echo "--------------------------------------------"

    local count=0
    while IFS=',' read -r d e w s r n; do
        if [ "$e" = "$selected" ]; then
            local vol
            vol=$(echo "$w * $s * $r" | bc)
            printf "%-12s %-10s %-6s %-6s %s\n" "$d" "${w}kg" "$s" "$r" "${vol}kg"
            ((count++))
        fi
    done < <(tail -n +2 "$WORKOUTS_FILE")

    echo -e "\nEintraege: ${CYAN}$count${NC}"

    if [ "$count" -ge 2 ]; then
        local first last diff
        first=$(grep ",${selected}," "$WORKOUTS_FILE" | head -1 | cut -d',' -f3)
        last=$(grep ",${selected}," "$WORKOUTS_FILE" | tail -1 | cut -d',' -f3)
        diff=$(echo "$last - $first" | bc)
        if (( $(echo "$diff > 0" | bc -l) )); then
            echo -e "Fortschritt: ${GREEN}+${diff}kg seit dem ersten Eintrag 💪${NC}"
        elif (( $(echo "$diff < 0" | bc -l) )); then
            echo -e "Fortschritt: ${RED}${diff}kg seit dem ersten Eintrag${NC}"
        else
            echo -e "Fortschritt: ${YELLOW}Unveraendert${NC}"
        fi
    fi
    press_enter
}

generate_report() {
    print_header
    echo -e "${BOLD}📋 Bericht generieren${NC}\n"

    local report="$DATA_DIR/bericht_$(date '+%Y-%m-%d').txt"
    {
        echo "=========================================="
        echo "  GYMTRACKER - BERICHT  |  $(date '+%Y-%m-%d %H:%M')"
        echo "=========================================="
        echo ""
        echo "Eintraege gesamt: $(tail -n +2 "$WORKOUTS_FILE" | wc -l)"
        echo ""
        echo "--- BESTLEISTUNGEN ---"
        tail -n +2 "$RECORDS_FILE" | sort -t',' -k2 -rn | while IFS=',' read -r e w d; do
            printf "%-25s %skg  (%s)\n" "$e" "$w" "$d"
        done
        echo ""
        echo "--- LETZTE 10 WORKOUTS ---"
        printf "%-12s %-20s %-10s %-6s %s\n" "Datum" "Uebung" "Gewicht" "Saetze" "Wdh"
        echo "----------------------------------------------------"
        tail -n +2 "$WORKOUTS_FILE" | tail -10 | while IFS=',' read -r d e w s r n; do
            printf "%-12s %-20s %-10s %-6s %s\n" "$d" "$e" "${w}kg" "$s" "$r"
        done
        echo ""
        echo "=========================================="
    } > "$report"

    log_message "INFO" "Bericht erstellt: $report"
    echo -e "${GREEN}✅ Bericht gespeichert: ${CYAN}$report${NC}\n"
    read -rp "Bericht anzeigen? (j/n): " yn
    [[ "$yn" =~ ^[jJyY]$ ]] && cat "$report"
    press_enter
}

setup_cronjob() {
    print_header
    echo -e "${BOLD}⏰ Cronjob einrichten${NC}\n"
    echo -e "Richtet zwei Cronjobs ein:"
    echo -e "  • Taeglich 08:00 – Reminder ins Log"
    echo -e "  • Sonntag 20:00  – Automatischer Bericht\n"

    local script_path
    script_path="$(realpath "$0")"
    local current_cron
    current_cron=$(crontab -l 2>/dev/null || echo "")

    if echo "$current_cron" | grep -q "gymtracker"; then
        echo -e "${YELLOW}Cronjob bereits vorhanden:${NC}"
        echo "$current_cron" | grep "gymtracker"
        read -rp $'\nErsetzen? (j/n): ' yn
        [[ ! "$yn" =~ ^[jJyY]$ ]] && press_enter && return
        current_cron=$(echo "$current_cron" | grep -v "gymtracker")
    fi

    printf '%s\n' "$current_cron" \
        "# GymTracker - Reminder (08:00)" \
        "0 8 * * * echo \"[\$(date '+\%Y-\%m-\%d \%H:\%M:\%S')] [REMINDER] Vergiss dein Training nicht!\" >> $DATA_DIR/gymtracker.log" \
        "# GymTracker - Wochenbericht (Sonntag 20:00)" \
        "0 20 * * 0 $script_path --report >> $DATA_DIR/gymtracker.log 2>&1" | crontab -

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Cronjob eingerichtet!${NC}"
        log_message "INFO" "Cronjob eingerichtet"
    else
        echo -e "${RED}❌ Fehler beim Einrichten.${NC}"
        log_message "ERROR" "Cronjob fehlgeschlagen"
    fi
    press_enter
}

reset_data() {
    print_header
    echo -e "${RED}${BOLD}⚠️  Alle Daten loeschen${NC}\n"
    echo -e "${RED}Diese Aktion loescht ALLE Workouts, Bestleistungen und Logs!${NC}\n"
    read -rp "Zur Bestaetigung 'LOESCHEN' eingeben: " confirm

    if [ "$confirm" = "LOESCHEN" ]; then
        rm -f "$WORKOUTS_FILE" "$RECORDS_FILE" "$LOG_FILE"
        init_data
        echo -e "${GREEN}Alle Daten geloescht und neu initialisiert.${NC}"
        log_message "WARN" "Alle Daten zurueckgesetzt"
    else
        echo -e "${YELLOW}Abgebrochen.${NC}"
    fi
    press_enter
}

# ---- Hauptmenue --------------------------------------------------------------

show_menu() {
    print_header

    local total today_date today_count
    total=$(tail -n +2 "$WORKOUTS_FILE" 2>/dev/null | wc -l)
    today_date=$(date "+%Y-%m-%d")
    today_count=$(grep "^$today_date," "$WORKOUTS_FILE" 2>/dev/null | wc -l)

    echo -e "  Eintraege: ${CYAN}$total${NC}  |  Heute: ${CYAN}$today_count${NC}  |  ${YELLOW}$(date '+%d.%m.%Y')${NC}\n"
    echo -e "  ${CYAN}[1]${NC} 📝 Workout eintragen"
    echo -e "  ${CYAN}[2]${NC} 📅 Historie anzeigen"
    echo -e "  ${CYAN}[3]${NC} 🏆 Bestleistungen"
    echo -e "  ${CYAN}[4]${NC} 📊 Wochen-Statistik"
    echo -e "  ${CYAN}[5]${NC} 📈 Fortschritt einer Uebung"
    echo -e "  ${CYAN}[6]${NC} 📋 Bericht generieren"
    echo -e "  ${CYAN}[7]${NC} ⏰ Cronjob einrichten"
    echo -e "  ${CYAN}[8]${NC} 🗑️  Alle Daten loeschen"
    echo -e "  ${CYAN}[0]${NC} 🚪 Beenden\n"
    read -rp "  Auswahl: " choice
    echo "$choice"
}

# ---- Start -------------------------------------------------------------------

if [ "$1" = "--report" ]; then
    init_data
    log_message "INFO" "Automatischer Bericht via Cronjob"
    exit 0
fi

init_data
log_message "INFO" "GymTracker gestartet"

while true; do
    choice=$(show_menu)
    case "$choice" in
        1) add_workout ;;
        2) show_history ;;
        3) show_records ;;
        4) show_weekly_stats ;;
        5) show_exercise_progress ;;
        6) generate_report ;;
        7) setup_cronjob ;;
        8) reset_data ;;
        0)
            echo -e "\n${GREEN}💪 Stay strong! Tschuess!${NC}\n"
            log_message "INFO" "GymTracker beendet"
            exit 0
            ;;
        *) echo -e "${RED}Ungueltige Eingabe.${NC}"; sleep 1 ;;
    esac
done