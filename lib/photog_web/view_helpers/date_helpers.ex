defmodule PhotogWeb.ViewHelpers.DateHelpers do
	@doc """
  	Takes integer and returns string padded to 2 digits
  	"""
	def pad_number(number) do
		number
		|> Integer.to_string
		|> String.pad_leading(2, "0")
	end

	@doc """
  	Takes datetime
  	returns string date in format MM-DD-YYYY HH:MM:SS
  	"""
	def datetime_to_us_format(datetime) do
		pad_number(datetime.month) <> 
		"-" <>
		pad_number(datetime.day) <> 
		"-" <>
		Integer.to_string(datetime.year) <>
		" " <>
		pad_number(datetime.hour) <>
		":" <>
		pad_number(datetime.minute) <>
		":" <>
		pad_number(datetime.second)
	end


end