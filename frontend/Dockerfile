# ==================================================
# Stage 1: Build Flutter Web
# ==================================================
FROM ghcr.io/gmeligio/flutter-web:3.47.4 AS build

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./

RUN flutter pub get

COPY lib ./lib
COPY web ./web

RUN flutter build web --release

# ==================================================
# Stage 2: Serve with Nginx
# ==================================================
FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]