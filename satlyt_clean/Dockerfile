FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY server.js ./
RUN mkdir -p /app/results /app/errors
RUN echo "dummy result 1" > /app/results/test_file_1.txt
RUN echo "dummy result 2" > /app/results/test_file_2.txt
RUN echo "error log 1" > /app/errors/error_1.txt
EXPOSE 3000
CMD ["node", "server.js"]