# EverythingLocation
Everything Location is as SAAS that can verify the correctness of and address, update or correct values, and return a certainty of those values. This will also return a formatted address according to the rules of the country of that address. 
For more information see : https://www.everythinglocation.com

## Example
```iex
  iex> EverythingLocation.verify("baastion 16, 3833BP Amersfuurt, NL)
  %EverythingLocation.Result{
    administrative_area: "Utrecht", 
    certainty_percentage: 88, 
    city: "Amersfoort",
    country: "Netherlands", 
    country_alpha2: "NL", 
    country_alpha3: "NLD",
    formatted_address: "Bastion 16\n3823 BP  Amersfoort\nNetherlands",   
    postal_code: "3823 BP", 
    street: "Bastion 16", 
    verified: true
  }

```
## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add everything_location to your list of dependencies in `mix.exs`:

        def deps do
          [{:everything_location, "~> 0.0.1"}]
        end

  2. Ensure everything_location is started before your application:

        def application do
          [applications: [:everything_location]]
        end
