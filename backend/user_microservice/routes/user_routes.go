package routes

import (
	"github.com/gorilla/mux"
	"user_microservice/controllers"
)

func UserRoute(router *mux.Router) {
	router.HandleFunc("/getCredentialsLogin", controllers.GetCredentialsLogin()).Methods("POST")
	router.HandleFunc("/saveCredentialsRegister", controllers.SaveCredentialsRegister()).Methods("POST")
	router.HandleFunc("/getAllChats", controllers.GetAllChats()).Methods("GET")
}
