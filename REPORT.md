## Part 1. Настройка gitlab-runner
- Скачать и установить на виртуальную машину gitlab-runner
```
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash

sudo apt-get install gitlab-runner
```

- Запустить gitlab-runner и зарегистрировать его для использования в текущем проекте (DO6_CICD)
```
sudo gitlab-runner register
```

## Part 2. Сборка
- Написать этап для CI по сборке приложений из проекта C2_SimpleBashUtils:
```
stages:
  - build

build:
  stage: build
  script:
    - cd src/cat
    - make
    - cd ../grep
    - make
  artifacts:
    paths:
      - src/artifacts/
    expire_in: 30 days
```