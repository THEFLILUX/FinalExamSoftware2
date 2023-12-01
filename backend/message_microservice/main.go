package main

import (
	"github.com/gorilla/mux"
	"log"
	"message_microservice/routes"
	"net/http"
)

func main() {
	router := mux.NewRouter()

	// Rutas de mensaje
	routes.MessageRoute(router)

	log.Fatal(http.ListenAndServe(":8082", router))
}
