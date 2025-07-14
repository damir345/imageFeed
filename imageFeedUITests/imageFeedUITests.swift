//
//  imageFeedUITests.swift
//  imageFeedUITests
//
//  Created by Damir Salakhetdinov on 8/07/25.
//

import XCTest

class imageFeedUITests: XCTestCase {
    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        app.launchArguments.append("testMode")
        app.launch() // запускаем приложение перед каждым тестом
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        // Ввод email
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("email")
        
        // Снять фокус с логина, чтобы закрыть клавиатуру
        let dismissCoordinate = webView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        dismissCoordinate.tap()
        
        sleep(1)
        
        // Найти поле пароля
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        // Прокрутка до видимости
        while !passwordTextField.isHittable {
            webView.swipeUp()
        }
        
        // Тап по координате для надёжного фокуса
        let passwordCoordinate = passwordTextField.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        passwordCoordinate.tap()
        
        // Проверка появления клавиатуры
        XCTAssertTrue(app.keyboards.element.waitForExistence(timeout: 3), "Клавиатура не появилась")
        
        // Ввод пароля
        passwordTextField.typeText("Password")
        
        // Скроллим до кнопки Login и тапаем
        webView.swipeUp()
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()
        
        // Проверяем успешную авторизацию — появление ячейки
        let cell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables

        tablesQuery.firstMatch.swipeUp()

        let cellToLike = tablesQuery.cells.element(boundBy: 1)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5), "Ячейка не появилась")

        // Лайк / анлайк
        let likeButton = cellToLike.buttons["LikeButton"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 2), "Кнопка Like не появилась")
        likeButton.tap()
        likeButton.tap()

        // Открываем изображение в полный экран
        cellToLike.tap()
        sleep(2)

        // Ожидаем появления изображения
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 10), "Изображение не загрузилось")

        // Зум
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)

        // Ожидаем появления кнопки "Назад"
        let backButton = app.buttons["NavBackButtonWhite"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Кнопка 'Назад' не появилась")
        backButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
       
        XCTAssertTrue(app.staticTexts["Name Surname"].exists)
        XCTAssertTrue(app.staticTexts["Username"].exists)
        
        app.buttons["logoutButton"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        
        let loginButton = app.buttons["Войти"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
    }
}
