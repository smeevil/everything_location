defmodule EverythingLocationTest do
  use ExUnit.Case
  use ExVCR.Mock

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
    Application.put_env(:everything_location, :api_key, "test")
    :ok
  end

  test "it requires an address" do
    use_cassette "no_address" do
      assert {:error, "Invalid input"} = EverythingLocation.verify("")
    end
  end

  test "it should return formatted errors when passing invalid params" do
    assert {:error,  [address1: "can't be blank"]} = EverythingLocation.verify(%{})
  end

  test "it should cast the options" do
    assert {:error,  [address1: "is invalid"]} = EverythingLocation.verify(%{address1: 123})
  end

  test "it should handle the situation when everything location is not reachable" do
    use_cassette "no_connection" do
      assert  {:error, %HTTPotion.HTTPError{message: "nxdomain"}} = EverythingLocation.verify("something")
    end
  end

  test "verifies an address" do
    use_cassette "with_api_key" do
      assert %EverythingLocation.Result{
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
      } = EverythingLocation.verify("Bastion 16, 3823 BP, Amersfoort, Netherlands")
    end
  end

  test "invalid address" do
    use_cassette "invalid_address" do
      assert %{verified: false, certainty_percentage: 0} = EverythingLocation.verify("aguamariijn 138, 2407 GH, Alphen aan den water")
    end
  end
end
