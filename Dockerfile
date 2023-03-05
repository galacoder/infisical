FROM node:14-alpine as builder

WORKDIR /app

COPY ./frontend ./
RUN npm install && npm run build

WORKDIR /app/backend

COPY ./backend/package*.json ./
RUN npm install --production

COPY ./backend ./

# Build the backend server
RUN npm run build

# --- Production image ---
FROM node:14-alpine

WORKDIR /app

COPY --from=builder /app/frontend/public /app/frontend/public

COPY --from=builder /app/backend/dist /app/backend/dist
COPY --from=builder /app/backend/package*.json /app/backend/
COPY --from=builder /app/backend/server.js /app/backend/

RUN npm install --only=production --prefix /app/backend

# Expose ports and start the app
EXPOSE 80
EXPOSE 443

CMD [ "npm", "start", "--prefix", "/app/backend" ]

# Set environment variables
ARG MONGO_USERNAME
ARG MONGO_PASSWORD
ARG TELEMETRY_ENABLED
ARG STRIPE_PRODUCT_PRO
ARG STRIPE_PRODUCT_TEAM
ARG STRIPE_PRODUCT_STARTER

ENV MONGO_USERNAME=$MONGO_USERNAME
ENV MONGO_PASSWORD=$MONGO_PASSWORD
ENV INFISICAL_TELEMETRY_ENABLED=$TELEMETRY_ENABLED
ENV NEXT_PUBLIC_STRIPE_PRODUCT_PRO=$STRIPE_PRODUCT_PRO
ENV NEXT_PUBLIC_STRIPE_PRODUCT_TEAM=$STRIPE_PRODUCT_TEAM
ENV NEXT_PUBLIC_STRIPE_PRODUCT_STARTER=$STRIPE_PRODUCT_STARTER
