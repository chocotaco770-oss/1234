# STEP 11 — VIVA / OOP EXPLANATION GUIDE

Everything below is traced to real files in `src/main/java/com/hospitalmanagement/`. Use it to prepare for the OOP Sessional viva — and to answer confidently *why* each design choice exists.

---

## 1. One-Paragraph Project Summary (memorize this)

> "This is an object-oriented **hospital management system** built in Java with a JavaFX desktop UI and an SQLite database. It implements the SmartCare proposal: patients, doctors, appointments, prescriptions, medical records, billing, payments, rooms, ambulances and reports — all coordinated through a layered architecture of **model → service → repository → database**. The system has three roles — Admin, Doctor and Patient — each with a role-scoped dashboard. Business rules like double-booking prevention, room allocation and payment limits are enforced in the service layer, and the design demonstrates encapsulation, inheritance, abstraction, polymorphism, interfaces, aggregation, composition and exception handling."

---

## 2. OOP Concepts → Exact Code Locations

### 2.1 Class & Object
Every screen maps to a class that is instantiated at runtime.
- **Model classes:** `model/Patient.java`, `model/Doctor.java`, `model/Appointment.java`, `model/Bill.java`, … (13 classes)
- **Objects:** `PatientService patientService = new PatientService(DatabaseManager.getInstance());` in every controller.

### 2.2 Encapsulation
- **All fields are `private`** — e.g. `Person.java` declares `private String name;` with public getters/setters.
- **State changes are guarded:** `RoomService.allocateRoom()` only changes a room to Occupied if `room.isAvailable()`; `PaymentServiceImpl` only inserts a payment if `amount <= outstanding`. The outside world cannot corrupt the state directly.

### 2.3 Inheritance
- `Person` is the **abstract superclass**; `Patient`, `Doctor`, `Admin` **extend** it:
  ```java
  public abstract class Person { ... }
  public class Patient extends Person { ... }
  ```
- Shared attributes (id, name, age, gender, phone) live in `Person`; subclasses add their own (specialization + fee for Doctor, blood group for Patient).

### 2.4 Abstraction
- `Person` declares an **abstract method**:
  ```java
  public abstract String displayInformation();
  ```
- The UI calls `selected.displayInformation()` without knowing the concrete role — `PatientController.onHistory()` does exactly this.
- **Service interfaces:** `PaymentService` and `ReportGenerator` define *what* the system does, not *how*.

### 2.5 Polymorphism
- **Method overriding (runtime polymorphism):** `Patient`, `Doctor`, `Admin` each implement `displayInformation()` differently; `Patient.updateProfile(...)` vs `Doctor.updateProfile(...)` differ in parameters.
- **Interface polymorphism:** `ReportService.getReport(ReportType)` returns `ReportGenerator`, and the caller writes:
  ```java
  ReportGenerator report = reportService.getReport(type);
  String text = report.generateReport();   // works for all 8 report types
  ```
  Adding a 9th report type requires zero changes to `ReportController` — the strongest viva answer.
- **Overloading (compile-time polymorphism):** `PatientService.searchPatient(name)` and `searchPatient(name, phone)`; `DoctorService.searchDoctor(name)` vs `searchDoctor(specialization)`.

### 2.6 Interface
- `PaymentService` (proposal-mandated) + `PaymentServiceImpl`; `ReportGenerator` + 8 implementations (`report/` package). Interfaces decouple controllers from implementations and enable polymorphism + easy testing.

### 2.7 Association (has-a, by reference)
- `Appointment` holds `patientId` and `doctorId`; `Prescription` references patient, doctor, appointment and medical record. Entities know about each other through IDs — a *weak* (association) relationship.

### 2.8 Aggregation (whole–part, independent lifecycles)
- `Hospital` aggregates hospital info; services aggregate repositories. Patients and doctors exist independently of any appointment — deleting an appointment never deletes a patient.

### 2.9 Composition (whole–part, strong ownership)
- A medical record **owns** its prescriptions. In `schema.sql`:
  ```sql
  medical_record_id INTEGER REFERENCES medical_records(record_id) ON DELETE CASCADE
  ```
  and `MedicalRecordService.deleteRecord()` deletes the record → linked prescriptions go with it. If the owner dies, the parts die.

### 2.10 Collections
- `List<Patient>`, `List<Appointment>` returned by repositories; `ObservableList` feeds JavaFX `TableView`s; `Map<Integer,String>` caches display names. Collections are for in-memory display only — **the database is the single source of truth**.

### 2.11 Exception Handling
- 10 custom exceptions (`exception/` package) — e.g. `AppointmentConflictException`, `RoomUnavailableException`, `PaymentException`.
- Controllers wrap service calls in `try/catch` and map exceptions to friendly `AlertUtil` dialogs — e.g. `PaymentController` catches `PaymentException` → "Payment Failed" dialog. `Main` installs a global uncaught-exception handler so the app never shows a raw stack trace.

### 2.12 File Handling (proposal requirement, preserved)
- The original proposal's file handling is kept where it fits the new design: **report export** (`ReportController.onExport` → `.txt`) and **database backup/restore** (`SettingsController` → `.db` file via `DatabaseManager`).

---

## 3. Layered Architecture — Why

```
FXML (view)  →  Controller  →  Service  →  Repository  →  DatabaseManager  →  SQLite
```

| Layer | Job | Proof |
|---|---|---|
| FXML | Declarative layout | `resources/fxml/*.fxml` |
| Controller | Capture input, call service, show alerts, navigate | `controller/*.java` — **no SQL, no business rules** |
| Service | Business rules + transactions + exceptions | `service/*.java` — double-booking, allocation guards, totals |
| Repository | JDBC + PreparedStatement only | `repository/*.java` — no SQL injection possible |
| DatabaseManager | Connection, schema, FK enforcement, backup/restore | `database/DatabaseManager.java` |

**Why this layering?** Each layer has one job, so changes stay local: e.g. switching SQLite → MySQL only touches repositories/DatabaseManager; adding a validation rule only touches the service; restyling only touches CSS. This is also what makes the code testable — services are tested against a temp SQLite file (`TestDatabase`).

---

## 4. Business Rules — Be Ready to Explain

1. **No double-booking:** `AppointmentService.bookAppointment` checks the same doctor at same date+time *and* the same patient at same date+time; the DB also enforces `UNIQUE(doctor_id, appointment_date, appointment_time)`. Statuses `Booked / Completed / Cancelled`.
2. **Rooms:** `allocateRoom` throws `RoomUnavailableException` for an occupied room; `releaseRoom` throws for an available room.
3. **Ambulances:** `bookAmbulance` throws `AmbulanceUnavailableException` when already booked.
4. **Billing:** `Bill.computeTotal()` = consultation + room + medicine + ambulance + other; `BillingService.generateBill` calls it. The UI never sums charges itself (live preview delegates to `billingService.previewTotal`).
5. **Payments:** amount > 0 and ≤ outstanding (`PaymentException`); a successful payment refreshes bill status Unpaid → Partially Paid → Paid.
6. **Security:** PBKDF2 password hashing (`PasswordUtil`, salt + 65,536 iterations); no plaintext passwords in DB; sessions via `SessionManager`; role-scoped dashboards.

---

## 5. Demo Walkthrough (for the live demo)

1. **Login as `admin` / `admin123`** → show dashboard cards + chart.
2. **Patients** → search "Patient Demo", open medical history.
3. **Appointments** → try booking Dr. Rahman at a time he already has an appointment → **show the conflict alert** (the money shot).
4. **Billing** → generate a bill → watch the auto-computed total.
5. **Payments** → pick the unpaid bill, try paying more than the outstanding → **show the PaymentException alert**, then pay correctly.
6. **Rooms** → allocate an occupied room → **show RoomUnavailableException**, then allocate an available one.
7. **Reports** → generate each of the 8 reports → export one to `.txt`.
8. **Settings** → backup the DB to a file.
9. **Logout** → login as `patient@hospital.com` / `patient123` → show the patient sees *only* their own data, and there is no "Settings/Reports/Patients" in the sidebar.
10. **Logout** → login as `doctor@hospital.com` / `doctor123` → create a prescription / medical record, toggle availability.

---

## 6. Likely Viva Questions + Short Answers

**Q: Why did you make `Person` abstract?**
A: It is a common template — real people are always a Patient, Doctor or Admin, never a bare "Person". Abstract lets me declare the shared `displayInformation()` contract and force subclasses to implement it (abstraction + inheritance).

**Q: What is the difference between abstract class and interface here?**
A: `Person` provides shared *state* (name, age…) and a partial implementation; `PaymentService`/`ReportGenerator` only declare *behavior*. A class can implement many interfaces but extend only one abstract class. Doctor and Patient *are* a Person (inheritance); Payment and Report are *capabilities* (interfaces).

**Q: Where is polymorphism actually used?**
A: `displayInformation()` behaves differently per role; `ReportGenerator report = reportService.getReport(type)` calls the same method on 8 different implementations; `searchPatient(name)` and `searchPatient(name, phone)` are overloads.

**Q: How do you prevent double-booking?**
A: Two layers — the service checks for an active appointment with the same doctor (and same patient) at the same date/time and throws `AppointmentConflictException`; the database has a `UNIQUE` constraint as a hard backstop. The whole booking is one transaction, so it can never be half-inserted.

**Q: Why SQLite and not files, when the proposal said file handling?**
A: The proposal's business logic and OOP design are preserved; only the delivery technology is upgraded. SQLite gives atomic transactions, foreign keys, unique constraints and fast search — none of which flat files provide reliably. File handling is kept where it fits: backup/restore and report export.

**Q: How did you secure passwords?**
A: PBKDF2 with a random 16-byte salt and 65,536 iterations, stored as `salt:hash` — the database never contains plaintext. Login verifies the hash, never compares strings.

**Q: What happens if a user with the wrong role tries an admin action?**
A: They can't reach it — the sidebar only contains role-appropriate links, every shared controller hides admin buttons unless `SessionManager.isAdmin()`, and data lists are scoped to the logged-in user. There is no admin entry point in the doctor/patient dashboards.

**Q: What would you improve next?**
A: (Good closing answer) Add JavaFX charts to reports, email/SMS reminders for appointments, a PDF invoice generator, and encryption at rest for the database. Each is a small, isolated change thanks to the layered architecture.

---

## 7. Numbers to Cite

- **13 model classes**, **10 custom exceptions**, **8 report implementations**, **17 FXML views**, **17 controllers**, **12 repositories**, **13 services**, **50 passing tests** (0 failures).
- **3 roles**, **27 sidebar links**, all audited.
- Runs with: `mvn clean javafx:run` · tests with: `mvn test`.
