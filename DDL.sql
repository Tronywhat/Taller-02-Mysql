DROP DATABASE IF EXISTS hotel;
CREATE DATABASE IF NOT EXISTS hotel;
USE hotel;

-- Tabla de Clientes
CREATE TABLE Clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    documento VARCHAR(20) UNIQUE
);

-- Tabla de Habitaciones
CREATE TABLE Habitaciones (
    id_habitacion INT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(10) UNIQUE NOT NULL,
    tipo ENUM('Individual', 'Doble', 'Triple', 'Cuádruple') NOT NULL,
    capacidad INT NOT NULL,
    precio_base DECIMAL(10,2) NOT NULL,
    estado ENUM('Disponible', 'Ocupada', 'Mantenimiento') DEFAULT 'Disponible'
);

-- Tabla de Reservas
CREATE TABLE Reservas (
    id_reserva INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_habitacion INT NOT NULL,
    fecha_reserva DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_entrada DATE NOT NULL,
    fecha_salida DATE NOT NULL,
    costo_total DECIMAL(10,2),
    estado ENUM('Pendiente', 'Confirmada', 'Cancelada', 'Finalizada') DEFAULT 'Pendiente',
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente),
    FOREIGN KEY (id_habitacion) REFERENCES Habitaciones(id_habitacion),
    CHECK (fecha_salida > fecha_entrada)
);

-- Tabla de Mantenimiento
CREATE TABLE MantenimientoHabitaciones (
    id_mantenimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_habitacion INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    descripcion VARCHAR(255),
    responsable VARCHAR(100),
    estado ENUM('Programado', 'En progreso', 'Completado') DEFAULT 'Programado',
    FOREIGN KEY (id_habitacion) REFERENCES Habitaciones(id_habitacion),
    CHECK (fecha_fin >= fecha_inicio)
);

-- Tabla de Registro de Cambios
CREATE TABLE RegistroCambiosReservas (
    id_registro INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva INT NOT NULL,
    accion VARCHAR(100) NOT NULL,
    fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP,
    detalles TEXT,
    FOREIGN KEY (id_reserva) REFERENCES Reservas(id_reserva)
);