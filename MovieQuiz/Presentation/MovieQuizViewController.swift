import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var correctAnswers = 0
    
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    private let presenter = MovieQuizPresenter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        presenter.viewController = self
        
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenterImplementation(viewController: self)
        statisticService = StatisticServiceImplementation()
        
        showLoadingIndicator()
        questionFactory?.loadData()
        
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Private functions
    private func show(quiz step: QuizStepViewModel) {
        
        hideLoadingIndicator() //before next question is appeared, the loading indicator is hidden
        
        imageView.layer.borderWidth = 0
        yesButton.isEnabled = true
        noButton.isEnabled = true
        
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    //function that checks if the answer is true. If it is correct, then the border of the movie poster should be green, otherwise red.
    func showAnswerResult(isCorrect: Bool) {
        
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        showLoadingIndicator() //while next question is loading, the loading indicator is shown
    }
    
    //function to check if the quiz is finished. If so, send result into showFinalResult() function. Otherwise, increase currentQuestionIndex and send it to
    private func showNextQuestionOrResults() {
        guard let statisticService = statisticService,
              let bestGame = statisticService.bestGame else { return }
        
        let currentGameResult = "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)"
        let totalPlayedCounter = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let personalRecord = "Рекорд: \(bestGame.correct)/\(bestGame.total)" + "(\(bestGame.date.dateTimeString))"
        let avgAccuracy = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        if presenter.isLastQuestion() {
            
            let text = "\(currentGameResult)\n\(totalPlayedCounter)\n\(personalRecord)\n\(avgAccuracy)"
            
            let result = QuizResultsViewModel(title: "Этот раунд окончен", text: text, buttonText: "Сыграть еще раз")
            
            showFinalResult(quiz: result)
      } else {
          presenter.switchToNextQuestion()
          
          questionFactory?.requestNextQuestion()
      }
        
    }
    
    private func showFinalResult(quiz result: QuizResultsViewModel) {
        statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
        
        //Alert presenter
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                self?.presenter.resetQuestionIndex()
                self?.correctAnswers = 0
                
                self?.questionFactory?.requestNextQuestion()
            }
        )
        
        alertPresenter?.show(alertModel: alertModel)
        
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        // создайте и покажите алерт
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                guard let self = self else { return }
                
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                
                self.questionFactory?.requestNextQuestion()
            }
        )
        
        alertPresenter?.show(alertModel: alertModel)
        
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
        
    }
    
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
        
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
