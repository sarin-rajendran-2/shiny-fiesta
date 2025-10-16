defmodule ExinsWeb.Router do
  @moduledoc """
  The ExinsWeb.Router module defines the routes for the application.

  It sets up pipelines for browser and API requests, and defines scopes
  for different parts of the application. It also includes development-only
  routes for the LiveDashboard and Swoosh mailbox preview.
  """
  use ExinsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ExinsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExinsWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/contacts", ContactLive.Index, :index
    live "/contacts/new", ContactLive.Form, :new
    live "/contacts/:id/edit", ContactLive.Form, :edit

    live "/contacts/:id", ContactLive.Show, :show
    live "/contacts/:id/show/edit", ContactLive.Show, :edit

    live "/policies", PolicyLive.Index, :index
    live "/policies/new", PolicyLive.Form, :new
    live "/policies/:id/edit", PolicyLive.Form, :edit

    live "/policies/:id", PolicyLive.Show, :show
    live "/policies/:id/show/edit", PolicyLive.Show, :edit

    live "/applicants", ApplicantLive.Index, :index
    live "/applicants/new", ApplicantLive.Form, :new
    live "/applicants/:id/edit", ApplicantLive.Form, :edit

    live "/applicants/:id", ApplicantLive.Show, :show
    live "/applicants/:id/show/edit", ApplicantLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", ExinsWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:exins, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ExinsWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
