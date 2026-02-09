FROM python:3.10-slim

ENV PYTHONUNBUFFERED=1

WORKDIR /code

RUN pip install --upgrade pip setuptools wheel

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0:8000"]

