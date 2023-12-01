package controllers

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/go-playground/validator/v10"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"net/http"
	"time"
	"user_microservice/configs"
	"user_microservice/models"
	"user_microservice/responses"
)

var userCollection = configs.GetCollection(configs.DB, "users")
var validateUser = validator.New()

func GetCredentialsLogin() http.HandlerFunc {
	return func(writer http.ResponseWriter, request *http.Request) {
		writer.Header().Set("Content-Type", "application/json; charset=utf-8")

		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		// Validar que el body está en formato JSON
		var user models.User
		if err := json.NewDecoder(request.Body).Decode(&user); err != nil {
			writer.WriteHeader(http.StatusBadRequest)
			response := responses.UserResponse{
				Status:  http.StatusBadRequest,
				Message: "Formato del contenido de la solicitud no válido",
				Data:    err.Error(),
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Se usa la librería para validar los campos del body
		if validationErr := validateUser.Struct(&user); validationErr != nil {
			writer.WriteHeader(http.StatusBadRequest)
			response := responses.UserResponse{
				Status:  http.StatusBadRequest,
				Message: "Campos del contenido de la solicitud no válidos",
				Data:    validationErr.Error(),
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Verificar que el usuario exista en la base de datos
		var tempUser models.User
		err := userCollection.FindOne(ctx, bson.M{"email": user.Email}).Decode(&tempUser)
		if err != nil {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.UserResponse{
				Status:  http.StatusInternalServerError,
				Message: "Usuario no registrado",
				Data:    nil,
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Verificar que la contraseña sea correcta
		if tempUser.Password != user.Password {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.UserResponse{
				Status:  http.StatusInternalServerError,
				Message: "Contraseña incorrecta",
				Data:    nil,
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Extraer datos del usuario de la base de datos
		var dbUser models.User
		_ = userCollection.FindOne(ctx, bson.M{"email": user.Email}).Decode(&dbUser)

		// Se retorna los campos del usuario autenticado
		writer.WriteHeader(http.StatusOK)
		response := responses.UserResponse{
			Status:  http.StatusOK,
			Message: "Credenciales de login obtenidas correctamente",
			Data:    dbUser,
		}
		_ = json.NewEncoder(writer).Encode(response)
		fmt.Printf("Credenciales de login del usuario %s obtenidas correctamente\n", user.Email)
	}
}

func SaveCredentialsRegister() http.HandlerFunc {
	return func(writer http.ResponseWriter, request *http.Request) {
		writer.Header().Set("Content-Type", "application/json; charset=utf-8")

		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		// Validar que el body está en formato JSON
		var user models.User
		if err := json.NewDecoder(request.Body).Decode(&user); err != nil {
			writer.WriteHeader(http.StatusBadRequest)
			response := responses.UserResponse{
				Status:  http.StatusBadRequest,
				Message: "Formato del contenido de la solicitud no válido",
				Data:    map[string]interface{}{"data": err.Error()},
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Se usa librería para validar los campos del body
		if validationErr := validateUser.Struct(&user); validationErr != nil {
			writer.WriteHeader(http.StatusBadRequest)
			response := responses.UserResponse{
				Status:  http.StatusBadRequest,
				Message: "Campos del contenido de la solicitud no válidos",
				Data:    map[string]interface{}{"data": validationErr.Error()},
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Verificar que el usuario no esté ya registrado en la base de datos
		var tempUser models.User
		err := userCollection.FindOne(ctx, bson.M{"email": user.Email}).Decode(&tempUser)
		if err == nil {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.UserResponse{
				Status:  http.StatusInternalServerError,
				Message: "Usuario ya existente",
				Data:    map[string]interface{}{"data": "Usuario ya existente"},
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Crear modelo de usuario con sus campos completos
		newUser := models.User{
			Id:         user.Id,
			Name:       user.Name,
			Email:      user.Email,
			Password:   user.Password,
			PublicKey:  user.PublicKey,
			PrivateKey: user.PrivateKey,
		}

		_, err = userCollection.InsertOne(ctx, newUser)
		if err != nil {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.UserResponse{
				Status:  http.StatusInternalServerError,
				Message: "Error al registrar el nuevo usuario",
				Data:    map[string]interface{}{"data": err.Error()},
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		writer.WriteHeader(http.StatusCreated)
		response := responses.UserResponse{
			Status:  http.StatusCreated,
			Message: "Usuario registrado con éxito",
			Data:    map[string]interface{}{"InsertedID": user.Id},
		}
		_ = json.NewEncoder(writer).Encode(response)
		fmt.Printf("Credenciales de registro del usuario %s obtenidas correctamente\n", user.Email)
	}
}

func GetAllChats() http.HandlerFunc {
	return func(writer http.ResponseWriter, request *http.Request) {
		writer.Header().Set("Content-Type", "application/json; charset=utf-8")

		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		userEmail := request.URL.Query().Get("email")

		var chats []models.User
		results, err := userCollection.Find(ctx, bson.M{"email": bson.M{"$nin": bson.A{userEmail}}})

		if err != nil {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.UserResponse{
				Status:  http.StatusInternalServerError,
				Message: "Error de conexión con la base de datos",
				Data:    map[string]interface{}{"data": err.Error()},
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Lectura de manera óptima de la BD
		defer func(results *mongo.Cursor, ctx context.Context) {
			_ = results.Close(ctx)
		}(results, ctx)

		for results.Next(ctx) {
			var singleUser models.User
			if err := results.Decode(&singleUser); err != nil {
				writer.WriteHeader(http.StatusInternalServerError)
				response := responses.UserResponse{
					Status:  http.StatusInternalServerError,
					Message: "Resultados no tienen la estructura de usuario",
					Data:    map[string]interface{}{"data": err.Error()},
				}
				_ = json.NewEncoder(writer).Encode(response)
			}

			// Se retornan todos los valores, excepto la contraseña y la llave privada
			chats = append(chats, models.User{
				Id:         singleUser.Id,
				Name:       singleUser.Name,
				Email:      singleUser.Email,
				Password:   "",
				PublicKey:  singleUser.PublicKey,
				PrivateKey: "",
			})
		}

		writer.WriteHeader(http.StatusOK)
		response := responses.UserResponse{
			Status:  http.StatusOK,
			Message: "Chats obtenidos con éxito",
			Data:    map[string]interface{}{"data": chats},
		}
		_ = json.NewEncoder(writer).Encode(response)
		fmt.Printf("Chats para el usuario %s obtenidos con éxito\n", userEmail)
	}
}
