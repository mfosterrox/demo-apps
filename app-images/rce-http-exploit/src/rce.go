package main

import (
    "log"
    "net/http"
    "strings"
    "runtime"
    "os/exec"
)

type RCE struct {
    Command string `json:"command"`
    Arguments string `json:"args"`
}

func homeHandler(w http.ResponseWriter, r *http.Request) {

    switch r.Method { 
        case http.MethodGet:
            // make sure that a command and argument are supplied
            command, ok := r.URL.Query()["command"]
            if !ok || len(command) < 1 {
                http.Error(w, "required argument is missing: command", 400)
                log.Println("required argument is missing: command")
                return
            }
            args, ok := r.URL.Query()["args"]
            if !ok || len(args) < 1 {
                http.Error(w, "required argument is missing: args", 400)
                log.Println("required argument is missing: args")
                return
            }
            log.Println("received rce of: " + strings.Join(command, ",") + " with args: " + strings.Join(args, ","))

            // execute the command
            if runtime.GOOS == "linux" {
                process := exec.Command(strings.Join(command, " "), strings.Join(args, " "))
                e := process.Run()
                if e != nil {
                    log.Println(e)
                }
            }

            // write the response
            w.WriteHeader(200)
            w.Write([]byte(strings.Join(command, ",")))

            
        default:
            http.Error(w, "Invalid request method.", 405)
            return
    }

}


func pingHandler(w http.ResponseWriter, r *http.Request) {
    w.WriteHeader(200)
    status := "{\"status\": \"ok\"}"
    w.Write([]byte(status))
    log.Printf("Received request for ping")
}


func main() {
    log.Println("rce service handler registration...")
    http.HandleFunc("/", homeHandler)
    http.HandleFunc("/ping", pingHandler)
    log.Println("rce service listener...")
    http.ListenAndServe(":8080", nil)
}
