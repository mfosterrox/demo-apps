FROM node:16-bullseye

WORKDIR /app
RUN chown node /app

COPY . .
RUN chmod u+s ./lookatme
RUN chmod g+s ./lookatme
RUN mv ./bot.code /root/bot.code

RUN npm install --no-audit

USER 1000
CMD npm start