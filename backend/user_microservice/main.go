package main

import (
	"github.com/gorilla/mux"
	"log"
	"net/http"
	"user_microservice/routes"
)

func main() {
	router := mux.NewRouter()

	// Rutas de usuario
	routes.UserRoute(router)

	log.Fatal(http.ListenAndServe(":8081", router))
}
