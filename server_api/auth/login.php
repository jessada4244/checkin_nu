<?php
include '../config/db_connect.php';
$data = json_decode(file_get_contents("php://input"));

if(isset($data->identifier) && isset($data->password)) { // identifier คือ รหัสนิสิต หรือ เบอร์โทร
    $identifier = $data->identifier;
    $password = $data->password;

    // ค้นหา User
    $sql = "SELECT * FROM users WHERE student_id = :id OR phone = :id";
    $stmt = $conn->prepare($sql);
    $stmt->execute([':id' => $identifier]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if($user) {
        // ตรวจสอบรหัสผ่าน (ในระบบจริงควรใช้ password_verify กับ hash)
        // สมมติว่าใน Database เก็บ plain text ไปก่อนเพื่อความง่ายในการเทสเบื้องต้น
        // แต่ถ้าจะทำจริงจังต้องเปลี่ยนเป็น: if(password_verify($password, $user['password'])) {
        if($password == $user['password']) { 
            
            if($user['is_approved'] == 0) {
                echo json_encode(["status" => "error", "message" => "รอแอดมินอนุมัติการใช้งาน"]);
                exit();
            }

            // ส่งข้อมูลกลับไปให้ Flutter เก็บไว้ใช้งาน
            unset($user['password']); // ลบรหัสผ่านออกก่อนส่งกลับ
            echo json_encode(["status" => "success", "data" => $user]);
        } else {
            echo json_encode(["status" => "error", "message" => "รหัสผ่านผิด"]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "ไม่พบผู้ใช้งาน"]);
    }
}
?>