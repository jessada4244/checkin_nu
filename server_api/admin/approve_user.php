<?php
include '../config/db_connect.php';
$data = json_decode(file_get_contents("php://input"));

if(isset($data->user_id) && isset($data->action)) {
    // action: 1=approve, 2=reject/delete
    if($data->action == 1) {
        $sql = "UPDATE users SET is_approved = 1 WHERE user_id = :uid";
    } else {
        $sql = "DELETE FROM users WHERE user_id = :uid";
    }
    
    $stmt = $conn->prepare($sql);
    $stmt->execute([':uid' => $data->user_id]);
    echo json_encode(["status" => "success", "message" => "ดำเนินการสำเร็จ"]);
}
?>