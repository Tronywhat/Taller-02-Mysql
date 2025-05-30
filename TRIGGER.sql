DROP TRIGGER IF EXISTS `hotel`.`reservas_AFTER_UPDATE`;

DELIMITER $$
USE `hotel`$$
CREATE DEFINER = CURRENT_USER TRIGGER `hotel`.`reservas_AFTER_UPDATE` AFTER UPDATE ON `reservas` FOR EACH ROW
BEGIN
    IF NEW.estado = 'Cancelada' AND OLD.estado != 'Cancelada' THEN

        UPDATE Habitaciones SET estado = 'Disponible' 
        WHERE id_habitacion = NEW.id_habitacion;

        INSERT INTO RegistroCambiosReservas (id_reserva, accion, detalles)
        VALUES (NEW.id_reserva, 'Reserva cancelada', 
               CONCAT('Habitación liberada: ', NEW.id_habitacion));
    END IF;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS `hotel`.`mantenimientohabitaciones_AFTER_INSERT`;

DELIMITER $$
USE `hotel`$$
CREATE DEFINER = CURRENT_USER TRIGGER `hotel`.`mantenimientohabitaciones_AFTER_INSERT` AFTER INSERT ON `mantenimientohabitaciones` FOR EACH ROW
BEGIN
    UPDATE Habitaciones SET estado = 'Mantenimiento' 
    WHERE id_habitacion = NEW.id_habitacion;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS `hotel`.`mantenimientohabitaciones_AFTER_UPDATE`;

DELIMITER $$
USE `hotel`$$
CREATE DEFINER = CURRENT_USER TRIGGER `hotel`.`mantenimientohabitaciones_AFTER_UPDATE` AFTER UPDATE ON `mantenimientohabitaciones` FOR EACH ROW
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
END$$
DELIMITER ;
