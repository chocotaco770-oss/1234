# STEP 1 — REQUIREMENT ANALYSIS

**Source document:** *SmartCare: An Object-Oriented Hospital Management System Using Java*
(Course: Object Oriented Programming Sessional, CCE 122 — Patuakhali Science & Technology University)

**Final project name:** HOSPITAL MANAGEMENT SYSTEM USING JAVA
**Implementation type:** Enhanced — Java + JavaFX + FXML + CSS + SQLite + JDBC + Maven
(Original: console-based Java with File Handling)

---

## 1. Project Overview

The proposal describes a desktop hospital management system that automates the core daily operations of a hospital:

- Patient registration and record keeping
- Doctor management with specializations
- Appointment scheduling between patients and doctors
- Prescription generation
- Medical record / treatment history maintenance
- Automatic bill calculation
- Room allocation
- Ambulance service management
- Payment processing
- Search, update, delete and reporting

The original design is fully object-oriented: 12 meaningful classes organized around a `Person` hierarchy, with `Hospital` acting as the central coordinating class. The proposal's stated problems — duplicated/misplaced patient records, appointment conflicts, billing errors, slow medical-history retrieval, uncoordinated room allocation, unmonitored ambulance availability, and manual reporting — are the exact problems the implementation must solve.

**Enhancement scope (unchanged business logic, upgraded technology):**

| Aspect | Original (proposal) | Enhanced (this project) |
|---|---|---|
| UI | Console-based (`MainMenu`) | JavaFX desktop app (FXML + CSS) |
| Storage | Java File Handling | SQLite database via JDBC |
| Build | Manual compilation | Maven (`pom.xml`) |
| Layers | Model + Service + FileManager | Controller → Service → Repository → Database |
| Persistence role of files | Primary storage | Backup/restore + optional report export only |

Every functional and OOP requirement of the proposal is preserved; only the delivery technology is upgraded.

---

## 2. Functional Requirements

Derived from the proposal's functional objectives, proposed features, and use cases.

**FR-1 Patient Registration & Management** — register, update, search, delete, and view patients; track blood group, disease, address, emergency contact.
**FR-2 Doctor Management** — add, edit, remove, search doctors; manage specialization, experience, consultation fee, license, availability.
**FR-3 Appointment Scheduling** — book, update, cancel, complete, reschedule appointments between a patient and a doctor; block doctor and patient double-booking; block invalid past dates.
**FR-4 Prescription Management** — create, update, print/view prescriptions (medicine list, dosage, advice).
**FR-5 Medical Record Management** — add, update, view records (diagnosis, treatment, test report, notes); chronological patient medical history.
**FR-6 Billing** — automatic bill calculation (consultation fee + room charge + medicine cost + ambulance charge + other charges) and invoice generation.
**FR-7 Payment Processing** — record simulated payments (method, amount, status, date); interface-driven (`PaymentService`); prevents over/under/negative payment.
**FR-8 Room Allocation** — add, update, view rooms; allocate/release; never allocate an occupied room; track daily charge and occupant.
**FR-9 Ambulance Management** — add, update, delete, view, search, book, release ambulances; prevent booking an unavailable ambulance.
**FR-10 Search / Update / Delete** — every major entity supports search (ID, name, phone, specialization, date, status…) and CRUD.
**FR-11 Authentication & Role-Based Access** — Admin / Doctor / Patient login with username/email + password, hashed passwords, session management, logout, role-scoped dashboards.
**FR-12 Reporting** — patient, doctor, appointment, billing, payment, room, ambulance, medical-record reports over real DB data (polymorphic `ReportGenerator`).
**FR-13 Database Backup / Restore** — copy SQLite file safely with confirmation; reinitialize after restore.
**FR-14 Input Validation & Exception Handling** — validated forms and user-friendly error messages mapped from custom exceptions.
**FR-15 Demo Data** — seeded sample admin/doctor/patient credentials on first launch.

---

## 3. User Roles

### 3.1 Administrator (Admin)
Dashboard with summary cards; full CRUD + search over patients and doctors; appointment management (view, search, update, cancel, monitor status); room management (add/update/allocate/release/view available/occupied); ambulance management (add/update/delete/book/release/view); billing (view, generate, payment status); all reports; settings (change password, DB backup, DB restore, app info).

### 3.2 Doctor
Profile view/limited update; view today's and upcoming appointments; view patient information; examine patient; create/update prescriptions; view/add/update medical records; diagnosis & treatment history; view test reports; manage own availability. **No access to admin functions.**

### 3.3 Patient
Profile view + update allowed fields; search doctors (specialization, availability); book appointments; view/cancel own appointments (where permitted); view own prescriptions, medical records, bills, payment status; make/record payment; request ambulance; view allocated room. **No access to admin functions.**

---

## 4. Major Modules

| # | Module | Core classes (per proposal) | Key operations |
|---|---|---|---|
| 1 | Patient Management | Patient, Hospital | register, update, search, delete, view history |
| 2 | Doctor Management | Doctor, Admin | add, edit, remove, search, specialization, fee, availability |
| 3 | Appointment Management | Appointment, Patient, Doctor | book, update, cancel, complete, conflict prevention |
| 4 | Prescription Management | Prescription | create, update, view/print |
| 5 | Medical Record Management | MedicalRecord | add, update, view, chronological history |
| 6 | Billing | Bill | calculate, invoice, status |
| 7 | Payment | Payment, PaymentService | process, status, history |
| 8 | Room Allocation | Room | add, update, allocate, release, availability |
| 9 | Ambulance Management | Ambulance | add, update, delete, book, release, search |
| 10 | Hospital / Reporting | Hospital, ReportGenerator | central info, reports |

**System workflow (from proposal, preserved):**
Patient Registration → Doctor Selection → Appointment Booking → Doctor Examination → Prescription Generation → Medical Record Update → Room Allocation (if required) → Bill Generation → Payment Processing → Discharge / Follow-up.

---

## 5. Major Classes (Model Layer)

| Class | Kind | Key attributes (proposal + enhancement) |
|---|---|---|
| `Person` | **abstract** | personId, name, age, gender, phone; abstract `displayInformation()`, `updateProfile()`; login/logout |
| `Patient` | extends Person | patientId, bloodGroup, disease, address, emergencyContact, email |
| `Doctor` | extends Person | doctorId, specialization, experience, consultationFee, licenseNumber, availability |
| `Admin` | extends Person | adminId, username, passwordHash |
| `Appointment` | entity | appointmentId, patientId, doctorId, date, time, status, reason, createdAt |
| `Prescription` | entity | prescriptionId, patientId, doctorId, appointmentId, medicineList, dosage, advice, createdDate |
| `MedicalRecord` | entity | recordId, patientId, doctorId, diagnosis, treatment, testReport, notes, recordDate |
| `Bill` | entity | billId, patientId, appointmentId, consultationFee, roomCharge, medicineCost, ambulanceCharge, otherCharges, totalAmount, billDate, status |
| `Payment` | entity | paymentId, billId, patientId, amount, paymentMethod, paymentStatus, paymentDate |
| `Room` | entity | roomNumber, roomType, availability, patientId, dailyCharge |
| `Ambulance` | entity | ambulanceId, driverName, driverPhone, ambulanceType, availability, charge |
| `Hospital` | aggregator | hospitalName, location, contactNumber; coordinates patients, doctors, rooms, ambulances, reports |

Models are **plain domain objects** (encapsulated fields, constructors, getters/setters, `toString`); business logic lives in services, SQL lives in repositories.

---

## 6. OOP Concepts — Where Each Is Demonstrated

| Concept | Implementation in the enhanced project |
|---|---|
| Class & Object | 12 model classes + services/repositories as objects |
| Encapsulation | All fields private; getters/setters; controlled state changes (e.g., `allocateRoom()` only when available); validation in setters/services |
| Inheritance | `Person` (abstract) → `Patient`, `Doctor`, `Admin` |
| Abstraction | Abstract `Person` with abstract `displayInformation()`; service interfaces |
| Polymorphism | `displayInformation()` overridden per role; `PaymentService` interface → `PaymentServiceImpl`; `ReportGenerator` interface → 8 report implementations; `Person`-typed collections |
| Interface | `PaymentService` (required by proposal), `ReportGenerator` (enhancement) |
| Association | `Patient` ↔ `Appointment` ↔ `Doctor` (by ID references) |
| Aggregation | `Hospital` holds collections of patients, doctors, rooms, ambulances (independent lifecycles) |
| Composition | `MedicalRecord` strongly owns its `Prescription`/`Bill` records (record deleted → its prescriptions/bills deleted) |
| Collections | `List<Patient>`, `ArrayList<Appointment>`, `Map` for dashboard counts; query results → TableView observable lists; never the primary storage |
| Method Overloading | e.g., `searchPatient(name)`, `searchPatient(name, phone)`; `generateBill(...)` overloads |
| Method Overriding | `displayInformation()`, `updateProfile()`, `toString()` in subclasses |
| Exception Handling | Custom exceptions → caught in controllers → user-friendly alerts |
| Input Validation | `Validator` utility (phone, email, age, fees, amounts, dates, times, IDs) |

---

## 7. Database Entities (SQLite)

| Table | Purpose | Key constraints |
|---|---|---|
| `users` | login (username/email, password hash, role) + link to profile | PK, UNIQUE username/email, role CHECK |
| `patients` | patient profiles | PK, UNIQUE patient_id, NOT NULL fields |
| `doctors` | doctor profiles | PK, UNIQUE doctor_id, NOT NULL fields |
| `admins` | admin profiles | PK, UNIQUE username |
| `appointments` | scheduling | PK, FK patient/doctor, status CHECK, date/time |
| `prescriptions` | prescriptions | PK, FK patient/doctor/appointment |
| `medical_records` | treatment history | PK, FK patient/doctor, record_date |
| `bills` | invoices | PK, FK patient/appointment, computed total |
| `payments` | payments | PK, FK bill/patient, amount CHECK |
| `rooms` | room registry | PK room_number, availability, daily charge |
| `ambulances` | ambulance registry | PK, driver info, availability, charge |

Rules: primary keys, foreign keys (enabled per connection), UNIQUE, NOT NULL, CHECK constraints; **PreparedStatement only** (no SQL injection); transactions for multi-step operations (appointment booking, room allocation, payment).

---

## 8. Relationships

- **Inheritance:** `Person` ← `Patient`, `Doctor`, `Admin`.
- **Association (many-to-one):** Appointment references Patient and Doctor; Prescription references Patient, Doctor, Appointment; MedicalRecord references Patient, Doctor; Bill references Patient and Appointment; Payment references Bill and Patient.
- **Aggregation:** `Hospital` contains `Patient`, `Doctor`, `Room`, `Ambulance` collections (these exist independently of Hospital).
- **Composition:** deleting a MedicalRecord cascades its Prescriptions (strong ownership).
- **Login link:** `users.role` + profile FK → patients/doctors/admins table.

---

## 9. UI Screens (JavaFX)

1. **Login** — username/email + password, error message, role routing.
2. **Admin Dashboard** — sidebar navigation (Dashboard, Patients, Doctors, Appointments, Prescriptions, Medical Records, Billing, Payments, Rooms, Ambulances, Reports, Settings); summary cards (total patients, total doctors, today's appointments, available rooms, available ambulances, pending payments).
3. **Patient Management** — TableView + search + add/edit/delete + details + medical history.
4. **Doctor Management** — TableView + search + add/edit/delete + specialization/fee/availability.
5. **Appointment Management** — book (patient/doctor/date/time/reason), update, cancel, search, status.
6. **Prescription Management** — doctor: select patient, medicine, dosage, advice, save/edit; patient: view.
7. **Medical Record Management** — diagnosis/treatment/test/notes/date; add/update/view/search; chronological history.
8. **Billing** — charge breakdown, auto total, generate bill, status.
9. **Payment** — bill, patient, amount, method, status, date; simulated processing.
10. **Room Management** — table, allocate, release, availability filters.
11. **Ambulance Management** — table, book, release, availability filters.
12. **Reports** — choose report type (polymorphic generators), TableView + charts.
13. **Doctor Dashboard** — today's/upcoming appointments, examine patient, prescriptions, records, availability.
14. **Patient Dashboard** — profile, doctor search, book/view/cancel appointments, prescriptions, records, bills, payments, ambulance, room.

Navigation via a single primary stage + reusable `NavigationUtil`; logout returns to Login; no duplicate stages.

---

## 10. Business Rules (Enforced in Service Layer)

- **Appointments:** no two active appointments for the same doctor at the same date+time; same for a patient; no booking on invalid past dates; statuses: BOOKED / COMPLETED / CANCELLED.
- **Rooms:** never allocate an occupied room; never release an available room (`RoomUnavailableException`).
- **Ambulances:** never book an unavailable ambulance (`AmbulanceUnavailableException`).
- **Patients/Doctors:** unique IDs; required-field validation (`InvalidPatientException`, `PatientNotFoundException`, `DoctorNotFoundException`).
- **Billing:** total = consultationFee + roomCharge + medicineCost + ambulanceCharge + otherCharges — calculated in `BillingService`, never in controllers.
- **Payments:** amount > 0; amount ≤ outstanding balance (`PaymentException`); paying a bill updates bill status to PAID/PARTIAL.
- **Auth:** invalid credentials → `InvalidLoginException`; hashed passwords; session tracked in `SessionManager`.

---

## 11. Enhanced Architecture (Layered)

```
FXML (views)
   ↓
Controller (input capture, validation display, service calls, navigation)
   ↓
Service (business rules, coordination, exceptions)
   ↓
Repository (JDBC + PreparedStatement, result mapping)
   ↓
DatabaseManager (connection, schema init, FK enable, backup/restore)
   ↓
SQLite (data/hospital.db)
```

| Layer | Contents |
|---|---|
| `model` | 12 entities (proposal classes) |
| `repository` | User, Patient, Doctor, Appointment, Prescription, MedicalRecord, Bill, Payment, Room, Ambulance |
| `service` | Authentication, Hospital, Patient, Doctor, Appointment, Prescription, MedicalRecord, Billing, Room, Ambulance, Payment (+Impl), Report |
| `report` | `ReportGenerator` interface + 8 concrete reports |
| `database` | `DatabaseManager`, `schema.sql` |
| `controller` | Login, Admin/Doctor/Patient dashboards, Patient, Doctor, Appointment, Prescription, MedicalRecord, Billing, Payment, Room, Ambulance, Report, Settings |
| `exception` | InvalidLogin, InvalidPatient, PatientNotFound, DoctorNotFound, RoomUnavailable, AmbulanceUnavailable, AppointmentConflict, Payment, Validation |
| `util` | Validator, AlertUtil, PasswordUtil, SessionManager, NavigationUtil |
| `resources` | `fxml/*`, `css/application.css`, `database/schema.sql` |
| root | `pom.xml`, `README.md`, `data/hospital.db` (generated) |

---

## 12. Original Proposal vs. Enhanced Implementation

| Concern | Original (SmartCare proposal) | Enhanced (this project) |
|---|---|---|
| Interface | Console menu (`MainMenu`) | JavaFX: FXML + CSS, 14+ screens |
| Persistence | Java File Handling | SQLite + JDBC (PreparedStatement, transactions, FKs) |
| File handling role | Primary storage | DB backup/restore + report export |
| Build/run | IDE run | Maven (`mvn clean javafx:run`) |
| Login | none specified | `users` table, PBKDF2/SHA hashing, sessions, role routing |
| Appointments | book/cancel/update | + conflict prevention (doctor & patient double-booking), statuses |
| Billing | manual calculation | `BillingService` auto-calculation |
| Reports | `generateReport()` on Hospital/Admin | Polymorphic `ReportGenerator` + charts |
| Exception handling | 2 custom exceptions | 9 custom exceptions, mapped to user alerts |
| Architecture | model / service / FileManager | FXML → Controller → Service → Repository → DB |
| Extra (within scope) | — | dashboards, demo data, backup/restore, validation, tests (JUnit 5) |
| **Preserved** | All functional objectives, OOP concepts, 12 classes, roles, workflow, scope limits | ✅ unchanged |

---

## Key Design Decisions Proposed (to be confirmed in Step 2)

1. **Package:** `com.hospitalmanagement` (Maven groupId `com.hospitalmanagement`).
2. **Versions:** JDK 21 LTS + JavaFX 21 LTS + SQLite JDBC 3.4x + JUnit 5. `maven.compiler.release=21`, `javafx-maven-plugin` configured for `javafx:run`.
3. **Database file:** `data/hospital.db`, auto-created + schema applied at first launch; FK enforcement per connection.
4. **Demo data:** seeded on first run — admin / `admin123`, doctor@hospital.com / `doctor123`, patient@hospital.com / `patient123`, plus a few sample doctors, rooms, ambulances. Passwords stored hashed (PBKDF2 via `PasswordUtil`, no external libs).
5. **Appointment time:** `HH:mm` string with conflict checks on (doctor, date, time) and (patient, date, time), only active statuses.
6. **Tests:** JUnit 5 against a disposable test SQLite database (temp file), covering auth, CRUD, conflicts, rooms, ambulances, billing, payments.
7. **Charts:** JavaFX native BarChart/PieChart only — no external UI libraries.
