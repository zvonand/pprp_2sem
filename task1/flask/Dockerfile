FROM python:3.10-alpine

COPY ./requirements.txt /app/requirements.txt

WORKDIR /app

RUN pip install -r requirements.txt

ADD src /app

EXPOSE 8080

ENTRYPOINT [ "python3" ]
CMD ["app.py"]