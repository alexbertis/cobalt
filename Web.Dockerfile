FROM node:24-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

FROM base AS build
WORKDIR /app
COPY . /app

RUN corepack enable
RUN apk add --no-cache python3 alpine-sdk

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --frozen-lockfile 

ARG WEB_HOST=http://localhost:9001
ARG WEB_DEFAULT_API=http://localhost:9000
ENV WEB_HOST=${WEB_HOST}
ENV WEB_DEFAULT_API=${WEB_DEFAULT_API}

RUN pnpm -C web run build

FROM nginx:alpine AS nginx

COPY ./web/nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/web/build /srv

EXPOSE 80
