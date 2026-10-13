# Dữ liệu mẫu đọc từ data/*.json, viết sẵn theo định dạng DynamoDB JSON ({"S": ...}, {"N": ...}, {"M": ...})
locals {
  music_items  = jsondecode(file("${path.module}/data/music.json"))
  movies_items = jsondecode(file("${path.module}/data/movies.json"))
}

resource "aws_dynamodb_table_item" "music" {
  # for và tạo key (Artist#SongTitle) value cho mỗi data item
  for_each = { for item in local.music_items : "${item.Artist.S}#${item.SongTitle.S}" => item }

  table_name = aws_dynamodb_table.music.name
  hash_key   = aws_dynamodb_table.music.hash_key
  range_key  = aws_dynamodb_table.music.range_key
  item       = jsonencode(each.value)
}

resource "aws_dynamodb_table_item" "movies" {
  for_each = { for item in local.movies_items : "${item.year.N}#${item.title.S}" => item }

  table_name = aws_dynamodb_table.movies.name
  hash_key   = aws_dynamodb_table.movies.hash_key
  range_key  = aws_dynamodb_table.movies.range_key
  item       = jsonencode(each.value)
}
