defmodule EverythingLocation do
  @moduledoc ~S"""
  Everything Location is as SAAS that can verify the correctness of and address, update or correct values, and return a certainty of those values.
  This will also return a formatted address according to the rules of the country of that address.
  For more information see : https://www.everythinglocation.com


  ## Example

      iex> EverythingLocation.verify("Bastion 16, 3823 BP, Amersfoort, Netherlands")
      %EverythingLocation.Result{
        administrative_area: "Utrecht",
        certainty_percentage: 100,
        city: "Amersfoort",
        country: "Netherlands",
        country_alpha2: "NL",
        country_alpha3: "NLD",
        formatted_address: "Bastion 16\n3823 BP  Amersfoort\nNetherlands",
        postal_code: "3823 BP",
        street: "Bastion 16",
        verified: true
      ]
  """

  @base_url "https://api.everythinglocation.com"
  @address_verify_path "/address/verify"

  alias EverythingLocation.Options
  alias EverythingLocation.Result

  @doc """
  Pass an address as string to update/complete it and verify its correctness.
  """
  @spec verify(string) :: {:ok, %EverythingLocation.Result{}} | {:error, string}
  def verify(string) when is_binary(string) and string != "" do
    %{address1: string}
    |> verify
  end

  @doc """
  Pass a Map of options to update/complete and verify its correctness.
  For accepted options, please refer to %EverythingLocation.Options{}.
  You must pass the options as a map, for example ```%{api_key: "my_api_key", address1: "my address"}```
  """
  @spec verify(map) :: {:ok, %EverythingLocation.Result{}} | {:error, string}
  def verify(options) when is_map(options) do
    result = options
    |> insert_api_key_if_missing
    |> create_changeset
    |> apply_changes
    |> Options.create
    |> request
    |> handle_request_result
    |> format_result
  end

  def verify(_), do: {:error, "Invalid input"}

  defp format_result({:ok, result}), do: result |> Result.create
  defp format_result(error), do: error

  defp insert_api_key_if_missing(options) do
    Map.put_new(options, :api_key, Application.get_env(:everything_location, :api_key))
  end

  defp create_changeset(options) do
    Options.changeset(%Options{}, options)
  end

  defp request({:error, _} = error), do: error
  defp request(%{} = options) do
    options = [
      body: Poison.encode!(options),
      headers: ["Accept": "application/json", "Content-Type": "application/json"]
    ]
    try do
      HTTPotion.request :post, @base_url <> @address_verify_path, options
    rescue
      e -> {:error, e}
    end
  end

  defp handle_request_result(%HTTPotion.Response{status_code: 200, body: body} = _response) do
    %{"Status" => "OK", "output" => [address_result|_]} = Poison.decode!(body)
    {:ok, address_result}
  end

  defp handle_request_result({:error, _} = error), do: error
  defp handle_request_result(%HTTPotion.HTTPError{} = error), do: {:error, error}
  defp handle_request_result(%HTTPotion.Response{body: body}) do
    {:ok, result} = Poison.decode(body)
    {:error, result["Error"]}
  end

  defp apply_changes(%{valid?: false} = changeset), do: {:error, changeset.errors}
  defp apply_changes(%{valid?: true} = changeset) do
    changeset |> Ecto.Changeset.apply_changes
  end
end
