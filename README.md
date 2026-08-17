# HOSPITAL MANAGEMENT SYSTEM USING JAVA

Enhanced desktop implementation of the **SmartCare: An Object-Oriented Hospital Management System Using Java** proposal (Object Oriented Programming Sessional, CCE 122 — Patuakhali Science & Technology University).

The original console + file-handling design is preserved exactly (same 12 classes, same roles, same business rules) and delivered with a modern desktop stack: **Java + JavaFX + FXML + CSS + SQLite + JDBC + Maven**.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Java 21 (LTS) |
| UI | JavaFX 21.0.4 (Controls + FXML), custom CSS design system |
| Persistence | SQLite 3.46.x via JDBC (`org.xerial:sqlite-jdbc`) — PreparedStatements, transactions, foreign keys |
| Build | Maven (`javafx-maven-plugin` 0.0.8) |
| Tests | JUnit 5 (Jupiter 5.10.2) — run against a disposable temp SQLite file |
| Architecture | `FXML → Controller → Service → Repository → DatabaseManager → SQLite` |

No external UI libraries — charts are native JavaFX `PieChart`/`BarChart`, password hashing is PBKDF2 implemented in `PasswordUtil` (no extra dependencies).

---

## Setup & Run

### Prerequisites
- **JDK 21** (any distribution — Temurin/OpenJDK/Oracle)
- **Maven 3.9+**
- A graphical desktop environment (JavaFX is a desktop UI)

### Build & run

```bash
# Compile + launch the application (schema + demo data auto-created on first run)
mvn clean javafx:run

# Run the full test suite (50 tests: model, repository, service, auth, UI/FXML)
mvn test
```

> **Note:** this workspace ships a portable toolchain under `tools/` (JDK 21 + Maven 3.9.9) so the project builds without a system install. If `mvn` is not on your PATH, use it directly:

```bash
export JAVA_HOME="$PWD/tools/jdk-21.0.12+8"
export PATH="$JAVA_HOME/bin:$PWD/tools/apache-maven-3.9.9/bin:$PATH"
mvn clean javafx:run
```

### First launch
`Main` calls `DatabaseManager.initialize()`, which:
1. Creates `data/hospital.db` if missing,
2. Applies `schema.sql` (idempotent),
3. Seeds demo data **only when the `users` table is empty**.

To start over with fresh demo data, delete `data/hospital.db` and relaunch (or use **Settings → Restore** with a backup).

---

## Publishing to GitHub & GitHub Pages

The repo is already prepared for GitHub: a `.gitignore` keeps the heavy/generated files out (`tools/`, `target/`, `data/` — the JDK/Maven toolchain, build output and the runtime database are all regenerated), `.gitattributes` normalizes line endings, `LICENSE` (MIT) is included, and a CI workflow (`.github/workflows/ci.yml`) runs all 50 tests on every push. The website is the static portal in **`docs/`** (GitHub Pages convention).

### 1. Create the repository
Create a new repository on github.com (e.g. `hospital-management-system`). Do **not** tick "Add a README" — this project already has one.

### 2. Upload from your machine
```bash
cd <project-folder>
git init
git add .
git commit -m "Hospital Management System — Java + JavaFX + SQLite"
git branch -M main
git remote add origin https://github.com/<your-username>/hospital-management-system.git
git push -u origin main
```

### 3. Publish the website (GitHub Pages)
1. GitHub → **Settings → Pages**.
2. **Build and deployment → Source: "Deploy from a branch"**.
3. Branch: `main`, folder: **`/docs`** → **Save**.
4. After ~1 minute your site is live at `https://<your-username>.github.io/hospital-management-system/`.

The site (built from `docs/index.html`) shows the tech stack, demo credentials, architecture, OOP concepts and a gallery of **17 real screenshots** of the running application.

### 4. Two one-line edits before publishing
- In `docs/index.html`, replace `YOUR_USERNAME` in `window.REPO = "YOUR_USERNAME/hospital-management-system";` with your GitHub username — this makes the Documentation links point at your repo.
- In `LICENSE`, optionally replace the copyright holder line with your name.

> Every push to `main` automatically re-runs the 50-test suite (CI badge on the repo page). To refresh the screenshots later: run `mvn test` (regenerates `target/screenshots/*.png` + `visual-pass.html`), copy the PNGs into `docs/screenshots/`, then run `./build-site.sh` to re-inline them into the self-contained `docs/index.html`.

---

## Demo Credentials

| Role | Username | Password |
|---|---|---|
| **Admin** | `admin` | `admin123` |
| **Doctor** | `doctor@hospital.com` | `doctor123` |
| **Patient** | `patient@hospital.com` | `patient123` |

Passwords are stored as **PBKDF2 hashes** (never plaintext). These accounts are only created on a fresh database.

### Seeded demo data (first run only)
- 4 doctors (Cardiology, Dermatology, Neurology, Pediatrics) — Dr. Rahman (demo doctor) is available
- 4 patients — Patient Demo has today's + tomorrow's appointments, a medical record with a linked prescription, one **unpaid bill** (ideal for the payment demo) and one **paid bill**
- 6 rooms (General, Semi-Private, Private, ICU) and 3 ambulances

---

## Features (by role)

### Admin — full hospital management
Dashboard with live stats (patients, doctors, today's appointments, available rooms/ambulances, pending payments) + appointment status chart. Full CRUD + search for patients, doctors, appointments, prescriptions, medical records, rooms (allocate/release), ambulances (book/release), bills (auto-calculated totals), payments, **polymorphic reports with export**, and settings (hospital info, change password, **SQLite backup/restore**).

### Doctor — clinical workflow
Dashboard (today's/upcoming appointments, own prescriptions & records), manage **own** appointments (reschedule/cancel/complete), create/edit **own** prescriptions, add/edit/delete **own** medical records, toggle **own availability**, change password. No access to admin functions.

### Patient — self-service
Dashboard (upcoming appointments, prescriptions, outstanding balance, allocated room), **find doctors**, book/reschedule/cancel **own** appointments, view **own** prescriptions/medical records/bills/payments, make payment on **own** unpaid bills, request an ambulance, view rooms, change password. No access to admin functions.

---

## Project Structure

```
├── pom.xml
├── README.md
├── ARCHITECTURE.md            # Step 2 — final architecture + schema
├── REQUIREMENT_ANALYSIS.md    # Step 1 — requirement analysis (FR-1..FR-15)
├── REQUIREMENT_CHECKLIST.md   # Step 11 — verified final requirement checklist
├── VIVA_GUIDE.md              # Step 11 — viva / OOP explanation guide
├── LICENSE                    # MIT
├── docs/                      # GitHub Pages website (index.html + screenshots/)
├── .github/workflows/ci.yml   # runs all 50 tests on every push
├── data/                      # runtime-generated hospital.db
└── src/
    ├── main/java/com/hospitalmanagement/
    │   ├── Main.java                  # entry point (primary stage)
    │   ├── model/                     # 13 classes: Person (abstract) → Patient/Doctor/Admin, entities, Hospital
    │   ├── repository/                # 12 JDBC repositories (PreparedStatement only)
    │   ├── service/                   # business rules; PaymentService interface + impl
    │   ├── report/                    # ReportGenerator interface + 8 concrete reports
    │   ├── database/                  # DatabaseManager, schema.sql, SeedData
    │   ├── controller/                # 17 JavaFX controllers (role-aware)
    │   ├── exception/                 # 10 custom exceptions
    │   └── util/                      # Validator, AlertUtil, PasswordUtil, SessionManager, NavigationUtil
    ├── main/resources/
    │   ├── fxml/                      # 17 views
    │   ├── css/application.css        # full design system
    │   └── database/schema.sql
    └── test/java/com/hospitalmanagement/  # 7 test classes (50 tests)
```

---

## Key Business Rules (enforced in the service layer)

- **Appointments** — no double-booking for the same doctor *or* patient at the same date+time; no booking on past dates; statuses `Booked / Completed / Cancelled`.
- **Rooms** — an occupied room can never be allocated; an available room can never be released.
- **Ambulances** — a booked ambulance can never be booked again.
- **Billing** — total is always computed by `BillingService` (`consultation + room + medicine + ambulance + other`), never in the UI.
- **Payments** — amount must be positive and ≤ outstanding balance; paying updates the bill status (`Unpaid → Partially Paid → Paid`).
- **Auth** — hashed passwords (PBKDF2), role-based session, role-scoped dashboards.

---

## Testing

```bash
mvn test
```

| Test class | Covers |
|---|---|
| `ServiceLayerTest` (18) | auth, CRUD, appointment conflicts, room/ambulance rules, billing, payments |
| `RepositoryLayerTest` (9) | JDBC repositories against a temp SQLite file |
| `ModelLayerTest` (9) | Person hierarchy, entities, `computeTotal()` |
| `DatabaseManagerTest` (5) | schema init, seed-on-empty, backup/restore |
| `PasswordUtilTest` (5) | PBKDF2 hashing / verification |
| `SessionManagerTest` (2) | session + role checks |
| `UiFxmlLoadTest` (2) | loads all 17 FXML views through the real JavaFX toolkit; renders every screen with CSS to `visual-pass.html` |

Current status: **50 tests, 0 failures** ✅
