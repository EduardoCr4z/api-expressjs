DROP SCHEMA IF EXISTS `asignaciones` ;
CREATE SCHEMA IF NOT EXISTS `asignaciones` DEFAULT CHARACTER SET utf8 ;
USE `asignaciones` ;
SET NAMES utf8mb4;

-- -----------------------------------------------------
-- Table `asignaciones`.`Estudiante`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `asignaciones`.`Estudiante` ;
CREATE TABLE IF NOT EXISTS `asignaciones`.`Estudiante` (
  `idEstudiante` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(45) NOT NULL,
  `correo` VARCHAR(45) NOT NULL,
  `telefono` VARCHAR(45) NULL,
  PRIMARY KEY (`idEstudiante`))
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `asignaciones`.`Profesor`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `asignaciones`.`Profesor` ;
CREATE TABLE IF NOT EXISTS `asignaciones`.`Profesor` (
  `idProfesor` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(45) NOT NULL,
  `correo` VARCHAR(45) NOT NULL,
  `telefono` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`idProfesor`))
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `asignaciones`.`Curso`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `asignaciones`.`Curso` ;
CREATE TABLE IF NOT EXISTS `asignaciones`.`Curso` (
  `idCurso` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(45) NOT NULL,
  `idProfesor` INT NOT NULL,
  PRIMARY KEY (`idCurso`, `idProfesor`),
  CONSTRAINT `fk_Curso_Profesor1`
    FOREIGN KEY (`idProfesor`)
    REFERENCES `asignaciones`.`Profesor` (`idProfesor`))
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `asignaciones`.`Asignacion`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `asignaciones`.`Asignacion` ;
CREATE TABLE IF NOT EXISTS `asignaciones`.`Asignacion` (
  `idAsignacion` INT NOT NULL AUTO_INCREMENT,
  `puntos` VARCHAR(45) NOT NULL,
  `idEstudiante` INT NOT NULL,
  `idCurso` INT NOT NULL,
  `idProfesor` INT NOT NULL,
  PRIMARY KEY (`idAsignacion`, `idEstudiante`, `idCurso`, `idProfesor`),
  CONSTRAINT `fk_Asignacion_Estudiante1`
    FOREIGN KEY (`idEstudiante`)
    REFERENCES `asignaciones`.`Estudiante` (`idEstudiante`),
  CONSTRAINT `fk_Asignacion_Curso1`
    FOREIGN KEY (`idCurso` , `idProfesor`)
    REFERENCES `asignaciones`.`Curso` (`idCurso` , `idProfesor`))
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


INSERT INTO Estudiante (nombre, correo, telefono) VALUES
('Juan Pérez', 'juan.perez@email.com', '555-1001'),
('María López', 'maria.lopez@email.com', '555-1002'),
('Carlos Ramírez', 'carlos.ramirez@email.com', '555-1003'),
('Ana Torres', 'ana.torres@email.com', '555-1004'),
('Luis Mendoza', 'luis.mendoza@email.com', '555-1005');



INSERT INTO Profesor (nombre, correo, telefono) VALUES
('Dr. Roberto García', 'roberto.garcia@email.com', '555-2001'),
('Dra. Patricia Sánchez', 'patricia.sanchez@email.com', '555-2002'),
('Ing. Fernando Díaz', 'fernando.diaz@email.com', '555-2003'),
('Lic. Gabriela Morales', 'gabriela.morales@email.com', '555-2004'),
('Mtro. Andrés Castillo', 'andres.castillo@email.com', '555-2005');



INSERT INTO Curso (nombre, idProfesor) VALUES
('Matemáticas I', 1),
('Física I', 2),
('Programación I', 3),
('Historia Universal', 4),
('Base de Datos', 5);

INSERT INTO Asignacion 
(puntos, idEstudiante, idCurso, idProfesor) VALUES

-- Estudiante 1
('90', 1, 1, 1),
('85', 1, 3, 3),

-- Estudiante 2
('88', 2, 2, 2),
('92', 2, 4, 4),

-- Estudiante 3
('75', 3, 3, 3),
('89', 3, 5, 5),

-- Estudiante 4
('95', 4, 1, 1),
('80', 4, 2, 2),

-- Estudiante 5
('78', 5, 4, 4),
('91', 5, 5, 5);


    