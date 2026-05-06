CALL CancelAppointment(1001);
-- giải thích:
-- Stored Procedure hiện tại không kiểm tra trạng thái hiện tại của lịch khám trước khi cập nhật
-- Vì vậy dù lịch đã completed  câu lệnh UPDATE vẫn cho phép chuyển sang Cancelled gây sai lệch dữ liệu.

-- xóa thủ tục cũ 
DROP PROCEDURE IF EXISTS CancelAppointment;
-- Tạo mới
DELIMITER $$
CREATE PROCEDURE CancelAppointment(IN p_appointment_id INT)
BEGIN
    DECLARE v_status VARCHAR(50);

   
    SELECT status INTO v_status
    FROM Appointments
    WHERE appointment_id = p_appointment_id;

   
    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Appointment does not exist';
    END IF;

   
    IF v_status = 'Completed' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot cancel a completed appointment';
    END IF;

   
    IF v_status IN ('Scheduled', 'Pending') THEN
        UPDATE Appointments
        SET status = 'Cancelled'
        WHERE appointment_id = p_appointment_id;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid status for cancellation';
    END IF;

END $$
DELIMITER
