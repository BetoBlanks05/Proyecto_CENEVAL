DROP DATABASE IF EXISTS sistema_evaluacion;
CREATE DATABASE sistema_evaluacion;
USE sistema_evaluacion;

CREATE TABLE Tema (
    id_tema INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    orden INT NOT NULL COMMENT 'Define la secuencia de avance del agente inteligente'
);

CREATE TABLE Pregunta (
    id_pregunta INT AUTO_INCREMENT PRIMARY KEY,
    id_tema INT NOT NULL,
    nivel_dificultad ENUM('basico', 'avanzado') NOT NULL,
    contexto TEXT NOT NULL,
    texto_pregunta TEXT NOT NULL,
    opciones JSON NOT NULL COMMENT 'Almacena el arreglo nativo de opciones',
    respuesta_correcta VARCHAR(255) NOT NULL,
    feedback TEXT NOT NULL,
    FOREIGN KEY (id_tema) REFERENCES Tema(id_tema) ON DELETE CASCADE
);

INSERT INTO Tema (nombre, orden) VALUES 
('Seguridad Informática', 1),
('Análisis Forense', 2),
('Programación Móvil', 3);

-- TEMA 1: SEGURIDAD INFORMÁTICA (5 Básicas, 5 Avanzadas)
INSERT INTO Pregunta (id_tema, nivel_dificultad, contexto, texto_pregunta, opciones, respuesta_correcta, feedback) VALUES
(1, 'basico', 'Una empresa requiere encriptar el tráfico web de su portal transaccional.', '¿Qué protocolo es el estándar actual más seguro para esta tarea?', '["SSL v3", "TLS 1.3", "IPSec", "HTTP"]', 'TLS 1.3', 'TLS 1.3 es el estándar criptográfico moderno que mitiga vulnerabilidades de SSL y versiones previas de TLS.'),
(1, 'basico', 'Un empleado recibe un correo simulando ser de TI solicitando su contraseña.', '¿Qué vector de ataque se está utilizando?', '["Ransomware", "Phishing", "Spoofing", "DDoS"]', 'Phishing', 'El phishing usa ingeniería social directa para engañar al usuario y capturar credenciales.'),
(1, 'basico', 'Se debe configurar el cortafuegos perimetral para una nueva sucursal.', '¿Cuál es el principio de diseño más seguro para las reglas de filtrado?', '["Permitir todo temporalmente", "Denegar por defecto", "Filtrar solo por MAC", "Bloquear solo el puerto 80"]', 'Denegar por defecto', 'El principio de Denegar por defecto asegura que solo el tráfico explícitamente autorizado pueda pasar.'),
(1, 'basico', 'Para evitar accesos no autorizados en caso de filtración de contraseñas, se implementa una capa extra.', '¿Qué control de seguridad se está aplicando?', '["Cifrado asimétrico", "MFA (Múltiple Factor de Autenticación)", "VPN", "Hashing"]', 'MFA (Múltiple Factor de Autenticación)', 'MFA requiere validación por dos o más canales distintos (ej. contraseña + token temporal).'),
(1, 'basico', 'Un formulario web procesa datos sin limpiarlos previamente.', '¿Qué tipo de ataque es el más probable a nivel de base de datos?', '["XSS", "Inyección SQL", "Man in the Middle", "Fuerza bruta"]', 'Inyección SQL', 'Sin parametrizar o sanitizar inputs, un atacante puede inyectar sentencias SQL directamente al motor.'),

(1, 'avanzado', 'Se audita una base de datos y se encuentra que usan MD5 sin salt.', '¿Cuál es la amenaza más crítica ante una extracción de la base?', '["Ataque de diccionario precomputado", "Desbordamiento de búfer", "Secuestro de sesión", "Inyección de código"]', 'Ataque de diccionario precomputado', 'Sin salt, los hashes deterministas como MD5 son vulnerables a tablas Rainbow (Rainbow Tables).'),
(1, 'avanzado', 'Una aplicación inyecta scripts no validados en el navegador de los usuarios.', '¿Qué ataque se está explotando?', '["CSRF", "Cross-Site Scripting (XSS)", "Clickjacking", "SSRF"]', 'Cross-Site Scripting (XSS)', 'XSS ocurre cuando un atacante logra ejecutar scripts maliciosos en el entorno del navegador de otra víctima.'),
(1, 'avanzado', 'Dos servidores necesitan intercambiar claves de sesión de forma segura por un canal inseguro.', '¿Qué algoritmo es adecuado para el intercambio de claves?', '["AES-256", "SHA-512", "RSA / Diffie-Hellman", "DES"]', 'RSA / Diffie-Hellman', 'La criptografía asimétrica o los protocolos como Diffie-Hellman resuelven el problema del intercambio seguro de claves.'),
(1, 'avanzado', 'Una arquitectura asume que la red interna ya está comprometida y requiere verificación constante.', '¿A qué modelo de seguridad corresponde?', '["Defensa en profundidad", "Zero Trust", "Perímetro seguro", "DMZ segmentada"]', 'Zero Trust', 'Zero Trust asume que no existe confianza implícita, verificando cada solicitud independientemente de su origen.'),
(1, 'avanzado', 'Un programa en C copia un string a la memoria sin comprobar su longitud, sobrescribiendo registros adyacentes.', '¿Cómo se clasifica esta vulnerabilidad?', '["Race condition", "Use-after-free", "Buffer Overflow", "Integer overflow"]', 'Buffer Overflow', 'El desbordamiento de búfer ocurre al exceder la capacidad de almacenamiento asignada en memoria, permitiendo ejecución de código.');

-- TEMA 2: ANÁLISIS FORENSE (5 Básicas, 5 Avanzadas)
INSERT INTO Pregunta (id_tema, nivel_dificultad, contexto, texto_pregunta, opciones, respuesta_correcta, feedback) VALUES
(2, 'basico', 'El equipo llega a un servidor encendido y posiblemente comprometido.', 'Según el orden de volatilidad, ¿qué se captura primero?', '["Disco duro", "Memoria RAM", "Logs del sistema", "Tráfico de red"]', 'Memoria RAM', 'La RAM contiene procesos activos, conexiones y claves en texto plano; se pierde al apagar el equipo.'),
(2, 'basico', 'Se debe garantizar que la evidencia no ha sido modificada desde su recolección.', '¿Qué procedimiento avala esto legalmente?', '["Cadena de custodia", "Clonación lógica", "Análisis estático", "Formateo a bajo nivel"]', 'Cadena de custodia', 'Documenta quién, cuándo y cómo manipuló la evidencia para mantener su validez judicial.'),
(2, 'basico', 'Se requiere validar la integridad de una imagen forense frente al disco original.', '¿Qué algoritmo es el estándar en la industria para esto?', '["Base64", "SHA-256", "AES", "RSA"]', 'SHA-256', 'Las funciones hash como SHA-256 generan una huella digital única para verificar que la copia es bit a bit exacta.'),
(2, 'basico', 'Un investigador conectará un disco sospechoso a su estación de trabajo.', '¿Qué hardware o software es obligatorio para evitar alterar la evidencia?', '["Clonador rápido", "Write blocker (Bloqueador de escritura)", "Antivirus", "Máquina virtual"]', 'Write blocker (Bloqueador de escritura)', 'Intercepta las instrucciones de escritura del SO, garantizando que el disco original se monte como solo lectura.'),
(2, 'basico', 'Se busca información oculta en el espacio no utilizado del último clúster asignado a un archivo.', '¿Cómo se le llama a este espacio?', '["Swap", "Slack space", "Unallocated space", "Paging file"]', 'Slack space', 'El slack space es la diferencia entre el tamaño lógico del archivo y el espacio físico del bloque de almacenamiento.'),

(2, 'avanzado', 'Un archivo de imagen de red social oculta un documento confidencial en sus bits menos significativos.', '¿Qué técnica se utilizó?', '["Ofuscación", "Criptografía", "Esteganografía", "Watermarking"]', 'Esteganografía', 'La esteganografía oculta información dentro de otro archivo portador para evadir su detección visual.'),
(2, 'avanzado', 'Se debe extraer el historial de comandos ejecutados, contraseñas cacheadas y conexiones TCP de un volcado de memoria.', '¿Qué framework es el estándar para esta tarea?', '["Autopsy", "Wireshark", "Volatility", "EnCase"]', 'Volatility', 'Volatility es la herramienta open-source líder en la industria para el análisis forense de memoria RAM.'),
(2, 'avanzado', 'Se investiga la persistencia de malware en un equipo Windows analizando el registro.', '¿Qué hive contiene la configuración específica del usuario afectado?', '["SAM", "SYSTEM", "SOFTWARE", "NTUSER.DAT"]', 'NTUSER.DAT', 'NTUSER.DAT mapea las configuraciones de la rama HKEY_CURRENT_USER del usuario específico.'),
(2, 'avanzado', 'Se intercepta un archivo PCAP de un posible exfiltrado de datos.', '¿Qué herramienta permite diseccionar y reconstruir los flujos TCP?', '["Nmap", "Wireshark", "Metasploit", "Netcat"]', 'Wireshark', 'Wireshark es un analizador de protocolos de red que permite decodificar paquetes y seguir flujos de comunicación.'),
(2, 'avanzado', 'Un archivo renombrado de .exe a .pdf debe ser identificado por su estructura real, no por su extensión.', '¿Qué se debe analizar?', '["Metadatos EXIF", "Firma del archivo (Magic numbers)", "Timestamp", "Permisos NTFS"]', 'Firma del archivo (Magic numbers)', 'Los "Magic numbers" son bytes fijos en el encabezado del archivo que identifican unívocamente su formato real.');

-- TEMA 3: PROGRAMACIÓN MÓVIL (5 Básicas, 5 Avanzadas)
INSERT INTO Pregunta (id_tema, nivel_dificultad, contexto, texto_pregunta, opciones, respuesta_correcta, feedback) VALUES
(3, 'basico', 'Una app en Android necesita ejecutar código justo cuando la interfaz se vuelve visible para el usuario.', '¿En qué método del ciclo de vida de la Activity se coloca?', '["onCreate", "onResume", "onPause", "onDestroy"]', 'onResume', 'onResume se dispara cuando la Activity está en el tope de la pila y comienza a interactuar con el usuario.'),
(3, 'basico', 'La aplicación debe guardar las preferencias de modo oscuro del usuario de forma sencilla.', '¿Cuál es la solución de almacenamiento local más eficiente para clave-valor?', '["SQLite", "Shared Preferences / DataStore", "Room", "Almacenamiento externo"]', 'Shared Preferences / DataStore', 'Ideal para persistir datos primitivos simples y configuraciones sin montar una base de datos relacional.'),
(3, 'basico', 'La aplicación se congela y el sistema lanza un error ANR (Application Not Responding).', '¿Cuál es la causa arquitectónica principal de este fallo?', '["Mala gestión de memoria", "Bloqueo del Main/UI Thread", "Falta de permisos", "Error de compilación"]', 'Bloqueo del Main/UI Thread', 'Las operaciones pesadas (red o base de datos) nunca deben correr en el hilo principal de la interfaz de usuario.'),
(3, 'basico', 'Se necesita diseñar una interfaz de usuario dinámica donde una misma pantalla adapte múltiples fragmentos de vista.', '¿Qué componente se debe usar?', '["Activity", "Intent", "Fragment", "Service"]', 'Fragment', 'Un Fragment representa un comportamiento o porción de interfaz modular dentro de una Activity.'),
(3, 'basico', 'Para invocar la cámara del dispositivo y devolver la foto, la app debe comunicarse con el sistema operativo.', '¿Qué mecanismo se utiliza?', '["Broadcast Receiver", "Intent explícito", "Intent implícito", "Content Provider"]', 'Intent implícito', 'Declara una acción genérica (ej. ACTION_IMAGE_CAPTURE) para que el SO asigne la app adecuada para resolverla.'),

(3, 'avanzado', 'Una Activity se destruye al rotar la pantalla, pero se requiere mantener una lista de datos descargada sin volver a consultar la API.', '¿Qué componente arquitectónico resuelve esto de forma nativa?', '["ViewModel", "SharedPreferences", "Service", "Singleton"]', 'ViewModel', 'El ViewModel está diseñado para almacenar y gestionar datos relacionados con la UI respetando el ciclo de vida, sobreviviendo a cambios de configuración.'),
(3, 'avanzado', 'Se implementa un flujo de datos asíncrono para leer desde la base de datos local y la red en Kotlin.', '¿Qué tecnología nativa moderna es la recomendada para esta concurrencia?', '["AsyncTask", "RxJava", "Corrutinas (Coroutines)", "Hilos puros (Threads)"]', 'Corrutinas (Coroutines)', 'Las corrutinas ofrecen un manejo de concurrencia ligero y estructurado integrado directamente en el lenguaje Kotlin.'),
(3, 'avanzado', 'Para reducir el acoplamiento y facilitar el testing, las dependencias de una clase deben ser suministradas desde fuera.', '¿Qué patrón y herramienta se aplican en Android para esto?', '["Inyección de Dependencias (Hilt/Dagger)", "Factory Pattern", "Service Locator", "Observer Pattern"]', 'Inyección de Dependencias (Hilt/Dagger)', 'Hilt automatiza la inyección de dependencias en Android, reduciendo el código repetitivo y estructurando mejor la app.'),
(3, 'avanzado', 'Se requiere programar tareas en segundo plano diferidas (ej. subida de logs) que garanticen su ejecución incluso si la app se cierra o el dispositivo se reinicia.', '¿Qué API del sistema es la correcta?', '["Foreground Service", "AlarmManager", "WorkManager", "JobScheduler"]', 'WorkManager', 'Es la API recomendada para tareas persistentes y diferidas que garantizan ejecución respetando las restricciones de batería del SO.'),
(3, 'avanzado', 'Un objeto mantiene una referencia estática a un Contexto (como una Activity) incluso después de que fue destruida.', '¿Qué problema crítico provoca esto en la aplicación?', '["Memory Leak (Fuga de memoria)", "NullPointerException", "IndexOutOfBounds", "StackOverflow"]', 'Memory Leak (Fuga de memoria)', 'El Garbage Collector no puede liberar la memoria de la Activity destruida porque aún existe una referencia fuerte, provocando fugas de memoria.');