
interface QuizQuestion {
  question_text: string;
  question_type: 'multiple_choice' | 'theory' | 'fill_in_the_blank' | 'true_false';
  difficulty: 'easy' | 'medium' | 'hard';
  correct_answer: string;
  options?: string[];
  points: number;
}

interface QuizPDFData {
  title: string;
  quizCode: string;
  topic: string;
  description: string;
  questions: QuizQuestion[];
  totalQuestions: number;
  duration: number;
}

export const generateQuizPDF = (data: QuizPDFData) => {
  // Create a new window for the PDF content
  const printWindow = window.open('', '_blank');
  
  if (!printWindow) {
    throw new Error('Unable to open print window. Please check popup blocker settings.');
  }

  // Generate HTML content for the PDF
  const htmlContent = `
    <!DOCTYPE html>
    <html>
    <head>
      <title>${data.title} - Quiz Questions</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          line-height: 1.6;
          color: #333;
          max-width: 800px;
          margin: 0 auto;
          padding: 20px;
        }
        
        .header {
          text-align: center;
          border-bottom: 2px solid #333;
          padding-bottom: 20px;
          margin-bottom: 30px;
        }
        
        .quiz-info {
          background-color: #f8f9fa;
          padding: 15px;
          border-radius: 5px;
          margin-bottom: 30px;
        }
        
        .quiz-info h2 {
          margin-top: 0;
          color: #2563eb;
        }
        
        .question {
          margin-bottom: 30px;
          page-break-inside: avoid;
        }
        
        .question-header {
          display: flex;
          align-items: center;
          margin-bottom: 10px;
          gap: 10px;
        }
        
        .question-number {
          background-color: #2563eb;
          color: white;
          padding: 5px 10px;
          border-radius: 3px;
          font-weight: bold;
        }
        
        .question-type {
          background-color: #e5e7eb;
          padding: 3px 8px;
          border-radius: 3px;
          font-size: 12px;
          text-transform: uppercase;
        }
        
        .difficulty {
          padding: 3px 8px;
          border-radius: 3px;
          font-size: 12px;
          font-weight: bold;
        }
        
        .difficulty.easy {
          background-color: #dcfce7;
          color: #166534;
        }
        
        .difficulty.medium {
          background-color: #fef3c7;
          color: #92400e;
        }
        
        .difficulty.hard {
          background-color: #fee2e2;
          color: #991b1b;
        }
        
        .points {
          background-color: #ddd6fe;
          color: #5b21b6;
          padding: 3px 8px;
          border-radius: 3px;
          font-size: 12px;
          font-weight: bold;
        }
        
        .question-text {
          font-size: 16px;
          font-weight: 500;
          margin-bottom: 15px;
          padding: 10px;
          background-color: #f9fafb;
          border-left: 4px solid #2563eb;
        }
        
        .options {
          margin-left: 20px;
        }
        
        .option {
          margin-bottom: 8px;
          padding: 5px;
        }
        
        .correct-answer {
          background-color: #dcfce7;
          border: 2px solid #16a34a;
          border-radius: 5px;
          padding: 10px;
          margin-top: 10px;
        }
        
        .correct-answer strong {
          color: #166534;
        }
        
        .page-break {
          page-break-before: always;
        }
        
        @media print {
          body {
            margin: 0;
            padding: 15px;
          }
          
          .no-print {
            display: none;
          }
        }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>${data.title}</h1>
        <p><strong>Quiz Code:</strong> ${data.quizCode}</p>
        <p><strong>Topic:</strong> ${data.topic}</p>
        ${data.description ? `<p><strong>Description:</strong> ${data.description}</p>` : ''}
      </div>
      
      <div class="quiz-info">
        <h2>Quiz Information</h2>
        <p><strong>Total Questions:</strong> ${data.totalQuestions}</p>
        <p><strong>Duration:</strong> ${data.duration} minutes</p>
        <p><strong>Generated on:</strong> ${new Date().toLocaleDateString()}</p>
      </div>
      
      <div class="questions">
        ${data.questions.map((question, index) => `
          <div class="question">
            <div class="question-header">
              <span class="question-number">Q${index + 1}</span>
              <span class="question-type">${question.question_type.replace('_', ' ')}</span>
              <span class="difficulty ${question.difficulty}">${question.difficulty}</span>
              <span class="points">${question.points} pts</span>
            </div>
            
            <div class="question-text">
              ${question.question_text}
            </div>
            
            ${question.options ? `
              <div class="options">
                <strong>Options:</strong>
                ${question.options.map((option, optIndex) => `
                  <div class="option">
                    ${String.fromCharCode(65 + optIndex)}. ${option}
                  </div>
                `).join('')}
              </div>
            ` : ''}
            
            <div class="correct-answer">
              <strong>Correct Answer:</strong> ${question.correct_answer}
            </div>
          </div>
          ${(index + 1) % 3 === 0 && index < data.questions.length - 1 ? '<div class="page-break"></div>' : ''}
        `).join('')}
      </div>
      
      <div class="no-print" style="text-align: center; margin-top: 30px;">
        <button onclick="window.print()" style="
          background-color: #2563eb;
          color: white;
          padding: 10px 20px;
          border: none;
          border-radius: 5px;
          cursor: pointer;
          font-size: 16px;
        ">Print / Save as PDF</button>
        <button onclick="window.close()" style="
          background-color: #6b7280;
          color: white;
          padding: 10px 20px;
          border: none;
          border-radius: 5px;
          cursor: pointer;
          font-size: 16px;
          margin-left: 10px;
        ">Close</button>
      </div>
    </body>
    </html>
  `;

  // Write content to the new window
  printWindow.document.write(htmlContent);
  printWindow.document.close();
  
  // Wait a moment for content to load, then trigger print dialog
  setTimeout(() => {
    printWindow.focus();
    printWindow.print();
  }, 500);
};
