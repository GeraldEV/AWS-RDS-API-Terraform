FROM python:3

WORKDIR /app
RUN mkdir /app/templates
RUN mkdir /app/static

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .
COPY static/* static/
COPY templates/* templates/

ENTRYPOINT ["python"]
CMD ["app.py"]

