USE hotel;
DELIMITER //

DROP TRIGGER IF EXISTS after_reserva_update;
CREATE TRIGGER after_reserva_update
AFTER UPDATE ON Reservas
FOR EACH ROW
BEGIN
    IF NEW.estado = 'Cancelada' AND OLD.estado != 'Cancelada' THEN

        UPDATE Habitaciones SET estado = 'Disponible' 
        WHERE id_habitacion = NEW.id_habitacion;

        INSERT INTO RegistroCambiosReservas (id_reserva, accion, detalles)
        VALUES (NEW.id_reserva, 'Reserva cancelada', 
               CONCAT('Habitación liberada: ', NEW.id_habitacion));
    END IF;
END //

DROP TRIGGER IF EXISTS after_mantenimiento_insert;
CREATE TRIGGER after_mantenimiento_insert
AFTER INSERT ON MantenimientoHabitaciones
FOR EACH ROW
BEGIN
    UPDATE Habitaciones SET estado = 'Mantenimiento' 
    WHERE id_habitacion = NEW.id_habitacion;
END //


DELIMITER //

DROP TRIGGER IF EXISTS after_mantenimiento_update;
CREATE TRIGGER after_mantenimiento_update
AFTER UPDATE ON MantenimientoHabitaciones
FOR EACH ROW
BEGIN

    IF NEW.estado = 'Completado' AND OLD.estado != 'Completado' THEN

        IF NOT EXISTS (
            SELECT 1 FROM Reservas 
            WHERE id_habitacion = NEW.id_habitacion 
            AND estado IN ('Confirmada', 'Pendiente')
            AND fecha_entrada >= CURDATE()
        ) THEN
            UPDATE Habitaciones SET estado = 'Disponible' 
            WHERE id_habitacion = NEW.id_habitacion;
            
            INSERT INTO RegistroCambiosReservas (id_reserva, accion, detalles)
            VALUES (NULL, 'Mantenimiento completado', 
                   CONCAT('Habitación ', NEW.id_habitacion, ' puesta como disponible'));
        END IF;
    END IF;
END//

DELIMITER ;