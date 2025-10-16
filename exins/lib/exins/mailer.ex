defmodule Exins.Mailer do
  @moduledoc """
  The Exins.Mailer module defines a Swoosh mailer for the application.

  This module is responsible for sending emails and can be configured
  in the `config/config.exs` file.
  """
  use Swoosh.Mailer, otp_app: :exins
end
