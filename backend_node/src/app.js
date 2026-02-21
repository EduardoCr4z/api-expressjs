const express = require('express');
const config = require('./config');
const path = require('path');


const estudiantes = require('./modulos/estudiantes/rutas_estudiantes');
const profesores = require('./modulos/profesores/rutas_profesores');
const cursos = require('./modulos/cursos/rutas_cursos');
const asignaciones = require('./modulos/asignaciones/rutas_asignaciones');



const app = express();

//Configuración
app.set('port', config.app.port);

app.use(express.static(path.resolve(__dirname, '..', 'public')));

app.use(express.json());
//Rutas
// Estudiantes
app.use('/api/estudiantes', estudiantes);
// Profesores
app.use('/api/profesores', profesores);
// Cursos
app.use('/api/cursos', cursos);
// Asignaciones
app.use('/api/asignaciones', asignaciones);

module.exports = app;