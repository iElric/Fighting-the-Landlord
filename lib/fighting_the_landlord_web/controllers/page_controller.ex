defmodule FightingTheLandlordWeb.PageController do
  use FightingTheLandlordWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
