module Knxbrowse
  class App < Padrino::Application

    menu = [:bus, :ets, :heating, :logic, :site, :timer, :schedule, :settings]

    get :about, :map => '/about' do
      @menu = menu
      render :erb, 'about'
    end
    get :contact , :map => '/test' do
      @title = "Test Page"
      @menu = menu
      render :'page/another'
    end
    get :contact , :map => '/contact' do
      @menu = menu
      render :erb, 'contact'
    end
    get :home, :map => '/' do
      @menu = menu
      render :erb, 'home'
    end

    get :test, :with => :id do
      @path     = :raw
      @title    = "Item"
      @menu     = menu
      # @node   = Node.find_xid(params[:id].to_i)
      @nid      = Index.new(params[:id].to_i)
      render :"node/#{Node.ntype(xid)}"
    end

        get :bus , :map => '/bus' do
      @title = "Bus Interact"
      @menu = menu
      render 'show/bus'
    end
    get :ets do
      @title = "ETS Project Browser"
      @menu  = menu
      # @types = node_types
      render 'index/type'
    end
    get :heating , :map => '/heating' do
      @title = "Heating System Overview"
      @menu = menu
      render 'show/heating'
    end
    get :logic  do
      @title = "Logic Engine"
      @menu = menu
      render :'show/default'
    end
    get :node, :with => :id do
      @path     = :node
      @title    = "Item"
      @menu     = menu
      # @node = Node.find_xid(params[:id].to_i)
      @nid = Index.new(params[:id].to_i)
      # begin
        # render :"node/#{Node.ntype(xid)}"
      # rescue
        render :'node/node'
      # end
    end
    get :raw, :with => :id do
      @path     = :raw
      @title    = "Item"
      @menu     = menu
      xid = params[:id].to_i
      fix_me node_get_data(xid)
      render :'node/node'
    end
    get :schedule do
      @title = "Schedule"
      @menu = menu
      render 'show/schedule'
    end
    get :settings do
      @title = "Settings"
      @menu = menu
      render 'show/settings'
    end
    get :site , :map => '/site' do
      @title = "Site Overview"
      @menu = menu
      @stoptype = "EtsDeviceInstance"
      render 'show/site'
    end
    get :table, :with => :name do
      type = params[:name]
      @title = type
      @menu  = menu
      @data  = sorted_node_summary(type)
      render 'show/type'
    end
    get :timer , :map => '/timer' do
      @title = "Timer"
      @menu = menu
      render 'show/timer'
    end

    # websocket :channel do
    #   on :ping do |message|
    #     binding.pry
    #     send_message(:channel, session['websocket_user'], {pong: true, data: message})
    #     broadcast(:channel, {pong: true, data: message, broadcast: true})
    #   end
    # end
    #


  end
end
