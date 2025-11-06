# Descriere proiect 
8. Feed-uri RSS
Date in timp real despre avertizari meteorologice pot fi descarcate prin intermediul unui feed RSS (http://www.meteoromania.ro/anm2/avertizari-rss.php) si adaugate de asemenea intr-un dashboard Web. Aceste date, astfel preluate, vor fi cuplate cu informatii meteo ce sunt disponibile pe platforme nationale in format XML. De exemplu informatii meteo despre prognoza sunt disponibile la adresa http://www.meteoromania.ro/anm/prognoza-orase-xml.php , in format XML. Servicii de sincronizare dezvoltate in cadrul temei vor descarca datele periodic, le vor interpreta siintegra in dashboard.


# Proiect Feed RSS Meteo cu Node-RED

Acest proiect folosește Node-RED pentru a prelua, procesa și afișa date meteo din surse publice.

## Cum se pornește

1.  Asigură-te că ai Docker și Docker Compose instalate.
2.  Deschide un terminal în acest director (`rss_feed`).
3.  Rulează comanda:
    ```bash
    docker-compose up -d
    ```
    La prima rulare, Docker va descărca imaginea Node-RED și va instala automat modulul de dashboard. Acest proces poate dura câteva minute.

## Accesare

*   **Editorul Node-RED**: Deschide un browser și navighează la [http://localhost:1880](http://localhost:1880)
*   **Dashboard-ul**: Va fi disponibil la [http://localhost:1880/ui](http://localhost:1880/ui) odată ce vei adăuga primele elemente de UI în flux.

## Cum se oprește

Pentru a opri containerul, rulează comanda:
```bash
docker-compose down
```
