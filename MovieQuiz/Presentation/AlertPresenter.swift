//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Bakgeldi Alkhabay on 31.01.2024.
//

import Foundation
import UIKit

protocol AlertPresenter {
    func show(alertModel: AlertModel)
}

final class AlertPresenterImplementation {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
}

extension AlertPresenterImplementation: AlertPresenter {
    func show(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            alertModel.completion()
            
        }
        
        alert.addAction(action)
        
        viewController?.present(alert, animated: true)
    }
}