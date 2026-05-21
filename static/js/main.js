document.addEventListener("DOMContentLoaded", () => {
    const ui = {
        topicTitle: document.getElementById('topic-title'),
        progressBadge: document.getElementById('progress-badge'),
        diffBadge: document.getElementById('diff-badge'),
        contextBox: document.getElementById('context-box'),
        questionText: document.getElementById('question-text'),
        optionsGrid: document.getElementById('options-grid'),
        feedbackPanel: document.getElementById('feedback-panel'),
        nextBtn: document.getElementById('next-btn'),
        mainContent: document.getElementById('main-content'),
        resultsContent: document.getElementById('results-content')
    };

    fetch('/api/start', { method: 'POST' })
        .then(res => res.json())
        .then(data => {
            if(data.error) {
                ui.topicTitle.innerText = "Error de conexión";
                ui.contextBox.innerText = data.error;
            } else {
                fetchNextQuestion();
            }
        });

    function fetchNextQuestion() {
        resetUI();

        fetch('/api/next_question')
            .then(res => res.json())
            .then(data => {
                if (data.status === "finalizado") {
                    renderResults(data);
                    return;
                }
                if (data.error) {
                    alert(data.error);
                    return;
                }
                renderQuestion(data);
            });
    }

    function renderQuestion(data) {
        const mainContent = document.getElementById('main-content');
        mainContent.classList.remove('new-question-animate');
        void mainContent.offsetWidth; // Trigger reflow para reiniciar animación
        mainContent.classList.add('new-question-animate');

        ui.topicTitle.innerText = data.tema;
        
        // Actualización de los badges con los porcentajes reales
        document.getElementById('topic-progress-badge').innerText = `Materia: ${data.progreso_tema}%`;
        ui.progressBadge.innerText = `Global: ${data.progreso_global}%`;
        
        // La barra de progreso principal ahora refleja el avance global adaptativo
        document.getElementById('progress-fill').style.width = `${data.progreso_global}%`;
        
        ui.diffBadge.innerText = `Nivel: ${data.dificultad.toUpperCase()}`;
        ui.diffBadge.className = `diff-badge diff-${data.dificultad}`;
        ui.diffBadge.classList.remove('hidden');

        ui.contextBox.innerText = data.contexto;
        ui.questionText.innerText = data.pregunta;

        ui.optionsGrid.innerHTML = ''; // Limpiar grid
        data.opciones.forEach(opcion => {
            const btn = document.createElement('button');
            btn.className = 'option-btn';
            btn.innerText = opcion;
            btn.onclick = () => submitAnswer(opcion, btn);
            ui.optionsGrid.appendChild(btn);
        });
    }

    function submitAnswer(respuesta, btnSelected) {
        document.querySelectorAll('.option-btn').forEach(b => b.disabled = true);

        btnSelected.classList.add('processing');
        btnSelected.innerText = 'Evaluando...';

        fetch('/api/answer', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ respuesta: respuesta })
        })
        .then(res => res.json())
        .then(data => {
            btnSelected.classList.remove('processing');
            btnSelected.innerText = respuesta;
            btnSelected.classList.add(data.correcta ? 'selected-correct' : 'selected-error');
            
            ui.feedbackPanel.className = `feedback-panel ${data.correcta ? 'correct' : 'error'}`;
            
            // Construcción de feedback detallado
            if (data.correcta) {
                ui.feedbackPanel.innerHTML = `<strong>¡Correcto!</strong><br><br>${data.feedback}`;
            } else {
                ui.feedbackPanel.innerHTML = `
                    <strong>Respuesta Incorrecta</strong><br><br>
                    <span style="color: #64748b; font-size: 0.9em;">Tu selección: <del>${data.respuesta_usuario}</del></span><br>
                    <span style="color: #166534; font-size: 0.9em; font-weight: 600;">Respuesta esperada: ${data.respuesta_esperada}</span><br><br>
                    <strong>Explicación técnica:</strong> ${data.feedback}
                `;
            }
            ui.feedbackPanel.style.display = 'block';

            ui.nextBtn.style.display = 'block';
            ui.nextBtn.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
            ui.nextBtn.onclick = fetchNextQuestion;
        });
    }

    function renderResults(data) {
        ui.mainContent.classList.add('hidden');
        ui.resultsContent.classList.remove('hidden');
        ui.topicTitle.innerText = "Diagnóstico Final del Agente";
        ui.progressBadge.innerText = "Completado";
        document.getElementById('progress-fill').style.width = `100%`;

        const correctas = data.score;
        const incorrectas = data.total_preguntas - data.score;

        document.getElementById('results-data').innerHTML = `
            <h1 style="font-size: 3.5rem; color: var(--secondary); margin-bottom: 0.5rem;">${data.porcentaje}%</h1>
            <p style="font-size: 1.1rem; color: #64748b;">Eficiencia de resolución</p>
            
            <div class="metrics-grid">
                <div class="metric-box">
                    <div class="metric-value" style="color: #166534;">${correctas}</div>
                    <div style="font-size: 0.9rem; color: #64748b; font-weight: 500;">Aciertos</div>
                </div>
                <div class="metric-box">
                    <div class="metric-value" style="color: #991b1b;">${incorrectas}</div>
                    <div style="font-size: 0.9rem; color: #64748b; font-weight: 500;">Errores</div>
                </div>
            </div>

            <div class="feedback-panel correct" style="display:block; text-align:left; border-left: 5px solid #166534;">
                <strong>Dictamen del Agente Inteligente:</strong><br><br>
                ${data.comentario_desempeno}
            </div>
        `;

        document.getElementById('download-pdf').onclick = () => {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF();

            doc.setFont("helvetica", "bold");
            doc.setFontSize(20);
            doc.text("Reporte de Evaluación Inteligente", 20, 30);
            
            doc.setFontSize(12);
            doc.setFont("helvetica", "normal");
            doc.text(`Fecha: ${new Date().toLocaleDateString()}`, 20, 40);
            doc.line(20, 45, 190, 45);

            doc.setFont("helvetica", "bold");
            doc.text("Resumen de Desempeño:", 20, 60);
            doc.setFont("helvetica", "normal");
            doc.text(`- Puntaje Final: ${data.porcentaje}%`, 25, 70);
            doc.text(`- Total evaluadas: ${data.total_preguntas}`, 25, 80);
            doc.text(`- Aciertos: ${correctas}`, 25, 90);
            doc.text(`- Errores: ${incorrectas}`, 25, 100);

            // Inyección de métricas por materia
            doc.setFont("helvetica", "bold");
            doc.text("Desglose Analítico por Materia:", 20, 120);
            doc.setFont("helvetica", "normal");
            
            let yPosition = 130;
            for (const [tema, stats] of Object.entries(data.desglose)) {
                let totalTema = stats.correctas + stats.incorrectas;
                let porcentajeTema = totalTema > 0 ? Math.round((stats.correctas / totalTema) * 100) : 0;
                doc.text(`• ${tema}: ${porcentajeTema}% (${stats.correctas} aciertos, ${stats.incorrectas} errores)`, 25, yPosition);
                yPosition += 10;
            }

            doc.setFont("helvetica", "bold");
            doc.text("Dictamen del Agente Tutor:", 20, yPosition + 10);
            doc.setFont("helvetica", "italic");
            
            const splitText = doc.splitTextToSize(data.comentario_desempeno, 160);
            doc.text(splitText, 25, yPosition + 20);

            doc.save("Resultado_Evaluacion_Tutor.pdf");
        };
    }

    function resetUI() {
        ui.feedbackPanel.style.display = 'none';
        ui.nextBtn.style.display = 'none';
        ui.optionsGrid.innerHTML = '';
    }
});