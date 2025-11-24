<?php
include '../config/db_connect.php';
$data = json_decode(file_get_contents("php://input"));

if(isset($data->student_id) && isset($data->password) && isset($data->first_name)) {
    // default role เป็น student ถ้าไม่ส่งมา
    $role = isset($data->role) ? $data->role : 'student'; 
    $is_approved = 0; // ต้องรอแอดมินอนุมัติเสมอ

    try {
        $sql = "INSERT INTO users (student_id, password, first_name, last_name, phone, role, device_id, is_approved) 
                VALUES (:sid, :pass, :fname, :lname, :phone, :role, :did, :appr)";
        
        $stmt = $conn->prepare($sql);
        $stmt->execute([
            ':sid' => $data->student_id,
            ':pass' => $data->password, // แนะนำให้ใช้ password_hash($data->password, PASSWORD_DEFAULT) ใน Production
            ':fname' => $data->first_name,
            ':lname' => $data->last_name,
            ':phone' => $data->phone,
            ':role' => $role,
            ':did'  => isset($data->device_id) ? $data->device_id : '',
            ':appr' => $is_approved
        ]);

        echo json_encode(["status" => "success", "message" => "สมัครสมาชิกสำเร็จ รอการอนุมัติจากแอดมิน"]);
    } catch (PDOException $e) {
        echo json_encode(["status" => "error", "message" => "Error: " . $e->getMessage()]);
    }
}
?>