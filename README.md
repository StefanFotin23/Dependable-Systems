# Descriere proiect
Date in timp real despre avertizari meteorologice pot fi descarcate prin intermediul unui feed RSS (http://www.meteoromania.ro/anm2/avertizari-rss.php) si adaugate de asemenea intr-un dashboard Web. Aceste date, astfel preluate, vor fi cuplate cu informatii meteo ce sunt disponibile pe platforme nationale in format XML. De exemplu informatii meteo despre prognoza sunt disponibile la adresa http://www.meteoromania.ro/anm/prognoza-orase-xml.php , in format XML. Servicii de sincronizare dezvoltate in cadrul temei vor descarca datele periodic, le vor interpreta si integra in dashboard.

---

# Arhitectură și Operare

Acest document descrie arhitectura și modul de operare al proiectului. Setup-ul este automatizat cu Ansible și este proiectat să funcționeze în două moduri distincte: **development** și **production**.

## Arhitectura de Ansamblu

Proiectul folosește **Kubernetes** ca platformă de orchestrare, **Ansible** pentru automatizare, și un set de unelte Cloud Native pentru a asigura fiabilitatea.

### Caracteristici de Fiabilitate (Dependability)

Proiectul este conceput pentru a oferi un sistem robust și rezilient, respectând principiile Dependable Systems.

*   **Disponibilitate (Availability):**
    *   **Failover Automat (Prod):** În modul de producție, Node-RED este configurat cu o singură replică (`Deployment`), dar utilizează Longhorn pentru stocare replicată. Dacă nodul pe care rulează pod-ul Node-RED eșuează, Kubernetes repornește automat pod-ul pe un alt nod sănătos, iar datele replicate sunt reatașate, asigurând continuitatea serviciului fără intervenție manuală.
    *   **Protecție la Disrupții:** `PodDisruptionBudget` pentru Node-RED (unde este aplicabil) asigură că un număr minim de replici (în cazul nostru, 1) rămâne disponibil în timpul unor evenimente de mentenanță controlate.
    *   **Izolare:** `PodAntiAffinity` ajută la distribuirea pod-urilor Node-RED pe noduri diferite (când sunt mai multe replici, în alte configurații), prevenind un singur punct de eșec.

*   **Fiabilitate și Durabilitate a Datelor (Reliability & Data Durability):**
    *   **Stocare Replicată (Prod):** Longhorn (în modul de producție) asigură protecția datelor prin replicarea volumelor persistente pe mai multe noduri ale clusterului. Aceasta previne pierderea datelor în cazul eșecului unui singur disc sau nod.
    *   **Backup Automat:** MinIO servește ca backend S3-compatibil pentru backup-uri. În modul de producție, Velero realizează backup-uri complete ale stării clusterului și volumelor.

*   **Recuperabilitate (Recoverability):**
    *   **Restaurare Granulară (Prod):** Velero permite restaurarea stării clusterului și a datelor aplicațiilor dintr-un backup, esențială pentru recuperarea după dezastre.
    *   **Restaurare Aplicație (Dev/Prod):** Scripturi specifice (`k8s/scripts/restore-from-s3.sh`) sunt disponibile pentru a restaura datele aplicației Node-RED (MinIO) independent de Velero.

*   **Mentenanță (Maintainability):**
    *   **Automatizare Completă:** Ansible permite instalarea, configurarea și actualizarea întregului mediu într-un mod idempotent.
    *   **Separare Dev/Prod:** Playbook-ul detectează automat mediul, simplificând deploy-ul și testarea.
    *   **Interfață Simplificată:** `Makefile` oferă o interfață ușor de utilizat pentru operații comune (`setup`, `start`, `stop`, `teardown`).
    *   **Observabilitate (Prod):** Stack-uri precum Prometheus și Loki (instalate în modul de producție) oferă monitorizare și logare centralizată, facilitând depanarea și mentenanța.

### Medii de Operare

Playbook-ul Ansible detectează automat mediul în care rulează și ajustează strategia de stocare:

1.  **Development (WSL / Local)**
    *   **Declanșator:** Rularea `make` pe un sistem WSL2.
    *   **Cluster:** Creează un cluster local folosind **KIND** (Kubernetes in Docker).
    *   **Stocare:** Folosește `local-path-provisioner` (StorageClass `standard`).
    *   **Avantaj:** Funcționează rapid, local, fără dependențe de kernel-ul gazdă.
    *   **Dezavantaj:** Stocarea nu este replicată. Pierderea unui nod duce la pierderea datelor de pe acel nod. **Nu este 'production-ready'**.

2.  **Production (GCP VM / Server Remote)**
    *   **Declanșator:** Rularea `make` pe un sistem Linux standard (non-WSL).
    *   **Cluster:** Presupune că un cluster Kubernetes (ex: **GKE**) **există deja** și este configurat în `kubectl`.
    *   **Stocare:** Instalează și configurează **Longhorn** pentru stocare distribuită, replicată și cu înaltă disponibilitate (StorageClass `longhorn-replicated`).
    *   **Backup:** Instalează și configurează **Velero** pentru backup-uri avansate ale stării cluster-ului și volumelor persistente, folosind MinIO ca backend.
    *   **Avantaj:** O arhitectură robustă, fiabilă, gata pentru producție.

## Comenzi de Operare (`make`)

Managementul proiectului este simplificat prin `Makefile`.

*   **Afișează comenzile disponibile:**
    ```bash
    make help
    ```

*   **Setup-ul Mediului:**
    Rulează playbook-ul Ansible pentru a instala și configura toate componentele.
    ```bash
    # Pentru mediul de dezvoltare (default)
    make setup

    # Pentru mediul de producție (rulează pe un VM remote)
    make setup ENV=prod
    ```

*   **Management Aplicație:**
    ```bash
    # Pornește aplicația Node-RED
    make start

    # Oprește aplicația Node-RED
    make stop
    ```

*   **Curățare Mediu de Dezvoltare:**
    *Șterge clusterul KIND local. Nu are efect în producție.*
    ```bash
    make teardown
    ```

## Workflow pentru Producție (cu GCP și GKE)

1.  **Creați un cluster GKE:** Folosiți consola Google Cloud pentru a crea un cluster Kubernetes standard.
2.  **Pregătiți un VM de Bootstrap:** Creați un VM mic (ex: e2-micro Ubuntu) în același proiect GCP.
3.  **Rulați Script-ul de Bootstrap:**
    *   Copiați script-ul `bootstrap-prod.sh` pe noul VM.
    *   Faceți-l executabil: `chmod +x bootstrap-prod.sh`.
    *   Rulați-l, oferind URL-ul repo-ului Git:
        ```bash
        ./bootstrap-prod.sh https://github.com/your-user/your-repo.git
        ```
    *   Script-ul va instala toate dependențele, va clona proiectul și va rula `make setup ENV=prod`. Playbook-ul Ansible se va conecta la clusterul GKE (asumând că `kubectl` este configurat corespunzător) și va instala aplicația în modul de producție.
