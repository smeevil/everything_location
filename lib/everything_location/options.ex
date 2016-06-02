defmodule EverythingLocation.Options do

  @moduledoc """
  A struct for validating the parameters before passing them to the api
  """

  use Ecto.Model
  import Ecto.Schema

  @required ~w(api_key address1)
  @optional ~w(geocode certify suggest enhance address2 address3 address4 address5 address6 address7 address8 locality administrative_area postal_code country)
  @input_mapping %{
    address1: "Address1",
    address2: "Address2",
    address3: "Address3",
    address4: "Address4",
    address5: "Address5",
    address6: "Address6",
    address7: "Address7",
    address8: "Address8",
    locality: "Locality",
    administrative_area: "AdministrativeArea",
    postal_code: "PostalCode",
    country: "Country"
  }

  schema "Options" do
    field :geocode, :boolean, default: false
    field :certify, :boolean, default: false
    field :suggest, :boolean, default: false
    field :enhance, :boolean, default: true
    field :address1, :string
    field :address2, :string
    field :address3, :string
    field :address4, :string
    field :address5, :string
    field :address6, :string
    field :address7, :string
    field :address8, :string
    field :locality, :string
    field :administrative_area, :string
    field :postal_code, :string
    field :country, :string
    field :api_key, :string
  end

  @doc """
  You can pass a Map with key values which will be cast and validated for use with the EverythingLocation API.
  """
  @spec changeset(%EverythingLocation.Options{}, Map) :: %Ecto.Changeset{}
  def changeset(model, params) do
    model
    |> cast(params, @required, @optional)
  end

  @doc """
  Takes a EverythingLocation.Options struct and converts it to a map of key values formatted for the EverythingLocation API.
  """
  @spec create(%EverythingLocation.Options{}) :: %{} | {:error, string}
  def create({:error, _} = error), do: error
  def create(%EverythingLocation.Options{} = data) do
    %{lqtkey: data.api_key}
    |> add_inputs(data)
    |> add_settings(data)
  end

  defp add_inputs(params, data) do
    inputs = Enum.reduce(@input_mapping, %{}, fn ({k, v}, acc) ->
        Map.put(acc, v, Map.get(data,k))
    end)
    Map.put(params, :input, [inputs])
  end

  defp add_settings(params, data) do
    [:geocode, :certify, :suggest, :enhance] |> Enum.reduce(params, fn(x, acc) ->
      case Map.get(data, x) do
        true -> Map.put(acc, x, "on")
        _ -> acc
      end
    end)
  end
end

