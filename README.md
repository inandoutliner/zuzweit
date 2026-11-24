# Zu zweit

Geteilte To-do-Liste für zwei, als Web-App auf beiden iPhones. Beide tragen ein und haken ab, sortiert nach dem nächsten Anlass (z. B. „Vor dem Abflug“), innerhalb des Anlasses in Erledigen, Besorgen, Einpacken.

Online: https://inandoutliner.github.io/zuzweit/

- `index.html` – die ganze App
- `config.js` – Supabase-Adresse und öffentlicher Schlüssel (dasselbe Projekt wie Weihnachten)
- `supabase.sql` – Tabellen und Funktionen, einmal im Supabase SQL Editor ausführen
- `sw.js` – hält die App offline verfügbar (Flugzeug, Camper)

## So funktioniert's

- Jede Aufgabe gehört zu einem Anlass mit Datum oder zu „Irgendwann“. Oben steht der nächste Anlass mit Countdown.
- Zuständig: Ich, Du oder Beide (Kreis rechts antippen wechselt).
- „Neu von …“ markiert, was die andere Person seit dem letzten Öffnen eingetragen hat.
- Abhaken und Löschen lassen sich 5 Sekunden lang rückgängig machen.
- Ist ein Anlass vorbei, bietet die App an, offene Punkte zum nächsten Anlass zu verschieben.
- Ohne Netz werden Änderungen gesammelt und später abgeglichen (Anzeige oben rechts).

## Daten und Zugriff

Die Daten liegen in Supabase (Tabellen `zz_listen`, `zz_anlaesse`, `zz_aufgaben`), nicht im Repo. Die Tabellen sind direkt nicht lesbar; die App spricht nur über die Funktionen `zz_anlegen`, `zz_laden`, `zz_speichern` und muss dabei den geheimen Listen-Code aus dem Link (`#k=…`) mitschicken. Gespeichert wird nur dessen SHA-256-Wert. Der Code steht im Teil hinter `#` und geht daher nicht an GitHub Pages.

Wer den Link hat, kann die Liste lesen und ändern. Namen stehen nur in der Datenbank, nicht im Repo.

Live-Abgleich: Nach einer Änderung schickt die App ein Signal über Supabase Realtime (Broadcast), das andere iPhone lädt dann neu. Zusätzlich gleicht sie alle 20 Sekunden und beim Öffnen ab.

Inhaltskarte für Änderungen: [KARTE.md](KARTE.md)
