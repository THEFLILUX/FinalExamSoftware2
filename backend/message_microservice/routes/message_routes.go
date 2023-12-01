package routes

import (
	"github.com/gorilla/mux"
	"message_microservice/controllers"
)

func MessageRoute(router *mux.Router) {
	router.HandleFunc("/newMessage", controllers.CreateMessage()).Methods("POST")
	router.HandleFunc("/getMessages", controllers.GetMessages()).Methods("GET")
}
