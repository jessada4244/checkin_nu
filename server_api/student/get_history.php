<?php
include '../config/db_connect.php';
$student_id = $_GET['student_id'];

// ดึงข้อมูล วิชา, วันที่, สถานะ
$sql = "SELECT c.subject_name, s.created_at as date, log.status 
        FROM attendance_logs log
        JOIN attendance_sessions s ON log.session_id = s.session_id
        JOIN classrooms c ON s.class_id = c.class_id
        WHERE log.student_id = :sid
        ORDER BY s.created_at DESC";

$stmt = $conn->prepare($sql);
$stmt->execute([':sid' => $student_id]);
$history = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode(["status" => "success", "data" => $history]);
?>