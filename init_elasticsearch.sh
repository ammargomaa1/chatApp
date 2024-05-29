# Wait until Elasticsearch is up
until curl -s "http://elasticsearch:9200/_cluster/health?wait_for_status=yellow&timeout=50s"; do
  echo "Waiting for Elasticsearch to be up..."
  sleep 1
done

# Create the index with custom analyzer
curl -X PUT "http://elasticsearch:9200/messages" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "analysis": {
      "tokenizer": {
        "ngram_tokenizer": {
          "type": "ngram",
          "min_gram": 3,
          "max_gram": 4,
          "token_chars": ["letter", "digit"]
        }
      },
      "analyzer": {
        "ngram_analyzer": {
          "type": "custom",
          "tokenizer": "ngram_tokenizer",
          "filter": ["lowercase"]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "body": {
        "type": "text",
        "analyzer": "ngram_analyzer",
        "fields": {
          "keyword": {
            "type": "keyword"
          }
        }
      },
      "id": {
        "type": "integer",
        "fields": {
          "keyword": {
            "type": "keyword"
          }
        }
      },
      "chat_id": {
        "type": "integer",
        "fields": {
          "keyword": {
            "type": "keyword"
          }
        }
      },
      "message_number": {
        "type": "integer",
        "fields": {
          "keyword": {
            "type": "keyword"
          }
        }
      }
    }
  }
}

'

echo "Elasticsearch index 'messages' created with custom analyzer."