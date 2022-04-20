variable "stage" {
    description = "the stage of the current environment, such as dev, qa, staging, prod"
}

variable "namespace" {
    type = string
    default = "wordpress"
}