-- Create database schema for Hostel Outpass Management System

-- Students table
CREATE TABLE IF NOT EXISTS students (
  id VARCHAR(36) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  roll_no VARCHAR(20) NOT NULL UNIQUE,
  room_no VARCHAR(10) NOT NULL,
  hostel VARCHAR(50) NOT NULL,
  contact VARCHAR(20) NOT NULL,
  parent_contact VARCHAR(20) NOT NULL,
  parent_email VARCHAR(100),
  profile_complete BOOLEAN DEFAULT FALSE,
  reset_token VARCHAR(100),
  reset_token_expires TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  last_login TIMESTAMP
);

-- Admins table
CREATE TABLE IF NOT EXISTS admins (
  id VARCHAR(36) PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(100) UNIQUE,
  password VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  hostel VARCHAR(50),
  role ENUM('hostel_admin', 'security', 'super_admin') NOT NULL,
  reset_token VARCHAR(100),
  reset_token_expires TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  last_login TIMESTAMP
);

-- Outpass requests table
CREATE TABLE IF NOT EXISTS outpass_requests (
  id VARCHAR(36) PRIMARY KEY,
  student_id VARCHAR(36) NOT NULL,
  type ENUM('Market', 'Home', 'Medical', 'Academic') NOT NULL,
  purpose VARCHAR(200) NOT NULL,
  place VARCHAR(200) NOT NULL,
  expected_date DATE NOT NULL,
  expected_return_time TIME NOT NULL,
  status ENUM('Pending', 'Approved', 'Rejected', 'Exited', 'Returned', 'Late', 'Cancelled') NOT NULL DEFAULT 'Pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  approved_by VARCHAR(36),
  approved_at TIMESTAMP NULL,
  reject_reason TEXT,
  actual_exit_time TIMESTAMP NULL,
  actual_return_time TIMESTAMP NULL,
  barcode_token VARCHAR(100),
  pdf_url VARCHAR(255),
  is_manual_entry BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (approved_by) REFERENCES admins(id) ON DELETE SET NULL
);

-- Gate logs table
CREATE TABLE IF NOT EXISTS gate_logs (
  id VARCHAR(36) PRIMARY KEY,
  outpass_id VARCHAR(36) NOT NULL,
  student_id VARCHAR(36) NOT NULL,
  action ENUM('exit', 'return') NOT NULL,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  recorded_by VARCHAR(36),
  notes TEXT,
  FOREIGN KEY (outpass_id) REFERENCES outpass_requests(id) ON DELETE CASCADE,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (recorded_by) REFERENCES admins(id) ON DELETE SET NULL
);

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id VARCHAR(36) PRIMARY KEY,
  type ENUM('parent', 'admin', 'student') NOT NULL,
  recipient_id VARCHAR(36) NOT NULL,
  outpass_id VARCHAR(36),
  message TEXT NOT NULL,
  status ENUM('sent', 'failed', 'read') NOT NULL DEFAULT 'sent',
  priority ENUM('low', 'medium', 'high') DEFAULT 'medium',
  sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  read_at TIMESTAMP,
  FOREIGN KEY (outpass_id) REFERENCES outpass_requests(id) ON DELETE CASCADE
);

-- Feedback table
CREATE TABLE IF NOT EXISTS feedback (
  id VARCHAR(36) PRIMARY KEY,
  outpass_id VARCHAR(36) NOT NULL,
  student_id VARCHAR(36) NOT NULL,
  satisfaction_level ENUM('dissatisfied', 'neutral', 'satisfied') NOT NULL,
  feedback_text TEXT NOT NULL,
  submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  admin_reviewed BOOLEAN DEFAULT FALSE,
  admin_reviewed_at TIMESTAMP,
  admin_reviewed_by VARCHAR(36),
  FOREIGN KEY (outpass_id) REFERENCES outpass_requests(id) ON DELETE CASCADE,
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (admin_reviewed_by) REFERENCES admins(id) ON DELETE SET NULL
);

-- System settings table
CREATE TABLE IF NOT EXISTS system_settings (
  id VARCHAR(36) PRIMARY KEY,
  setting_key VARCHAR(50) NOT NULL UNIQUE,
  setting_value TEXT,
  setting_type ENUM('string', 'number', 'boolean', 'json') NOT NULL DEFAULT 'string',
  description TEXT,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  updated_by VARCHAR(36),
  FOREIGN KEY (updated_by) REFERENCES admins(id) ON DELETE SET NULL
);

-- Audit logs table
CREATE TABLE IF NOT EXISTS audit_logs (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36),
  user_type ENUM('student', 'admin') NOT NULL,
  action VARCHAR(100) NOT NULL,
  entity_type VARCHAR(50) NOT NULL,
  entity_id VARCHAR(36),
  old_values JSON,
  new_values JSON,
  ip_address VARCHAR(45),
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Email templates table
CREATE TABLE IF NOT EXISTS email_templates (
  id VARCHAR(36) PRIMARY KEY,
  template_name VARCHAR(100) NOT NULL UNIQUE,
  subject VARCHAR(200) NOT NULL,
  body TEXT NOT NULL,
  variables JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by VARCHAR(36),
  updated_by VARCHAR(36),
  FOREIGN KEY (created_by) REFERENCES admins(id) ON DELETE SET NULL,
  FOREIGN KEY (updated_by) REFERENCES admins(id) ON DELETE SET NULL
);

-- SMS templates table
CREATE TABLE IF NOT EXISTS sms_templates (
  id VARCHAR(36) PRIMARY KEY,
  template_name VARCHAR(100) NOT NULL UNIQUE,
  body TEXT NOT NULL,
  variables JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by VARCHAR(36),
  updated_by VARCHAR(36),
  FOREIGN KEY (created_by) REFERENCES admins(id) ON DELETE SET NULL,
  FOREIGN KEY (updated_by) REFERENCES admins(id) ON DELETE SET NULL
);

-- API keys table
CREATE TABLE IF NOT EXISTS api_keys (
  id VARCHAR(36) PRIMARY KEY,
  service_name VARCHAR(100) NOT NULL,
  key_name VARCHAR(100) NOT NULL,
  key_value TEXT NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_by VARCHAR(36),
  FOREIGN KEY (created_by) REFERENCES admins(id) ON DELETE SET NULL
);

-- Indexes for better performance
CREATE INDEX idx_students_hostel ON students(hostel);
CREATE INDEX idx_students_email ON students(email);
CREATE INDEX idx_students_roll_no ON students(roll_no);
CREATE INDEX idx_admins_role ON admins(role);
CREATE INDEX idx_admins_hostel ON admins(hostel);
CREATE INDEX idx_outpass_student ON outpass_requests(student_id);
CREATE INDEX idx_outpass_status ON outpass_requests(status);
CREATE INDEX idx_outpass_date ON outpass_requests(expected_date);
CREATE INDEX idx_outpass_type ON outpass_requests(type);
CREATE INDEX idx_gate_logs_outpass ON gate_logs(outpass_id);
CREATE INDEX idx_gate_logs_student ON gate_logs(student_id);
CREATE INDEX idx_gate_logs_timestamp ON gate_logs(timestamp);
CREATE INDEX idx_notifications_recipient ON notifications(recipient_id);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_status ON notifications(status);
CREATE INDEX idx_feedback_outpass ON feedback(outpass_id);
CREATE INDEX idx_feedback_student ON feedback(student_id);
CREATE INDEX idx_feedback_satisfaction ON feedback(satisfaction_level);
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id, user_type);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
CREATE INDEX idx_system_settings_key ON system_settings(setting_key);

-- Triggers for automatic timestamp updates
DELIMITER //

CREATE TRIGGER before_student_update
BEFORE UPDATE ON students
FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END //

CREATE TRIGGER before_admin_update
BEFORE UPDATE ON admins
FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END //

CREATE TRIGGER before_outpass_update
BEFORE UPDATE ON outpass_requests
FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END //

DELIMITER ;

-- Initial system settings
INSERT INTO system_settings (id, setting_key, setting_value, setting_type, description)
VALUES
(UUID(), 'market_outpass_max_hours', '6', 'number', 'Maximum hours allowed for market outpass'),
(UUID(), 'home_outpass_max_days', '7', 'number', 'Maximum days allowed for home outpass'),
(UUID(), 'medical_outpass_max_days', '3', 'number', 'Maximum days allowed for medical outpass'),
(UUID(), 'academic_outpass_max_hours', '12', 'number', 'Maximum hours allowed for academic outpass'),
(UUID(), 'enable_sms_notifications', 'true', 'boolean', 'Enable SMS notifications'),
(UUID(), 'enable_email_notifications', 'true', 'boolean', 'Enable email notifications'),
(UUID(), 'late_return_threshold_minutes', '30', 'number', 'Minutes after expected return time to mark as late'),
(UUID(), 'system_email', 'outpass@yourdomain.com', 'string', 'System email address for sending notifications');
