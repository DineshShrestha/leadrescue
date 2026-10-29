defmodule LeadRescueWeb.ChangesetJSON do
  def errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, options} ->
      Enum.reduce(options, message, fn {key, value}, translated_message ->
        String.replace(translated_message, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
