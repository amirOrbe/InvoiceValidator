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
    emisor_date = DateTime.from_naive!(~N[2022-03-16 10:00:00], "Mexico/General")
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

  test "locate America/tijuana 72hr before" do
    emisor_date = DateTime.from_naive!(~N[2022-03-20 13:06:31], "America/Tijuana")
    pac_date = DateTime.from_naive!(~N[2022-03-24 15:06:31], "Mexico/General")
    assert InvoiceValidator.validate_dates(emisor_date, pac_date) === {:error, "Invoice was issued more than 72 hrs before received by the PAC"}
  end

  test "locate America/Sinaloa 72hr before" do
    emisor_date = DateTime.from_naive!(~N[2022-03-20 14:06:31], "America/Mazatlan")
    pac_date = DateTime.from_naive!(~N[2022-03-24 15:06:31], "Mexico/General")
    assert InvoiceValidator.validate_dates(emisor_date, pac_date) === {:error, "Invoice was issued more than 72 hrs before received by the PAC"}
  end

  test "locate America/CDMX 72hr before" do
    emisor_date = DateTime.from_naive!(~N[2022-03-20 14:06:31], "America/Mexico_City")
    pac_date = DateTime.from_naive!(~N[2022-03-24 15:06:31], "Mexico/General")
    assert InvoiceValidator.validate_dates(emisor_date, pac_date) === {:error, "Invoice was issued more than 72 hrs before received by the PAC"}
  end

  test "locate America/Qroo 72hr before" do
    emisor_date = DateTime.from_naive!(~N[2022-03-20 14:06:31], "America/Merida")
    pac_date = DateTime.from_naive!(~N[2022-03-24 15:06:31], "Mexico/General")
    assert InvoiceValidator.validate_dates(emisor_date, pac_date) === {:error, "Invoice was issued more than 72 hrs before received by the PAC"}
  end

  test "locate America/tijuana 72hr exact" do
    emisor_date = DateTime.from_naive!(~N[2022-03-20 13:06:31], "America/Tijuana")
    pac_date = DateTime.from_naive!(~N[2022-03-20 15:06:31], "Mexico/General")
    assert InvoiceValidator.validate_dates(emisor_date, pac_date) === {:ok}
  end

  test "locate America/Sinaloa 72hr exact" do
    emisor_date = DateTime.from_naive!(~N[2022-03-24 14:06:31], "America/Mazatlan")
    pac_date = DateTime.from_naive!(~N[2022-03-24 15:06:31], "Mexico/General")
    assert InvoiceValidator.validate_dates(emisor_date, pac_date) === {:ok}
  end

  test "locate America/CDMX 72hr exact" do
    emisor_date = DateTime.from_naive!(~N[2022-03-20 14:06:31], "America/Mexico_City")
    pac_date = DateTime.from_naive!(~N[2022-03-20 15:06:31], "Mexico/General")
    assert InvoiceValidator.validate_dates(emisor_date, pac_date) === {:ok}
  end

  test "locate America/Qroo 72hr exact" do
    emisor_date = DateTime.from_naive!(~N[2022-03-20 14:06:31], "America/Merida")
    pac_date = DateTime.from_naive!(~N[2022-03-20 15:06:31], "Mexico/General")
    assert InvoiceValidator.validate_dates(emisor_date, pac_date) === {:ok}
  end

  test "locate America/Tijuana 5min exact" do
    emisor_date = DateTime.from_naive!(~N[2022-03-23 13:11:35], "America/Tijuana")
    pac_date = DateTime.from_naive!(~N[2022-03-23 13:11:35], "Mexico/General")
    assert InvoiceValidator.validate_dates(emisor_date, pac_date) ===  {:ok}
  end

  test "locate America/Sinaloa 5min exact" do
    emisor_date = DateTime.from_naive!(~N[2022-03-23 14:11:35], "America/Mazatlan")
    pac_date = DateTime.from_naive!(~N[2022-03-23 14:11:35], "Mexico/General")
    assert InvoiceValidator.validate_dates(emisor_date, pac_date) ===  {:ok}
  end

  test "locate America/CDMX 5min exact" do
    emisor_date = DateTime.from_naive!(~N[2022-03-23 15:11:35], "America/Mexico_City")
    pac_date = DateTime.from_naive!(~N[2022-03-23 15:11:35], "Mexico/General")
    assert InvoiceValidator.validate_dates(emisor_date, pac_date) ===  {:ok}
  end

  test "locate America/Qroo 5min exact" do
    emisor_date = DateTime.from_naive!(~N[2022-03-23 16:11:35], "America/Merida")
    pac_date = DateTime.from_naive!(~N[2022-03-23 16:11:35], "Mexico/General")
    assert InvoiceValidator.validate_dates(emisor_date, pac_date) ===  {:ok}
  end

  test "locate America/Tijuana 5min after" do
    emisor_date = DateTime.from_naive!(~N[2022-03-23 13:11:35], "America/Tijuana")
    pac_date = DateTime.from_naive!(~N[2022-03-23 10:00:00], "Mexico/General")
    assert InvoiceValidator.validate_dates(emisor_date, pac_date) ===  {:error, "Invoice is more than 5 mins ahead in time"}
  end

  test "locate America/Sinaloa 5min after" do
    emisor_date = DateTime.from_naive!(~N[2022-03-23 14:11:35], "America/Mazatlan")
    pac_date = DateTime.from_naive!(~N[2022-03-23 10:00:00], "Mexico/General")
    assert InvoiceValidator.validate_dates(emisor_date, pac_date) ===  {:error, "Invoice is more than 5 mins ahead in time"}
  end

  test "locate America/CDMX 5min after" do
    emisor_date = DateTime.from_naive!(~N[2022-03-23 15:11:35], "America/Mexico_City")
    pac_date = DateTime.from_naive!(~N[2022-03-23 10:00:00], "Mexico/General")
    assert InvoiceValidator.validate_dates(emisor_date, pac_date) ===  {:error, "Invoice is more than 5 mins ahead in time"}
  end

  test "locate America/Qroo 5min after" do
    emisor_date = DateTime.from_naive!(~N[2022-03-23 16:11:35], "America/Merida")
    pac_date = DateTime.from_naive!(~N[2022-03-23 10:00:00], "Mexico/General")
    assert InvoiceValidator.validate_dates(emisor_date, pac_date) ===  {:error, "Invoice is more than 5 mins ahead in time"}
  end
end
