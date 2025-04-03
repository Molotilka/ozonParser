# Используем официальный образ с Python
FROM python:3.9-slim

# Устанавливаем необходимые зависимости для работы с Chrome
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    ca-certificates \
    fontconfig \
    libx11-dev \
    libxkbfile-dev \
    libgdk-pixbuf2.0-0 \
    libnspr4 \
    libnss3 \
    libxss1 \
    libgconf-2-4 \
    libasound2 \
    libxtst6 \
    libappindicator3-1 \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN dpkg -i google-chrome-stable_current_amd64.deb || apt-get -y --fix-broken install

# Устанавливаем ChromeDriver
RUN CHROME_DRIVER_VERSION=$(curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE) && \
    wget https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/chromedriver

# Устанавливаем Python зависимости
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем весь проект в контейнер
COPY . /app

# Устанавливаем рабочую директорию
WORKDIR /app

# Указываем переменную окружения для запуска Chrome в headless-режиме
ENV DISPLAY=:99

# Открываем нужный порт (если это необходимо для вашего приложения)
EXPOSE 5000

# Запускаем приложение
CMD ["python", "app.py"]
