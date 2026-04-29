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
        ui.topicTitle.innerText = data.tema;
        ui.progressBadge.innerText = data.progreso;
        
        // Paso 1: Lógica de la barra de progreso
        const progressParts = data.progreso.split('/');
        const currentQ = parseInt(progressParts[0]);
        const totalQ = parseInt(progressParts[1]) || 30;
        document.getElementById('progress-fill').style.width = `${(currentQ / totalQ) * 100}%`;
        
        ui.diffBadge.innerText = `Nivel: ${data.dificultad.toUpperCase()}`;
        ui.diffBadge.className = `diff-badge diff-${data.dificultad}`;
        ui.diffBadge.classList.remove('hidden');

        ui.contextBox.innerText = data.contexto;
        ui.questionText.innerText = data.pregunta;

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
        
        // Paso 3: Feedback visual de procesamiento
        btnSelected.classList.add('processing');
        btnSelected.innerText = 'Evaluando...';

        fetch('/api/answer', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ respuesta: respuesta })
        })
        .then(res => res.json())
        .then(data => {
            // Restaurar estado del botón
            btnSelected.classList.remove('processing');
            btnSelected.innerText = respuesta;
            btnSelected.classList.add(data.correcta ? 'selected-correct' : 'selected-error');
            
            ui.feedbackPanel.className = `feedback-panel ${data.correcta ? 'correct' : 'error'}`;
            ui.feedbackPanel.innerHTML = `
                <strong>${data.correcta ? '✅ Respuesta Correcta' : '❌ Respuesta Incorrecta'}</strong><br><br>
                ${data.feedback}
            `;
            ui.feedbackPanel.style.display = 'block';

            ui.nextBtn.style.display = 'block';
            ui.nextBtn.onclick = fetchNextQuestion;
        });
    }

    function renderResults(data) {
        ui.mainContent.classList.add('hidden');
        ui.resultsContent.classList.remove('hidden');
        ui.topicTitle.innerText = "Diagnóstico Final del Agente";
        ui.progressBadge.innerText = "Completado";
        document.getElementById('progress-fill').style.width = `100%`;

        // Paso 2: Cálculo de métricas
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

        // PDF Update (incluye las métricas)
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

            doc.setFont("helvetica", "bold");
            doc.text("Dictamen del Agente Tutor:", 20, 120);
            
            doc.setFont("helvetica", "italic");
            const splitText = doc.splitTextToSize(data.comentario_desempeno, 160);
            doc.text(splitText, 25, 130);

            doc.save("Resultado_Evaluacion_Tutor.pdf");
        };
    }

    function resetUI() {
        ui.feedbackPanel.style.display = 'none';
        ui.nextBtn.style.display = 'none';
        ui.optionsGrid.innerHTML = '';
    }
});