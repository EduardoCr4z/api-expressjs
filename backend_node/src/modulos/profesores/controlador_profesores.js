const db = require('../../DB/profesor_db');

const TABLA = 'Profesor'
function leer (){
    return db.leer(TABLA);
}

function crear (data){
    return db.crear(TABLA, data);
}

function eliminar (data){
    return db.eliminar(TABLA, data);
}
function actualizar (data, id){
    return db.actualizar(TABLA, data, id)
}


module.exports = {
    leer,
    crear,
    eliminar,
    actualizar
}