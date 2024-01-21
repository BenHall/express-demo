# Ability to override to ensure it matches .nvmrc
ARG NODE=20.11.0
FROM node:${NODE}

WORKDIR /usr/src/app

# Install Webpack + dependencies for compiling
ENV ADBLOCK=1
COPY package*.json ./
RUN npm ci

COPY . .

# Rebuild Webpack
## Will this cause it to generate the same hash each build even if it's a different container?
RUN npm run build 

FROM node:${NODE}

# Create app directory and define defaults
WORKDIR /usr/src/app
EXPOSE 3000
CMD [ "./bin/www" ]
ENV ADBLOCK=1

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

# If you are building your code for production
RUN npm ci --production

# Bundle app source
COPY --from=0 /usr/src/app/public public
COPY --from=0 /usr/src/app/webpack.version.json .
COPY . .
