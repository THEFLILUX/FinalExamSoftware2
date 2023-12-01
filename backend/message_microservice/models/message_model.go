package models

import (
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Message struct {
	Id            primitive.ObjectID `json:"id,omitempty"`
	Author        Author             `json:"author" validate:"required"`
	CreatedAt     int                `json:"createdAt" validate:"required"`
	Status        string             `json:"status" validate:"required"`
	Text          string             `json:"text" validate:"required"`
	DecryptedText string             `json:"decryptedText" validate:"required"`
	Type          string             `json:"type" validate:"required"`
	To            string             `json:"to" validate:"required"`
}
