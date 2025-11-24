<?php
include '../config/db_connect.php';
$session_id = $_GET['session_id'];

$sql = "SELECT u.student_id, u.first_name, u.last_name, log.status, log.scan_time 
        FROM attendance_logs log
        JOIN users u ON log.student_id = u.user_id
        WHERE log.session_id = :sid";

$stmt = $conn->prepare($sql);
$stmt->execute([':sid' => $session_id]);
$logs = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode(["status" => "success", "data" => $logs]);
?>