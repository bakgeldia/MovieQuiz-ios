//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Bakgeldi Alkhabay on 31.01.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
