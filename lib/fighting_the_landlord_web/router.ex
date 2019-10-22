defmodule FightingTheLandlordWeb.Router do
  use FightingTheLandlordWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FightingTheLandlordWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/game/:table_name", PageController, :game
    post "/game/:table_name", PageController, :game

  end

  # Other scopes may use custom stacks.
  # scope "/api", FightingTheLandlordWeb do
  #   pipe_through :api
  # end
end
