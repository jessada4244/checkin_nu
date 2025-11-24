<?php
include '../config/db_connect.php';
$data = json_decode(file_get_contents("php://input"));

if(isset($data->class_id) && isset($data->student_code)) {
    // หา user_id จาก student_code ก่อน
    $sql_find = "SELECT user_id FROM users WHERE student_id = :code AND role = 'student'";
    $stmt = $conn->prepare($sql_find);
    $stmt->execute([':code' => $data->student_code]);
    $student = $stmt->fetch(PDO::FETCH_ASSOC);

    if($student) {
        // เพิ่มลงตาราง class_students
        try {
            $sql_add = "INSERT INTO class_students (class_id, student_id) VALUES (:cid, :sid)";
            $stmt_add = $conn->prepare($sql_add);
            $stmt_add->execute([':cid' => $data->class_id, ':sid' => $student['user_id']]);
            echo json_encode(["status" => "success", "message" => "เพิ่มนิสิตเรียบร้อย"]);
        } catch (Exception $e) {
             echo json_encode(["status" => "error", "message" => "นิสิตคนนี้อยู่ในห้องเรียนแล้ว"]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "ไม่พบรหัสนิสิตนี้ในระบบ"]);
    }
}
?>