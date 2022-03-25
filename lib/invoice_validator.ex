defmodule InvoiceValidator do
  @moduledoc """
  Documentation for `InvoiceValidator`.
  """

  def validate_dates(
        %DateTime{day: emisor_day, minute: emisor_minute} = _emisor_date,
        %DateTime{day: pac_day, minute: pac_minute} = _pac_date
      ) do
    IO.inspect(emisor_day - pac_day)

    cond do
        (emisor_day - pac_day) < -3 ->
        {:error, "Invoice was issued more than 72 hrs before received by the PAC"}

      emisor_minute - pac_minute > 5 ->
        {:error, "Invoice is more than 5 mins ahead in time"}

      true ->
        {:ok}
    end
  end
end
