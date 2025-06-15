# Спасибо за ответы!

#  Вопросы ревьюеру
## Привет, ревьюер, подскажи пожалуйста
## Вопрос №1

Подскажи, пожалуйста, почему в этом случае код работает

```
    func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        ProfileService.shared.fetchProfile(token) { /* [weak self] */ result in
            UIBlockingProgressHUD.dismiss()
            
            //guard let self = self else { return }
            
            switch result {
                case .success:
                    self.switchToTabBarController()
                    guard let username = ProfileService.shared.profile?.username else {
                        print("Failed to get username from user profile singletone")
                        return
                    }
                    self.fetchProfileImageURL(username)
                    
                case .failure:
                    print("Profile load error")
                    break
                }
        }
    }
```

а в этом:
```
    func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
                case .success:
                    self.switchToTabBarController()
                    guard let username = ProfileService.shared.profile?.username else {
                        print("Failed to get username from user profile singletone")
                        return
                    }
                    self.fetchProfileImageURL(username)
                    
                case .failure:
                    print("Profile load error")
                    break
                }
        }
    }
```

##Второй вопрос

Будет ли в этом курсе тема миграции кода, основанного на замыканиях в код с использованием Async/Await?
То есть, при разработке проекта с нуля сейчас рекомендуется использовать Async/Await

Например, как объясняется в статье:

Migrating Closure-Based Code to Async/Await in Swift Concurrency

https://wearecommunity.io/communities/mobilepeople/articles/6466


