FROM python:3.9

WORKDIR /backend

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY . .

CMD ["gunicorn", "-w", "16", "-b", "0.0.0.0:5000", "FlaskServer.FlaskServer_main:app"]