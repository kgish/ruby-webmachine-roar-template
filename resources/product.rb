require 'resources/resource'
require 'models/product'
require 'json'

class ProductResource < Resource

  let(:allowed_methods) { %w{GET POST PUT DELETE OPTIONS} }
#  let(:create_path) { "/products/#{create_resource.id}" }
  let(:to_json) { resource_or_collection.to_json }

  def resource_exists?
    if (!request.path_info.has_key?(:id))
      res = true
    else
      @resource = Product.find(request.path_info[:id])
      res = !@resource.nil?
    end
    puts "ProductResource: resource_exists => #{res}"
    res
  end

  def delete_resource
    puts 'ProductResource: delete_resource'
    Product.delete(request.path_info[:id])
    true
  end

  def create_path
#    @resource = Product.from_attributes(:id => $products.length+1)
#    idn = $products.length == 0 ? 1 : $products[$products.length - 1].to_hash['product']['id'].to_i + 1
    puts "ProductResource: create_path id = #{$next_product_id}"
    @resource = Product.from_attributes(:id => $next_product_id); $next_product_id += 1
    @resource.to_json
    @resource.links[:self]
  end

  protected

  # def create_resource
  #   puts 'ProductResource: create_resource'
  #   @resource = Product.create(from_json)
  #   #response.body = as_json
  # end

  def resource
    puts 'ProductResource: resource'
    #@resource ||= Product[id: request.path_info[:id]]
    #@resource ||= $products[request.path_info[:id].to_i - 1]
    @resource ||= Product.find(request.path_info[:id])
  end

  def collection
    puts 'ProductResource: collection'
    @collection ||= Product.all
  end

  def resource_or_collection
    puts 'ProductResource: resource_or_collection'
    @resource || {:products => collection.map(&:to_hash)}
#    resource ? resource.to_hash : {:products => collection.map(&:to_hash)}
  end

  def from_json
    puts "ProductResource: from_json => #{request.method}"
    if request.method === 'PUT'

      # Replace the entire resource, not merge the attributes! That's what PATCH is for.
      # order.destroy if order
      delete_resource if @resource
      # new_order = Order.new(params)
      @resource = Product.from_attributes(:id => $next_product_id); $next_product_id += 1
      # new_order.save(id)
      # response.body = new_order.to_json
      response.body = @resource.to_json
    else
      $products << @resource.from_json(request.body.to_s, :except => [:id])
    end
  end

end

#class ProductResource < Webmachine::Resource
#
#  def to_json
#    @product.to_json
#  end
#end