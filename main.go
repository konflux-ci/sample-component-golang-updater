package main

import (
	"fmt"
	"net/http"
	"os"

	"golang.org/x/text/language"
)

var port = os.Getenv("PORT")

var matcher = language.NewMatcher([]language.Tag{
	language.English,
	language.Spanish,
	language.French,
	language.German,
})

func main() {
	if port == "" {
		port = "8080"
	}

	fmt.Println("Starting server on port", port)
	http.HandleFunc("/", HelloServer)
	http.ListenAndServe(fmt.Sprintf("0.0.0.0:%s", port), nil)
}

func HelloServer(w http.ResponseWriter, r *http.Request) {
	accept := r.Header.Get("Accept-Language")
	tag, _ := language.MatchStrings(matcher, accept)
	fmt.Fprintf(w, "Hello World! (lang=%s)\n", tag)
}
