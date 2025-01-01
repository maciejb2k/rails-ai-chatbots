module Chatbots
  module Clients
    class Flowise < BaseClient
      def initialize
        super(base_url: ENV["FLOWISE_URL"])
      end

      def get_document_stores
        response = connection.get "/api/v1/document-store/store" do |req|
          req.headers["Authorization"] = "Bearer #{ENV["FLOWISE_API_KEY"]}"
        end

        response.body
      end

      def get_document_store(document_store_id:)
        response = connection.get "/api/v1/document-store/store/#{document_store_id}" do |req|
          req.headers["Authorization"] = "Bearer #{ENV["FLOWISE_API_KEY"]}"
        end

        response.body
      end

      def create_document_store(url:, description:, token:)
        response = connection.post "/api/v1/document-store/store" do |req|
          req.headers["Authorization"] = "Bearer #{ENV["FLOWISE_API_KEY"]}"
          req.body = {
            "name": url,
            "description": description
          }.to_json
        end

        response.body
      end

      def create_api_loader(document_store_id:, url:, token:)
        response = connection.post "/api/v1/document-store/loader/process" do |req|
          req.headers["Authorization"] = "Bearer #{ENV["FLOWISE_API_KEY"]}"
          req.body = {
            "storeId": document_store_id,
            "loaderId": "apiLoader",
            "loaderName": "API Loader",
            "loaderConfig": {
              "url": "#{ENV["API_URL"]}/scraped_data?url=#{url}",
              "method": "GET",
              "headers": { "Authorization": "Bearer #{token}" }.to_json,
              "body": "",
              "metadata": "",
              "omitMetadataKeys": "",
              "textSplitter": ""
            },
            "splitterId": "recursiveCharacterTextSplitter",
            "splitterName": "Recursive Character Text Splitter",
            "splitterConfig": {
              "chunkOverlap": 200,
              "chunkSize": 1000,
              "separators": ""
            }
          }.to_json
        end

        response.body
      end

      def process_all_loaders(document_store_id:)
        response = get_document_store(document_store_id:)

        response["loaders"].each do |loader|
          process_loader(document_store_id:, loader_id: loader["id"])
        end
      end

      def process_loader(document_store_id:, loader_id:)
        response = connection.post "/api/v1/document-store/loader/process" do |req|
          req.headers["Authorization"] = "Bearer #{ENV["FLOWISE_API_KEY"]}"
          req.body = {
            "id": loader_id,
            "storeId": document_store_id
          }.to_json
        end

        response.body
      end

      def insert_configuration(document_store_id:, url:, openai_credentials_id:, postgres_credentials_id:)
        response = connection.post "/api/v1/document-store/vectorstore/save" do |req|
          req.headers["Authorization"] = "Bearer #{ENV["FLOWISE_API_KEY"]}"
          req.body = get_upsert_configuration_body(
            document_store_id: document_store_id,
            url: url,
            openai_credentials_id: openai_credentials_id,
            postgres_credentials_id: postgres_credentials_id
          )
        end

        response.body
      end

      def upsert_configuration(document_store_id:, url:, openai_credentials_id:, postgres_credentials_id:)
        response = connection.post "/api/v1/document-store/vectorstore/insert" do |req|
          req.headers["Authorization"] = "Bearer #{ENV["FLOWISE_API_KEY"]}"
          req.body = get_upsert_configuration_body(
            document_store_id: document_store_id,
            url: url,
            openai_credentials_id: openai_credentials_id,
            postgres_credentials_id: postgres_credentials_id
          )
        end

        response.body
      end

      def get_credentials
        response = connection.get "/api/v1/credentials" do |req|
          req.headers["Authorization"] = "Bearer #{ENV["FLOWISE_API_KEY"]}"
        end

        response.body
      end

      def get_templates
        response = connection.get "/api/v1/marketplaces/custom" do |req|
          req.headers["Authorization"] = "Bearer #{ENV["FLOWISE_API_KEY"]}"
        end

        response.body
      end

      def create_chatflow(openai_credentials_id:, document_store_id:, flowdata:, url:)
        response = connection.post "/api/v1/chatflows" do |req|
          req.headers["Authorization"] = "Bearer #{ENV["FLOWISE_API_KEY"]}"
          req.body = {
            "name": url,
            "type": "CHATFLOW",
            "deployed": true,
            "isPublic": true,
            "flowData": flowdata
          }
        end

        response.body
      end

      def wait_for_loaders_to_sync(document_store_id:)
        retries = 5
        while retries > 0
          response = connection.get "/api/v1/document-store/store/#{document_store_id}" do |req|
            req.headers["Authorization"] = "Bearer #{ENV["FLOWISE_API_KEY"]}"
          end

          break if response.body["status"] = "SYNC" || response.body["status"] = "UPSERTED"

          retries -= 1
          raise "All loaders did not reach 'SYNC' status within the retry limit." if retries == 0

          sleep 5
        end

        true
      end

      private

      def normalize_url(url)
        url.downcase.gsub(".", "_")
      end

      def get_upsert_configuration_body(document_store_id:, url:, openai_credentials_id:, postgres_credentials_id:)
        {
          "storeId": document_store_id,

          # Embedding Configuration
          "embeddingName": "openAIEmbeddings",
          "embeddingConfig": {
            "modelName": "text-embedding-ada-002",
            "stripNewLines": "",
            "batchSize": "",
            "timeout": "",
            "basepath": "",
            "credential": openai_credentials_id,
            "dimensions": ""
          },

          # Vector Store Configuration
          "vectorStoreName": "chroma",
          "vectorStoreConfig": {
            "chromaMetadataFilter": "",
            "chromaURL": ENV["CHROMA_URL"],
            "collectionName": normalize_url(url),
            "document": "",
            "embeddings": "",
            "recordManager": "",
            "topK": ""
          },

          # Record Manager Configuration
          "recordManagerName": "postgresRecordManager",
          "recordManagerConfig": {
            "host": ENV["POSTGRES_HOST"],
            "database": ENV["POSTGRES_DATABASE"],
            "port": ENV["POSTGRES_PORT"],
            "additionalConfig": "",
            "tableName": normalize_url(url),
            "cleanup": "full",
            "credential": postgres_credentials_id,
            "namespace": "",
            "sourceIdKey": "source"
          }
        }.to_json
      end
    end
  end
end
