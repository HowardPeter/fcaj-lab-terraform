resource "aws_dynamodb_table" "music" {
  name           = "Music"
  billing_mode   = "PROVISIONED" # Tự cấu hình capacity đọc/ghi
  read_capacity  = 10
  write_capacity = 5
  table_class    = "STANDARD"

  hash_key  = "Artist" # Partition key
  range_key = "SongTitle" # Sort key

  attribute {
    name = "Artist"
    type = "S" # String
  }

  attribute {
    name = "SongTitle"
    type = "S"
  }

  attribute {
    name = "AlbumTitle"
    type = "S"
  }

  global_secondary_index {
    name            = "AlbumTitle-index"
    projection_type = "ALL" # Index chứa tất cả thuộc tính của item

    read_capacity  = 10
    write_capacity = 5

    # Định nghĩa Key Schema cho GSI
    key_schema {
      attribute_name = "AlbumTitle"
      key_type       = "HASH"       # HASH = Partition Key
    }
  }
}


resource "aws_dynamodb_table" "movies" {
  name           = "Movies"
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "year"
  range_key      = "title"

  attribute {
    name = "year"
    type = "N"
  }

  attribute {
    name = "title"
    type = "S"
  }
}
