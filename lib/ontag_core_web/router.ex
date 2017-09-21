defmodule OntagCoreWeb.Router do
  use OntagCoreWeb, :router

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

  scope "/", OntagCoreWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/v1", OntagCoreWeb do
    pipe_through :api

    resources "/sessions", SessionController, only: [:create]
    resources "/entries", EntryController, only: [:create, :index, :show, :delete]
    resources "/tags", TagController, only: [:create, :index, :show, :delete, :update]
    resources "/questions", QuestionController, only: [:create, :index, :show, :delete]
    resources "/annotations", AnnotationController, only: [:create]
    resources "/answers", AnswerController, only: [:create]
  end
end
