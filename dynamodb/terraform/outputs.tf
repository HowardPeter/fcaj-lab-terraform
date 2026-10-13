output "tables" {
  value = {
    music  = aws_dynamodb_table.music.arn
    movies = aws_dynamodb_table.movies.arn
  }
}

output "item_counts" {
  value = {
    music  = length(aws_dynamodb_table_item.music)
    movies = length(aws_dynamodb_table_item.movies)
  }
}
