FROM alpine:edge

RUN apk update

# Installs latest Chromium (97) package.
RUN apk add --no-cache \
      chromium=97.0.4692.99-r0 \
      nss \
      freetype \
      harfbuzz \
      ca-certificates \
      ttf-freefont \
      nodejs \
      yarn

RUN apk upgrade

WORKDIR /home/pptruser

COPY yarn.lock /home/pptruser

COPY package.json /home/pptruser

RUN yarn

COPY main.js /home/pptruser

# Tell Puppeteer to skip installing Chrome. We'll be using the installed package.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Puppeteer v12.0.0 works with Chromium 97.
RUN yarn add puppeteer@12.0.0

# Add user so we don't need --no-sandbox.
RUN addgroup -S pptruser && adduser -S -g pptruser pptruser \
    && mkdir -p /home/pptruser/Downloads /app \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /app

# Run everything after as non-privileged user.
USER pptruser

CMD ["node", "main.js"]
