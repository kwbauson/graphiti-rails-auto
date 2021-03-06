require "graphiti/rails/auto/version"
require "graphiti"
require "graphiti-rails"
require "vandal_ui"
require "kaminari"
require "responders"

module Graphiti::Rails::Auto
  class Resource < Graphiti::Resource
    self.abstract_class = true
    self.adapter = Graphiti::Adapters::ActiveRecord
    self.endpoint_namespace = "/api/v1"

    def self.route
      model_name = name.delete_suffix("Resource")
      controller_name = "#{model_name.pluralize}Controller"
      Object.const_set(model_name, Class.new(Record)) unless Object.const_defined?(model_name)
      Object.const_set(controller_name, Class.new(Controller)) unless Object.const_defined?(controller_name)

      name.delete_suffix("Resource").underscore.pluralize
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
      respond_with(resource.find(params))
    end

    def create
      model = resource.build(params)

      if model.save
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
      safe_extra_params = [:format, :action, :controller, :id]
      passed_params = params.to_unsafe_h.except(*safe_extra_params).deep_symbolize_keys
      used_params = Graphiti::Query.new(resource, params).hash
      pp used_params
      extra = (passed_params.to_a - used_params.to_a).to_h
      raise "extra params: #{extra}" unless extra.empty?
    end

    def resource
      self.class.name.delete_suffix("Controller").singularize.concat("Resource").constantize
    end
  end
end
