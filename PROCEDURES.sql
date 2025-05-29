USE hotel;
DELIMITER //

-- Procedimiento para crear reserva
DROP PROCEDURE IF EXISTS CrearReserva;
CREATE PROCEDURE CrearReserva(
    IN p_id_cliente INT,
    IN p_id_habitacion INT,
    IN p_fecha_entrada DATE,
    IN p_fecha_salida DATE,
    OUT p_resultado VARCHAR(100)
)
BEGIN
    DECLARE dias INT;
    DECLARE precio DECIMAL(10,2);
    DECLARE capacidad_habitacion INT;
    DECLARE estado_habitacion VARCHAR(20);
    DECLARE costo DECIMAL(10,2);
    
    -- Verificar disponibilidad de la habitación
    SELECT capacidad, estado, precio_base INTO capacidad_habitacion, estado_habitacion, precio
    FROM Habitaciones WHERE id_habitacion = p_id_habitacion;
    
    IF estado_habitacion != 'Disponible' THEN
        SET p_resultado = 'Error: Habitación no disponible';
    ELSEIF NOT VerificarDisponibilidad(p_id_habitacion, p_fecha_entrada, p_fecha_salida) THEN
        SET p_resultado = 'Error: Habitación no disponible para las fechas seleccionadas';
    ELSE
        -- Calcular días de estadía y costo
        SET dias = DATEDIFF(p_fecha_salida, p_fecha_entrada);
        SET costo = CalcularCostoReserva(precio, dias, NOW(), p_fecha_entrada);
        
        -- Insertar reserva
        INSERT INTO Reservas (id_cliente, id_habitacion, fecha_entrada, fecha_salida, costo_total)
        VALUES (p_id_cliente, p_id_habitacion, p_fecha_entrada, p_fecha_salida, costo);
        
        -- Actualizar estado de la habitación
        UPDATE Habitaciones SET estado = 'Ocupada' WHERE id_habitacion = p_id_habitacion;
        
        SET p_resultado = CONCAT('Reserva creada exitosamente. Costo total: $', costo);
    END IF;
END //

DROP PROCEDURE IF EXISTS AsignarHabitacionAutomatica;
CREATE PROCEDURE AsignarHabitacionAutomatica(
    IN p_id_cliente INT,
    IN p_fecha_entrada DATE,
    IN p_fecha_salida DATE,
    IN p_capacidad INT,
    OUT p_id_habitacion INT,
    OUT p_resultado VARCHAR(100)
)
BEGIN
    DECLARE habitacion_disponible INT DEFAULT NULL;

    SELECT h.id_habitacion INTO habitacion_disponible
    FROM Habitaciones h
    WHERE h.capacidad >= p_capacidad
    AND h.estado = 'Disponible'
    AND VerificarDisponibilidad(h.id_habitacion, p_fecha_entrada, p_fecha_salida)
    LIMIT 1;
    
    IF habitacion_disponible IS NULL THEN
        SET p_resultado = 'Error: No hay habitaciones disponibles para las fechas y capacidad solicitada';
        SET p_id_habitacion = NULL;
    ELSE

        CALL CrearReserva(p_id_cliente, habitacion_disponible, p_fecha_entrada, p_fecha_salida, p_resultado);
        SET p_id_habitacion = habitacion_disponible;
    END IF;
END //

DELIMITER ;