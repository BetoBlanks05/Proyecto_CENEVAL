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

import random
from flask import Flask, jsonify, request, session, render_template
import mysql.connector
import json


app = Flask(__name__)
app.secret_key = 'clave_secreta_prototipo'

def get_db_connection():
    """Establece el puente entre el Motor de Inferencia y la Base de Conocimiento."""
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="200999",
        database="sistema_evaluacion"
    )

@app.route('/')
def index():
    session['score'] = 0
    session['total_preguntas'] = 0
    session['tema_actual'] = 1
    session['preguntas_tema'] = 0
    session['dificultad'] = 'basico'
    session['aciertos_seguidos'] = 0
    session['historial'] = []
    return render_template('index.html')

def aplicar_reglas_inferencia():

    aciertos_seguidos = session.get('aciertos_seguidos', 0)
    dificultad_actual = session.get('dificultad', 'basico')
    preguntas_tema = session.get('preguntas_tema', 0)
    
    # REGLA 1: Aumento de dificultad (Inferencia de nivel)
    if aciertos_seguidos >= 3 and dificultad_actual == 'basico':
        session['dificultad'] = 'avanzado'
        session['aciertos_seguidos'] = 0
    
    # REGLA 2: Cambio de tema (Razonamiento por bloques)
    if preguntas_tema >= 10:
        session['tema_actual'] += 1
        session['preguntas_tema'] = 0
        session['dificultad'] = 'basico'
        session['aciertos_seguidos'] = 0

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
    # 1. Limpiar sesión: CRÍTICO para evitar que variables viejas rompan el sistema
    session.clear() 
    
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM Tema")
    temas = cursor.fetchall()
    cursor.close()
    conn.close()

    # 2. Mezclar el orden de los temas (módulos aleatorios)
    random.shuffle(temas)

    # 3. Inicialización limpia
    session['temas_ruta'] = temas
    session['tema_actual_idx'] = 0
    session['dificultad_actual'] = 'basico'
    session['preguntas_vistas'] = [] 

    session['calificacion_acumulada'] = 0
    session['preguntas_totales'] = 0
    session['racha_aciertos'] = 0
    session['preguntas_ronda'] = 0
    session['metricas_tema'] = {tema['nombre']: {'correctas': 0, 'incorrectas': 0} for tema in temas}

    return jsonify({"status": "inicializado"})

@app.route('/api/next_question', methods=['GET'])
def get_next_question():
    temas_ruta = session.get('temas_ruta', [])
    tema_idx = session.get('tema_actual_idx', 0)

    # 1. Validación de fin de examen (usando idx, no la variable vieja)
    if tema_idx >= len(temas_ruta):
        return generar_diagnostico_final()

    tema_actual = temas_ruta[tema_idx]
    id_tema = tema_actual['id_tema']
    dificultad = session.get('dificultad_actual', 'basico')
    vistas = session.get('preguntas_vistas', [])

    # 2. Extracción de pregunta aleatoria sin repetir
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    if vistas:
        format_strings = ','.join(['%s'] * len(vistas))
        query = f"SELECT * FROM Pregunta WHERE id_tema = %s AND nivel_dificultad = %s AND id_pregunta NOT IN ({format_strings}) ORDER BY RAND() LIMIT 1"
        params = [id_tema, dificultad] + vistas
        cursor.execute(query, tuple(params))
    else:
        query = "SELECT * FROM Pregunta WHERE id_tema = %s AND nivel_dificultad = %s ORDER BY RAND() LIMIT 1"
        cursor.execute(query, (id_tema, dificultad))

    pregunta = cursor.fetchone()
    cursor.close()
    conn.close()

    # 3. Excepción de seguridad: Si el banco se queda sin preguntas, fuerza el avance al siguiente tema
    if not pregunta:
        session['tema_actual_idx'] += 1
        session['racha_aciertos'] = 0
        session['preguntas_ronda'] = 0
        session['dificultad_actual'] = 'basico'
        return get_next_question() # Llamada recursiva para traer la del nuevo tema

    # 4. Registrar la pregunta como vista
    vistas.append(pregunta['id_pregunta'])
    session['preguntas_vistas'] = vistas
    session['pregunta_actual'] = pregunta

    # 5. Aleatorizar el orden de las opciones de respuesta
    opciones = json.loads(pregunta['opciones'])
    random.shuffle(opciones)

    # 6. Cálculo de progreso global y por materia
    racha = session.get('racha_aciertos', 0)
    preguntas_ronda = session.get('preguntas_ronda', 0)
    total_temas = len(temas_ruta) if temas_ruta else 3 

    progreso_por_racha = (racha / 3) * 100
    progreso_por_limite = (preguntas_ronda / 5) * 100
    progreso_tema = min(100, max(progreso_por_racha, progreso_por_limite))

    if total_temas > 0:
        peso_por_tema = 100 / total_temas
        progreso_global = (tema_idx * peso_por_tema) + (progreso_tema / total_temas)
    else:
        progreso_global = 0

    return jsonify({
        "tema": tema_actual['nombre'],
        "dificultad": dificultad,
        "contexto": pregunta['contexto'],
        "pregunta": pregunta['texto_pregunta'],
        "opciones": opciones,
        "progreso_global": round(progreso_global),
        "progreso_tema": round(progreso_tema)
    })

@app.route('/api/answer', methods=['POST'])
def submit_answer():
    data = request.json
    respuesta_usuario = data.get('respuesta')
    pregunta_actual = session.get('pregunta_actual')
    
    es_correcta = (respuesta_usuario == pregunta_actual['respuesta'])
    session['preguntas_totales'] += 1
    session['preguntas_ronda'] += 1
    
    # Actualizar métricas del tema específico
    tema_actual_nombre = session.get('temas_ruta')[session['tema_actual_idx']]['nombre']
    if es_correcta:
        session['metricas_tema'][tema_actual_nombre]['correctas'] += 1
        session['racha_aciertos'] += 1
        session['calificacion_acumulada'] += 1
    else:
        session['metricas_tema'][tema_actual_nombre]['incorrectas'] += 1
        session['racha_aciertos'] = 0

    estado_ronda = evaluar_reglas_agente()

    return jsonify({
        "correcta": es_correcta,
        "respuesta_esperada": pregunta_actual['respuesta'], # Necesario para feedback detallado
        "respuesta_usuario": respuesta_usuario,
        "feedback": pregunta_actual['feedback'],
        "estado_ronda": estado_ronda
    })

@app.route('/test', methods=['GET', 'POST'])
def test():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    if request.method == 'POST':
        # Procesar respuesta y actualizar hechos
        id_p = request.form.get('id_pregunta')
        resp_user = request.form.get('respuesta')
        
        cursor.execute("SELECT * FROM Pregunta WHERE id_pregunta = %s", (id_p,))
        pregunta = cursor.fetchone()
        
        es_correcta = (resp_user == pregunta['respuesta_correcta'])
        
        # Actualización de hechos
        session['total_preguntas'] += 1
        session['preguntas_tema'] += 1
        
        if es_correcta:
            session['score'] += 1
            session['aciertos_seguidos'] += 1
        else:
            session['aciertos_seguidos'] = 0
            
        # Aplicar el motor de inferencia para la siguiente pregunta
        aplicar_reglas_inferencia()
        
        # Guardar historial para el PDF final
        session['historial'].append({
            'pregunta': pregunta['texto_pregunta'],
            'correcta': es_correcta,
            'feedback': pregunta['feedback']
        })

    # Finalizar si llegamos al límite de 30 preguntas o temas
    if session['total_preguntas'] >= 30 or session['tema_actual'] > 3:
        return redirect(url_for('resultados'))

    # Seleccionar siguiente pregunta basada en hechos actuales
    cursor.execute("""
        SELECT * FROM Pregunta 
        WHERE id_tema = %s AND nivel_dificultad = %s 
        ORDER BY RAND() LIMIT 1
    """, (session['tema_actual'], session['dificultad']))
    
    nueva_pregunta = cursor.fetchone()
    nueva_pregunta['opciones'] = json.loads(nueva_pregunta['opciones'])
    
    conn.close()
    return render_template('test.html', pregunta=nueva_pregunta)

@app.route('/resultados')
def resultados():
    # Razonamiento final y generación de dictamen
    porcentaje = (session['score'] / 30) * 100
    dictamen = "Sobresaliente" if porcentaje >= 90 else "Satisfactorio" if porcentaje >= 70 else "Aún no satisfactorio"
    return render_template('resultados.html', score=session['score'], dictamen=dictamen)

def evaluar_reglas_agente():
    # Avanza tema por racha
    if session['racha_aciertos'] >= 3:
        session['tema_actual_idx'] += 1
        session['dificultad_actual'] = 'basico'
        session['racha_aciertos'] = 0
        session['preguntas_ronda'] = 0
        return "avanza_tema"

    # Heuristica predictiva de ronda
    preguntas_restantes = 5 - session['preguntas_ronda']
    max_racha_posible = session['racha_aciertos'] + preguntas_restantes

    # Fallo rapido si imposible ganar
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
    metricas = session.get('metricas_tema', {})
    
    # Generación de diagnóstico detallado
    areas_mejora = []
    for tema, stats in metricas.items():
        total_tema = stats['correctas'] + stats['incorrectas']
        if total_tema > 0:
            pct_tema = stats['correctas'] / total_tema
            if pct_tema < 0.7:  # Menos del 70% requiere mejora
                areas_mejora.append(tema)

    if not areas_mejora:
        comentario = "Sobresaliente. Demuestras un dominio práctico y sólido en todas las áreas evaluadas. No hay deficiencias críticas detectadas."
    else:
        comentario = f"Desempeño general del {porcentaje}%. Tienes fallas estructurales que requieren atención inmediata en las siguientes áreas: {', '.join(areas_mejora)}. Se recomienda repasar los conceptos fundamentales de estos módulos."

    # Guardar resultados en BD
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO ResultadoEvaluacion (puntaje_total, porcentaje, desglose_temas, comentario_final) VALUES (%s, %s, %s, %s)",
            (score, porcentaje, json.dumps(metricas), comentario)
        )
        conn.commit()
        cursor.close()
        conn.close()
    except Exception as e:
        print("Error guardando métricas:", e)

    return jsonify({
        "status": "finalizado",
        "score": score,
        "total_preguntas": total,
        "porcentaje": porcentaje,
        "comentario_desempeno": comentario,
        "desglose": metricas
    })

if __name__ == '__main__':
    app.run(debug=True)