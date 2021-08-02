# Start from the latest golang base image
FROM golang:alpine as builder

ARG version

# Add Maintainer Info
LABEL maintainer="Alec Scott <alecbcs@github.com>"

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source from the current directory to the Working Directory inside the container
COPY . .

# Install required packages for building Binoc.
RUN apk add --no-cache \
    gcc \
    build-base \ 
    binutils \
    musl-dev \
    binutils-gold \
    musl-dev \
    linux-headers

# Build the Go app
RUN go build -ldflags "-s -w -X github.com/autamus/binoc/config.Version=$version" -o binoc .

# Start again with minimal envoirnment.
FROM alpine

RUN apk add --no-cache git

# Set the Current Working Directory inside the container
WORKDIR /app

COPY --from=builder /app/binoc /app/binoc

# Command to run the executable
ENTRYPOINT ["/app/binoc"]