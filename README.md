# Descriere proiect
Date in timp real despre avertizari meteorologice pot fi descarcate prin intermediul unui feed RSS (http://www.meteoromania.ro/anm2/avertizari-rss.php) si adaugate de asemenea intr-un dashboard Web. Aceste date, astfel preluate, vor fi cuplate cu informatii meteo ce sunt disponibile pe platforme nationale in format XML. De exemplu informatii meteo despre prognoza sunt disponibile la adresa http://www.meteoromania.ro/anm/prognoza-orase-xml.php , in format XML. Servicii de sincronizare dezvoltate in cadrul temei vor descarca datele periodic, le vor interpreta si integra in dashboard.

---

# Arhitectură și Operare

Acest document descrie arhitectura sistemului și modul de operare pentru mediul de producție simulat local. Sistemul este proiectat pentru a fi fiabil, cu disponibilitate ridicată și recuperare rapidă în caz de erori (dependable system).

## 1. Arhitectura de Ansamblu

Proiectul folosește **Kubernetes** ca platformă de orchestrare a containerelor, cu toate componentele definite declarativ prin manifeste și automatizare prin Ansible. Pentru dezvoltare locală, se utilizează **KIND (Kubernetes in Docker)**.

### Componente Cheie:

*   **Ansible:** Utilizat pentru automatizarea completă a procesului de setup. Un singur playbook (`k8s/ansible/playbook.yaml`) instalează și configurează întregul mediu, de la clusterul Kubernetes până la aplicația finală.
*   **Node-RED:** Aplicația principală, configurată să ruleze într-un container pe Kubernetes. Este configurată pentru înaltă disponibilitate într-un mod **Active-Passive**.
*   **Longhorn:** O soluție de stocare distribuită (block storage) pentru Kubernetes. Asigură **persistența și replicarea datelor** pentru Node-RED. Dacă un nod din cluster eșuează, datele Node-RED sunt deja replicate pe alt nod, permițând un failover aproape instantaneu.
*   **MinIO:** Un server de stocare obiecte S3-compatibil, utilizat pentru a stoca backup-urile datelor Node-RED.
*   **Kubernetes CronJob:** Un job programat care rulează periodic pentru a crea **backup-uri automate** ale volumului Node-RED și a le salva în MinIO.

### Strategia de Fiabilitate (Dependability):

*   **Disponibilitate Ridicată (High Availability):**
    *   **Model Active-Passive:** O singură replică Node-RED este activă, montând un volum de stocare `ReadWriteOnce`.
    *   **Stocare Replicată:** Longhorn replică datele volumului pe mai multe noduri.
    *   **Failover Automat:** Dacă nodul activ eșuează, Kubernetes repornește automat pod-ul Node-RED pe un nod sănătos, unde datele sunt deja disponibile datorită Longhorn. Acest proces asigură continuitatea serviciului.
*   **Durabilitatea Datelor și Recuperare (Data Durability & Recovery):**
    *   Datele Node-RED sunt stocate pe un `PersistentVolume` gestionat de Longhorn.
    *   Backup-uri automate și periodice sunt trimise către MinIO printr-un `CronJob`, oferind o soluție de recuperare în caz de dezastru (disaster recovery). Script-ul `k8s/scripts/restore-from-s3.sh` poate fi folosit pentru a restaura datele.

## 2. Comenzi de Operare

Managementul ciclului de viață al proiectului se face simplu, prin `make`.

**Prerechizite:** Asigură-te că ai `make`, `docker`, `kubectl` și `ansible` instalate.

*   **Afișează comenzile disponibile:**
    ```bash
    make help
    ```

*   **Setup Inițial (Crearea Mediului):**
    *Creează clusterul KIND și instalează toate componentele (Longhorn, MinIO, Node-RED etc.) folosind Ansible.*
    ```bash
    make setup
    ```

*   **Pornire Aplicație (Start):**
    *Pornește aplicația Node-RED, asigurând o replică activă.*
    ```bash
    make start
    ```

*   **Oprire Aplicație (Stop):**
    *Oprește aplicația Node-RED (scalează replicele la 0), păstrând datele intacte.*
    ```bash
    make stop
    ```

*   **Ștergerea Mediului (Teardown):**
    *Șterge complet clusterul Kubernetes local.*
    ⚠️ **Atenție:** Această acțiune este distructivă.
    ```bash
    make teardown
    ```