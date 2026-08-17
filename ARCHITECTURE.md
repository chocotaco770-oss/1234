# STEP 2 — FINAL ARCHITECTURE

**Project:** HOSPITAL MANAGEMENT SYSTEM USING JAVA
**Stack:** Java 21 (LTS) · JavaFX 21 (LTS) · FXML · CSS · SQLite · JDBC · Maven · JUnit 5
**Package root:** `com.hospitalmanagement`
**Database file:** `data/hospital.db` (auto-created + schema applied on first run)

---

## 1. Technology Versions (pom.xml)

| Dependency | Version |
|---|---|
| JDK (maven.compiler.release) | 21 LTS |
| JavaFX Controls + FXML | 21.0.4 |
| SQLite JDBC (org.xerial) | 3.46.1.3 |
| JUnit Jupiter | 5.10.2 |
| javafx-maven-plugin | 0.0.8 |
| maven-surefire-plugin | 3.2.5 |

Run: `mvn clean javafx:run` · Tests: `mvn test` (tests use a disposable temp SQLite file, never `data/hospital.db`).

---

## 2. Complete Folder Structure

```
HospitalManagementSystem/
├── pom.xml
├── README.md
├── ARCHITECTURE.md
├── REQUIREMENT_ANALYSIS.md
├── .gitignore
│
├── data/                                    ← created at runtime (hospital.db)
│
├── src/main/java/com/hospitalmanagement/
│   ├── Main.java                            ← Application entry, primary stage
│   │
│   ├── model/
│   │   ├── Person.java                      (abstract)
│   │   ├── Patient.java
│   │   ├── Doctor.java
│   │   ├── Admin.java
│   │   ├── User.java
│   │   ├── Appointment.java
│   │   ├── Prescription.java
│   │   ├── MedicalRecord.java
│   │   ├── Bill.java
│   │   ├── Payment.java
│   │   ├── Room.java
│   │   ├── Ambulance.java
│   │   └── Hospital.java
│   │
│   ├── repository/
│   │   ├── UserRepository.java
│   │   ├── PatientRepository.java
│   │   ├── DoctorRepository.java
│   │   ├── AdminRepository.java
│   │   ├── AppointmentRepository.java
│   │   ├── PrescriptionRepository.java
│   │   ├── MedicalRecordRepository.java
│   │   ├── BillRepository.java
│   │   ├── PaymentRepository.java
│   │   ├── RoomRepository.java
│   │   └── AmbulanceRepository.java
│   │
│   ├── service/
│   │   ├── AuthenticationService.java
│   │   ├── HospitalService.java
│   │   ├── PatientService.java
│   │   ├── DoctorService.java
│   │   ├── AppointmentService.java
│   │   ├── PrescriptionService.java
│   │   ├── MedicalRecordService.java
│   │   ├── BillingService.java
│   │   ├── RoomService.java
│   │   ├── AmbulanceService.java
│   │   ├── PaymentService.java              (interface — proposal-mandated)
│   │   ├── PaymentServiceImpl.java
│   │   └── ReportService.java
│   │
│   ├── report/
│   │   ├── ReportGenerator.java             (interface)
│   │   ├── PatientReport.java
│   │   ├── DoctorReport.java
│   │   ├── AppointmentReport.java
│   │   ├── BillingReport.java
│   │   ├── PaymentReport.java
│   │   ├── RoomReport.java
│   │   ├── AmbulanceReport.java
│   │   └── MedicalRecordReport.java
│   │
│   ├── database/
│   │   ├── DatabaseManager.java
│   │   └── SeedData.java
│   │
│   ├── controller/
│   │   ├── BaseDashboardController.java     (abstract, shared nav/header logic)
│   │   ├── LoginController.java
│   │   ├── PatientRegistrationController.java
│   │   ├── AdminDashboardController.java
│   │   ├── DoctorDashboardController.java
│   │   ├── PatientDashboardController.java
│   │   ├── PatientController.java
│   │   ├── DoctorController.java
│   │   ├── AppointmentController.java
│   │   ├── PrescriptionController.java
│   │   ├── MedicalRecordController.java
│   │   ├── BillingController.java
│   │   ├── PaymentController.java
│   │   ├── RoomController.java
│   │   ├── AmbulanceController.java
│   │   ├── ReportController.java
│   │   └── SettingsController.java
│   │
│   ├── exception/
│   │   ├── InvalidLoginException.java
│   │   ├── InvalidPatientException.java
│   │   ├── PatientNotFoundException.java
│   │   ├── DoctorNotFoundException.java
│   │   ├── RoomUnavailableException.java
│   │   ├── AmbulanceUnavailableException.java
│   │   ├── AppointmentConflictException.java
│   │   ├── PaymentException.java
│   │   ├── ValidationException.java
│   │   └── DatabaseException.java
│   │
│   └── util/
│       ├── Validator.java
│       ├── AlertUtil.java
│       ├── PasswordUtil.java
│       ├── SessionManager.java
│       └── NavigationUtil.java
│
├── src/main/resources/
│   ├── fxml/
│   │   ├── Login.fxml
│   │   ├── PatientRegistration.fxml
│   │   ├── AdminDashboard.fxml
│   │   ├── DoctorDashboard.fxml
│   │   ├── PatientDashboard.fxml
│   │   ├── PatientManagement.fxml
│   │   ├── DoctorManagement.fxml
│   │   ├── AppointmentManagement.fxml
│   │   ├── PrescriptionManagement.fxml
│   │   ├── MedicalRecordManagement.fxml
│   │   ├── Billing.fxml
│   │   ├── Payment.fxml
│   │   ├── RoomManagement.fxml
│   │   ├── AmbulanceManagement.fxml
│   │   ├── Reports.fxml
│   │   └── Settings.fxml
│   ├── css/
│   │   └── application.css
│   └── database/
│       └── schema.sql
│
└── src/test/java/com/hospitalmanagement/
    ├── support/
    │   └── TestDatabase.java                (temp-file DB helper)
    └── service/
        ├── AuthenticationServiceTest.java
        ├── PatientServiceTest.java
        ├── DoctorServiceTest.java
        ├── AppointmentServiceTest.java
        ├── RoomServiceTest.java
        ├── AmbulanceServiceTest.java
        ├── BillingServiceTest.java
        └── PaymentServiceTest.java
```

---

## 3. Database Schema (`schema.sql` — applied by DatabaseManager on startup)

All dates are TEXT `yyyy-MM-dd`, times TEXT `HH:mm`, money REAL, ids INTEGER AUTOINCREMENT except `rooms.room_number` (TEXT PK). FK enforcement: `PRAGMA foreign_keys = ON` on every connection.

**users** — login + role
| Column | Type | Constraint |
|---|---|---|
| user_id | INTEGER | PK AUTOINCREMENT |
| username | TEXT | NOT NULL UNIQUE |
| password_hash | TEXT | NOT NULL |
| role | TEXT | NOT NULL CHECK IN ('ADMIN','DOCTOR','PATIENT') |
| profile_id | INTEGER | NOT NULL (→ patients/doctors/admins id; link enforced in service) |
| created_at | TEXT | NOT NULL |

**patients** — `patient_id` PK AUTOINCREMENT; name NOT NULL; age INTEGER NOT NULL CHECK (0–150); gender CHECK IN ('Male','Female','Other'); phone NOT NULL UNIQUE; blood_group; disease; address; emergency_contact; email UNIQUE; created_at NOT NULL.

**doctors** — `doctor_id` PK AUTOINCREMENT; name NOT NULL; age CHECK; gender CHECK; phone NOT NULL; specialization NOT NULL; experience INTEGER NOT NULL CHECK (≥0); consultation_fee REAL NOT NULL CHECK (≥0); license_number NOT NULL UNIQUE; availability CHECK IN ('Available','Unavailable') DEFAULT 'Available'; email UNIQUE; created_at NOT NULL.

**admins** — `admin_id` PK AUTOINCREMENT; name NOT NULL; username NOT NULL UNIQUE; password_hash NOT NULL; created_at NOT NULL.

**appointments** — `appointment_id` PK AUTOINCREMENT; patient_id NOT NULL FK→patients ON DELETE CASCADE; doctor_id NOT NULL FK→doctors ON DELETE CASCADE; appointment_date NOT NULL; appointment_time NOT NULL; status NOT NULL DEFAULT 'Booked' CHECK IN ('Booked','Completed','Cancelled'); reason; created_at NOT NULL; **UNIQUE(doctor_id, appointment_date, appointment_time)** (hard double-booking guarantee; service adds friendly conflict messages and patient-side check).

**prescriptions** — `prescription_id` PK AUTOINCREMENT; patient_id NOT NULL FK→patients ON DELETE CASCADE; doctor_id NOT NULL FK→doctors ON DELETE CASCADE; appointment_id FK→appointments ON DELETE SET NULL; **medical_record_id FK→medical_records ON DELETE CASCADE (composition)**; medicine_list NOT NULL; dosage NOT NULL; advice; created_date NOT NULL.

**medical_records** — `record_id` PK AUTOINCREMENT; patient_id NOT NULL FK→patients ON DELETE CASCADE; doctor_id NOT NULL FK→doctors ON DELETE CASCADE; diagnosis NOT NULL; treatment; test_report; notes; record_date NOT NULL.

**bills** — `bill_id` PK AUTOINCREMENT; patient_id NOT NULL FK→patients ON DELETE CASCADE; appointment_id FK→appointments ON DELETE SET NULL; consultation_fee / room_charge / medicine_cost / ambulance_charge / other_charges REAL NOT NULL DEFAULT 0 CHECK (≥0); total_amount REAL NOT NULL CHECK (≥0); bill_date NOT NULL; status NOT NULL DEFAULT 'Unpaid' CHECK IN ('Unpaid','Partially Paid','Paid').

**payments** — `payment_id` PK AUTOINCREMENT; bill_id NOT NULL FK→bills ON DELETE CASCADE; patient_id NOT NULL FK→patients ON DELETE CASCADE; amount REAL NOT NULL CHECK (>0); payment_method NOT NULL CHECK IN ('Cash','Card','Mobile Banking'); payment_status NOT NULL DEFAULT 'Completed' CHECK IN ('Completed','Pending','Failed'); payment_date NOT NULL.

**rooms** — `room_number` TEXT PK; room_type NOT NULL CHECK IN ('General','Private','ICU','Semi-Private'); availability NOT NULL DEFAULT 'Available' CHECK IN ('Available','Occupied'); patient_id FK→patients ON DELETE SET NULL; daily_charge REAL NOT NULL CHECK (≥0).

**ambulances** — `ambulance_id` PK AUTOINCREMENT; driver_name NOT NULL; driver_phone NOT NULL; ambulance_type NOT NULL CHECK IN ('Basic Life Support','Advanced Life Support','Patient Transport'); availability NOT NULL DEFAULT 'Available' CHECK IN ('Available','Booked'); charge REAL NOT NULL CHECK (≥0).

**hospital_info** — single row: id INTEGER PK CHECK (id=1); name NOT NULL; location NOT NULL; contact_number NOT NULL; tagline.

**DatabaseManager** — single shared `Connection` (safe on the JavaFX thread), `PRAGMA foreign_keys=ON`, `PRAGMA busy_timeout=5000`, executes schema.sql idempotently, seeds demo data only when tables are empty. Backup via `VACUUM INTO 'path'` (safe copy). Restore: confirm → close connection → copy backup over `hospital.db` → reopen + re-init.

---

## 4. Model Layer — Class Responsibilities

| Class | Kind | Key fields | Key methods |
|---|---|---|---|
| `Person` | abstract | personId, name, age, gender, phone | abstract `displayInformation()`, `updateProfile(...)`; common getters/setters; `toString()` |
| `Patient` | extends Person | patientId, bloodGroup, disease, address, emergencyContact, email | overrides `displayInformation()`, `updateProfile()`; `toString()` |
| `Doctor` | extends Person | doctorId, specialization, experience, consultationFee, licenseNumber, availability, email | overrides `displayInformation()`, `updateProfile()`; availability toggle helpers |
| `Admin` | extends Person | adminId, username, passwordHash | overrides `displayInformation()` |
| `User` | login entity | userId, username, passwordHash, role, profileId | `getRole()`, `isRole(...)` |
| `Appointment` | entity | appointmentId, patientId, doctorId, appointmentDate, appointmentTime, status, reason, createdAt | status helpers (`isActive()`) |
| `Prescription` | entity | prescriptionId, patientId, doctorId, appointmentId, medicalRecordId, medicineList, dosage, advice, createdDate | — |
| `MedicalRecord` | entity | recordId, patientId, doctorId, diagnosis, treatment, testReport, notes, recordDate | — |
| `Bill` | entity | billId, patientId, appointmentId, 5 charge fields, totalAmount, billDate, status | `computeTotal()` (sum, used by BillingService) |
| `Payment` | entity | paymentId, billId, patientId, amount, paymentMethod, paymentStatus, paymentDate | — |
| `Room` | entity | roomNumber, roomType, availability, patientId, dailyCharge | `isAvailable()` |
| `Ambulance` | entity | ambulanceId, driverName, driverPhone, ambulanceType, availability, charge | `isAvailable()` |
| `Hospital` | aggregator | hospitalName, location, contactNumber, tagline | `toString()`; displayed in Settings |

All fields private (encapsulation); constructors + getters/setters; validation delegated to `Validator` at service layer. Models contain **no SQL**.

---

## 5. Repository Layer — JDBC (PreparedStatement only, no SQL in controllers)

Each repository is constructed with `DatabaseManager`. Row mapping via private `mapRow(ResultSet)` helpers.

| Repository | Key methods |
|---|---|
| `UserRepository` | findByUsername, findById, insert, updatePassword, countByRole, usernameExists |
| `PatientRepository` | insert(→generated id), update, delete, findById, findAll, searchByName, searchByNameAndPhone, searchByPhone, emailExists, phoneExists, count |
| `DoctorRepository` | insert, update, delete, findById, findAll, searchByName, searchBySpecialization, findAvailable, licenseExists, count |
| `AdminRepository` | findById, findByUsername, count |
| `AppointmentRepository` | insert, update, delete, findById, findAll, findByPatient, findByDoctor, findByDate, findByStatus, findByPatientAndDate, findActiveDoctorConflict(doctorId,date,time), findActivePatientConflict(patientId,date,time), countByDate, countByStatus |
| `PrescriptionRepository` | insert, update, delete, findById, findByPatient, findByDoctor, findByMedicalRecord |
| `MedicalRecordRepository` | insert, update, delete, findById, findByPatientOrderedByDate, findByDoctor, count |
| `BillRepository` | insert, update, findById, findAll, findByPatient, findByStatus, count, sumUnpaid |
| `PaymentRepository` | insert, findById, findByBill, findByPatient, sumByBill, count |
| `RoomRepository` | insert, update, delete, findById, findAll, findAvailable, findOccupied, count, countAvailable, countOccupied |
| `AmbulanceRepository` | insert, update, delete, findById, findAll, findAvailable, count, countAvailable, countBooked |

---

## 6. Service Layer — Business Rules

| Service | Responsibilities (rules enforced here, not in controllers) |
|---|---|
| `AuthenticationService` | login(username,password) → verifies hash, checks role, returns User; throws `InvalidLoginException`; changePassword(userId, old, new); uses PasswordUtil |
| `HospitalService` | hospital info from `hospital_info`; dashboard stats (totalPatients, totalDoctors, todayAppointments, availableRooms, availableAmbulances, pendingPayments, unpaidAmount) via repositories |
| `PatientService` | registerPatient(patient, username, password) **transaction** (insert patient + user, validate unique phone/email/username); updatePatient; deletePatient (cascade); `searchPatient(name)` / `searchPatient(name, phone)` **overloading**; findById; getMedicalHistory(patientId) → chronological records + prescriptions; throws `InvalidPatientException`, `PatientNotFoundException`, `ValidationException` |
| `DoctorService` | addDoctor(doctor, username, password) transaction; updateDoctor; deleteDoctor; `searchDoctor(name)` / `searchDoctor(specialization)` overloading; findAvailable; updateAvailability; throws `DoctorNotFoundException`, `ValidationException` |
| `AppointmentService` | bookAppointment: validate patient exists → doctor exists → **doctor active conflict** (`AppointmentConflictException`) → **patient active conflict** (`AppointmentConflictException`) → past-date check → insert **transaction**; updateAppointment (re-checks conflicts excluding self); cancelAppointment; completeAppointment; findById; findByPatient; findByDoctor; todayAppointments; upcomingAppointments; search |
| `PrescriptionService` | createPrescription (optionally attach medicalRecordId); updatePrescription; deletePrescription; findByPatient; findByDoctor |
| `MedicalRecordService` | addRecord; updateRecord; deleteRecord (**cascades linked prescriptions — composition**); findByPatient chronological; findByDoctor; search |
| `BillingService` | generateBill(patientId, appointmentId, charges…) → **computes total** via `Bill.computeTotal()`, inserts bill; getBillsByPatient; getByStatus; outstandingAmount(bill) = total − paid; refreshBillStatus (Paid / Partially Paid / Unpaid) |
| `RoomService` | addRoom; updateRoom; deleteRoom; **allocateRoom** (room must be available → `RoomUnavailableException`; patient must exist → `PatientNotFoundException`; transaction: set occupied + occupant); **releaseRoom** (must be occupied → `RoomUnavailableException`; transaction: set available, clear occupant); findAvailable; findOccupied; search |
| `AmbulanceService` | addAmbulance; updateAmbulance; deleteAmbulance; **bookAmbulance** (must be available → `AmbulanceUnavailableException`); **releaseAmbulance** (must be booked → `AmbulanceUnavailableException`); findAvailable; search |
| `PaymentService` (interface) | `Payment processPayment(Payment payment)`; `List<Payment> getPaymentsByBill(billId)`; `List<Payment> getPaymentsByPatient(patientId)`; `double getPaidAmount(billId)` |
| `PaymentServiceImpl` | processPayment **transaction**: bill exists → amount > 0 (`PaymentException`) → amount ≤ outstanding (`PaymentException`) → insert payment → update bill status; throws `PaymentException` on any failure |
| `ReportService` | `ReportGenerator getReport(ReportType)` → constructs the matching concrete report (polymorphism); ReportType enum |

Services depend on repositories (constructor injection). Multi-step operations use `DatabaseManager.beginTransaction()/commit()/rollback()`.

---

## 7. Report Layer — Polymorphic `ReportGenerator`

```java
public interface ReportGenerator {
    String getTitle();
    List<String> getHeaders();
    List<List<String>> getRows();          // real DB data via repository
    default String generateReport() { ... } // formatted text from headers+rows (proposal method)
}
```

Concrete reports (each takes its repository): `PatientReport`, `DoctorReport`, `AppointmentReport`, `BillingReport`, `PaymentReport`, `RoomReport`, `AmbulanceReport`, `MedicalRecordReport`. `ReportService` picks one by enum → UI fills a TableView with `getRows()` and offers **Export to .txt/.csv** (Java file handling preserved for reports/backup). `ReportController` uses `ReportGenerator report = reportService.getReport(type);` — the exact polymorphism the proposal requires.

---

## 8. Exceptions (exception package)

`InvalidLoginException` · `InvalidPatientException` · `PatientNotFoundException` · `DoctorNotFoundException` · `RoomUnavailableException` · `AmbulanceUnavailableException` · `AppointmentConflictException` · `PaymentException` · `ValidationException` · `DatabaseException` (wraps SQLException → generic user message).

All extend `RuntimeException` (or Exception) with clear messages. Controllers catch them and map to `AlertUtil` dialogs; **no empty catch blocks, no raw stack traces in UI** (stack trace logged to console for development only).

---

## 9. Utilities

| Util | Responsibility |
|---|---|
| `Validator` | static checks → `ValidationException`: required text, phone regex, email regex, age 0–150, non-negative fees/amounts, positive amounts, date not in past (for booking), HH:mm time format, room number format, gender/type/status enums |
| `AlertUtil` | showInfo / showError / showWarning / showConfirm dialogs; consistent styling |
| `PasswordUtil` | PBKDF2WithHmacSHA256, random 16-byte salt, 65 536 iterations → `salt:hash` Base64; `hash()` + `verify()`; **no plaintext stored** |
| `SessionManager` | static current `User`; login/logout/getCurrentUser/isRole(role) |
| `NavigationUtil` | holds primary `Stage`; `loadScene(fxml, title)` (swaps scene, applies CSS); `loadInto(Parent container, fxml)` (sidebar content pane); `logout()` (clears session → Login) |

---

## 10. JavaFX Layer — Screens, Controllers, Navigation Flow

### Login flow
`Login.fxml` → `LoginController` → `AuthenticationService.login()` → role check via `SessionManager` → `NavigationUtil.loadScene` to Admin/Doctor/Patient dashboard. Invalid credentials → error alert. "Register as Patient" link → `PatientRegistration.fxml` (self-registration, honors the proposal's patient "Register" use case).

### Dashboard shell (single primary stage, no duplicate stages)
Each dashboard FXML: header (app title + current user + Logout) · left sidebar · content `StackPane`. Clicking a sidebar item loads a management FXML into the content pane via `NavigationUtil.loadInto`. `BaseDashboardController` provides header/user/logout/content-loading; role subclasses define the sidebar.

**Admin sidebar:** Dashboard · Patients · Doctors · Appointments · Prescriptions · Medical Records · Billing · Payments · Rooms · Ambulances · Reports · Settings
**Doctor sidebar:** Dashboard · My Appointments · Today's Appointments · Examine Patient (Prescription) · Prescriptions · Medical Records · My Availability · Settings
**Patient sidebar:** Dashboard · Find Doctors · Book Appointment · My Appointments · My Prescriptions · My Medical Records · My Bills · Make Payment · Ambulance · My Room · Profile

### Management screens (shared FXML, role-filtered)
Each screen: toolbar (search field + Add/Edit/Delete/Refresh/Details buttons) · TableView · form panel (fields + Save/Cancel). Controllers enforce role restrictions (e.g., delete hidden for doctor/patient) via `SessionManager` and pass the current doctor/patient id into services so data is auto-scoped.

| Screen / Controller | Content |
|---|---|
| `PatientManagement` / `PatientController` | TableView, search (name/phone), add/edit/delete, details, medical history |
| `DoctorManagement` / `DoctorController` | TableView, search (name/specialization), add/edit/delete, fee & availability |
| `AppointmentManagement` / `AppointmentController` | book (patient+doctor ComboBox, DatePicker, time ComboBox, reason), update, cancel, complete, search; conflict alerts |
| `PrescriptionManagement` / `PrescriptionController` | doctor: patient selector, medicines (TextArea), dosage, advice, link to medical record, save/edit; patient: read-only view |
| `MedicalRecordManagement` / `MedicalRecordController` | diagnosis, treatment, test report, notes, date; add/update/view/search; chronological history |
| `Billing` / `BillingController` | select patient/appointment, enter charges, auto total (read-only, from BillingService), generate bill, status |
| `Payment` / `PaymentController` | select bill, show outstanding, amount, method ComboBox, process (PaymentService) |
| `RoomManagement` / `RoomController` | room table, add/edit/delete, allocate (pick patient), release, available/occupied filters |
| `AmbulanceManagement` / `AmbulanceController` | table, add/edit/delete, book/release, availability filter |
| `Reports` / `ReportController` | report type ComboBox → polymorphic generator → TableView + text preview + export to file |
| `Settings` / `SettingsController` | change password, hospital info, backup (FileChooser), restore (confirm), app info, demo credentials reminder |
| Dashboard controllers | summary cards + BarChart (appointments by status) / PieChart (room occupancy) from HospitalService |

### CSS
Single `application.css` design system: sidebar (dark teal), header, cards, primary/secondary/danger buttons, form fields, tables, badges (status colors: Booked/Completed/Cancelled, Available/Occupied, Paid/Unpaid, Available/Booked). No external UI libraries; JavaFX native charts only.

---

## 11. Data Consistency (transactions)

- **Patient/Doctor add** → insert profile + insert login user (one transaction).
- **Appointment booking** → validate patient → validate doctor → conflict checks → insert (one transaction; rollback on any failure).
- **Room allocation** → check availability → check patient → update room (transaction).
- **Payment** → validate bill + amount → insert payment → update bill status (transaction).
- **Medical record delete** → deletes record → cascades linked prescriptions (composition enforced at DB + service).
- Backup/restore are file-level operations with confirmation; restore closes/reopens the connection and re-initializes.

---

## 12. Implementation Order

1. **STEP 3 — Maven + DB foundation:** pom.xml, Main.java (stub), DatabaseManager, schema.sql, SeedData, PasswordUtil, Validator, all exceptions. Compiles; `mvn test` green baseline.
2. **STEP 4 — Model layer:** all 13 model classes.
3. **STEP 5 — Repositories:** all 11 JDBC repositories.
4. **STEP 6 — Services:** all services + PaymentServiceImpl + ReportService + reports.
5. **STEP 7 — Utils:** SessionManager, AlertUtil, NavigationUtil, ReportType enum.
6. **STEP 8 — JavaFX UI:** all 16 FXML + 17 controllers, wired end-to-end.
7. **STEP 9 — CSS:** full design system.
8. **STEP 10 — Testing:** 8 JUnit test classes against temp DB; run `mvn test` until green.
9. **STEP 11 — Final audit:** `mvn clean javafx:run` smoke test, requirement checklist, README, viva guide.

---

## 13. Demo Data (seeded only when DB is empty)

| Role | Username | Password | Profile |
|---|---|---|---|
| Admin | `admin` | `admin123` | System Administrator |
| Doctor | `doctor@hospital.com` | `doctor123` | Dr. Rahman (Cardiology) |
| Patient | `patient@hospital.com` | `patient123` | Patient Demo |

Plus: 4 sample doctors, 4 sample patients, 6 rooms (mixed types), 3 ambulances, a few appointments (incl. today), 1 completed prescription + medical record, 1 unpaid bill (payment demo), 1 paid bill. Passwords stored hashed via PasswordUtil.
