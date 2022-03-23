defmodule InvoiceValidatorTest do
  use ExUnit.Case
  doctest InvoiceValidator

  setup do
    Calendar.put_time_zone_database(Tzdata.TimeZoneDatabase) 
  end
  
  test "validate when date and stamp are the same" do
    pac_date = DateTime.utc_now()
    emisor_date = DateTime.utc_now()
    assert InvoiceValidator.validate_dates(emisor_date, pac_date) === {:ok}
  end
  
  test "validate when emisor_date is equals to 3" do
    emisor_date = DateTime.from_naive!(~N[2022-03-23 10:00:00], "Mexico/General")
    pac_date = DateTime.from_naive!(~N[2022-03-20 10:00:00], "Mexico/General")
    assert InvoiceValidator.validate_dates(emisor_date, pac_date) === {:ok}
  end
  
  test "validate when emisor_date > 3" do
    emisor_date = DateTime.from_naive!(~N[2022-03-24 10:00:00], "Mexico/General")
    pac_date = DateTime.from_naive!(~N[2022-03-20 10:00:00], "Mexico/General")
    assert InvoiceValidator.validate_dates(emisor_date, pac_date) === {:error, "Invoice was issued more than 72 hrs before received by the PAC"}
  end
  
  test "validate when emisor_date is equals than 5 mins ahead in time" do
    emisor_date = DateTime.from_naive!(~N[2022-03-20 10:05:00], "Mexico/General")
    pac_date = DateTime.from_naive!(~N[2022-03-20 10:00:00], "Mexico/General")
    assert InvoiceValidator.validate_dates(emisor_date, pac_date) === {:ok}
  end

  test "validate when emisor_date is more than 5 mins ahead in time" do
    emisor_date = DateTime.from_naive!(~N[2022-03-20 10:06:00], "Mexico/General")
    pac_date = DateTime.from_naive!(~N[2022-03-20 10:00:00], "Mexico/General")
    assert InvoiceValidator.validate_dates(emisor_date, pac_date) ===  {:error, "Invoice is more than 5 mins ahead in time"}
  end

  test "validate timezone in tijuana" do
    emisor_date = DateTime.from_naive!(~N[2022-03-20 10:06:00], "America/Tijuana")
    pac_date = DateTime.from_naive!(~N[2022-03-20 10:00:00], "Mexico/General")
    assert InvoiceValidator.validate_dates(emisor_date, pac_date) ===  {:error, "Invoice is more than 5 mins ahead in time"}
  end
end
