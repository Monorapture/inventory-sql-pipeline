# ⚙️ SQL Engine-Logik: Die Execution Order

Ein entscheidender Unterschied zum Programmieren: SQL liest Code **nicht** von oben nach unten (wie Python), sondern in einer festen logischen Reihenfolge.

Das ist der Grund, warum man z.B. im `WHERE` noch keine Aliases nutzen kann, die erst im `SELECT` definiert werden (weil Schritt 2 vor Schritt 5 passiert).

## Die 8 Schritte der Abarbeitung

| Rang | Befehl | Was passiert technisch? | Logistik-Analogie 🚚 |
| :--- | :--- | :--- | :--- |
| **1.** | `FROM` & `JOIN` | **Daten laden:** Die Tabellen werden identifiziert und verknüpft (Kartesisches Produkt). | **Wareneingang:** Alle Paletten werden ungeprüft in die Halle gestellt. |
| **2.** | `WHERE` | **Rohdaten filtern:** Zeilen werden entfernt, *bevor* gerechnet wird. | **Qualitätskontrolle:** Kaputte Teile sofort aussortieren (noch in der Box). |
| **3.** | `GROUP BY` | **Aggregieren:** Zeilen werden zu logischen Päckchen zusammengefasst. | **Kommissionierung:** Alle gleichen Teile kommen auf einen Haufen. |
| **4.** | `HAVING` | **Gruppen filtern:** Ganze Päckchen werden basierend auf Aggregaten entfernt. | **Gewichtskontrolle:** "Haufen unter 5kg kommen weg." |
| **5.** | `SELECT` | **Berechnen:** Spalten auswählen, Mathematik, Window Functions (`RANK`, `NTILE`). | **Labeling:** Etiketten drucken, Preise berechnen, "Schleifchen drum". |
| **6.** | `DISTINCT` | **Duplikate entfernen:** Doppelte Ergebniszeilen werden eliminiert. | **Bereinigung:** Doppelte Lieferscheine werden geschreddert. |
| **7.** | `ORDER BY` | **Sortieren:** Die finale Liste wird in Reihenfolge gebracht. | **Verladung:** In der richtigen Reihenfolge (Tourenplan) in den LKW. |
| **8.** | `LIMIT` | **Begrenzen:** Anzahl der Zeilen wird abgeschnitten. | **Cut-Off:** "Nur die ersten 10 Paletten fahren heute mit." |

---

### 💡 Warum ist das wichtig? (Der "Scope"-Fehler)

Ein klassischer Anfängerfehler entsteht durch Unkenntnis dieser Reihenfolge:

```sql
-- ❌ FALSCH: Funktioniert nicht!
SELECT preis * 1.19 AS brutto_preis   -- Schritt 5
FROM artikel                          -- Schritt 1
WHERE brutto_preis > 100;             -- Schritt 2 (Kennt "brutto_preis" noch nicht!)