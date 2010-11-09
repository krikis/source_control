module CouchRest
  module Model
    module DocumentQueries
      module ClassMethods
        # Load a document from the database by id
        # No exceptions will be raised if the document isn't found
        #
        # ==== Returns
        # Object:: if the document was found
        # or
        # Nil::
        # 
        # === Parameters
        # id<String, Integer>:: Document ID
        # db<Database>:: optional option to pass a custom database to use
        def get(id, options = {})
          options[:db] ||= database
          begin
            get!(id, options)
          rescue
            nil
          end
        end
        alias :find :get
        
        # Load a document from the database by id
        # An exception will be raised if the document isn't found
        #
        # ==== Returns
        # Object:: if the document was found
        # or
        # Exception
        # 
        # === Parameters
        # id<String, Integer>:: Document ID
        # db<Database>:: optional option to pass a custom database to use
        def get!(id, options = {})
          db = options[:db] || database
          raise "Missing or empty document ID" if id.to_s.empty?
          doc = db.get id, options
          create_from_database(doc)
        end
        alias :find! :get!
        
      end

    end
  end
end