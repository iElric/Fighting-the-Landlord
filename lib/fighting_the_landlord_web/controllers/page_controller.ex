defmodule FightingTheLandlordWeb.PageController do
  use FightingTheLandlordWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def game(conn, %{"table_name" => table_name}) do
    render conn, "game.html", table_name: table_name
  end
end
