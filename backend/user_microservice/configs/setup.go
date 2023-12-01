package configs

import (
	"context"
	"fmt"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"log"
	"time"
)

func ConnectDB() *mongo.Client {
	client, err := mongo.NewClient(options.Client().ApplyURI(EnvMongoURI()))
	if err != nil {
		log.Fatal(err)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	err = client.Connect(ctx)
	if err != nil {
		log.Fatal(err)
	}

	// Hacer un ping a la BD
	err = client.Ping(ctx, nil)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Conectado a Base de Datos EIM de MongoDB")
	return client
}

// DB Instancia de Cliente
var DB = ConnectDB()

// GetCollection Obtener una colleción de la BD
func GetCollection(client *mongo.Client, collectionName string) *mongo.Collection {
	collection := client.Database("EIM").Collection(collectionName)
	return collection
}
