package main

import (
	"encoding/json"
	"html/template"
	"log"
	"net/http"
	"os"
	"time"
)

type GuestbookEntry struct {
	ID      int    `json:"id"`
	Author  string `json:"author"`
	Message string `json:"message"`
	Date    string `json:"date"`
}

var entries []GuestbookEntry
var nextID int = 1

const htmlTemplate = `
<!DOCTYPE html>
<html>
<head>
    <title>Guestbook</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        h1 {
            color: #333;
        }
        .entry {
            background-color: white;
            padding: 15px;
            margin: 10px 0;
            border-radius: 5px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .author {
            font-weight: bold;
            color: #0066cc;
        }
        .date {
            color: #666;
            font-size: 0.9em;
        }
        form {
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-top: 20px;
        }
        input, textarea {
            width: 100%;
            padding: 10px;
            margin: 5px 0;
            border: 1px solid #ddd;
            border-radius: 3px;
            box-sizing: border-box;
        }
        button {
            background-color: #0066cc;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 3px;
            cursor: pointer;
        }
        button:hover {
            background-color: #0052a3;
        }
    </style>
</head>
<body>
    <h1>Guestbook</h1>
    <div id="entries">
        {{range .}}
        <div class="entry">
            <div class="author">{{.Author}}</div>
            <div class="message">{{.Message}}</div>
            <div class="date">{{.Date}}</div>
        </div>
        {{end}}
    </div>
    <form method="POST" action="/sign">
        <h2>Sign the Guestbook</h2>
        <input type="text" name="author" placeholder="Your name" required>
        <textarea name="message" placeholder="Your message" rows="4" required></textarea>
        <button type="submit">Submit</button>
    </form>
</body>
</html>
`

func indexHandler(w http.ResponseWriter, r *http.Request) {
	tmpl := template.Must(template.New("index").Parse(htmlTemplate))
	tmpl.Execute(w, entries)
}

func signHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	author := r.FormValue("author")
	message := r.FormValue("message")

	if author == "" || message == "" {
		http.Error(w, "Author and message are required", http.StatusBadRequest)
		return
	}

	// Get current date
	date := time.Now().Format("2006-01-02 15:04:05")

	entry := GuestbookEntry{
		ID:      nextID,
		Author:  author,
		Message: message,
		Date:    date,
	}

	entries = append(entries, entry)
	nextID++

	http.Redirect(w, r, "/", http.StatusSeeOther)
}

func apiHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(entries)
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}

	http.HandleFunc("/", indexHandler)
	http.HandleFunc("/sign", signHandler)
	http.HandleFunc("/api/entries", apiHandler)

	log.Printf("Starting guestbook server on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

