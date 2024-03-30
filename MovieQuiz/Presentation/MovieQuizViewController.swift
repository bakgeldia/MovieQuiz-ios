import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenter?
    private var presenter: MovieQuizPresenter?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        
        imageView.layer.cornerRadius = 20
        alertPresenter = AlertPresenterImplementation(viewController: self)
        
        showLoadingIndicator()
    }
    
    // MARK: - Private functions
    func show(quiz step: QuizStepViewModel) {
        
        hideLoadingIndicator() //before next question is appeared, the loading indicator is hidden
        
        imageView.layer.borderWidth = 0
        yesButton.isEnabled = true
        noButton.isEnabled = true
        
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        showLoadingIndicator() //while next question is loading, the loading indicator is shown
    }
    
    func showFinalResult(quiz result: QuizResultsViewModel) {
        //Alert presenter
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                self?.presenter?.restartGame()
            }
        )
        
        alertPresenter?.show(alertModel: alertModel)
        
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        // создание и показ алерта
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                guard let self = self else { return }
                
                self.presenter?.restartGame()
            }
        )
        
        alertPresenter?.show(alertModel: alertModel)
        
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
    }
    
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
    }
    
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
