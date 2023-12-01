package controllers

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/go-playground/validator/v10"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"message_microservice/configs"
	"message_microservice/models"
	"message_microservice/responses"
	"net/http"
	"time"
)

var messageCollection = configs.GetCollection(configs.DB, "messages")
var validateMessage = validator.New()

func CreateMessage() http.HandlerFunc {
	return func(writer http.ResponseWriter, request *http.Request) {
		writer.Header().Set("Content-Type", "application/json; charset=utf-8")

		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		var message models.Message

		// Validar que el body esté en formato JSON
		if err := json.NewDecoder(request.Body).Decode(&message); err != nil {
			writer.WriteHeader(http.StatusBadRequest)
			response := responses.MessageResponse{
				Status:  http.StatusBadRequest,
				Message: "Formato del contenido de la solicitud no válido",
				Data:    err.Error(),
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Se usa librería para validar los campos del body
		if validationErr := validateMessage.Struct(&message); validationErr != nil {
			writer.WriteHeader(http.StatusBadRequest)
			response := responses.MessageResponse{
				Status:  http.StatusBadRequest,
				Message: "Campos del contenido de la solicitud no válidos",
				Data:    validationErr.Error(),
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Crear modelo de mensaje con sus campos completos
		newMessage := models.Message{
			Id: primitive.NewObjectID(),
			Author: models.Author{
				Id:        message.Author.Id,
				FirstName: message.Author.FirstName,
				Email:     message.Author.Email,
			},
			CreatedAt:     message.CreatedAt,
			Status:        message.Status,
			Text:          message.Text,
			DecryptedText: message.DecryptedText,
			Type:          message.Type,
			To:            message.To,
		}
		result, err := messageCollection.InsertOne(ctx, newMessage)
		if err != nil {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.MessageResponse{
				Status:  http.StatusInternalServerError,
				Message: "Error al crear el nuevo mensaje",
				Data:    err.Error(),
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		writer.WriteHeader(http.StatusCreated)
		response := responses.MessageResponse{
			Status:  http.StatusCreated,
			Message: "Mensaje creado con éxito",
			Data:    map[string]interface{}{"data": result},
		}
		_ = json.NewEncoder(writer).Encode(response)
		fmt.Printf("Mensaje de %s a %s creado con éxito\n", message.Author.Email, message.To)
	}
}

func GetMessages() http.HandlerFunc {
	return func(writer http.ResponseWriter, request *http.Request) {
		writer.Header().Set("Content-Type", "application/json; charset=utf-8")

		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		userFromEmail := request.URL.Query().Get("userFrom")
		userToEmail := request.URL.Query().Get("userTo")

		var messages []models.Message
		results, err := messageCollection.Find(ctx, bson.M{
			"$and": bson.A{
				bson.M{
					"$or": bson.A{
						bson.M{"author.email": userFromEmail},
						bson.M{"author.email": userToEmail},
					},
				},
				bson.M{
					"$or": bson.A{
						bson.M{"to": userFromEmail},
						bson.M{"to": userToEmail},
					},
				},
			},
		})

		if err != nil {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.MessageResponse{
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
			var singleMessage models.Message
			if err := results.Decode(&singleMessage); err != nil {
				writer.WriteHeader(http.StatusInternalServerError)
				response := responses.MessageResponse{
					Status:  http.StatusInternalServerError,
					Message: "Resultados no contienen la estructura de mensaje",
					Data:    map[string]interface{}{"data": err.Error()},
				}
				_ = json.NewEncoder(writer).Encode(response)
			}

			// Se retornan todos los valores, dependiendo si es el autor del mensaje
			// se retorna el texto cifrado o sin descifrar
			if userFromEmail == singleMessage.Author.Email {
				// El usuario logeado es el autor del mensaje
				messages = append(messages, models.Message{
					Id: singleMessage.Id,
					Author: models.Author{
						Id:        singleMessage.Author.Id,
						FirstName: singleMessage.Author.FirstName,
						Email:     "",
					},
					CreatedAt:     singleMessage.CreatedAt,
					Status:        singleMessage.Status,
					Text:          singleMessage.Text,
					DecryptedText: singleMessage.DecryptedText,
					Type:          singleMessage.Type,
					To:            "",
				})
			} else {
				// El usuario logeado no es el autor del mensaje
				messages = append(messages, models.Message{
					Id: singleMessage.Id,
					Author: models.Author{
						Id:        singleMessage.Author.Id,
						FirstName: singleMessage.Author.FirstName,
						Email:     "",
					},
					CreatedAt:     singleMessage.CreatedAt,
					Status:        singleMessage.Status,
					Text:          singleMessage.Text,
					DecryptedText: "",
					Type:          singleMessage.Type,
					To:            "",
				})
			}
		}

		writer.WriteHeader(http.StatusOK)
		response := responses.MessageResponse{
			Status:  http.StatusOK,
			Message: "Mensajes obtenidos con éxito",
			Data:    map[string]interface{}{"data": messages},
		}
		_ = json.NewEncoder(writer).Encode(response)
		fmt.Printf("Mensajes entre los usuarios %s y %s obtenidos con éxito\n", userFromEmail, userToEmail)
	}
}
