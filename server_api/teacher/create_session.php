<?php
include '../config/db_connect.php';
$data = json_decode(file_get_contents("php://input"));

if(isset($data->class_id) && isset($data->late_minutes)) {
    // คำนวณเวลาที่ถือว่าสาย (เวลาปัจจุบัน + จำนวนนาทีที่อาจารย์ตั้ง)
    $late_time = date("Y-m-d H:i:s", strtotime("+" . $data->late_minutes . " minutes"));

    $sql = "INSERT INTO attendance_sessions (class_id, late_time, is_active) VALUES (:cid, :late, 1)";
    $stmt = $conn->prepare($sql);
    $stmt->execute([':cid' => $data->class_id, ':late' => $late_time]);
    
    // คืนค่า session_id กลับไป เพื่อให้ Flutter เอาไปสร้าง QR Code
    // QR Code Value จะเป็น: { "session_id": "15", "type": "attendance" }
    echo json_encode(["status" => "success", "session_id" => $conn->lastInsertId(), "late_time" => $late_time]);
}
?>