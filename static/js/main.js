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
        
        ui.diffBadge.innerText = `Nivel: ${data.dificultad}`;
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

        fetch('/api/answer', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ respuesta: respuesta })
        })
        .then(res => res.json())
        .then(data => {
            btnSelected.classList.add(data.correcta ? 'selected-correct' : 'selected-error');
            ui.feedbackPanel.className = `feedback-panel ${data.correcta ? 'correct' : 'error'}`;
            ui.feedbackPanel.innerHTML = `
                <strong>${data.correcta ? 'Respuesta Correcta' : 'Respuesta Incorrecta'}</strong><br><br>
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

        ui.resultsContent.innerHTML = `
            <div style="text-align:center; padding: 2rem;">
                <h1 style="font-size: 3rem; color: var(--secondary); margin-bottom: 1rem;">${data.porcentaje}%</h1>
                <p style="font-size: 1.2rem; margin-bottom: 2rem;">Preguntas evaluadas: ${data.total_preguntas}</p>
                
                <div class="feedback-panel correct" style="display:block; text-align:left;">
                    <strong>Dictamen del Tutor Inteligente:</strong><br><br>
                    ${data.comentario_desempeno}
                </div>
            </div>
        `;
    }

    function resetUI() {
        ui.feedbackPanel.style.display = 'none';
        ui.nextBtn.style.display = 'none';
        ui.optionsGrid.innerHTML = '';
    }
});