//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Bakgeldi Alkhabay on 26.03.2024.
//

import UIKit

final class MovieQuizPresenter {
    
    weak var viewController: MovieQuizViewController?
    
    var currentQuestion: QuizQuestion?
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        let newModel = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return newModel
    }
    
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = true
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = false
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
}
