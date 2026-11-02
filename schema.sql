-- RentaManager Database Schema
-- Created: June 2026

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(20) NOT NULL CHECK (role IN ('admin','landlord','caretaker')),
  phone VARCHAR(20),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE properties (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  location VARCHAR(150) NOT NULL,
  landlord_id INTEGER REFERENCES users(id),
  floors INTEGER DEFAULT 1,
  deposit_amount DECIMAL(10,2) DEFAULT 0,
  utilities JSONB,
  contact_email VARCHAR(100),
  created_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE units (
  id SERIAL PRIMARY KEY,
  property_id INTEGER REFERENCES properties(id),
  unit_number VARCHAR(20) NOT NULL,
  floor_number INTEGER DEFAULT 1,
  unit_type VARCHAR(20) CHECK (unit_type IN ('bedsitter','single','1bedroom','2bedroom')),
  rent_amount DECIMAL(10,2) NOT NULL,
  deposit_amount DECIMAL(10,2) DEFAULT 0,
  is_occupied BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE tenants (
  id SERIAL PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  national_id VARCHAR(20) UNIQUE NOT NULL,
  phone VARCHAR(20) NOT NULL,
  emergency_contact_name VARCHAR(100),
  emergency_contact_phone VARCHAR(20),
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active','former')),
  created_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE leases (
  id SERIAL PRIMARY KEY,
  tenant_id INTEGER REFERENCES tenants(id),
  unit_id INTEGER REFERENCES units(id),
  start_date DATE NOT NULL,
  end_date DATE,
  rent_amount DECIMAL(10,2) NOT NULL,
  deposit_amount DECIMAL(10,2) DEFAULT 0,
  deposit_status VARCHAR(20) DEFAULT 'held' CHECK (deposit_status IN ('held','refunded','forfeited')),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE bills (
  id SERIAL PRIMARY KEY,
  lease_id INTEGER REFERENCES leases(id),
  tenant_id INTEGER REFERENCES tenants(id),
  unit_id INTEGER REFERENCES units(id),
  billing_month DATE NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  status VARCHAR(20) DEFAULT 'unpaid' CHECK (status IN ('unpaid','paid','partial')),
  due_date DATE,
  created_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE bill_items (
  id SERIAL PRIMARY KEY,
  bill_id INTEGER REFERENCES bills(id),
  item_name VARCHAR(50) NOT NULL,
  amount DECIMAL(10,2) NOT NULL
);
CREATE TABLE payments (
  id SERIAL PRIMARY KEY,
  bill_id INTEGER REFERENCES bills(id),
  tenant_id INTEGER REFERENCES tenants(id),
  unit_id INTEGER REFERENCES units(id),
  amount DECIMAL(10,2) NOT NULL,
  mpesa_code VARCHAR(50),
  payment_month DATE NOT NULL,
  payment_type VARCHAR(50) DEFAULT 'rent',
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected')),
  recorded_by INTEGER REFERENCES users(id),
  approved_by INTEGER REFERENCES users(id),
  approved_at TIMESTAMP,
  sms_sent BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE sms_receipts (
  id SERIAL PRIMARY KEY,
  payment_id INTEGER REFERENCES payments(id),
  tenant_id INTEGER REFERENCES tenants(id),
  phone_number VARCHAR(20) NOT NULL,
  message_content TEXT NOT NULL,
  sent_at TIMESTAMP DEFAULT NOW(),
  status VARCHAR(20) DEFAULT 'sent' CHECK (status IN ('sent','failed'))
);
CREATE TABLE alerts (
  id SERIAL PRIMARY KEY,
  tenant_id INTEGER REFERENCES tenants(id),
  unit_id INTEGER REFERENCES units(id),
  alert_type VARCHAR(50) DEFAULT 'arrears',
  months_unpaid INTEGER DEFAULT 0,
  total_owed DECIMAL(10,2) DEFAULT 0,
  notice_sent BOOLEAN DEFAULT FALSE,
  notice_sent_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE maintenance (
  id SERIAL PRIMARY KEY,
  property_id INTEGER REFERENCES properties(id),
  unit_id INTEGER REFERENCES units(id),
  reported_by INTEGER REFERENCES users(id),
  description TEXT NOT NULL,
  contractor_name VARCHAR(100),
  cost DECIMAL(10,2) DEFAULT 0,
  repair_date DATE,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected')),
  created_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE maintenance_verification (
  id SERIAL PRIMARY KEY,
  maintenance_id INTEGER REFERENCES maintenance(id),
  verified_by INTEGER REFERENCES users(id),
  decision VARCHAR(20) CHECK (decision IN ('approved','rejected')),
  remarks TEXT,
  verified_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE deposits (
  id SERIAL PRIMARY KEY,
  tenant_id INTEGER REFERENCES tenants(id),
  unit_id INTEGER REFERENCES units(id),
  lease_id INTEGER REFERENCES leases(id),
  amount DECIMAL(10,2) NOT NULL,
  date_paid DATE NOT NULL,
  status VARCHAR(20) DEFAULT 'held' CHECK (status IN ('held','refunded','forfeited')),
  refund_date DATE,
  refund_amount DECIMAL(10,2),
  remarks TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
