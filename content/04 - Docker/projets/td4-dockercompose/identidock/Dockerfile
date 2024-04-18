FROM python:3.7

# RUN groupadd -r uwsgi && useradd -r -g uwsgi uwsgi
RUN pip3 install Flask uWSGI requests redis
# USER uwsgi
WORKDIR /app
COPY app/identidock.py /app/identidock.py
COPY boot.sh /boot.sh

EXPOSE 5000 9191
CMD ["/boot.sh"]
