# Kittygram — DevOps Pet Project

Социальная сеть для владельцев кошек. Проект использовался как полигон для отработки DevOps-компетенций: контейнеризация, CI/CD, IaC и облачная инфраструктура.

## Стек технологий

**Приложение**
- Backend: Django (Python 3.10)
- Frontend: React
- База данных: PostgreSQL 13
- Reverse proxy: Nginx

**Инфраструктура и DevOps**
- Docker / Docker Compose
- GitHub Actions
- Terraform
- Yandex Cloud (Compute, VPC, Object Storage)

---

## Что реализовано

### Контейнеризация
Приложение разбито на 4 сервиса и оркестрируется через Docker Compose:
- `db` — PostgreSQL
- `backend` — Django REST API
- `frontend` — React (собирает статику и завершает работу)
- `gateway` — Nginx, раздаёт статику и проксирует запросы к backend

Образы публикуются на Docker Hub: `gabella187/kittygram_*`

### CI/CD — GitHub Actions ([main.yaml](.github/workflows/main.yaml))

Пайплайн запускается при каждом пуше в `main` и проходит 5 этапов:

```
push → tests → build & push images → deploy → auto tests → telegram notify
```

1. **tests** — линтинг flake8 + pytest
2. **build_and_push** — сборка и публикация трёх Docker-образов на DockerHub
3. **deploy** — деплой на ВМ по SSH: копирование docker-compose, генерация `.env`, `docker compose up`, миграции, collectstatic
4. **auto_tests** — проверка доступности задеплоенного приложения
5. **send_message** — уведомление в Telegram об успешном деплое

### Infrastructure as Code — Terraform ([terraform/](.github/workflows/terraform.yaml))

Инфраструктура в Yandex Cloud полностью описана кодом:
- ВМ: 2 vCPU, 2 GB RAM, Ubuntu 24.04, cloud-init provisioning
- VPC, подсеть, группы безопасности
- Terraform state хранится в Yandex Cloud Object Storage (S3-совместимый backend)

Управление инфраструктурой вынесено в отдельный воркфлоу ([terraform.yaml](.github/workflows/terraform.yaml)) с ручным запуском и выбором действия: `plan / apply / destroy`.

После `apply` воркфлоу автоматически обновляет секрет `HOST` в репозитории новым IP-адресом ВМ.

### Безопасность и секреты
- Долгоживущие секреты (cloud_id, folder_id, SSH-ключи, токены БД) хранятся в GitHub Secrets
- IAM-токен для Terraform генерируется на лету через **OIDC-федерацию** с Yandex Cloud — долгоживущий токен нигде не хранится

---

## Схема пайплайна

```
GitHub push
    │
    ├─► flake8 + pytest
    │
    ├─► Docker build → DockerHub
    │       backend / frontend / gateway
    │
    ├─► SSH deploy на Yandex Cloud VM
    │       docker compose pull → up → migrate → collectstatic
    │
    ├─► Auto tests (connection + dockerhub)
    │
    └─► Telegram notification
```

---

## Локальный запуск

```bash
# Создать .env по примеру ниже
cp .env.example .env

docker compose -f docker-compose.production.yml up -d
```

Минимальный `.env`:
```
POSTGRES_DB=kittygram
POSTGRES_USER=kittygram
POSTGRES_PASSWORD=password
DB_HOST=db
DB_PORT=5432
SECRET_KEY=your-django-secret-key
```

Приложение будет доступно на `http://localhost:8000`.
