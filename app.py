## Prototipo de sistema de evaluación adaptativa para estudiantes de programación
## Este prototipo implementa un sistema de evaluación adaptativa utilizando Flask y MySQL.
## Funcionalidades clave:
## - Inicio de examen con selección de tema inicial
## - Generación dinámica de preguntas basadas en el tema y dificultad
## - Evaluación de respuestas con feedback inmediato
## - Reglas de agente para ajustar dificultad y avanzar temas
## - Diagnóstico final con calificación y recomendaciones
## ######################################################
## Autores: Alberto Blancas Parra
##          David Moreno Razo

from flask import Flask, jsonify, request, session, render_template
import mysql.connector
import json

app = Flask(__name__)
app.secret_key = 'clave_secreta_prototipo'

@app.route('/')
def index():
    return render_template('index.html')

def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="200999",
        database="sistema_evaluacion"
    )

def obtener_ruta_aprendizaje():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT id_tema, nombre FROM Tema ORDER BY orden ASC")
    temas = cursor.fetchall()
    cursor.close()
    conn.close()
    return temas

@app.route('/api/start', methods=['POST'])
def start_exam():
    temas = obtener_ruta_aprendizaje()
    if not temas:
        return jsonify({"error": "Sin temas en DB"}), 500

    session['preguntas_totales'] = 0
    session['temas_ruta'] = temas
    session['tema_actual_idx'] = 0
    session['dificultad_actual'] = 'basico'
    session['racha_aciertos'] = 0
    session['preguntas_ronda'] = 0
    session['calificacion_acumulada'] = 0
    session['preguntas_vistas'] = [] 

    return jsonify({
        "status": "Examen iniciado", 
        "tema_inicial": temas[0]['nombre']
    })

@app.route('/api/next_question', methods=['GET'])
def get_next_question():
    if session.get('preguntas_totales', 0) >= 30:
        return generar_diagnostico_final()

    temas = session.get('temas_ruta')
    idx_actual = session.get('tema_actual_idx')
    
    if idx_actual >= len(temas):
        return generar_diagnostico_final() 

    tema_actual = temas[idx_actual]
    dificultad = session.get('dificultad_actual')
    vistas = session.get('preguntas_vistas', [])

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    if vistas:
        format_strings = ','.join(['%s'] * len(vistas))
        query = f"""
            SELECT id_pregunta, contexto, texto_pregunta, opciones, respuesta_correcta, feedback 
            FROM Pregunta 
            WHERE id_tema = %s AND nivel_dificultad = %s AND id_pregunta NOT IN ({format_strings})
            ORDER BY RAND() LIMIT 1
        """
        parametros = (tema_actual['id_tema'], dificultad) + tuple(vistas)
    else:
        query = """
            SELECT id_pregunta, contexto, texto_pregunta, opciones, respuesta_correcta, feedback 
            FROM Pregunta 
            WHERE id_tema = %s AND nivel_dificultad = %s 
            ORDER BY RAND() LIMIT 1
        """
        parametros = (tema_actual['id_tema'], dificultad)

    cursor.execute(query, parametros)
    pregunta = cursor.fetchone()
    cursor.close()
    conn.close()

    if not pregunta:
        return jsonify({"error": "Sin preguntas disponibles"}), 404

    vistas.append(pregunta['id_pregunta'])
    session['preguntas_vistas'] = vistas
    opciones = json.loads(pregunta['opciones']) if isinstance(pregunta['opciones'], str) else pregunta['opciones']

    session['pregunta_actual'] = {
        "id": pregunta['id_pregunta'],
        "respuesta": pregunta['respuesta_correcta'],
        "feedback": pregunta['feedback']
    }

    return jsonify({
        "tema": tema_actual['nombre'],
        "dificultad": dificultad,
        "contexto": pregunta['contexto'],
        "pregunta": pregunta['texto_pregunta'],
        "opciones": opciones,
        "progreso": f"{session['preguntas_totales']}/30"
    })

@app.route('/api/answer', methods=['POST'])
def submit_answer():
    data = request.json
    respuesta_usuario = data.get('respuesta')
    pregunta_actual = session.get('pregunta_actual')
    
    es_correcta = (respuesta_usuario == pregunta_actual['respuesta'])
    session['preguntas_totales'] += 1
    session['preguntas_ronda'] += 1
    
    if es_correcta:
        session['racha_aciertos'] += 1
        session['calificacion_acumulada'] += 1
    else:
        session['racha_aciertos'] = 0

    estado_ronda = evaluar_reglas_agente()

    return jsonify({
        "correcta": es_correcta,
        "feedback": pregunta_actual['feedback'],
        "estado_ronda": estado_ronda
    })

def evaluar_reglas_agente():
    # Avanza tema por racha
    if session['racha_aciertos'] >= 3:
        session['tema_actual_idx'] += 1
        session['dificultad_actual'] = 'basico'
        session['racha_aciertos'] = 0
        session['preguntas_ronda'] = 0
        return "avanza_tema"

    # Heurística predictiva de ronda
    preguntas_restantes = 5 - session['preguntas_ronda']
    max_racha_posible = session['racha_aciertos'] + preguntas_restantes

    # Fallo rápido si imposible ganar
    if max_racha_posible < 3:
        session['preguntas_ronda'] = 0
        session['racha_aciertos'] = 0
        
        if session['dificultad_actual'] == 'basico':
            session['dificultad_actual'] = 'avanzado'
            return "aumenta_dificultad"
        else:
            session['tema_actual_idx'] += 1
            session['dificultad_actual'] = 'basico'
            return "fuerza_avance_tema" 
            
    return "continua_ronda"

def generar_diagnostico_final():
    score = session.get('calificacion_acumulada', 0)
    total = session.get('preguntas_totales', 1)
    porcentaje = round((score / total) * 100, 2)
    
    comentario = "Competente. Buen dominio práctico."
    if porcentaje < 60:
        comentario = "Requiere reforzamiento de conceptos."
        
    return jsonify({
        "status": "finalizado",
        "score": score,
        "total_preguntas": total,
        "porcentaje": porcentaje,
        "comentario_desempeno": comentario
    })

if __name__ == '__main__':
    app.run(debug=True)