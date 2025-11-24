<?php
include '../config/db_connect.php';
$data = json_decode(file_get_contents("php://input"));

if(isset($data->teacher_id) && isset($data->subject_name)) {
    // สร้าง Join Key สุ่ม 6 ตัวอักษร
    $join_key = strtoupper(substr(md5(time()), 0, 6));

    $sql = "INSERT INTO classrooms (subject_name, teacher_id, join_key) VALUES (:name, :tid, :key)";
    $stmt = $conn->prepare($sql);
    $stmt->execute([':name' => $data->subject_name, ':tid' => $data->teacher_id, ':key' => $join_key]);

    echo json_encode(["status" => "success", "message" => "สร้างวิชาสำเร็จ", "join_key" => $join_key]);
}
?>