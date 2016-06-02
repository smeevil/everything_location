defmodule EverythingLocation.Result do
  @moduledoc """
  A struct for accessing the address result information
  """

  use Ecto.Model
  import Ecto.Schema

  @required ~w(verified certainty_percentage)
  @optionals ~w(street city postal_code administrative_area country country_alpha2 country_alpha3 formatted_address)

  @mapping %{
    "DeliveryAddress" => :street,
    "Locality" => :city,
    "PostalCode" => :postal_code,
    "AdministrativeArea" => :administrative_area,
    "CountryName" => :country,
    "ISO3166-2" => :country_alpha2,
    "ISO3166-3" => :country_alpha3,
  }

  schema "result" do
    field :verified, :boolean
    field :formatted_address, :string
    field :certainty_percentage, :integer
    field :street, :string
    field :city, :string
    field :postal_code, :string
    field :administrative_area
    field :country
    field :country_alpha2
    field :country_alpha3
  end

  @doc """
  Takes a map from the EverythingLocation API results and casts them to a EverythingLocation.Result struct
  """
  @spec create(%{}) :: %EverythingLocation.Result{} | {:error, string}
  def create(params) when params == [], do: {:error, "no result"}
  def create(params) do
    %EverythingLocation.Result{}
    |> changeset(params)
    |> apply_changes
  end

  defp changeset(model, params) do
    params = params |> prepare_params
    model
    |> cast(params, @required, @optionals)
  end

  defp prepare_params(params) do
    params
    |> extract_data
    |> Map.put(:certainty_percentage, certainty_percentage(params))
    |> Map.put(:verified, verified?(params))
    |> Map.put(:formatted_address, extract_formatted_address(params))
  end

  defp extract_data(params) do
    Enum.reduce(@mapping, %{}, fn({k,v}, acc) ->
      Map.put(acc, v, Map.get(params, k))
    end)
  end

  defp verified?(%{"AVC" => "V" <> _rest}), do: true
  defp verified?(%{"AVC" => _}), do: false

  defp certainty_percentage(%{"AVC" => avc}) do
    avc
    |> String.split("-")
    |> Enum.at(-1)
    |> String.to_integer
  end

  defp extract_formatted_address(params) do
    params
    |> get_address(1)
    |> List.insert_at(-1, params["CountryName"])
    |> Enum.join("\n")

  end

  defp get_address(params, i) do
    case Map.get(params, "Address" <> to_string(i)) do
      string when is_binary(string) and string != "" -> [string|get_address(params, i + 1)]
      _ -> []
    end
  end
end
