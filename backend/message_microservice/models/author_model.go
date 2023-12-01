package models

type Author struct {
	Id        string `json:"id,omitempty"`
	FirstName string `json:"firstName" validate:"required"`
	Email     string `json:"email" validate:"required"`
}
