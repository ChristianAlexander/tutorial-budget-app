defmodule BudgieWeb.JoinHTML do
  @moduledoc """
  This module contains pages rendered by JoinController.

  See the `join_html` directory for all templates available.
  """
  use BudgieWeb, :html

  embed_templates "join_html/*"
end
