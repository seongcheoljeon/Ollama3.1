FROM python:3.11 AS requirements-stage

WORKDIR /tmp
RUN pip install poetry
COPY ./pyproject.toml* ./poetry.lock* /tmp/

RUN poetry export -f requirements.txt --output requirements.txt


FROM python:3.11-slim
LABEL authors="Seongcheol Jeon"

COPY --from=requirements-stage /tmp/requirements.txt /code/requirements.txt

COPY ./wait-for-it.sh /code

WORKDIR /code

RUN chmod +x wait-for-it.sh

RUN apt-get update && apt-get install -y git curl vim build-essential

# llama 설치
RUN curl -fsSL https://ollama.com/install.sh | sh

RUN pip install --no-cache-dir -r requirements.txt

COPY ./src ./src

EXPOSE 8005

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8005", "--reload"]
