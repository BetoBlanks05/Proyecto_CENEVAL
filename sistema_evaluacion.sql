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
('Fundamentos de Programación', 1), ('Bases de Datos', 2), ('Desarrollo Web', 3);

TRUNCATE TABLE Pregunta;

-- TEMA 1: FUNDAMENTOS DE PROGRAMACIÓN
INSERT INTO Pregunta (id_tema, nivel_dificultad, contexto, texto_pregunta, opciones, respuesta_correcta, feedback) VALUES
(1, 'basico', 'Se requiere almacenar la edad de un usuario en una variable que no cambiará durante la ejecución.', '¿Qué tipo de declaración es la más adecuada?', '["Variable global", "Constante", "Arreglo", "Puntero"]', 'Constante', 'Las constantes protegen la integridad de datos fijos al impedir modificaciones accidentales.'),
(1, 'basico', 'Un algoritmo debe repetir una acción exactamente 10 veces.', '¿Qué estructura de control es preferible?', '["While", "If-Else", "For", "Switch"]', 'For', 'El ciclo For es óptimo para iteraciones donde el límite está definido de antemano.'),
(1, 'basico', 'Se necesita verificar si un número es par o impar.', '¿Qué operador aritmético se debe utilizar?', '["División (/)", "Módulo (%)", "Multiplicación (*)", "Resta (-)"]', 'Módulo (%)', 'El residuo 0 al dividir entre 2 indica que el número es par.'),
(1, 'basico', 'Una función necesita devolver un valor verdadero o falso.', '¿Qué tipo de dato debe retornar?', '["Integer", "String", "Boolean", "Float"]', 'Boolean', 'Los booleanos manejan lógica binaria fundamental en la toma de decisiones.'),
(1, 'basico', 'Se desea agrupar 5 nombres de estudiantes en una sola estructura.', '¿Qué tipo de dato compuesto es el más común?', '["Char", "Array", "Double", "Long"]', 'Array', 'Los arreglos indexan múltiples elementos del mismo tipo en memoria contigua.'),
(1, 'avanzado', 'Se busca medir la eficiencia de un algoritmo de ordenamiento en el peor de los casos.', '¿Qué notación se utiliza para este análisis?', '["Notación Big O", "Notación Decimal", "Álgebra de Boole", "Lógica difusa"]', 'Notación Big O', 'La Notación Big O describe el límite superior de la complejidad temporal o espacial.'),
(1, 'avanzado', 'Una función se llama a sí misma para resolver un problema dividiéndolo en subproblemas.', '¿Cómo se define esta técnica?', '["Iteración", "Encapsulamiento", "Recursividad", "Polimorfismo"]', 'Recursividad', 'La recursividad utiliza la pila de llamadas para procesar estructuras anidadas.'),
(1, 'avanzado', 'En Programación Orientada a Objetos, se ocultan los detalles internos de una clase.', '¿Qué principio se está aplicando?', '["Herencia", "Abstracción", "Encapsulamiento", "Instanciación"]', 'Encapsulamiento', 'El encapsulamiento protege el estado interno del objeto mediante modificadores de acceso.'),
(1, 'avanzado', 'Se requiere que una clase hija adquiera métodos y atributos de una clase padre.', '¿Cómo se le denomina a esta relación?', '["Sobrecarga", "Herencia", "Interfaz", "Constructor"]', 'Herencia', 'La herencia permite la reutilización de código y la jerarquización de clases.'),
(1, 'avanzado', 'Se desea crear una función que acepte diferentes tipos de datos sin duplicar código.', '¿Qué concepto se utiliza en lenguajes como Java o C#?', '["Genéricos", "Variables locales", "Punteros", "Scripts"]', 'Genéricos', 'Los tipos genéricos permiten parametrizar la lógica para diferentes estructuras de datos.');

-- TEMA 2: BASES DE DATOS
INSERT INTO Pregunta (id_tema, nivel_dificultad, contexto, texto_pregunta, opciones, respuesta_correcta, feedback) VALUES
(2, 'basico', 'Se requiere extraer todos los registros de la tabla Usuarios.', '¿Qué sentencia SQL es la correcta?', '["GET * FROM Usuarios", "SELECT * FROM Usuarios", "PUSH * FROM Usuarios", "READ Usuarios"]', 'SELECT * FROM Usuarios', 'SELECT es la instrucción base del DML para recuperación de datos.'),
(2, 'basico', 'Se desea identificar de forma única cada registro en una tabla.', '¿Qué tipo de llave debe definirse?', '["Llave foránea", "Llave primaria (PK)", "Llave candidata", "Llave compuesta"]', 'Llave primaria (PK)', 'La PK garantiza la unicidad y no nulidad de los registros en una relación.'),
(2, 'basico', 'Es necesario filtrar los resultados de una consulta para obtener solo ventas mayores a 1000.', '¿Qué cláusula se utiliza?', '["ORDER BY", "GROUP BY", "WHERE", "JOIN"]', 'WHERE', 'La cláusula WHERE aplica predicados lógicos para filtrar filas.'),
(2, 'basico', 'Se requiere ordenar una lista de productos por precio de menor a mayor.', '¿Qué comando se debe agregar al final?', '["ORDER BY precio DESC", "ORDER BY precio ASC", "SORT BY precio", "GROUP BY precio"]', 'ORDER BY precio ASC', 'ASC realiza un ordenamiento ascendente por defecto.'),
(2, 'basico', 'Se desea eliminar un registro específico de la base de datos.', '¿Qué comando es el adecuado?', '["REMOVE", "DROP", "DELETE", "TRUNCATE"]', 'DELETE', 'DELETE elimina registros bajo condición, mientras DROP elimina la estructura de la tabla.'),
(2, 'avanzado', 'Se requiere combinar datos de dos tablas que comparten un identificador común.', '¿Qué tipo de unión recupera solo registros con coincidencias?', '["LEFT JOIN", "INNER JOIN", "CROSS JOIN", "FULL JOIN"]', 'INNER JOIN', 'INNER JOIN es la operación de conjunto que intersecta registros relacionados.'),
(2, 'avanzado', 'Se busca eliminar la redundancia de datos y proteger la integridad referencial.', '¿A qué proceso se refiere?', '["Indexación", "Normalización", "Transacción", "Minería"]', 'Normalización', 'La normalización organiza el esquema para evitar anomalías de actualización.'),
(2, 'avanzado', 'Se requiere ejecutar una serie de operaciones SQL como una única unidad de trabajo.', '¿Cómo se le conoce a este concepto?', '["Procedimiento", "Trigger", "Transacción", "Vista"]', 'Transacción', 'Las transacciones garantizan las propiedades ACID en el motor de base de datos.'),
(2, 'avanzado', 'Para acelerar la búsqueda de registros en una tabla de gran volumen, se crea una estructura especial.', '¿Qué se debe implementar?', '["Clúster", "Índice", "Llave foránea", "Caché"]', 'Índice', 'Los índices mejoran drásticamente el rendimiento de las consultas de lectura.'),
(2, 'avanzado', 'Se requiere que un script se ejecute automáticamente ante una inserción o actualización.', '¿Qué objeto de base de datos se debe programar?', '["Store Procedure", "View", "Trigger", "Cursor"]', 'Trigger', 'Los disparadores (Triggers) reaccionan a eventos DML específicos automáticamente.');

-- TEMA 3: DESARROLLO WEB
INSERT INTO Pregunta (id_tema, nivel_dificultad, contexto, texto_pregunta, opciones, respuesta_correcta, feedback) VALUES
(3, 'basico', 'Se desea crear la estructura básica de una página web.', '¿Qué lenguaje es el estándar para el marcado de contenido?', '["CSS", "JavaScript", "HTML", "PHP"]', 'HTML', 'HTML define la semántica y estructura del documento en el navegador.'),
(3, 'basico', 'Se requiere cambiar el color de fondo y el diseño visual de un sitio.', '¿Qué tecnología se debe emplear?', '["SQL", "CSS", "JSON", "Python"]', 'CSS', 'CSS separa la presentación del contenido de la estructura.'),
(3, 'basico', 'Se necesita agregar interactividad dinámica en el lado del cliente.', '¿Qué lenguaje corre nativamente en el navegador?', '["Java", "JavaScript", "C#", "Ruby"]', 'JavaScript', 'JavaScript es el lenguaje estándar para la lógica de front-end.'),
(3, 'basico', 'Un navegador solicita un recurso que no existe en el servidor.', '¿Qué código de estado HTTP se devuelve?', '["200 OK", "500 Error", "404 Not Found", "301 Move"]', '404 Not Found', 'El código 404 indica que el servidor no pudo encontrar el recurso solicitado.'),
(3, 'basico', 'Se envían datos sensibles de un formulario de registro al servidor.', '¿Qué método HTTP es el más adecuado?', '["GET", "POST", "HEAD", "OPTIONS"]', 'POST', 'POST envía los datos en el cuerpo de la petición, ocultándolos de la URL.'),
(3, 'avanzado', 'Se requiere que una aplicación web actualice partes de la página sin recargar todo el sitio.', '¿Qué técnica asíncrona se utiliza?', '["Sincronización", "AJAX", "Compilación", "Serialización"]', 'AJAX', 'AJAX permite la comunicación asíncrona con el servidor para mejorar la UX.'),
(3, 'avanzado', 'Se desea almacenar un token de sesión en el navegador que no expire al cerrar la pestaña.', '¿Dónde se debe guardar?', '["SessionStorage", "LocalStorage", "Cookies de sesión", "Caché L1"]', 'LocalStorage', 'LocalStorage ofrece persistencia de datos en el cliente sin límite de tiempo.'),
(3, 'avanzado', 'Se utiliza una biblioteca basada en componentes para construir interfaces de usuario.', '¿Cuál es una opción líder en el mercado actual?', '["Django", "React", "Laravel", "Flask"]', 'React', 'React emplea un Virtual DOM y arquitectura de componentes para interfaces escalables.'),
(3, 'avanzado', 'Se busca un estándar para el intercambio seguro de información de identidad mediante tokens.', '¿Cuál es el más utilizado en APIs REST?', '["XML", "JWT (JSON Web Token)", "CSV", "Markdown"]', 'JWT (JSON Web Token)', 'JWT es un estándar compacto y seguro para transmitir objetos JSON firmados.'),
(3, 'avanzado', 'Se necesita un entorno de ejecución para JavaScript en el lado del servidor.', '¿Qué tecnología permite esto?', '["Node.js", "Apache", "Nginx", "Docker"]', 'Node.js', 'Node.js permite usar el motor V8 fuera del navegador para aplicaciones de backend.');