<?php
include '../config/db_connect.php';

// รับค่า JSON จาก Flutter
$data = json_decode(file_get_contents("php://input"));

if(isset($data->session_id) && isset($data->student_id) && isset($data->device_id)) {
    
    $session_id = $data->session_id;
    $student_id = $data->student_id;
    $device_id  = $data->device_id;

    try {
        // 1. ตรวจสอบว่า Session นี้ยังเปิดอยู่ไหม และดึงเวลาสาย (late_time)
        $sql_session = "SELECT is_active, late_time FROM attendance_sessions WHERE session_id = :sid";
        $stmt = $conn->prepare($sql_session);
        $stmt->execute([':sid' => $session_id]);
        $session = $stmt->fetch(PDO::FETCH_ASSOC);

        if(!$session || $session['is_active'] == 0) {
            echo json_encode(["status" => "error", "message" => "QR Code หมดเวลาแล้ว"]);
            exit();
        }

        // 2. คำนวณสถานะ (มาทัน / มาสาย)
        $current_time = date("Y-m-d H:i:s");
        $status = ($current_time > $session['late_time']) ? 'late' : 'present';

        // 3. ANTI-CHEAT: ตรวจสอบว่า Device ID นี้ เคยถูกใช้สแกนให้นิสิตคนอื่นใน Session นี้ไปแล้วหรือยัง?
        // (ป้องกัน 1 เครื่องสแกนให้เพื่อนทั้งกลุ่ม)
        $sql_cheat = "SELECT * FROM attendance_logs WHERE session_id = :sid AND device_id = :did AND student_id != :stid";
        $stmt_cheat = $conn->prepare($sql_cheat);
        $stmt_cheat->execute([':sid' => $session_id, ':did' => $device_id, ':stid' => $student_id]);

        if($stmt_cheat->rowCount() > 0) {
            echo json_encode(["status" => "error", "message" => "โกง! อุปกรณ์นี้ถูกใช้เช็คชื่อไปแล้ว"]);
            exit();
        }

        // 4. บันทึกการเช็คชื่อ
        $sql_insert = "INSERT INTO attendance_logs (session_id, student_id, status, device_id) VALUES (:sid, :stid, :st, :did)";
        $stmt_insert = $conn->prepare($sql_insert);
        $stmt_insert->execute([':sid' => $session_id, ':stid' => $student_id, ':st' => $status, ':did' => $device_id]);

        echo json_encode(["status" => "success", "message" => "เช็คชื่อสำเร็จ ($status)"]);

    } catch (PDOException $e) {
        // Error 23000 คือ Duplicate Key (เช็คชื่อซ้ำ)
        if ($e->getCode() == 23000) {
            echo json_encode(["status" => "error", "message" => "คุณเช็คชื่อไปแล้ว"]);
        } else {
            echo json_encode(["status" => "error", "message" => $e->getMessage()]);
        }
    }

} else {
    echo json_encode(["status" => "error", "message" => "ข้อมูลไม่ครบถ้วน"]);
}
?>