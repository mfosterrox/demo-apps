# Start by building the application.
FROM golang:1.19 as build

RUN mkdir /rce
WORKDIR /rce
COPY src/* /rce

ENV GOPROXY=direct
RUN go clean -modcache
RUN go mod init main
RUN go get -u -v -f all
#RUN go get -d -v ./...
#RUN go mod tidy
#RUN go install
RUN GOOS=linux GOARCH=amd64 go build rce.go
RUN GOBIN=/go/bin go install -v ./...
RUN ls -l /go/bin

# Now copy it into our base image.
FROM redhat/ubi8

RUN dnf -y update 

COPY --from=build /rce/rce /usr/bin

CMD [ "/usr/bin/rce" ]
