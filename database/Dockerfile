FROM postgres:15.8
COPY init.sql /docker-entrypoint-initdb.d/
ENV POSTGRES_DB=app_db
ENV POSTGRES_USER=admin
ENV POSTGRES_PASSWORD=securepassword