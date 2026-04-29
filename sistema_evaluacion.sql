DROP DATABASE IF EXISTS sistema_evaluacion;
CREATE DATABASE sistema_evaluacion;
USE sistema_evaluacion;

CREATE TABLE Tema (
    id_tema INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    orden INT NOT NULL
);

CREATE TABLE Pregunta (
    id_pregunta INT AUTO_INCREMENT PRIMARY KEY,
    id_tema INT NOT NULL,
    nivel_dificultad ENUM('basico', 'avanzado') NOT NULL,
    contexto TEXT NOT NULL,
    texto_pregunta TEXT NOT NULL,
    opciones JSON NOT NULL,
    respuesta_correcta VARCHAR(255) NOT NULL,
    feedback TEXT NOT NULL,
    FOREIGN KEY (id_tema) REFERENCES Tema(id_tema) ON DELETE CASCADE
);

INSERT INTO Tema (nombre, orden) VALUES 
('Fundamentos de Programación', 1),
('Bases de Datos', 2),
('Desarrollo Web', 3);

-- TEMA 1: FUNDAMENTOS DE PROGRAMACIÓN
INSERT INTO Pregunta (id_tema, nivel_dificultad, contexto, texto_pregunta, opciones, respuesta_correcta, feedback) VALUES
(1, 'basico', 'Se requiere almacenar la edad de un usuario en una variable que no cambiará durante la ejecución.', '¿Qué tipo de declaración es la más adecuada?', '["Variable global", "Constante", "Arreglo", "Puntero"]', 'Constante', 'Las constantes protegen la integridad de datos fijos.'),
(1, 'basico', 'Un algoritmo debe repetir una acción exactamente 10 veces.', '¿Qué estructura de control es preferible?', '["While", "If-Else", "For", "Switch"]', 'For', 'El ciclo For es óptimo para iteraciones definidas.'),
(1, 'basico', 'Se necesita verificar si un número es par o impar.', '¿Qué operador aritmético se debe utilizar?', '["División (/)", "Módulo (%)", "Multiplicación (*)", "Resta (-)"]', 'Módulo (%)', 'El residuo 0 indica que el número es par.'),
(1, 'basico', 'Una función necesita devolver un valor verdadero o falso.', '¿Qué tipo de dato debe retornar?', '["Integer", "String", "Boolean", "Float"]', 'Boolean', 'Los booleanos manejan lógica binaria (True/False).'),
(1, 'basico', 'Se desea agrupar 5 nombres de estudiantes en una sola estructura.', '¿Qué tipo de dato compuesto es el más común?', '["Char", "Array", "Double", "Long"]', 'Array', 'Los arreglos indexan múltiples elementos del mismo tipo.'),
(1, 'avanzado', 'Se busca medir la eficiencia de un algoritmo de ordenamiento en el peor de los casos.', '¿Qué notación se utiliza para este análisis?', '["Notación Big O", "Notación Decimal", "Álgebra de Boole", "Lógica difusa"]', 'Notación Big O', 'Big O describe el límite superior de complejidad.'),
(1, 'avanzado', 'Una función se llama a sí misma para resolver un problema dividiéndolo en subproblemas.', '¿Cómo se define esta técnica?', '["Iteración", "Encapsulamiento", "Recursividad", "Polimorfismo"]', 'Recursividad', 'La recursividad utiliza la pila de llamadas para ciclos.'),
(1, 'avanzado', 'En Programación Orientada a Objetos, se ocultan los detalles internos de una clase.', '¿Qué principio se está aplicando?', '["Herencia", "Abstracción", "Encapsulamiento", "Instanciación"]', 'Encapsulamiento', 'Protege el estado interno del objeto.'),
(1, 'avanzado', 'Se requiere que una clase hija adquiera métodos y atributos de una clase padre.', '¿Cómo se le denomina a esta relación?', '["Sobrecarga", "Herencia", "Interfaz", "Constructor"]', 'Herencia', 'Permite la reutilización y extensión de código.'),
(1, 'avanzado', 'Se desea crear una función que acepte diferentes tipos de datos sin duplicar código.', '¿Qué concepto se utiliza en lenguajes como Java o C#?', '["Genéricos", "Variables locales", "Punteros", "Scripts"]', 'Genéricos', 'Permiten parametrizar tipos para mayor flexibilidad.');

-- TEMA 2: BASES DE DATOS
INSERT INTO Pregunta (id_tema, nivel_dificultad, contexto, texto_pregunta, opciones, respuesta_correcta, feedback) VALUES
(2, 'basico', 'Se requiere extraer todos los registros de la tabla "Usuarios".', '¿Qué sentencia SQL es la correcta?', '["GET * FROM Usuarios", "SELECT * FROM Usuarios", "PUSH * FROM Usuarios", "READ Usuarios"]', 'SELECT * FROM Usuarios', 'SELECT es la sentencia estándar de recuperación.'),
(2, 'basico', 'Se desea identificar de forma única cada registro en una tabla.', '¿Qué tipo de llave debe definirse?', '["Llave foránea", "Llave primaria (PK)", "Llave candidata", "Llave compuesta"]', 'Llave primaria (PK)', 'La PK garantiza la unicidad y no nulidad.'),
(2, 'basico', 'Es necesario filtrar los resultados de una consulta para obtener solo ventas mayores a $1000.', '¿Qué cláusula se utiliza?', '["ORDER BY", "GROUP BY", "WHERE", "JOIN"]', 'WHERE', 'WHERE aplica condiciones lógicas a la consulta.'),
(2, 'basico', 'Se requiere ordenar una lista de productos por precio de menor a mayor.', '¿Qué comando se debe agregar al final?', '["ORDER BY precio DESC", "ORDER BY precio ASC", "SORT BY precio", "GROUP BY precio"]', 'ORDER BY precio ASC', 'ASC realiza el ordenamiento ascendente.'),
(2, 'basico', 'Se desea eliminar un registro específico de la base de datos.', '¿Qué comando es el adecuado?', '["REMOVE", "DROP", "DELETE", "TRUNCATE"]', 'DELETE', 'DELETE elimina filas; DROP elimina objetos o tablas.'),
(2, 'avanzado', 'Se requiere combinar datos de dos tablas (Clientes y Pedidos) que comparten un ID.', '¿Qué tipo de unión es la más común?', '["OUTER JOIN", "INNER JOIN", "CROSS JOIN", "UNION"]', 'INNER JOIN', 'INNER JOIN recupera registros con coincidencias en ambas.'),
(2, 'avanzado', 'Se busca eliminar la redundancia de datos y proteger la integridad referencial.', '¿A qué proceso se refiere?', '["Indexación", "Normalización", "Transacción", "Minería"]', 'Normalización', 'La normalización organiza tablas para evitar anomalías.'),
(2, 'avanzado', 'Se requiere ejecutar una serie de operaciones SQL como una única unidad de trabajo (todo o nada).', '¿Cómo se le conoce a este concepto?', '["Procedimiento", "Trigger", "Transacción", "Vista"]', 'Transacción', 'Las transacciones garantizan propiedades ACID.'),
(2, 'avanzado', 'Para acelerar la búsqueda de registros en una columna muy grande, se crea una estructura especial.', '¿Qué se debe implementar?', '["Clúster", "Índice", "Llave foránea", "Caché"]', 'Índice', 'Los índices optimizan la velocidad de lectura.'),
(2, 'avanzado', 'Se requiere que un script se ejecute automáticamente cuando se inserta un dato en una tabla.', '¿Qué objeto de base de datos se debe programar?', '["Store Procedure", "View", "Trigger", "Cursor"]', 'Trigger', 'Los disparadores reaccionan a eventos DML.');

-- TEMA 3: DESARROLLO WEB
INSERT INTO Pregunta (id_tema, nivel_dificultad, contexto, texto_pregunta, opciones, respuesta_correcta, feedback) VALUES
(3, 'basico', 'Se desea crear la estructura básica de una página web.', '¿Qué lenguaje es el estándar para el marcado de contenido?', '["CSS", "JavaScript", "HTML", "PHP"]', 'HTML', 'HTML define la estructura semántica del documento.'),
(3, 'basico', 'Se requiere cambiar el color de fondo y el tamaño de fuente de un sitio.', '¿Qué tecnología se debe emplear?', '["SQL", "CSS", "JSON", "Python"]', 'CSS', 'CSS gestiona la presentación y el diseño visual.'),
(3, 'basico', 'Se necesita agregar interactividad, como una alerta al presionar un botón.', '¿Qué lenguaje corre nativamente en el navegador?', '["Java", "JavaScript", "C#", "Ruby"]', 'JavaScript', 'JavaScript es el motor de comportamiento en el cliente.'),
(3, 'basico', 'Un navegador solicita una página que no existe en el servidor.', '¿Qué código de estado HTTP se devuelve habitualmente?', '["200 OK", "500 Error", "404 Not Found", "301 Move"]', '404 Not Found', 'El error 404 indica recurso no encontrado.'),
(3, 'basico', 'Se envían datos de un formulario de registro que deben ser procesados por el servidor.', '¿Qué método HTTP es el más seguro para enviar contraseñas?', '["GET", "POST", "PUT", "DELETE"]', 'POST', 'POST envía datos en el cuerpo de la petición.'),
(3, 'avanzado', 'Se requiere que una aplicación web actualice contenido sin recargar toda la página.', '¿Qué técnica se utiliza?', '["Sincronización", "AJAX", "Compilación", "Serialización"]', 'AJAX', 'AJAX permite actualizaciones asíncronas con el servidor.'),
(3, 'avanzado', 'Se desea almacenar un token de sesión en el navegador que persista incluso al cerrar la ventana.', '¿Dónde se debe guardar?', '["SessionStorage", "LocalStorage", "Cookies temporales", "Caché L1"]', 'LocalStorage', 'LocalStorage no tiene tiempo de expiración automático.'),
(3, 'avanzado', 'Un desarrollador usa un framework basado en componentes para construir interfaces complejas.', '¿Cuál de estos es una opción popular?', '["Django", "React", "Laravel", "Flask"]', 'React', 'React se especializa en interfaces basadas en componentes.'),
(3, 'avanzado', 'Se busca proteger una API para que solo usuarios autenticados puedan realizar peticiones.', '¿Qué estándar de tokens es el más utilizado?', '["XML", "JWT (JSON Web Token)", "CSV", "Markdown"]', 'JWT (JSON Web Token)', 'JWT es el estándar para intercambio seguro de identidad.'),
(3, 'avanzado', 'En el backend, se necesita un entorno de ejecución que use JavaScript fuera del navegador.', '¿Qué tecnología se debe instalar?', '["Node.js", "Apache", "Nginx", "Docker"]', 'Node.js', 'Node.js permite usar JS en el lado del servidor.');