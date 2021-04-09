require "graphiti/rails/auto/version"

module Graphiti::Rails::Auto
  class Resource < Graphiti::Resource
    self.abstract_class = true
    self.adapter = Graphiti::Adapters::ActiveRecord
    self.endpoint_namespace = "/api/v1"

    def self.inherited(subclass)
      super(subclass)
      model_name = subclass.name.delete_suffix("Resource")
      Object.const_set(model_name, Class.new(Record))
      Object.const_set("#{model_name.pluralize}Controller", Class.new(Controller))
    end
  end

  class Record < ActiveRecord::Base
    self.abstract_class = true
  end

  class Controller < ActionController::API
    include Graphiti::Rails::Responders

    before_action :check_params, only: [:index, :show, :update, :create, :destroy]

    respond_to :jsonapi, :json, :xml

    def index
      respond_with(resource.all(params))
    end

    def show
      respond_with(resource.find(post))
    end

    def create
      model = resource.build(params)

      if post.save
        render jsonapi: model, status: 201
      else
        render jsonapi_errors: model
      end
    end

    def update
      model = resource.find(params)

      if model.update_attributes
        render jsonapi: model
      else
        render jsonapi_errors: model
      end
    end

    def destroy
      model = resource.find(params)

      if model.destroy
        render jsonapi: { meta: {} }, status: 200
      else
        render jsonapi_errors: model
      end
    end

    private

    def check_params
      passed_params = params.to_unsafe_h.except(:format, :action, :controller).deep_symbolize_keys
      used_params = Graphiti::Query.new(resource, params).hash
      extra = (passed_params.to_a - used_params.to_a).to_h
      raise "extra params: #{extra}" unless extra.empty?
    end

    def resource
      self.class.name.delete_suffix("Controller").singularize.concat("Resource").constantize
    end
  end
end
