USE `hotel`;
DROP function IF EXISTS `CalcularCostoReserva`;

DELIMITER $$
USE `hotel`$$
CREATE FUNCTION `CalcularCostoReserva` (
	p_precio_base DECIMAL(10,2),
    p_dias INT,
    p_fecha_reserva DATETIME,
    p_fecha_entrada DATE
) RETURNS DECIMAL(10,2)
BEGIN
    DECLARE costo_total DECIMAL(10,2);
    DECLARE descuento DECIMAL(10,2) DEFAULT 0;
    
    -- Aplicar descuento del 10% si se reserva con 15 días de anticipación
    IF DATEDIFF(p_fecha_entrada, DATE(p_fecha_reserva)) >= 15 THEN
        SET descuento = 0.1;
    END IF;
    
    SET costo_total = (p_precio_base * p_dias) * (1 - descuento);
    
    RETURN costo_total;
END$$

DELIMITER ;

USE `hotel`;
DROP function IF EXISTS `VerificarDisponibilidad`;

DELIMITER $$
USE `hotel`$$
CREATE FUNCTION `VerificarDisponibilidad` (
    p_id_habitacion INT,
    p_fecha_entrada DATE,
    p_fecha_salida DATE
) RETURNS BOOLEAN
BEGIN
    DECLARE disponible BOOLEAN DEFAULT TRUE;
    
    -- Verificar si la habitación está en mantenimiento
    IF EXISTS (
        SELECT 1 FROM MantenimientoHabitaciones 
        WHERE id_habitacion = p_id_habitacion 
        AND estado != 'Completado'
        AND (p_fecha_entrada BETWEEN fecha_inicio AND fecha_fin
             OR p_fecha_salida BETWEEN fecha_inicio AND fecha_fin
             OR fecha_inicio BETWEEN p_fecha_entrada AND p_fecha_salida)
    ) THEN
        SET disponible = FALSE;
    END IF;
    
    -- Verificar si la habitación tiene reservas en esas fechas
    IF EXISTS (
        SELECT 1 FROM Reservas 
        WHERE id_habitacion = p_id_habitacion 
        AND estado IN ('Confirmada', 'Pendiente')
        AND (p_fecha_entrada BETWEEN fecha_entrada AND fecha_salida
             OR p_fecha_salida BETWEEN fecha_entrada AND fecha_salida
             OR fecha_entrada BETWEEN p_fecha_entrada AND p_fecha_salida)
    ) THEN
        SET disponible = FALSE;
    END IF;
    
    RETURN disponible;
END$$

DELIMITER ;