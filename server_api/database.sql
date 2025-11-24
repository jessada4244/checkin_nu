CREATE DATABASE checkin_classroom;
USE checkin_classroom;

-- ตารางผู้ใช้งาน (รองรับ 3 roles)
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(20) UNIQUE, -- รหัสนักศึกษา (ถ้าเป็นอาจารย์อาจเป็นว่างหรือรหัสอาจารย์)
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    role ENUM('admin', 'teacher', 'student') NOT NULL,
    device_id VARCHAR(100), -- เก็บ ID เครื่องโทรศัพท์ (ใช้กันโกง)
    is_approved TINYINT(1) DEFAULT 0, -- 0=รออนุมัติ, 1=อนุมัติแล้ว
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ตารางห้องเรียน/วิชา
CREATE TABLE classrooms (
    class_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL,
    teacher_id INT NOT NULL,
    join_key VARCHAR(10) UNIQUE, -- Key สำหรับให้นิสิตกดเข้าร่วม
    FOREIGN KEY (teacher_id) REFERENCES users(user_id)
);

-- ตารางเซสชันการเช็คชื่อ (แต่ละคาบเรียน)
CREATE TABLE attendance_sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    class_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    late_time TIMESTAMP NOT NULL, -- เวลาที่เริ่มนับว่าสาย
    is_active TINYINT(1) DEFAULT 1, -- 1=เปิดให้สแกน, 0=ปิด
    FOREIGN KEY (class_id) REFERENCES classrooms(class_id)
);

-- ตารางบันทึกการเช็คชื่อ (Log)
CREATE TABLE attendance_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    student_id INT NOT NULL,
    scan_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('present', 'late') NOT NULL,
    device_id VARCHAR(100) NOT NULL, -- บันทึกว่าใช้เครื่องไหนสแกน (กันโกง)
    FOREIGN KEY (session_id) REFERENCES attendance_sessions(session_id),
    FOREIGN KEY (student_id) REFERENCES users(user_id),
    UNIQUE(session_id, student_id) -- ป้องกันสแกนซ้ำในคาบเดิม
);