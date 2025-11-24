<?php
include '../config/db_connect.php';
$data = json_decode(file_get_contents("php://input"));

if(isset($data->student_id) && isset($data->join_key)) {
    // หา class_id จาก key
    $sql_class = "SELECT class_id FROM classrooms WHERE join_key = :key";
    $stmt = $conn->prepare($sql_class);
    $stmt->execute([':key' => $data->join_key]);
    $class = $stmt->fetch(PDO::FETCH_ASSOC);

    if($class) {
        try {
            $sql_add = "INSERT INTO class_students (class_id, student_id) VALUES (:cid, :sid)";
            $stmt_add = $conn->prepare($sql_add);
            $stmt_add->execute([':cid' => $class['class_id'], ':sid' => $data->student_id]);
            echo json_encode(["status" => "success", "message" => "เข้าห้องเรียนสำเร็จ"]);
        } catch(Exception $e) {
            echo json_encode(["status" => "error", "message" => "คุณอยู่ในห้องเรียนนี้แล้ว"]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "รหัสเข้าห้องเรียนไม่ถูกต้อง"]);
    }
}
?>