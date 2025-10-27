ALTER TABLE patients ADD CONSTRAINT patient_unique_phone UNIQUE (phone);

CREATE TABLE IF NOT EXISTS appointments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    patient_id INTEGER NOT NULL,
    doctor_id INTEGER NOT NULL,
    date_time TEXT NOT NULL,
    status TEXT NOT NULL,
    notes TEXT,
    FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    appointment_id INTEGER NOT NULL,
    amount REAL NOT NULL,
    date TEXT NOT NULL,
    payment_method TEXT NOT NULL,
    status TEXT NOT NULL,
    transaction_id TEXT,
    notes TEXT,
    FOREIGN KEY (appointment_id) REFERENCES appointments (id) ON DELETE CASCADE
);