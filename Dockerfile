
### STAGE 1: Build ###

# We label our stage as ‘builder’
FROM node:10-alpine as builder

COPY package.json yarn.lock ./

## Storing node modules on a separate layer will prevent unnecessary npm installs at each build

RUN yarn install && mkdir /undercover-front && mv ./node_modules ./undercover-front

WORKDIR /undercover-front

COPY . .

## Build the angular app in production mode and store the artifacts in dist folder

RUN yarn run ng build -- --prod --output-path=dist


### STAGE 2: Setup ###

FROM nginx:1.15.12-alpine

## Copy our default nginx config
COPY nginx/default.conf /etc/nginx/conf.d/

## Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

## From ‘builder’ stage copy over the artifacts in dist folder to default nginx public folder
COPY --from=builder /undercover-front/dist /usr/share/nginx/html

CMD ["nginx", "-g", "daemon off;"]

