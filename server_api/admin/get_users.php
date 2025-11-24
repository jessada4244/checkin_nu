<?php
include '../config/db_connect.php';

// ถ้าส่ง status=pending มา จะดึงแค่คนที่รออนุมัติ
$status_filter = isset($_GET['status']) && $_GET['status'] == 'pending' ? "WHERE is_approved = 0" : "";

$sql = "SELECT user_id, student_id, first_name, last_name, role, is_approved FROM users $status_filter ORDER BY created_at DESC";
$stmt = $conn->prepare($sql);
$stmt->execute();
$users = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode(["status" => "success", "data" => $users]);
?>